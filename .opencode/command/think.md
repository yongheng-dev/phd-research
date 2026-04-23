---
description: Think — ideation, concept cards, or theory maps, auto-selected from intent
agent: build
audit: auto
---

Think through a topic: $ARGUMENTS

## Intent routing

Classify `$ARGUMENTS`:

1. **Ideation / brainstorm** ("give me ideas on X", "research directions for Y", "what can I study"):
   → Delegate to `research-ideator` with the 4 mandatory doctrine fields (`mainstream_anchor`, `sub_branch`, `theoretical_contribution`, `so_what`). Save to `/Users/xuyongheng/Obsidian-Vault/Writing/` as `YYYY-MM-DD-{topic}.md`.

2. **Concept explain** ("explain X", "what is Y", "how does Z work"):
   → Delegate to `concept-explainer`. Save to `/Users/xuyongheng/Obsidian-Vault/Notes/` as `{ConceptName}.md`.

3. **Theory map** ("map theories of X", "theoretical landscape of Y", "theory inventory"):
   → Delegate to `theory-mapper`. Save to `/Users/xuyongheng/Obsidian-Vault/Notes/` as `{TopicName}-theory-map.md`.

If unclear, ask one short question.

## Modes and flags

- `--effort=quick|standard|deep` (optional; auto-inferred from phrasing)
- `--gate=strict|lenient` (ideation only; default `strict`)
- `--mode=sub-branch` (ideation only; uses theory-mapper blank spots as seeds)
- `--depth=shallow|full` (theory-map only)

## Mandatory audit

- **Ideation** → `novelty-checker` acts as the **So-What Gate** (mandatory, never skippable). Strict gate requires `so_what_score ≥ 6` AND all 3 sub-gates PASS. REJECTs are appended to `.opencode/memory/failed-ideas.md`.
- **Concept card** → `concept-auditor` (GPT-5.4) verifies definition accuracy.
- **Theory map** → `citation-verifier` on every theory paper cited.

`--audit=off` is **not allowed** on `/think` — thinking without audit produces noise.

This constitutes the **mandatory mini-audit** for this command.

## Pre-flight: load doctrine

Before delegating to any of the 3 subagents, read `.opencode/memory/phd-doctrine.md` and `.opencode/memory/failed-ideas.md`. Pass both to the subagent so prior dead-ends are not re-proposed.

## Output Language

Default to deep Chinese for user-facing output and saved notes. Keep paper titles and theory names in their original language. Search queries, filters, flags, and API parameters remain in English academic register.

## Trace

```json
{"ts":"<iso>","command":"/think","audit":"auto-fired","route":"ideation|concept|theory-map","effort":"...","gate":"strict|lenient","proceed_count":<n>,"reject_count":<n>}
```

If no topic given, ask for one.
