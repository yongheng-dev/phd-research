# Traces

Append-only runtime traces for commands, sessions, and audit agents.

## Minimum Schema

- Command traces: `ts`, `command`, `audit`
- Agent traces: `ts`, `agent`
- Audit-agent traces: `ts`, `agent`, `model`
- Fallback traces: `event`, `agent`, `reason`, `fallback`
- Session traces (`session-*.jsonl`): `ts`, `event`
