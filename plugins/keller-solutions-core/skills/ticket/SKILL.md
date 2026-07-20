---
name: ticket
description: Work on existing tickets end-to-end. Runs Prepare → Produce → Present (skips Plan). Accepts one ticket, several tickets (impromptu epic), or an epic/parent ticket. Use when asked to pick up, work, or deliver existing ticket numbers (the ks-ticket workflow).
version: 1.0.1
argument-hint: "<ticket number(s)>"
---

# Ticket Workflow

Deliver existing tickets by running the phases in order, then summarize the results at the end:

1. **Prepare** — run the [prep](../prep/SKILL.md) skill.
2. **Infer the delivery shape from the given ticket reference(s)** — no special syntax; read the arguments and any accompanying instructions as written. Use the ticket system identified in prep, and fetch **full ticket bodies** before deciding (never titles alone):

   - **One ticket that has child feature tickets** (ClickUp subtasks, GitHub epic label/task list, Jira Epic Link, Linear sub-issues, Azure DevOps parent/child links) → it is an **epic**: follow [Epic Mode](../../references/epic-mode.md) — one branch and one PR for the whole epic, children delivered in order, at least one commit per child, status kept live, evidence captured per child, the in-depth stack review, then the present phase **once**.
   - **Multiple tickets** (any phrasing — "23983 and 21408", a comma list, "these three") → an **impromptu epic**: the same Epic Mode treatment with exactly those tickets as the children, in the order given unless dependencies dictate otherwise.
   - **One ticket, no children** → continue with the single-ticket steps below.

   Natural-language modifiers are honored, never required: "stack this on #N" cuts the epic branch from #N's branch (see Epic Mode's stacking mechanics); "hold the PR until I say" finishes produce and evidence but leaves the PR unopened; a propose-shaped ask ("describe what's in effect and propose an updated approach") runs read-only — current state, options, halt for the developer's selection before any implementation. **Confirm the inferred shape in one line before starting** — e.g. "Impromptu epic: EADEV-301 → EADEV-305 → EADEV-299, one branch/PR — starting."

   **Blocking questions**: whenever this workflow needs the developer's answer — a decision, a confirmation, a choice (the halt for the developer's selection in a propose-shaped ask included) — use the platform's blocking question tool (`AskUserQuestion` in Claude Code; `request_user_input` in Codex; otherwise present numbered options in chat and wait for the reply). Never silently skip the question or choose a default on the developer's behalf.

3. **Produce** — run the [produce](../produce/SKILL.md) skill on the ticket(s).
4. **Present** — run the [present](../present/SKILL.md) skill.

Every shape inherits the full process — quality gates, evidence contract, fidelity pass, Copilot loop, live lifecycle. The developer never has to restate it or point at old prompts.
