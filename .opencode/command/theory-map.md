---
description: Build a theory map (theory frequency, co-occurrence, blank spots) for a topic
agent: build
---

Build theory map for: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--effort=quick|standard|deep` (quick: top-10 theories table; standard: table + co-occurrence; deep: table + co-occurrence + blank-spot analysis)
   - `--sources=<obsidian-folder-or-tag>` — corpus to analyze (default: `Paper Notes` + `Search Results`)
   - `--years=N` — restrict corpus to last N years (default: 5)
   - `--no-audit` → skip post-audit
   Default: `--effort=standard`

2. **Delegate to `theory-mapper` subagent** via the `task` tool. Output: a Theory Map saved to `/Users/xuyongheng/Obsidian-Vault/Theory Maps/{Topic}.md` with:
   - Theory frequency table (theory → count → representative papers)
   - Co-occurrence graph (which theories are cited together)
   - Blank spots (theories used elsewhere but absent here) — **these feed `/phd-route` S4**
   - Draft doctrine fields for the topic

3. **Mandatory post-audit** (unless `--no-audit`):
   - **`concept-auditor`** (GPT-5.4) — verifies every theory named in the map corresponds to an established, named theoretical framework (not a term invented or conflated by the agent).
   - **`summary-auditor`** (GPT-5.4) — verifies every theory→paper attribution matches the cited paper.
   - Verdicts appended under `## Audit Trail`.

4. **Trace logging**: one JSONL line to `.opencode/traces/$(date +%Y-%m-%d)/theory-map.jsonl` with topic, theories_counted, blank_spots, audit verdicts.

Doctrine: the map must explicitly label which theories are candidate `mainstream_anchor`s for the topic and which blank spots are candidate `sub_branch` openings.
