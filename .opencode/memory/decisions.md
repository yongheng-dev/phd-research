# Decisions Log

> Auto-appended by `/deep-dive` and `/phd-route` on completion.
> Loaded by `session-start` hook.

<!-- New entries are appended below this line. Format:

## YYYY-MM-DD — {short title}
- **Context**: {what was being decided}
- **Decision**: {what was chosen}
- **Rationale**: {why}
- **Alternatives rejected**: {what and why}
- **Source**: {workflow id / session id}

-->

## 2026-04-23 — Memory rotation policy (Option C hybrid)
- **Context**: Memory files growing unbounded; need rotation without losing audit trail.
- **Decision**: Tier 1 (`phd-doctrine.md`, `decisions.md`, `research-log.md`) never rotate. Tier 2 (`failed-ideas.md`, `patterns.md`) rotate at 90 days into `.opencode/memory/archive/YYYY-MM/`, never deleted.
- **Rationale**: Permanent provenance for institutional knowledge; bounded active context for transient signals; archives preserve everything for audit.
- **Alternatives rejected**: A) Rotate everything (loses doctrine continuity). B) Rotate nothing (active files balloon, hurt context budget).
- **Source**: refactor session 2026-04-23 R3.
