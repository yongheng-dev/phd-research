# .opencode/plugins/

OpenCode plugin modules for PhD-Research.

## Files

| File | Purpose |
|------|---------|
| `phd.ts` | Single-file, zero-dependency plugin. Handles session lifecycle, /deep-dive checkpoints, compaction state injection, and audit-agent tool traces. |

## Why single-file + zero-dependency

Locked decision (session 2026-04-23): we do **not** introduce `@opencode-ai/plugin` as an npm devDependency. The plugin uses only Node built-ins (`node:fs`, `node:path`) and OpenCode's plugin context object (`ctx.client`, `ctx.directory`, `ctx.project`). This means:

- No `.opencode/package.json`
- No `bun install` step
- No version drift when OpenCode updates

The trade-off is no TypeScript intellisense for the event payloads — we use `any` defensively and guard every field access.

## Events subscribed

| Event | Action |
|-------|--------|
| `session.created` | Log session start + whether doctrine loaded |
| `session.idle` | Append idle marker to session trace |
| `session.compacted` | Write post-compaction snapshot checkpoint |
| `experimental.session.compacting` | Inject persistent research state into compaction prompt |
| `command.executed` | Log every command; if `/deep-dive` and output contains `S1..S5` stage marker, write a stage checkpoint |
| `tool.execute.before` / `tool.execute.after` | Light trace for audit-class agents only (citation-verifier, coverage-critic, summary-auditor, novelty-checker) |

## Output locations

- Session traces: `.opencode/traces/session-<id>.jsonl` (append-only JSONL)
- Deep-dive stage checkpoints: `.opencode/checkpoints/<session>-deep-dive-<stage>-<ts>.json`
- Post-compaction snapshots: `.opencode/checkpoints/<session>-compacted-<ts>.json`

Deep-dive checkpoints are resumability state only. The completed workflow must still terminate in a vault synthesis note plus any necessary appends to `.opencode/memory/research-log.md` and `.opencode/memory/decisions.md`.

## Safety invariants

- Never throws out of a hook (all fs ops wrapped in try/catch).
- Never mutates `.opencode/memory/*` (those files are immutable at runtime).
- No network calls.
- No checkpoint proliferation outside `/deep-dive` — other commands only get a one-line trace entry.

## Verifying the plugin loads

After starting an OpenCode session, check:

```
ls .opencode/traces/        # should contain session-*.jsonl
cat .opencode/traces/session-*.jsonl | head
```

If empty after a full session, the plugin did not load — check `opencode` logs for `[phd-plugin]` prefix.
