# .opencode/traces/

Append-only JSONL traces of every command execution, audit-agent run, and plugin event. These feed:

- `/weekly-report` assurance dashboard (P5.C)
- `meta-optimizer` drift detection (P5.D)
- Ad-hoc forensics

## Write rules

| Writer | Path | Append-only? |
|---|---|---|
| `.opencode/plugins/phd.ts` | `.opencode/traces/session-<id>.jsonl` | yes |
| Each command | `.opencode/traces/YYYY-MM-DD/<command>.jsonl` | yes |
| Each audit agent | `.opencode/traces/YYYY-MM-DD/<agent>.jsonl` | yes |

Daily directories (`YYYY-MM-DD/`) keep trace files bounded. Per-session files (`session-<id>.jsonl`) preserve full causal order for one session.

## Common record fields

Every JSONL line MUST have:

```json
{ "ts": "ISO-8601", "event": "string" }
```

## Schema by producer

### Plugin (`phd.ts`)

| event | extra fields |
|---|---|
| `session.created` | `session_id`, `doctrine_loaded` (bool) |
| `session.idle` | `session_id` |
| `session.compacted` | `session_id`, `checkpoint` (path) |
| `experimental.session.compacting` | `session_id`, `injected_chars` |
| `command.executed` | `session_id`, `command` |
| `deep-dive.stage.checkpoint` | `session_id`, `stage`, `checkpoint` (path) |
| `tool.execute.before` | `agent`, `tool` |
| `tool.execute.after` | `agent`, `tool`, `ok` (bool) |

### Audit agents

Every adversarial audit appends a verdict record:

```json
{
  "ts": "...",
  "agent": "citation-verifier | coverage-critic | summary-auditor | novelty-checker",
  "model": "github-copilot/gpt-5.4",
  "target": "paper-id | search-id | summary-id | idea-id",
  "verdict": "PASS | FAIL | BLOCK | PROCEED | REJECT",
  "counts": { "total": 10, "failed": 1, "passed": 9 },
  "notes": "short reason"
}
```

So-What Gate (novelty-checker) adds:

```json
{ "so_what_score": 7, "gates": { "mainstream_anchor": true, "sub_branch": true, "so_what": false } }
```

### Commands

Each command emits a start and end record:

```json
{ "ts":"...", "command":"/search-papers", "phase":"start", "args":{...} }
{ "ts":"...", "command":"/search-papers", "phase":"end", "outcome":"saved", "path":"/Users/.../Search Results/2026-04-23-xxx.md" }
```

## Validator

`.opencode/verifiers/check-traces.sh` samples the last 7 days and validates every line parses as JSON and has `ts` + `event`.

## Retention

Traces are gitignored. The meta-optimizer reads the last 30 days for drift trends; older traces can be archived/deleted.
