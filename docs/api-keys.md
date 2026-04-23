# API Keys Guide

Most configured MCP services in this repository work without manual key wiring in repo files.

## Optional Environment Variables

### Semantic Scholar

```bash
export SEMANTIC_SCHOLAR_API_KEY=your_key_here
```

### Brave Search

Not configured in the current baseline project.

If you add it later, set:

```bash
export BRAVE_SEARCH_API_KEY=your_key_here
```

## Rule

Keep secrets in shell environment variables, not committed config files.
