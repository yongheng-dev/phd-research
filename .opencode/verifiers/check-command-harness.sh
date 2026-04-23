#!/usr/bin/env bash
# C9 — Command harness verifier
# Enforces command-level consistency:
# - required frontmatter fields exist
# - audit policy documentation matches frontmatter
# - Chinese-first output language is explicit
# - legacy vault wording is gone
# - doctrine-aware commands reference phd-doctrine

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CMD_DIR="$ROOT/.opencode/command"
FAIL=0

OUTPUT_LANGUAGE_REQUIRED=(find read think write plan review admin)
DOCTRINE_REQUIRED=(think write plan)

requires_output_language() {
  local name="$1"
  for c in "${OUTPUT_LANGUAGE_REQUIRED[@]}"; do
    [[ "$name" == "$c" ]] && return 0
  done
  return 1
}

requires_doctrine() {
  local name="$1"
  for c in "${DOCTRINE_REQUIRED[@]}"; do
    [[ "$name" == "$c" ]] && return 0
  done
  return 1
}

extract_frontmatter_field() {
  local file="$1"
  local field="$2"
  awk -v key="$field" '/^---$/{c++; next} c==1 && $0 ~ "^"key":" {sub("^"key":[[:space:]]*",""); print; exit}' "$file"
}

for f in "$CMD_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f" .md)"
  fm="$(awk '/^---$/{c++; next} c==1{print} c>=2{exit}' "$f")"

  for field in description agent audit; do
    if ! grep -q "^$field:" <<<"$fm"; then
      echo "FAIL [C9] $base: missing frontmatter field '$field'"
      FAIL=$((FAIL+1))
    fi
  done

  audit_val="$(extract_frontmatter_field "$f" audit)"
  case "$audit_val" in
    on)
      if ! grep -qiE 'mandatory.{0,5}(full-pipeline|post-audit|mini-audit)' "$f"; then
        echo "FAIL [C9] $base: audit=on but missing mandatory audit section"
        FAIL=$((FAIL+1))
      fi
      ;;
    auto)
      if ! grep -qiE 'Audit policy.{0,5}`audit: auto`|Audit policy.{0,5}audit: auto|mandatory.{0,5}(mini-audit|post-audit)' "$f"; then
        echo "FAIL [C9] $base: audit=auto but documentation is incomplete"
        FAIL=$((FAIL+1))
      fi
      ;;
    off)
      if [[ "$base" != "admin" ]]; then
        echo "FAIL [C9] $base: audit=off only allowed for admin"
        FAIL=$((FAIL+1))
      fi
      ;;
    *)
      echo "FAIL [C9] $base: invalid audit value '$audit_val'"
      FAIL=$((FAIL+1))
      ;;
  esac

  if requires_output_language "$base"; then
    if ! grep -q '^## Output Language' "$f"; then
      echo "FAIL [C9] $base: missing '## Output Language' section"
      FAIL=$((FAIL+1))
    fi
    if ! grep -qi 'deep Chinese' "$f"; then
      echo "FAIL [C9] $base: missing Chinese-first output rule"
      FAIL=$((FAIL+1))
    fi
    if [[ "$base" != "admin" ]] && ! grep -qi 'original language' "$f"; then
      echo "FAIL [C9] $base: missing original-language title rule"
      FAIL=$((FAIL+1))
    fi
    if ! grep -qiE 'English academic register|parameters remain in English|flags.*English|API/runtime parameters remain in English|citation metadata.*English' "$f"; then
      echo "FAIL [C9] $base: missing English query/flag/parameter rule"
      FAIL=$((FAIL+1))
    fi
  fi

  if requires_doctrine "$base"; then
    if ! grep -q '.opencode/memory/phd-doctrine.md' "$f"; then
      echo "FAIL [C9] $base: missing doctrine reference"
      FAIL=$((FAIL+1))
    fi
  fi

  if grep -qE 'Paper Notes/|Search Results / Inbox|Obsidian-Vault/Theory Maps/|references/|\.scholar-flow/|templates/|evals/' "$f"; then
    echo "FAIL [C9] $base: contains stale legacy wording or paths"
    FAIL=$((FAIL+1))
  fi

  if grep -q '/Users/xuyongheng/Obsidian-Vault/' "$f"; then
    if grep -qE '/Users/xuyongheng/Obsidian-Vault/(Inbox|Notes|Writing)/' "$f"; then
      :
    else
      echo "FAIL [C9] $base: references vault path outside Inbox/Notes/Writing"
      FAIL=$((FAIL+1))
    fi
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C9] command harness contract"
else
  echo "TOTAL FAIL [C9]: $FAIL"
  exit 1
fi
