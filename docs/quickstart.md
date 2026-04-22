# Quick Start

Get PhD-Research running in 5 minutes.

## Prerequisites

1. **OpenCode** — Install from [opencode.ai](https://opencode.ai) and authenticate with GitHub Copilot (default model `github-copilot/claude-opus-4.7`)
2. **Bun** — Required to build the `.opencode/plugins/phd.ts` plugin
3. **Node.js 18+** — `npx` is used by `obsidian-fs` and `sequential-thinking` MCP servers
4. **Python 3.10+ with uv** — `uvx` is used by `semantic-scholar`, `arxiv`, `paper-search`, `zotero` MCP servers
5. **Obsidian Vault** at `/Users/xuyongheng/Obsidian-Vault` (with `Inbox / Notes / Writing` folders)
6. **Zotero** desktop client running (only if you use the `zotero` MCP)

## Setup

```bash
git clone <repo-url> PhD-Research
cd PhD-Research

# One-time plugin build
cd .opencode/plugins && bun build phd.ts --target=node --outfile=phd.js && cd ../..

# Verify integrity (must be 7/7 GREEN)
bash .opencode/verifiers/run-all.sh

# Launch
opencode
```

OpenCode auto-loads `opencode.json` + `AGENTS.md`, registers the 6 MCP servers, and exposes the 8 commands and 18 subagents in `.opencode/`.

## First-time wizard (optional)

```
/init
```

Walks through field configuration, MCP keys, and Obsidian path setup. Skip if you've already cloned a configured workspace.

## Try the verbs

| Command | What it does |
|---------|--------------|
| `/find AI literacy assessment` | Multi-source paper search → saves to `Inbox/` |
| `/read arXiv:2310.02207` | Auto-fetches + deep-reads → saves to `Notes/` |
| `/think assessment of AI literacy` | Ideation / concept card / theory map → `Notes/` |
| `/write lit review on AI literacy` | Long-form draft → `Writing/` |
| `/review --cadence=day` | Today's research summary |
| `/plan AI literacy in K-12` | PhD doctoral 5-step route (S1→S5) |
| `/admin health` | System health + verifier status |

## Where output goes

The Obsidian vault uses a **3-folder layout**. The save paths are defined in `AGENTS.md` Save Path Mapping and enforced by C2 (`.opencode/verifiers/check-persistence.sh`):

| Output type | Folder | Filename pattern |
|---|---|---|
| Daily picks, search results | `Inbox/` | `YYYY-MM-DD[-keywords].md` |
| Paper notes, ideation, concept cards | `Notes/` | `{Author}-{Year}-{ShortTitle}.md` or `YYYY-MM-DD-{topic}.md` |
| Lit reviews, writing drafts | `Writing/` | `{TopicName}.md` |

You never need to ask "save this" — every research output auto-saves with frontmatter and bidirectional links.

## Tips

- **Verifier suite runs in <5s.** Run `bash .opencode/verifiers/run-all.sh` before every commit.
- **Memory tiers**: Tier-1 files (`decisions.md`, `phd-doctrine.md`, `research-log.md`) accumulate forever. Tier-2 files (`failed-ideas.md`, `patterns.md`) rotate to `archive/YYYY-MM/` after 90 days when you run `/admin meta-optimize --rotate`.
- **Audit fallback**: If `gpt-5.4` is unreachable, audit agents fall back to `claude-opus-4.7` and emit a `degraded_audit:true` flag — visible in the next `/review` output.
- **Domain pack**: Edit `domains/ai-in-education/` to refine theories, journals, keyword mapping. See `docs/creating-domains.md` to add a new field.
