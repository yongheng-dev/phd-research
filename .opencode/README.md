# `.opencode/` — System Architecture

This directory is the **operational core** of the PhD-Research workflow system.
For project-level guidance see `../AGENTS.md`. For the authoritative integration contract see `verifiers/CONTRACT.md`.

## Layout

```
.opencode/
├── README.md              ← you are here
├── agent/                 ← subagents (literature-searcher, paper-summarizer, ...)
├── command/               ← slash commands (/find, /read, /think, /write, /review, /plan, /admin, /init)
├── memory/                ← persistent state (decisions, doctrine, research-log, patterns, failed-ideas)
│   ├── ROTATION.md        ← Tier-1/2 rotation policy (Option C)
│   └── archive/           ← rotated memory snapshots (YYYY-MM/)
├── plugins/               ← TypeScript plugins (phd.ts compiled by bun)
├── hooks/                 ← lightweight event scripts
├── verifiers/             ← integrity checks (C1–C7)
│   ├── CONTRACT.md        ← AUTHORITATIVE integration contract
│   ├── run-all.sh         ← run all 7 verifiers
│   └── check-*.sh         ← individual checks
├── proposals/             ← drafted system changes pending review
├── checkpoints/           ← saved system snapshots
└── traces/                ← runtime traces
```

## Daily Operations

```bash
# Health check (must be 7/7 GREEN before any commit)
bash .opencode/verifiers/run-all.sh

# Plugin rebuild (after edits to plugins/phd.ts)
cd .opencode/plugins && bun build phd.ts --target=node --outfile=phd.js

# Memory rotation check (auto-fired by phd.ts every 90 days)
ls .opencode/memory/archive/
```

## Architecture Invariants

1. **8 commands, no more.** `find / read / think / write / review / plan / admin / init`. Adding a command requires updating `verifiers/CONTRACT.md` and the corresponding verifier.
2. **Audit agents are read-only.** `tools.write: false`, `permission.edit: deny`, `model: gpt-5.4`. Enforced by `check-frontmatter.sh` (C1).
3. **Tier-1 memory is append-only.** `decisions.md`, `phd-doctrine.md`, `research-log.md` never rotate. See `memory/ROTATION.md`.
4. **Vault path mapping is locked.** `Inbox / Notes / Writing` only. See `AGENTS.md` Save Path Mapping table.
5. **Audit fallback is mandatory.** Every audit agent declares `fallback_model` and emits `degraded_audit: true` when the primary model is unavailable. Plugin re-emits as `audit.degraded` events.

## Where Things Live

| If you want to... | Look at... |
|---|---|
| Add/modify a slash command | `command/*.md` + `verifiers/CONTRACT.md` |
| Add/modify a subagent | `agent/*.md` (frontmatter must satisfy C1) |
| Change vault save paths | `AGENTS.md` mapping table + `verifiers/check-persistence.sh` |
| Add a new event/hook | `plugins/phd.ts` then rebuild |
| Lock a project decision | append to `memory/decisions.md` (Tier-1, never rotates) |
| Capture a finished session lesson | append to `memory/research-log.md` (Tier-1) |
| Capture a half-baked idea or anti-pattern | `memory/failed-ideas.md` or `patterns.md` (Tier-2, rotates @ 90d) |

## Rollback Anchors

| Tag | Purpose |
|---|---|
| `pre-claude-removal` | Before legacy Claude Code asset cleanup |
| `pre-vault-refactor` | Before Obsidian-Vault 8→3 folder migration (set by `scripts/migrate-vault.sh`) |
