#!/usr/bin/env bash
# C7 — Plugin Contract verifier
# Verifies that .opencode/plugins/phd.ts exists, is single-file, zero-dependency,
# and subscribes to the minimum required events.

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PLUGIN="$ROOT/.opencode/plugins/phd.ts"
FAIL=0

echo "=== C7 Plugin Contract ==="

if [[ ! -f "$PLUGIN" ]]; then
  echo "FAIL  missing $PLUGIN"
  exit 1
fi

# 1) zero-dependency source rule
#    OpenCode runtime auto-generates .opencode/package.json when plugins exist
#    (to register @opencode-ai/plugin types). We tolerate that file but require
#    it to be gitignored, and we require phd.ts itself to import only node:*.
if [[ -f "$ROOT/.opencode/package.json" ]]; then
  # must be gitignored
  if ! git -C "$ROOT" check-ignore -q .opencode/package.json 2>/dev/null; then
    echo "FAIL  .opencode/package.json exists but is NOT gitignored"
    FAIL=1
  fi
fi

# 2) no third-party import (only node:* allowed)
if grep -nE "^\s*import .* from ['\"](?!node:)" "$PLUGIN" >/dev/null 2>&1; then
  # grep -P not portable on macOS; do a simpler check
  :
fi
# portable equivalent: flag any import whose spec does NOT start with "node:"
BAD_IMPORTS="$(grep -nE "^\s*import " "$PLUGIN" | grep -vE "from ['\"]node:" || true)"
if [[ -n "$BAD_IMPORTS" ]]; then
  echo "FAIL  non-node: imports detected in $PLUGIN"
  echo "$BAD_IMPORTS"
  FAIL=1
fi

# 3) required event subscriptions
REQUIRED_EVENTS=(
  "session.created"
  "session.idle"
  "session.compacted"
  "experimental.session.compacting"
  "command.executed"
  "tool.execute.before"
  "tool.execute.after"
)
for ev in "${REQUIRED_EVENTS[@]}"; do
  if ! grep -q "\"$ev\"" "$PLUGIN"; then
    echo "FAIL  plugin missing subscription for $ev"
    FAIL=1
  fi
done

# 4) single file rule — no other .ts files in plugins/
OTHER_TS="$(find "$ROOT/.opencode/plugins" -maxdepth 1 -name '*.ts' ! -name 'phd.ts' 2>/dev/null || true)"
if [[ -n "$OTHER_TS" ]]; then
  echo "FAIL  extra plugin files found (C7 requires single-file):"
  echo "$OTHER_TS"
  FAIL=1
fi

# 5) default export
if ! grep -q "export default" "$PLUGIN"; then
  echo "FAIL  $PLUGIN has no default export"
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo "PASS  C7 plugin contract satisfied"
  exit 0
else
  exit 1
fi
