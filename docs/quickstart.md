# Quick Start Guide

Get Scholar Flow running in 5 minutes.

## Prerequisites

1. **Claude Code** — Install from [claude.ai/code](https://claude.ai/code) and authenticate
2. **Node.js 18+** — Required for some MCP servers (`npx`)
3. **Python 3.10+ with uv** — Required for some MCP servers (`uvx`)

## Setup

```bash
git clone https://github.com/yourusername/scholar-flow.git
cd scholar-flow
claude
```

Inside Claude Code, run:

```
/init
```

The wizard will ask about your:
- Research field and topics
- Academic level
- Preferred language
- Obsidian vault (optional)
- Zotero setup (optional)
- API keys for paper search services

## After Setup

Your personalized environment is ready. Try these commands:

| Command | What It Does |
|---------|-------------|
| `/daily` | Paper recommendations + review reminders |
| `/search-papers AI literacy` | Search for papers on a topic |
| `/summarize 10.1234/example` | Deep-read a paper by DOI |
| `/brainstorm assessment` | Generate creative research directions |
| `/lit-review self-regulated learning` | Build a systematic literature review |
| `/concept cognitive load theory` | Create a concept card |
| `/weekly-report` | Summarize your week's research |

## What Was Generated

After `/init`, these files are created for you:

- `CLAUDE.md` — Project instructions tailored to your field
- `.mcp.json` — MCP server configuration
- `.scholar-flow.yaml` — Your settings (re-run `/init` to update)
- `.claude/commands/*.md` — Slash commands
- `references/*/` — Research skills with your domain data
- `domains/{your-field}/` — Domain knowledge pack (if auto-generated)

## Tips

- **Re-run `/init`** anytime to update your setup (existing notes are preserved)
- **Create custom skills** by adding `SKILL.md` files to `references/{name}/`
- **Domain packs** can be edited in `domains/{your-field}/` to refine theories, journals, etc.
- Notes are auto-saved — you never need to ask "save this"
