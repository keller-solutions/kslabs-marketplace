---
name: ks-ticket
description: Work on an existing ticket. Runs Prepare → Produce → Present (skips Plan). Handles epics as a single branch/PR.
argument-hint: "<ticket number>"
---

# Ticket Workflow

Do each of these steps in order and summarize the results at the end:

1. `/ks-prep`
2. **Determine whether `$ARGUMENTS` is an epic / parent ticket** (a grouping with child feature tickets — e.g. a ClickUp parent with subtasks, or a GitHub issue labeled/linked as an epic). Use the ticket system identified in prep.

   - **If it is an epic** → follow [Epic Mode](../references/epic-mode.md): one branch and one PR for the whole epic; iterate `/ks-produce` over each child feature ticket **in order** (one commit per child, status kept live, evidence captured as each child is done); run the project's in-depth stack review; then `/ks-present` **once** for the whole epic.
   - **If it is a single ticket** → continue with the steps below.

3. `/ks-produce $ARGUMENTS`
4. `/ks-present`
