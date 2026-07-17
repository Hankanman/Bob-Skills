---
name: migrate-to-bob
description: >-
  Migrate or onboard a repository into IBM Bob from GitHub Copilot, Cursor, or
  Claude Code. Use when a user wants to move to Bob, adopt Bob for an existing
  repo, port their AI config, or asks what to do with their .cursor/rules,
  .cursorrules, .github/copilot-instructions.md, .github/instructions,
  CLAUDE.md, .claude/, .mcp.json, .cursor/mcp.json, .vscode/mcp.json, skills,
  subagents, custom instructions, rules, or MCP servers so Bob works optimally.
---

# Migrate a repo to IBM Bob

Onboard an existing repository into Bob by finding the AI-assistant configuration
left behind by **GitHub Copilot**, **Cursor**, or **Claude Code**, translating
what maps cleanly, flagging what needs a human decision, and producing a written
plan to make Bob optimal for this codebase.

Bob's native config lives under `.bob/` (project) and `~/.bob/` (global):

| Bob concept | Where it lives | Format |
| --- | --- | --- |
| Project rules (always-on) | `.bob/rules/*.md` | Markdown, all files concatenated into context |
| Mode-scoped rules | `.bob/rules-{mode-slug}/*.md` | Markdown, loaded only in that mode |
| Skills | `.bob/skills/<name>/SKILL.md` (+ supporting files) | YAML frontmatter (`name`, `description`) + Markdown |
| MCP servers | `.bob/mcp.json` | JSON, root key `mcpServers` |
| Custom modes | `.bob/custom_modes.yaml` | YAML, `customModes:` list |
| Ignore list | `.bobignore` (repo root) | `.gitignore` syntax |

Do the migration in five phases. **This is additive by default — never delete or
move the source config.** The repo must keep working in Copilot, Cursor, and
Claude Code after the migration; Bob's `.bob/` config is added *alongside* the
existing `.cursor/`, `.github/`, `CLAUDE.md`, and `.claude/` files, which all stay
exactly where they are. You are copying/translating into Bob's format, not
cutting over. Only remove a source tool's config if the user explicitly says they
are dropping that tool.

## Phase 1 — Detect the source tool(s)

Run the detector to inventory what's in the repo:

```bash
bash .bob/skills/migrate-to-bob/scripts/detect-sources.sh
```

It reports every Copilot / Cursor / Claude Code artifact it finds (rules, skills,
subagents, commands, prompts, MCP configs, ignore files). A repo may contain more
than one tool's config — migrate all of them. If the script finds nothing, ask the
user which tool they came from and where their config lives (it may be in a global
location like `~/.cursor/`, `~/.claude/`, or VS Code user settings).

Read `references/source-formats.md` for the full catalog of what each tool leaves
behind and exactly what each artifact means.

## Phase 2 — Migrate rules & instructions → `.bob/rules/`

This is the highest-value migration. Read every source rule/instruction file, then
write the equivalent under `.bob/rules/` as focused Markdown files (one concern per
file, e.g. `01-stack.md`, `02-testing.md`, `03-style.md`).

Key translations — see `references/source-formats.md` for detail:

- **Claude Code `CLAUDE.md`** → split into `.bob/rules/*.md`. Resolve any `@path`
  imports by inlining the referenced content. Nested `CLAUDE.md` files become
  rules that state their directory scope in prose.
- **Cursor `.cursor/rules/*.mdc`** → one `.bob/rules/*.md` per `.mdc`. Bob rules
  are **always applied** and have no `globs`/`alwaysApply` frontmatter, so:
  - `alwaysApply: true` rules → straight copy (drop the frontmatter).
  - `globs`-scoped rules → either state the scope in the rule body ("Applies to
    files matching `app/**/*.py`: …") or, if the scope maps to a workflow, move
    it to a mode-scoped `.bob/rules-{slug}/` file. Don't silently drop the glob.
  - Legacy `.cursorrules` (single file) → split by concern.
- **Copilot `.github/copilot-instructions.md`** → `.bob/rules/`. `AGENTS.md`, if
  present, is also generic guidance → `.bob/rules/`.
- **Copilot `.github/instructions/*.instructions.md`** → the `applyTo:` glob is
  path-scoped; handle it like a Cursor glob rule (scope-in-prose or mode rule).

Keep rules lean — every always-on rule is spent on every request. Consolidate
duplicates across tools rather than copying three overlapping style guides.

## Phase 3 — Migrate skills, commands, subagents & modes

- **Claude Code `.claude/skills/<name>/SKILL.md`** → **near 1:1** to
  `.bob/skills/<name>/SKILL.md`. Both use `SKILL.md` with `name` + `description`
  frontmatter and a Markdown body, and both support supporting files in the skill
  folder. Copy the folder; keep `name`/`description`; **strip Claude-only
  frontmatter** (`allowed-tools`, `disable-model-invocation`, `model`) — Bob
  ignores unknown keys but clean them anyway. Verify referenced supporting files
  came across.
- **Slash commands / prompt files** (`.claude/commands/*.md`,
  `.cursor/commands/*.md`, `.github/prompts/*.prompt.md`) → these are reusable
  task recipes. Convert each to a Bob **skill** (`.bob/skills/<name>/SKILL.md`)
  with a `description` that captures when to run it. A command that defines a
  whole persona/workflow may be better as a **custom mode** (Phase 3 modes).
- **Claude Code subagents `.claude/agents/*.md`** → Bob's subagents are the
  built-in **explore** (read-only) and **general** (read/write) types, not
  file-defined. A specialized agent persona → a **custom mode** in
  `.bob/custom_modes.yaml` (map its `description`/`tools` to a mode `slug`,
  `roleDefinition`, `whenToUse`, and `groups`). A reusable procedure the agent ran
  → a skill instead.
- **Copilot chat modes `.github/chatmodes/*.chatmode.md`** → **custom modes** in
  `.bob/custom_modes.yaml`.

See `references/bob-targets.md` for the exact custom-mode YAML schema and tool
groups, and `references/source-formats.md` for the per-file mapping table.

## Phase 4 — Migrate MCP servers → `.bob/mcp.json`

MCP is where silent breakage hides. Read `references/mcp-migration.md` and follow
it exactly. Summary:

- **Claude Code `.mcp.json`** and **Cursor `.cursor/mcp.json`** already use the
  `mcpServers` root key → structurally compatible, copy servers across into
  `.bob/mcp.json`.
- **Copilot `.vscode/mcp.json`** uses the root key **`servers`** (not
  `mcpServers`) and may use an `inputs`/`${input:…}` block for secrets → rename
  the key and rewrite secret references.
- Never copy hard-coded tokens/keys. Move them to `env` (stdio) or `headers`
  (http) and reference environment variables. Flag any secret you find to the user.
- Confirm each server's transport: stdio (`command`/`args`/`cwd`/`env`) vs remote
  (`type: streamable-http` or `sse`, `url`, `headers`).

## Phase 5 — Write the optimization plan

Produce `BOB_MIGRATION_PLAN.md` at the repo root using
`references/migration-plan-template.md` as the structure. It must contain:

1. **Inventory** — what was found, per source tool.
2. **Migrated** — the mapping of each source artifact → its new Bob location.
3. **Needs a decision** — glob-scoped rules, secrets, subagents-as-modes, and
   anything ambiguous, each with a concrete recommendation.
4. **Recommended Bob setup for this repo** — a `.bobignore` (build artifacts,
   secrets, large data), suggested custom modes for the repo's real workflows,
   suggested MCP servers for its stack, and auto-approve guidance.
5. **Verification steps** — how to confirm Bob's rules load, skills activate, and
   MCP servers connect. (The source configs stay in place; verification is about
   confirming Bob *also* works, not about a cutover.)
6. **Keeping tools in sync** — the same guidance now lives in two places (e.g.
   `CLAUDE.md` and `.bob/rules/`, or `.cursor/mcp.json` and `.bob/mcp.json`). Note
   which files are duplicated so the user knows to update both when standards
   change, and recommend a single-source-of-truth strategy (see Ground rules).

Present the plan to the user and ask for confirmation on the "needs a decision"
items. Do **not** propose deleting any source config — the repo stays multi-tool.
Only if the user later says they're retiring Copilot/Cursor/Claude Code should
removing that tool's files even be discussed.

## Ground rules

- **Additive, non-destructive.** Never delete, rename, or move `.cursor/`,
  `.cursorrules`, `.github/copilot-instructions.md`, `.github/instructions/`,
  `.vscode/mcp.json`, `CLAUDE.md`, or `.claude/`. Bob config is added beside them
  so the repo still works in every tool.
- Preserve the intent of every rule; when in doubt, keep the wording and note the
  ambiguity in the plan rather than dropping it.
- Don't invent standards the source config didn't state — this is a migration,
  not a rewrite.
- Keep the migrated `.bob/rules/` lean and de-duplicated across source tools.
- **Manage duplication.** Because the same guidance now exists in Bob's format and
  the source tools' formats, they can drift. Prefer keeping the substance in one
  canonical place and referencing it: e.g. an `AGENTS.md` at the repo root is read
  by Copilot and Claude Code, so point Cursor rules and a thin `.bob/rules/` file
  at it rather than triplicating prose. Where duplication is unavoidable (MCP
  configs must exist per-tool), list the paired files in the plan so both get
  updated together.
