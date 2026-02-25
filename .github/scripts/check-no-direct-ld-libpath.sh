#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

# Temporary allowlist during migration window.
ALLOWLIST=(
)

is_allowlisted() {
  local file="$1"
  for item in "${ALLOWLIST[@]}"; do
    if [[ "$file" == "$item" ]]; then
      return 0
    fi
  done
  return 1
}

if command -v rg >/dev/null 2>&1; then
  matches="$(rg -n "LD_LIBRARY_PATH\\s*=" "pkgs" --glob "*.lua" || true)"
elif command -v grep >/dev/null 2>&1; then
  matches="$(grep -R -n --include="*.lua" -E "LD_LIBRARY_PATH[[:space:]]*=" pkgs || true)"
else
  echo "::error::Neither rg nor grep is available; cannot enforce LD_LIBRARY_PATH policy check."
  exit 1
fi

if [[ -z "$matches" ]]; then
  echo "LD_LIBRARY_PATH direct assignment check: PASS (no direct usage found)."
  exit 0
fi

failed=0
declare -A warned_allowlisted=()

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  file="${line%%:*}"

  if is_allowlisted "$file"; then
    if [[ -z "${warned_allowlisted[$file]:-}" ]]; then
      echo "::warning file=${file}::Legacy direct LD_LIBRARY_PATH usage is temporarily allowlisted. Please migrate to XLINGS_EXTRA_LIBPATH."
      warned_allowlisted["$file"]=1
    fi
    continue
  fi

  echo "::error file=${file}::Direct LD_LIBRARY_PATH assignment is disallowed in xpkg definitions. Use XLINGS_PROGRAM_LIBPATH/XLINGS_EXTRA_LIBPATH inputs instead."
  failed=1
done <<< "$matches"

if [[ "$failed" -ne 0 ]]; then
  echo "LD_LIBRARY_PATH direct assignment check: FAIL"
  exit 1
fi

echo "LD_LIBRARY_PATH direct assignment check: PASS (only allowlisted legacy usages found)."

