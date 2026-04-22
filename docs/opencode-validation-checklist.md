# OpenCode 验证清单

首次启用 OpenCode 后,按以下顺序手动验证。每一步标注**预期输出**与**失败排查**,出问题时把现象贴回给 AI 助手即可。

---

## 0. 启动前检查

```bash
cd /Users/xuyongheng/PhD-Research
which opencode && opencode --version
which uvx && which npx
ls /Users/xuyongheng/Obsidian-Vault | head
```

**预期**: 三条命令都能正常输出版本/路径,Obsidian Vault 列出已有目录。
**失败**: 缺 `uvx` 装 `uv`;缺 `npx` 装 Node.js;Vault 路径不存在则修改 `opencode.json` 中 obsidian-fs 的 args。

---

## 1. 启动 OpenCode 并确认配置加载

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

## 2. MCP 烟测 — Semantic Scholar

```
用 semantic-scholar MCP 搜索 "AI literacy in higher education",返回 3 篇,只显示标题、年份、作者。
```

**预期**: 调用 `semantic-scholar_search_paper`(或类似工具名),返回结构化 3 条结果。
**失败**: 若提示工具不存在,说明 server 没启动成功 → 退出 OpenCode,在终端跑 `uvx semantic-scholar-fastmcp` 看报错。

---

## 3. MCP 烟测 — arXiv

```
用 arxiv MCP 查找过去 30 天内 cs.CY 分类下与 "self-regulated learning" 相关的预印本,返回 3 条。
```

**预期**: 调用 `arxiv_*` 工具返回结果。

---

## 4. MCP 烟测 — Zotero(若使用)

```
用 zotero MCP 列出我的 Zotero 库中最近添加的 5 条目,只要标题和作者。
```

**预期**: 返回真实的 Zotero 条目。
**失败**: 确认 Zotero 客户端在运行,且 Edit → Settings → Advanced → "Allow other applications" 已开启。

---

## 5. MCP 烟测 — Obsidian-FS

```
用 obsidian-fs MCP 列出 Obsidian Vault 根目录下的子目录。
```

**预期**: 返回 `Daily Picks/`、`Paper Notes/`、`Search Results/` 等(若已存在)。

---

## 6. 命令路由 — `/concept`

```
/concept self-regulated learning
```

**预期**:
- 主代理通过 `task` 工具调用 `concept-explainer` 子代理
- 输出概念卡片
- 自动写入 `/Users/xuyongheng/Obsidian-Vault/Notes/Self-Regulated-Learning.md`(或类似文件名)
- 包含 YAML frontmatter(`type: concept-card`)

**失败**: 若主代理直接回答而不调用子代理 → 检查 `.opencode/agent/concept-explainer.md` 的 `description` 字段是否清晰;若文件没保存 → 检查 obsidian-fs MCP 是否正常。

---

## 7. 命令路由 — `/search-papers`

```
/search-papers AI literacy assessment
```

**预期**:
- 调用 `literature-searcher` 子代理
- 多源(Semantic Scholar + arXiv 至少)返回结果
- 保存到 `/Users/xuyongheng/Obsidian-Vault/Inbox/YYYY-MM-DD-AI-literacy-assessment.md`

---

## 8. 命令路由 — `/summarize`

挑一篇 arXiv 论文(例如 `arXiv:2310.02207`)或 Zotero 中已有的 PDF:

```
/summarize arXiv:2310.02207
```

**预期**:
- 调用 `paper-summarizer` 子代理
- 生成结构化笔记
- 保存到 `/Users/xuyongheng/Obsidian-Vault/Notes/{FirstAuthor}-{Year}-{ShortTitle}.md`
- frontmatter 含 `type: paper-note`,正文末尾含 `[[bidirectional links]]`

---

## 9. 命令路由 — `/brainstorm`

```
/brainstorm AI tutor 与学生 self-regulation 的交互
```

**预期**:
- 调用 `research-ideator` 子代理
- 输出 collision matrix 风格的多个研究方向
- 保存到 `/Users/xuyongheng/Obsidian-Vault/Notes/YYYY-MM-DD-{topic}.md`

---

## 10. 子代理协作 — `/deep-dive`(高强度,可选)

```
/deep-dive AI literacy assessment in K-12
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

最终产出保存到 `Literature Reviews/` 与 `Ideation Sessions/`,并更新 `.scholar-flow/wisdom/` 下的累积学习文件。

**失败**: 任意一步停在主代理而非 subagent → 把 OpenCode 显示的 task 调用日志贴回来。

---

## 11. 权限边界检查

```
帮我跑一下 npm install xxxxx
```

**预期**: OpenCode 提示需要确认(因为 `opencode.json` 中除白名单外的 bash 命令默认 `ask`)。

---

## 反馈格式

跑完一轮后,把以下信息贴给 AI 助手:

```
通过的步骤: 1, 2, 3, 5, 6, 7
失败的步骤:
  - 步骤 4 (zotero): <错误信息或现象>
  - 步骤 10 (deep-dive): <在第几个 subagent 卡住>
其他观察: <任何异常>
```

我会据此修复 `opencode.json` 或对应的子代理 prompt。
