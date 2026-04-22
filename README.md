# PhD-Research

> An OpenCode-powered research assistant workspace for AI-in-Education PhD work.
> Multi-agent literature search, paper summarization, ideation, and PhD-level research routing —
> with cross-model adversarial review and persistent project memory.

This is a **personal, customized** workspace, not a redistributable framework.
It runs on [OpenCode](https://opencode.ai) and is wired to Obsidian + Zotero.

---

## Stack

| Layer | Tool | Role |
|------|------|------|
| Runtime | OpenCode (`opencode.json`) | Agent + command engine |
| Primary model | `github-copilot/claude-opus-4.7` | Execution layer |
| Adversarial model | `gpt-5.4` | Audit / second-opinion layer |
| Knowledge base | Obsidian (`/Users/xuyongheng/Obsidian-Vault`) | Notes, links, daily logs |
| Reference manager | Zotero | PDF + citation storage |
| Project memory | `.opencode/memory/` | Persistent decisions, failed ideas, patterns, doctrine |

### MCP Servers (configured in `opencode.json`)

| Server | Purpose |
|--------|---------|
| `semantic-scholar` | Primary academic paper search |
| `arxiv` | Preprint search |
| `paper-search` | Multi-source aggregator |
| `zotero` | Reference management |
| `obsidian-fs` | Knowledge base read/write |
| `sequential-thinking` | Multi-step reasoning |

> Brave Search MCP is **optional** (gray literature). Not configured by default.

---

## Available Slash Commands

| Command | Purpose |
|---------|---------|
| `/daily` | Daily research routine |
| `/search-papers {topic}` | Multi-source literature search (default `--years=5`) |
| `/summarize {paper}` | Deep paper summary + auto-save to Obsidian |
| `/brainstorm {topic}` | Research ideation (sub-branch mode + So-What gating) |
| `/lit-review {topic}` | Systematic review (`--mode=quick-survey` for ≤2y reviews) |
| `/concept {term}` | Concept card with audit |
| `/weekly-report` | Weekly research summary |
| `/deep-dive {topic}` | Verified multi-stage research pipeline |
| `/phd-route {topic}` | **PhD-level research positioning** (S1→S5 doctrine flow) |
| `/fetch {ref}` | DOI/arXiv/URL → Zotero |
| `/extract {paper}` | Tables/figures → structured markdown |
| `/draft {section}` | Reading notes → writing draft |
| `/curate` | Zotero library cleanup |
| `/theory-map {topic}` | Theoretical framework genealogy |
| `/meta-optimize` | Self-improvement proposals (human-approved) |
| `/eval {agent}` | Regression on fixed benchmark |

---

## Subagents

Located in `.opencode/agent/`. All have access to `references/` (legacy skill data).

### Execution layer (model: `claude-opus-4.7`)
- `research-planner` · `literature-searcher` · `paper-summarizer`
- `research-ideator` (sub-branch mode) · `lit-review-builder` · `concept-explainer`
- `paper-fetcher` · `theory-mapper` · `data-extractor`
- `writing-drafter` · `zotero-curator`

### Audit layer (model: `gpt-5.4`, adversarial)
- `coverage-critic` · `citation-verifier` · `summary-auditor`
- `novelty-checker` (So-What Gate) · `concept-auditor` · `meta-optimizer`

### Orchestration layer
- `deep-dive` · `/phd-route` (5-stage S1→S5)

---

## PhD Research Doctrine

The system enforces a methodological constraint at the agent level:

> **A PhD = small sub-branch within a mainstream topic + theoretical contribution + answer "so what".**

Operationalized as a 5-step path (`.opencode/memory/phd-doctrine.md`):

1. **S1 Deep Search** — last 5 years, hotspots + gaps
2. **S2 Quick Survey** — last 2 years review papers
3. **S3 Theory Inventory** — genealogy via `theory-mapper`
4. **S4 Sub-Branch Positioning** — small cut within mainstream
5. **S5 So-What Validation** — theoretical contribution + downstream change

Every brainstorm output must carry `mainstream_anchor`, `sub_branch`,
`theoretical_contribution`, `so_what` — otherwise rejected by `novelty-checker`.

---

## Project Layout

```
PhD-Research/
├── .opencode/
│   ├── agent/         # 18 subagents
│   ├── command/       # Slash commands
│   ├── memory/        # phd-doctrine + decisions + failed-ideas + patterns
│   ├── checkpoints/   # Resumable workflow state
│   ├── traces/        # Audit prompt/response logs
│   ├── verifiers/     # Machine-checkable contracts
│   ├── proposals/     # meta-optimizer suggestions (human-approved)
│   └── hooks/         # Session lifecycle hooks
├── references/        # Legacy skill data (domain.yaml, theories.yaml, ...)
├── domains/           # Domain knowledge packs (ai-in-education)
├── docs/              # Documentation
├── evals/             # Benchmark queries + results
├── arxiv_cache/       # arXiv response cache
├── outputs/           # Temporary generated files
├── opencode.json      # Runtime config (models, MCP, permissions)
├── AGENTS.md          # Authoritative agent guidance
└── README.md          # This file
```

---

## Getting Started

```bash
opencode  # in this directory
```

Then in the session:
```
/daily              # morning routine
/phd-route AI literacy in K-12   # PhD-level positioning
```

---

## Memory & Learning

The system continuously writes to `.opencode/memory/`:
- **decisions.md** — append on workflow completion
- **failed-ideas.md** — append on novelty-checker reject
- **patterns.md** — append after paper batch summarization
- **phd-doctrine.md** — static, hand-edited only

Hooks load these files on `session-start` so prior context is always available.

---

## License

MIT — see [LICENSE](LICENSE).
