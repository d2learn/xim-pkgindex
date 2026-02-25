#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

# Files that are allowed to set LD_LIBRARY_PATH directly (documented exceptions).
# musl-gcc.lua: musl-ldd and musl-loader are alias wrappers invoking the musl
# dynamic linker, where RPATH cannot apply.
LD_ALLOWLIST=(
  "pkgs/m/musl-gcc.lua"
)

is_ld_allowlisted() {
  local file="$1"
  for item in "${LD_ALLOWLIST[@]}"; do
    if [[ "$file" == "$item" ]]; then
      return 0
    fi
  done
  return 1
}

search() {
  local pattern="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -n "$pattern" "pkgs" --glob "*.lua" || true
  elif command -v grep >/dev/null 2>&1; then
    grep -R -n --include="*.lua" -E "$pattern" pkgs || true
  else
    echo "::error::Neither rg nor grep is available; cannot enforce policy check."
    exit 1
  fi
}

failed=0

# --- Check 1: Reject deprecated XLINGS_PROGRAM_LIBPATH / XLINGS_EXTRA_LIBPATH ---
deprecated_matches="$(search "XLINGS_(PROGRAM|EXTRA)_LIBPATH")"
if [[ -n "$deprecated_matches" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    file="${line%%:*}"
    echo "::error file=${file}::Deprecated field found. XLINGS_PROGRAM_LIBPATH and XLINGS_EXTRA_LIBPATH have been removed. Library paths are now handled by elfpatch RPATH."
    failed=1
  done <<< "$deprecated_matches"
fi

# --- Check 2: LD_LIBRARY_PATH only in documented exceptions ---
ld_matches="$(search "LD_LIBRARY_PATH\s*=")"
if [[ -n "$ld_matches" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    file="${line%%:*}"

    if is_ld_allowlisted "$file"; then
      continue
    fi

    echo "::error file=${file}::Direct LD_LIBRARY_PATH assignment is disallowed in xpkg definitions. Library paths should use elfpatch RPATH instead."
    failed=1
  done <<< "$ld_matches"
fi

if [[ "$failed" -ne 0 ]]; then
  echo "xpkg libpath policy check: FAIL"
  exit 1
fi

echo "xpkg libpath policy check: PASS"
