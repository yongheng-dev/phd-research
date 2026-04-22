# Meta-Optimizer Proposals

Output sink for `/meta-optimize`. Files here are **proposals only** — not automatically applied.

## Lifecycle

```
meta-optimizer reads traces/memory
        │
        ▼
writes proposal file: YYYY-MM-DD-<slug>.md
        │
        ▼
coverage-critic audit appended
        │
        ▼
/weekly-report surfaces new proposals
        │
        ▼
user reviews → accepts / rejects / defers
        │
        ▼
if accepted → user (or Claude in a separate session) applies the
change manually; meta-optimizer NEVER edits agents/commands/memory
directly.
```

## Proposal file format

```yaml
---
date: YYYY-MM-DD
window_analyzed: "Nd"
traces_sampled: N
status: pending | accepted | rejected | deferred
target_files:
  - .opencode/agent/<name>.md
  - .opencode/command/<name>.md
severity: P0 | P1 | P2
---

## Observation
<what the optimizer saw in traces/memory>

## Hypothesis
<why this happens>

## Proposed change
<concrete diff sketch — natural language OR indented pseudo-diff>

## Expected impact
<which eval queries would shift; which audit failure rate would drop>

## Risks
<what could go wrong; counter-argument>

## Coverage-critic audit
<verdict appended by the audit step>
```

## Hard rules

- `/meta-optimize` MUST NOT edit files outside this directory.
- Proposals are append-only. If superseded, write a new proposal that references the old one; do not delete.
- `status: accepted` can only be set by the user, not by the optimizer.
