#!/usr/bin/env bash
# detect-sources.sh — inventory AI-assistant config left by GitHub Copilot,
# Cursor, and Claude Code so the migrate-to-bob skill knows what to port.
# Read-only: it never modifies anything. Run from the repo root.

set -uo pipefail
ROOT="${1:-.}"
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 1; }

found_any=0

section() { printf '\n=== %s ===\n' "$1"; }

# report <label> <path-or-glob> : print each existing match
report() {
  local label="$1"; shift
  local hit=0
  for p in "$@"; do
    for f in $p; do
      if [ -e "$f" ]; then
        printf '  [%s] %s\n' "$label" "$f"
        hit=1; found_any=1
      fi
    done
  done
  return $hit
}

# count files under a dir matching a glob, print if any
report_glob() {
  local label="$1" dir="$2" pat="$3"
  if [ -d "$dir" ]; then
    local n
    n=$(find "$dir" -type f -name "$pat" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$n" -gt 0 ]; then
      printf '  [%s] %s (%s file(s) matching %s)\n' "$label" "$dir" "$n" "$pat"
      find "$dir" -type f -name "$pat" 2>/dev/null | sed 's/^/      - /'
      found_any=1
    fi
  fi
}

echo "Scanning $(pwd) for source AI-assistant config..."

section "GitHub Copilot"
report "copilot-instructions" ".github/copilot-instructions.md" "AGENTS.md"
report_glob "copilot-instructions" ".github/instructions" "*.instructions.md"
report_glob "copilot-prompts"      ".github/prompts"       "*.prompt.md"
report_glob "copilot-chatmodes"    ".github/chatmodes"     "*.chatmode.md"
report "copilot-mcp (root key: 'servers')" ".vscode/mcp.json"
report "copilot-ignore" ".copilotignore"

section "Cursor"
report_glob "cursor-rules"    ".cursor/rules"    "*.mdc"
report_glob "cursor-rules"    ".cursor/rules"    "*.md"
report "cursor-rules-legacy"  ".cursorrules"
report_glob "cursor-commands" ".cursor/commands" "*.md"
report "cursor-mcp (root key: 'mcpServers')" ".cursor/mcp.json"
report "cursor-ignore" ".cursorignore" ".cursorindexingignore"

section "Claude Code"
report "claude-md" "CLAUDE.md"
report_glob "claude-nested-md" "." "CLAUDE.md"   # nested per-dir memory
report_glob "claude-skills"   ".claude/skills"   "SKILL.md"
report_glob "claude-agents"   ".claude/agents"   "*.md"
report_glob "claude-commands" ".claude/commands" "*.md"
report "claude-settings" ".claude/settings.json" ".claude/settings.local.json"
report "claude-mcp (root key: 'mcpServers')" ".mcp.json"

section "Existing Bob config (migration target)"
report "bob" ".bob/mcp.json" ".bob/custom_modes.yaml" ".bobignore" ".bobrules"
report_glob "bob-rules"  ".bob/rules"  "*.md"
report_glob "bob-skills" ".bob/skills" "SKILL.md"

echo
if [ "$found_any" -eq 0 ]; then
  echo "No source-tool config found in this path."
  echo "Check global locations: ~/.cursor/, ~/.claude/, ~/.config/, or VS Code user settings."
  echo "Then ask the user which tool they migrated from."
else
  echo "Done. Migrate each artifact above per the migrate-to-bob skill (Phases 2-5)."
fi
