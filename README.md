# PhD-Research

> An OpenCode-powered research assistant workspace for AI-in-Education PhD work.
> Eight intent verbs route to 18 specialised subagents, with cross-model adversarial audit
> and a tiered persistent memory layer.

This is a **personal, customised** workspace, not a redistributable framework.
It runs on [OpenCode](https://opencode.ai) and is wired to Obsidian + Zotero.

---

## Stack

| Layer | Tool | Role |
|------|------|------|
| Runtime | OpenCode (`opencode.json`) | Agent + command engine |
| Primary model | `github-copilot/claude-opus-4.7` | Execution layer |
| Audit model | `github-copilot/gpt-5.4` | Adversarial / second-opinion layer |
| Audit fallback | `github-copilot/claude-opus-4.7` | Mandatory fallback when gpt-5.4 unavailable (emits `degraded_audit:true`) |
| Knowledge base | Obsidian (`/Users/xuyongheng/Obsidian-Vault`) | Notes, links, daily logs (3-folder layout) |
| Reference manager | Zotero | PDF + citation storage |
| Project memory | `.opencode/memory/` | Tier-1 permanent + Tier-2 90-day rotated |

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

## Slash Commands (8 verbs)

The command surface was collapsed from 17 single-purpose commands to 8 intent verbs in R1+R2.
Each verb auto-routes to the right subagent based on the argument shape.

| Command | Purpose |
|---------|---------|
| `/find {query}` | Find papers, concepts, or existing notes — auto-routes by query shape |
| `/read {paper}` | Read a paper deeply — auto-fetches PDF, summarises, extracts |
| `/think {topic}` | Ideation, concept cards, or theory maps — auto-selected from intent |
| `/write {target}` | Long-form output — draft, section, literature review, response |
| `/review [--cadence=day\|week\|month]` | Daily / weekly / monthly retrospective |
| `/plan {topic}` | PhD 5-step doctoral path (S1→S5); `--mode=deep-dive` for full pipeline |
| `/admin {subcommand}` | System maintenance — `meta-optimize`, `eval`, `health`, `init` |
| `/init` | First-time project setup wizard (Scholar Flow) |

Legacy single-purpose names (`/search-papers`, `/summarize`, `/brainstorm`, `/lit-review`, `/concept`, `/theory-map`, `/daily`, `/weekly-report`, `/deep-dive`, `/phd-route`, `/fetch`, `/extract`, `/draft`, `/curate`, `/meta-optimize`, `/eval`) are removed. They are folded into the verbs above.

---

## Subagents

Located in `.opencode/agent/`. Eighteen subagents in three layers.

### Execution layer (model: `claude-opus-4.7`)
- `research-planner` · `literature-searcher` · `paper-summarizer`
- `research-ideator` (sub-branch mode) · `lit-review-builder` · `concept-explainer`
- `paper-fetcher` · `theory-mapper` · `data-extractor`
- `writing-drafter` · `zotero-curator`

### Audit layer (model: `gpt-5.4`, read-only, adversarial)
- `coverage-critic` · `citation-verifier` · `summary-auditor`
- `novelty-checker` (So-What Gate) · `concept-auditor` · `meta-optimizer`

Every audit agent declares `fallback_model: github-copilot/claude-opus-4.7` and emits `degraded_audit:true` plus an `audit.degraded` plugin event when the primary model is unavailable.

### Orchestration layer
- `deep-dive` · `/plan` (5-stage S1→S5 doctoral route)

---

## PhD Research Doctrine

The system enforces a methodological constraint at the agent level:

> **A PhD = small sub-branch within a mainstream topic + theoretical contribution + answer "so what".**

Operationalised as a 5-step path (`.opencode/memory/phd-doctrine.md`):

1. **S1 Deep Search** — last 5 years, hotspots + gaps
2. **S2 Quick Survey** — last 2 years review papers
3. **S3 Theory Inventory** — genealogy via `theory-mapper`
4. **S4 Sub-Branch Positioning** — small cut within mainstream
5. **S5 So-What Validation** — theoretical contribution + downstream change

Every brainstorm output must carry `mainstream_anchor`, `sub_branch`, `theoretical_contribution`, `so_what` — otherwise rejected by `novelty-checker`.

---

## Project Layout

```
PhD-Research/
├── .opencode/
│   ├── agent/         # 18 subagents
│   ├── command/       # 8 slash commands
│   ├── memory/        # Tier-1 (decisions, doctrine, research-log)
│   │   ├── archive/   # Tier-2 archives (YYYY-MM/)
│   │   └── ROTATION.md
│   ├── verifiers/     # 7 contract checks (C1–C7)
│   │   ├── CONTRACT.md      # AUTHORITATIVE integration contract
│   │   └── run-all.sh       # must be 7/7 GREEN before any commit
│   ├── plugins/       # phd.ts (single TS plugin, bun-built)
│   ├── hooks/         # Session lifecycle hooks
│   ├── checkpoints/   # /deep-dive resume state
│   ├── traces/        # Per-session JSONL audit trail
│   └── proposals/     # meta-optimizer suggestions (human-approved)
├── references/        # Legacy Claude Code skills (READ-ONLY, see MANIFEST.md)
├── domains/           # Domain knowledge packs (ai-in-education)
├── docs/              # Documentation
├── evals/             # Benchmark queries + reports + dashboard
├── scripts/           # Migration / maintenance scripts
├── arxiv_cache/       # arXiv response cache
├── outputs/           # Temporary generated files
├── opencode.json      # Runtime config (models, MCP, permissions)
├── AGENTS.md          # Authoritative agent guidance
└── README.md          # This file
```

The Obsidian vault is external and uses a **3-folder layout** (R4 migration):

```
/Users/xuyongheng/Obsidian-Vault/
├── Inbox/        # Daily picks, search results (transient)
├── Notes/        # Paper notes, ideation, concept cards
├── Writing/      # Lit reviews, drafts, long-form
├── Templates/
└── Attachments/
```

---

## Getting Started

```bash
opencode  # in this directory
```

Then in the session:

```
/find AI literacy assessment        # multi-source search
/read arXiv:2310.02207              # deep read
/plan AI literacy in K-12           # PhD-level positioning (S1→S5)
/review --cadence=week              # weekly retrospective
```

Verify integrity at any time:

```bash
bash .opencode/verifiers/run-all.sh   # must be 7/7 GREEN
```

---

## Memory & Learning

The system writes to `.opencode/memory/` continuously. Files split into two tiers — see `.opencode/memory/ROTATION.md` for the full policy.

### Tier 1 — Permanent (never rotated)

| File | Written by |
|------|------------|
| `phd-doctrine.md` | Manual edit only (the constitution) |
| `decisions.md` | Append on workflow completion |
| `research-log.md` | `/think`, `/read`, manual |

### Tier 2 — 90-day rotated → `archive/YYYY-MM/`

| File | Written by |
|------|------------|
| `failed-ideas.md` | `novelty-checker` on REJECT |
| `patterns.md` | `paper-summarizer` after batch runs |

The `phd.ts` plugin emits a `rotation.due` event when entries exceed 90 days; the user runs `/admin meta-optimize --rotate` when ready. **Rotation is never automatic.**

---

## Integration Contract

All agents and commands must satisfy seven machine-checkable contracts (C1–C7) defined in `.opencode/verifiers/CONTRACT.md`. Each contract has a corresponding `check-*.sh` verifier. The full suite runs via `bash .opencode/verifiers/run-all.sh`.

| Contract | Enforces |
|---|---|
| C1 — Frontmatter | Every agent declares model, mode, tools, permission |
| C2 — Persistence | Every saved note matches Save Path Mapping + frontmatter schema |
| C3 — Audit | Every research command invokes the right audit agent |
| C4 — Trace | Every command + audit agent emits JSONL traces |
| C5 — Memory | Tier-1 + Tier-2 files are append-only (git-verified) |
| C6 — Doctrine | Research-class agents load `phd-doctrine.md` and cite the 4 fields |
| C7 — Plugin | `phd.ts` is a single dependency-free TS file with required event subscriptions |

---

## Rollback Anchors

| Tag | Purpose |
|---|---|
| `pre-claude-removal` | Before legacy Claude Code asset cleanup |
| `pre-vault-refactor` | Set by `scripts/migrate-vault.sh` before the 8→3 folder migration |

---

## License

MIT — see [LICENSE](LICENSE).
