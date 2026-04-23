# Integration Contract — PhD-Research

**Status:** Authoritative.
**Verification:** Run `bash .opencode/verifiers/run-all.sh`.

## C1 — Frontmatter

Every file under `.opencode/agent/*.md` must declare:

- `description`
- `mode`
- `model`
- `tools`
- `permission`

Audit agents must:

- use `github-copilot/gpt-5.4`
- declare `fallback_model`

Strict read-only audit agents must also set:

- `tools.write: false`
- `tools.edit: false`

`meta-optimizer` is the single exception: it may write proposal files under `.opencode/proposals/`.

## C2 — Persistence

Every note saved to `/Users/xuyongheng/Obsidian-Vault/` must include:

1. frontmatter with `title`, `date`, `type`, `tags`, `source`
2. trailing `Related notes` block
3. a valid save path under the current 3-folder vault layout

## C3 — Audit Contract

Every command in `.opencode/command/*.md` must declare an `audit:` policy.

Research commands must document their mandatory audit behavior:

- `/find` → auto audit depending on route
- `/read` → summary and citation verification
- `/think` → novelty / concept / citation audit depending on route
- `/write` → citation and coverage audit
- `/plan` → full doctrine-driven audit chain
- `/review` → cadence-specific review/audit logic

Only `/admin` may use `audit: off`.

## C4 — Trace Contract

Commands and audit agents must emit JSONL traces under `.opencode/traces/`.

The system may use either:

- dated trace files under `.opencode/traces/YYYY-MM-DD/`
- session trace files under `.opencode/traces/session-*.jsonl`

Traces are append-only.

## C5 — Memory Contract

Persistent project memory lives under `.opencode/memory/`.

Core files:

- `phd-doctrine.md`
- `decisions.md`
- `research-log.md`
- `failed-ideas.md`
- `patterns.md`

These are append-oriented project memory files and should not be casually repurposed.

## C6 — Doctrine Contract

Research-class agents must load and respect `.opencode/memory/phd-doctrine.md`.

The four mandatory fields are:

- `mainstream_anchor`
- `sub_branch`
- `theoretical_contribution`
- `so_what`

They must appear in downstream research direction framing where applicable.

## C7 — Plugin Contract

`.opencode/plugins/phd.ts` is the only runtime plugin and must:

1. remain a single TypeScript file
2. avoid unnecessary dependency sprawl
3. never mutate `.opencode/memory/*`
4. handle hook errors defensively
5. support trace writing and deep-dive checkpointing for `/plan --mode=deep-dive`

## C10 — Trace Schema Contract

Trace files under `.opencode/traces/` must remain append-only JSONL.

Minimum schema rules:

1. command traces must include `ts`, `command`, `audit`
2. agent traces must include `ts`, `agent`
3. audit-agent traces must also include `model`
4. fallback trace examples must include `event`, `agent`, `reason`, `fallback`
5. session trace files under `.opencode/traces/session-*.jsonl` must include `ts`, `event`
6. command and agent docs that declare `## Trace` must show a JSON example matching these minimum fields

## C11 — Agent Taxonomy Contract

Agent categories are explicit and enforceable.

### Audit Agents

Audit agents are:

- `citation-verifier`
- `coverage-critic`
- `summary-auditor`
- `novelty-checker`
- `concept-auditor`
- `meta-optimizer`

Rules:

1. must use `github-copilot/gpt-5.4`
2. must declare `fallback_model`
3. must declare trace examples with `model`
4. only `meta-optimizer` may write, and only to `.opencode/proposals/`

### Research-Class Agents

Research-class agents are:

- `deep-dive`
- `theory-mapper`
- `research-planner`
- `literature-searcher`
- `writing-drafter`
- `research-ideator`
- `paper-summarizer`
- `concept-explainer`
- `lit-review-builder`

Rules:

1. must reference `.opencode/memory/phd-doctrine.md`
2. must declare `## Output Language`

### Vault-Persistence Agents

Vault-persistence agents are:

- `theory-mapper`
- `literature-searcher`
- `writing-drafter`
- `paper-summarizer`
- `concept-explainer`
- `lit-review-builder`
- `research-ideator`
- `deep-dive`
- `zotero-curator`
- `data-extractor`

Rules:

1. may persist notes only under `/Users/xuyongheng/Obsidian-Vault/Inbox/`, `/Notes/`, or `/Writing/`
2. must follow the Chinese-first output policy

### Runtime Output Agents

Runtime-output agents are:

- `paper-fetcher`
- `data-extractor`
- `meta-optimizer`

Rules:

1. non-vault outputs must stay under `arxiv_cache/`, `outputs/`, or `.opencode/proposals/`

### Orchestrator Agents

Orchestrator agents are:

- `deep-dive`

Rules:

1. `task: true` is only allowed here
