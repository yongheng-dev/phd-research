# Architecture Overview

Scholar Flow is a template-based personalization system that turns Claude Code into a research assistant.

## Three-Layer Design

```
┌─────────────────────────────────────────┐
│           Generated Environment          │
│  CLAUDE.md, .mcp.json, skills, commands │
├─────────────────────────────────────────┤
│           Skill Templates                │
│  Domain-agnostic research workflows      │
├─────────────────────────────────────────┤
│           Domain Packs                   │
│  Field-specific theories, journals, etc. │
└─────────────────────────────────────────┘
```

### Layer 1: Domain Packs (`domains/`)

Field-specific knowledge that varies by research discipline:
- **theories.yaml** — Theoretical frameworks (used by research-ideation collision matrix)
- **methods.yaml** — Research methods common in the field
- **topics.yaml** — Subfields and application areas
- **social-issues.yaml** — Relevant societal dimensions
- **journals.md** — Tiered venue list for quality filtering
- **keyword-mapping.md** — Search term synonyms and translations

### Layer 2: Skill Templates (`templates/`)

Research workflows written in English, parameterized with `{{PLACEHOLDERS}}`:
- Skills reference domain data via `references/` files (copied from the domain pack)
- Skills reference user paths via `{{NOTES_BASE}}/{{FOLDERS.*}}/`
- Skills are domain-agnostic — the same literature-search workflow works for education, CS, or biology

### Layer 3: Generated Environment

The `/init` wizard connects layers 1 and 2 based on user answers:
- Reads templates → substitutes placeholders → writes personalized files
- Copies domain pack data into skill reference directories
- Configures MCP servers based on available tools

## Data Flow

```
User runs /search-papers "AI literacy"
         │
         ▼
.claude/commands/search-papers.md  (generated command)
         │
         ▼
references/literature-search/SKILL.md  (generated skill)
         │
         ├─► reads references/keyword-mapping.md  (from domain pack)
         ├─► reads references/journals.md  (from domain pack)
         ├─► calls Semantic Scholar MCP
         ├─► calls arXiv MCP
         │
         ▼
Auto-saves to {{NOTES_BASE}}/{{FOLDERS.search_results}}/
```

## Configuration

`.scholar-flow.yaml` is the single source of truth for all user settings. Running `/init` again regenerates all files from this config.

## MCP Server Architecture

Scholar Flow uses Model Context Protocol (MCP) servers for external tool access:

| Server | Package | Transport | Purpose |
|--------|---------|-----------|---------|
| semantic-scholar | `semantic-scholar-fastmcp` (uvx) | stdio | Paper search and metadata |
| arxiv | `arxiv-mcp-server` (uvx) | stdio | Preprint access |
| paper-search | `paper-search-mcp` (uvx) | stdio | Multi-source aggregation |
| zotero | `zotero-mcp` (uvx) | stdio | Reference management |
| obsidian-fs | `@modelcontextprotocol/server-filesystem` (npx) | stdio | Note vault access |
| sequential-thinking | `@modelcontextprotocol/server-sequential-thinking` (npx) | stdio | Complex reasoning |

## File Lifecycle

| File | Created By | Modified By | In Git |
|------|-----------|-------------|--------|
| `templates/*.tmpl` | Developer | Developer | Yes |
| `domains/education/*` | Developer | Developer | Yes |
| `.claude/commands/init.md` | Developer | Developer | Yes |
| `CLAUDE.md` | /init | /init (re-run) | No |
| `.mcp.json` | /init | /init (re-run) | No |
| `references/*` | /init | /init (re-run) | No |
| `.scholar-flow.yaml` | /init | /init (re-run) | No |
| User-created skills | User | User | User's choice |
