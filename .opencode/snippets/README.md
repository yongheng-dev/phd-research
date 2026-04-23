# Prompt Snippets

Canonical prompt snippets for repeated policy blocks.

Purpose:

- reduce drift across agent prompts
- keep wording aligned with the contract system
- preserve self-contained runtime prompts while giving maintainers one source of truth

Usage rule:

- agents should remain self-contained at runtime
- do not replace critical prompt content with external-only references
- instead, keep a short in-file version aligned to these canonical snippets
- when updating a repeated policy, update the snippet first, then sync affected agents
