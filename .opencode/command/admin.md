---
description: Admin — system maintenance (meta-optimize, health). Hidden from main help.
agent: build
audit: off
---

Run a system-admin subcommand: $ARGUMENTS

## Subcommands

Parse the first token of `$ARGUMENTS` as the subcommand:

### `meta-optimize` [--window=7d|14d|30d]

Run `meta-optimizer` on recent traces and memory to PROPOSE (not apply) improvements.

- Aggregates JSONL traces under `.opencode/traces/` for the window (default: 7 days).
- Inspects `.opencode/memory/` (failed-ideas density, patterns emergence, decisions cadence).
- Emits one proposal markdown file per recommendation into `.opencode/proposals/YYYY-MM-DD-<slug>.md`.
- **Never edits** agents, commands, or memory directly — proposals must be reviewed by the user.

Audit: none (meta-optimizer output is itself a proposal; the proposal review IS the audit step).

### `health`

Re-run project scaffolding checks (memory files exist, verifier scripts executable, plugin loads, MCP servers reachable). Read-only except for creating missing `.gitkeep` files.

Audit: none.

## Mandatory mini-audit (meta)

While individual subcommands skip audits (audit: off), `/admin` logs every invocation to `.opencode/traces/$(date +%Y-%m-%d)/admin.jsonl`:

```json
{"ts":"<iso>","command":"/admin","audit":"off","subcommand":"meta-optimize|health","args":"<raw>","result":"ok|fail"}
```

This trace entry IS the mandatory mini-audit record — every admin action leaves a forensic trail even when no audit agent fires.

## Output Language

Default to deep Chinese for user-facing output. File paths, subcommand names, flags, and API/runtime parameters remain in English.

## Hard rules

- `/admin` never writes to Obsidian.
- `/admin meta-optimize` never modifies any file outside `.opencode/proposals/`.
- Unknown subcommand → print list and exit.

If `$ARGUMENTS` is empty, print:
```
/admin subcommands:
   meta-optimize [--window=7d|14d|30d]
   health
```
