---
description: Deep paper summary and structured reading note
agent: build
---

Summarize the following paper: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--effort=quick|standard|deep` (quick: abstract-only summary; standard: full-text key sections; deep: full-text + figures + supplementary)
   - `--no-audit` → skip post-audit (NOT recommended)
   Default: `--effort=standard`

2. **Delegate to `paper-summarizer` subagent** via the `task` tool. The user may provide a paper title, DOI, arXiv ID, URL, Zotero key, or local PDF path. If the input is unclear, ask before delegating. The subagent saves to `/Users/xuyongheng/Obsidian-Vault/Paper Notes/{FirstAuthor}-{Year}-{ShortTitle}.md`.

3. **Mandatory post-audit** (unless `--no-audit`), in this order:
   - **`summary-auditor`** (GPT-5.4) — verifies the summary's claims against the actual paper. If verdict is `NEEDS_REVISION` or `INACCURATE`, regenerate the affected sections (max 1 retry) and re-audit.
   - **`citation-verifier`** (GPT-5.4) — verifies any references cited in the summary's "Related Work" or "Builds on" sections actually exist.
   - Append both audit summaries to the paper note under `## Audit Trail`.

4. **Trace logging**: Append a one-line JSON to `.opencode/traces/$(date +%Y-%m-%d)/summarize.jsonl` with paper id, audit verdicts, retry count.

Research field context: AI in Education (PhD level).
