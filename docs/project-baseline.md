# Project Baseline

This file records the intended steady-state structure of the repository after cleanup.

## Runtime Core

- `.opencode/command/`
- `.opencode/agent/`
- `.opencode/plugins/phd.ts`
- `.opencode/memory/`
- `.opencode/verifiers/`
- `opencode.json`

## Domain Core

- `domains/ai-in-education/`

## Docs Core

- `README.md`
- `使用指南.md`
- `AGENTS.md`
- `docs/architecture.md`
- `docs/quickstart.md`
- `docs/opencode-usage.md`

## Operational Rules

1. No legacy compatibility layer.
2. No parallel memory system.
3. No template generator inside the repo.
4. No dormant eval scaffold unless intentionally reintroduced.
5. Domain knowledge flows from `domains/ai-in-education/`.

## Model Baseline

| Scope | Model |
|---|---|
| Root | `github-copilot/claude-sonnet-4.6` |
| Heavy synthesis | `github-copilot/claude-opus-4.7` |
| Medium reasoning | `github-copilot/claude-sonnet-4.6` |
| Light ops | `github-copilot/claude-haiku-4.5` |
| Audit | `github-copilot/gpt-5.4` |
