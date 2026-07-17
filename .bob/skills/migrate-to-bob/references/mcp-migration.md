# MCP migration: transforms & gotchas

Target: `.bob/mcp.json`, root key **`mcpServers`**. Merge every source server into
this one file. Global servers can instead go in `~/.bob/mcp.json`.

## Source → Bob key mapping

| Source | File | Root key | Transform to Bob |
| --- | --- | --- | --- |
| Claude Code | `.mcp.json`, `~/.claude.json` | `mcpServers` | Copy servers as-is (compatible) |
| Cursor | `.cursor/mcp.json`, `~/.cursor/mcp.json` | `mcpServers` | Copy servers as-is (compatible) |
| Copilot / VS Code | `.vscode/mcp.json` | **`servers`** | **Rename `servers` → `mcpServers`**; rewrite `inputs`/`${input:…}` |

## Per-server field normalization

Bob per-server keys: `command`, `args`, `cwd`, `env` (stdio) / `type`, `url`,
`headers` (remote), plus `alwaysAllow`, `disabled`.

- **stdio server**: keep `command`, `args`, `cwd`, `env`. Good.
- **remote server**: Bob uses `type` + `url` (+ `headers`). Normalize transport:
  - Cursor/Claude sometimes express remote as just `{ "url": "…" }` — add an
    explicit `"type": "streamable-http"` (or `"sse"` if that's the endpoint).
  - VS Code uses `"type": "http"` or `"sse"` — map `http` → `streamable-http`.
- Drop editor-only keys that Bob doesn't use (e.g. VS Code `gallery`, `dev`).
- Preserve `alwaysAllow` if the source had an equivalent auto-approve list;
  otherwise omit and let the user approve tools on first use.

## Secrets — never copy verbatim

Source configs frequently inline tokens. In Bob:

- **stdio**: put secrets in `env` and reference an environment variable:
  `"env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }`.
- **remote**: put them in `headers`:
  `"headers": { "Authorization": "Bearer ${MY_TOKEN}" }`.
- VS Code `inputs` blocks with `${input:token}` prompt-style placeholders →
  replace with the corresponding `${ENV_VAR}` and tell the user which env vars to
  set.
- **Flag every literal secret you find** to the user in the plan — it may already
  be committed and need rotating.

## Example: VS Code → Bob

Source `.vscode/mcp.json`:

```json
{
  "inputs": [
    { "id": "gh_pat", "type": "promptString", "description": "GitHub PAT", "password": true }
  ],
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer ${input:gh_pat}" }
    }
  }
}
```

Bob `.bob/mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "type": "streamable-http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer ${GITHUB_PAT}" }
    }
  }
}
```

(Then: `export GITHUB_PAT=…` in the environment Bob runs in.)

## Verify

After writing `.bob/mcp.json`, have the user reload Bob and confirm each server
connects and its tools are listed. A server that fails is usually a missing env
var, a wrong `type`, or a stdio `command` not on `PATH`.
