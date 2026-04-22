---
description: Extract structured data (samples, constructs, measures, effect sizes) from a paper
agent: build
---

Extract structured data from: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--effort=quick|standard|deep` (quick: abstract+method only; standard: full method+results; deep: also tables, figures, supplementary)
   - `--schema=<name>` (default: `ai-ed-default`) — which extraction schema to apply
   - `--no-audit` → skip post-audit
   Default: `--effort=standard`, `--schema=ai-ed-default`

2. **Delegate to `data-extractor` subagent** via the `task` tool. Input may be a Zotero key, Obsidian paper note, or file path. Output: structured YAML/JSON block saved into the paper's existing Paper Note under `## Extracted Data`. If no paper note exists, create one.

3. **Mandatory post-audit** (unless `--no-audit`):
   - **`summary-auditor`** (GPT-5.4) — verifies every extracted data point is grounded in the source text (no hallucinated effect sizes, samples, or constructs).
   - If any field marked `UNSUPPORTED`: drop it and note the drop.
   - Append verdict to `## Audit Trail` in the paper note.

4. **Trace logging**: one JSONL line to `.opencode/traces/$(date +%Y-%m-%d)/extract.jsonl` with paper id, fields_extracted, fields_dropped, audit verdict.

Schema references live in `references/data-extractor/schemas/` (create on first use if missing).
