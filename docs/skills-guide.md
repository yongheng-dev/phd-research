# Skills Guide

## Built-in Skills

Scholar Flow ships with 5 research skills, all generated during `/init`:

### literature-search

**Triggers**: search papers, find studies, latest research, what's published on...

Multi-source academic paper discovery with:
- Query matrix construction (multiple search angles per topic)
- Citation chaining (forward and backward tracking)
- Coverage analysis (theory, method, geography, time balance)
- Quality filtering using your field's journal tiers
- Auto-save to your search results folder

### paper-summarizer

**Triggers**: summarize paper, read this paper, paper notes, what does this paper say...

Deep structured reading notes including:
- One-sentence summary for quick recall
- Method breakdown (design, participants, analysis)
- Key findings with data
- Connection to your research (borrow, extend, watch out)
- Quality and relevance ratings
- Auto-save to your paper notes folder

### research-ideation

**Triggers**: brainstorm, research ideas, what can I study, find a gap...

Creative research direction generation using an N-dimensional collision matrix:
- Dimensions loaded from your domain pack (theories, methods, topics, issues)
- Generates 3-5 directions with research questions, feasibility, and seed literature
- Cross-collision for second-order innovation
- Auto-save to your ideation folder

### lit-review-builder

**Triggers**: literature review, systematic review, survey the field...

Guided systematic review construction:
- Scope definition with inclusion/exclusion criteria
- PRISMA-compliant search documentation
- Thematic synthesis across papers
- Structured output with introduction, methods, results, discussion

### concept-explainer

**Triggers**: what is, explain, define, concept card...

Academic concept cards with:
- Clear definition from seminal sources
- Key components breakdown
- Origin and development history
- Field-specific applications
- Related concept links

## Creating Custom Skills

1. Create a directory: `references/{your-skill-name}/`
2. Write a `SKILL.md` file with this structure:

```markdown
---
name: your-skill-name
description: >
  When this skill triggers. List keywords and scenarios.
---

# Skill Title

Role description for Claude.

## Workflow

### Step 1: ...
### Step 2: ...

## Output Language
Communicate in the user's preferred language.
```

3. Do NOT include `generated: true` in frontmatter — this protects your skill from being overwritten when `/init` is re-run.

## Modifying Built-in Skills

The generated skills in `references/` can be edited directly. However, re-running `/init` will overwrite them (they have `generated: true` in frontmatter).

To make permanent changes:
1. Edit the template in `templates/skills/{name}/SKILL.md.tmpl`
2. Re-run `/init` to regenerate

Or remove `generated: true` from the skill's frontmatter to prevent overwrites.
