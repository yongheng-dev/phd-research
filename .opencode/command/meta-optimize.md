---
description: Meta-optimizer — analyze recent traces and propose workflow improvements (read-only, writes proposals only)
agent: build
---

Run meta-optimization on: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--effort=quick|standard|deep` (quick: last 7 days; standard: last 30 days; deep: last 90 days + eval results)
   - `--window=Nd` — explicit window override (e.g., `--window=14d`)
   - `--scope=agents|commands|all` (default: `all`)
   - `--no-audit` → skip post-audit (NOT recommended)
   Default: `--effort=standard`

2. **Delegate to `meta-optimizer` subagent** via the `task` tool. The subagent:
   - Reads `.opencode/traces/**` in the window
   - Reads `.opencode/memory/decisions.md`, `failed-ideas.md`, `patterns.md`
   - Identifies recurring audit failures, retry loops, flag misuse, doctrine violations
   - **Writes proposals to `.opencode/proposals/YYYY-MM-DD-<slug>.md` ONLY** — it MUST NOT edit any agent or command file directly.

3. **Mandatory mini-audit** (unless `--no-audit`):
   - **`coverage-critic`** (GPT-5.4) — reviews the proposals for blind spots (e.g., did the optimizer only look at failures and miss silent successes? did it miss doctrine compliance?).
   - Verdict appended to each proposal file.

4. **Trace logging**: one JSONL line to `.opencode/traces/$(date +%Y-%m-%d)/meta-optimize.jsonl` with window, traces_analyzed, proposals_written, audit verdict.

**Hard rule**: This command is read-only with respect to agents, commands, and memory. User must apply proposals manually. If the subagent attempts direct edits, abort and WARN.
