#!/usr/bin/env bash
#
# codex-tool-map.sh — one-time setup for Codex CLI users of keller-solutions-core.
#
# Upserts a marker-delimited block into ~/.codex/AGENTS.md that translates
# Claude Code tool names into Codex primitives, so skills written against
# Claude Code tooling read naturally in Codex.
#
# Deference rule: if Every's compound-engineering plugin already maintains its
# own tool map there (COMPOUND CODEX TOOL MAP markers), this script adds
# nothing — their block covers the same translations and they keep it current.
#
# Idempotent: re-running replaces the KS block in place. A symlinked AGENTS.md
# is never written through (warns and exits instead).
#
# Pattern credit: adapted from the compound-engineering plugin by Every Inc.

set -eu

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
TARGET="$CODEX_HOME/AGENTS.md"

BEGIN_MARKER='<!-- BEGIN KS CODEX TOOL MAP -->'
END_MARKER='<!-- END KS CODEX TOOL MAP -->'
CE_MARKER='COMPOUND CODEX TOOL MAP'

print_block() {
  cat <<'EOF'
<!-- BEGIN KS CODEX TOOL MAP -->
## Keller Solutions Codex Tool Mapping (Claude Code compatibility)

Skills from the keller-solutions-core plugin reference Claude Code tool
names. In Codex, translate them as follows. Only this block is managed
automatically (by the plugin's scripts/codex-tool-map.sh).

- Read: cat, sed, or rg via shell
- Write: apply_patch, or shell redirection for new files
- Edit/MultiEdit: apply_patch
- Bash: shell_command
- Grep: rg (fallback: grep)
- Glob: rg --files or find
- WebFetch/WebSearch: curl, or whatever web tooling is available
- AskUserQuestion: present the choices as a numbered list in chat and WAIT
  for the user's reply. Never skip the question or pick a default yourself.
- Task (subagent dispatch): do the work yourself, sequentially, in the main
  thread
- TaskCreate/TaskUpdate/TodoWrite (task tracking): update_plan
- Skill or slash-command reference: open that skill's SKILL.md and follow it
- EnterPlanMode/ExitPlanMode: ignore
<!-- END KS CODEX TOOL MAP -->
EOF
}

# Never write through a symlink — clobbering the link target is destructive.
if [ -L "$TARGET" ]; then
  echo "warning: $TARGET is a symlink; refusing to write through it." >&2
  echo "Convert it to a real file first (e.g. cp the link target over the link), then re-run." >&2
  exit 1
fi

# Deference: compound-engineering already maintains a tool map here.
if [ -f "$TARGET" ] && grep -qF "$CE_MARKER" "$TARGET"; then
  echo "compound-engineering's Codex tool map is already present in $TARGET — nothing to add."
  echo "keller-solutions-core leans on their block; it covers the same translations and they keep it current."
  if grep -qF "$BEGIN_MARKER" "$TARGET"; then
    echo "note: a KS tool-map block is also present; it is now redundant and can be deleted."
  fi
  exit 0
fi

# No file yet: create it with just our block.
if [ ! -e "$TARGET" ]; then
  mkdir -p "$CODEX_HOME"
  print_block > "$TARGET"
  echo "created $TARGET with the KS Codex tool map."
  exit 0
fi

if grep -qF "$BEGIN_MARKER" "$TARGET"; then
  # Replace the existing block in place.
  if ! grep -qF "$END_MARKER" "$TARGET"; then
    echo "error: $TARGET has the begin marker but no end marker; fix the file manually, then re-run." >&2
    exit 1
  fi
  tmp_out=$(mktemp "${TARGET}.tmp.XXXXXX")
  tmp_block=$(mktemp "${TARGET}.block.XXXXXX")
  trap 'rm -f "$tmp_out" "$tmp_block"' EXIT
  print_block > "$tmp_block"
  awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" -v blockfile="$tmp_block" '
    $0 == begin { while ((getline line < blockfile) > 0) print line; close(blockfile); skip = 1; next }
    $0 == end   { skip = 0; next }
    skip != 1   { print }
  ' "$TARGET" > "$tmp_out"
  mv "$tmp_out" "$TARGET"
  rm -f "$tmp_block"
  trap - EXIT
  echo "updated the KS Codex tool map block in $TARGET."
else
  # Append our block to the existing file.
  { printf '\n'; print_block; } >> "$TARGET"
  echo "appended the KS Codex tool map to $TARGET."
fi
