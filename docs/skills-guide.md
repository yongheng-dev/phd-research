# Subagent Guide

This project uses OpenCode subagents under `.opencode/agent/`.

## Main Routing

| Command | Main agents |
|---|---|
| `/find` | `literature-searcher`, `concept-explainer` |
| `/read` | `paper-fetcher`, `paper-summarizer`, `data-extractor` |
| `/think` | `research-ideator`, `concept-explainer`, `theory-mapper` |
| `/write` | `writing-drafter`, `lit-review-builder` |
| `/plan` | `research-planner`, `literature-searcher`, `theory-mapper`, `research-ideator`, `deep-dive` |
| `/admin` | `meta-optimizer` for meta-optimize |

## Model Split

| Tier | Model |
|---|---|
| Heavy | `github-copilot/claude-opus-4.7` |
| Medium | `github-copilot/claude-sonnet-4.6` |
| Light | `github-copilot/claude-haiku-4.5` |
| Audit | `github-copilot/gpt-5.4` |

## Audit Agents

- `coverage-critic`
- `citation-verifier`
- `summary-auditor`
- `novelty-checker`
- `concept-auditor`
- `meta-optimizer`
