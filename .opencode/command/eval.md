---
description: Run the eval harness — execute saved eval queries and score system assurance
agent: build
---

Run evaluations: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--effort=quick|standard|deep` (quick: smoke subset ~5 queries; standard: full suite; deep: full suite + variance analysis across 3 runs)
   - `--suite=<name>` — run only a named suite (e.g., `search`, `doctrine`, `audit`) (default: all)
   - `--no-audit` → skip post-audit (NOT recommended)
   Default: `--effort=standard`

2. **Load eval queries** from `evals/queries/*.yaml`. Each query file declares: `id`, `suite`, `command`, `args`, `expected_properties` (e.g., must produce doctrine fields, must cite ≥5 papers, must pass audit).

3. **Execute each query** against the current system. Capture:
   - Command output location (path to saved note)
   - Audit verdicts from trace files
   - Whether expected properties hold (pass/warn/fail)

4. **Mandatory post-audit** (unless `--no-audit`):
   - **`coverage-critic`** (GPT-5.4) — checks that the query suite itself covers the system's stated capabilities (no blind spots in what is being tested).
   - Verdict appended to the eval report.

5. **Produce assurance dashboard** at `evals/reports/YYYY-MM-DD.md` with:
   - Pass/warn/fail count per suite
   - Audit failure rate
   - Doctrine compliance rate
   - Trend vs previous report (if exists)
   - Top 3 failing queries with suggested fixes (pipe to `/meta-optimize` for actioning)

6. **Trace logging**: one JSONL line to `.opencode/traces/$(date +%Y-%m-%d)/eval.jsonl` with suite, queries_run, pass, warn, fail, audit verdict.

If `evals/queries/` is empty, print a bootstrap message explaining the format and create one template file at `evals/queries/_template.yaml`.
