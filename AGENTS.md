# AGENTS.md

This file provides guidance to OpenCode (and other AGENTS.md-aware agents) when working with this repository.

## Project

AI in Education research assistant workspace (PhD level).
Focus areas: AI literacy, self-regulated learning, learning analytics, intelligent tutoring systems.

## Tool Ecosystem

| Tool | Path | Role |
|------|------|------|
| OpenCode | This directory | Analysis engine and command center |
| Obsidian | `/Users/xuyongheng/Obsidian-Vault` | Knowledge base |
| Zotero | Zotero-managed | PDF storage and citation management |

### MCP Strategy

- **Search academic papers** → Prefer Semantic Scholar (`semantic-scholar` MCP)
- **Search preprints** → Use arXiv (`arxiv` MCP)
- **Manage references** → Use Zotero MCP (`zotero`)
- **Read/write notes** → Use obsidian-fs MCP (`obsidian-fs`)
- **Complex reasoning** → Use Sequential Thinking (`sequential-thinking`)

In OpenCode, MCP tools are exposed as `<server>_<tool>` (e.g. `semantic-scholar_search_paper`). Prefer MCP tools over generic web search for academic content.

## Subagent Routing

Specialised subagents live under `.opencode/agent/`. The main agent should delegate via the `task` tool when a request matches:

| Subagent | Triggers when... |
|----------|------------------|
| `literature-searcher` | User wants to find/search papers, build a reading list, or survey a topic |
| `paper-summarizer` | User provides a paper (title/DOI/arXiv ID/PDF) and wants a structured summary |
| `lit-review-builder` | User wants a systematic literature review or synthesis across many studies |
| `research-ideator` | User wants ideation, brainstorming, gap analysis, or new research directions |
| `concept-explainer` | User asks "what is X", "explain X", or wants a concept card |
| `research-planner` | Need to turn a vague topic into a structured search brief |
| `citation-verifier` | Need to verify a list of papers actually exists |
| `coverage-critic` | Need to audit whether a search result set covers a topic well |
| `summary-auditor` | Need to verify a paper summary against the real paper |
| `novelty-checker` | Need to score the novelty of research directions |
| `deep-dive` | User wants a full multi-stage verified research pipeline on a topic |

## Persistence Rules

Whenever a task produces content worth keeping, **automatically save** to Obsidian. Do not ask "should I save?" — just save.

### Save Path Mapping

| Output Type | Save Path | Filename Format |
|------------|-----------|-----------------|
| Daily paper picks | `/Users/xuyongheng/Obsidian-Vault/Daily Picks/` | `YYYY-MM-DD.md` |
| Search results | `/Users/xuyongheng/Obsidian-Vault/Search Results/` | `YYYY-MM-DD-{keywords}.md` |
| Paper reading notes | `/Users/xuyongheng/Obsidian-Vault/Paper Notes/` | `{FirstAuthor}-{Year}-{ShortTitle}.md` |
| Ideation sessions | `/Users/xuyongheng/Obsidian-Vault/Ideation Sessions/` | `YYYY-MM-DD-{topic}.md` |
| Literature reviews | `/Users/xuyongheng/Obsidian-Vault/Literature Reviews/` | `{TopicName}.md` |
| Concept cards | `/Users/xuyongheng/Obsidian-Vault/Concept Cards/` | `{ConceptName}.md` |
| Writing drafts | `/Users/xuyongheng/Obsidian-Vault/Writing Drafts/` | `{DocumentTitle}.md` |

### Note Format

Every saved note must include YAML frontmatter:
```yaml
---
title: "{Title}"
date: "{YYYY-MM-DD}"
type: "{paper-note|ideation|lit-review|search-results|concept-card|daily-picks}"
tags:
  - {auto-generated tags}
source: "{source info}"
---
```

End of each note:
```
---
Related notes:
- [[{bidirectional links to existing notes}]]

Saved: {full timestamp}
```

### Bidirectional Links

When saving notes, scan the text and add `[[bidirectional links]]` for:
- Theoretical frameworks in AI in Education
- Research methods
- Key scholar names
- Core concepts

## Language and Style

Communicate in English. Academic terms need no special annotation.

## Domain Knowledge

Research field: AI in Education
Domain pack: See `domains/ai-in-education/` for field-specific theories, methods, journals, and keyword mappings.

### Key Journals

See `domains/ai-in-education/journals.md` for the tiered journal list used in quality filtering.

### Keyword Mapping

See `domains/ai-in-education/keyword-mapping.md` for search term synonyms and translations.

## Project Structure

```
PhD-Research/
├── .opencode/
│   ├── command/          ← OpenCode slash commands (/daily, /search-papers, etc.)
│   └── agent/            ← OpenCode subagents (deep-dive, paper-summarizer, etc.)
├── .claude/              ← Legacy Claude Code assets (kept for parity, do not edit)
├── .agents/skills/       ← Legacy Claude Code skills (kept for reference)
├── domains/              ← Domain knowledge packs
├── templates/            ← Source templates (do not modify)
├── docs/                 ← Documentation
├── arxiv_cache/          ← arXiv search cache
├── outputs/              ← Generated temporary files
├── opencode.json         ← OpenCode config (model + MCP + permissions)
└── /Users/xuyongheng/Obsidian-Vault   ← External knowledge base
```

## Available Commands

| Command | Purpose |
|---------|---------|
| `/daily` | Daily research routine |
| `/search-papers {topic}` | Multi-source literature search |
| `/summarize {paper}` | Deep paper summary and note generation |
| `/brainstorm {topic}` | Research ideation via collision matrix |
| `/lit-review {topic}` | Systematic literature review |
| `/concept {term}` | Concept explanation and card creation |
| `/weekly-report` | Weekly research activity summary |
| `/deep-dive {topic}` | Full verified multi-stage research pipeline |
