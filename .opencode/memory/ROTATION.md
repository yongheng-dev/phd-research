# Memory Rotation Policy (Option C — Hybrid)

This file is the **authoritative policy** for when and how memory files in `.opencode/memory/` get rotated.

## Tier 1 — Permanent (NEVER rotated)

These files accumulate forever. They are the project's institutional memory.

| File | Why permanent |
|------|---------------|
| `phd-doctrine.md` | Hard methodological constraints. Editing is intentional, never time-based. |
| `decisions.md` | Locked decisions from `/deep-dive` and `/plan` runs. Future sessions must respect them. |
| `research-log.md` | Lab-notebook style log of research milestones (paper accepted, idea promoted to S2, etc.). Provenance value increases with age. |

**Rotation action:** none. Manual edits only, with `<!-- manual: YYYY-MM-DD reason -->` marker.

## Tier 2 — Rotated (Option C)

These files capture transient signals. Old entries lose value but **must be preserved** for audit.

| File | Rotation trigger | Destination |
|------|------------------|-------------|
| `failed-ideas.md` | Entries older than **90 days** | `.opencode/memory/archive/YYYY-MM/failed-ideas.md` |
| `patterns.md` | Entries older than **90 days** | `.opencode/memory/archive/YYYY-MM/patterns.md` |

**Rotation action:**

1. Entries are dated via inline `## YYYY-MM-DD` headings (one per appended block).
2. Once a month (triggered by `phd.ts` `session.created` reminder), the user runs `/admin meta-optimize --rotate`.
3. `meta-optimizer` agent moves headings older than 90 days from active file → archive file (append, never overwrite).
4. Archive files are git-tracked. They are **never deleted**.

## Triggering

`phd.ts` checks at `session.created` whether the **last `## YYYY-MM-DD` heading in `failed-ideas.md` or `patterns.md`** is older than 90 days. If yes, it logs a one-line notice in the session trace:

```
{"event":"rotation.due","files":["failed-ideas.md","patterns.md"],"oldest":"2025-01-12"}
```

The user sees this via `/admin health` and decides when to run `/admin meta-optimize --rotate`. Rotation is **never automatic**.

## Manual override

To skip rotation for a specific entry (e.g. an evergreen anti-pattern), tag it:

```markdown
## 2025-01-12 <!-- evergreen -->
This failure mode is structural; never archive.
```

`meta-optimizer` skips entries with `<!-- evergreen -->`.

## Verifier note

`check-memory.sh` (C5) treats moves between `memory/` and `memory/archive/` as legitimate (not "deletions") because both paths are tracked. The `--follow` flag in C5's `git log` already handles renames; adding new path prefixes does not break the contract.

---

Decision lock: 2026-04-23 (Option C, see decisions.md `2026-04-23-memory-rotation`).
