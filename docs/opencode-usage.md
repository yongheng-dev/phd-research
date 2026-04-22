# OpenCode 使用指南

本项目同时支持 **Claude Code** 与 **OpenCode** 两套运行环境,配置并存,互不干扰。本文档说明如何在 OpenCode 中使用项目的研究工作流。

> Claude Code 用法见 `docs/quickstart.md`。OpenCode 与 Claude Code 共享同一套 MCP 服务、Obsidian 笔记目录与领域知识包,只是运行入口与配置文件不同。

## 配置对照

| 资产 | Claude Code | OpenCode |
|------|-------------|----------|
| 项目说明 | `CLAUDE.md` | `AGENTS.md` |
| MCP 配置 | `.mcp.json` | `opencode.json` |
| 权限配置 | `.claude/settings.json` | `opencode.json` 的 `permission` 字段 |
| 斜杠命令 | `.claude/commands/*.md` | `.opencode/command/*.md` |
| 子代理 | `.claude/agents/*.md` | `.opencode/agent/*.md` |
| 技能 | `references/*/SKILL.md` | `.opencode/agent/*.md`(转换为 subagent) |

## 前置条件

1. **OpenCode** — 已安装并完成模型认证(默认 `github-copilot/claude-opus-4.7`)
2. **Node.js 18+** — `npx` 用于 obsidian-fs 与 sequential-thinking
3. **Python 3.10+ 与 uv** — `uvx` 用于 semantic-scholar、arxiv、paper-search、zotero
4. **Obsidian Vault** 已存在于 `/Users/xuyongheng/Obsidian-Vault`
5. **Zotero** 本地客户端运行中(若使用 `zotero` MCP)

## 启动

```bash
cd /Users/xuyongheng/PhD-Research
opencode
```

OpenCode 会自动读取 `opencode.json` 与 `AGENTS.md`,加载 6 个 MCP server 并注册 `.opencode/` 下的命令与子代理。

## 可用命令

| 命令 | 用途 |
|------|------|
| `/daily` | 每日研究例程 |
| `/search-papers {主题}` | 多源文献搜索 |
| `/summarize {论文}` | 深度论文摘要并生成笔记 |
| `/brainstorm {主题}` | 通过 collision matrix 进行研究构思 |
| `/lit-review {主题}` | 系统性文献综述 |
| `/concept {术语}` | 概念解释与卡片生成 |
| `/weekly-report` | 周度研究活动汇总 |
| `/deep-dive {主题}` | 完整的多阶段验证型研究流水线 |
| `/init` | 项目初始化向导 |

## 子代理路由

主代理会根据用户请求自动调用 `.opencode/agent/` 下的子代理。完整路由表见 `AGENTS.md` 的 *Subagent Routing* 章节。常用映射:

- 找论文 → `literature-searcher`
- 读论文 → `paper-summarizer`
- 综述 → `lit-review-builder`
- 想点子 → `research-ideator`
- 解释概念 → `concept-explainer`
- 全流水线 → `deep-dive`

## MCP 工具命名

OpenCode 中 MCP 工具暴露为 `<server>_<tool>`,例如:

- `semantic-scholar_search_paper`
- `arxiv_search_papers`
- `zotero_zotero_search_items`
- `obsidian-fs_read_file`
- `sequential-thinking_sequentialthinking`

如需在终端检查可用工具,在 OpenCode TUI 中查看工具列表。

## 持久化规则

所有产出会自动保存到 Obsidian Vault,路径映射详见 `AGENTS.md` 的 *Save Path Mapping* 表。子代理已内置该规则,无需手动指定保存路径。

## 与 Claude Code 切换

两套配置完全独立。同一目录下:

```bash
claude    # 使用 .claude/ + .mcp.json + CLAUDE.md
opencode  # 使用 .opencode/ + opencode.json + AGENTS.md
```

修改 Claude Code 资产不会影响 OpenCode,反之亦然。如需同步功能改动,需要在两侧分别更新对应文件。

## 故障排查

| 现象 | 排查方向 |
|------|---------|
| MCP 工具不可见 | 检查 `uvx` / `npx` 是否在 PATH;查看 OpenCode 日志中 MCP 启动报错 |
| Zotero 工具报错 | 确认 Zotero 桌面客户端正在运行,且本地 API 已启用 |
| obsidian-fs 写入失败 | 检查 `/Users/xuyongheng/Obsidian-Vault` 路径存在且可写 |
| 子代理找不到 | 确认文件位于 `.opencode/agent/` 且 frontmatter 包含 `mode: subagent` |
| bash 命令被拦截 | 在 `opencode.json` 的 `permission.bash` 中添加白名单规则 |

## 验证清单

首次启动后建议跑一遍 `docs/opencode-validation-checklist.md` 中的烟测命令,确认 MCP 与子代理路由正常。
