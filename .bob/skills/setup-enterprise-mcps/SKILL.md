---
name: setup-enterprise-mcps
description: Sets up the global MCP server stack for enterprise Azure/M365/IBM watsonx Orchestrate work — wxo-docs, wxo-mcp (Orchestrate ADK), azure-mcp-server (incl. Terraform tooling), ms365, and optionally azure-devops. Use when the user asks to set up, install, configure, or restore their standard enterprise MCP servers, or mentions "enterprise MCP stack" or "watsonx/Azure/M365 MCPs".
---

# Enterprise MCP Stack Setup (Orchestrate + Azure + Terraform + M365 + ADO)

When this skill activates, configure Bob's **global** MCP settings with the four servers below, verify prerequisites, and confirm each server comes up green. Do not overwrite existing entries in `mcpServers` — merge in, preserving anything already there.

## 1. Check prerequisites

Run these checks first and report anything missing before proceeding:

```bash
uv --version && uvx --version   # needed for wxo-docs, wxo-mcp
node --version && npx --version # needed for azure-mcp-server, ms365 (Node 20+ LTS)
az account show                 # confirms Azure CLI auth; if it fails, run: az login
```

If `uv`/`uvx` is missing, install with:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## 2. Locate the global MCP settings file

- macOS: `~/.bob/settings/mcp_settings.json`
- Windows: `%APPDATA%\IBM Bob\User\globalStorage\ibm.bob-code\settings\mcp_settings.json or C:\Users\%USERNAME%\.bob\settings`

If it doesn't exist yet, create it with an empty `{"mcpServers": {}}` shell first.

## 3. Merge in this configuration

```json
{
  "mcpServers": {
    "wxo-docs": {
      "command": "uvx",
      "args": [
        "mcp-proxy",
        "--transport",
        "streamablehttp",
        "https://developer.watson-orchestrate.ibm.com/mcp"
      ],
      "alwaysAllow": ["SearchIbmWatsonxOrchestrateAdk"],
      "disabled": false
    },
    "wxo-mcp": {
      "command": "uvx",
      "args": [
        "--with",
        "ibm-watsonx-orchestrate==1.13.0",
        "ibm-watsonx-orchestrate-mcp-server"
      ],
      "env": {
        "WXO_MCP_WORKING_DIRECTORY": "/path/to/your/wxo/working/dir"
      },
      "disabled": false
    },
    "azure-mcp-server": {
      "command": "npx",
      "args": ["-y", "@azure/mcp@latest", "server", "start"],
      "disabled": false
    },
    "ms365": {
      "command": "npx",
      "args": ["-y", "@softeria/ms-365-mcp-server", "--org-mode", "--toon"],
      "disabled": false
    }
  }
}
```

Before writing, ask the user what to set `WXO_MCP_WORKING_DIRECTORY` to (their ADK agent/tool project folder) — do not guess a path.

## 4. Optional: Azure DevOps MCP

Add this if the user works with Azure DevOps boards, work items, or sprints. This server requires a PAT — it cannot use `az login`. Ask the user for their org name before writing.

The PAT must be **base64-encoded** in the format `email:pat`:

```bash
# macOS / Linux
echo -n "user@example.com:YOUR_RAW_PAT" | base64

# PowerShell
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("user@example.com:YOUR_RAW_PAT"))
```

```json
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
    "PERSONAL_ACCESS_TOKEN": "<base64-encoded email:pat>"
  },
  "disabled": false
}
```

> ⚠️ Never hard-code the raw PAT. Store it outside of source control and inject it via the environment. For project-specific work, prefer the project-scoped `.bob/mcp.json` with an `envFile: ".env"` entry instead of the global config — see the `azure-devops` skill for the full setup.

## 5. Optional: HashiCorp Terraform MCP

Only add this if the user needs registry/module search or HCP Terraform/Terraform Enterprise workspace management beyond what `azure-mcp-server`'s built-in Terraform tools (AzureRM/AzAPI docs, AVM discovery, export, policy validation) cover. Requires Docker running locally.

```json
"terraform": {
  "command": "docker",
  "args": ["run", "-i", "--rm", "hashicorp/terraform-mcp-server:0.5.2"]
}
```

If the user has HCP Terraform, also add an `env` block with `TFE_TOKEN` and `TFE_ADDRESS` (ask for these, never invent them).

## 6. Save and refresh

Save the file, then tell the user to click **Refresh all servers** in Bob's MCP panel (⋯ menu → MCP Servers). Each of `wxo-docs`, `wxo-mcp`, `azure-mcp-server`, and `ms365` should show a green indicator (plus any optional servers added).

## 7. Verify

Suggest these test prompts to confirm each server is live:

- wxo-docs / wxo-mcp: "Search the Orchestrate ADK docs for tool decorators"
- azure-mcp-server: "List my Azure resource groups"
- ms365: "Show my calendar for tomorrow"
- azure-devops *(if added)*: "List my Azure DevOps projects"

## 8. Notes to relay to the user

- `azure-mcp-server` takes no API keys — it inherits credentials from `az login` or other local Azure tooling auth caches.
- `ms365` will trigger a device-code sign-in on first run; the token is cached after.
- `ms365` exposes 200+ Graph endpoints by default. Once the user knows which Graph permissions they actually need, suggest scoping down with `--allowed-scopes` rather than leaving the full surface open tenant-wide.
- Project-level `.bob/mcp.json` configs take precedence over these global ones if a server name collides — flag this if the user later reports unexpected behaviour in a specific project.