---
description: Explain an academic concept and create a concept card
agent: build
---

Explain the concept: $ARGUMENTS

## Workflow

1. **Parse flags** in `$ARGUMENTS`:
   - `--effort=quick|standard|deep` (quick: 1-paragraph definition; standard: full concept card; deep: card + worked examples + critique)
   - `--no-audit` → skip post-audit
   Default: `--effort=standard`

2. **Delegate to `concept-explainer` subagent** via the `task` tool. The subagent creates a thorough concept card and saves to `/Users/xuyongheng/Obsidian-Vault/Concept Cards/{ConceptName}.md`.

3. **Mandatory post-audit** (unless `--no-audit`):
   - **`citation-verifier`** (GPT-5.4) — verifies any seminal references cited in the concept card actually exist.
   - Append the audit summary to the card under `## Audit Trail`.

4. **Trace logging**: Append a one-line JSON to `.opencode/traces/$(date +%Y-%m-%d)/concept.jsonl`.

If no concept is provided, ask what the user wants explained.

Research field context: AI in Education.
