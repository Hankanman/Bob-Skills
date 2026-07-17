# Bob-Skills

A personal library of [IBM Bob](https://www.ibm.com/products/bob) **skills** and supporting resources, including workshop material used for internal Trustmarque/Ultima developer days.

---

## Repository layout

```
.bob/
  skills/
    migrate-to-bob/          # Skill: migrate repos from Copilot/Cursor/Claude Code → Bob
    setup-enterprise-mcps/   # Skill: configure the global enterprise MCP server stack
Bob-Workbook.md              # Bobathon workshop workbook (hands-on developer day guide)
```

---

## Skills

### `migrate-to-bob`

Onboards an existing repository into Bob from **GitHub Copilot**, **Cursor**, or **Claude Code**.

Activates when a user wants to:
- Move to Bob or adopt it for an existing repo
- Port `.cursor/rules`, `.cursorrules`, `.github/copilot-instructions.md`, `CLAUDE.md`, `.claude/`, MCP configs, subagents, or prompt files into Bob's native format

**What it does:** detects all source-tool artefacts, translates them into `.bob/rules/`, `.bob/skills/`, `.bob/mcp.json`, and `.bob/custom_modes.yaml`, then produces a `BOB_MIGRATION_PLAN.md` covering what was migrated, what needs a human decision, and how to verify. The migration is **additive** — source configs are never deleted.

Supporting files live under `.bob/skills/migrate-to-bob/references/` and `scripts/`.

---

### `azure-devops`

Connects Bob to Azure DevOps for ticket management and work pickup, backed by a **PAT stored in a `.env` file**.

Activates when the user mentions Azure DevOps, ADO, work items, tickets, sprints, boards, PBIs, user stories, or asks "what should I work on next". Also activates when setting up the Azure DevOps MCP server.

**What it does:** walks through creating a PAT (with correct scopes), base64-encoding it (the official server's required format), setting up the `.env` file, configuring `@azure-devops/mcp` in `.bob/mcp.json`, and verifying the connection. Includes ready-to-use prompts for common workflows:

- Listing items assigned to you / current sprint contents
- Picking up a ticket (moving to Active, self-assigning)
- Updating state, adding comments, logging effort
- Creating tasks, bugs, and linking items
- Triage and planning queries

**Auth:** PAT via `.env` — never committed, never hard-coded in the MCP config.

---

### `setup-enterprise-mcps`

Configures Bob's **global** MCP server stack for Azure / M365 / IBM watsonx Orchestrate work.

Activates when a user asks to set up, install, configure, or restore their standard enterprise MCP servers, or mentions "enterprise MCP stack", "watsonx", "Azure MCPs", or "M365 MCPs".

**Servers it configures:**

| Server | Purpose |
|---|---|
| `wxo-docs` | Searches the IBM watsonx Orchestrate ADK documentation |
| `wxo-mcp` | IBM watsonx Orchestrate MCP server (ADK, tools, agents) |
| `azure-mcp-server` | Azure resource management, Terraform tooling, AVM |
| `ms365` | Microsoft 365 via Graph API (calendar, mail, Teams, etc.) |
| `terraform` *(optional)* | HashiCorp Terraform registry + HCP workspace management |

Prerequisites: `uv`/`uvx` (for wxo servers), Node 20+ LTS, and `az login`.

---

## Bob-Workbook.md

A structured workshop guide for internal developer days ("Bobathon"). Covers eight hands-on capability modules:

1. Literate Coding
2. Custom Modes
3. Agentic Orchestration
4. MCP Integration
5. Bob Shell / DevOps Automation
6. Skills
7. Shift-Left Security
8. Bobalytics — cost & token visibility

Also includes a competitive comparison table (Copilot / Claude Code / Cursor / Codex) and a stretch-goals section for tables that run ahead of schedule.

---

## Using the skills

Skills in this repo are picked up automatically by Bob when the repo is open in the IDE. To use them in any project, copy the relevant skill folder to your global skills directory:

- **macOS / Linux:** `~/.bob/skills/<skill-name>/`
- **Windows:** `%APPDATA%\IBM Bob\User\globalStorage\ibm.bob-code\skills\<skill-name>\`

Trigger them by describing the task in plain language — Bob matches on the `description` field in each `SKILL.md` frontmatter.
