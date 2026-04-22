#!/usr/bin/env bash
# migrate-vault.sh — One-shot migration of Obsidian-Vault from 8-folder layout to 3-folder layout
#
# Pre-R4 layout:                          Post-R4 layout:
#   Daily Picks/                            Inbox/
#   Search Results/                         Notes/
#   Daily Notes/                            Writing/
#   Paper Notes/                            Templates/         (unchanged)
#   Concept Cards/                          Attachments/       (unchanged)
#   Ideation Sessions/                      .obsidian/         (unchanged)
#   Literature Reviews/
#   Writing Drafts/
#
# Mapping (locked by R4):
#   Inbox    ← Daily Picks + Search Results + Daily Notes
#   Notes    ← Paper Notes + Concept Cards + Ideation Sessions
#   Writing  ← Literature Reviews + Writing Drafts
#
# Safety:
#   1. Asserts VAULT is a clean git repo
#   2. Tags `pre-vault-refactor` before touching anything
#   3. Default = DRY RUN. Pass `--apply` to actually move files.
#   4. Uses `git mv` so history is preserved
#   5. Refuses to run if any target folder already has content (prevents collision)

set -euo pipefail

VAULT="${VAULT:-/Users/xuyongheng/Obsidian-Vault}"
DRY_RUN=true
[[ "${1:-}" == "--apply" ]] && DRY_RUN=false

log() { printf '[migrate-vault] %s\n' "$*"; }
run() {
  if $DRY_RUN; then
    printf '  DRY: %s\n' "$*"
  else
    eval "$@"
  fi
}

# --- 1. Pre-flight ---------------------------------------------------------
[[ -d "$VAULT" ]] || { log "ERROR: vault not found at $VAULT"; exit 1; }
cd "$VAULT"

[[ -d .git ]] || { log "ERROR: $VAULT is not a git repo — refusing to proceed"; exit 1; }

if [[ -n "$(git status --porcelain)" ]]; then
  log "ERROR: vault has uncommitted changes — commit or stash first:"
  git status --short
  exit 1
fi
log "OK: vault is a clean git repo"

# --- 2. Tag rollback anchor ------------------------------------------------
if git rev-parse --verify --quiet pre-vault-refactor >/dev/null; then
  log "OK: tag pre-vault-refactor already exists"
else
  run "git tag pre-vault-refactor"
  log "tagged pre-vault-refactor"
fi

# --- 3. Collision check ----------------------------------------------------
for target in Inbox Notes Writing; do
  if [[ -d "$target" ]] && [[ -n "$(ls -A "$target" 2>/dev/null)" ]]; then
    log "ERROR: $target/ already exists and is non-empty — manual reconcile needed"
    exit 1
  fi
done

# --- 4. Mapping ------------------------------------------------------------
declare -a INBOX_SRC=("Daily Picks" "Search Results" "Daily Notes")
declare -a NOTES_SRC=("Paper Notes" "Concept Cards" "Ideation Sessions")
declare -a WRITING_SRC=("Literature Reviews" "Writing Drafts")

migrate_group() {
  local target="$1"; shift
  local sources=("$@")
  run "mkdir -p '$target'"
  for src in "${sources[@]}"; do
    if [[ ! -d "$src" ]]; then
      log "skip: '$src' does not exist"
      continue
    fi
    # Move every file (including dotfiles) inside src into target/
    while IFS= read -r -d '' f; do
      rel="${f#$src/}"
      dest="$target/$rel"
      run "mkdir -p '$(dirname "$dest")'"
      run "git mv -k '$f' '$dest'"
    done < <(find "$src" -mindepth 1 -type f -print0 2>/dev/null)
    # Remove the now-empty source dir (if truly empty)
    if [[ -z "$(ls -A "$src" 2>/dev/null)" ]]; then
      run "rmdir '$src'"
    else
      log "WARN: '$src' still has content after move"
    fi
  done
}

log "=== Migrating to Inbox/ ==="
migrate_group "Inbox" "${INBOX_SRC[@]}"

log "=== Migrating to Notes/ ==="
migrate_group "Notes" "${NOTES_SRC[@]}"

log "=== Migrating to Writing/ ==="
migrate_group "Writing" "${WRITING_SRC[@]}"

# --- 5. Commit -------------------------------------------------------------
if $DRY_RUN; then
  log "DRY RUN complete — re-run with --apply to execute"
else
  if [[ -n "$(git status --porcelain)" ]]; then
    git commit -m "vault: migrate 8-folder layout to 3-folder (Inbox/Notes/Writing)

Mapping:
  Inbox   ← Daily Picks + Search Results + Daily Notes
  Notes   ← Paper Notes + Concept Cards + Ideation Sessions
  Writing ← Literature Reviews + Writing Drafts

Rollback: git reset --hard pre-vault-refactor"
    log "committed migration"
  fi
  log "DONE — verify with: ls -la $VAULT"
  log "Rollback if needed: cd $VAULT && git reset --hard pre-vault-refactor"
fi
