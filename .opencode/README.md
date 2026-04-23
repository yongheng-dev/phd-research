# `.opencode/`

Active runtime core of the project.

## Layout

```text
.opencode/
├── agent/
├── command/
├── memory/
├── plugins/
├── verifiers/
├── traces/
├── checkpoints/
└── proposals/
```

## Invariants

1. Active command surface is 7 commands.
2. Audit agents use `github-copilot/gpt-5.4`.
3. Root session model is `github-copilot/claude-sonnet-4.6`.
4. Heavy synthesis stays on `github-copilot/claude-opus-4.7`.
5. Domain knowledge comes from `domains/ai-in-education/`.
6. Persistent memory lives in `.opencode/memory/` only.

## Common Checks

```bash
bash .opencode/verifiers/run-all.sh
```
