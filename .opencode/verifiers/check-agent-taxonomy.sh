#!/usr/bin/env bash
# C11 — Agent taxonomy verifier

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AGENT_DIR="$ROOT/.opencode/agent"
FAIL=0

AUDIT_AGENTS=("citation-verifier" "coverage-critic" "summary-auditor" "novelty-checker" "concept-auditor" "meta-optimizer")
RESEARCH_CLASS_AGENTS=("deep-dive" "theory-mapper" "research-planner" "literature-searcher" "writing-drafter" "research-ideator" "paper-summarizer" "concept-explainer" "lit-review-builder")
VAULT_PERSISTENCE_AGENTS=("theory-mapper" "literature-searcher" "writing-drafter" "paper-summarizer" "concept-explainer" "lit-review-builder" "research-ideator" "deep-dive" "zotero-curator" "data-extractor")
RUNTIME_OUTPUT_AGENTS=("paper-fetcher" "data-extractor" "meta-optimizer")
ORCHESTRATOR_AGENTS=("deep-dive")

contains_name() {
  local name="$1"
  shift
  local arr=("$@")
  for item in "${arr[@]}"; do
    [[ "$name" == "$item" ]] && return 0
  done
  return 1
}

for f in "$AGENT_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f" .md)"
  fm="$(awk '/^---$/{c++; next} c==1{print} c>=2{exit}' "$f")"

  if contains_name "$base" "${AUDIT_AGENTS[@]}"; then
    model="$(grep '^model:' <<<"$fm" | sed 's/^model:[[:space:]]*//')"
    if [[ "$model" != "github-copilot/gpt-5.4" ]]; then
      echo "FAIL [C11] $base: audit agent must use github-copilot/gpt-5.4"
      FAIL=$((FAIL+1))
    fi
    if ! grep -q '^fallback_model:' <<<"$fm"; then
      echo "FAIL [C11] $base: audit agent must declare fallback_model"
      FAIL=$((FAIL+1))
    fi
    if [[ "$base" == "meta-optimizer" ]]; then
      if ! grep -q '\.opencode/proposals/' "$f"; then
        echo "FAIL [C11] meta-optimizer: must write proposals under .opencode/proposals/"
        FAIL=$((FAIL+1))
      fi
    else
      if grep -qE 'write:[[:space:]]*true' "$f"; then
        echo "FAIL [C11] $base: audit agent must not declare write:true"
        FAIL=$((FAIL+1))
      fi
    fi
  fi

  if contains_name "$base" "${RESEARCH_CLASS_AGENTS[@]}"; then
    if ! grep -q '.opencode/memory/phd-doctrine.md' "$f"; then
      echo "FAIL [C11] $base: research-class agent missing doctrine reference"
      FAIL=$((FAIL+1))
    fi
    if ! grep -q '^## Output Language' "$f"; then
      echo "FAIL [C11] $base: research-class agent missing Output Language section"
      FAIL=$((FAIL+1))
    fi
  fi

  if contains_name "$base" "${VAULT_PERSISTENCE_AGENTS[@]}"; then
    if grep -q '/Users/xuyongheng/Obsidian-Vault/' "$f"; then
      if ! grep -qE '/Users/xuyongheng/Obsidian-Vault/(Inbox|Notes|Writing)/' "$f"; then
        echo "FAIL [C11] $base: vault-persistence agent uses invalid vault path"
        FAIL=$((FAIL+1))
      fi
    else
      echo "FAIL [C11] $base: vault-persistence agent missing explicit vault path"
      FAIL=$((FAIL+1))
    fi
    if ! grep -qi 'deep Chinese' "$f"; then
      echo "FAIL [C11] $base: vault-persistence agent missing Chinese-first rule"
      FAIL=$((FAIL+1))
    fi
  fi

  if contains_name "$base" "${RUNTIME_OUTPUT_AGENTS[@]}"; then
    if [[ "$base" == "paper-fetcher" ]]; then
      if ! grep -qE 'arxiv_cache/|outputs/' "$f"; then
        echo "FAIL [C11] paper-fetcher: runtime outputs must stay under arxiv_cache/ or outputs/"
        FAIL=$((FAIL+1))
      fi
    fi
    if [[ "$base" == "data-extractor" ]]; then
      if ! grep -q 'outputs/extractions/' "$f"; then
        echo "FAIL [C11] data-extractor: runtime output JSON must stay under outputs/"
        FAIL=$((FAIL+1))
      fi
    fi
    if [[ "$base" == "meta-optimizer" ]]; then
      if ! grep -q '\.opencode/proposals/' "$f"; then
        echo "FAIL [C11] meta-optimizer: runtime outputs must stay under .opencode/proposals/"
        FAIL=$((FAIL+1))
      fi
    fi
  fi

  if grep -qE '^[[:space:]]+task:[[:space:]]*true' "$f"; then
    if ! contains_name "$base" "${ORCHESTRATOR_AGENTS[@]}"; then
      echo "FAIL [C11] $base: task:true only allowed for orchestrator agents"
      FAIL=$((FAIL+1))
    fi
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C11] agent taxonomy contract"
else
  echo "TOTAL FAIL [C11]: $FAIL"
  exit 1
fi
