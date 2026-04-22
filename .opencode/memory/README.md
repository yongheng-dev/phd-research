# `.opencode/memory/` — Project Memory Layer

This directory holds **persistent project memory** that survives across sessions and is auto-loaded by hooks.

## Files

| File | Purpose | Written by | Read by |
|------|---------|------------|---------|
| `phd-doctrine.md` | Hard methodological constraints for PhD-level research | Static (manual edits only) | All research-class agents at startup |
| `decisions.md` | Key decisions and rationale from completed `/deep-dive` and `/phd-route` runs | Auto-append on workflow completion | `session-start` hook |
| `failed-ideas.md` | Saturated/rejected research directions (anti-repeat memory) | `novelty-checker` on reject | `research-ideator` at startup |
| `patterns.md` | Cross-paper consensus and disagreements | `paper-summarizer` after batch runs | `lit-review-builder` at startup |

## Size Limits

Each file should stay under **500 lines**. When exceeded, `meta-optimizer` summarizes and archives older entries to `memory/archive/YYYY-MM/`.

## Editing Rules

- `phd-doctrine.md` is the only file safe to hand-edit.
- Other three files: prefer letting agents append; manual edits are allowed but should add a `<!-- manual: YYYY-MM-DD reason -->` marker.
