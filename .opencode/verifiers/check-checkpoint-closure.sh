#!/usr/bin/env bash
# C18 — Checkpoint closure contract

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLAN_CMD="$ROOT/.opencode/command/plan.md"
PLUGIN="$ROOT/.opencode/plugins/phd.ts"
PLUGIN_README="$ROOT/.opencode/plugins/README.md"
CHECKPOINT_README="$ROOT/.opencode/checkpoints/README.md"
DEEP_DIVE="$ROOT/.opencode/agent/deep-dive.md"
MEMORY_README="$ROOT/.opencode/memory/README.md"
CHECKPOINT_DIR="$ROOT/.opencode/checkpoints"
FAIL=0
CHECKED=0

for file in "$PLAN_CMD" "$PLUGIN" "$PLUGIN_README" "$CHECKPOINT_README" "$DEEP_DIVE" "$MEMORY_README"; do
  [[ -f "$file" ]] || { echo "FAIL [C18] missing required file $file"; exit 1; }
done

if ! grep -q -- '--mode=deep-dive' "$PLAN_CMD"; then
  echo "FAIL [C18] plan command missing deep-dive reference"
  FAIL=$((FAIL+1))
fi

if ! grep -q '.opencode/checkpoints/' "$PLAN_CMD"; then
  echo "FAIL [C18] plan command missing checkpoint path"
  FAIL=$((FAIL+1))
fi

if ! grep -q 'deep-dive-stage-checkpoint' "$PLUGIN"; then
  echo "FAIL [C18] plugin missing deep-dive-stage-checkpoint kind"
  FAIL=$((FAIL+1))
fi

if ! grep -q '/plan --mode=deep-dive' "$PLUGIN"; then
  echo "FAIL [C18] plugin missing deep-dive command provenance"
  FAIL=$((FAIL+1))
fi

if ! grep -q 'research-log.md' "$DEEP_DIVE" || ! grep -q 'decisions.md' "$DEEP_DIVE"; then
  echo "FAIL [C18] deep-dive agent missing memory closure references"
  FAIL=$((FAIL+1))
fi

if ! grep -q 'research-log.md' "$CHECKPOINT_README" || ! grep -q 'decisions.md' "$CHECKPOINT_README"; then
  echo "FAIL [C18] checkpoints README missing memory closure note"
  FAIL=$((FAIL+1))
fi

if ! grep -q 'research-log.md' "$MEMORY_README" || ! grep -q 'decisions.md' "$MEMORY_README"; then
  echo "FAIL [C18] memory README missing deep-dive closure note"
  FAIL=$((FAIL+1))
fi

if [[ -d "$CHECKPOINT_DIR" ]]; then
  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    CHECKED=$((CHECKED+1))
    if ! python3 - <<'PY' "$file" >/dev/null 2>&1
import json, sys
from pathlib import Path
obj = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
assert 'ts' in obj
assert 'session_id' in obj
assert 'kind' in obj
if obj.get('kind') == 'deep-dive-stage-checkpoint':
    assert 'stage' in obj
PY
    then
      echo "FAIL [C18] invalid checkpoint schema: $file"
      FAIL=$((FAIL+1))
    fi
  done < <(find "$CHECKPOINT_DIR" -type f -name '*.json' -mtime -30 2>/dev/null)
fi

if [[ $CHECKED -eq 0 ]]; then
  echo "INFO [C18] no recent checkpoint files found; closure capability verified"
else
  echo "INFO [C18] checked $CHECKED recent checkpoint files"
fi

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C18] checkpoint closure contract"
else
  echo "TOTAL FAIL [C18]: $FAIL"
  exit 1
fi
