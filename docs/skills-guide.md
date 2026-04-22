# Subagent Guide

OpenCode replaces the legacy Claude Code "skills" system with **subagents** under `.opencode/agent/`. The five `references/*/SKILL.md` files are kept for provenance only — see `references/MANIFEST.md` for the deprecation policy.

This guide covers the 18 active subagents, how the 8 commands route to them, and how to add a new one.

## Routing: Command → Subagent

Every slash command is a thin router. The mapping is enforced by C3 (`check-audit-contract.sh`).

| Command | Primary subagent(s) | Mandatory audit |
|---------|---------------------|-----------------|
| `/find` | `literature-searcher`, `paper-fetcher`, `zotero-curator`, `concept-explainer`, `research-planner` | `coverage-critic` + `citation-verifier` |
| `/read` | `paper-fetcher` → `paper-summarizer` → `data-extractor` | `summary-auditor` + `citation-verifier` |
| `/think` | `research-ideator`, `concept-explainer`, `theory-mapper` | `novelty-checker` (So-What Gate) + `citation-verifier` for ideation; `concept-auditor` for concept cards |
| `/write` | `lit-review-builder`, `writing-drafter` | `coverage-critic` + `citation-verifier` |
| `/review` | (no agent — aggregates traces + vault activity) | n/a |
| `/plan` | Orchestrator: stages call `research-planner`, `literature-searcher`, `theory-mapper`, `research-ideator`, `lit-review-builder` | All four audit agents (S2, S4, S5) |
| `/admin meta-optimize` | `meta-optimizer` (audit-class, drift detection) | n/a (this *is* the audit) |
| `/admin eval` | (no agent — runs `evals/bin/run.sh`) | n/a |

## The 18 Subagents

### Execution layer (`model: github-copilot/claude-opus-4.7`)

| Agent | Description |
|---|---|
| `research-planner` | Turns vague intent into a structured search brief (asks ≤1 clarifying question) |
| `literature-searcher` | Multi-source paper discovery + screening + 6-dimension self-audit |
| `paper-fetcher` | DOI/arXiv/URL → Zotero attachment retrieval |
| `paper-summarizer` | Structured deep reading notes with checklist self-check |
| `data-extractor` | Tables / figures / parameters → structured markdown |
| `research-ideator` | N-dimensional collision matrix → 3-5 research directions (sub-branch mode) |
| `concept-explainer` | Academic concept card with definition, origin, applications |
| `lit-review-builder` | PRISMA-style systematic synthesis across many papers |
| `theory-mapper` | Theoretical framework genealogy and relationship map |
| `writing-drafter` | Reading notes → publishable prose section |
| `zotero-curator` | Library cleanup, deduplication, tag normalisation |

### Audit layer (`model: github-copilot/gpt-5.4`, read-only, adversarial)

All declare `fallback_model: github-copilot/claude-opus-4.7` and emit `degraded_audit:true` when falling back. Plugin re-emits as `audit.degraded` event.

| Agent | Catches |
|---|---|
| `coverage-critic` | Search blind spots across 6 dimensions (theory, method, time, citations, stance, dedup) |
| `citation-verifier` | Hallucinated references — every cited paper checked against Semantic Scholar |
| `summary-auditor` | Over-interpretation, missing limitations, claims without data support |
| `novelty-checker` | Saturated research directions; enforces So-What Gate (the 4 doctrine fields) |
| `concept-auditor` | Inaccurate definitions, missing seminal sources in concept cards |
| `meta-optimizer` | Cross-contract drift; writes proposals to `.opencode/proposals/` |

### Orchestration layer

| Agent | Purpose |
|---|---|
| `deep-dive` | 9-stage verified research pipeline (used by `/plan --mode=deep-dive`) |
| `/plan` (5-stage) | S1 deep search → S2 quick survey → S3 theory inventory → S4 sub-branch → S5 so-what |

## Writing a New Subagent

1. Create `.opencode/agent/{your-agent}.md` with this frontmatter:

```yaml
---
description: One-line trigger description used by the main agent's task router
mode: subagent
model: github-copilot/claude-opus-4.7
tools:
  write: true
  edit: true
  bash: true
permission:
  edit: allow
---
```

For an **audit-class agent**, change the model and lock writes:

```yaml
model: github-copilot/gpt-5.4
fallback_model: github-copilot/claude-opus-4.7
tools:
  write: false
  edit: false
permission:
  edit: deny
```

2. Body should include:
   - **Role** — what the agent does in one paragraph
   - **Inputs** — required context, tool usage rules
   - **Workflow** — numbered steps
   - **Output schema** — structured fields the caller can parse
   - **Trace requirement** — what JSONL line to emit (C4)
   - For research-class agents: **Doctrine load** block citing the 4 fields (C6)

3. If the agent should be invoked by an existing command, edit the routing logic in `.opencode/command/{verb}.md` and update C3 verifier expectations.

4. Run the verifier suite:

```bash
bash .opencode/verifiers/run-all.sh   # all 7 must be GREEN
```

C1 will fail if frontmatter is incomplete or an audit agent has writes enabled.

## Modifying Existing Subagents

Edit `.opencode/agent/{agent}.md` directly. Then:

1. Re-run `bash .opencode/verifiers/run-all.sh`
2. If you changed model/tools/permission, C1 must still pass
3. If you changed audit pairing, update C3 expectations
4. If you changed trace format, update C4 expectations
5. Commit (verifier suite must be GREEN before commit)

## Legacy `references/*/SKILL.md`

Five files (`literature-search`, `paper-summarizer`, `research-ideation`, `lit-review-builder`, `concept-explainer`) remain on disk as **provenance and re-portability artifacts only**. They are not loaded at runtime.

To make a behavioral change, edit the `.opencode/agent/*.md` file. Editing the SKILL.md does nothing.

See `references/MANIFEST.md` for the deprecation criteria and the conditions under which `references/` may eventually be deleted.
