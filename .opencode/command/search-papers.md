---
description: Multi-source academic literature search on a topic
agent: build
---

Search for academic papers on the topic: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--years=N` → restrict to last N years (default: 5, per PhD doctrine S1 deep-search step)
   - `--effort=quick|standard|deep` → controls search breadth (quick: 1 source ×10 papers; standard: 2 sources ×15; deep: 3+ sources ×25)
   - `--no-audit` → skip post-audit (NOT recommended; only for quick lookups)
   - `--gate` → enforce strict So-What gating downstream
   Default: `--years=5 --effort=standard`

2. **Delegate to `literature-searcher` subagent** via the `task` tool. Pass topic + parsed flags. The subagent runs Semantic Scholar + arXiv (+ paper-search for coverage) and persists results to `/Users/xuyongheng/Obsidian-Vault/Search Results/YYYY-MM-DD-{keywords}.md`.

3. **Mandatory post-audit** (unless `--no-audit`):
   - Spawn `coverage-critic` (GPT-5.4) via `task` with the saved result file path.
   - If verdict is `INSUFFICIENT`, automatically run a supplementary search with the critic's suggested queries and re-audit (max 1 retry).
   - Append the audit summary to the search results file under a `## Coverage Audit` section.

4. **Trace logging**: Append a one-line JSON to `.opencode/traces/$(date +%Y-%m-%d)/search-papers.jsonl` with topic, flags, paper count, audit verdict, retry count.

If no topic is provided, ask what the user wants to search for.

Research field context: AI in Education (PhD level).
Focus areas: AI literacy, self-regulated learning, learning analytics, intelligent tutoring systems.
