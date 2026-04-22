#!/usr/bin/env bash
# Run all integration contract verifiers (C1-C6)
# Exit non-zero if any contract fails.

set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
FAIL=0

for v in check-frontmatter.sh check-persistence.sh check-audit-contract.sh check-traces.sh check-memory.sh check-doctrine-references.sh; do
  echo "── Running $v ──"
  bash "$DIR/$v" || FAIL=$((FAIL+1))
  echo
done

if [[ $FAIL -eq 0 ]]; then
  echo "════════════════════════════════════"
  echo "✓ All 6 contracts PASS"
  echo "════════════════════════════════════"
  exit 0
else
  echo "════════════════════════════════════"
  echo "✗ $FAIL contracts FAILED"
  echo "════════════════════════════════════"
  exit 1
fi
