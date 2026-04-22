# OpenCode 使用指南

PhD-Research 的运行环境是 **OpenCode**。本文说明如何在日常研究中使用 8 个命令、18 个子代理、以及自动持久化到 Obsidian 的工作流。

> 历史上本目录同时支持 Claude Code(`.claude/` 资产),目前已废弃,所有功能迁移到 `.opencode/`。新功能仅在 OpenCode 侧维护。

## 配置文件

| 资产 | 路径 |
|------|------|
| 项目说明 | `AGENTS.md` |
| MCP 与权限 | `opencode.json` |
| 斜杠命令(8 个) | `.opencode/command/*.md` |
| 子代理(18 个) | `.opencode/agent/*.md` |
| 项目记忆 | `.opencode/memory/`(Tier-1 永久 + Tier-2 90 天轮换) |
| 集成契约 | `.opencode/verifiers/CONTRACT.md`(权威) |
| 插件 | `.opencode/plugins/phd.ts`(单文件,bun 构建) |

## 前置条件

1. **OpenCode** — 已安装并完成模型认证(默认 `github-copilot/claude-opus-4.7`)
2. **Bun** — 用于构建 `.opencode/plugins/phd.ts`
3. **Node.js 18+** — `npx` 用于 obsidian-fs 与 sequential-thinking
4. **Python 3.10+ 与 uv** — `uvx` 用于 semantic-scholar、arxiv、paper-search、zotero
5. **Obsidian Vault** 位于 `/Users/xuyongheng/Obsidian-Vault`,使用 3 文件夹布局(`Inbox / Notes / Writing`)
6. **Zotero** 桌面客户端运行中(若使用 `zotero` MCP)

## 启动

```bash
cd /Users/xuyongheng/PhD-Research

# 首次:构建插件
cd .opencode/plugins && bun build phd.ts --target=node --outfile=phd.js && cd ../..

# 验证完整性(必须 7/7 GREEN)
bash .opencode/verifiers/run-all.sh

# 启动
opencode
```

OpenCode 自动读取 `opencode.json` 与 `AGENTS.md`,加载 6 个 MCP server 并注册 `.opencode/` 下的命令、子代理、插件。

## 8 个命令

R1+R2 重构把原先的 17 个单用途命令折叠为 8 个意图动词。每个动词是一个轻量 router,根据参数形态自动路由到合适的子代理。

| 命令 | 用途 | 强制审计 |
|------|------|---------|
| `/find {query}` | 找论文/概念/已有笔记(自动路由) | coverage-critic + citation-verifier |
| `/read {paper}` | 深读论文(自动 fetch + 摘要 + 抽取) | summary-auditor + citation-verifier |
| `/think {topic}` | 构思 / 概念卡片 / 理论谱系 | novelty-checker(So-What 门禁) + citation-verifier |
| `/write {target}` | 长文输出(综述/章节/草稿) | coverage-critic + citation-verifier |
| `/review [--cadence=day\|week\|month]` | 日/周/月度回顾 | n/a |
| `/plan {topic}` | PhD 5 步博士路径(S1→S5);`--mode=deep-dive` 走 9 阶段全流水线 | 全部 4 个审计 agent |
| `/admin {sub}` | 系统维护:`meta-optimize` / `eval` / `health` / `init` | n/a |
| `/init` | 首次项目初始化向导 | n/a |

旧命令(`/search-papers`、`/summarize`、`/brainstorm`、`/lit-review`、`/concept`、`/theory-map`、`/daily`、`/weekly-report`、`/deep-dive`、`/phd-route`、`/fetch`、`/extract`、`/draft`、`/curate`、`/meta-optimize`、`/eval`)均已移除,功能合入上述 8 个动词。

## 子代理

完整路由表见 `AGENTS.md` 的 *Subagent Routing* 章节,详细说明见 `docs/skills-guide.md`。常用快速对照:

- 找论文 → `literature-searcher` / `paper-fetcher`
- 读论文 → `paper-summarizer` / `data-extractor`
- 想点子 → `research-ideator` / `theory-mapper`
- 解释概念 → `concept-explainer`
- 写综述/初稿 → `lit-review-builder` / `writing-drafter`
- 整理引用 → `zotero-curator`
- 全流水线 → `deep-dive`
- 审计层 → `coverage-critic` / `citation-verifier` / `summary-auditor` / `novelty-checker` / `concept-auditor` / `meta-optimizer`

每个审计 agent 都声明 `fallback_model: github-copilot/claude-opus-4.7`,在 gpt-5.4 不可用时自动降级并发出 `degraded_audit:true` 标记;插件以 `audit.degraded` 事件再发,可在下一次 `/review` 中看到。

## MCP 工具命名

OpenCode 中 MCP 工具暴露为 `<server>_<tool>`,例如:

- `semantic-scholar_paper_relevance_search`
- `arxiv_search_papers`
- `zotero_zotero_search_items`
- `obsidian-fs_read_text_file`
- `sequential-thinking_sequentialthinking`

在 OpenCode TUI 中可查看完整工具列表。

## 持久化规则

所有产出自动保存到 Obsidian Vault 的 3 文件夹布局,路径映射见 `AGENTS.md` 的 *Save Path Mapping* 表:

| 输出类型 | 保存到 |
|---------|--------|
| 每日推荐 / 搜索结果 | `Inbox/` |
| 论文笔记 / 构思 / 概念卡片 | `Notes/` |
| 文献综述 / 写作草稿 | `Writing/` |

子代理已内置该规则,无需手动指定路径。C2 验证器(`check-persistence.sh`)抽样最近 7 天笔记自动核对。

## 项目记忆(两层)

- **Tier-1 永久**(`phd-doctrine.md` / `decisions.md` / `research-log.md`):仅 append,never 轮换
- **Tier-2 90 天**(`failed-ideas.md` / `patterns.md`):满 90 天由 `phd.ts` 发出 `rotation.due`,用户运行 `/admin meta-optimize --rotate` 后归档到 `archive/YYYY-MM/`,**永不自动**

详见 `.opencode/memory/ROTATION.md`。

## 集成契约与验证

7 个机器可检查的契约(C1–C7)定义在 `.opencode/verifiers/CONTRACT.md`。任何提交前应:

```bash
bash .opencode/verifiers/run-all.sh   # 必须 7/7 GREEN
```

| 契约 | 检查内容 |
|---|---|
| C1 | 所有 agent frontmatter 完整;审计 agent 必须只读 |
| C2 | 笔记保存路径与 frontmatter schema 合规 |
| C3 | 每个研究命令调用了正确的审计 agent |
| C4 | 命令与审计 agent 都写了 JSONL trace |
| C5 | Tier-1 + Tier-2 文件 git-verified append-only |
| C6 | 研究类 agent 加载了 `phd-doctrine.md` 并引用 4 个字段 |
| C7 | `phd.ts` 是无依赖单文件且订阅了必需事件 |

## 故障排查

| 现象 | 排查方向 |
|------|---------|
| MCP 工具不可见 | 检查 `uvx` / `npx` 在 PATH;独立运行 MCP 命令看报错 |
| Zotero 工具报错 | 确认 Zotero 桌面客户端运行,本地 API 已启用 |
| obsidian-fs 写入失败 | 确认 `/Users/xuyongheng/Obsidian-Vault` 存在且可写 |
| 子代理找不到 | 确认 `.opencode/agent/` 下文件 frontmatter 含 `mode: subagent`;C1 verifier 会先报错 |
| bash 命令被拦截 | 在 `opencode.json` 的 `permission.bash` 中添加白名单 |
| 审计走了降级 | 在 `/review` 中看 `audit.degraded` 事件计数;通常是 gpt-5.4 临时不可用 |
| Tier-2 内存涨太大 | 运行 `/admin health`,如显示 `rotation.due` 则跑 `/admin meta-optimize --rotate` |

## 验证清单

首次启用或大改后,跑一遍 `docs/opencode-validation-checklist.md` 的烟测命令。
