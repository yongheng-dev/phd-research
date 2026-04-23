# AGENTS.md

## Project

OpenCode-first AI in Education research workspace.

Focus areas:

- AI literacy
- self-regulated learning
- learning analytics
- intelligent tutoring systems

## Source Of Truth

When docs drift, trust this order:

1. `.opencode/command/*.md`
2. `.opencode/agent/*.md`
3. `opencode.json`
4. `.opencode/verifiers/CONTRACT.md`

## Tool Ecosystem

| Tool | Role |
|---|---|
| OpenCode | runtime and command surface |
| Obsidian | note persistence |
| Zotero | reference management |

## MCP Strategy

- paper search: Semantic Scholar first
- preprints: arXiv
- references: Zotero
- notes: obsidian-fs
- multi-step reasoning: sequential-thinking

## Active Commands

| Command | Purpose |
|---|---|
| `/find` | search papers, concepts, or notes |
| `/read` | fetch and read a paper deeply |
| `/think` | ideation, concept cards, theory maps |
| `/write` | draft long-form research output |
| `/review` | day/week/month review |
| `/plan` | PhD route and deep-dive planning |
| `/admin` | system maintenance |

## Persistence

All research outputs should save into the 3-folder vault layout:

- `Inbox/`
- `Notes/`
- `Writing/`

## Output Language Policy

Default output language is deep Chinese for both user-facing responses and persisted research notes.

- Keep paper titles in their original language; do not translate them unless the user explicitly asks
- Preserve necessary English technical terms; on first mention, write `中文术语 (English term)` when that improves clarity
- Search queries, database filters, and API parameters should remain in English academic register unless a tool requires otherwise
- Obsidian notes saved into `Inbox/`, `Notes/`, and `Writing/` must follow the same Chinese-first rule
- If the user explicitly requests English output for a specific deliverable, follow that request for the deliverable only

## Domain Knowledge

The active domain pack is:

```text
domains/ai-in-education/
```

Use it for:

- `keyword-mapping.md`
- `journals.md`
- `theories.yaml`
- `methods.yaml`
- `topics.yaml`
- `social-issues.yaml`
- `domain.yaml`

## Project Structure

```text
PhD-Research/
├── .opencode/
│   ├── command/
│   ├── agent/
│   ├── memory/
│   ├── plugins/
│   └── verifiers/
├── domains/
├── docs/
├── scripts/
├── opencode.json
├── README.md
└── 使用指南.md
```
