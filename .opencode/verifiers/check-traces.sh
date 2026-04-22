#!/usr/bin/env bash
# C4 — Trace contract verifier
# Validates that JSONL trace files in .opencode/traces/YYYY-MM-DD/ are parseable

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TRACE_DIR="$ROOT/.opencode/traces"
FAIL=0
CHECKED=0

if [[ ! -d "$TRACE_DIR" ]]; then
  echo "INFO [C4] no traces directory yet — nothing to verify"
  exit 0
fi

# Check last 7 days
for d in $(find "$TRACE_DIR" -maxdepth 1 -type d -mtime -7 2>/dev/null); do
  [[ "$d" == "$TRACE_DIR" ]] && continue
  for f in "$d"/*.jsonl; do
    [[ -f "$f" ]] || continue
    CHECKED=$((CHECKED+1))
    line_no=0
    while IFS= read -r line; do
      line_no=$((line_no+1))
      [[ -z "$line" ]] && continue
      if ! echo "$line" | python3 -c 'import sys,json;json.loads(sys.stdin.read())' 2>/dev/null; then
        echo "FAIL [C4] $f line $line_no: not valid JSON"
        FAIL=$((FAIL+1))
      fi
    done < "$f"
  done
done

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C4] trace contract ($CHECKED files checked)"
else
  echo "TOTAL FAIL [C4]: $FAIL"
  exit 1
fi
