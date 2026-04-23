#!/usr/bin/env bash
# C14 — E2E scenario contract

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCENARIOS="$ROOT/.opencode/scenarios/e2e-scenarios.json"
SCENARIO_README="$ROOT/.opencode/scenarios/README.md"
CMD_DIR="$ROOT/.opencode/command"
AGENT_DIR="$ROOT/.opencode/agent"
PLUGIN="$ROOT/.opencode/plugins/phd.ts"
FAIL=0

[[ -f "$SCENARIOS" ]] || { echo "FAIL [C14] missing e2e-scenarios.json"; exit 1; }
[[ -f "$SCENARIO_README" ]] || { echo "FAIL [C14] missing scenarios README"; exit 1; }

python3 - "$SCENARIOS" <<'PY' >/dev/null || { echo "FAIL [C14] invalid e2e-scenarios.json"; exit 1; }
import json, sys
obj = json.load(open(sys.argv[1], 'r', encoding='utf-8'))
assert isinstance(obj.get('scenarios'), list)
for s in obj['scenarios']:
    assert 'id' in s and 'command' in s and 'agents' in s and 'audits' in s and 'persistence' in s and 'trace' in s
PY

while IFS=$'\t' read -r sid command route_hint persistence trace checkpoints agents audits audit_hint; do
  [[ -z "$sid" ]] && continue
  cmd_file="$CMD_DIR/$command.md"
  if [[ ! -f "$cmd_file" ]]; then
    echo "FAIL [C14] $sid: missing command file $command.md"
    FAIL=$((FAIL+1))
    continue
  fi

  if ! grep -q "$persistence" "$cmd_file"; then
    echo "FAIL [C14] $sid: command $command missing persistence path $persistence"
    FAIL=$((FAIL+1))
  fi

  if ! grep -q '^## Trace' "$cmd_file"; then
    echo "FAIL [C14] $sid: command $command missing trace section"
    FAIL=$((FAIL+1))
  fi

  for agent in $agents; do
    [[ -f "$AGENT_DIR/$agent.md" ]] || {
      echo "FAIL [C14] $sid: missing agent $agent.md"
      FAIL=$((FAIL+1))
      continue
    }
    if ! grep -q "$agent" "$cmd_file"; then
      echo "FAIL [C14] $sid: command $command does not mention delegated agent $agent"
      FAIL=$((FAIL+1))
    fi
  done

  for audit in $audits; do
    [[ -f "$AGENT_DIR/$audit.md" ]] || {
      echo "FAIL [C14] $sid: missing audit agent $audit.md"
      FAIL=$((FAIL+1))
      continue
    }
    if ! grep -q "$audit" "$cmd_file"; then
      if [[ -n "$audit_hint" ]] && grep -qi "$audit_hint" "$cmd_file"; then
        :
      else
        echo "FAIL [C14] $sid: command $command does not mention required audit $audit"
        FAIL=$((FAIL+1))
      fi
    fi
  done

  if [[ "$trace" != "" ]] && ! grep -q "$trace" "$cmd_file"; then
    echo "FAIL [C14] $sid: command $command does not mention trace file $trace"
    FAIL=$((FAIL+1))
  fi

  if [[ "$checkpoints" == "true" ]]; then
    if ! grep -q 'checkpoints/' "$cmd_file"; then
      echo "FAIL [C14] $sid: command $command missing checkpoint documentation"
      FAIL=$((FAIL+1))
    fi
    if [[ -f "$PLUGIN" ]] && ! grep -q 'deep-dive-stage-checkpoint' "$PLUGIN"; then
      echo "FAIL [C14] $sid: plugin missing deep-dive checkpoint support"
      FAIL=$((FAIL+1))
    fi
  fi
done < <(python3 - "$SCENARIOS" <<'PY'
import json, sys
obj = json.load(open(sys.argv[1], 'r', encoding='utf-8'))
for s in obj['scenarios']:
    print('\t'.join([
        s['id'],
        s['command'],
        s.get('route_hint', ''),
        s['persistence'],
        s['trace'],
        'true' if s.get('checkpoints') else 'false',
        ' '.join(s['agents']),
        ' '.join(s['audits']),
        s.get('audit_hint', ''),
    ]))
PY
)

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C14] e2e scenario contract"
else
  echo "TOTAL FAIL [C14]: $FAIL"
  exit 1
fi
