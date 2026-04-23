# Checkpoints

Checkpoint files for `/plan --mode=deep-dive` runs.

## Expected Shapes

- Deep-dive stage checkpoint: `ts`, `session_id`, `command`, `stage`, `label`, `kind: "deep-dive-stage-checkpoint"`
- Post-compaction snapshot: `ts`, `session_id`, `kind: "post-compaction-snapshot"`

These checkpoints are resumability artifacts. They do not replace the final synthesis note or memory updates in `.opencode/memory/research-log.md` and `.opencode/memory/decisions.md`.
