---
name: azure-devops
description: >-
  Work with Azure DevOps boards and tickets — list work items assigned to me,
  pick up a ticket, update status, log effort, create tasks, and manage sprints.
  Use when the user mentions Azure DevOps, ADO, work items, tickets, sprints,
  boards, PBIs, user stories, tasks, or "what should I work on next". Also
  activates when the user asks to set up or configure the Azure DevOps MCP
  server with a PAT.
---

# Azure DevOps — Tickets & Work Management

This skill connects Bob to Azure DevOps via the **official Microsoft
`@azure-devops/mcp`** server ([microsoft/azure-devops-mcp](https://github.com/microsoft/azure-devops-mcp)),
authenticated with a **Personal Access Token** stored in a `.env` file.

---

## 1. Prerequisites

- Node.js 20+ (`node --version` to confirm)
- An Azure DevOps organisation you have access to
- A PAT with (at minimum) **Work Items — Read & Write** scope

**Create a PAT:**
1. Azure DevOps → top-right avatar → **Personal access tokens**
2. **New Token** → set expiry → tick **Work Items (Read & Write)**;
   add **Code (Read)** if you also want repo/PR tools
3. Copy the token — you only see it once

---

## 2. `.env` setup

The server reads `PERSONAL_ACCESS_TOKEN` from the process environment.
Store it in a `.env` file at the repo root and **never commit it**.

```bash
echo ".env" >> .gitignore
```

### Required format

The value must be the **base64 encoding of `email:pat`** — the Azure DevOps
API only uses the token portion, so the email can be any non-empty string.

**Generate the encoded value:**

```bash
# macOS / Linux
echo -n "user@example.com:YOUR_RAW_PAT_HERE" | base64

# PowerShell
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("user@example.com:YOUR_RAW_PAT_HERE"))
```

### `.env` file

```dotenv
# Azure DevOps PAT authentication (base64 of "email:pat")
PERSONAL_ACCESS_TOKEN=dXNlckBleGFtcGxlLmNvbTpZT1VSX1BBVEhFUkU=
```

> ⚠️ If you accidentally commit a PAT, revoke it immediately in Azure DevOps
> and generate a new one.

---

## 3. MCP server configuration

Add to your **project** config (`.bob/mcp.json`) so it picks up the `.env`
in this repo's working directory. Bob's project config uses the `mcpServers`
root key; note the org name is a positional argument, not an env var.

### `.bob/mcp.json`

```json
{
  "mcpServers": {
    "azure-devops": {
      "command": "npx",
      "args": [
        "-y",
        "@azure-devops/mcp",
        "YOUR-ORG-NAME",
        "--authentication", "pat",
        "-d", "core", "work", "work-items"
      ],
      "envFile": ".env",
      "disabled": false
    }
  }
}
```

Replace `YOUR-ORG-NAME` with your Azure DevOps organisation slug (the part
after `dev.azure.com/` in your org URL).

### If your MCP host doesn't support `envFile`

Pass the env var directly — still safe as long as you reference it from the
shell environment rather than hard-coding the value:

```json
{
  "mcpServers": {
    "azure-devops": {
      "command": "npx",
      "args": [
        "-y",
        "@azure-devops/mcp",
        "YOUR-ORG-NAME",
        "--authentication", "pat",
        "-d", "core", "work", "work-items"
      ],
      "env": {
        "PERSONAL_ACCESS_TOKEN": "${PERSONAL_ACCESS_TOKEN}"
      },
      "disabled": false
    }
  }
}
```

After saving, click **Refresh all servers** in Bob's MCP panel
(⋯ menu → MCP Servers). `azure-devops` should show a green indicator.

---

## 4. Domain filtering

The official server has a large tool surface. The `-d` flag loads only the
named domains, keeping context lean and avoiding model confusion. Always
include `core` so project-level lookups work.

| Domain | What it covers |
|---|---|
| `core` | Projects, teams, iterations (always include) |
| `work` | Boards, backlogs, sprint queries |
| `work-items` | Get, create, update, comment on individual items |
| `repositories` | Repos, branches, pull requests |
| `pipelines` | Pipeline runs, build history |
| `search` | Cross-project code and work item search |
| `wiki` | Wiki pages |
| `test-plans` | Test plans and suites |
| `advanced-security` | ADO Advanced Security findings |

For day-to-day ticket work, **`core work work-items`** is sufficient.

---

## 5. Verify the connection

Once the server is green, test with:

> "List all projects in my Azure DevOps organisation"

If it fails, check:
- `PERSONAL_ACCESS_TOKEN` is the full base64 string of `email:rawpat`
- `--authentication pat` is present in `args`
- The PAT hasn't expired and has Work Items scope
- The org name in `args` matches your org slug exactly (case-insensitive)

---

## 6. Prompts for common workflows

### See what's on my plate

> "Show me all work items assigned to me that are Active or In Progress"

> "What work items are in the current sprint for the [project] project?"

### Pick up a ticket

> "Show me the details of work item #1234"

> "I'm starting work on item #1234 — move it to Active and assign it to me"

### Update progress

> "Mark work item #1234 as Resolved and add a comment: 'Implemented and unit tested — PR raised'"

### Create work

> "Create a task under PBI #1000 called 'Write unit tests for the auth service', estimate 4 hours, assign to me"

> "Create a bug in [project]: title 'Login fails on Safari 17', assign to me, set priority to 1"

### Triage and planning

> "List all unassigned bugs in [project] ordered by priority"

> "Show me backlog items with no estimate marked High priority"

---

## 7. Security notes

- `PERSONAL_ACCESS_TOKEN` is the only secret — keep it in `.env`, never
  in `.bob/mcp.json` or committed source.
- Scope the PAT to the minimum needed. `Work Items (Read & Write)` covers
  everything in section 6. Add `Code (Read)` only if using repo/PR tools.
- Rotate on a schedule (90-day expiry is sensible). When you rotate, update
  `.env` and re-encode the new value — no MCP config change required.
- If you share this repo with teammates, each person provides their own `.env`
  with their own PAT. Do not share PATs.
- The `--authentication azcli` flag is a good alternative for workstations
  that already run `az login` — no base64 encoding, no env var to manage.
