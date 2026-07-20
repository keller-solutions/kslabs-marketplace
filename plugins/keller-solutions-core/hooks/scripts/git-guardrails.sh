#!/usr/bin/env bash
# KS Core guardrails: deny git never-events, ask on risky-but-sometimes-sanctioned ones.
# PreToolUse hook for Bash tool calls. Fast-exits on anything that isn't a guarded command.
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0

decide() { # $1 = deny|ask, $2 = reason (no double quotes)
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}' "$1" "$2"
  exit 0
}

# 1. Merges are always human — no gh pr merge in any form (including --auto).
if printf '%s' "$cmd" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+merge'; then
  decide deny "Merges are always human (KS git integrity). Hand the PR back with a ready report — the developer merges."
fi

# 2. Never rewrite pushed history — no force pushes.
if printf '%s' "$cmd" | grep -Eq 'git[^|;&]*push[^|;&]*(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$))'; then
  decide deny "Force pushes rewrite pushed history — forbidden by KS git integrity. Fix forward with a new commit instead."
fi

# 3. CLI remote-branch deletion closes dependent PRs (stacked epics) — confirm first.
if printf '%s' "$cmd" | grep -Eq 'git[^|;&]*push[^|;&]*(--delete|[[:space:]]:[[:alnum:]])'; then
  decide ask "CLI remote-branch deletion silently closes dependent PRs. Prefer the GitHub UI/API (auto-retargets children). Proceed only if no open PR depends on this branch."
fi

# 4. Direct commits to integration branches — sanctioned only for release flows.
if printf '%s' "$cmd" | grep -Eq '(^|[|;&][[:space:]]*)git[[:space:]]+commit'; then
  br=$(git branch --show-current 2>/dev/null || echo "")
  case "$br" in
    main|master|develop)
      decide ask "Committing directly to $br — sanctioned only for release flows (publish). Feature work belongs on a feature branch."
      ;;
  esac
fi

exit 0
