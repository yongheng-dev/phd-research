---
description: Generate research ideas via collision matrix (with mandatory So-What gating)
agent: build
---

Generate research ideas on the topic: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--effort=quick|standard|deep` (quick: 3 directions; standard: 5-7; deep: 10+ with cross-domain collisions)
   - `--gate=strict|lenient` (default: strict — `so_what_score >= 6` AND all 3 gates pass to PROCEED)
   - `--no-audit` → SKIPS the So-What Gate (NOT recommended; reserved for free-association brainstorming only — explicitly mark output as "ungated")
   Default: `--effort=standard --gate=strict`

2. **Pre-flight: load PhD doctrine.** Before delegating, read `.opencode/memory/phd-doctrine.md` and `.opencode/memory/failed-ideas.md`. Pass both to the subagent so it does not re-propose known dead-ends.

3. **Delegate to `research-ideator` subagent** via the `task` tool. The subagent must produce, for each direction, the 4 mandatory fields:
   - `mainstream_anchor` (well-cited recent reference defining the active research line)
   - `sub_branch` (the concrete small twist)
   - `theoretical_contribution` (named theory/framework being updated/extended/refuted)
   - `so_what` (one-paragraph answer to "why does this matter beyond a benchmark gain?")

4. **Mandatory So-What Gate** (unless `--no-audit`):
   - Spawn `novelty-checker` (GPT-5.4) which runs the 3-gate evaluation on every direction.
   - Directions with verdict `REJECTED` are removed from the final output and auto-appended to `.opencode/memory/failed-ideas.md`.
   - Directions with verdict `REVISE` are returned to the user with the specific gate failure and a suggested patch.
   - Only `PROCEED` directions enter the saved ideation note at `/Users/xuyongheng/Obsidian-Vault/Ideation Sessions/YYYY-MM-DD-{topic}.md`.

5. **Citation verification**: Spawn `citation-verifier` on all `mainstream_anchor` references. Hallucinated anchors → direction auto-rejected.

6. **Trace logging**: Append a one-line JSON to `.opencode/traces/$(date +%Y-%m-%d)/brainstorm.jsonl` with topic, n_proposed, n_proceed, n_revise, n_rejected, avg_so_what_score.

If no topic is provided, ask what area the user wants to explore.

Research field context: AI in Education (PhD level).
Focus areas: AI literacy, self-regulated learning, learning analytics, intelligent tutoring systems.
