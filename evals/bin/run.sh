#!/usr/bin/env bash
# evals/bin/run.sh — eval harness runner (stub).
#
# Status: SCAFFOLD. This script enumerates queries and prints an
# execution plan. It does NOT invoke OpenCode commands yet — the user
# has to confirm the execution strategy (subprocess vs. SDK vs. manual)
# on first real run. See evals/README.md.

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
Q_DIR="$ROOT/evals/queries"
REPORT_DIR="$ROOT/evals/reports"
SUITE_FILTER="${1:-all}"
DATE="$(date +%Y-%m-%d)"

mkdir -p "$REPORT_DIR"

plan_file="$REPORT_DIR/$DATE-plan.md"
{
  echo "# Eval Plan — $DATE"
  echo ""
  echo "Suite filter: $SUITE_FILTER"
  echo ""
  echo "| id | suite | severity | command | args |"
  echo "|---|---|---|---|---|"
} > "$plan_file"

count=0
for f in "$Q_DIR"/*.yaml; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f" .yaml)"
  [[ "$base" == "_template" ]] && continue

  id=$(grep -E '^id:'       "$f" | head -1 | sed 's/^id: *//')
  suite=$(grep -E '^suite:'   "$f" | head -1 | sed 's/^suite: *//')
  sev=$(grep -E '^severity:' "$f" | head -1 | sed 's/^severity: *//')
  cmd=$(grep -E '^command:'  "$f" | head -1 | sed 's/^command: *//')
  args=$(grep -E '^args:'    "$f" | head -1 | sed 's/^args: *//' | sed 's/^"//;s/"$//')

  if [[ "$SUITE_FILTER" != "all" && "$suite" != "$SUITE_FILTER" ]]; then
    continue
  fi

  echo "| $id | $suite | $sev | $cmd | $args |" >> "$plan_file"
  count=$((count+1))
done

{
  echo ""
  echo "Total queries in plan: $count"
  echo ""
  echo "## Status"
  echo ""
  echo "Runner is scaffold-only. No queries executed. To activate,"
  echo "decide on an invocation strategy (see evals/README.md) and"
  echo "replace the STUB block below with real command dispatch."
} >> "$plan_file"

echo "Plan written: $plan_file"
echo "Queries enumerated: $count"
echo "Runner status: SCAFFOLD (no live execution)."
