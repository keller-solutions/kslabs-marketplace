# Guardrails: Never-Events, Enforced

The plugin ships deterministic guardrails in `hooks/` — instruction text advises, hooks enforce. Every denial says what to do instead.

## What's Enforced (always-on, all sessions)

| Action | Decision | Instead |
|--------|----------|---------|
| `gh pr merge` (any form, incl. `--auto`) | **Deny** | Hand the PR back with a ready report — merging is always the developer's act |
| `git push --force` / `--force-with-lease` / `-f` | **Deny** | Fix forward with a new commit; pushed history is never rewritten |
| `git push --delete` / colon-refspec deletion | **Ask** | Delete merged branches via the GitHub UI/API — CLI deletion silently closes dependent PRs |
| `git commit` while on `main`/`master`/`develop` | **Ask** | Feature work belongs on a branch; direct commits are sanctioned only for release flows |

Only universally-safe rules live in the always-on set. Pipeline-specific gates (checklist enforcement, evidence checks) belong in **skill-scoped hooks** (declared in a skill's frontmatter, active only while that skill runs) so casual sessions stay unaffected.

## Honest Limits

- Hooks see tool calls, not subprocesses: a script that itself force-pushes won't be caught. The guardrail raises the floor; it isn't a sandbox.
- Pattern matching can be fooled by exotic quoting or exec wrappers. Treat a bypassed guardrail as a bug to report, never a loophole to use.
- Patterns anchor to command position, so commit messages *mentioning* guarded commands pass through; accepted false positive: `gh pr merge --help` is denied (the denial text explains itself). Plus-refspec force pushes (`git push origin +main`) are covered; tag deletions (`:refs/tags/…`) are exempt from the branch-deletion ask.
- Plugins **cannot ship permission rules** — only hooks. For defense in depth, add the equivalents to your user settings once:

```json
"permissions": {
  "deny": [
    "Bash(gh pr merge:*)",
    "Bash(gh pr merge)",
    "Bash(git push --force:*)",
    "Bash(git push -f:*)"
  ]
}
```

## Why These Four

Each rule earned its place: agent-performed merges upset the developer every time they happened; a force push is the unambiguous symptom of history rewriting ([Git Integrity](git-integrity.md)); CLI branch deletion closed dependent PRs in stacked-epic work; and direct integration-branch commits are how "just a quick fix" bypasses the pipeline.
