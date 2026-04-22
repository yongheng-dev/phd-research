---
description: Fetch a paper PDF and ingest into Zotero (and arxiv_cache/ if arXiv)
agent: build
---

Fetch the paper identified by: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--effort=quick|standard|deep` (quick: single-source try; standard: arXiv→SemanticScholar→Zotero fallback; deep: also try Unpaywall/OpenAlex and prompt user for OA link)
   - `--no-audit` → skip post-audit
   - `--dry-run` → locate only, do not store
   Default: `--effort=standard`

2. **Delegate to `paper-fetcher` subagent** via the `task` tool. Accepts title, DOI, arXiv ID, or URL.

3. **Mandatory post-audit** (unless `--no-audit`):
   - **`citation-verifier`** (GPT-5.4) — confirm the fetched paper metadata matches the requested identifier (no silent substitution).
   - Append verdict to the Zotero item's notes.

4. **Trace logging**: one JSONL line to `.opencode/traces/$(date +%Y-%m-%d)/fetch.jsonl` with identifier, source_used, stored_path, audit verdict.

If the paper cannot be located legally from any source, WARN the user with the exact reason; do not fabricate a PDF.
