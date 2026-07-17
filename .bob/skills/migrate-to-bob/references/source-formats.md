# Source-tool artifact catalog & mapping to Bob

Every AI-config artifact the three source tools leave in a repo (or user config),
what it does, and where it goes in Bob. Bob targets are detailed in
`bob-targets.md`.

## Master mapping table

| Concept | GitHub Copilot | Cursor | Claude Code | → Bob target |
| --- | --- | --- | --- | --- |
| Repo-wide instructions | `.github/copilot-instructions.md`, `AGENTS.md` | `.cursorrules` (legacy), `.cursor/rules/*.mdc` with `alwaysApply: true` | `CLAUDE.md`, `~/.claude/CLAUDE.md` | `.bob/rules/*.md` |
| Path-scoped rules | `.github/instructions/*.instructions.md` (`applyTo:` glob) | `.cursor/rules/*.mdc` with `globs:` | nested `CLAUDE.md` per dir | `.bob/rules/*.md` (scope in prose) or `.bob/rules-{slug}/` |
| Reusable skill | — (no direct equiv) | — | `.claude/skills/<name>/SKILL.md` | `.bob/skills/<name>/SKILL.md` (≈1:1) |
| Slash command / prompt | `.github/prompts/*.prompt.md` | `.cursor/commands/*.md` | `.claude/commands/*.md` | `.bob/skills/<name>/SKILL.md` |
| Persona / chat mode | `.github/chatmodes/*.chatmode.md` | — | `.claude/agents/*.md`, output styles | `.bob/custom_modes.yaml` |
| Subagent | — | — | `.claude/agents/*.md` | built-in explore/general subagent, or a custom mode |
| MCP servers | `.vscode/mcp.json` (root key **`servers`**) | `.cursor/mcp.json`, `~/.cursor/mcp.json` (`mcpServers`) | `.mcp.json`, `~/.claude.json` (`mcpServers`) | `.bob/mcp.json` (`mcpServers`) |
| Ignore | `.copilotignore` (partial) | `.cursorignore`, `.cursorindexingignore` | `.gitignore` used implicitly | `.bobignore` |
| Settings / permissions | VS Code settings | `.cursor/` settings | `.claude/settings.json` | Bob Settings UI + `.bob/mcp.json` `alwaysAllow` |

## GitHub Copilot

- `.github/copilot-instructions.md` — single repo-wide custom-instructions file.
  Plain Markdown, always applied. → `.bob/rules/`.
- `.github/instructions/*.instructions.md` — path-specific instructions.
  Frontmatter `applyTo: "<glob>"` (comma-separated globs). → `.bob/rules/` with the
  path scope stated in prose, or a mode-scoped rule.
- `.github/prompts/*.prompt.md` — reusable prompt files (invoked with `/name`).
  Frontmatter can include `mode`, `tools`, `description`. → Bob **skill**.
- `.github/chatmodes/*.chatmode.md` — custom chat modes. Frontmatter `description`,
  `tools`, `model`. → Bob **custom mode**.
- `AGENTS.md` — increasingly the cross-tool standard for agent guidance. Treat as
  repo-wide instructions → `.bob/rules/`.
- `.vscode/mcp.json` — MCP config. **Root key is `servers`** and it often has an
  `inputs:` array with `${input:id}` secret placeholders. See `mcp-migration.md`.

## Cursor

- `.cursor/rules/*.mdc` — the modern rules format. YAML frontmatter:
  - `description:` — used by Cursor to decide when to auto-attach the rule.
  - `globs:` — file patterns; rule attaches only when a matching file is in context.
  - `alwaysApply:` — `true` = always in context; `false`/absent = conditional.
  - Body = Markdown guidance. Cursor also supports `@file` references.
  → `.bob/rules/`. Bob has no glob/alwaysApply mechanism (rules are always on), so:
    - `alwaysApply: true` → copy body straight in.
    - `globs`-scoped → put the scope in the rule text, or convert to a
      `.bob/rules-{mode-slug}/` file if it lines up with a workflow/mode.
- `.cursorrules` — legacy single-file rules at repo root. → split by concern into
  `.bob/rules/*.md`.
- `.cursor/commands/*.md` — reusable slash commands. → Bob **skills**.
- `.cursor/mcp.json` (project) / `~/.cursor/mcp.json` (global) — MCP config, root
  key `mcpServers`. Structurally compatible with Bob.
- `.cursorignore` / `.cursorindexingignore` → `.bobignore`.

## Claude Code

- `CLAUDE.md` (repo root, nested per-dir, and `~/.claude/CLAUDE.md`) — memory /
  project instructions. Supports `@path/to/file` imports that inline other files.
  → `.bob/rules/*.md`. Resolve `@` imports by inlining; nested files → rules that
  name their directory scope.
- `.claude/skills/<name>/SKILL.md` — Agent Skills. Frontmatter `name`,
  `description`, optionally `allowed-tools`, `disable-model-invocation`, `model`;
  Markdown body; supporting files in the folder. → `.bob/skills/<name>/SKILL.md`,
  **near 1:1** (keep `name`+`description`, drop the Claude-only keys).
- `.claude/agents/*.md` — subagents. Frontmatter `name`, `description`, `tools`,
  `model`; body = system prompt. → a Bob **custom mode** (persona) or, if it just
  ran a procedure, a **skill**. Bob's actual subagent runners are the built-in
  explore/general types.
- `.claude/commands/*.md` — custom slash commands. → Bob **skills**.
- `.claude/settings.json` — permissions, hooks, env. No 1:1 Bob file; translate
  permission intent into Bob's auto-approve settings and note hooks in the plan.
- `.mcp.json` (root key `mcpServers`) — MCP config. Compatible with Bob.

## What does NOT port (call these out in the plan)

- Cursor `globs` / Copilot `applyTo` auto-scoping — Bob rules are always-on.
- Claude Code hooks and fine-grained `settings.json` permissions — Bob uses its
  Settings/auto-approve UI instead.
- Model pins in source frontmatter — Bob selects models per mode, not per file.
- Any embedded secrets in MCP configs — must be re-homed to env/headers.
