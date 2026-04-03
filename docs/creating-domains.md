# Creating Domain Packs

A domain pack provides field-specific knowledge that Scholar Flow uses to customize skills for your research area.

## When You Need One

- `/init` auto-generates a domain pack if your field isn't pre-built
- Auto-generated packs are good but not community-reviewed
- Contributing a polished domain pack helps everyone in your field

## Structure

```
domains/{your-field}/
├── domain.yaml           # Field metadata (required)
├── theories.yaml         # Theoretical frameworks (required)
├── methods.yaml          # Research methods (required)
├── topics.yaml           # Subfields and areas (required)
├── social-issues.yaml    # Societal dimensions (required)
├── journals.md           # Tiered venue list (required)
└── keyword-mapping.md    # Search synonyms (recommended)
```

## File Formats

### domain.yaml

```yaml
name: "Your Field"
description: "One-line description of the field and its focus"
core_topics:
  - "Major Topic 1"
  - "Major Topic 2"
  # 8-12 topics total
```

### theories.yaml, methods.yaml, topics.yaml, social-issues.yaml

```yaml
- name: "Framework Name"
  description: "Brief description — what it is and when researchers use it"

- name: "Another Framework"
  description: "Brief description"
```

Recommended counts:
- theories: 8-12 items
- methods: 6-8 items
- topics: 8-10 items
- social-issues: 5-7 items

### journals.md

```markdown
# {Field} Research — Journals and Conferences

## Tier 1 — Top Journals

| Journal | Abbreviation | Impact Factor (approx.) | Focus |
|---------|-------------|------------------------|-------|
| ... | ... | ~X | ... |

## Tier 2 — Excellent Journals

| Journal | Focus |
|---------|-------|
| ... | ... |

## Top Conferences

| Conference | Full Name | Frequency |
|-----------|-----------|-----------|
| ... | ... | Annual |
```

### keyword-mapping.md

```markdown
# {Field} Research — Keyword Mapping

## Core Terms

| Term | Primary Search Query | Synonyms / Alternatives |
|------|---------------------|------------------------|
| ... | "exact phrase" | synonym1, synonym2 |
```

For multilingual packs, add columns for other languages.

## How to Contribute

1. Copy `domains/_template/` to `domains/{your-field}/`
2. Fill in all files following the formats above
3. Test: run `/init`, select your field, verify skills work
4. Submit a pull request

## Quality Guidelines

- Theories should be widely recognized in the field
- Journal tiers should reflect current impact and reputation
- Keywords should cover major concepts a researcher would search for
- Descriptions should be concise but informative (1-2 sentences)
