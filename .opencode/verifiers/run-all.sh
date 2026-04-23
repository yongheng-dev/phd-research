#!/usr/bin/env bash
# Run all integration contract verifiers (C1-C17)
# Exit non-zero if any contract fails.

set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
FAIL=0

for v in check-frontmatter.sh check-persistence.sh check-audit-contract.sh check-traces.sh check-memory.sh check-doctrine-references.sh check-plugin.sh check-prompt-harness.sh check-command-harness.sh check-trace-harness.sh check-agent-taxonomy.sh check-runtime-reality.sh check-verifier-coverage.sh check-e2e-scenarios.sh check-mcp-health.sh check-evidence-chain.sh check-trace-note-links.sh; do
  echo "── Running $v ──"
  bash "$DIR/$v" || FAIL=$((FAIL+1))
  echo
done

if [[ $FAIL -eq 0 ]]; then
  echo "════════════════════════════════════"
  echo "✓ All 17 contracts PASS"
  echo "════════════════════════════════════"
  exit 0
else
  echo "════════════════════════════════════"
  echo "✗ $FAIL contracts FAILED"
  echo "════════════════════════════════════"
  exit 1
fi
