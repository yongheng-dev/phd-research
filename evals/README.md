# Eval Harness

Purpose: nightly/weekly regression harness that probes the OpenCode research system and produces an **Assurance Dashboard** consumed by `/review --cadence=week`.

## Structure

```
evals/
├── queries/            # YAML eval definitions (one scenario per file)
│   ├── _template.yaml  # schema documentation
│   ├── search-*.yaml
│   ├── summarize-*.yaml
│   ├── doctrine-*.yaml
│   ├── audit-*.yaml
│   └── integration-*.yaml
├── bin/
│   └── run.sh          # runner script (invoked by /admin eval)
├── results/            # raw JSON results, one per run
└── reports/
    └── YYYY-MM-DD.md   # assurance dashboard output (P5.A–D delivered)
```

## Query Schema

See `queries/_template.yaml`. Each query declares:
- `id` — stable identifier
- `suite` — one of: `search`, `summarize`, `doctrine`, `audit`, `integration`
- `command` — the OpenCode slash command to invoke
- `args` — arguments to pass
- `expected_properties` — list of checks (file exists, frontmatter fields, audit verdicts, doctrine fields, citation count)
- `severity` — P0 | P1 | P2 — determines whether a failure blocks the dashboard green status

## Invocation

Normally via `/admin eval`. Direct invocation: `bash evals/bin/run.sh [--suite=<name>] [--effort=quick|standard|deep]`.

After a run completes, the runner emits a `dashboard.update` plugin event so the assurance dashboard view is refreshed without a manual command.

## Pass/Warn/Fail

- PASS — all `expected_properties` hold
- WARN — soft-fail (e.g., citation count below target but >0)
- FAIL — a P0 or P1 property is violated

A run that includes any audit subagent in fallback mode (`degraded_audit:true`) is annotated in the dashboard so the user knows the verdict came from the smaller model.

## Status

The runner skeleton and the five suite categories shipped in P5.A–D. The runner does not yet drive live OpenCode invocations end-to-end — extending it is a future task. Until then, treat `bash evals/bin/run.sh` as a dry-run harness; the user has explicitly asked not to invoke it during routine work.
