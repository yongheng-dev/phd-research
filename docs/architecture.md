# Architecture Overview

PhD-Research now uses a single OpenCode-first architecture.

## Runtime Layers

```text
Commands
  /find /read /think /write /review /plan /admin
      ↓
Agents
  execution + audit + orchestration
      ↓
Memory
  .opencode/memory/
      ↓
MCP tools
  semantic-scholar / arxiv / paper-search / zotero / obsidian-fs / sequential-thinking
      ↓
Obsidian Vault
  Inbox / Notes / Writing
```

## Command Layer

Commands live in `.opencode/command/`.

They are the primary routing surface for user workflows.

## Agent Layer

Agents live in `.opencode/agent/`.

Current model split:

- heavy synthesis: `github-copilot/claude-opus-4.7`
- medium reasoning: `github-copilot/claude-sonnet-4.6`
- light mechanical work: `github-copilot/claude-haiku-4.5`
- audits: `github-copilot/gpt-5.4`

## Memory Layer

Persistent memory is centralized in `.opencode/memory/`.

Core files:

- `phd-doctrine.md`
- `decisions.md`
- `research-log.md`
- `failed-ideas.md`
- `patterns.md`

## Domain Layer

Field knowledge comes from:

```text
domains/ai-in-education/
```

There is no longer a parallel legacy reference layer.

## Verification

Repository integrity is checked through:

```bash
bash .opencode/verifiers/run-all.sh
```
