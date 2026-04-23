#!/usr/bin/env bash
# C3 — Audit contract verifier (post-R1/R2)
# Every research command must declare an audit policy.
# - audit: on   → must document a "Mandatory post-audit|mini-audit|full-pipeline" section
# - audit: auto → must document the auto-fire trigger rules AND a "mandatory mini-audit" fallback hook
# - audit: off  → allowed only for /admin and explicitly exempt commands
# /plan must NOT permit --audit=off

set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CMD_DIR="$ROOT/.opencode/command"
FAIL=0
# No command-level exemptions.
EXEMPT=()

is_exempt() {
  local name="$1"
  [[ ${#EXEMPT[@]} -eq 0 ]] && return 1
  for e in "${EXEMPT[@]}"; do
    [[ "$name" == "$e" ]] && return 0
  done
  return 1
}

extract_audit_field() {
  # Returns the `audit:` value from frontmatter, or empty string
  awk '/^---$/{c++; next} c==1 && /^audit:/{sub(/^audit:[[:space:]]*/,""); print; exit}' "$1"
}

for f in "$CMD_DIR"/*.md; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f" .md)"
  is_exempt "$base" && continue

  audit_val="$(extract_audit_field "$f")"

  case "$audit_val" in
    on)
      if ! grep -qiE 'mandatory.{0,5}post-?audit|mandatory.{0,5}so-what gate|mandatory.{0,5}mini-audit|mandatory.{0,5}full-pipeline' "$f"; then
        echo "FAIL [C3] $base: audit=on but no Mandatory post-audit/mini-audit/full-pipeline section"
        FAIL=$((FAIL+1))
      fi
      ;;
    auto)
      if ! grep -qiE 'audit:.{0,5}auto|audit policy.{0,5}auto' "$f"; then
        echo "FAIL [C3] $base: audit=auto but no 'Audit policy — auto' section"
        FAIL=$((FAIL+1))
      fi
      if ! grep -qiE 'mandatory.{0,5}(mini-?audit|post-?audit|full-pipeline)' "$f"; then
        echo "FAIL [C3] $base: audit=auto must still document a mandatory fallback hook"
        FAIL=$((FAIL+1))
      fi
      ;;
    off)
      # only /admin legitimately declares audit=off
      if [[ "$base" != "admin" ]]; then
        echo "FAIL [C3] $base: audit=off is only allowed for /admin"
        FAIL=$((FAIL+1))
      fi
      # /admin must still log every call as a forensic mini-audit
      if [[ "$base" == "admin" ]] && ! grep -qiE 'mandatory.{0,5}mini-?audit' "$f"; then
        echo "FAIL [C3] admin: must document a mandatory mini-audit trace"
        FAIL=$((FAIL+1))
      fi
      ;;
    "")
      echo "FAIL [C3] $base: missing 'audit:' frontmatter field (must be on|auto|off)"
      FAIL=$((FAIL+1))
      ;;
    *)
      echo "FAIL [C3] $base: invalid audit value '$audit_val' (must be on|auto|off)"
      FAIL=$((FAIL+1))
      ;;
  esac

  if [[ "$base" == "plan" ]]; then
    if grep -qE 'audit=off.*supported|--audit=off' "$f" && ! grep -qiE 'not supported|disallowed|forbidden|cannot be combined' "$f"; then
      echo "FAIL [C3] plan: --audit=off must be explicitly forbidden"
      FAIL=$((FAIL+1))
    fi
  fi
done

if [[ $FAIL -eq 0 ]]; then
  echo "PASS [C3] audit contract"
else
  echo "TOTAL FAIL [C3]: $FAIL"
  exit 1
fi
