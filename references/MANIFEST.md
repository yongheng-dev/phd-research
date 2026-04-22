# `references/` — Legacy Claude Code Skills (READ-ONLY)

## What This Is

These five SKILL.md files are **historical artifacts** from the original Claude Code skill system that preceded the OpenCode subagent architecture. They are kept on disk for three reasons:

1. **Behavioral parity reference** — when refactoring an OpenCode subagent, the corresponding SKILL.md is the source-of-truth for the original prompt structure, edge cases, and formatting conventions.
2. **Provenance trail** — many design decisions in the current `.opencode/agent/` files trace back to these skills. Removing them would erase rationale.
3. **Re-portability** — if another agent platform requires Claude-Code-format skills, these remain ready.

## Status: DEPRECATED

- ❌ Not loaded by OpenCode at runtime
- ❌ Not invoked by any slash command
- ❌ Not maintained for new features
- ✅ Only referenced manually when re-implementing an agent

## Inventory

| Skill | OpenCode equivalent | Notes |
|---|---|---|
| `concept-explainer/SKILL.md` | `.opencode/agent/concept-explainer.md` | Concept-card generation, vault save logic |
| `lit-review-builder/SKILL.md` | `.opencode/agent/lit-review-builder.md` | Multi-paper synthesis pipeline |
| `literature-search/SKILL.md` | `.opencode/agent/literature-searcher.md` | Multi-source academic search + screening |
| `paper-summarizer/SKILL.md` | `.opencode/agent/paper-summarizer.md` | Structured paper reading notes |
| `research-ideation/SKILL.md` | `.opencode/agent/research-ideator.md` | Collision-matrix ideation |

## Rules

1. **Do not edit** these files to change runtime behavior — edit the corresponding `.opencode/agent/*.md` instead.
2. **Path references inside SKILL.md** were updated during R4 to use the post-migration vault layout (`Inbox / Notes / Writing`) for consistency, even though these files are not executed.
3. **If you add a new OpenCode agent**, do NOT add a matching SKILL.md here. This directory is closed to new entries.
4. **If you decide to delete this directory**, first verify no `.opencode/agent/*.md` references it (currently none do — confirmed at R4).

## Removal Criteria

This directory MAY be deleted when ALL of:

- All five OpenCode agents have passed 30 days of production evals without behavioral regressions traceable to their SKILL.md ancestor
- `git log --all -- references/` confirms no commits in the last 90 days (i.e. nobody is consulting it)
- `grep -rn references/ .opencode/ AGENTS.md docs/` returns zero hits
