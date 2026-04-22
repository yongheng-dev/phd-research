# OpenCode 验证清单

首次启用 OpenCode 或做完结构改动后,按以下顺序手动验证。每一步标注**预期输出**与**失败排查**。

---

## 0. 启动前检查

```bash
cd /Users/xuyongheng/PhD-Research
which opencode && opencode --version
which uvx && which npx && which bun
ls /Users/xuyongheng/Obsidian-Vault | head
```

**预期**: 命令都能输出版本/路径,Vault 列出 `Inbox/`、`Notes/`、`Writing/`、`Templates/`、`Attachments/`(R4 之后的 3 文件夹布局)。
**失败**: 缺 `uvx` 装 `uv`;缺 `npx` 装 Node.js;缺 `bun` 装 Bun;Vault 路径不存在则修改 `opencode.json` 中 obsidian-fs 的 args。

---

## 1. 集成契约验证(必须 7/7 GREEN)

```bash
bash .opencode/verifiers/run-all.sh
```

**预期**: 7 个检查全部 GREEN(C1 frontmatter / C2 persistence / C3 audit / C4 trace / C5 memory / C6 doctrine / C7 plugin)。
**失败**: 任意 RED 必须先修复才能继续。错误信息会指向具体文件和缺失字段。

---

## 2. 启动 OpenCode 并确认配置加载

```bash
opencode
```

**预期**: 进入 TUI,顶部/状态栏显示模型 `github-copilot/claude-opus-4.7`。

在 OpenCode 中输入:

```
你能列出当前可用的 MCP 工具吗?只列前缀(server 名)即可。
```

**预期**: 列出 `semantic-scholar`、`arxiv`、`paper-search`、`zotero`、`obsidian-fs`、`sequential-thinking` 共 6 个 server。

**失败**: 少哪个就检查对应 MCP 的命令是否能在终端独立运行(例如 `uvx semantic-scholar-fastmcp --help`)。

---

## 3. MCP 烟测 — Semantic Scholar

```
用 semantic-scholar MCP 搜索 "AI literacy in higher education",返回 3 篇,只显示标题、年份、作者。
```

**预期**: 调用 `semantic-scholar_paper_relevance_search`(或类似工具名),返回结构化 3 条结果。
**失败**: 若提示工具不存在,说明 server 没启动成功 → 退出 OpenCode,在终端跑 `uvx semantic-scholar-fastmcp` 看报错。

---

## 4. MCP 烟测 — arXiv

```
用 arxiv MCP 查找过去 30 天内 cs.CY 分类下与 "self-regulated learning" 相关的预印本,返回 3 条。
```

**预期**: 调用 `arxiv_search_papers` 返回结果。

---

## 5. MCP 烟测 — Zotero(若使用)

```
用 zotero MCP 列出我的 Zotero 库中最近添加的 5 条目,只要标题和作者。
```

**预期**: 返回真实的 Zotero 条目。
**失败**: 确认 Zotero 客户端在运行,且 Edit → Settings → Advanced → "Allow other applications" 已开启。

---

## 6. MCP 烟测 — Obsidian-FS

```
用 obsidian-fs MCP 列出 Obsidian Vault 根目录下的子目录。
```

**预期**: 返回 `Inbox/`、`Notes/`、`Writing/`、`Templates/`、`Attachments/`(R4 之后的 3 文件夹布局)。
**失败**: 若仍显示旧的 8 文件夹结构,说明迁移未跑 → `bash scripts/migrate-vault.sh`。

---

## 7. 命令路由 — `/think`(概念卡片分支)

```
/think 解释 self-regulated learning
```

**预期**:
- 主代理通过 `task` 调用 `concept-explainer` 子代理
- 输出概念卡片,后接 `concept-auditor` 审计意见
- 自动写入 `/Users/xuyongheng/Obsidian-Vault/Notes/Self-Regulated-Learning.md`
- 含 frontmatter `type: concept-card`,末尾含 `[[bidirectional links]]`

**失败**: 若主代理直接回答而不调用子代理 → 检查 `.opencode/agent/concept-explainer.md` 的 `description` 字段;若文件没保存 → 检查 obsidian-fs MCP。

---

## 8. 命令路由 — `/find`

```
/find AI literacy assessment
```

**预期**:
- 调用 `literature-searcher` 子代理
- 多源(Semantic Scholar + arXiv 至少)返回结果
- **强制后审**: `coverage-critic` + `citation-verifier` 自动跑(C3)
- 保存到 `/Users/xuyongheng/Obsidian-Vault/Inbox/YYYY-MM-DD-AI-literacy-assessment.md`
- Trace 写入 `.opencode/traces/YYYY-MM-DD/find.jsonl`(C4)

---

## 9. 命令路由 — `/read`

挑一篇 arXiv 论文(例如 `arXiv:2310.02207`)或 Zotero 中已有的 PDF:

```
/read arXiv:2310.02207
```

**预期**:
- 若 PDF 不在 Zotero,先调用 `paper-fetcher`
- 然后调用 `paper-summarizer`
- 强制后审 `summary-auditor` + `citation-verifier`
- 保存到 `/Users/xuyongheng/Obsidian-Vault/Notes/{FirstAuthor}-{Year}-{ShortTitle}.md`
- frontmatter 含 `type: paper-note`

---

## 10. 命令路由 — `/think`(构思分支)

```
/think AI tutor 与学生 self-regulation 的交互
```

**预期**:
- 调用 `research-ideator` 子代理
- 输出 collision matrix 风格的多个研究方向,每个含 `mainstream_anchor` / `sub_branch` / `theoretical_contribution` / `so_what`(C6 doctrine)
- 强制后审 `novelty-checker`(So-What 门禁)+ `citation-verifier`
- 被拒方向自动写入 `.opencode/memory/failed-ideas.md`(Tier-2,append-only)
- 保存到 `/Users/xuyongheng/Obsidian-Vault/Notes/YYYY-MM-DD-{topic}.md`

---

## 11. 全流水线 — `/plan --mode=deep-dive`(高强度,可选)

```
/plan AI literacy assessment in K-12 --mode=deep-dive
```

**预期**: orchestrator (`deep-dive` 子代理) 依次 spawn:
1. `research-planner` → 搜索计划
2. `literature-searcher` → 多源检索
3. `coverage-critic` → 覆盖度审计
4. `citation-verifier` → 引用核验
5. `paper-summarizer` × N → 逐篇摘要
6. `summary-auditor` → 摘要核验
7. `lit-review-builder` → 综述合成
8. `research-ideator` → 衍生方向
9. `novelty-checker` → 新颖度评分

最终产出保存到 `Writing/`(综述)与 `Notes/`(构思),并 append 到 `.opencode/memory/patterns.md`。每阶段在 `.opencode/checkpoints/` 留 checkpoint(可断点续跑)。

**失败**: 任意一步停在主代理而非 subagent → 把 OpenCode 显示的 task 调用日志贴回来。

---

## 12. 系统健康 — `/admin health`

```
/admin health
```

**预期**: 输出包含
- 7/7 verifier 状态
- 最近 7 天 trace 行数
- Tier-2 内存是否到达 90 天轮换阈值(若是,显示 `rotation.due`)
- 最近 `audit.degraded` 事件计数
- `evals/reports/` 最近一次 dashboard 快照

---

## 13. 权限边界检查

```
帮我跑一下 npm install xxxxx
```

**预期**: OpenCode 提示需要确认(`opencode.json` 中除白名单外的 bash 命令默认 `ask`)。

---

## 反馈格式

跑完一轮后,把以下信息贴给 AI 助手:

```
通过的步骤: 1, 2, 3, 5, 6, 7
失败的步骤:
  - 步骤 4 (zotero): <错误信息或现象>
  - 步骤 11 (deep-dive): <在第几个 subagent 卡住>
  - 验证器 RED: <C? + 输出>
其他观察: <任何异常>
```

会据此修复 `opencode.json` / 子代理 prompt / 验证器期望值。
