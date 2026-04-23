#!/usr/bin/env bash
# C8 — Prompt harness verifier
# Enforces prompt-level consistency for research agents:
# - Chinese-first output policy is explicit where required
# - legacy vault paths are not referenced
# - research-class agents reference doctrine
# - stale English-first prompt rules are gone

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AGENT_DIR="$ROOT/.opencode/agent"
FAIL=0

LANGUAGE_REQUIRED_AGENTS=(
  "paper-summarizer"
  "literature-searcher"
  "coverage-critic"
  "citation-verifier"
  "summary-auditor"
  "research-planner"
  "concept-explainer"
  "lit-review-builder"
  "novelty-checker"
  "research-ideator"
  "deep-dive"
  "theory-mapper"
  "writing-drafter"
  "zotero-curator"
  "data-extractor"
)

DOCTRINE_REQUIRED_AGENTS=(
  "paper-summarizer"
  "literature-searcher"
  "research-planner"
  "concept-explainer"
  "lit-review-builder"
  "novelty-checker"
  "research-ideator"
  "deep-dive"
  "theory-mapper"
  "writing-drafter"
)

requires_language_policy() {
  local name="$1"
  for a in "${LANGUAGE_REQUIRED_AGENTS[@]}"; do
    [[ "$name" == "$a" ]] && return 0
  done
  return 1
}

requires_doctrine() {
  local name="$1"
  for a in "${DOCTRINE_REQUIRED_AGENTS[@]}"; do
    [[ "$name" == "$a" ]] && return 0
  done
  return 1
}

for f in "$AGENT_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f" .md)"

  if grep -qE 'Communicate in English|Report in English|written in English|translated to English|Abstract \(English\)|Translated title|Paper English Title|Paper Notes/|Obsidian-Vault/Theory Maps/' "$f"; then
    echo "FAIL [C8] $base: contains stale English-first or legacy vault wording"
    FAIL=$((FAIL+1))
  fi

  if requires_language_policy "$base"; then
    if ! grep -q '^## Output Language' "$f"; then
      echo "FAIL [C8] $base: missing '## Output Language' section"
      FAIL=$((FAIL+1))
    fi
    if ! grep -qiE 'deep Chinese' "$f"; then
      echo "FAIL [C8] $base: missing Chinese-first output rule"
      FAIL=$((FAIL+1))
    fi
    if ! grep -qiE 'original language' "$f"; then
      echo "FAIL [C8] $base: missing paper-title original-language rule"
      FAIL=$((FAIL+1))
    fi
    if ! grep -qiE 'English academic register|API parameters remain in English|query strings remain in English|DOI fields.*English|metadata.*English' "$f"; then
      echo "FAIL [C8] $base: missing rule for English queries/parameters/metadata"
      FAIL=$((FAIL+1))
    fi
  fi

  if requires_doctrine "$base"; then
    if ! grep -q '.opencode/memory/phd-doctrine.md' "$f"; then
      echo "FAIL [C8] $base: missing doctrine reference"
      FAIL=$((FAIL+1))
    fi
  fi

  if grep -q '/Users/xuyongheng/Obsidian-Vault/' "$f"; then
    if grep -qE '/Users/xuyongheng/Obsidian-Vault/(Inbox|Notes|Writing)/' "$f"; then
      :
    else
      echo "FAIL [C8] $base: references vault path outside Inbox/Notes/Writing"
      FAIL=$((FAIL+1))
    fi
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C8] prompt harness contract"
else
  echo "TOTAL FAIL [C8]: $FAIL"
  exit 1
fi
