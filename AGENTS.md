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

Specialised subagents live under `.opencode/agent/` (18 total). The main agent should delegate via the `task` tool when a request matches:

### Execution agents (11)

| Subagent | Triggers when... |
|----------|------------------|
| `literature-searcher` | User wants to find/search papers, build a reading list, or survey a topic |
| `paper-fetcher` | Need to download a paper PDF (arXiv / open access / Zotero) |
| `paper-summarizer` | User provides a paper (title/DOI/arXiv ID/PDF) and wants a structured summary |
| `data-extractor` | Need to pull structured data (samples, effect sizes, instruments) from a paper |
| `lit-review-builder` | User wants a systematic literature review or synthesis across many studies |
| `research-ideator` | User wants ideation, brainstorming, gap analysis, or new research directions |
| `concept-explainer` | User asks "what is X", "explain X", or wants a concept card |
| `theory-mapper` | User wants a theory map / framework comparison across multiple theories |
| `research-planner` | Need to turn a vague topic into a structured search brief |
| `writing-drafter` | User wants long-form prose — section, draft, response letter |
| `zotero-curator` | Need to add/tag/organise items in the Zotero library |

### Audit agents (6) — must declare `fallback_model` and emit `degraded_audit:true` when fallback fires

| Subagent | Triggers when... |
|----------|------------------|
| `citation-verifier` | Need to verify a list of papers actually exists |
| `coverage-critic` | Need to audit whether a search result set covers a topic well |
| `summary-auditor` | Need to verify a paper summary against the real paper |
| `novelty-checker` | Need to score the novelty of research directions |
| `concept-auditor` | Need to verify a concept card's claims and citations |
| `meta-optimizer` | Need to audit prompts/agents for drift (invoked by `/admin meta-optimize`) |

### Orchestration (1)

| Subagent | Triggers when... |
|----------|------------------|
| `deep-dive` | User wants a full multi-stage verified research pipeline on a topic (`/plan --mode=deep-dive`) |

## Persistence Rules

Whenever a task produces content worth keeping, **automatically save** to Obsidian. Do not ask "should I save?" — just save.

### Save Path Mapping

| Output Type | Save Path | Filename Format |
|------------|-----------|-----------------|
| Daily paper picks | `/Users/xuyongheng/Obsidian-Vault/Inbox/` | `YYYY-MM-DD.md` |
| Search results | `/Users/xuyongheng/Obsidian-Vault/Inbox/` | `YYYY-MM-DD-{keywords}.md` |
| Paper reading notes | `/Users/xuyongheng/Obsidian-Vault/Notes/` | `{FirstAuthor}-{Year}-{ShortTitle}.md` |
| Ideation sessions | `/Users/xuyongheng/Obsidian-Vault/Notes/` | `YYYY-MM-DD-{topic}.md` |
| Literature reviews | `/Users/xuyongheng/Obsidian-Vault/Writing/` | `{TopicName}.md` |
| Concept cards | `/Users/xuyongheng/Obsidian-Vault/Notes/` | `{ConceptName}.md` |
| Writing drafts | `/Users/xuyongheng/Obsidian-Vault/Writing/` | `{DocumentTitle}.md` |

### Note Format

Every saved note must include YAML frontmatter:
```yaml
---
title: "{Title}"
date: "{YYYY-MM-DD}"
type: "{paper-note|ideation|lit-review|search-results|concept-card|daily-picks|weekly-report|deep-dive|documentation}"
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
│   ├── command/          ← 8 OpenCode slash commands (find/read/think/write/review/plan/admin/init)
│   ├── agent/            ← 18 OpenCode subagents (11 execution + 6 audit + 1 orchestration)
│   ├── memory/           ← Tier-1 permanent + Tier-2 90-day rotating context
│   ├── verifiers/        ← 7 contract verifiers (C1–C7) + run-all.sh + CONTRACT.md
│   └── plugin/           ← Lifecycle hooks (rotation.due, audit.degraded, dashboard.update)
├── references/           ← Legacy SKILL.md kept for reference (deprecated, see MANIFEST.md)
├── domains/              ← Domain knowledge packs
├── templates/            ← Source templates (do not modify)
├── docs/                 ← Documentation
├── scripts/              ← Migration / maintenance scripts (e.g. migrate-vault.sh)
├── evals/                ← Eval harness (queries/ bin/ reports/ results/)
├── arxiv_cache/          ← arXiv search cache
├── outputs/              ← Generated temporary files
├── opencode.json         ← OpenCode config (model + MCP + permissions)
└── /Users/xuyongheng/Obsidian-Vault   ← External knowledge base (3 folders: Inbox/Notes/Writing)
```

## Available Commands

| Command | Purpose |
|---------|---------|
| `/find {query}` | Find papers, concepts, or existing notes (auto-routes) |
| `/read {paper}` | Read a paper deeply — auto-fetches PDF, summarizes, extracts |
| `/think {topic}` | Ideation, concept cards, or theory maps (auto-routes) |
| `/write {target}` | Long-form output — draft, review, section, response |
| `/review [--cadence=day\|week\|month]` | Daily / weekly / monthly retrospective |
| `/plan {topic}` | PhD 5-step doctoral path (S1→S5); `--mode=deep-dive` for full pipeline |
| `/admin {subcommand}` | System maintenance — `meta-optimize`, `eval`, `health` |
| `/init` | First-time project setup wizard (Scholar Flow) |
