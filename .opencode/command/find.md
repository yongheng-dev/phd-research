---
description: Find papers, concepts, or existing notes — auto-routes by query shape
agent: build
audit: auto
---

Find something in the research ecosystem: $ARGUMENTS

## Routing

Inspect `$ARGUMENTS` to classify the query:

1. **Looks like a paper search** (contains topic words, methods, or is a question like "what has been done on X"):
   → Delegate to `literature-searcher` (multi-source: Semantic Scholar + arXiv). Save to `/Users/xuyongheng/Obsidian-Vault/Inbox/` as `YYYY-MM-DD-{keywords}.md`.

2. **Looks like a concept lookup** ("what is X", "define Y", "difference between A and B"):
   → Delegate to `concept-explainer`. Save to `/Users/xuyongheng/Obsidian-Vault/Notes/` as `{ConceptName}.md`.

3. **Looks like a vault lookup** ("do I have notes on X", "find my note about Y"):
   → Grep Obsidian vault directly (no subagent), return a ranked list.

If ambiguous, ask a one-line clarification.

## Effort inference (auto)

- `$ARGUMENTS` ≤ 5 words → `quick`
- Contains "deep" / "thorough" / "full" / "comprehensive" → `deep`
- Otherwise → `standard`

Override with explicit `--effort=quick|standard|deep`.

## Audit policy — `audit: auto`

Fire post-audit when **any** of:
- Result will be saved to Obsidian (almost always true for paper searches and concept cards)
- Output contains any of the 4 doctrine fields (`mainstream_anchor`, `sub_branch`, `theoretical_contribution`, `so_what`)
- Query contains decision words ("should I", "is X worth", "better than")

Otherwise skip audit and mark output with `audit: skipped` in trace.

When firing:
- Paper search → `coverage-critic` (GPT-5.4)
- Concept card → `concept-auditor` (GPT-5.4)
- Vault lookup → no audit (read-only)

Explicit `--audit=on` forces audit; `--audit=off` skips (trace marks `audit_skipped_by_user: true`).

## Mandatory mini-audit hook

Even under `audit: auto`, if the classifier routes to paper search AND any paper in the result list lacks a DOI or arXiv ID, `citation-verifier` MUST run (a mandatory mini-audit) regardless of audit flag.

## Output Language

Default to deep Chinese for user-facing output. Keep paper titles in their original language. Search queries, filters, flags, and API parameters remain in English academic register.

## Evidence Chain

- Source evidence: live database search results, stable paper identifiers (DOI/arXiv), and coverage dimensions inferred from the query.
- Verification trail: `coverage-critic` audits the ranked set, and `citation-verifier` runs whenever any paper lacks a DOI or arXiv ID.
- Persisted artifact: save the ranked search note to `/Users/xuyongheng/Obsidian-Vault/Inbox/` with `[[Paper Title]]` wikilinks and a recommended reading order.
- Downstream handoff: the saved search note becomes admissible input for `/read`, `/think`, `/plan`, and `/write`.

## Trace

One JSONL line to `.opencode/traces/$(date +%Y-%m-%d)/find.jsonl`:

```json
{"ts":"<iso>","command":"/find","route":"search|concept|vault","effort":"quick|standard|deep","audit":"on|off|auto-fired|auto-skipped","items":<n>}
```

If no `$ARGUMENTS` given, ask what to find before routing.
