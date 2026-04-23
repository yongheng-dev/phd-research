# Traces

Append-only runtime traces for commands, sessions, and audit agents.

## Minimum Schema

- Command traces: `ts`, `command`, `audit`
- Agent traces: `ts`, `agent`
- Audit-agent traces: `ts`, `agent`, `model`
- Fallback traces: `event`, `agent`, `reason`, `fallback`
- Session traces (`session-*.jsonl`): `ts`, `event`

## Note Linkage

When a research command saves a note, the plugin may emit a best-effort session event:

- `note.persisted`: `ts`, `event`, `command`, `note_path`, `vault_type`

`note_path` must point into `/Users/xuyongheng/Obsidian-Vault/Inbox/`, `/Notes/`, or `/Writing/`.
