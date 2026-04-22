# Integration Contract — PhD-Research Workflow System

**Status:** Authoritative. All agents and commands MUST satisfy these six contracts.
**Owner:** Meta-optimizer (P5) audits compliance weekly.
**Verification:** Automated checks live in this directory. Run `bash .opencode/verifiers/run-all.sh` to validate.
**Location:** This file lives alongside the verifier scripts that enforce it (`.opencode/verifiers/CONTRACT.md`).

---

## C1 — Frontmatter Contract (every agent)

Every file under `.opencode/agent/*.md` MUST have YAML frontmatter with:

| Field | Required | Allowed values |
|---|---|---|
| `description` | yes | non-empty string |
| `mode` | yes | `subagent` (for delegated agents) or `primary` (for orchestrators) |
| `model` | yes | `github-copilot/claude-opus-4.7` (primary) OR `github-copilot/gpt-5.4` (audit agents only) |
| `tools` | yes | object — audit agents must have `write: false, edit: false` |
| `permission` | yes | object — audit agents must have `edit: deny` |

**Audit agents** (citation-verifier, coverage-critic, summary-auditor, novelty-checker) MUST be on `gpt-5.4` and MUST be read-only.

**Verifier:** `.opencode/verifiers/check-frontmatter.sh`

---

## C2 — Persistence Contract (every saved artifact)

Every note saved to `/Users/xuyongheng/Obsidian-Vault/` MUST contain:

1. YAML frontmatter with `title`, `date` (YYYY-MM-DD), `type`, `tags`, `source`
2. Trailing block:
   ```
   ---
   Related notes:
   - [[link]] [[link]]

   Saved: <full ISO timestamp>
   ```
3. Type ∈ { `paper-note`, `ideation`, `lit-review`, `search-results`, `concept-card`, `daily-picks`, `weekly-report`, `deep-dive` }
4. Path matches the AGENTS.md "Save Path Mapping" table

**Verifier:** `.opencode/verifiers/check-persistence.sh` (samples last-7-day notes)

---

## C3 — Audit Contract (every research command)

Every command in `.opencode/command/*.md` (except `init`, `weekly-report`) MUST:

1. Document a `Mandatory post-audit` step in its workflow
2. Either invoke an audit agent OR document `--no-audit` as the explicit user-controlled bypass
3. Pass `--no-audit` is **forbidden** for `/deep-dive`
4. The audit agent invoked must match the command:
   - search-papers → coverage-critic
   - summarize → summary-auditor + citation-verifier
   - brainstorm → novelty-checker (So-What Gate) + citation-verifier
   - lit-review → coverage-critic + citation-verifier
   - deep-dive → all four
   - concept → citation-verifier
   - daily → citation-verifier (lightweight)

**Verifier:** `.opencode/verifiers/check-audit-contract.sh`

---

## C4 — Trace Contract (every command + every audit agent)

Every command and every audit agent MUST emit a JSONL trace line per invocation to:

```
.opencode/traces/YYYY-MM-DD/<command-or-agent>.jsonl
```

Required fields per line:
- `ts` (ISO-8601)
- `agent` or `command` (string)
- `model` (string, for agents)
- Verdict / counts relevant to the agent (see each agent's adversarial protocol section)

Traces are append-only, never rewritten. The meta-optimizer (P5) reads these to compute weekly quality trends.

**Verifier:** `.opencode/verifiers/check-traces.sh` (validates JSONL parseability for the last 7 days)

---

## C5 — Memory Contract (failed ideas + decisions + patterns + doctrine)

`.opencode/memory/` is the system's persistent wisdom layer.

| File | Write rule | Read rule |
|---|---|---|
| `phd-doctrine.md` | Manual edit only (this is the constitution) | Loaded by every research-class agent at session start |
| `decisions.md` | Append-only — log each major method/scope decision | Read before any conflicting decision |
| `failed-ideas.md` | Append-only — auto-written by novelty-checker on REJECTED | Loaded by research-ideator before brainstorming to prevent re-proposing dead-ends |
| `patterns.md` | Append-only — extracted by deep-dive S6 + meta-optimizer | Read by research-class agents for pattern reuse |

No agent may overwrite or delete entries in `decisions.md`, `failed-ideas.md`, or `patterns.md`. Append-only.

**Verifier:** `.opencode/verifiers/check-memory.sh` (validates append-only via git history)

---

## C6 — Doctrine Contract (research-class agents only)

The following agents MUST load `.opencode/memory/phd-doctrine.md` at session start and explicitly cite it in their reasoning:

- `research-ideator`
- `novelty-checker` (the So-What Gate enforcer)
- `lit-review-builder`
- `deep-dive`
- `theory-mapper` (P4)
- and the `/phd-route` orchestrator (P4)

The doctrine's 4 mandatory fields (`mainstream_anchor`, `sub_branch`, `theoretical_contribution`, `so_what`) MUST appear in every research direction proposed, every literature review's "positioning" section, and every deep-dive's final brief.

Non-research agents (paper-summarizer, concept-explainer, citation-verifier, etc.) do NOT need to load the doctrine.

**Verifier:** `.opencode/verifiers/check-doctrine-references.sh`

---

## C7 — Plugin Contract (runtime event hooks)

The file `.opencode/plugins/phd.ts` is the ONLY plugin and MUST:

1. Be a single TypeScript file with zero npm dependencies (Node/Bun built-ins only).
2. Export a default async plugin function (and/or `PhdPlugin` named export) returning an event-subscription object.
3. Subscribe at minimum to: `session.created`, `session.idle`, `session.compacted`, `experimental.session.compacting`, `command.executed`, `tool.execute.before`, `tool.execute.after`.
4. Write per-session traces to `.opencode/traces/session-<id>.jsonl` (append-only).
5. Write `/deep-dive` stage checkpoints to `.opencode/checkpoints/<session>-deep-dive-<stage>-<ts>.json` — and NOT write checkpoints for any other command (locked decision).
6. Never throw out of a hook (all fs ops wrapped in try/catch).
7. Never mutate `.opencode/memory/*`.
8. Inject a doctrine-preservation block into `experimental.session.compacting` so long research threads survive context compaction.

If `.opencode/package.json` appears (OpenCode runtime auto-generates it), it MUST be gitignored. The source file `phd.ts` itself must import only `node:*` modules.

**Verifier:** `.opencode/verifiers/check-plugin.sh`

---

## Compliance & Drift

The meta-optimizer (P5) runs all six verifiers weekly. Any contract violation:
1. Writes a `proposal-YYYY-MM-DD-<n>.md` under `.opencode/proposals/` describing the drift and a suggested patch.
2. Surfaces the proposal in `/weekly-report`.
3. **Never auto-applies** — human approval required before any contract or agent rewrite.

This is the integration backbone. Violating it silently breaks the assurance chain.
