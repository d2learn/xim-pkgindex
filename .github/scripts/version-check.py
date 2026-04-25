#!/usr/bin/env python3
"""Dry-run upstream version checker for xim-pkgindex.

Scans every `pkgs/**/*.lua` for an opt-in `url_template` field on any
platform inside the `xpm` table. For each opted-in package, queries the
GitHub Releases API for the latest tag, compares against the version
recorded in `xpm.<plat>.["latest"].ref`, and prints a JSON report of
every package whose upstream has moved ahead.

This script does **not** modify any package description and does **not**
open any pull request. Phase 2 will add those steps once Phase 1 has
proved its output shape and stability.

See docs/spec/url-template.md for the contract this script consumes.

Usage
-----

    python3 .github/scripts/version-check.py [--workspace <path>]
                                              [--token <github-token>]

Output is JSON on stdout. Exit code is 0 on a clean run regardless of
whether updates were found; non-zero only on operational errors (e.g.
a malformed lua, a 5xx from GitHub).
"""

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any


# Match every "<word> = { ... }" block at top-level of `xpm = { ... }`,
# where <word> is a platform name. Naive but enough for the limited set
# of well-formed lua files this repo contains.
_PLATFORM_KEYS = ("linux", "macosx", "windows")


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def find_xpm_block(lua: str) -> str | None:
    """Return the body of the `xpm = { ... }` table, or None if absent."""
    m = re.search(r"\bxpm\s*=\s*\{", lua)
    if not m:
        return None
    start = m.end()
    depth = 1
    i = start
    while i < len(lua) and depth > 0:
        c = lua[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
        i += 1
    if depth != 0:
        return None
    return lua[start : i - 1]


def find_platform_block(xpm_body: str, platform: str) -> str | None:
    """Return the body of `<platform> = { ... }` from inside xpm."""
    m = re.search(rf"\b{re.escape(platform)}\s*=\s*\{{", xpm_body)
    if not m:
        return None
    start = m.end()
    depth = 1
    i = start
    while i < len(xpm_body) and depth > 0:
        c = xpm_body[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
        i += 1
    if depth != 0:
        return None
    return xpm_body[start : i - 1]


def extract_url_template(platform_body: str) -> str | None:
    m = re.search(r'\burl_template\s*=\s*"([^"]+)"', platform_body)
    return m.group(1) if m else None


def extract_latest_ref(platform_body: str) -> str | None:
    m = re.search(
        r'\["latest"\]\s*=\s*\{\s*ref\s*=\s*"([^"]+)"',
        platform_body,
    )
    return m.group(1) if m else None


def extract_field(lua: str, name: str) -> str | None:
    m = re.search(rf'\b{re.escape(name)}\s*=\s*"([^"]+)"', lua)
    return m.group(1) if m else None


def parse_github_repo(repo_url: str) -> tuple[str, str] | None:
    m = re.match(r"https?://github\.com/([\w.-]+)/([\w.-]+?)(?:\.git)?/?$", repo_url)
    return (m.group(1), m.group(2)) if m else None


def github_latest_release(owner: str, name: str, token: str | None) -> dict[str, Any]:
    url = f"https://api.github.com/repos/{owner}/{name}/releases/latest"
    req = urllib.request.Request(url, headers={"User-Agent": "xim-pkgindex-version-check"})
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read())


def normalize_version(tag: str) -> str:
    return tag[1:] if tag.startswith("v") else tag


def check_package(lua_path: Path, token: str | None) -> dict[str, Any] | None:
    """Return a JSON-serializable record for this package, or None to skip.

    Status values:
      "skip"          — opt-out (no url_template anywhere)
      "skip-no-repo"  — repo missing or not on GitHub
      "skip-bad-template" — template missing the {version} placeholder
      "up-to-date"    — opted in, upstream version matches current latest
      "update-available" — opted in, upstream is ahead of current latest
      "error"         — any operational failure (network, HTTP, parse)
    """
    text = read_text(lua_path)
    xpm = find_xpm_block(text)
    if not xpm:
        return None

    platforms: dict[str, dict[str, str]] = {}
    for plat in _PLATFORM_KEYS:
        body = find_platform_block(xpm, plat)
        if not body:
            continue
        tmpl = extract_url_template(body)
        ref = extract_latest_ref(body)
        if tmpl or ref:
            platforms[plat] = {"url_template": tmpl, "ref": ref}

    if not any(p.get("url_template") for p in platforms.values()):
        # No opt-in marker on any platform → manual maintenance.
        return None

    # Validate each opted-in template has the placeholder.
    for plat, info in platforms.items():
        if info.get("url_template") and "{version}" not in info["url_template"]:
            return {
                "pkg": lua_path.stem,
                "path": str(lua_path),
                "status": "skip-bad-template",
                "reason": f"{plat}.url_template does not contain {{version}}",
            }

    # All opted-in platforms must agree on the current version.
    current_versions = {
        plat: info["ref"]
        for plat, info in platforms.items()
        if info.get("url_template") and info.get("ref")
    }
    if len(set(current_versions.values())) != 1:
        return {
            "pkg": lua_path.stem,
            "path": str(lua_path),
            "status": "skip-bad-template",
            "reason": f"per-platform 'latest' refs disagree: {current_versions}",
        }
    current = next(iter(current_versions.values()))

    repo_url = extract_field(text, "repo")
    if not repo_url:
        return {
            "pkg": lua_path.stem,
            "path": str(lua_path),
            "status": "skip-no-repo",
            "reason": "package.repo missing",
        }
    parsed = parse_github_repo(repo_url)
    if not parsed:
        return {
            "pkg": lua_path.stem,
            "path": str(lua_path),
            "status": "skip-no-repo",
            "reason": f"package.repo is not a GitHub URL ({repo_url})",
        }

    owner, name = parsed
    try:
        rel = github_latest_release(owner, name, token)
    except urllib.error.HTTPError as e:
        return {
            "pkg": lua_path.stem,
            "path": str(lua_path),
            "status": "error",
            "reason": f"GitHub HTTP {e.code}: {e.reason}",
        }
    except (urllib.error.URLError, TimeoutError) as e:
        return {
            "pkg": lua_path.stem,
            "path": str(lua_path),
            "status": "error",
            "reason": f"network error: {e}",
        }

    tag = rel.get("tag_name", "")
    if not tag:
        return {
            "pkg": lua_path.stem,
            "path": str(lua_path),
            "status": "error",
            "reason": "GitHub release has no tag_name",
        }
    upstream = normalize_version(tag)

    record: dict[str, Any] = {
        "pkg": lua_path.stem,
        "path": str(lua_path),
        "repo": f"{owner}/{name}",
        "tag": tag,
        "current": current,
        "upstream": upstream,
    }

    if upstream == current:
        record["status"] = "up-to-date"
        return record

    record["status"] = "update-available"
    proposed: dict[str, str] = {}
    for plat, info in platforms.items():
        if info.get("url_template"):
            proposed[plat] = info["url_template"].replace("{version}", upstream)
    record["proposed_urls"] = proposed
    return record


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--workspace",
        default=os.environ.get("GITHUB_WORKSPACE") or ".",
        help="Repo root (defaults to GITHUB_WORKSPACE or '.').",
    )
    ap.add_argument(
        "--token",
        default=os.environ.get("GITHUB_TOKEN"),
        help="GitHub API token (for rate-limit headroom). "
        "Falls back to $GITHUB_TOKEN.",
    )
    args = ap.parse_args()

    pkg_dir = Path(args.workspace) / "pkgs"
    if not pkg_dir.is_dir():
        print(f"error: {pkg_dir} not found", file=sys.stderr)
        return 2

    records: list[dict[str, Any]] = []
    skipped = 0
    for lua in sorted(pkg_dir.glob("*/*.lua")):
        rec = check_package(lua, args.token)
        if rec is None:
            skipped += 1
            continue
        records.append(rec)

    summary = {
        "scanned": len(records) + skipped,
        "skipped_manual": skipped,
        "checked": len(records),
        "update_available": sum(1 for r in records if r["status"] == "update-available"),
        "up_to_date": sum(1 for r in records if r["status"] == "up-to-date"),
        "errors": sum(1 for r in records if r["status"] in ("error", "skip-no-repo", "skip-bad-template")),
    }
    out = {"summary": summary, "packages": records}
    print(json.dumps(out, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
