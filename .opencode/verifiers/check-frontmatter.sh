#!/usr/bin/env bash
# C1 — Frontmatter contract verifier
# Checks every .opencode/agent/*.md has required fields and audit agents are on gpt-5.4

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AGENT_DIR="$ROOT/.opencode/agent"
FAIL=0
AUDIT_AGENTS=("citation-verifier" "coverage-critic" "summary-auditor" "novelty-checker")

is_audit_agent() {
  local name="$1"
  for a in "${AUDIT_AGENTS[@]}"; do
    [[ "$name" == "$a" ]] && return 0
  done
  return 1
}

for f in "$AGENT_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f" .md)"
  fm="$(awk '/^---$/{c++; next} c==1{print} c>=2{exit}' "$f")"

  for field in description mode model tools permission; do
    if ! grep -q "^$field:" <<<"$fm"; then
      echo "FAIL [C1] $base: missing frontmatter field '$field'"
      FAIL=$((FAIL+1))
    fi
  done

  model="$(grep '^model:' <<<"$fm" | sed 's/^model:[[:space:]]*//')"
  if is_audit_agent "$base"; then
    if [[ "$model" != "github-copilot/gpt-5.4" ]]; then
      echo "FAIL [C1] $base: audit agent must use github-copilot/gpt-5.4 (got: $model)"
      FAIL=$((FAIL+1))
    fi
    if ! grep -qE '^\s*write:\s*false' "$f"; then
      echo "FAIL [C1] $base: audit agent must have tools.write=false"
      FAIL=$((FAIL+1))
    fi
    if ! grep -qE '^\s*edit:\s*false' "$f"; then
      echo "FAIL [C1] $base: audit agent must have tools.edit=false"
      FAIL=$((FAIL+1))
    fi
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C1] frontmatter contract"
else
  echo "TOTAL FAIL [C1]: $FAIL"
  exit 1
fi
