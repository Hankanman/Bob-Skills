# Bob target formats (reference)

Exact shapes to write when migrating. Project config lives under `.bob/` in the
repo root; global config under `~/.bob/`. Project-level always overrides global on
name conflicts.

## Rules — `.bob/rules/*.md`

- A directory of Markdown files; **every file is always loaded** into context.
- No frontmatter, no `globs`, no `alwaysApply`. Scope must be expressed in prose.
- One concern per file, numbered for readable ordering:
  `.bob/rules/01-stack.md`, `02-testing.md`, `03-style.md`, …
- Mode-scoped rules go in `.bob/rules-{mode-slug}/*.md` and load only in that mode.
- Legacy single-file `.bobrules` at repo root is supported but prefer the directory.

Keep rules lean — always-on rules are spent on every request.

## Skills — `.bob/skills/<name>/SKILL.md`

```markdown
---
name: skill-identifier
description: Clear summary Bob uses to decide when to activate this skill.
---

# Title

Instructions Bob receives when the skill activates. Everything below the
frontmatter is the skill body. Supporting files (checklists, templates, scripts)
can sit alongside SKILL.md and Bob reads them once the skill is active.
```

- Required frontmatter: `name`, `description`. A skill with no description is
  ignored. Bob matches the `description` against the user's request to activate.
- Project skills (`.bob/skills/`) override global (`~/.bob/skills/`) by name.
- Skills load once per conversation. Auto-activation can be enabled at
  **Settings → Auto-Approve → Skills**.

## MCP servers — `.bob/mcp.json`

Root key `mcpServers`. See `mcp-migration.md` for full transform rules.

```json
{
  "mcpServers": {
    "local-server": {
      "command": "node",
      "args": ["server.js"],
      "cwd": "/path/to/root",
      "env": { "API_KEY": "${MY_API_KEY}" },
      "alwaysAllow": ["tool1"],
      "disabled": false
    },
    "remote-server": {
      "type": "streamable-http",
      "url": "https://example.com/mcp",
      "headers": { "Authorization": "Bearer ${MY_TOKEN}" },
      "alwaysAllow": ["tool3"],
      "disabled": false
    }
  }
}
```

Per-server keys: `command`, `args`, `cwd`, `env`, `url`, `type`, `headers`,
`alwaysAllow`, `disabled`.

## Custom modes — `.bob/custom_modes.yaml`

Project file `.bob/custom_modes.yaml`; global `~/.bob/settings/custom_modes.yaml`.
YAML preferred (legacy JSON still read).

```yaml
customModes:
  - slug: docs-writer            # unique: letters, numbers, hyphens
    name: 📝 Documentation Writer # shown in the mode picker
    description: Writes and revises Markdown docs.   # optional short summary
    roleDefinition: You are a technical writer specializing in clear docs.
    whenToUse: Use for writing and editing documentation.   # optional
    customInstructions: Focus on clarity and completeness.   # optional
    groups:                      # tool groups this mode may use
      - read
      - - edit                   # edit restricted to matching files
        - fileRegex: "\\.(md|mdx)$"
          description: Markdown files only
      - skill
```

Tool groups: `read`, `edit` (optionally `fileRegex`-restricted), `execute`, `mcp`,
`skill`, `workflow`, `todo`, `subtask`, `subagent`, `mode`.

Built-in modes to model custom ones on:
- **Agent** — full tools (read, edit, execute, mcp, skill, todo, subtask,
  subagent, mode). Implementing code.
- **Plan** — read, edit, mcp, skill, subagent, mode. Design/strategy.
- **Ask** — read, mcp, skill, subagent. Learning/analysis, no edits.

## Subagents

Not file-defined. Bob spawns two built-in types on demand (with approval):
- **explore** — read-only codebase analysis on a lighter model.
- **general** — full read/write tools.
Subagents get their own context; set `fork_context: true` to pass parent history.
Migrate a Claude Code subagent's *persona* to a custom mode, and its *procedure*
to a skill.

## `.bobignore` (repo root)

`.gitignore` syntax. Files/dirs Bob should not read or modify. Put build
artifacts, large data, and anything secret here.
