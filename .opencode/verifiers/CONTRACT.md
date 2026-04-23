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

## C8 — Prompt Harness Contract

Agent prompts must remain aligned with the Chinese-first research workspace rules.

Rules:

1. covered agents must declare `## Output Language`
2. Chinese-first output must be explicit where required
3. legacy English-first wording and legacy vault paths must not reappear
4. doctrine-required agents must reference `.opencode/memory/phd-doctrine.md`

## C9 — Command Harness Contract

Command docs under `.opencode/command/*.md` must remain structurally aligned with runtime behavior.

Rules:

1. every command must declare frontmatter `description`, `agent`, `audit`
2. audit documentation must match the declared `audit:` mode
3. required commands must declare `## Output Language`
4. doctrine-aware commands must reference `.opencode/memory/phd-doctrine.md`
5. legacy wording and out-of-layout vault paths must not reappear

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

## C12 — Runtime Reality Contract

Prompts and command docs must only describe runtime capabilities that actually exist in the current project.

Rules:

1. command-referenced agents must exist under `.opencode/agent/`
2. documented MCP/tool families must exist in `opencode.json`
3. stale or invented tool names must not appear in prompts
4. documented runtime paths must match the current project layout

## C13 — Verifier Coverage Contract

The verifier system and the contract document must stay in sync.

Rules:

1. every `check-*.sh` verifier executed by `run-all.sh` must have a matching `## Cn` section in `CONTRACT.md`
2. every `## Cn` section for an active verifier must correspond to a real `check-*.sh` script
3. `run-all.sh` success banner count must match the number of executed verifier scripts

## C14 — E2E Scenario Contract

The system must preserve a small set of canonical end-to-end research workflows.

Rules:

1. canonical scenarios must be declared in `.opencode/scenarios/e2e-scenarios.json`
2. each scenario must identify a command, the expected delegated agents, the required audit agents, the expected persistence target, and the trace/checkpoint expectations
3. every referenced command and agent must exist
4. command docs must still describe the delegated agents, audit chain, trace emission, and persistence target required by the scenario
5. `/plan --mode=deep-dive` scenarios must also preserve checkpoint behavior

## C15 — MCP Live Health Contract

Configured MCP entries must remain minimally runnable on the local machine.

Rules:

1. enabled MCP entries in `opencode.json` must have launchers available on PATH
2. local path arguments required by enabled MCPs must exist
3. safe non-interactive launcher smoke checks should pass where such probes exist
4. MCP command chains must not depend on missing executables

## C16 — Evidence Chain Contract

Core research workflows must preserve a traceable evidence chain from discovery to downstream synthesis.

Rules:

1. canonical evidence chains must be declared in `.opencode/scenarios/evidence-chains.json`
2. each evidence chain must identify a command entry point, upstream evidence sources, verification agents, persisted artifact target, and downstream handoff commands
3. covered command docs must include `## Evidence Chain` with `Source evidence:`, `Verification trail:`, `Persisted artifact:`, and `Downstream handoff:` labels
4. covered agent docs must include `## Evidence Chain` with `Upstream evidence:`, `Output artifact:`, `Verification note:`, and `Downstream handoff:` labels
5. persisted research artifacts in the chain must stay inside the current `Inbox/`, `Notes/`, and `Writing/` vault layout and document how downstream work links back to upstream evidence
6. the verifier must sample recent research notes and ensure each sampled artifact keeps a minimal evidence marker set appropriate to its note type, allowing equivalent downstream-link markers where the historical note format varies

## C17 — Trace-to-Note Link Contract

Runtime traces must be able to point back to persisted research notes.

Rules:

1. `.opencode/plugins/phd.ts` must support best-effort `note.persisted` session trace events for note-producing research commands
2. `.opencode/traces/README.md` must document the `note.persisted` event schema
3. when a `note.persisted` event exists, it must include at least `ts`, `event`, `command`, `note_path`, and `vault_type`
4. every traced `note_path` must exist under `/Users/xuyongheng/Obsidian-Vault/Inbox/`, `/Notes/`, or `/Writing/`
5. every traced note must keep frontmatter `source`, so runtime linkage and evidence provenance remain aligned

## C18 — Checkpoint Closure Contract

Deep-dive workflows must preserve a resumable closure from checkpoints to synthesized outputs and memory updates.

Rules:

1. checkpoint behavior for `/plan --mode=deep-dive` must remain documented in command, plugin, and checkpoint docs
2. `.opencode/plugins/phd.ts` must preserve deep-dive stage checkpoint writes with `kind`, `stage`, and `/plan --mode=deep-dive` provenance
3. `deep-dive` must document the post-synthesis handoff into `.opencode/memory/research-log.md` and `.opencode/memory/decisions.md`
4. if recent checkpoint files exist, they must be valid JSON and include `ts`, `session_id`, and `kind`; deep-dive stage checkpoints must also include `stage`
5. if recent deep-dive checkpoints exist together with recent deep-dive outputs, the verifier should ensure the closure docs still point from checkpointed work to synthesis notes and memory files
