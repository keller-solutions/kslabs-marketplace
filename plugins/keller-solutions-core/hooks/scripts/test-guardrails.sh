#!/usr/bin/env bash
# Regression tests for git-guardrails.sh — run locally or in CI. Exit 0 = all pass.
set -uo pipefail
cd "$(dirname "$0")"
pass=0; fail=0

check() { # $1 desc, $2 command-json-fragment, $3 expected substring ("" = expect empty output)
  out=$(printf '{"tool_input":{"command":"%s"}}' "$2" | ./git-guardrails.sh)
  if [ -z "$3" ]; then
    if [ -z "$out" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL (expected pass-through): $1 → $out"; fi
  else
    if printf '%s' "$out" | grep -q "$3"; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $1 → $out"; fi
  fi
}

check "deny gh pr merge"              "gh pr merge 5 --auto --merge"          '"deny"'
check "deny gh pr merge plain"        "gh pr merge 12"                        '"deny"'
check "deny force push"               "git push --force origin feature/x"     '"deny"'
check "deny force-with-lease"         "git push --force-with-lease"           '"deny"'
check "deny -f push"                  "git push -f"                           '"deny"'
check "ask remote delete"             "git push origin --delete feature/old"  '"ask"'
check "pass benign ls"                "ls -la"                                ""
check "pass normal push"              "git push origin feature/x"             ""
check "pass gh pr view"               "gh pr view 5 --json url"               ""

echo "guardrail tests: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
