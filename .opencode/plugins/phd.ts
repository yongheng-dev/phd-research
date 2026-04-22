/**
 * phd.ts — PhD-Research workflow plugin (zero-dependency, single file)
 *
 * Subscribes to OpenCode plugin events to enforce the PhD Doctrine
 * and persist research state across sessions and compactions.
 *
 * Events handled:
 *   - session.created           → inject PhD Doctrine summary into session context (log only)
 *                                 + emit `rotation.due` notice if Tier-2 memory is >90 days old
 *   - session.idle              → write a session trace summary
 *   - session.compacted         → snapshot session state into checkpoints/
 *   - experimental.session.compacting → inject persistent research state into compaction prompt
 *   - command.executed          → if /deep-dive stage marker detected, write per-stage checkpoint
 *   - tool.execute.after        → light-weight tool-call trace (audit-class agents only)
 *                                 + emit `audit.degraded` if result carries `degraded_audit: true`
 *   - file.edited               → emit `dashboard.update` when evals/reports/* files change
 *
 * Design constraints (locked decisions):
 *   - Single file, zero npm dependencies. Uses only Node/Bun built-ins.
 *   - Checkpoints written ONLY for /deep-dive stages (S1..S5).
 *   - All writes are append-only to .opencode/traces/ and atomic to .opencode/checkpoints/.
 *   - No network calls. No mutation of memory/ files (those are immutable at runtime).
 *
 * Layout:
 *   .opencode/
 *     plugins/phd.ts            ← this file
 *     memory/                   ← immutable at runtime
 *     traces/                   ← append-only JSONL
 *     checkpoints/              ← per-session per-stage JSON
 */

import { mkdirSync, appendFileSync, writeFileSync, existsSync, readFileSync } from "node:fs";
import { join, dirname } from "node:path";

// ---------- helpers ----------

const PROJECT_ROOT_FALLBACK = process.cwd();

function resolveRoot(ctx: any): string {
  // plugin context exposes project / directory / worktree depending on version
  return (
    ctx?.directory ||
    ctx?.worktree ||
    ctx?.project?.worktree ||
    ctx?.project?.directory ||
    PROJECT_ROOT_FALLBACK
  );
}

function ensureDir(p: string) {
  try {
    mkdirSync(p, { recursive: true });
  } catch {
    /* ignore */
  }
}

function nowIso(): string {
  return new Date().toISOString();
}

function safeAppendJsonl(file: string, record: Record<string, unknown>) {
  try {
    ensureDir(dirname(file));
    appendFileSync(file, JSON.stringify(record) + "\n", "utf8");
  } catch (err) {
    // never throw from a plugin hook
    console.error("[phd-plugin] append failed", file, err);
  }
}

function safeWriteJson(file: string, obj: unknown) {
  try {
    ensureDir(dirname(file));
    writeFileSync(file, JSON.stringify(obj, null, 2), "utf8");
  } catch (err) {
    console.error("[phd-plugin] write failed", file, err);
  }
}

function readDoctrineSummary(root: string): string {
  const p = join(root, ".opencode", "memory", "phd-doctrine.md");
  if (!existsSync(p)) return "";
  try {
    const text = readFileSync(p, "utf8");
    // extract Core Principle + 5-Step table headings only (compact)
    const lines = text.split("\n");
    const head = lines.slice(0, 32).join("\n");
    return head;
  } catch {
    return "";
  }
}

// crude detector for /deep-dive stage markers in command output / messages
const STAGE_RE = /\b(S[1-5])\b\s*[:\-—]\s*([A-Za-z][^\n]{0,80})/;

function detectStage(text: string | undefined): { stage: string; label: string } | null {
  if (!text) return null;
  const m = text.match(STAGE_RE);
  if (!m) return null;
  return { stage: m[1], label: m[2].trim() };
}

// audit-class agents (must match .opencode/agent/*.md)
const AUDIT_AGENTS = new Set([
  "citation-verifier",
  "coverage-critic",
  "summary-auditor",
  "novelty-checker",
  "concept-auditor",
  "meta-optimizer",
]);

// ---------- rotation reminder (Option C — see .opencode/memory/ROTATION.md) ----------

const ROTATION_FILES = ["failed-ideas.md", "patterns.md"];
const ROTATION_AGE_DAYS = 90;
const DATE_HEADING_RE = /^##\s+(\d{4}-\d{2}-\d{2})\b/m;

/** Find the OLDEST date heading still present in an active Tier-2 memory file.
 *  Returns ISO date string or null if none. */
function oldestDateHeading(file: string): string | null {
  if (!existsSync(file)) return null;
  try {
    const txt = readFileSync(file, "utf8");
    const dates: string[] = [];
    for (const line of txt.split("\n")) {
      const m = line.match(/^##\s+(\d{4}-\d{2}-\d{2})\b/);
      if (m) dates.push(m[1]);
    }
    if (dates.length === 0) return null;
    dates.sort();
    return dates[0];
  } catch {
    return null;
  }
}

function daysBetween(isoOld: string, now: Date): number {
  const old = new Date(isoOld + "T00:00:00Z").getTime();
  return Math.floor((now.getTime() - old) / 86_400_000);
}

function checkRotationDue(root: string): { due: string[]; oldest: string | null } {
  const due: string[] = [];
  let oldestOverall: string | null = null;
  const now = new Date();
  for (const name of ROTATION_FILES) {
    const p = join(root, ".opencode", "memory", name);
    const oldest = oldestDateHeading(p);
    if (oldest && daysBetween(oldest, now) > ROTATION_AGE_DAYS) {
      due.push(name);
      if (!oldestOverall || oldest < oldestOverall) oldestOverall = oldest;
    }
  }
  return { due, oldest: oldestOverall };
}

// ---------- plugin entry ----------

export const PhdPlugin = async (ctx: any) => {
  const root = resolveRoot(ctx);
  const tracesDir = join(root, ".opencode", "traces");
  const checkpointsDir = join(root, ".opencode", "checkpoints");
  ensureDir(tracesDir);
  ensureDir(checkpointsDir);

  const sessionTrace = (sessionId: string) =>
    join(tracesDir, `session-${sessionId || "unknown"}.jsonl`);

  const log = (level: string, message: string, extra?: Record<string, unknown>) => {
    // best-effort structured log via OpenCode client if available
    try {
      ctx?.client?.app?.log?.({
        body: { service: "phd-plugin", level, message, extra: extra ?? {} },
      });
    } catch {
      /* ignore */
    }
  };

  log("info", "phd-plugin loaded", { root });

  return {
    // -------- session lifecycle --------

    "session.created": async ({ session }: any) => {
      const sid = session?.id ?? "unknown";
      const doctrine = readDoctrineSummary(root);
      safeAppendJsonl(sessionTrace(sid), {
        ts: nowIso(),
        event: "session.created",
        session_id: sid,
        doctrine_loaded: doctrine.length > 0,
      });

      // Rotation reminder (Option C). Never auto-rotate; just emit a notice.
      const rot = checkRotationDue(root);
      if (rot.due.length > 0) {
        safeAppendJsonl(sessionTrace(sid), {
          ts: nowIso(),
          event: "rotation.due",
          files: rot.due,
          oldest: rot.oldest,
          policy: ".opencode/memory/ROTATION.md",
          action: "Run `/admin meta-optimize --rotate` when convenient.",
        });
        log("info", "memory rotation due", { files: rot.due, oldest: rot.oldest });
      }

      log("info", "session.created", { session_id: sid, doctrine_chars: doctrine.length });
    },

    "session.idle": async ({ session }: any) => {
      const sid = session?.id ?? "unknown";
      safeAppendJsonl(sessionTrace(sid), {
        ts: nowIso(),
        event: "session.idle",
        session_id: sid,
      });
    },

    "session.compacted": async ({ session }: any) => {
      const sid = session?.id ?? "unknown";
      const file = join(checkpointsDir, `${sid}-compacted-${Date.now()}.json`);
      safeWriteJson(file, {
        ts: nowIso(),
        session_id: sid,
        kind: "post-compaction-snapshot",
        note: "Session was compacted; lightweight checkpoint written.",
      });
      safeAppendJsonl(sessionTrace(sid), {
        ts: nowIso(),
        event: "session.compacted",
        session_id: sid,
        checkpoint: file,
      });
    },

    // inject persistent research state into the compaction summary prompt
    "experimental.session.compacting": async ({ session, prompt }: any) => {
      const sid = session?.id ?? "unknown";
      const doctrine = readDoctrineSummary(root);
      const inject =
        "\n\n---\n[PhD Plugin Persistent State]\n" +
        "Preserve across compaction:\n" +
        "  - active research topic / mainstream_anchor / sub_branch\n" +
        "  - papers already audited (citation-verifier PASS list)\n" +
        "  - current /deep-dive stage (S1..S5) if any\n" +
        "  - PROCEED-marked research directions and their so_what_score\n" +
        "  - any open So-What Gate REJECTs awaiting revision\n\n" +
        "Doctrine excerpt (do not drop):\n" +
        doctrine.split("\n").slice(0, 12).join("\n");

      safeAppendJsonl(sessionTrace(sid), {
        ts: nowIso(),
        event: "experimental.session.compacting",
        session_id: sid,
        injected_chars: inject.length,
      });

      // mutate prompt if the runtime accepts a return value; also append in place if mutable
      try {
        if (prompt && typeof prompt === "object" && "text" in prompt) {
          (prompt as any).text = String((prompt as any).text ?? "") + inject;
        }
      } catch {
        /* ignore */
      }
      return { prompt: { text: inject, append: true } };
    },

    // -------- command lifecycle --------

    "command.executed": async ({ session, command, output }: any) => {
      const sid = session?.id ?? "unknown";
      const name: string = command?.name ?? command ?? "";
      if (!name) return;

      // record every command execution lightly
      safeAppendJsonl(sessionTrace(sid), {
        ts: nowIso(),
        event: "command.executed",
        session_id: sid,
        command: name,
      });

      // checkpoint ONLY for /deep-dive stages
      if (name.endsWith("deep-dive") || name === "deep-dive" || name === "/deep-dive") {
        const stage = detectStage(typeof output === "string" ? output : output?.text);
        if (stage) {
          const file = join(
            checkpointsDir,
            `${sid}-deep-dive-${stage.stage}-${Date.now()}.json`,
          );
          safeWriteJson(file, {
            ts: nowIso(),
            session_id: sid,
            command: "/deep-dive",
            stage: stage.stage,
            label: stage.label,
            kind: "deep-dive-stage-checkpoint",
          });
          safeAppendJsonl(sessionTrace(sid), {
            ts: nowIso(),
            event: "deep-dive.stage.checkpoint",
            session_id: sid,
            stage: stage.stage,
            checkpoint: file,
          });
          log("info", "deep-dive checkpoint written", { stage: stage.stage, file });
        }
      }
    },

    // -------- tool calls (light trace for audit agents only) --------

    "tool.execute.before": async ({ session, agent, tool }: any) => {
      const agentName: string = agent?.name ?? agent ?? "";
      if (!AUDIT_AGENTS.has(agentName)) return;
      safeAppendJsonl(sessionTrace(session?.id ?? "unknown"), {
        ts: nowIso(),
        event: "tool.execute.before",
        agent: agentName,
        tool: tool?.name ?? tool ?? "unknown",
      });
    },

    "tool.execute.after": async ({ session, agent, tool, result }: any) => {
      const agentName: string = agent?.name ?? agent ?? "";
      if (!AUDIT_AGENTS.has(agentName)) return;

      // Detect degraded_audit signal in the result body (best-effort string scan;
      // result shape is runtime-dependent so we stringify defensively).
      let degraded = false;
      try {
        const blob =
          typeof result === "string"
            ? result
            : JSON.stringify(result ?? "", null, 0);
        if (/"degraded_audit"\s*:\s*true|degraded_audit:\s*true/.test(blob)) {
          degraded = true;
        }
      } catch {
        /* ignore */
      }

      const sid = session?.id ?? "unknown";
      safeAppendJsonl(sessionTrace(sid), {
        ts: nowIso(),
        event: "tool.execute.after",
        agent: agentName,
        tool: tool?.name ?? tool ?? "unknown",
        ok: result?.error == null,
        degraded_audit: degraded,
      });

      if (degraded) {
        safeAppendJsonl(sessionTrace(sid), {
          ts: nowIso(),
          event: "audit.degraded",
          agent: agentName,
          reason: "primary_unavailable_or_marked_by_agent",
          fallback: "anthropic/claude-opus-4.7",
        });
        log("warn", "audit ran on fallback model", { agent: agentName });
      }
    },

    // -------- file watcher: surface dashboard refresh need --------

    "file.edited": async ({ session, file }: any) => {
      const path: string = file?.path ?? file ?? "";
      if (!path) return;
      // Only care about evals dashboard outputs
      if (!/evals\/reports\/.+\.(md|json)$/.test(path)) return;
      const sid = session?.id ?? "unknown";
      safeAppendJsonl(sessionTrace(sid), {
        ts: nowIso(),
        event: "dashboard.update",
        path,
        hint: "Run `/review --cadence=week` to refresh the Assurance Dashboard view.",
      });
    },
  };
};

export default PhdPlugin;
