# .opencode/checkpoints/

Durable snapshots of long-running research state. Written by `.opencode/plugins/phd.ts` and by agents during multi-stage commands.

## Write rules (locked)

| Trigger | Writer | File pattern |
|---|---|---|
| `/deep-dive` stage boundary (S1..S5) | `phd.ts` `command.executed` hook | `<session>-deep-dive-S<n>-<ts>.json` |
| `session.compacted` event | `phd.ts` `session.compacted` hook | `<session>-compacted-<ts>.json` |

No other commands write checkpoints (locked decision — keeps file count bounded).

## Schema: deep-dive stage checkpoint

```json
{
  "ts": "2026-04-23T14:05:17.201Z",
  "session_id": "ses_abc123",
  "command": "/deep-dive",
  "stage": "S2",
  "label": "Quick Survey",
  "kind": "deep-dive-stage-checkpoint"
}
```

Agent-written richer variants (when `/deep-dive` completes a stage) may add:

```json
{
  "topic": "AI literacy in K-12",
  "mainstream_anchor": "generative AI classroom adoption",
  "sub_branch": "teacher TPACK gaps for GenAI",
  "papers_audited_pass": ["arxiv:2401.12345", "ssid:ABC"],
  "theoretical_frameworks": ["TPACK", "SAMR"],
  "next_stage_input": "S3 theory inventory focus list"
}
```

## Schema: post-compaction snapshot

```json
{
  "ts": "2026-04-23T15:11:02.444Z",
  "session_id": "ses_abc123",
  "kind": "post-compaction-snapshot",
  "note": "Session was compacted; lightweight checkpoint written."
}
```

## Recovery protocol

To resume a research thread after a crash or context loss:

1. `ls -t .opencode/checkpoints/<session>-* | head`
2. Read the newest stage checkpoint.
3. Feed `mainstream_anchor` / `sub_branch` / `papers_audited_pass` back into the continuing `/deep-dive` or `/phd-route` invocation.

## Retention

Checkpoints are gitignored (large, regenerable). Manual archival: move interesting ones to `/Users/xuyongheng/Obsidian-Vault/Deep Dives/`.
