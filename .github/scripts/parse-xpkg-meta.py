"""Emit a small JSON meta object for a single .lua xpkg file.

Used by the Windows CI job to decide whether to install/test a changed
package and what programs to look for afterwards.

Fields in the output:
  name         package name (string)
  programs     list of program names declared by the package
  is_ref       true if this file is a thin ref to another package
  has_windows  true if the package declares a windows branch in xpm
"""
import json
import sys
from pathlib import Path

repo_root = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(repo_root))

from tests.lib.xpkg_parser import parse_xpkg


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: parse-xpkg-meta.py <path-to-lua>", file=sys.stderr)
        return 2
    meta = parse_xpkg(sys.argv[1])
    print(json.dumps({
        "name": meta.name,
        "type": meta.pkg_type,
        "programs": list(meta.programs),
        "is_ref": bool(meta.is_ref),
        "has_windows": bool(meta.platforms.get("windows")),
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
