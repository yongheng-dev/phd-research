# Eval Harness

Purpose: nightly/weekly regression harness that probes the OpenCode research system and produces an **Assurance Dashboard** consumed by `/weekly-report`.

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
│   └── run.sh          # runner script (invoked by /eval command)
└── reports/
    └── YYYY-MM-DD.md   # assurance dashboard output
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

Normally via `/eval` command. Direct invocation: `bash evals/bin/run.sh [--suite=<name>] [--effort=quick|standard|deep]`.

## Pass/Warn/Fail

- PASS — all `expected_properties` hold
- WARN — soft-fail (e.g., citation count below target but >0)
- FAIL — a P0 or P1 property is violated

## Not yet implemented

The runner `bin/run.sh` is a stub until the user runs `/eval` for the first time and confirms which queries to activate. A first pass creates skeleton queries only — no live OpenCode invocation inside `run.sh` until the user approves the execution strategy (subprocess? internal SDK? manual?).
