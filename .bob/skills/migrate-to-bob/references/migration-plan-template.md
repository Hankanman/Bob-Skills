# Bob migration plan — {REPO NAME}

Structure for the `BOB_MIGRATION_PLAN.md` written at the repo root in Phase 5.
Fill every section from the actual migration; delete guidance in braces.

## 1. Inventory

Source tool(s) detected: {Copilot / Cursor / Claude Code}

| Artifact | Path | Type |
| --- | --- | --- |
| {e.g. Cursor rules} | `.cursor/rules/*.mdc` | rules |
| … | … | … |

## 2. Migrated

| Source | → Bob location | Notes |
| --- | --- | --- |
| `CLAUDE.md` | `.bob/rules/01-*.md … ` | split into N files |
| `.claude/skills/foo/` | `.bob/skills/foo/` | 1:1, stripped Claude-only frontmatter |
| `.cursor/mcp.json` | `.bob/mcp.json` | 2 servers copied |
| … | … | … |

## 3. Needs a decision

Each item has a recommendation; ask the user to confirm.

- **Glob-scoped rules** {list each Cursor `globs` / Copilot `applyTo` rule}:
  recommendation — {keep as always-on with scope-in-prose | move to mode
  `.bob/rules-{slug}/`}.
- **Secrets found in MCP config** {list}: recommendation — move to env vars
  {names}; rotate if committed.
- **Subagents → modes** {list `.claude/agents/*`}: recommendation — create custom
  mode(s) {slugs}.
- **Ambiguous / overlapping rules**: {describe}, recommendation — {consolidate}.

## 4. Recommended Bob setup for this repo

- **`.bobignore`**: {proposed patterns — build output, secrets, large data}.
- **Custom modes** for this repo's real workflows: {e.g. a `db-schema` mode
  restricted to schema files; a `deploy` mode; a `docs` mode} — with slugs and
  tool groups.
- **MCP servers worth adding** for this stack: {e.g. a Postgres MCP, the docs MCP,
  a cloud-provider MCP} — why each helps here.
- **Auto-approve**: {which low-risk actions to auto-approve; what to keep gated}.
- **Skills worth authoring**: {repo-specific recurring tasks that deserve a skill}.

## 5. Verification (Bob works *alongside* the other tools)

The source config stays in place — this repo remains usable in Copilot, Cursor,
and Claude Code. Verify only that Bob *also* works:

1. Reload Bob; confirm `.bob/rules/` load (ask Bob to state a project convention).
2. Trigger each migrated skill by its `description` and confirm activation.
3. Confirm each `.bob/mcp.json` server connects and lists its tools.
4. Exercise each custom mode.
5. Sanity-check the repo still opens cleanly in the original tool(s) — nothing was
   moved or removed.

## 6. Keeping tools in sync

The same guidance now lives in multiple formats. List every duplicated pair so
both get updated when standards change, and note the canonical source.

| Concern | Canonical source | Also mirrored in |
| --- | --- | --- |
| {coding standards} | `AGENTS.md` | `.bob/rules/`, `.cursor/rules/*.mdc`, `.github/copilot-instructions.md` |
| {MCP servers} | — (per-tool, must match) | `.bob/mcp.json`, `.cursor/mcp.json`, `.vscode/mcp.json`, `.mcp.json` |
| … | … | … |

Recommendation: keep prose guidance in one file that several tools already read
(`AGENTS.md` is read by Copilot and Claude Code) and keep `.bob/rules/` /
`.cursor/rules/` thin pointers to it, so there is one place to edit.
