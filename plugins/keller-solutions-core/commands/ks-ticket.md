---
name: ks-ticket
description: Work on an existing ticket. Runs Prepare → Produce → Present (skips Plan).
argument-hint: "<ticket number>"
---

# Ticket Workflow

1. `/ralph-loop:ralph-loop "complete all workflow steps" --completion-promise "DONE"`
2. `/ks-prep`
3. `/ks-produce $ARGUMENTS`
4. `/compound-engineering:lint`
5. `/ks-present`
6. Output `<promise>DONE</promise>`
