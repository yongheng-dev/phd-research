# `.opencode/memory/` — Project Memory Layer

This directory holds **persistent project memory** that survives across sessions and is auto-loaded by hooks.

## Files

| File | Tier | Purpose | Written by | Read by |
|------|------|---------|------------|---------|
| `phd-doctrine.md` | 1 (permanent) | Hard methodological constraints for PhD-level research | Static (manual edits only) | All research-class agents at startup |
| `decisions.md` | 1 (permanent) | Locked decisions and rationale from `/deep-dive` and `/plan` runs | Auto-append on workflow completion | `session-start` hook |
| `research-log.md` | 1 (permanent) | Lab-notebook style milestones and observations | `/think`, `/read`, manual | `session-start` hook |
| `failed-ideas.md` | 2 (rotated 90d) | Saturated/rejected research directions (anti-repeat memory) | `novelty-checker` on reject | `research-ideator` at startup |
| `patterns.md` | 2 (rotated 90d) | Cross-paper consensus and disagreements | `paper-summarizer` after batch runs | `lit-review-builder` at startup |

See `ROTATION.md` for the full rotation policy (Option C hybrid).

## Archive

Old Tier-2 entries move to `.opencode/memory/archive/YYYY-MM/{file}.md` via `/admin meta-optimize --rotate`. Archives are git-tracked and **never deleted**. C5 verifier treats moves to `archive/` as legitimate.

## Editing Rules

- `phd-doctrine.md` is the only file safe to hand-edit freely.
- All other files: prefer letting agents append; manual edits allowed but should add a `<!-- manual: YYYY-MM-DD reason -->` marker.
- Tag evergreen entries in Tier-2 files with `<!-- evergreen -->` to skip rotation.

## Triggering rotation

`phd.ts` plugin emits a `rotation.due` trace event at `session.created` if the oldest unarchived entry in a Tier-2 file is older than 90 days. The user runs `/admin meta-optimize --rotate` when ready. **Rotation is never automatic.**
