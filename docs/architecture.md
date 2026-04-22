# Architecture Overview

PhD-Research is an OpenCode workspace organised as **three operational layers** sitting on top of MCP tools and an Obsidian knowledge base. The structure is enforced by 7 machine-checkable contracts (`.opencode/verifiers/CONTRACT.md`).

## Three-Layer Design

```
┌──────────────────────────────────────────────────────────┐
│  Commands (8 verbs)                                      │
│  /find  /read  /think  /write  /review  /plan  /admin    │
│  /init                                                   │
└────────────────────────┬─────────────────────────────────┘
                         │ task tool routing
┌────────────────────────┴─────────────────────────────────┐
│  Agents (18 subagents)                                   │
│   ┌─ Execution (3-tier model split) ───────────────┐      │
│   │  Heavy  (claude-opus-4.7)   × 6 agents          │      │
│   │  Medium (claude-sonnet-4.6) × 4 agents          │      │
│   │  Light  (claude-haiku-4.5)  × 2 agents          │      │
│   ├─ Audit (gpt-5.4, read-only, adversarial) ─────┤      │
│   │ coverage-critic · citation-verifier · ...      │      │
│   └─ Orchestration ────────────────────────────────┘     │
│     deep-dive · plan (S1→S5)                             │
└────────────────────────┬─────────────────────────────────┘
                         │
┌────────────────────────┴─────────────────────────────────┐
│  Memory (.opencode/memory/)                              │
│   Tier 1 permanent: doctrine · decisions · research-log  │
│   Tier 2 rotated:   failed-ideas · patterns              │
└────────────────────────┬─────────────────────────────────┘
                         │
┌────────────────────────┴─────────────────────────────────┐
│  MCP tool layer                                          │
│   semantic-scholar · arxiv · paper-search · zotero       │
│   obsidian-fs · sequential-thinking                      │
└────────────────────────┬─────────────────────────────────┘
                         │
┌────────────────────────┴─────────────────────────────────┐
│  Obsidian vault (3-folder layout, R4)                    │
│   Inbox/  Notes/  Writing/  Templates/  Attachments/     │
└──────────────────────────────────────────────────────────┘
```

### Layer 1: Commands (`.opencode/command/`)

8 intent verbs. Each verb is a thin router that interprets the argument shape and delegates to one or more subagents via the `task` tool. Adding a 9th command requires updating C3 (audit contract) and the corresponding verifier.

### Layer 2: Agents (`.opencode/agent/`)

Three sub-layers:

- **Execution** (11 agents) — the workers. Read-write, full tool access. Split into three cost tiers:
  - **Heavy** (`claude-opus-4.7`, 6 agents): `deep-dive`, `lit-review-builder`, `research-ideator`, `writing-drafter`, `theory-mapper`, `paper-summarizer`. Long reasoning, synthesis, structured generation.
  - **Medium** (`claude-sonnet-4.6`, 4 agents): `literature-searcher`, `research-planner`, `concept-explainer`, `data-extractor`. Querying APIs, structured extraction, brief writing.
  - **Light** (`claude-haiku-4.5`, 2 agents): `paper-fetcher`, `zotero-curator`. Mechanical PDF/citation handling, no reasoning load.
- **Audit** (6 agents, `gpt-5.4`) — adversarial second opinion. Read-only (`tools.write:false`, `permission.edit:deny`). Each declares a `fallback_model` and emits `degraded_audit:true` when the primary model is unavailable. Untouched by the execution-tier split — independence preserved.
- **Orchestration** (2 agents) — `deep-dive` runs the full 9-stage verified pipeline; `/plan` runs the 5-stage S1→S5 doctoral route.

### Layer 3: Memory (`.opencode/memory/`)

Persistent project state in two tiers (see `memory/ROTATION.md`):

| Tier | Files | Rotation |
|---|---|---|
| 1 — permanent | `phd-doctrine.md`, `decisions.md`, `research-log.md` | Never |
| 2 — rotated | `failed-ideas.md`, `patterns.md` | 90 days → `archive/YYYY-MM/` |

The `phd.ts` plugin checks rotation eligibility at `session.created` and emits a `rotation.due` event. The user runs `/admin meta-optimize --rotate` when ready. Rotation is never automatic.

### MCP tool layer (`opencode.json`)

| Server | Package | Purpose |
|--------|---------|---------|
| semantic-scholar | `semantic-scholar-fastmcp` (uvx) | Paper search and metadata |
| arxiv | `arxiv-mcp-server` (uvx) | Preprint access |
| paper-search | `paper-search-mcp` (uvx) | Multi-source aggregation |
| zotero | `zotero-mcp` (uvx) | Reference management |
| obsidian-fs | `@modelcontextprotocol/server-filesystem` (npx) | Note vault access |
| sequential-thinking | `@modelcontextprotocol/server-sequential-thinking` (npx) | Complex reasoning |

OpenCode exposes these as `<server>_<tool>` (e.g. `semantic-scholar_paper_relevance_search`).

## Data Flow Example: `/find`

```
User: /find AI literacy assessment
        │
        ▼
.opencode/command/find.md (router)
        │
        ▼ task(literature-searcher, ...)
literature-searcher (claude-sonnet-4.6, Medium tier)
        │
        ├─► reads domains/ai-in-education/keyword-mapping.md
        ├─► reads domains/ai-in-education/journals.md
        ├─► calls semantic-scholar MCP
        ├─► calls arxiv MCP
        │
        ▼
Mandatory post-audit (C3): task(coverage-critic) + task(citation-verifier)
        │
        ▼
Auto-saves to /Users/xuyongheng/Obsidian-Vault/Inbox/YYYY-MM-DD-AI-literacy-assessment.md
        │
        ▼
Trace appended to .opencode/traces/YYYY-MM-DD/find.jsonl (C4)
```

## Integration Contracts (C1–C7)

The system's correctness rests on 7 contracts in `.opencode/verifiers/CONTRACT.md`. Each has a `check-*.sh` script. Run all with:

```bash
bash .opencode/verifiers/run-all.sh   # must be 7/7 GREEN
```

| ID | Contract | Verifier |
|---|---|---|
| C1 | Every agent has required frontmatter; audit agents are read-only | `check-frontmatter.sh` |
| C2 | Every saved note matches Save Path Mapping + frontmatter schema | `check-persistence.sh` |
| C3 | Every research command invokes the correct audit agent | `check-audit-contract.sh` |
| C4 | Every command + audit agent emits JSONL traces | `check-traces.sh` |
| C5 | Tier-1 + Tier-2 memory files are append-only (git-verified) | `check-memory.sh` |
| C6 | Research-class agents load `phd-doctrine.md` and cite the 4 fields | `check-doctrine-references.sh` |
| C7 | `phd.ts` is a single dependency-free TS file with required hooks | `check-plugin.sh` |

## Plugin Layer (`.opencode/plugins/phd.ts`)

A single TypeScript file (no npm deps, Node/Bun built-ins only). Subscribes to OpenCode lifecycle events and emits the system's structured events:

| Plugin event | Trigger | Consumed by |
|---|---|---|
| `session.created` | Each new session | Loads doctrine + checks Tier-2 rotation eligibility |
| `experimental.session.compacting` | Long context | Injects doctrine-preservation block |
| `command.executed` | After every command | Appends to per-command JSONL trace |
| `tool.execute.before` / `.after` | Each tool call | Trace + dashboard counters |
| `rotation.due` | Tier-2 file >90 days | Surfaces in `/admin health` |
| `audit.degraded` | Audit agent fell back to primary model | Surfaces in next `/review` |
| `dashboard.update` | After audit / eval runs | Updates `evals/reports/` dashboard |

Built with:

```bash
cd .opencode/plugins && bun build phd.ts --target=node --outfile=phd.js
```

`.opencode/package.json` (auto-generated by OpenCode runtime) is gitignored.

## File Lifecycle

| File | Created By | Modified By | In Git |
|------|-----------|-------------|--------|
| `.opencode/command/*.md` | Developer | Developer | Yes |
| `.opencode/agent/*.md` | Developer | Developer | Yes |
| `.opencode/plugins/phd.ts` | Developer | Developer | Yes |
| `.opencode/plugins/phd.js` | bun build | bun build | No (gitignored) |
| `.opencode/verifiers/CONTRACT.md` | Developer | Developer | Yes |
| `.opencode/memory/phd-doctrine.md` | Developer | Manual edit only | Yes |
| `.opencode/memory/decisions.md` | Workflows | Append only (C5) | Yes |
| `.opencode/memory/failed-ideas.md` | `novelty-checker` | Append only (C5) | Yes |
| `.opencode/memory/archive/YYYY-MM/*` | `/admin meta-optimize --rotate` | Append only | Yes |
| `.opencode/traces/YYYY-MM-DD/*.jsonl` | Plugin / commands | Append only (C4) | Yes |
| `.opencode/checkpoints/*.json` | `/deep-dive` only | Stage transitions | Yes |
| `domains/ai-in-education/*` | Developer | Developer | Yes |
| `evals/reports/YYYY-MM-DD.md` | `/admin eval` | `/admin eval` | Yes |
| `references/*` | Legacy (READ-ONLY) | Never | Yes (deprecated) |
| Vault `Inbox|Notes|Writing/*` | Subagents | Subagents | (vault is its own repo) |
