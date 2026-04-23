---
description: Read a paper deeply — auto-fetches PDF if missing, then summarizes and extracts
agent: build
audit: auto
---

Read and digest a paper: $ARGUMENTS

## Modes

Parse `--mode=quick|deep|structured` from `$ARGUMENTS` (default: `standard` → paper-summarizer full-text key sections).

- `quick` → abstract + intro/conclusion only, 200-word summary, no structured extraction
- `deep` (alias `standard`) → full-text key sections + figures, narrative summary, Related Work traced
- `structured` → paper-summarizer + data-extractor (method/sample/effect-size/RQ fields emitted as YAML block)

## Auto-fetch

If the input is a DOI, arXiv ID, URL, or title-only string AND no local PDF is accessible:
1. Try Zotero first (search vault for matching key).
2. If absent, delegate to `paper-fetcher` to retrieve the PDF or HTML source.
3. If fetch fails, fall back to abstract-only and downgrade mode to `quick`, logging `downgraded: true` in trace.

If input is already a local path or Zotero key with attachment → skip fetch step.

## Workflow

1. **Resolve source** (auto-fetch if needed).
2. **Delegate to `paper-summarizer`** with the resolved source and mode. Save to `/Users/xuyongheng/Obsidian-Vault/Notes/` as `{FirstAuthor}-{Year}-{ShortTitle}.md`.
3. **If `--mode=structured`**, additionally delegate to `data-extractor` and append the YAML block to the same note under `## Structured Extraction`.
4. **Mandatory post-audit — run in PARALLEL** (per `audit: auto`, always fires for saved notes):
   - **`summary-auditor`** against the actual paper content. `NEEDS_REVISION` → regenerate once.
   - **`citation-verifier`** on any Related Work / Builds-on references.
   - Both agents receive the same paper source and draft note simultaneously; do not wait for one before starting the other.
   - Append both audit summaries under `## Audit Trail` after both complete.

## Audit policy — `audit: auto`

Always fires for `/read` because output is always saved to Obsidian. Explicit `--audit=off` is disallowed here (reading a paper without verifying the summary defeats the purpose).

## Output Language

Default to deep Chinese for user-facing output and saved notes. Keep paper titles in their original language. Search queries, filters, flags, and API parameters remain in English academic register.

## Trace

```json
{"ts":"<iso>","command":"/read","mode":"quick|deep|structured","source":"doi|arxiv|url|path|zotero","fetched":true|false,"downgraded":true|false,"audit":"auto-fired"}
```

If no paper given in `$ARGUMENTS`, ask for a DOI / arXiv ID / URL / Zotero key / local path.
