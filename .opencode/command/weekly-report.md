---
description: Generate a weekly research activity report (with trace stats)
agent: build
---

Generate my weekly research report.

Review the past 7 days of activity:

1. **Papers Read**: Check `/Users/xuyongheng/Obsidian-Vault/Paper Notes/` for notes created this week. Summarize each briefly.

2. **Searches Conducted**: Check `/Users/xuyongheng/Obsidian-Vault/Search Results/` for search results from this week.

3. **Ideas Generated**: Check `/Users/xuyongheng/Obsidian-Vault/Ideation Sessions/` for ideation sessions this week. **Report So-What Gate stats**: how many directions PROCEED vs REVISE vs REJECTED.

4. **Concepts Learned**: Check `/Users/xuyongheng/Obsidian-Vault/Concept Cards/` for new concept cards.

5. **Writing Progress**: Check `/Users/xuyongheng/Obsidian-Vault/Writing Drafts/` for writing draft updates.

6. **Audit & Quality Stats** (from `.opencode/traces/`): Aggregate the JSONL trace files from the past 7 days and report:
   - Total commands run, by command
   - Audit verdicts: coverage SUFFICIENT/PARTIAL/INSUFFICIENT counts
   - Citation hallucination rate (n_hallucinated / n_total across all summaries this week)
   - Summary audit pass rate (ACCURATE / total)
   - So-What Gate pass rate (PROCEED / total proposed)

7. **New entries in `.opencode/memory/`** this week (decisions / patterns / failed-ideas) — list briefly.

8. **Summary**: Provide a brief narrative of the week's research progress, key insights, quality trends (improving or degrading?), and suggested focus areas for next week.

Save the report to `/Users/xuyongheng/Obsidian-Vault/Daily Notes/weekly-YYYY-MM-DD.md` with frontmatter (`type: "weekly-report"`).

Communicate in English.
