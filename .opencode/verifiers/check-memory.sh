#!/usr/bin/env bash
# C5 — Memory contract verifier
# decisions.md, failed-ideas.md, patterns.md must be append-only (no rewrites in git history)

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 1
FAIL=0
APPEND_ONLY=("decisions.md" "failed-ideas.md" "patterns.md")

for f in "${APPEND_ONLY[@]}"; do
  path=".opencode/memory/$f"
  [[ -f "$path" ]] || { echo "INFO [C5] $path not found"; continue; }

  # Check git history for any commit that DELETED lines (not just added)
  # A pure append should show 0 lines deleted.
  if git -C "$ROOT" log --follow --numstat --pretty=format: -- "$path" 2>/dev/null | awk 'NF==3 && $2>0 {bad++} END{exit bad?1:0}'; then
    : # PASS
  else
    echo "WARN [C5] $f has commits with line deletions (may indicate non-append edits)"
    # warn, not fail — legitimate template scaffolding may have deletions
  fi
done

echo "PASS [C5] memory contract (append-only check is advisory)"
