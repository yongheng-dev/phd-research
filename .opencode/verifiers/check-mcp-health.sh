#!/usr/bin/env bash
# C15 — MCP live health contract

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CONFIG="$ROOT/opencode.json"
FAIL=0

[[ -f "$CONFIG" ]] || { echo "FAIL [C15] missing opencode.json"; exit 1; }

TMP_FILE="$(mktemp)"
python3 - "$CONFIG" <<'PY' > "$TMP_FILE"
import json, re, sys
from pathlib import Path

text = Path(sys.argv[1]).read_text()
text = re.sub(r'^\s*//.*$', '', text, flags=re.M)
cfg = json.loads(text)

for name, spec in sorted(cfg.get('mcp', {}).items()):
    if not spec.get('enabled'):
        continue
    cmd = spec.get('command', [])
    for idx, token in enumerate(cmd):
        print(f"{name}\tCMD\t{idx}\t{token}")
    for key, value in sorted(spec.get('environment', {}).items()):
        print(f"{name}\tENV\t{key}\t{value}")
PY

has_launcher() {
  command -v "$1" >/dev/null 2>&1
}

smoke_probe() {
  case "$1" in
    arxiv)
      uvx arxiv-mcp-server --help >/dev/null 2>&1
      ;;
    zotero)
      uvx zotero-mcp --help >/dev/null 2>&1
      ;;
    fetch)
      uvx mcp-server-fetch --help >/dev/null 2>&1
      ;;
    sequential-thinking)
      npx -y @modelcontextprotocol/server-sequential-thinking --help >/dev/null 2>&1
      ;;
    obsidian-fs)
      return 0
      ;;
    paper-search)
      return 0
      ;;
    semantic-scholar)
      return 0
      ;;
    brave-search)
      return 0
      ;;
    *)
      return 0
      ;;
  esac
}

while IFS=$'\t' read -r name kind a b; do
  [[ -z "$name" ]] && continue
  if [[ "$kind" == "CMD" ]]; then
    token="$b"
    if [[ "$a" == "0" ]]; then
      if ! has_launcher "$token"; then
        echo "FAIL [C15] $name: launcher '$token' not found on PATH"
        FAIL=$((FAIL+1))
      fi
    fi

    if [[ "$token" == /* ]] && [[ ! -e "$token" ]]; then
      echo "FAIL [C15] $name: required local path '$token' does not exist"
      FAIL=$((FAIL+1))
    fi

    if [[ "$token" == "python" ]] && ! has_launcher python; then
      echo "FAIL [C15] $name: command chain depends on 'python' but it is not on PATH"
      FAIL=$((FAIL+1))
    fi

    if [[ "$token" == "python3" ]] && ! has_launcher python3; then
      echo "FAIL [C15] $name: command chain depends on 'python3' but it is not on PATH"
      FAIL=$((FAIL+1))
    fi
  fi
done < "$TMP_FILE"

for name in $(awk -F $'\t' '$2 == "CMD" {print $1}' "$TMP_FILE" | sort -u); do
  if ! smoke_probe "$name"; then
    echo "FAIL [C15] $name: safe launcher smoke probe failed"
    FAIL=$((FAIL+1))
  fi
done

rm -f "$TMP_FILE"

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C15] mcp live health contract"
else
  echo "TOTAL FAIL [C15]: $FAIL"
  exit 1
fi
