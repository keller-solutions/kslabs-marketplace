# Epic Mode

When `/ks-ticket` (or the produce skill) is invoked with an **epic / parent ticket**, the entire epic is delivered in a **single branch and a single PR**. The epic is a grouping; its child feature stories are the unit of work. All of the produce and present rules apply to each child story — this document covers what changes at epic scale.

## What an Epic Is

- An epic/parent ticket **groups** related feature stories. It has no acceptance criteria of its own and produces **no commit of its own**.
- Each child is a normal user story ("In order to… As a… I want") with its own acceptance criteria and its own **single commit** (see the commit rule in [produce](../skills/produce/SKILL.md): one commit per story, not per criterion).
- An epic with 5 children yields **≥5 commits** (one per child, plus any extras for refactor or review feedback) — none attributed to the epic ticket.

## Detection

Determined from the project's ticket system (identified during [prep](../skills/prep/SKILL.md)):

- **ClickUp** — the ticket is a parent task with **subtasks**; children are the subtasks, in board order.
- **GitHub** — the ticket is labeled/formatted as an epic; children are the **linked/tagged** feature issues.
- **Jira** — Epic issue type; children via Epic Link / parent.
- **Linear** — parent issue or project; children are sub-issues.
- **Azure DevOps** — Epic or Feature work item type; children via parent/child links, in backlog order.

If the ticket has **no children**, it is not an epic — fall back to the normal single-ticket flow.

## One Branch, One PR

- Cut **one branch** for the epic (e.g. `feature/<epic-slug>`) from the default branch, once.
- Every child commits onto that branch. The PR is opened **only after** the last child is done and the in-depth review has run.

## Ordered, Live-Lifecycled Delivery

Work children in **delivery order** (Deliver Without Seeding: each child is independently functional given only the children before it). The board must reflect reality **as you go** — a PM watching during the work session should see each child move *unstarted → in progress → awaiting review*, in order.

For each child, in order:

1. **Status → the project's "in progress" state.**
2. **Implement** via the produce TDD cycle → **one commit** referencing the child (`Refs <child-id>`) → push.
3. **Capture evidence** and attach it to the child ticket now **if the tool supports automated attachment** (ClickUp); otherwise **hold** it for the batch at PR time.
4. **Status → the project's "awaiting review" state.**

The actual state names and the per-tool status/attachment commands are discovered during prep — see [managing-tickets](../skills/managing-tickets/SKILL.md). Evidence buckets: **attach-as-you-go** where the tool's API allows it (ClickUp); **hold-and-batch** where attachment needs developer involvement (GitHub, Jira, Linear, Azure DevOps), posting links inline where possible.

## In-Depth Review Before the PR

After the last child and **before** opening the PR, run an in-depth review **appropriate to the stack** — especially warranted here because the PR delivers many stories at once. **That a review happens is the rule; which review is a project-level determination** (surfaced during prep). For example, a DHH-style review for Rails. Address findings as additional commits on the epic branch.

## Present Once

Run [present](../skills/present/SKILL.md) a **single time** for the whole epic:

- Open **one PR** referencing every child (`Refs <child-id> …`) and the epic. (On GitHub Issues you may use `Closes` to auto-close children on merge; for other tools the epic lifecycle moves them to done — see [managing-tickets](../skills/managing-tickets/SKILL.md).)
- **Batch-attach** any held evidence to its child ticket now.
- **Aggregate** the Quality Dimensions report across the children.
- Request Copilot review, address feedback, then hand to the user for final review + merge.
- On merge, the children (and the epic) move to the project's "done" state.

## Not an Epic?

If the ticket has no children, ignore this document and run the normal **prep → produce → present** flow.
