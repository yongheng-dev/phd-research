#!/usr/bin/env bash
# C2 — Persistence contract verifier (samples last 7 days of Obsidian notes)

set -u
VAULT="/Users/xuyongheng/Obsidian-Vault"
FAIL=0
CHECKED=0

if [[ ! -d "$VAULT" ]]; then
  echo "INFO [C2] vault not mounted at $VAULT — skipping"
  exit 0
fi

ALLOWED_TYPES="paper-note ideation lit-review search-results concept-card daily-picks weekly-report deep-dive documentation"

while IFS= read -r f; do
  CHECKED=$((CHECKED+1))
  # Must start with frontmatter
  if ! head -1 "$f" | grep -q '^---$'; then
    echo "FAIL [C2] $f: missing YAML frontmatter"
    FAIL=$((FAIL+1))
    continue
  fi
  fm="$(awk '/^---$/{c++; next} c==1{print} c>=2{exit}' "$f")"
  for field in title date type tags; do
    if ! grep -qE "^$field:" <<<"$fm"; then
      echo "FAIL [C2] $f: missing frontmatter '$field'"
      FAIL=$((FAIL+1))
    fi
  done
  type="$(grep -E '^type:' <<<"$fm" | head -1 | sed -E 's/^type:[[:space:]]*"?([^"]*)"?/\1/')"
  if [[ -n "$type" ]] && ! grep -qw "$type" <<<"$ALLOWED_TYPES"; then
    echo "FAIL [C2] $f: type '$type' not in allowed set"
    FAIL=$((FAIL+1))
  fi
done < <(find "$VAULT" -type f -name '*.md' -mtime -7 2>/dev/null | head -50)

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C2] persistence contract ($CHECKED notes sampled)"
else
  echo "TOTAL FAIL [C2]: $FAIL ($CHECKED notes sampled)"
  exit 1
fi
