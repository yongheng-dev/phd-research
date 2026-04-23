---
description: Review — daily, weekly, or monthly retrospective (aggregates traces + vault activity)
agent: build
audit: auto
---

Review recent research activity: $ARGUMENTS

## Cadence

Parse `--cadence=day|week|month` from `$ARGUMENTS` (default: `day`).

- `day` → lightweight daily routine (paper picks, reminders, inspiration). Audit: auto (mini-audit on picks).
- `week` → weekly report across vault + traces + memory. Audit: on (mandatory mini-audit on aggregated stats).
- `month` → curation pass across paper notes + dead-idea archive review. Audit: on.

## Workflow by cadence

### `--cadence=day`

1. **Paper picks** — search last 7 days for AI literacy / SRL / learning analytics / ITS via Semantic Scholar + arXiv. 3–5 papers.
2. **Review reminders** — list paper notes from last 7 days; suggest any for re-read.
3. **Inspiration spark** — 1 brief thought with a `mainstream_anchor` and `so_what` (no theory-free suggestions).
4. **Mandatory mini-audit**: `citation-verifier` (GPT-5.4) on the picks list — flag hallucinations.
5. Save to `/Users/xuyongheng/Obsidian-Vault/Inbox/` as `YYYY-MM-DD.md` with `type: "daily-picks"`.

### `--cadence=week`

1. **Papers read** (`Notes/` paper notes from last 7 days) — brief per-note summary.
2. **Searches conducted** (`Inbox/` search-result notes from last 7 days) — list.
3. **Ideas generated** — So-What Gate stats (PROCEED / REVISE / REJECTED counts).
4. **Concepts learned** — new concept cards.
5. **Writing progress** — draft updates.
6. **Audit & quality stats** from `.opencode/traces/` last 7 days:
   - Total commands by name
   - Audit verdicts (SUFFICIENT / PARTIAL / INSUFFICIENT)
   - Hallucination rate, summary pass rate, So-What pass rate
7. **Memory deltas** — new entries this week in `decisions.md` / `patterns.md` / `failed-ideas.md`.
8. **Meta-optimization proposals** — list new files in `.opencode/proposals/` this week (NOT applied automatically).
9. **Narrative summary** — quality trend, focus suggestion.
10. Save to `/Users/xuyongheng/Obsidian-Vault/Writing/` as `weekly-YYYY-MM-DD.md` with `type: "weekly-report"`.

This step constitutes the **mandatory post-audit** for weekly reviews: the quality-stats section IS the audit. If stats cannot be produced (missing traces), the command WARNS rather than failing silently.

### `--cadence=month`

1. **Zotero curation** — delegate to `zotero-curator` for library curation pass: deduplication, tag standardization, metadata enrichment (DOI/abstract completion), and sync of selected items into the current Obsidian vault layout.
2. Produce a summary of additions, deletions, retagging.
3. **Vault hygiene** — check for Inbox notes older than 30 days with no corresponding Notes entry; list them for promotion or archival.
4. **Sequential-thinking synthesis** — call `sequential-thinking_sequentialthinking` (totalThoughts: 5) to reflect on the month's research trajectory: what themes emerged, what gaps persist, what should be prioritized next month.
5. Review `.opencode/memory/failed-ideas.md` — archive entries > 90 days per R3/Option C rotation policy.
6. Save curation log to `/Users/xuyongheng/Obsidian-Vault/Writing/` as `curation-YYYY-MM-DD.md` with `type: "curation-log"`.

This step constitutes the **mandatory mini-audit** for monthly reviews: the curation diff + archival count IS the audit trail.

## Output Language

Default to deep Chinese for user-facing output and saved review notes. Keep paper titles in their original language. Search queries, filters, flags, and API parameters remain in English academic register.

## Trace

```json
{"ts":"<iso>","command":"/review","cadence":"day|week|month","audit":"auto-fired|on","items_reviewed":<n>}
```

If no cadence and `$ARGUMENTS` is empty, default to `day`.
