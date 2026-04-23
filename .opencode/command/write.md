---
description: Write long-form output — draft, section, literature review, or response
agent: build
audit: on
---

Write a long-form research output: $ARGUMENTS

## Kinds

Parse `--kind=draft|review|section|response` from `$ARGUMENTS` (default: inferred from phrasing):

- `draft` → a full working draft of a piece (related work, methods, discussion). Delegate to `writing-drafter`.
- `review` → a systematic literature review across many studies. Delegate to `lit-review-builder`. Supports `--mode=quick-survey` (review articles only, 2-year window, skips PRISMA) for rapid S2-style panoramas.
- `section` → one labeled paper section (e.g., "Related Work", "Limitations"). Delegate to `writing-drafter` with a tight section brief.
- `response` → response letter / rebuttal to reviewers. Delegate to `writing-drafter` with `--tone=response`.

## Effort

`--effort=quick|standard|deep` (default: `standard`). Deep mode runs extra coverage-critic passes on cited literature.

## Mandatory audit chain — `audit: on` (non-negotiable)

Every `/write` invocation runs:
1. **`citation-verifier`** (GPT-5.4) — every citation must resolve. Hallucinated refs block save.
2. **`coverage-critic`** (GPT-5.4) — if the write cites a literature base, coverage gaps are flagged.
3. **Doctrine check** — if the piece makes claims about research direction / contribution, the 4 doctrine fields must be present somewhere (body or footer metadata). Missing fields abort save.
4. **Summary-auditor** (GPT-5.4) for reviews only — spot-checks 5 random claims against their cited papers.

Load `.opencode/memory/phd-doctrine.md` before drafting or auditing any contribution-facing output.

`--audit=off` is **forbidden** on `/write`. This constitutes the **mandatory full-pipeline audit** for this command.

## Save location

`/Users/xuyongheng/Obsidian-Vault/Writing/`, as `{DocumentTitle}.md` with YAML frontmatter including `type: "writing-draft"` or `type: "lit-review"`.

## Output Language

Default to deep Chinese for user-facing output and saved drafts. Keep paper titles in their original language. Search queries, citation metadata, flags, and API parameters remain in English academic register.

## Evidence Chain

- Source evidence: verified vault notes from `/Users/xuyongheng/Obsidian-Vault/Inbox/`, `/Notes/`, and `/Writing/`, plus any explicit brief or `reference_list` provided by the caller.
- Verification trail: `citation-verifier`, `coverage-critic`, the doctrine check, and `summary-auditor` for reviews must all pass before save.
- Persisted artifact: save the draft or review to `/Users/xuyongheng/Obsidian-Vault/Writing/` with inline citations, frontmatter, and the downstream note context it builds on.
- Downstream handoff: the saved writing draft can be reused by `/review`, later `/write` revisions, and manuscript assembly without losing its upstream evidence base.

## Trace

One JSONL line to `.opencode/traces/$(date +%Y-%m-%d)/write.jsonl`:

```json
{"ts":"<iso>","command":"/write","audit":"on","kind":"draft|review|section|response","effort":"...","citations_checked":<n>,"hallucinated":<n>,"coverage_verdict":"SUFFICIENT|PARTIAL|INSUFFICIENT"}
```

## Hard rules

- If `citation-verifier` flags ≥ 1 hallucination → block the save and show the user the offending refs.
- If the user explicitly asks for draft without citations, allow `--no-citations` but still run doctrine check.
- Never silently soften claims to make audits pass; surface the conflict to the user.

If no target given, ask what to write.
