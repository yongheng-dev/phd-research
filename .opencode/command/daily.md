---
description: Daily research routine — paper recommendations, review reminders, inspiration
agent: build
---

Run my daily research routine: $ARGUMENTS

**Parse flags**:
- `--effort=quick|standard|deep` (quick: 3 papers + skip inspiration spark; standard: full routine; deep: full routine + deeper coverage-critic audit)
- `--no-audit` → skip mini-audit (NOT recommended)
Default: `--effort=standard`.

1. **Paper Recommendations**: Search for 3-5 recent papers (last 7 days) related to my research topics: AI literacy, self-regulated learning, learning analytics, intelligent tutoring systems. Use Semantic Scholar (sort by recency) and arXiv. Focus on AI in Education.

2. **Review Reminders**: Check `/Users/xuyongheng/Obsidian-Vault/Paper Notes/` for notes created in the last 7 days. List them and suggest any that deserve a second read or deeper analysis.

3. **Inspiration Spark**: Based on the new papers found and my recent notes, suggest one brief research thought or connection worth exploring. The thought must include a `mainstream_anchor` (a real recent paper) and a `so_what` line — even at brainstorm stage, no theory-free suggestions.

4. **Mandatory mini-audit**:
   - Spawn `citation-verifier` (GPT-5.4) on the recommended papers list — flag any hallucinated picks.
   - The inspiration spark, if it cites any paper, must pass citation verification before being included.

5. **Save** the daily picks to `/Users/xuyongheng/Obsidian-Vault/Daily Picks/YYYY-MM-DD.md` with appropriate YAML frontmatter (`type: "daily-picks"`).

6. **Trace logging**: Append a one-line JSON to `.opencode/traces/$(date +%Y-%m-%d)/daily.jsonl`.

Communicate in English.
