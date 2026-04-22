#!/usr/bin/env bash
# C3 — Audit contract verifier
# Every research command must declare a Mandatory post-audit step (or document --no-audit)
# /deep-dive must NOT permit --no-audit

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CMD_DIR="$ROOT/.opencode/command"
FAIL=0
EXEMPT=("init" "weekly-report")

is_exempt() {
  local name="$1"
  for e in "${EXEMPT[@]}"; do
    [[ "$name" == "$e" ]] && return 0
  done
  return 1
}

for f in "$CMD_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f" .md)"
  is_exempt "$base" && continue

  if ! grep -qiE 'mandatory.{0,5}post-?audit|mandatory.{0,5}so-what gate|mandatory.{0,5}mini-audit|mandatory.{0,5}full-pipeline' "$f"; then
    echo "FAIL [C3] $base: no mandatory audit step documented"
    FAIL=$((FAIL+1))
  fi

  if [[ "$base" == "deep-dive" ]]; then
    if grep -qE 'no-audit.*supported|--no-audit' "$f" && ! grep -qE 'not supported|disallows.*no-audit|--no-audit.{0,30}not supported' "$f"; then
      echo "FAIL [C3] deep-dive: --no-audit must be explicitly forbidden"
      FAIL=$((FAIL+1))
    fi
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C3] audit contract"
else
  echo "TOTAL FAIL [C3]: $FAIL"
  exit 1
fi
