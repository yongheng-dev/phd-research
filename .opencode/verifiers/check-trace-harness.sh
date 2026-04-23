#!/usr/bin/env bash
# C10 — Trace harness verifier
# Enforces minimum trace schema in docs and in recent JSONL trace files.

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CMD_DIR="$ROOT/.opencode/command"
AGENT_DIR="$ROOT/.opencode/agent"
TRACE_DIR="$ROOT/.opencode/traces"
FAIL=0

AUDIT_AGENTS=("citation-verifier" "coverage-critic" "summary-auditor" "novelty-checker" "concept-auditor" "meta-optimizer")

is_audit_agent() {
  local name="$1"
  for a in "${AUDIT_AGENTS[@]}"; do
    [[ "$name" == "$a" ]] && return 0
  done
  return 1
}

for f in "$CMD_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f" .md)"
  if grep -q '^## Trace' "$f"; then
    if ! grep -qE '\{"ts":"<iso>|\{"ts":"<ISO-8601>' "$f"; then
      echo "FAIL [C10] $base: trace section missing ts field example"
      FAIL=$((FAIL+1))
    fi
    if ! grep -q '"command":"/'"$base"'"' "$f"; then
      echo "FAIL [C10] $base: trace section missing command field example"
      FAIL=$((FAIL+1))
    fi
    if ! grep -q '"audit":' "$f"; then
      echo "FAIL [C10] $base: trace section missing audit field example"
      FAIL=$((FAIL+1))
    fi
  fi
done

for f in "$AGENT_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f" .md)"
  if grep -qE '^## Trace|Trace logging \(mandatory\)' "$f"; then
    if ! grep -qE '\{"ts":"<iso>|\{"ts":"<ISO-8601>' "$f"; then
      echo "FAIL [C10] $base: trace section missing ts field example"
      FAIL=$((FAIL+1))
    fi
    if ! grep -q '"agent":"'"$base"'"' "$f"; then
      echo "FAIL [C10] $base: trace section missing agent field example"
      FAIL=$((FAIL+1))
    fi
    if is_audit_agent "$base"; then
      if ! grep -q '"model":' "$f"; then
        echo "FAIL [C10] $base: audit-agent trace section missing model field example"
        FAIL=$((FAIL+1))
      fi
      if grep -q 'audit.degraded' "$f"; then
        if ! grep -qE '\{"event":"audit\.degraded","agent":"<this-agent>","reason":"primary_unavailable","fallback":"github-copilot/' "$f"; then
          echo "FAIL [C10] $base: fallback trace example incomplete"
          FAIL=$((FAIL+1))
        fi
      fi
    fi
  fi
done

if [[ -d "$TRACE_DIR" ]]; then
  while IFS= read -r trace_file; do
    [[ -f "$trace_file" ]] || continue
    base_name="$(basename "$trace_file")"
    line_no=0
    while IFS= read -r line; do
      line_no=$((line_no+1))
      [[ -z "$line" ]] && continue
      if [[ "$base_name" == session-* ]]; then
        if ! echo "$line" | python3 -c 'import sys,json; obj=json.loads(sys.stdin.read()); assert isinstance(obj, dict); assert "ts" in obj; assert "event" in obj' >/dev/null 2>&1; then
          echo "FAIL [C10] $base_name line $line_no: session trace missing ts/event"
          FAIL=$((FAIL+1))
        fi
        continue
      fi
      if ! echo "$line" | python3 -c 'import sys,json; obj=json.loads(sys.stdin.read()); assert isinstance(obj, dict); assert ("ts" in obj) or (obj.get("event") == "audit.degraded"); assert ("command" in obj) or ("agent" in obj); print("ok")' >/dev/null 2>&1; then
        echo "FAIL [C10] $base_name line $line_no: missing required trace keys"
        FAIL=$((FAIL+1))
      fi
      if [[ "$base_name" == *"-verifier.jsonl" || "$base_name" == "coverage-critic.jsonl" || "$base_name" == "summary-auditor.jsonl" || "$base_name" == "novelty-checker.jsonl" || "$base_name" == "concept-auditor.jsonl" || "$base_name" == "meta-optimizer.jsonl" ]]; then
        if ! echo "$line" | python3 -c 'import sys,json; obj=json.loads(sys.stdin.read()); import sys as _s; _s.exit(0 if (obj.get("event") == "audit.degraded" or "model" in obj) else 1)' >/dev/null 2>&1; then
          echo "FAIL [C10] $base_name line $line_no: audit trace missing model field"
          FAIL=$((FAIL+1))
        fi
      fi
      if [[ "$base_name" == *.jsonl && "$base_name" != *session-* ]]; then
        if echo "$line" | python3 -c 'import sys,json; obj=json.loads(sys.stdin.read()); import sys as _s; _s.exit(0 if ("command" not in obj or "audit" in obj or obj.get("event") == "audit.degraded") else 1)' >/dev/null 2>&1; then
          :
        else
          if echo "$line" | python3 -c 'import sys,json; obj=json.loads(sys.stdin.read()); import sys as _s; _s.exit(0 if "command" in obj else 1)' >/dev/null 2>&1; then
            echo "FAIL [C10] $base_name line $line_no: command trace missing audit field"
            FAIL=$((FAIL+1))
          fi
        fi
      fi
    done < "$trace_file"
  done < <(find "$TRACE_DIR" -type f -name '*.jsonl' 2>/dev/null)
fi

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C10] trace harness contract"
else
  echo "TOTAL FAIL [C10]: $FAIL"
  exit 1
fi
