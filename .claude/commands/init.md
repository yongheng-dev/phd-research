You are running the Scholar Flow setup wizard. Your job is to conduct an interactive interview with the user, then generate a fully personalized research environment based on their answers.

Follow these phases exactly. Be conversational but efficient — the whole process should take about 5 minutes.

---

## Pre-Flight Checks

Before starting the interview:

1. Check if `.scholar-flow.yaml` exists in the project root.
   - If it exists, read it and tell the user: "I found an existing Scholar Flow configuration. Would you like to **update** it (I'll use your current settings as defaults), or **start fresh**?"
   - If updating, pre-fill all answers from the existing config. Only ask about things the user wants to change.

2. Check if there's a `CLAUDE.md` that contains Chinese characters (e.g., "教育学", "沉淀铁律"). This indicates a legacy setup.
   - If detected: "I see you have an existing setup from a previous version. I'll back up your current files and preserve your notes."
   - Rename: `CLAUDE.md` → `CLAUDE.md.v0`, `.mcp.json` → `.mcp.json.v0` (only if they exist and aren't already backed up)

---

## Phase 1: Research Profile

Ask these questions one at a time. Wait for each answer before proceeding.

**Q1: Research Field**
"Welcome to Scholar Flow! Let's set up your personalized AI research environment."
"What is your research field? (e.g., education, computer science, psychology, biomedical science, economics, linguistics, sociology)"

After they answer, check if `domains/{field}/domain.yaml` exists (normalize the field name to lowercase, replace spaces with hyphens).
- If found: "We have a pre-built knowledge pack for {field}."
- If not found: "I'll generate a custom knowledge pack for {field} during setup."

**Q2: Specific Topics**
"What specific topics or subfields are you focused on? (comma-separated)"
Give 2-3 examples relevant to the field they chose.

**Q3: Academic Level**
"What is your academic level? (undergraduate / master's / PhD / postdoc / faculty)"

**Q4: Preferred Language**
"What language do you prefer for notes and interaction? (default: English)"

---

## Phase 2: Tool Ecosystem

**Q5: Obsidian**
"Do you use Obsidian for knowledge management? (yes / no / help me set it up)"

If **yes**:
- Try to detect the vault path. Run `ls -d ~/Obsidian* ~/Documents/Obsidian* 2>/dev/null` to find candidates.
- If found: "I detected a vault at {path}. Is this correct?"
- If not found: "Where is your Obsidian vault? Please provide the full path."
- Then present default folder names based on their language:
  - English: Paper Notes, Concept Cards, Ideation Sessions, Literature Reviews, Search Results, Daily Picks, Writing Drafts, Daily Notes, Templates, Attachments
  - Chinese: 论文笔记, 概念卡片, 灵感碰撞, 文献综述, 文献检索, 每日推荐, 写作草稿, 每日笔记, 模板, 附件
- Ask: "Here are the default folder names. Want to customize any? (or press enter to accept defaults)"

If **no**:
- "No problem. Notes will be saved to a local `notes/` directory in this project. You can switch to Obsidian anytime by re-running `/init`."
- Set notes_fallback = true

If **help me set it up**:
- "Download Obsidian from https://obsidian.md (it's free). Create a new vault anywhere you like (e.g., ~/Obsidian-Vault). Then tell me the path."

**Q6: Zotero**
"Do you use Zotero for reference management? (yes / no / help me set it up)"

If yes: enable Zotero MCP.
If help: "Download Zotero 7 from https://www.zotero.org. After installation, come back and re-run `/init` to enable the integration."

---

## Phase 3: API Keys & MCP Servers

Walk through each service. Be concise.

"Let me configure your research tools. I'll go through each one quickly."

**Semantic Scholar** (academic paper search):
"Semantic Scholar API key is optional but improves rate limits. Do you have one? (yes / no / skip)"
- If yes: "Set it as an environment variable: `export SEMANTIC_SCHOLAR_API_KEY=your_key`"
- If no: "You can get a free key at https://www.semanticscholar.org/product/api — or skip for now. It works without a key, just slower."
- Always enable this server regardless of key.

**Brave Search** (gray literature — reports, blogs, policies):
"Brave Search requires an API key for gray literature search. Do you have one? (yes / no / skip)"
- If yes: "Set it as an environment variable: `export BRAVE_SEARCH_API_KEY=your_key`"
- If no: "Get one at https://brave.com/search/api/ — or skip to disable gray literature search."
- Only enable if they have a key or want it.

**Auto-enabled (no keys needed)**:
"These tools need no API keys and are enabled automatically: arXiv (preprints), Sequential Thinking (complex reasoning)."

Zotero and Obsidian-fs: auto-enable based on Phase 2 answers.

---

## Phase 4: Domain Pack

Check if a domain pack exists for the user's field at `domains/{field}/`.

**If it exists**: Read `domains/{field}/domain.yaml` and confirm:
"Using the {field} domain pack. It includes {N} theoretical frameworks, {N} research methods, and a curated journal list."

**If it does NOT exist**: Generate a complete domain pack. Create the directory `domains/{field}/` and write these files:

1. `domain.yaml` — Field name, description, and 8-12 core topics
2. `theories.yaml` — 8-12 major theoretical frameworks for the field, each with `name` and `description`
3. `methods.yaml` — 6-8 common research methods, each with `name` and `description`
4. `topics.yaml` — 8-10 subfields/application areas, each with `name` and `description`
5. `social-issues.yaml` — 5-7 relevant societal dimensions, each with `name` and `description`
6. `journals.md` — Tiered journal list: Tier 1 (~7 top journals with impact factor and focus), Tier 2 (~8 good journals), Top Conferences (~8)
7. `keyword-mapping.md` — Search term synonyms. If user's language is not English, include bilingual mapping table.

After generating, briefly show what was created and ask: "Does this look right? Want me to adjust anything?"

---

## Phase 5: File Generation

Now generate all personalized files. Read each template, substitute placeholders, and write the output.

### 5.1: Write `.scholar-flow.yaml`

Write the config file with all collected answers. Use the structure from `.scholar-flow.example.yaml` as reference.

### 5.2: Generate `CLAUDE.md`

Read `templates/CLAUDE.md.tmpl`. Substitute all `{{PLACEHOLDERS}}`:

| Placeholder | Value |
|-------------|-------|
| `{{RESEARCH_FIELD}}` | User's research field (capitalized) |
| `{{DEGREE_LEVEL}}` | User's academic level |
| `{{TOPICS_LIST}}` | Comma-separated topics |
| `{{NOTES_BASE}}` | Vault path (e.g., `~/Obsidian-Vault`) or `./notes` |
| `{{NOTES_TARGET}}` | "Obsidian" or "the local notes directory" |
| `{{FOLDERS.paper_notes}}` | Configured folder name for paper notes |
| `{{FOLDERS.concept_cards}}` | Configured folder name for concept cards |
| `{{FOLDERS.ideation}}` | Configured folder name for ideation sessions |
| `{{FOLDERS.lit_reviews}}` | Configured folder name for literature reviews |
| `{{FOLDERS.search_results}}` | Configured folder name for search results |
| `{{FOLDERS.daily_picks}}` | Configured folder name for daily picks |
| `{{FOLDERS.writing}}` | Configured folder name for writing drafts |
| `{{FOLDERS.daily_notes}}` | Configured folder name for daily notes |
| `{{FOLDERS.templates}}` | Configured folder name for templates |
| `{{FOLDERS.attachments}}` | Configured folder name for attachments |
| `{{DOMAIN_PACK}}` | Domain pack directory name |
| `{{LANGUAGE}}` | User's preferred language |
| `{{LANGUAGE_RULES}}` | Language instructions (see below) |
| `{{OBSIDIAN_ROW}}` | If Obsidian enabled: `\| Obsidian \| \`{vault_path}\` \| Knowledge base \|` else empty |
| `{{ZOTERO_ROW}}` | If Zotero enabled: `\| Zotero \| Zotero-managed \| PDF storage and citation management \|` else empty |
| `{{BRAVE_SEARCH_LINE}}` | If Brave enabled: `- **Search gray literature** → Use Brave Search` else empty |
| `{{ZOTERO_LINE}}` | If Zotero enabled: `- **Manage references** → Use Zotero MCP` else empty |
| `{{OBSIDIAN_LINE}}` | If Obsidian enabled: `- **Read/write notes** → Use obsidian-fs MCP` else `- **Read/write notes** → Use local filesystem` |
| `{{OBSIDIAN_STRUCTURE}}` | Vault path in structure diagram |

**Language rules** by language:
- English: "Communicate in English. Academic terms need no special annotation."
- Chinese: "Default to Chinese for communication and notes. Academic terms should include English on first use, e.g., 'self-regulated learning (SRL)'. Paper titles stay in English. Abstracts are translated to Chinese."
- Other: "Communicate in {language}. Academic terms should include English on first use. Paper titles stay in English."

Write the rendered CLAUDE.md to the project root.

### 5.3: Generate `.mcp.json`

Read `templates/mcp.json.tmpl` for reference. Build a JSON object with only the enabled MCP servers:

- `semantic-scholar`: Always include. Add `SEMANTIC_SCHOLAR_API_KEY` to env if user has one.
- `arxiv`: Always include.
- `paper-search`: Always include.
- `zotero`: Include only if Zotero enabled. Set `ZOTERO_LOCAL: "true"`.
- `obsidian-fs`: Include only if Obsidian enabled. Set the vault path in args.
- `sequential-thinking`: Always include.
- `brave-search`: Include only if Brave Search enabled. Set API key in env.

Write valid JSON to `.mcp.json`.

### 5.4: Generate `.claude/settings.json`

Read `templates/settings.json.tmpl` for reference. Build a JSON object with `allowedTools` array:
- Always include: `Bash(*)`, `WebSearch`, `WebFetch`
- If Obsidian enabled: include all `mcp__obsidian-fs__*` tools
- Always include: `mcp__sequential-thinking__sequentialthinking`

Write to `.claude/settings.json`.

### 5.5: Generate Slash Commands

For each template in `templates/commands/`:
1. Read the template file
2. Substitute all `{{PLACEHOLDERS}}` with user's config values
3. Write to `.claude/commands/{name}.md` (remove the `.tmpl` extension)

Commands to generate: daily.md, search-papers.md, summarize.md, brainstorm.md, lit-review.md, concept.md, weekly-report.md

IMPORTANT: Do NOT overwrite `.claude/commands/init.md` (this file).

### 5.6: Generate Skills

For each template in `templates/skills/*/`:
1. Read the `SKILL.md.tmpl` file
2. Substitute all `{{PLACEHOLDERS}}`
3. Create `.agents/skills/{name}/SKILL.md`
4. Copy relevant domain pack files to `.agents/skills/{name}/references/`:
   - `literature-search` gets: `keyword-mapping.md`, `journals.md` from the domain pack
   - `research-ideation` gets: `theories.yaml`, `methods.yaml`, `topics.yaml`, `social-issues.yaml` from the domain pack
   - All other skills get: `domain.yaml` from the domain pack

Skills to generate: literature-search, paper-summarizer, research-ideation, lit-review-builder, concept-explainer

### 5.7: Generate Agent

Read `templates/agents/deep-dive.md.tmpl`, substitute placeholders, write to `.claude/agents/deep-dive.md`.

### 5.8: Set Up Notes Directory

If Obsidian enabled:
- Create all configured folders in the vault using mkdir (or obsidian-fs MCP if available)
- Copy rendered note templates from `templates/obsidian/` to the vault's Templates folder

If Obsidian disabled:
- Create `notes/` directory with subdirectories for each configured folder (use kebab-case: `paper-notes/`, `concept-cards/`, etc.)

---

## Phase 6: Verification

Test each enabled MCP server with a simple call:

- **Semantic Scholar**: Call `paper_relevance_search` with query "machine learning" limit 1
- **arXiv**: Call `search_papers` with a simple query
- **Zotero**: Call `zotero_search_items` with a simple query
- **Obsidian-fs**: Call `list_directory` on the vault path

Report status for each: connected or not available.

If a server fails, don't block — just note it and suggest the user check their setup.

---

## Phase 7: Summary

Print the completion summary:

```
Scholar Flow is ready!

Field: {field} ({degree level})
Topics: {topics}
Notes: {Obsidian at path / Local notes/ directory}
Zotero: {Enabled / Not configured}
Language: {language}

MCP Servers:
  {checkmark or x} Semantic Scholar
  {checkmark or x} arXiv
  {checkmark or x} Brave Search
  {checkmark or x} Zotero
  {checkmark or x} Obsidian FS
  {checkmark or x} Sequential Thinking

Generated:
  - CLAUDE.md
  - .mcp.json + .claude/settings.json
  - 7 slash commands in .claude/commands/
  - 5 research skills in .agents/skills/
  - 1 deep-dive agent in .claude/agents/
  - Domain pack: domains/{field}/

Get started:
  /daily               Start your daily research routine
  /search-papers       Search for papers on a topic
  /brainstorm          Generate research ideas
  /summarize           Deep-read a paper

Config saved to .scholar-flow.yaml — run /init again anytime to update.
```

---

## Error Handling

- If a template file is missing, skip it and warn: "Template {file} not found — skipping."
- If a directory can't be created, warn and continue.
- If an MCP server fails verification, note it but don't block the setup.
- Never leave the setup in a half-finished state — if something fails, still write whatever files you can.
