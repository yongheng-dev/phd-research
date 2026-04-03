# API Keys Guide

Scholar Flow uses several external services. Most work without API keys, but keys improve the experience.

## Summary

| Service | Key Required | Free Tier | Purpose |
|---------|-------------|-----------|---------|
| Semantic Scholar | Optional | Yes (no key needed, key improves rate limits) | Academic paper search |
| Brave Search | Required | Yes (2,000 queries/month) | Gray literature, reports, blogs |
| arXiv | Not needed | — | Preprint search |
| Zotero | Not needed | — | Local reference management |

## Semantic Scholar

**Purpose**: Primary academic paper search — metadata, abstracts, citations.

**Without key**: Works, but rate-limited to ~100 requests per 5 minutes.
**With key**: Higher rate limits for heavy search sessions.

**Get a key**:
1. Go to https://www.semanticscholar.org/product/api
2. Click "Request API Key"
3. Fill in the form (academic use is approved quickly)
4. Set the environment variable:
   ```bash
   export SEMANTIC_SCHOLAR_API_KEY=your_key_here
   ```
   Add to your shell profile (`~/.zshrc` or `~/.bashrc`) to persist.

## Brave Search

**Purpose**: Gray literature search — policy reports, blog posts, news, non-academic sources.

**Without key**: Brave Search is disabled entirely.
**With key**: Full gray literature search capability.

**Get a key**:
1. Go to https://brave.com/search/api/
2. Sign up for the free plan (2,000 queries/month)
3. Copy your API key
4. Set the environment variable:
   ```bash
   export BRAVE_SEARCH_API_KEY=your_key_here
   ```

## Storing Keys

Never put API keys directly in config files. Use environment variables:

```bash
# Add to ~/.zshrc or ~/.bashrc
export SEMANTIC_SCHOLAR_API_KEY=your_key
export BRAVE_SEARCH_API_KEY=your_key
```

Then restart your terminal or run `source ~/.zshrc`.

Scholar Flow's `/init` will ask about your keys and configure MCP servers accordingly.
