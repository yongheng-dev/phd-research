#!/usr/bin/env bash
# C12 — Runtime reality harness
# Verifies that documented runtime references match actual configured agents, tools, and project layout.

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CMD_DIR="$ROOT/.opencode/command"
AGENT_DIR="$ROOT/.opencode/agent"
CONFIG="$ROOT/opencode.json"
FAIL=0

require_file() {
  local p="$1"
  [[ -f "$p" ]]
}

if [[ ! -f "$CONFIG" ]]; then
  echo "FAIL [C12] missing opencode.json"
  exit 1
fi

MCP_KEYS="$(python3 - <<'PY'
import json, re
from pathlib import Path
text = Path('opencode.json').read_text()
text = re.sub(r'^\s*//.*$', '', text, flags=re.M)
cfg = json.loads(text)
print('\n'.join(sorted(cfg.get('mcp', {}).keys())))
PY
)"

for cmd in "$CMD_DIR"/*.md; do
  [[ -f "$cmd" ]] || continue
  base="$(basename "$cmd" .md)"

  while IFS= read -r agent_name; do
    [[ -z "$agent_name" ]] && continue
    if [[ ! -f "$AGENT_DIR/$agent_name.md" ]]; then
      echo "FAIL [C12] $base: references missing agent '$agent_name'"
      FAIL=$((FAIL+1))
    fi
  done < <(python3 - "$cmd" <<'PY'
import re, sys
text = open(sys.argv[1], 'r', encoding='utf-8').read()
names = sorted(set(re.findall(r'`([a-z0-9-]+)`', text)))
for n in names:
    if n in {
        'day','week','month','meta-optimize','health','quick','standard','deep','structured',
        'strict','lenient','draft','review','section','response','on','off','auto','sub-branch'
    }:
        continue
    if '-' in n and not n.startswith('--'):
        print(n)
PY
)
done

for agent in "$AGENT_DIR"/*.md; do
  [[ -f "$agent" ]] || continue
  base="$(basename "$agent" .md)"

  if grep -qE '`paper_relevance_search`|`paper_bulk_search`|`get_citations`|`read_paper`|Obsidian Paper Notes|paper-search MCP' "$agent"; then
    echo "FAIL [C12] $base: contains stale or non-runtime tool wording"
    FAIL=$((FAIL+1))
  fi

  if grep -q '`semantic-scholar_paper_' "$agent"; then
    if ! grep -q '^semantic-scholar$' <<<"$MCP_KEYS"; then
      echo "FAIL [C12] $base: references semantic-scholar tools but MCP is not configured"
      FAIL=$((FAIL+1))
    fi
  fi
  if grep -q '`arxiv_' "$agent"; then
    if ! grep -q '^arxiv$' <<<"$MCP_KEYS"; then
      echo "FAIL [C12] $base: references arxiv tools but MCP is not configured"
      FAIL=$((FAIL+1))
    fi
  fi
  if grep -q '`zotero_zotero_' "$agent"; then
    if ! grep -q '^zotero$' <<<"$MCP_KEYS"; then
      echo "FAIL [C12] $base: references zotero tools but MCP is not configured"
      FAIL=$((FAIL+1))
    fi
  fi
  if grep -q 'obsidian-fs' "$agent"; then
    if ! grep -q '^obsidian-fs$' <<<"$MCP_KEYS"; then
      echo "FAIL [C12] $base: references obsidian-fs but MCP is not configured"
      FAIL=$((FAIL+1))
    fi
  fi
  if grep -q 'sequential-thinking_sequentialthinking' "$agent"; then
    if ! grep -q '^sequential-thinking$' <<<"$MCP_KEYS"; then
      echo "FAIL [C12] $base: references sequential-thinking but MCP is not configured"
      FAIL=$((FAIL+1))
    fi
  fi
  if grep -q 'brave-search' "$agent"; then
    if ! grep -q '^brave-search$' <<<"$MCP_KEYS"; then
      echo "FAIL [C12] $base: references brave-search but MCP is not configured"
      FAIL=$((FAIL+1))
    fi
  fi
  if grep -q 'paper-search' "$agent"; then
    if ! grep -q '^paper-search$' <<<"$MCP_KEYS"; then
      echo "FAIL [C12] $base: references paper-search but MCP is not configured"
      FAIL=$((FAIL+1))
    fi
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C12] runtime reality contract"
else
  echo "TOTAL FAIL [C12]: $FAIL"
  exit 1
fi
