#!/usr/bin/env bash
# C16 — Evidence chain contract

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHAIN_FILE="$ROOT/.opencode/scenarios/evidence-chains.json"
CMD_DIR="$ROOT/.opencode/command"
AGENT_DIR="$ROOT/.opencode/agent"
FAIL=0

[[ -f "$CHAIN_FILE" ]] || { echo "FAIL [C16] missing evidence-chains.json"; exit 1; }

python3 - "$CHAIN_FILE" <<'PY' >/dev/null || { echo "FAIL [C16] invalid evidence-chains.json"; exit 1; }
import json, sys
obj = json.load(open(sys.argv[1], 'r', encoding='utf-8'))
assert isinstance(obj.get('evidence_agents'), list)
assert isinstance(obj.get('chains'), list)
for name in obj['evidence_agents']:
    assert isinstance(name, str) and name
for chain in obj['chains']:
    assert isinstance(chain.get('id'), str) and chain['id']
    assert isinstance(chain.get('command'), str) and chain['command']
    assert isinstance(chain.get('agents'), list)
    assert isinstance(chain.get('verification_agents'), list)
    assert isinstance(chain.get('persisted_path'), str) and chain['persisted_path']
    assert isinstance(chain.get('artifact_type'), str) and chain['artifact_type']
    assert isinstance(chain.get('artifact_markers'), list)
    assert isinstance(chain.get('artifact_any_of'), list)
    assert isinstance(chain.get('handoff_commands'), list)
    assert isinstance(chain.get('required_terms'), list)
PY

while IFS= read -r agent; do
  [[ -z "$agent" ]] && continue
  file="$AGENT_DIR/$agent.md"
  if [[ ! -f "$file" ]]; then
    echo "FAIL [C16] missing evidence agent $agent.md"
    FAIL=$((FAIL+1))
    continue
  fi
  for label in '^## Evidence Chain' 'Upstream evidence:' 'Output artifact:' 'Verification note:' 'Downstream handoff:'; do
    if ! grep -q "$label" "$file"; then
      echo "FAIL [C16] $agent: missing evidence-chain label ${label#^}"
      FAIL=$((FAIL+1))
    fi
  done
done < <(python3 - "$CHAIN_FILE" <<'PY'
import json, sys
obj = json.load(open(sys.argv[1], 'r', encoding='utf-8'))
for name in obj['evidence_agents']:
    print(name)
PY
)

while IFS=$'\t' read -r sid command persisted_path artifact_type artifact_markers handoffs agents audits required_terms; do
  [[ -z "$sid" ]] && continue
  file="$CMD_DIR/$command.md"
  if [[ ! -f "$file" ]]; then
    echo "FAIL [C16] $sid: missing command $command.md"
    FAIL=$((FAIL+1))
    continue
  fi

  for label in '^## Evidence Chain' 'Source evidence:' 'Verification trail:' 'Persisted artifact:' 'Downstream handoff:'; do
    if ! grep -q "$label" "$file"; then
      echo "FAIL [C16] $sid: command $command missing evidence-chain label ${label#^}"
      FAIL=$((FAIL+1))
    fi
  done

  if ! grep -F -q "$persisted_path" "$file"; then
    echo "FAIL [C16] $sid: command $command missing persisted path $persisted_path"
    FAIL=$((FAIL+1))
  fi

  for agent in $agents; do
    if ! grep -q "$agent" "$file"; then
      echo "FAIL [C16] $sid: command $command missing evidence agent $agent"
      FAIL=$((FAIL+1))
    fi
  done

  for audit in $audits; do
    if ! grep -q "$audit" "$file"; then
      echo "FAIL [C16] $sid: command $command missing verification agent $audit"
      FAIL=$((FAIL+1))
    fi
  done

  for handoff in $handoffs; do
    if ! grep -q "/$handoff" "$file"; then
      echo "FAIL [C16] $sid: command $command missing downstream handoff /$handoff"
      FAIL=$((FAIL+1))
    fi
  done

  while IFS= read -r term; do
    [[ -z "$term" ]] && continue
    if ! grep -F -q "$term" "$file"; then
      echo "FAIL [C16] $sid: command $command missing required evidence term '$term'"
      FAIL=$((FAIL+1))
    fi
  done <<<"$(python3 - <<'PY' "$required_terms"
import json, sys
for item in json.loads(sys.argv[1]):
    print(item)
PY
)"

  if [[ "$persisted_path" != "/Users/xuyongheng/Obsidian-Vault/"* ]]; then
    echo "FAIL [C16] $sid: persisted path must stay inside Obsidian vault"
    FAIL=$((FAIL+1))
  fi
done < <(python3 - "$CHAIN_FILE" <<'PY'
import json, sys
obj = json.load(open(sys.argv[1], 'r', encoding='utf-8'))
for chain in obj['chains']:
    print('\t'.join([
        chain['id'],
        chain['command'],
        chain['persisted_path'],
        chain['artifact_type'],
        json.dumps(chain['artifact_markers'], ensure_ascii=False),
        ' '.join(chain['handoff_commands']),
        ' '.join(chain['agents']),
        ' '.join(chain['verification_agents']),
        json.dumps(chain['required_terms'], ensure_ascii=False),
    ]))
PY
)

VAULT="/Users/xuyongheng/Obsidian-Vault"
if [[ -d "$VAULT" ]]; then
  NOTE_CHECK_OUTPUT="$(python3 - "$CHAIN_FILE" "$VAULT" <<'PY'
import json, sys
from pathlib import Path

chain_file = Path(sys.argv[1])
vault = Path(sys.argv[2])
obj = json.load(chain_file.open('r', encoding='utf-8'))
specs = {
    c['artifact_type']: {
        'markers': c['artifact_markers'],
        'any_of': c.get('artifact_any_of', []),
    }
    for c in obj['chains']
}
allowed = set(specs)
checked = 0
errors = []

for path in sorted(vault.rglob('*.md')):
    try:
        stat = path.stat()
    except FileNotFoundError:
        continue
    if (Path().cwd() if False else None):
        pass
    age_days = (__import__('time').time() - stat.st_mtime) / 86400
    if age_days > 7:
        continue
    text = path.read_text(encoding='utf-8')
    if not text.startswith('---\n'):
        continue
    parts = text.split('\n---\n', 1)
    if len(parts) != 2:
        continue
    fm, body = parts
    note_type = None
    for line in fm.splitlines():
        if line.startswith('type:'):
            note_type = line.split(':', 1)[1].strip().strip('"')
            break
    if note_type not in allowed:
        continue
    checked += 1
    markers = specs[note_type]['markers']
    any_of = specs[note_type]['any_of']
    haystack = text
    for marker in markers:
        if marker not in haystack:
            errors.append(f"FAIL [C16] {path}: type {note_type} missing artifact marker '{marker}'")
    if any_of and not any(marker in haystack for marker in any_of):
        errors.append(f"FAIL [C16] {path}: type {note_type} missing any downstream evidence marker from {any_of}")
    if 'source:' not in fm:
        errors.append(f"FAIL [C16] {path}: type {note_type} missing frontmatter source")

if checked == 0:
    print('INFO [C16] no recent evidence-chain notes sampled')
else:
    print(f'INFO [C16] sampled {checked} recent evidence-chain notes')
for err in errors:
    print(err)
if errors:
    raise SystemExit(1)
PY
  )"
  status=$?
  printf '%s\n' "$NOTE_CHECK_OUTPUT"
  if [[ $status -ne 0 ]]; then
    FAIL=$((FAIL+1))
  fi
else
  echo "INFO [C16] vault not mounted — skipping artifact sample"
fi

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C16] evidence chain contract"
else
  echo "TOTAL FAIL [C16]: $FAIL"
  exit 1
fi
