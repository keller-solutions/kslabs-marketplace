#!/usr/bin/env bash
# KS Core guardrails: deny git never-events, ask on risky-but-sometimes-sanctioned ones.
# PreToolUse hook for Bash tool calls. Fast-exits on anything that isn't a guarded command.
# Patterns anchor to command position — text inside commit messages/strings is not matched.
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0

decide() { # $1 = deny|ask, $2 = reason (jq guarantees valid JSON whatever the text)
  jq -cn --arg d "$1" --arg r "$2" \
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":$d,"permissionDecisionReason":$r}}'
  exit 0
}

# Command-position anchor: start of string, or after ; | & (covers && and || via their second char).
ANCHOR='(^|[;|&][[:space:]]*)'

# 1. Merges are always human — no gh pr merge in any form (including --auto).
#    Known accepted false positive: `gh pr merge --help` is also denied.
if printf '%s' "$cmd" | grep -Eq "${ANCHOR}gh[[:space:]]+pr[[:space:]]+merge"; then
  decide deny "Merges are always human (KS git integrity). Hand the PR back with a ready report — the developer merges."
fi

# 2. Never rewrite pushed history — no force pushes: flags or +refspec (git push origin +main).
if printf '%s' "$cmd" | grep -Eq "${ANCHOR}git[^|;&]*push[^|;&]*(--force|--force-with-lease|[[:space:]]-f([[:space:]]|$)|[[:space:]]\\+[^[:space:]])"; then
  decide deny "Force pushes rewrite pushed history — forbidden by KS git integrity. Fix forward with a new commit instead."
fi

# 3. CLI remote-branch deletion closes dependent PRs (stacked epics) — confirm first.
#    Tag deletions (refs/tags/) are exempt — no PRs depend on tags.
if printf '%s' "$cmd" | grep -Eq "${ANCHOR}git[^|;&]*push[^|;&]*(--delete|[[:space:]]:[[:alnum:]])" \
   && ! printf '%s' "$cmd" | grep -q 'refs/tags/'; then
  decide ask "CLI remote-branch deletion silently closes dependent PRs. Prefer the GitHub UI/API (auto-retargets children). Proceed only if no open PR depends on this branch."
fi

# 4. Direct commits to integration branches — sanctioned only for release flows.
if printf '%s' "$cmd" | grep -Eq "${ANCHOR}git[[:space:]]+commit"; then
  br=$(git branch --show-current 2>/dev/null || echo "")
  case "$br" in
    main|master|develop)
      decide ask "Committing directly to $br — sanctioned only for release flows (publish). Feature work belongs on a feature branch."
      ;;
  esac
fi

exit 0
