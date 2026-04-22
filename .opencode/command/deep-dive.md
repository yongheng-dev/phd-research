---
description: Full verified multi-stage research pipeline (orchestrator with all 4 audits)
agent: build
---

Run a deep, verified research pipeline on the topic: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--effort=standard|deep` (default: deep — this command is the highest-assurance entry point)
   - `--gate=strict|lenient` (default: strict; passed through to the ideation stage)
   Note: `--no-audit` is **not supported** here — the entire point of `/deep-dive` is full audit coverage. Use `/search-papers --no-audit` if you want unaudited speed.

2. **Delegate to `deep-dive` subagent** via the `task` tool. It orchestrates:
   - **S1** — intent planning (via `research-planner`)
   - **S2** — literature search (via `literature-searcher`) → audited by `coverage-critic`
   - **S3** — paper analysis (via `paper-summarizer` for top picks) → each audited by `summary-auditor` + `citation-verifier`
   - **S4** — ideation (via `research-ideator`) → gated by `novelty-checker` (So-What Gate, strict by default)
   - **S5** — cross-synthesis (theoretical contribution map) → final `citation-verifier` sweep
   - **S6** — wisdom extraction → append decisions/patterns/failures to `.opencode/memory/`

3. **Mandatory full-pipeline assurance**: All four audit agents (coverage-critic, citation-verifier, summary-auditor, novelty-checker) MUST be invoked at the appropriate stages. The orchestrator may not skip any audit.

4. **Trace logging**: One JSON line per stage to `.opencode/traces/$(date +%Y-%m-%d)/deep-dive.jsonl` with stage name, agent, verdict, retry count. A final summary line aggregates total cost, total audits, total retries.

5. **Output**: A consolidated brief saved to `/Users/xuyongheng/Obsidian-Vault/Deep Dives/YYYY-MM-DD-{topic}.md` with full audit trail, citation list, and PROCEED-grade research directions.

If no topic is provided, ask the user for one before delegating.

Research field context: AI in Education (PhD level).
