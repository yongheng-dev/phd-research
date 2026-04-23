#!/usr/bin/env bash
# C13 — Verifier coverage contract

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUN_ALL="$ROOT/.opencode/verifiers/run-all.sh"
CONTRACT="$ROOT/.opencode/verifiers/CONTRACT.md"
FAIL=0

[[ -f "$RUN_ALL" ]] || { echo "FAIL [C13] missing run-all.sh"; exit 1; }
[[ -f "$CONTRACT" ]] || { echo "FAIL [C13] missing CONTRACT.md"; exit 1; }

SCRIPT_NAMES="$(python3 - "$RUN_ALL" <<'PY'
import re, sys
text = open(sys.argv[1], 'r', encoding='utf-8').read()
m = re.search(r'for v in (.+?); do', text, re.S)
if not m:
    raise SystemExit(0)
items = re.findall(r'check-[a-z0-9-]+\.sh', m.group(1))
for item in items:
    print(item)
PY
)"

SCRIPT_COUNT="$(printf '%s\n' "$SCRIPT_NAMES" | sed '/^$/d' | wc -l | tr -d ' ')"

for script in $SCRIPT_NAMES; do
  path="$ROOT/.opencode/verifiers/$script"
  if [[ ! -f "$path" ]]; then
    echo "FAIL [C13] run-all.sh references missing verifier $script"
    FAIL=$((FAIL+1))
  fi

  case "$script" in
    check-frontmatter.sh) section='## C1 '
      ;;
    check-persistence.sh) section='## C2 '
      ;;
    check-audit-contract.sh) section='## C3 '
      ;;
    check-traces.sh) section='## C4 '
      ;;
    check-memory.sh) section='## C5 '
      ;;
    check-doctrine-references.sh) section='## C6 '
      ;;
    check-plugin.sh) section='## C7 '
      ;;
    check-prompt-harness.sh) section='## C8 '
      ;;
    check-command-harness.sh) section='## C9 '
      ;;
    check-trace-harness.sh) section='## C10 '
      ;;
    check-agent-taxonomy.sh) section='## C11 '
      ;;
    check-runtime-reality.sh) section='## C12 '
      ;;
    check-verifier-coverage.sh) section='## C13 '
      ;;
    check-e2e-scenarios.sh) section='## C14 '
      ;;
    check-mcp-health.sh) section='## C15 '
      ;;
    check-evidence-chain.sh) section='## C16 '
      ;;
    check-trace-note-links.sh) section='## C17 '
      ;;
    check-checkpoint-closure.sh) section='## C18 '
      ;;
    *) section=''
      ;;
  esac

  if [[ -n "$section" ]] && ! grep -q "^$section" "$CONTRACT"; then
    echo "FAIL [C13] CONTRACT.md missing section for $script ($section)"
    FAIL=$((FAIL+1))
  fi
done

for section in $(grep -E '^## C[0-9]+' "$CONTRACT" | awk '{print $2}'); do
  case "$section" in
    C1|C2|C3|C4|C5|C6|C7|C8|C9|C10|C11|C12|C13|C14|C15|C16|C17|C18) : ;;
    *)
      echo "FAIL [C13] CONTRACT.md declares unknown section $section"
      FAIL=$((FAIL+1))
      ;;
  esac
done

BANNER_COUNT="$(python3 - "$RUN_ALL" <<'PY'
import re, sys
text = open(sys.argv[1], 'r', encoding='utf-8').read()
m = re.search(r'All\s+(\d+)\s+contracts PASS', text)
print(m.group(1) if m else '')
PY
)"

if [[ -z "$BANNER_COUNT" ]]; then
  echo "FAIL [C13] run-all.sh missing success banner count"
  FAIL=$((FAIL+1))
elif [[ "$BANNER_COUNT" != "$SCRIPT_COUNT" ]]; then
  echo "FAIL [C13] success banner count $BANNER_COUNT does not match verifier count $SCRIPT_COUNT"
  FAIL=$((FAIL+1))
fi

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C13] verifier coverage contract"
else
  echo "TOTAL FAIL [C13]: $FAIL"
  exit 1
fi
