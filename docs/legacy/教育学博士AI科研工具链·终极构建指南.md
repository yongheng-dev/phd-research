# 教育学博士 AI 科研工具链 · 终极构建指南

> **版本**: v1.0 终极版
> **适用对象**: 零基础到完全体，教育学 / 社科博士生
> **目标**: 一个命令搜论文、一键生成笔记、每日自动推荐、灵感碰撞、知识自动沉淀

---

## 目录

- [第一章 全局架构与工具分工](#第一章-全局架构与工具分工)
- [第二章 基础环境安装](#第二章-基础环境安装)
- [第三章 目录结构搭建](#第三章-目录结构搭建)
- [第四章 MCP 服务器安装（全部 7 个）](#第四章-mcp-服务器安装)
- [第五章 CLAUDE.md 完整版](#第五章-claudemd-完整版)
- [第六章 Skill 技能包（全部 4 个）](#第六章-skill-技能包)
- [第七章 斜杠命令（全部 6 个）](#第七章-斜杠命令)
- [第八章 Obsidian 配置与模板](#第八章-obsidian-配置与模板)
- [第九章 Zotero 配置](#第九章-zotero-配置)
- [第十章 自动化与定时任务](#第十章-自动化与定时任务)
- [第十一章 日常使用手册](#第十一章-日常使用手册)
- [附录](#附录)

---

## 第一章 全局架构与工具分工

### 工具分工表

| 工具 | 角色 | 负责什么 | 不负责什么 |
|------|------|---------|-----------|
| **Claude Code** | 大脑 + 指挥官 | 分析、总结、灵感碰撞、调度所有 MCP | 不存储任何长期数据 |
| **Zotero** | 图书馆 + 仓库 | 论文 PDF 存储、阅读标注、引用管理、参考文献导出 | 不做深度分析和知识网络 |
| **Obsidian** | 第二大脑 + 笔记本 | 阅读笔记、概念网络、灵感沉淀、写作草稿、每日推荐 | 不存原始 PDF、不管引用格式 |

### 数据流向

```
论文源（Semantic Scholar / arXiv / Google Scholar / ERIC / OpenAlex / SSRN）
    │
    ▼ Claude Code 通过 MCP 搜索
    │
    ├──→ Zotero（通过 Zotero MCP 存入引用 + 下载 PDF）
    │       │
    │       └──→ 你在 Zotero 里阅读、高亮、批注
    │               │
    │               └──→ Claude Code 读取 Zotero 标注（通过 Zotero MCP）
    │
    └──→ Claude Code 分析、总结、碰撞
            │
            └──→ Obsidian（通过文件系统 MCP 写入笔记）
                    │
                    └──→ 双向链接自动连接已有知识
```

---

## 第二章 基础环境安装

### 2.1 安装 Node.js（Claude Code 依赖）

**macOS：**
```bash
# 用 Homebrew 安装（如果没有 Homebrew，先装它）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install node
```

**Windows：**
```bash
winget install OpenJS.NodeJS.LTS
```

**Linux (Ubuntu/Debian)：**
```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**验证：**
```bash
node --version   # 需要 v20+ 
npm --version    # 需要 v10+
```

### 2.2 安装 Python 包管理器 uv（多个 MCP 依赖）

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# 验证
uv --version
```

### 2.3 安装 Claude Code

```bash
npm install -g @anthropic-ai/claude-code

# 验证
claude --version
```

> **前提条件**：你需要以下之一：
> - Anthropic API 密钥（按用量付费）
> - Claude Pro 订阅（$20/月）
> - Claude Max 订阅（$100/月，推荐重度科研使用）
>
> 首次运行 `claude` 时会引导你登录认证。

### 2.4 安装 Zotero 7

- 下载地址：https://www.zotero.org/download/
- 安装后打开 Zotero → 设置 → 高级
- **勾选「允许其他应用程序与 Zotero 通信」**（这是 MCP 连接的前提）
- 安装插件 **Better BibTeX**：
  - 下载：https://retorque.re/zotero-better-bibtex/installation/
  - Zotero → 工具 → 附加组件 → 从文件安装

### 2.5 安装 Obsidian

- 下载地址：https://obsidian.md/download
- 安装后创建一个新 Vault，路径设为 `~/Obsidian-Vault`
- 安装社区插件（可选但推荐）：
  - **Templater**：高级模板引擎
  - **Dataview**：数据库式笔记查询
  - **Calendar**：日历视图看每日笔记
  - **Tag Wrangler**：标签管理

### 2.6 获取必要的 API 密钥

| 服务 | 获取地址 | 是否免费 | 用途 |
|------|---------|---------|------|
| Semantic Scholar | https://www.semanticscholar.org/product/api#api-key-form | 免费 | 学术论文搜索（核心） |
| Brave Search | https://brave.com/search/api/ | 免费（2000次/月） | 网页搜索、灰色文献 |
| Zotero Web API | https://www.zotero.org/settings/keys | 免费 | 文献库远程访问（可选） |

> Semantic Scholar 不用密钥也能用，只是速率更低。建议申请一个。

---

## 第三章 目录结构搭建

### 一键创建全部目录

打开终端，复制粘贴以下命令：

```bash
# ============================================
# 科研工具链目录结构 · 一键创建
# ============================================

# 1. Claude Code 工作区（你的指挥部）
mkdir -p ~/PhD-Research/{skills/{literature-search,paper-summarizer,research-ideation,lit-review-builder}/{references,scripts,assets},.claude/commands,outputs,scripts}

# 2. Obsidian 知识库（你的第二大脑）
mkdir -p ~/Obsidian-Vault/{论文笔记,概念卡片,灵感碰撞,文献综述,文献检索,每日推荐,写作草稿,每日笔记,模板,附件}

# 3. 验证结构
echo "=== Claude Code 工作区 ==="
ls ~/PhD-Research/
echo ""
echo "=== Obsidian 知识库 ==="
ls ~/Obsidian-Vault/
echo ""
echo "✅ 全部目录创建完成"
```

### 目录结构全景图

```
~/
├── PhD-Research/                    ← Claude Code 在此启动（cd 到这里再运行 claude）
│   ├── CLAUDE.md                   ← 项目记忆文件（第五章创建）
│   ├── skills/                     ← 4 个自定义 Skill
│   │   ├── literature-search/      ← 文献检索助手
│   │   │   ├── SKILL.md
│   │   │   └── references/
│   │   │       ├── education-journals.md
│   │   │       └── keyword-mapping.md
│   │   ├── paper-summarizer/       ← 论文总结器
│   │   │   └── SKILL.md
│   │   ├── research-ideation/      ← 灵感碰撞器
│   │   │   └── SKILL.md
│   │   └── lit-review-builder/     ← 文献综述构建器
│   │       └── SKILL.md
│   ├── .claude/
│   │   └── commands/               ← 6 个斜杠命令
│   │       ├── daily.md            ← /daily 每日流程
│   │       ├── search-papers.md    ← /search-papers 文献搜索
│   │       ├── summarize.md        ← /summarize 论文总结
│   │       ├── brainstorm.md       ← /brainstorm 灵感碰撞
│   │       ├── lit-review.md       ← /lit-review 文献综述
│   │       └── weekly-report.md    ← /weekly-report 周报
│   ├── outputs/                    ← Claude 生成的临时文件
│   └── scripts/                    ← 自动化脚本
│       └── daily-recommend.sh      ← cron 定时任务脚本
│
├── Obsidian-Vault/                 ← Obsidian 打开此文件夹作为 Vault
│   ├── 论文笔记/                   ← Claude 自动生成的论文总结
│   ├── 概念卡片/                   ← 一个概念一张卡（如「TPACK」）
│   ├── 灵感碰撞/                   ← 灵感碰撞记录
│   ├── 文献综述/                   ← 主题式文献梳理
│   ├── 文献检索/                   ← 每次检索的结果存档
│   ├── 每日推荐/                   ← 每日论文推荐
│   ├── 写作草稿/                   ← 论文章节草稿
│   ├── 每日笔记/                   ← 研究日志
│   ├── 模板/                      ← Obsidian 笔记模板
│   └── 附件/                      ← 图片等（不放 PDF）
│
└── Zotero/                         ← Zotero 自动管理，不要手动改
    └── storage/                    ← PDF 文件自动存在这里
```

---

## 第四章 MCP 服务器安装

### 安装前说明

所有命令都在**终端**中运行（不是在 Claude Code 内部）。
`-s user` 表示全局安装，所有项目都能用。

### 4.1 Semantic Scholar MCP（核心 · 学术搜索引擎）

覆盖：2 亿+ 篇论文，跨学科，支持引用网络分析、作者信息、论文推荐。

```bash
claude mcp add semantic-scholar -s user \
  -e SEMANTIC_SCHOLAR_API_KEY="你的密钥" \
  -- uvx semantic-scholar-fastmcp
```

> 如果还没有 API 密钥，可以先不加 `-e` 参数，无密钥也能用（速率更低）：
> ```bash
> claude mcp add semantic-scholar -s user -- uvx semantic-scholar-fastmcp
> ```

**提供的能力：**
- `paper_relevance_search` — 按相关性搜索论文
- `paper_bulk_search` — 批量搜索，可按引用数/日期排序
- `paper_details` — 获取论文详细信息（摘要、作者、引用数）
- `get_citations` — 获取引用/被引用论文列表
- `get_paper_recommendations` — 基于一篇论文推荐相似论文
- `get_author_details` — 获取作者信息（h-index、发表量）

### 4.2 arXiv MCP（预印本 · 最新研究前沿）

覆盖：物理、计算机科学、数学、统计学等领域的预印本，AI+教育相关论文常首发于此。

```bash
claude mcp add arxiv -s user -- uvx arxiv-mcp-server
```

**提供的能力：**
- 按关键词搜索 arXiv 论文
- 按学科分类浏览最新提交
- 获取论文摘要和元数据
- 下载 PDF 链接

### 4.3 Paper Search MCP（多源聚合 · 一站式搜索）

覆盖：同时搜索 arXiv、PubMed、bioRxiv、Semantic Scholar、Google Scholar、OpenAlex、Crossref、SSRN、DOAJ 等 20+ 数据库。

```bash
claude mcp add paper-search -s user -- uvx paper-search-mcp
```

**提供的能力：**
- `search_papers` — 多源并发搜索 + 自动去重
- `download_with_fallback` — 多源 PDF 下载（依次尝试开放获取链接）
- 各平台独立搜索工具（`search_arxiv`、`search_pubmed` 等）

> 这是覆盖面最广的学术 MCP，它整合了几乎所有主要学术数据库。

### 4.4 Zotero MCP（文献管理 · 双向同步）

```bash
# 安装
uv tool install zotero-mcp-server

# 自动配置（会检测你的 Zotero 并设置连接）
zotero-mcp setup
```

如果自动配置不成功，手动添加：

```bash
# 方式一：连接本地 Zotero（推荐，需要 Zotero 在运行）
claude mcp add zotero -s user \
  -e ZOTERO_LOCAL="true" \
  -- uvx zotero-mcp

# 方式二：连接 Zotero Web API（不需要 Zotero 运行）
claude mcp add zotero -s user \
  -e ZOTERO_API_KEY="你的密钥" \
  -e ZOTERO_LIBRARY_ID="你的库ID" \
  -- uvx zotero-mcp
```

获取 Zotero Web API 密钥和库 ID：
1. 访问 https://www.zotero.org/settings/keys
2. 创建新密钥，勾选所有权限
3. 库 ID 通过以下命令获取：
   ```bash
   curl -H "Zotero-API-Key: 你的密钥" https://api.zotero.org/keys/current
   ```
   返回的 `userID` 就是你的库 ID。

**提供的能力：**
- `zotero_search` — 在你的文献库中搜索
- `zotero_get_item` — 获取论文详细信息
- `zotero_get_fulltext` — 获取论文全文
- `zotero_get_annotations` — 提取你的 PDF 高亮和标注
- `zotero_add_item` — 向 Zotero 添加新论文
- `zotero_semantic_search` — AI 语义搜索你的文献库

### 4.5 Obsidian 文件系统 MCP（知识库读写）

```bash
claude mcp add obsidian-fs -s user -- \
  npx -y @modelcontextprotocol/server-filesystem \
  "$HOME/Obsidian-Vault"
```

> 注意：`$HOME` 会自动展开为你的用户目录。如果你的 Vault 路径不同，请修改。

**提供的能力：**
- 读取 Obsidian vault 中的任何 Markdown 文件
- 创建新笔记
- 编辑已有笔记
- 列出文件和目录
- 搜索文件内容

### 4.6 Brave Search MCP（网络搜索 · 灰色文献）

覆盖：网页、博客、政策文件、会议通知、教育报告等非学术资源。

```bash
claude mcp add brave-search -s user \
  -e BRAVE_API_KEY="你的密钥" \
  -- npx -y @modelcontextprotocol/server-brave-search
```

### 4.7 Sequential Thinking MCP（复杂推理辅助）

帮助 Claude 在复杂分析任务中进行更结构化的推理，适合文献综述、研究设计等需要深度思考的场景。

```bash
claude mcp add sequential-thinking -s user -- \
  npx -y @modelcontextprotocol/server-sequential-thinking
```

### 安装验证

全部安装完成后，验证连接状态：

```bash
# 列出所有已安装的 MCP
claude mcp list
```

然后启动 Claude Code 并检查：

```bash
cd ~/PhD-Research
claude

# 在 Claude Code 内部输入：
/mcp
```

你应该看到 7 个 MCP 全部显示 `connected`：

```
MCP Server Status
• semantic-scholar: connected
• arxiv: connected
• paper-search: connected
• zotero: connected
• obsidian-fs: connected
• brave-search: connected
• sequential-thinking: connected
```

---

## 第五章 CLAUDE.md 完整版

在 `~/PhD-Research/` 下创建 `CLAUDE.md` 文件。以下是完整内容，直接复制：

```markdown
# 教育学博士 AI 科研助手

## 我是谁

我是教育学博士研究生。研究方向：AI 在教育中的应用。

当前关注的具体领域（按优先级排列）：
1. 生成式 AI（LLM）在高等教育中的教学应用
2. AI 辅助个性化学习与自适应学习系统
3. 教师对 AI 工具的接受度、使用行为与专业发展
4. AI 素养教育的课程设计与评估
5. AI 在教育评估中的应用（自动评分、反馈生成）
6. 教育公平视角下的 AI 应用

## 工具生态

| 工具 | 路径 | 角色 |
|------|------|------|
| Claude Code | ~/PhD-Research/ | 分析引擎，在此目录启动 |
| Obsidian | ~/Obsidian-Vault/ | 知识沉淀，所有笔记存这里 |
| Zotero | Zotero 自管理 | 论文 PDF 存储与引用管理 |

## MCP 使用策略

- **搜索学术论文** → 优先用 Semantic Scholar，补充用 arXiv 和 Paper Search
- **搜索灰色文献**（政策、报告、博客） → 用 Brave Search
- **管理已有文献** → 用 Zotero MCP 读写我的文献库
- **读写笔记** → 用 obsidian-fs 读写 Obsidian vault
- **复杂推理** → 用 Sequential Thinking 辅助

## 沉淀铁律（每次任务必须遵守）

无论执行什么任务，只要产出了可沉淀的内容，都必须自动保存到 Obsidian。
不需要问我「要不要保存」，直接保存。

### 保存路径映射表

| 产出类型 | 保存路径 | 文件名格式 |
|---------|---------|-----------|
| 每日论文推荐 | ~/Obsidian-Vault/每日推荐/ | YYYY-MM-DD.md |
| 文献检索结果 | ~/Obsidian-Vault/文献检索/ | YYYY-MM-DD-{关键词}.md |
| 论文阅读笔记 | ~/Obsidian-Vault/论文笔记/ | {第一作者姓}-{年份}-{简短标题}.md |
| 灵感碰撞记录 | ~/Obsidian-Vault/灵感碰撞/ | YYYY-MM-DD-{主题}.md |
| 文献综述 | ~/Obsidian-Vault/文献综述/ | {主题名称}.md |
| 概念解释 | ~/Obsidian-Vault/概念卡片/ | {概念名称}.md |
| 研究设计/提纲 | ~/Obsidian-Vault/写作草稿/ | {文档标题}.md |

### 保存格式规范

每个保存的文件必须包含以下结构：

```
---
title: {标题}
date: {YYYY-MM-DD}
type: {论文笔记|灵感碰撞|文献综述|文献检索|概念卡片|每日推荐}
tags:
  - {自动生成的标签1}
  - {自动生成的标签2}
source: {来源信息}
---

{正文内容}

---
相关笔记：
- [[{已有笔记的链接1}]]
- [[{已有笔记的链接2}]]

沉淀时间：{完整时间戳}
```

### 双向链接规则

保存笔记时，扫描正文中出现的以下关键概念，如果 Obsidian vault 中已有对应的概念卡片或论文笔记，自动添加 [[双向链接]]：
- 教育学理论名称（建构主义、联通主义、TPACK 等）
- 研究方法名称（设计研究、扎根理论、混合方法等）
- 重要学者姓名
- 核心概念（AI素养、个性化学习、学习分析等）

## 语言与风格

- 默认用中文交流和输出笔记
- 搜索文献时自动将中文关键词翻译为英文学术术语
- 论文标题保留英文原文，摘要翻译为中文
- 学术术语首次出现时标注英文原文，如「建构主义（Constructivism）」
- 总结论文时保持学术严谨，不过度简化

## 可用 Skills

以下 Skill 位于 ~/PhD-Research/skills/ 目录下，执行相关任务时请先读取对应的 SKILL.md：

- **literature-search** → 文献检索助手
- **paper-summarizer** → 论文总结器
- **research-ideation** → 灵感碰撞器
- **lit-review-builder** → 文献综述构建器
```

> 注意：把上面的内容保存为 `~/PhD-Research/CLAUDE.md`。

---

## 第六章 Skill 技能包

### 6.1 文献检索助手

文件路径：`~/PhD-Research/skills/literature-search/SKILL.md`

```markdown
---
name: literature-search
description: >
  教育学学术文献的智能多源检索与分析。当用户提到搜索文献、查找论文、
  文献检索、research、找参考文献、有什么相关研究、最新论文、
  search papers、find studies 等关键词时触发。
  也适用于用户想了解某个话题的研究现状、某个领域最近发了什么论文时。
  即使用户没有明确说「搜索」，只要问了一个需要学术文献支撑的问题，
  也应该考虑使用此 Skill。
---

# 文献检索助手

你是教育学领域的资深文献检索专家。你的任务是帮助博士生快速、全面、精准地找到高质量学术文献。

## 检索流程

### 第一步：解析检索意图

分析用户的请求，确定：
- **核心研究问题**：用户到底想了解什么？
- **检索范围**：时间范围（默认最近 3 年）、学科领域、文献类型
- **检索深度**：快速浏览（5 篇）/ 标准检索（10 篇）/ 深度检索（20-30 篇）

如果用户的请求模糊，先给出你的理解并确认，不要盲目搜索。

### 第二步：构建多语言搜索查询

将用户的中文研究主题翻译为英文学术关键词，并构建多组查询：

参考关键词映射表（详见 references/keyword-mapping.md）

**查询构建策略：**
- 核心查询：最精确的关键词组合
- 扩展查询：同义词替换（如 AI → artificial intelligence → machine learning）
- 交叉查询：跨领域组合（如 education + NLP, pedagogy + LLM）

### 第三步：多源并发搜索

按以下优先级使用可用的 MCP 工具：

1. **Semantic Scholar**（首选）
   - 用 `paper_relevance_search` 按相关性搜索
   - 用 `paper_bulk_search` 按引用数排序获取高影响力论文
   - 优势：覆盖广、引用数据准确、支持推荐
   
2. **Paper Search MCP**（补充多源）
   - 用 `search_papers` 同时搜索 Google Scholar、OpenAlex、Crossref、SSRN 等
   - 优势：覆盖教育学专有数据库 ERIC、社科数据库 SSRN
   
3. **arXiv**（前沿补充）
   - 搜索最新预印本，特别是 cs.CY（计算与社会）、cs.AI、cs.CL 分类
   - 优势：最新研究，通常比正式发表早 6-12 个月

4. **Brave Search**（灰色文献）
   - 搜索会议论文集、政策报告、教育机构白皮书、教育博客
   - 搜索关键词加上 site:eric.ed.gov 可定向搜索 ERIC 数据库

### 第四步：智能筛选与排序

**去重规则**：通过 DOI 或标题相似度去重，保留元数据最完整的版本

**排序算法**（权重从高到低）：
1. 与用户研究问题的语义相关性（40%）
2. 发表时间新旧，优先近 3 年（25%）
3. 引用数量（15%）
4. 发表期刊等级（参考 references/education-journals.md）（10%）
5. 作者在该领域的影响力（10%）

**质量过滤**：
- 排除引用数 < 5 的论文（近 1 年内发表的除外）
- 排除预印本中超过 2 年仍未正式发表的
- 优先保留 SSCI 索引期刊的论文

### 第五步：结构化输出

对每篇推荐论文，按以下格式输出：

---
### 📄 [序号]. [英文标题]

**中文标题**：[翻译]

| 字段 | 信息 |
|------|------|
| 👤 作者 | [第一作者 et al., 年份] |
| 📊 引用数 | [数量] |
| 📰 期刊/来源 | [期刊名, 卷(期), 页码] |
| 🔗 DOI | [DOI 链接] |
| 📂 数据库 | [来自哪个数据库：Semantic Scholar / arXiv / ERIC 等] |

**摘要（中文）**：
[2-3 句话概括研究问题、方法和主要发现]

**与你的研究的关联**：
[1-2 句话说明为什么推荐这篇，与用户当前研究的关系]

**关键词**：#标签1 #标签2 #标签3

---

### 第六步：沉淀到 Obsidian（必须执行）

将检索结果保存到 Obsidian，按照 CLAUDE.md 中的沉淀铁律执行：

1. 路径：~/Obsidian-Vault/文献检索/
2. 文件名：{今天日期}-{检索主题关键词}.md
3. 包含 YAML frontmatter
4. 每篇论文标题添加 Obsidian 内部链接 [[论文标题]]，方便后续创建论文笔记时自动链接
5. 在文件末尾生成「推荐阅读顺序」——根据关联度排出建议阅读的先后顺序
6. 保存完成后告知用户文件路径

### 第七步：后续建议

检索完成后，主动提供：
- 「是否要我为其中某篇论文生成详细阅读笔记？」
- 「是否要我将这些论文添加到你的 Zotero 库？」
- 「基于这些文献，要不要做一次灵感碰撞？」
```

**关键词映射参考文件**：`~/PhD-Research/skills/literature-search/references/keyword-mapping.md`

```markdown
# 教育学中英关键词映射表

## AI + 教育核心术语

| 中文 | 英文关键词（用于搜索） | 同义/近义检索词 |
|------|----------------------|----------------|
| 人工智能教育 | AI in Education | AIEd, artificial intelligence in education |
| 生成式 AI | Generative AI | GenAI, large language models in education, ChatGPT in education |
| AI 素养 | AI Literacy | artificial intelligence literacy, AI competence |
| 个性化学习 | Personalized Learning | adaptive learning, individualized instruction |
| 学习分析 | Learning Analytics | educational data mining, LA |
| 智能辅导系统 | Intelligent Tutoring System | ITS, AI tutor, AI-powered tutoring |
| 自动评估 | Automated Assessment | automated grading, AI-based assessment, automated feedback |
| 计算思维 | Computational Thinking | CT, algorithmic thinking |
| 教师专业发展 | Teacher Professional Development | TPD, teacher training |
| 混合式学习 | Blended Learning | hybrid learning, HyFlex |
| 教育公平 | Educational Equity | digital divide, inclusive education |
| 自我调节学习 | Self-Regulated Learning | SRL, metacognition |
| 协作学习 | Collaborative Learning | CSCL, cooperative learning |
| 翻转课堂 | Flipped Classroom | inverted classroom |
| TPACK | TPACK | Technological Pedagogical Content Knowledge |
| 学术诚信 | Academic Integrity | plagiarism, AI-generated content detection |
| 多模态学习 | Multimodal Learning | multimedia learning |
| 人机协作 | Human-AI Collaboration | human-AI interaction, HAI |

## 研究方法术语

| 中文 | 英文 |
|------|------|
| 设计研究 | Design-Based Research, DBR |
| 混合方法 | Mixed Methods Research |
| 扎根理论 | Grounded Theory |
| 叙事研究 | Narrative Inquiry |
| 行动研究 | Action Research |
| 准实验设计 | Quasi-Experimental Design |
| 系统文献综述 | Systematic Literature Review, SLR |
| 元分析 | Meta-Analysis |
| 内容分析 | Content Analysis |
| 主题分析 | Thematic Analysis |
```

**教育学期刊参考文件**：`~/PhD-Research/skills/literature-search/references/education-journals.md`

```markdown
# 教育学与 AI+教育 核心期刊列表

## Tier 1 · 顶级期刊（SSCI Q1，优先推荐）

| 期刊名 | 缩写 | 影响因子(约) | 侧重 |
|--------|------|------------|------|
| Computers & Education | C&E | ~12 | 技术增强学习 |
| Internet and Higher Education | IHE | ~8 | 高等教育中的技术 |
| British Journal of Educational Technology | BJET | ~7 | 教育技术综合 |
| Learning and Instruction | L&I | ~6 | 学习科学 |
| Educational Technology Research & Development | ETR&D | ~5 | 教育技术研发 |
| International Journal of AI in Education | IJAIED | ~4 | AI 教育专刊 |
| Education and Information Technologies | EAIT | ~5 | 教育信息技术 |

## Tier 2 · 优秀期刊（SSCI Q1-Q2）

| 期刊名 | 侧重 |
|--------|------|
| Journal of Computer Assisted Learning (JCAL) | 计算机辅助学习 |
| Computers & Education: Artificial Intelligence | AI 教育专刊（新刊） |
| Educational Technology & Society (ET&S) | 教育技术与社会 |
| TechTrends | 教育技术趋势 |
| Journal of Educational Computing Research | 教育计算研究 |
| Interactive Learning Environments | 交互学习环境 |
| Technology, Knowledge and Learning | 技术知识与学习 |

## 顶级会议

| 会议 | 全称 | 频率 |
|------|------|------|
| AIED | Artificial Intelligence in Education | 年度 |
| LAK | Learning Analytics & Knowledge | 年度 |
| ICLS | International Conference of the Learning Sciences | 双年度 |
| AERA | American Educational Research Association | 年度 |
| SITE | Society for IT and Teacher Education | 年度 |
| EC-TEL | European Conference on Technology Enhanced Learning | 年度 |
| CSCL | Computer Supported Collaborative Learning | 双年度 |
```

### 6.2 论文总结器

文件路径：`~/PhD-Research/skills/paper-summarizer/SKILL.md`

```markdown
---
name: paper-summarizer
description: >
  深度总结和分析学术论文。当用户提到总结论文、读论文、paper summary、
  这篇论文说了什么、帮我读一下、分析这篇文章、论文笔记等关键词时触发。
  也适用于用户提供了论文标题、DOI、或 PDF 并希望获得结构化总结时。
  当用户说「总结 Zotero 里的某篇论文」或「读一下我标注的那篇」时也触发。
---

# 论文总结器

你是一位教育学领域的资深研究员，擅长快速抓住论文的核心贡献并评估其学术价值。

## 总结流程

### 第一步：获取论文信息

根据用户提供的线索获取论文内容：

- **如果提供了 DOI 或标题** → 用 Semantic Scholar 获取详细元数据
- **如果说「Zotero 里的某篇」** → 用 Zotero MCP 搜索并获取全文/标注
- **如果提供了 PDF 文件路径** → 直接读取文件内容
- **如果只给了模糊描述** → 先搜索确认是哪篇论文

优先获取的信息：标题、作者、年份、期刊、摘要、全文（如有）、用户在 Zotero 中的标注（如有）。

### 第二步：生成结构化总结

按以下模板生成总结笔记：

```
---
title: "{论文英文标题}"
title_cn: "{论文中文翻译标题}"
authors: ["{第一作者}", "{第二作者}"]
year: {年份}
journal: "{期刊名}"
doi: "{DOI}"
date: {今天日期}
type: 论文笔记
tags:
  - {自动标签1}
  - {自动标签2}
  - {自动标签3}
citation_count: {引用数}
rating: {你对这篇论文的质量评分 1-5}
relevance: {与用户研究方向的相关度 1-5}
---

## 一句话概括

{用一句中文概括这篇论文最核心的贡献，不超过 50 字}

## 研究背景与问题

{2-3 句话描述研究背景和具体研究问题/假设}

- 研究问题 1: {RQ1}
- 研究问题 2: {RQ2}（如果有）

## 理论框架

{使用了什么理论？为什么选择这个理论？}

关联理论：[[{理论名称}]]

## 研究方法

- **研究设计**：{定量/定性/混合方法/设计研究/...}
- **参与者**：{N=多少, 什么群体, 如何抽样}
- **数据收集**：{问卷/访谈/观察/学习日志/系统日志/...}
- **数据分析**：{统计方法/编码方法/...}
- **研究工具**：{使用的AI工具/平台/量表}

## 主要发现

1. {发现1：用中文清晰表述}
2. {发现2}
3. {发现3}

## 讨论与启示

### 理论贡献
{这篇论文对理论的推进}

### 实践启示
{对教育实践的意义}

### 局限性
{作者承认的局限}

## 与我的研究的关联

{结合 CLAUDE.md 中的研究方向，分析这篇论文与用户研究的关系}

- **可以借鉴的**：{方法/理论/框架}
- **可以补充的**：{这篇论文没做但用户可以做的}
- **需要注意的**：{方法论局限或适用范围}

## 值得追踪的参考文献

从这篇论文的参考文献中挑出 3-5 篇值得进一步阅读的：

1. [[{作者-年份-简短标题}]] — {为什么值得读}
2. [[{作者-年份-简短标题}]] — {为什么值得读}
3. [[{作者-年份-简短标题}]] — {为什么值得读}

## 我的 Zotero 标注摘录

{如果通过 Zotero MCP 获取到了用户的标注，在此处列出}

> {标注1} — 页码 p.{x}
> {标注2} — 页码 p.{x}
```

### 第三步：沉淀到 Obsidian（必须执行）

1. 保存路径：~/Obsidian-Vault/论文笔记/
2. 文件名：{第一作者姓}-{年份}-{3-5个英文关键词}.md
3. 扫描正文中的理论名称、方法名称、核心概念，添加 [[双向链接]]
4. 如果相关概念的概念卡片不存在，提示用户是否要创建
5. 向用户确认保存路径
```

### 6.3 灵感碰撞器

文件路径：`~/PhD-Research/skills/research-ideation/SKILL.md`

```markdown
---
name: research-ideation
description: >
  研究灵感碰撞与创意研究方向生成。当用户提到灵感、碰撞、brainstorm、
  研究方向、选题、研究空白、gap、创新点、想做什么研究、
  有什么可以研究的、给我一些思路、idea 等关键词时触发。
  也适用于用户表达困惑（如「不知道做什么方向」）或寻求研究突破时。
  当用户读完一批文献后想找新方向时也应该触发。
---

# 灵感碰撞器

你是一位善于跨学科思考、兼具教育学理论素养和 AI 技术视野的学术导师。
你的目标不是给出「安全」的建议，而是通过多维碰撞产生真正有创意的研究方向。

## 碰撞流程

### 第一步：锚定用户当前位置

了解（从 CLAUDE.md 和对话上下文推断，不要每次都问）：
- 已有的理论积累和方法论偏好
- 最近读了哪些论文（可通过 Obsidian MCP 查看最近的论文笔记）
- 导师的研究方向（如果提到过）
- 可用的数据源和研究资源

### 第二步：搜索最新研究动态

用 MCP 工具搜索：
1. Semantic Scholar：该主题最近 6 个月的高引论文
2. arXiv：最近 1 个月的预印本
3. Brave Search：相关学术会议最新议程、教育政策动态

### 第三步：五维碰撞矩阵

从以下五个维度交叉组合，寻找创新研究角度：

**维度 A：教育理论**
- 建构主义（Constructivism）
- 社会文化理论（Sociocultural Theory / Vygotsky）
- 联通主义（Connectivism / Siemens）
- 自我调节学习理论（Self-Regulated Learning）
- 认知负荷理论（Cognitive Load Theory）
- 社会认知理论（Social Cognitive Theory / Bandura）
- 技术接受模型（TAM / UTAUT）
- TPACK 框架
- 社区探究模型（Community of Inquiry）
- 活动理论（Activity Theory）
- 变革学习理论（Transformative Learning / Mezirow）

**维度 B：AI 技术**
- 大语言模型（LLM/GPT/Claude）
- 多模态 AI（视觉+语言）
- AI Agent（自主代理）
- RAG（检索增强生成）
- 微调与适配（Fine-tuning）
- 提示工程（Prompt Engineering）
- AI 生成内容检测
- 教育专用模型（EduLLM）

**维度 C：教育场景**
- K-12 基础教育
- 高等教育（本科/研究生）
- 职业教育与培训
- 教师教育与专业发展
- 特殊教育与融合教育
- 语言学习（L2/EFL）
- STEM 教育
- 人文社科教育
- 终身学习 / 非正式学习

**维度 D：研究方法**
- 设计研究（DBR）
- 混合方法（Sequential/Concurrent）
- 学习分析与教育数据挖掘
- 多模态分析（话语+手势+系统日志）
- 纵向追踪研究
- 比较研究（跨文化/跨制度）
- 系统文献综述 + 元分析

**维度 E：社会议题**
- 教育公平与数字鸿沟
- AI 伦理与学术诚信
- 隐私与数据安全
- 教师职业身份与角色转变
- 学生心理健康与福祉
- 全球南方的教育技术
- 政策与治理

### 第四步：生成研究方向

对每个推荐的研究方向，输出以下格式：

---
### 💡 方向 [编号]：[简短标题]

**碰撞来源**：[维度A的什么] × [维度B的什么] × [维度C的什么]

**研究问题**：
- RQ1: {具体的、可操作的研究问题}
- RQ2: {可选}

**理论基础**：
{支撑这个问题的理论，为什么这个理论视角有新意}

**为什么值得研究**：
- 🔬 学术空白：{现有研究缺失了什么}
- 🌍 实践价值：{对教育实践的意义}
- ⏰ 时效性：{为什么现在做正当时}

**可行的研究设计**：
- 方法：{具体的研究方法}
- 数据来源：{从哪里获取数据}
- 样本：{建议的参与者类型和数量}
- 预计周期：{需要多长时间}

**风险评估**：⭐⭐⭐☆☆（1-5 星，星越多越可行）
- 主要风险：{可能遇到的困难}
- 应对策略：{如何规避}

**种子文献**：
- {推荐的 2-3 篇必读论文，用 [[双向链接]] 格式}
---

### 第五步：交叉碰撞

选取上面最有潜力的 2-3 个方向，两两交叉组合，看看能否产生更有创意的第二层方向。

### 第六步：沉淀到 Obsidian（必须执行）

1. 保存路径：~/Obsidian-Vault/灵感碰撞/
2. 文件名：{今天日期}-{碰撞主题}.md
3. 每个方向的种子文献添加 [[双向链接]]
4. 为碰撞中涉及的理论添加 [[理论名称]] 链接
5. 确认保存
```

### 6.4 文献综述构建器

文件路径：`~/PhD-Research/skills/lit-review-builder/SKILL.md`

```markdown
---
name: lit-review-builder
description: >
  系统性文献综述的构建与组织。当用户提到文献综述、literature review、
  综述、研究现状、研究综述、梳理文献、整理文献、
  这个领域的研究进展、state of the art 等关键词时触发。
  也适用于用户准备写论文的文献综述章节时。
---

# 文献综述构建器

你是一位有丰富发表经验的教育学研究者，擅长构建结构清晰、论证有力的文献综述。

## 构建流程

### 第一步：确定综述范围

与用户确认：
- 综述主题和具体焦点
- 时间范围（默认最近 5 年，经典文献不限）
- 目的：博士论文章节 / 独立综述论文 / 研究提案背景
- 预期文献数量：30-50 篇（标准）/ 50-100 篇（深度）

### 第二步：系统检索

使用所有可用的学术 MCP，按以下策略检索：

1. **核心检索**：在 Semantic Scholar 用 3-5 组关键词搜索
2. **滚雪球**：对核心论文做引用追踪（cited by + references）
3. **作者追踪**：查找核心作者的其他相关论文
4. **补充检索**：用 Paper Search MCP 搜索 ERIC、SSRN 等教育学专有数据库
5. **前沿扫描**：在 arXiv 搜索最新预印本

### 第三步：文献分类与主题提取

将搜集到的文献按**主题**（而非时间或作者）分类。典型的分类维度：

- 按研究问题分
- 按理论视角分
- 按方法论分
- 按研究对象/场景分
- 按研究结论的立场分（支持/反对/混合）

### 第四步：生成综述框架

输出结构化的文献综述大纲：

```
## [综述标题]

### 1. 引言
- 主题的重要性和背景（2-3 段）
- 现有综述的不足（为什么需要这篇综述）
- 本综述的范围和组织方式

### 2. [主题板块 1 名称]
- 核心论点概述（1 段）
- 关键文献 1-N 的贡献和发现
- 板块内的共识与分歧
- 小结

### 3. [主题板块 2 名称]
（同上结构）

### 4. [主题板块 N 名称]
（同上结构）

### 5. 研究空白与未来方向
- 已识别的研究空白 1
- 已识别的研究空白 2
- 未来研究建议

### 6. 结论

### 参考文献
（APA 7 格式）
```

### 第五步：生成文献对照表

创建一个结构化的文献对照表，帮助用户快速把握全貌：

| 作者(年) | 研究问题 | 理论框架 | 方法 | 样本 | 主要发现 | 与我的关联 |
|---------|---------|---------|------|------|---------|-----------|
| ... | ... | ... | ... | ... | ... | ... |

### 第六步：沉淀到 Obsidian（必须执行）

1. 保存路径：~/Obsidian-Vault/文献综述/
2. 文件名：{综述主题名称}.md
3. 每篇引用的论文都添加 [[双向链接]]
4. 文献对照表单独保存或嵌入综述文件
5. 在综述中识别的研究空白同步到灵感碰撞文件夹（如果产生了新方向建议）
```

---

## 第七章 斜杠命令

在 `~/PhD-Research/.claude/commands/` 下创建以下文件：

### 7.1 /daily · 每日科研流程

文件：`daily.md`

```markdown
今天是新的一天。请执行每日科研流程：

## 第一部分：每日论文推荐

1. 用 Semantic Scholar 搜索过去 48 小时关于以下主题的新发表论文：
   - "generative AI" AND "education"
   - "large language model" AND ("teaching" OR "learning")
   - "AI literacy" AND "higher education"
   - "ChatGPT" AND ("assessment" OR "pedagogy")
2. 用 arXiv 搜索 cs.CY 和 cs.AI 分类中与教育相关的最新预印本
3. 从搜索结果中筛选最相关的 5 篇论文
4. 对每篇提供：标题、作者、来源、50 字中文摘要、与我研究的关联度（1-5 星）
5. 保存到 ~/Obsidian-Vault/每日推荐/{今天日期}.md

## 第二部分：回顾与提醒

6. 检查 ~/Obsidian-Vault/论文笔记/ 中最近 3 天的笔记，看是否有标记为「待补充」的内容
7. 检查 ~/Obsidian-Vault/灵感碰撞/ 中最近的记录，提醒我有哪些未跟进的方向

## 第三部分：今日灵感

8. 基于今天推荐的论文和最近的研究积累，给我一句灵感提示（一个值得思考的研究问题或角度）

完成后告诉我今天推荐文件的路径和总结。
```

### 7.2 /search-papers · 文献搜索

文件：`search-papers.md`

```markdown
请先读取 skills/literature-search/SKILL.md，然后按照其中的流程为我搜索学术文献。

搜索主题：$ARGUMENTS

如果我没有指定时间范围，默认搜索最近 3 年。
如果我没有指定数量，默认返回 10 篇。

搜索完成后，自动保存到 Obsidian 并询问我是否需要进一步操作。
```

### 7.3 /summarize · 论文总结

文件：`summarize.md`

```markdown
请先读取 skills/paper-summarizer/SKILL.md，然后为我生成论文阅读笔记。

论文信息：$ARGUMENTS

如果我提供的是论文标题，请先搜索确认具体是哪篇论文。
如果我说的是「Zotero 里的某篇」，请通过 Zotero MCP 搜索。
如果我提供的是 DOI，直接用 Semantic Scholar 获取信息。

生成完成后自动保存到 Obsidian。
```

### 7.4 /brainstorm · 灵感碰撞

文件：`brainstorm.md`

```markdown
请先读取 skills/research-ideation/SKILL.md，然后围绕以下主题进行灵感碰撞。

碰撞主题：$ARGUMENTS

请至少生成 5 个具体的研究方向建议，并进行交叉碰撞。
碰撞完成后自动保存到 Obsidian。
```

### 7.5 /lit-review · 文献综述

文件：`lit-review.md`

```markdown
请先读取 skills/lit-review-builder/SKILL.md，然后为以下主题构建文献综述框架。

综述主题：$ARGUMENTS

请先确认综述的范围和深度，然后系统性地检索和组织文献。
完成后保存到 Obsidian。
```

### 7.6 /weekly-report · 周报

文件：`weekly-report.md`

```markdown
请生成本周的科研周报。

## 执行步骤

1. 扫描 ~/Obsidian-Vault/ 中过去 7 天修改或创建的所有文件
2. 统计：
   - 本周阅读/总结的论文数量
   - 新增的概念卡片
   - 灵感碰撞次数
   - 文献检索次数
3. 梳理本周的主要收获（基于论文笔记和灵感碰撞记录）
4. 识别本周出现频率最高的研究主题和关键词
5. 与上周对比（如果有上周的周报）
6. 提出下周的建议关注方向
7. 保存到 ~/Obsidian-Vault/每日笔记/{今天日期}-周报.md
```

---

## 第八章 Obsidian 配置与模板

### 8.1 Obsidian 笔记模板

在 `~/Obsidian-Vault/模板/` 下创建以下模板文件：

**论文笔记模板** · `模板/论文笔记模板.md`

```markdown
---
title: ""
title_cn: ""
authors: []
year: 
journal: ""
doi: ""
date: {{date:YYYY-MM-DD}}
type: 论文笔记
tags: []
citation_count: 
rating: 
relevance: 
---

## 一句话概括



## 研究背景与问题



## 理论框架



## 研究方法

- **研究设计**：
- **参与者**：
- **数据收集**：
- **数据分析**：

## 主要发现

1. 
2. 
3. 

## 讨论与启示



## 与我的研究的关联



## 值得追踪的参考文献

1. 
2. 
3. 

---
相关笔记：

沉淀时间：{{date:YYYY-MM-DD HH:mm}}
```

**概念卡片模板** · `模板/概念卡片模板.md`

```markdown
---
title: ""
date: {{date:YYYY-MM-DD}}
type: 概念卡片
tags: []
aliases: []
---

## 定义

{用一段话定义这个概念，标注提出者和年份}

## 核心要素

1. 
2. 
3. 

## 在教育学中的应用



## 与 AI 教育的关联



## 代表性文献

- [[]]
- [[]]

## 相关概念

- [[]]
- [[]]

---
沉淀时间：{{date:YYYY-MM-DD HH:mm}}
```

**每日推荐模板** · `模板/每日推荐模板.md`

```markdown
---
title: "每日论文推荐 {{date:YYYY-MM-DD}}"
date: {{date:YYYY-MM-DD}}
type: 每日推荐
tags:
  - 每日推荐
---

## 今日推荐论文

{由 Claude 自动填充}

## 今日灵感

{由 Claude 自动填充}

---
生成时间：{{date:YYYY-MM-DD HH:mm}}
```

### 8.2 Obsidian 推荐设置

在 Obsidian 设置中：

- **文件与链接 → 新建笔记的存放位置**：设为「指定的文件夹」→ 选择根目录
- **文件与链接 → 内部链接类型**：设为「尽可能简短」
- **编辑器 → 默认编辑模式**：设为「所见即所得」（对新手友好）
- **核心插件 → 日记**：开启，设置日记文件夹为 `每日笔记`
- **核心插件 → 标签面板**：开启
- **核心插件 → 关系图谱**：开启（可视化知识网络）

---

## 第九章 Zotero 配置

### 9.1 Zotero 内部设置

1. **设置 → 高级 → 勾选「允许其他应用程序与 Zotero 通信」**
2. **设置 → 同步 → 配置 Zotero 同步**（推荐，多设备同步）
3. **Better BibTeX → 引用键格式**：设为 `auth.lower + year + shorttitle(3,3)`
   - 这样每篇论文会有一个唯一的引用键如 `wang2024generative`

### 9.2 推荐的 Zotero 分类结构

在 Zotero 中创建以下文献集（Collection）：

```
我的文献库
├── AI in Education（AI 教育总库）
│   ├── LLM & Teaching（大语言模型与教学）
│   ├── AI Literacy（AI 素养）
│   ├── Personalized Learning（个性化学习）
│   ├── Assessment & AI（评估与AI）
│   ├── Teacher & AI（教师与AI）
│   └── Ethics & Equity（伦理与公平）
├── Methodology（研究方法参考）
├── Theory（理论框架参考）
├── To Read（待读）
└── Key Papers（核心文献，反复引用的）
```

### 9.3 Zotero + Claude Code 工作流

```
你在 Claude Code 中说：
  「帮我把今天搜到的 5 篇论文添加到 Zotero」

Claude 通过 Zotero MCP：
  → zotero_add_item 添加每篇论文的元数据
  → 论文被自动归入正确的文献集

你在 Zotero 中：
  → 下载 PDF（Zotero 自动查找开放获取版本）
  → 阅读并做高亮标注

回到 Claude Code 中说：
  「/summarize Zotero 里最近添加的那篇关于 AI literacy 的论文」

Claude 通过 Zotero MCP：
  → zotero_search 找到论文
  → zotero_get_annotations 读取你的标注
  → 生成结构化总结
  → 通过 obsidian-fs MCP 保存到 Obsidian
```

---

## 第十章 自动化与定时任务

### 10.1 方案一：cron 全自动（推荐有经验用户）

创建自动化脚本：`~/PhD-Research/scripts/daily-recommend.sh`

```bash
#!/bin/bash
# ============================================
# 每日论文推荐自动化脚本
# 每天早上 9 点由 cron 触发
# ============================================

LOG_FILE="$HOME/PhD-Research/outputs/daily-$(date +%Y%m%d).log"

echo "=== 每日论文推荐 $(date) ===" >> "$LOG_FILE"

cd "$HOME/PhD-Research" || exit 1

claude -p "
执行每日论文推荐流程：
1. 搜索过去 48 小时关于 AI in education, LLM in teaching, AI literacy 的新论文
2. 从 Semantic Scholar 和 arXiv 各搜索一轮
3. 筛选最相关的 5 篇
4. 为每篇写 50 字中文摘要和关联度评分
5. 保存到 ~/Obsidian-Vault/每日推荐/$(date +%Y-%m-%d).md
6. 如果有引用数 > 50 的新论文，在文件开头标注【重要】
" --dangerously-skip-permissions >> "$LOG_FILE" 2>&1

echo "=== 完成 $(date) ===" >> "$LOG_FILE"
```

设置执行权限和 cron：

```bash
# 设置执行权限
chmod +x ~/PhD-Research/scripts/daily-recommend.sh

# 编辑 cron 定时任务
crontab -e

# 添加以下行（每天早上 9 点执行）：
0 9 * * * $HOME/PhD-Research/scripts/daily-recommend.sh
```

### 10.2 方案二：/loop 会话内定时

在 Claude Code 会话中输入：

```
/loop 24h 执行每日论文推荐：搜索 AI+教育最新论文，筛选 5 篇，写中文摘要，保存到 Obsidian 每日推荐文件夹
```

> 注意：会话关闭后任务消失。适合白天工作时保持 Claude Code 开着的场景。

### 10.3 方案三：/daily 半自动（推荐新手）

每天打开终端后：

```bash
cd ~/PhD-Research
claude

# 然后输入：
/daily
```

一键触发所有每日流程。这是最可控、最不容易出错的方式。

---

## 第十一章 日常使用手册

### 快速参考卡

| 我想做什么 | 输入什么 |
|-----------|---------|
| 开始一天的科研 | `/daily` |
| 搜索某个主题的论文 | `/search-papers AI对教师角色的影响` |
| 总结一篇论文 | `/summarize 10.1016/j.compedu.2024.xxxxx` |
| 总结 Zotero 里的论文 | `/summarize Zotero 里最近那篇关于 AI literacy 的` |
| 灵感碰撞 | `/brainstorm 生成式AI如何改变高等教育写作教学` |
| 构建文献综述 | `/lit-review AI辅助个性化学习的研究进展` |
| 生成周报 | `/weekly-report` |
| 直接提问 | 直接用自然语言问，不需要命令 |

### 典型的一周工作流

```
周一：
  /daily → 浏览推荐 → 挑 2 篇精读 → /summarize 生成笔记

周二：
  /daily → 继续精读 → 发现有趣方向 → /brainstorm 碰撞

周三：
  /search-papers 针对碰撞结果的具体方向深入搜索
  → /summarize 生成笔记

周四：
  /daily → 整理本周读的论文 → 开始写作

周五：
  /lit-review 构建某个小主题的文献综述
  → /weekly-report 生成周报
```

---

## 附录

### A. 故障排查

| 问题 | 解决方案 |
|------|---------|
| `claude: command not found` | 重新运行 `npm install -g @anthropic-ai/claude-code` |
| MCP 显示 disconnected | 运行 `claude mcp list` 检查配置，确认相关服务在运行 |
| Zotero MCP 连不上 | 确认 Zotero 已打开且「允许其他应用通信」已勾选 |
| Obsidian 笔记没保存成功 | 检查路径是否正确：`ls ~/Obsidian-Vault/` |
| `uvx: command not found` | 重新安装 uv：`curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| cron 任务不执行 | 检查 PATH：在 crontab 顶部加 `PATH=/usr/local/bin:/usr/bin:/bin` |
| Semantic Scholar 搜索太慢 | 申请 API 密钥提高速率限制 |

### B. 所有 MCP 安装命令汇总（一键复制）

```bash
# ============================================
# 一键安装所有 MCP 服务器
# 在终端中按顺序执行（不是在 Claude Code 内部）
# ============================================

# 1. Semantic Scholar（学术搜索核心）
claude mcp add semantic-scholar -s user -- uvx semantic-scholar-fastmcp

# 2. arXiv（预印本前沿）
claude mcp add arxiv -s user -- uvx arxiv-mcp-server

# 3. Paper Search（多源聚合搜索）
claude mcp add paper-search -s user -- uvx paper-search-mcp

# 4. Zotero（文献管理）
claude mcp add zotero -s user -e ZOTERO_LOCAL="true" -- uvx zotero-mcp

# 5. Obsidian 文件系统（知识库）
claude mcp add obsidian-fs -s user -- npx -y @modelcontextprotocol/server-filesystem "$HOME/Obsidian-Vault"

# 6. Brave Search（网络搜索，需要 API 密钥）
# claude mcp add brave-search -s user -e BRAVE_API_KEY="你的密钥" -- npx -y @modelcontextprotocol/server-brave-search

# 7. Sequential Thinking（复杂推理）
claude mcp add sequential-thinking -s user -- npx -y @modelcontextprotocol/server-sequential-thinking

# 验证
claude mcp list
```

### C. 完整文件清单

以下是你需要创建的所有文件（共 16 个）：

```
~/PhD-Research/CLAUDE.md                              ← 第五章
~/PhD-Research/skills/literature-search/SKILL.md       ← 第六章 6.1
~/PhD-Research/skills/literature-search/references/keyword-mapping.md  ← 第六章 6.1
~/PhD-Research/skills/literature-search/references/education-journals.md ← 第六章 6.1
~/PhD-Research/skills/paper-summarizer/SKILL.md        ← 第六章 6.2
~/PhD-Research/skills/research-ideation/SKILL.md       ← 第六章 6.3
~/PhD-Research/skills/lit-review-builder/SKILL.md      ← 第六章 6.4
~/PhD-Research/.claude/commands/daily.md               ← 第七章 7.1
~/PhD-Research/.claude/commands/search-papers.md       ← 第七章 7.2
~/PhD-Research/.claude/commands/summarize.md           ← 第七章 7.3
~/PhD-Research/.claude/commands/brainstorm.md          ← 第七章 7.4
~/PhD-Research/.claude/commands/lit-review.md          ← 第七章 7.5
~/PhD-Research/.claude/commands/weekly-report.md       ← 第七章 7.6
~/PhD-Research/scripts/daily-recommend.sh              ← 第十章
~/Obsidian-Vault/模板/论文笔记模板.md                   ← 第八章
~/Obsidian-Vault/模板/概念卡片模板.md                   ← 第八章
~/Obsidian-Vault/模板/每日推荐模板.md                   ← 第八章
```

### D. 学习路径

```
第 1 天：安装所有软件（第二章）→ 创建目录（第三章）
第 2 天：安装所有 MCP（第四章）→ 验证连接
第 3 天：复制 CLAUDE.md（第五章）→ 创建 Skills（第六章）
第 4 天：创建斜杠命令（第七章）→ 配置 Obsidian 模板（第八章）
第 5 天：配置 Zotero（第九章）→ 设置自动化（第十章）
第 6 天起：正式使用，参考日常手册（第十一章）
```

### E. 资源链接

| 资源 | 地址 |
|------|------|
| Claude Code 官方文档 | https://docs.claude.com/en/docs/claude-code/overview |
| MCP 协议官网 | https://modelcontextprotocol.io |
| MCP 服务器目录 | https://www.pulsemcp.com |
| Semantic Scholar API | https://api.semanticscholar.org |
| Zotero MCP GitHub | https://github.com/54yyyu/zotero-mcp |
| Obsidian 官网 | https://obsidian.md |
| Obsidian Claude Code MCP 插件 | https://github.com/iansinnott/obsidian-claude-code-mcp |
| Brave Search API | https://brave.com/search/api/ |

---

> **最后提醒**：这套系统的核心理念是「三角循环」：
> **Zotero 收集原料（论文）→ Claude Code 加工分析 → Obsidian 沉淀知识**。
> 三者通过 MCP 自动互通，你只需要用自然语言下达指令。
> 随着使用，你的 Obsidian 知识网络会越来越密，灵感碰撞会越来越精准。
