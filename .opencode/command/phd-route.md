---
description: "PhD methodology router — runs the 5-step doctoral research path (S1→S5) on a topic"
agent: build
---

Route a topic through the PhD-grade 5-step research path: $ARGUMENTS

## Context

This command operationalizes `.opencode/memory/phd-doctrine.md`. It is the **canonical doctrine-driven entry point** (whereas `/deep-dive` is the full-pipeline entry point). Prefer `/phd-route` when the user is early in topic selection; prefer `/deep-dive` when the topic is locked and you want maximum assurance.

## Flags

Parse from `$ARGUMENTS`:
- `--effort=quick|standard|deep` (quick: S1+S5 only for fast gate; standard: all 5 steps; deep: all 5 + extra coverage-critic pass on S1 and S2) — default: `standard`
- `--years=N`   window for S1 deep search (default: 5)
- `--review-years=N`  window for S2 quick survey (default: 2)
- `--gate=strict|lenient`  passed to S5 So-What Gate (default: strict)
- `--skip=S1,S2`  comma list to skip already-done steps (use with care)

## Mandatory post-audit

Every step in this command runs through a **mandatory full-pipeline audit chain**: S1 → coverage-critic, S2 → citation-verifier, S3 → concept-auditor, S4 → novelty-checker, S5 → So-What Gate (strict). `--no-audit` is **not supported** on `/phd-route` — auditing is inseparable from the doctrine path.

## Workflow — 5 steps (ALL five MUST run unless `--skip`)

### S1 — Deep Search (last `--years` years)
Delegate to `literature-searcher` with `--recency=<years>`. Output: a hotspot list of **mainstream_anchor** candidates (min 3).
Audit: `coverage-critic` (mandatory).

### S2 — Quick Survey (last `--review-years` years, review papers only)
Delegate to `lit-review-builder` with `--mode=quick-survey` restricted to review articles. Output: SOTA panorama per mainstream anchor.
Audit: `citation-verifier` on the reviews cited.

### S3 — Theory Inventory
Delegate to `theory-mapper` on the papers collected in S1+S2. Output: theory frequency table, co-occurrence graph, blank-spot candidates, and the draft 4 doctrine fields.

### S4 — Sub-Branch Positioning
Delegate to `research-ideator` in `--mode=sub-branch` passing S3's blank spots as seeds. Require 3-5 candidate sub_branch propositions, each with a draft `theoretical_contribution`.

### S5 — So-What Argument
Delegate to `novelty-checker` (So-What Gate) with `--gate=<flag value>` on every S4 proposition. Each must score ≥ 8/10 to emerge as PROCEED. REJECTs are auto-appended to `.opencode/memory/failed-ideas.md`.

## Final output

Save to `/Users/xuyongheng/Obsidian-Vault/Deep Dives/YYYY-MM-DD-phd-route-<topic-slug>.md` with:

```yaml
---
title: "PhD Route: <topic>"
date: YYYY-MM-DD
type: deep-dive
tags: [phd-route, doctrine, <topic>]
source: "phd-route command"
---

## S1 Mainstream anchors (top 3)
## S2 SOTA panorama
## S3 Theory map summary + [[link to Theory Maps/<topic>.md]]
## S4 Sub-branch candidates (3-5)
## S5 So-What verdicts per candidate
## PROCEED list (score ≥ 8)
## REJECTED list + reasons (also in failed-ideas.md)

---
Related notes: [[...]]

Saved: <ts>
```

## Trace

One JSONL line per step to `.opencode/traces/$(date +%Y-%m-%d)/phd-route.jsonl`:

```json
{"ts":"<iso>","command":"/phd-route","step":"S1|S2|S3|S4|S5","agent":"<delegated>","verdict":"ok|warn|fail","items":<n>}
```

Plus a final summary line with `proceed_count`, `reject_count`, `top_so_what_score`.

## Hard rules

- All 5 steps MUST run in order. A later step MUST NOT start if its predecessor failed.
- The final brief MUST contain all 4 doctrine fields for every PROCEED item: `mainstream_anchor`, `sub_branch`, `theoretical_contribution`, `so_what`.
- `--gate=lenient` is allowed but WARN the user in the output that it relaxes the doctoral bar.

If no topic given in `$ARGUMENTS`, ask for one before starting.
