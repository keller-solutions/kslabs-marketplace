---
name: ks-feature
description: Full feature workflow from idea to PR-ready. Runs Prepare → Plan → Produce → Present.
argument-hint: "<feature description>"
---

# Feature Workflow

1. `/ralph-loop:ralph-loop "complete all workflow steps" --completion-promise "DONE"`
2. `/ks-prep`
3. `/ks-plan $ARGUMENTS`
4. `/ks-produce`
5. `/compound-engineering:lint`
6. `/ks-present`
7. Output `<promise>DONE</promise>`
