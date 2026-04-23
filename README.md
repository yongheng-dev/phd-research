# PhD-Research

OpenCode-powered AI in Education research workspace.

## What This Project Is

This repository is now a clean OpenCode-first project.

It keeps only the active architecture:

- `.opencode/command/`
- `.opencode/agent/`
- `.opencode/plugins/`
- `.opencode/memory/`
- `.opencode/verifiers/`
- `domains/ai-in-education/`
- `opencode.json`

Legacy Scholar Flow, Claude-era templates, compatibility generators, and scaffold-heavy side systems have been removed.

## Command Surface

Current commands:

- `/find`
- `/read`
- `/think`
- `/write`
- `/review`
- `/plan`
- `/admin`

## Model Layout

Current allocation:

| Layer | Model |
|---|---|
| Root session model | `github-copilot/claude-sonnet-4.6` |
| Heavy agents | `github-copilot/claude-opus-4.7` |
| Medium agents | `github-copilot/claude-sonnet-4.6` |
| Light agents | `github-copilot/claude-haiku-4.5` |
| Audit agents | `github-copilot/gpt-5.4` |
| Audit fallback | `github-copilot/claude-opus-4.7` |

Rationale:

- `Sonnet 4.6` is the better default orchestration model for quality/latency balance.
- `Opus 4.7` is reserved for long synthesis, theory work, and heavy drafting.
- `Haiku 4.5` is used for fast mechanical retrieval work.
- `GPT-5.4` stays as the independent audit family.

## Core Structure

```text
PhD-Research/
├── .opencode/
├── domains/
├── docs/
├── scripts/
├── opencode.json
├── AGENTS.md
└── 使用指南.md
```

## Setup (First-time / New User)

Clone the repo, then run the init script to replace hardcoded paths with your own `$HOME`:

```bash
git clone <repo-url> PhD-Research
cd PhD-Research

# Preview what will be replaced
bash scripts/init.sh

# Apply the replacement
bash scripts/init.sh --apply
```

The script auto-detects the original author's path and substitutes it with your `$HOME` across all `.md`, `.json`, `.yaml`, and `.yml` files. Safe to re-run — skips if paths already match.

## Start

```bash
cd ~/PhD-Research
opencode
```

## Verify

```bash
bash .opencode/verifiers/run-all.sh
```
