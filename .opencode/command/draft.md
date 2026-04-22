---
description: Draft academic writing (intro, related work, methods, discussion) from vault notes
agent: build
---

Draft writing on: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--section=intro|related-work|methods|results|discussion|abstract` (required)
   - `--effort=quick|standard|deep` (quick: outline only; standard: full draft; deep: full draft + counter-argument pass)
   - `--sources=<obsidian-tag-or-folder>` — which notes to ground the draft in
   - `--words=N` — target word count
   - `--no-audit` → skip post-audit (NOT recommended for related-work sections)
   Default: `--effort=standard`

2. **Delegate to `writing-drafter` subagent** via the `task` tool. The subagent MUST ground every claim in a cited vault note; unsupported claims are forbidden. Saves to `/Users/xuyongheng/Obsidian-Vault/Writing Drafts/{DocumentTitle}.md`.

3. **Mandatory post-audit** (unless `--no-audit`):
   - **`citation-verifier`** (GPT-5.4) — every citation in the draft must trace to a real paper in Zotero or a live DB query.
   - **`summary-auditor`** (GPT-5.4) — every claim attributed to a paper must actually be in that paper.
   - Append both verdicts to the draft under `## Audit Trail`. If either fails, mark sections with `[UNVERIFIED]` and WARN the user.

4. **Trace logging**: one JSONL line to `.opencode/traces/$(date +%Y-%m-%d)/draft.jsonl` with section, word_count, citations_verified, citations_failed.

Writing must follow the doctrine: drafts that propose research directions must state `mainstream_anchor`, `sub_branch`, `theoretical_contribution`, and `so_what` explicitly.
