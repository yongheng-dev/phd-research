---
description: Build a systematic literature review on a topic
agent: build
---

Build a systematic literature review on the topic: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--mode=quick-survey|systematic` (quick-survey: 2-year scan, ~15 papers, 1-page synthesis — for PhD doctrine S2 step; systematic: full PRISMA-lite, 50+ papers, structured synthesis)
   - `--years=N` (default: 5 for systematic, 2 for quick-survey)
   - `--effort=quick|standard|deep`
   - `--no-audit` → skip post-audit (NOT recommended)
   Default: `--mode=systematic --years=5 --effort=standard`

2. **Delegate to `lit-review-builder` subagent** via the `task` tool. The subagent runs search → screen → synthesize and saves to `/Users/xuyongheng/Obsidian-Vault/Literature Reviews/{TopicName}.md`.

3. **Mandatory post-audit** (unless `--no-audit`):
   - **`coverage-critic`** (GPT-5.4) — audits the final paper set for systematic blind spots. If `INSUFFICIENT`, run one supplementary search round.
   - **`citation-verifier`** (GPT-5.4) — verifies every cited paper in the review actually exists. Hallucinated citations are removed.
   - Append both audit summaries to the review under `## Audit Trail`.

4. **Trace logging**: Append a one-line JSON to `.opencode/traces/$(date +%Y-%m-%d)/lit-review.jsonl` with topic, mode, n_papers, coverage_verdict, n_hallucinated.

If no topic is provided, ask what the user wants to review.

Research field context: AI in Education (PhD level).
