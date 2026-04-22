---
description: Curate and normalize Zotero library (dedupe, retag, fill missing metadata)
agent: build
---

Curate Zotero library: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--effort=quick|standard|deep` (quick: flag issues only; standard: dedupe + retag; deep: also enrich metadata from Semantic Scholar/CrossRef)
   - `--scope=collection:<name>|tag:<name>|all` (default: `all`)
   - `--dry-run` → report actions without applying
   - `--no-audit` → skip post-audit
   Default: `--effort=standard`, `--dry-run=false`

2. **Delegate to `zotero-curator` subagent** via the `task` tool. The subagent:
   - Finds duplicates (title+year fuzzy match)
   - Normalizes tags against the controlled vocabulary in `references/zotero-curator/tag-vocab.md` (create on first run)
   - Fills missing DOI/abstract/venue via Semantic Scholar lookup

3. **Mandatory post-audit** (unless `--no-audit`):
   - **`citation-verifier`** (GPT-5.4) — any metadata filled from an external lookup must match the item's existing identifier (no cross-paper contamination).
   - Verdict appended to a summary note at `/Users/xuyongheng/Obsidian-Vault/Curation Logs/YYYY-MM-DD-curation.md`.

4. **Trace logging**: one JSONL line to `.opencode/traces/$(date +%Y-%m-%d)/curate.jsonl` with items_touched, dupes_merged, tags_normalized, metadata_filled, audit verdict.

Destructive operations (merges, deletions) MUST be confirmed with the user unless `--dry-run=false` AND `--effort=quick` is explicitly set by the user.
