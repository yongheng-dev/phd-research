## Canonical Audit Fallback Snippet

If the primary audit model is unavailable after retry, fall back to the declared `fallback_model`. Under fallback:

1. set `degraded_audit: true` in structured output
2. add a one-line human notice that fallback was used
3. emit a degraded trace record with `event`, `agent`, `reason`, `fallback`

Never silently fall back.
