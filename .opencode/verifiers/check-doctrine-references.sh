#!/usr/bin/env bash
# C6 — Doctrine reference verifier
# Research-class agents must reference .opencode/memory/phd-doctrine.md

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AGENT_DIR="$ROOT/.opencode/agent"
FAIL=0

# Research-class agents that exist or will exist
RESEARCH_AGENTS=("research-ideator" "novelty-checker" "lit-review-builder" "deep-dive")
# theory-mapper added in P4

for a in "${RESEARCH_AGENTS[@]}"; do
  f="$AGENT_DIR/$a.md"
  [[ -f "$f" ]] || { echo "INFO [C6] $a not yet created"; continue; }
  if ! grep -qE 'phd-doctrine\.md|PhD doctrine|\.opencode/memory/phd-doctrine' "$f"; then
    echo "FAIL [C6] $a: must reference .opencode/memory/phd-doctrine.md"
    FAIL=$((FAIL+1))
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C6] doctrine contract"
else
  echo "TOTAL FAIL [C6]: $FAIL"
  exit 1
fi
