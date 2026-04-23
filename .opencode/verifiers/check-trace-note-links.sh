#!/usr/bin/env bash
# C17 — Trace-to-note link contract

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLUGIN="$ROOT/.opencode/plugins/phd.ts"
TRACE_README="$ROOT/.opencode/traces/README.md"
TRACE_DIR="$ROOT/.opencode/traces"
FAIL=0
LINKS=0

[[ -f "$PLUGIN" ]] || { echo "FAIL [C17] missing plugin file"; exit 1; }
[[ -f "$TRACE_README" ]] || { echo "FAIL [C17] missing traces README"; exit 1; }

if ! grep -q 'note.persisted' "$PLUGIN"; then
  echo "FAIL [C17] plugin missing note.persisted support"
  FAIL=$((FAIL+1))
fi

if ! grep -q 'note_path' "$PLUGIN" || ! grep -q 'vault_type' "$PLUGIN"; then
  echo "FAIL [C17] plugin missing note linkage fields"
  FAIL=$((FAIL+1))
fi

if ! grep -q 'note.persisted' "$TRACE_README"; then
  echo "FAIL [C17] traces README missing note.persisted documentation"
  FAIL=$((FAIL+1))
fi

if [[ -d "$TRACE_DIR" ]]; then
  while IFS= read -r trace_file; do
    [[ -f "$trace_file" ]] || continue
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      if ! python3 - <<'PY' "$line" >/dev/null 2>&1
import json, sys
obj = json.loads(sys.argv[1])
if obj.get("event") != "note.persisted":
    raise SystemExit(0)
for key in ("ts", "event", "command", "note_path", "vault_type"):
    if key not in obj:
        raise SystemExit(2)
note_path = obj["note_path"]
if not isinstance(note_path, str):
    raise SystemExit(3)
allowed = (
    "/Users/xuyongheng/Obsidian-Vault/Inbox/",
    "/Users/xuyongheng/Obsidian-Vault/Notes/",
    "/Users/xuyongheng/Obsidian-Vault/Writing/",
)
if not note_path.startswith(allowed):
    raise SystemExit(4)
raise SystemExit(1)
PY
      then
        status=$?
        if [[ $status -eq 2 || $status -eq 3 || $status -eq 4 ]]; then
          echo "FAIL [C17] $trace_file: invalid note.persisted event"
          FAIL=$((FAIL+1))
          continue
        fi
      fi

      if python3 - <<'PY' "$line" >/dev/null 2>&1
import json, sys
obj = json.loads(sys.argv[1])
raise SystemExit(0 if obj.get("event") == "note.persisted" else 1)
PY
      then
        LINKS=$((LINKS+1))
        note_path="$(python3 - <<'PY' "$line"
import json, sys
obj = json.loads(sys.argv[1])
print(obj.get("note_path", ""))
PY
)"
        if [[ ! -f "$note_path" ]]; then
          echo "FAIL [C17] traced note missing on disk: $note_path"
          FAIL=$((FAIL+1))
          continue
        fi
        if ! python3 - <<'PY' "$note_path" >/dev/null 2>&1
from pathlib import Path
import sys
text = Path(sys.argv[1]).read_text(encoding='utf-8')
if not text.startswith('---\n'):
    raise SystemExit(1)
end = text.find('\n---\n', 4)
if end == -1:
    raise SystemExit(1)
fm = text[4:end]
raise SystemExit(0 if 'source:' in fm else 1)
PY
        then
          echo "FAIL [C17] traced note missing frontmatter source: $note_path"
          FAIL=$((FAIL+1))
        fi
      fi
    done < "$trace_file"
  done < <(find "$TRACE_DIR" -type f -name 'session-*.jsonl' -mtime -7 2>/dev/null)
fi

if [[ $LINKS -eq 0 ]]; then
  echo "INFO [C17] no recent note.persisted events found yet; plugin capability verified"
fi

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C17] trace-to-note link contract"
else
  echo "TOTAL FAIL [C17]: $FAIL"
  exit 1
fi
