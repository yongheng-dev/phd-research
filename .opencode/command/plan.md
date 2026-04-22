---
description: "PhD methodology path — 5-step doctoral research route (S1→S5), with optional full-pipeline mode"
agent: build
audit: on
---

Route a topic through the PhD-grade research path: $ARGUMENTS

## Context

This command operationalizes `.opencode/memory/phd-doctrine.md`. It is the **canonical entry point** for doctoral-grade topic selection and validation. Replaces the legacy `/phd-route` and absorbs `/deep-dive` via `--mode=deep-dive`.

## Modes

- `--mode=sub-branch` (default) — the 5-step doctrine path for identifying a small sub-branch inside a mainstream line.
- `--mode=deep-dive` — full verified pipeline with all 4 audit agents at every stage. Use when topic is locked and maximum assurance is required.

## Flags

Parse from `$ARGUMENTS`:
- `--effort=quick|standard|deep` (quick: S1+S5 only; standard: all 5 steps; deep: all 5 + extra coverage-critic pass) — default `standard`
- `--years=N` — S1 deep-search window (default: 5)
- `--review-years=N` — S2 quick-survey window (default: 2)
- `--gate=strict|lenient` — passed to S5 (default: strict)
- `--skip=S1,S2,...` — comma list to skip (use with care)

## Mandatory full-pipeline audit

Every step runs through a **mandatory full-pipeline audit chain**: S1 → coverage-critic, S2 → citation-verifier, S3 → concept-auditor, S4 → novelty-checker, S5 → So-What Gate (strict). `--audit=off` is **not supported** — auditing is inseparable from the doctrine path.

In `--mode=deep-dive`, add summary-auditor to every paper-summarizer invocation in S3 and a final citation-verifier sweep across the whole pipeline output.

## Workflow — 5 steps (all MUST run unless `--skip`)

### S1 — Deep Search (last `--years` years)
Delegate to `literature-searcher` with `--recency=<years>`. Output: hotspot list of **mainstream_anchor** candidates (min 3).
Audit: `coverage-critic` (mandatory).

### S2 — Quick Survey (last `--review-years` years, review papers only)
Delegate to `lit-review-builder` with `--mode=quick-survey` restricted to review articles. Output: SOTA panorama per mainstream anchor.
Audit: `citation-verifier` on the reviews cited.

### S3 — Theory Inventory
Delegate to `theory-mapper` on papers from S1+S2. Output: theory frequency table, co-occurrence graph, blank-spot candidates, draft 4 doctrine fields.
Audit in deep-dive mode: `summary-auditor` on each theory card extracted.

### S4 — Sub-Branch Positioning
Delegate to `research-ideator` in `--mode=sub-branch` with S3 blank spots as seeds. Require 3–5 `sub_branch` propositions, each with a draft `theoretical_contribution`.
Audit: `novelty-checker` against prior art.

### S5 — So-What Argument
Delegate to `novelty-checker` (So-What Gate) with `--gate=<flag>` on every S4 proposition. Each must score ≥ 8/10 to emerge PROCEED. REJECTs auto-appended to `.opencode/memory/failed-ideas.md`.

## Final output

Save to `/Users/xuyongheng/Obsidian-Vault/Writing/` (post-R4) or `Deep Dives/` (pre-R4) as `YYYY-MM-DD-plan-<topic-slug>.md`:

```yaml
---
title: "Plan: <topic>"
date: YYYY-MM-DD
type: deep-dive
tags: [plan, doctrine, <topic>]
source: "plan command"
---

## S1 Mainstream anchors (top 3)
## S2 SOTA panorama
## S3 Theory map summary + [[link to Notes/<topic>-theory-map.md]]
## S4 Sub-branch candidates (3-5)
## S5 So-What verdicts per candidate
## PROCEED list (score ≥ 8)
## REJECTED list + reasons (also in failed-ideas.md)

---
Related notes: [[...]]

Saved: <ts>
```

## Checkpoint hook

In `--mode=deep-dive`, after each stage write `.opencode/checkpoints/$(date +%Y-%m-%d)/plan-<slug>-<stage>.json` with resume state (topic, stage, partial results, last audit verdict). Allows `/plan --resume=<slug>` to continue from last checkpoint.

## Trace

One JSONL line per step to `.opencode/traces/$(date +%Y-%m-%d)/plan.jsonl`:

```json
{"ts":"<iso>","command":"/plan","mode":"sub-branch|deep-dive","step":"S1|S2|S3|S4|S5","agent":"<delegated>","verdict":"ok|warn|fail","items":<n>}
```

Plus a final summary line with `proceed_count`, `reject_count`, `top_so_what_score`.

## Hard rules

- All 5 steps run in order; a later step MUST NOT start if its predecessor failed.
- Final brief MUST contain all 4 doctrine fields for every PROCEED item: `mainstream_anchor`, `sub_branch`, `theoretical_contribution`, `so_what`.
- `--gate=lenient` allowed but WARN user that it relaxes the doctoral bar.
- `--mode=deep-dive` cannot be combined with `--audit=off` (disallowed).

If no topic in `$ARGUMENTS`, ask for one.
