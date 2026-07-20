# Epic Mode

When `/ks-ticket` (or the produce skill) is invoked with an **epic / parent ticket**, the entire epic is delivered in a **single branch and a single PR**. The epic is a grouping; its child feature stories are the unit of work. All of the produce and present rules apply to each child story — this document covers what changes at epic scale.

## What an Epic Is

- An epic/parent ticket **groups** related feature stories. It has no acceptance criteria of its own and produces **no commit of its own**.
- An **impromptu epic** is the same grouping declared at invocation: several independent tickets passed to `/ks-ticket` together. No parent ticket exists — the passed tickets are the children, delivered in the order given unless dependencies dictate otherwise; everything else in this document applies unchanged.
- Each child is a normal user story ("In order to… As a… I want") with its own acceptance criteria and **at least one commit of its own** (see the commit rule in [produce](../skills/produce/SKILL.md): one per story is the floor, not the ceiling; every commit shippable).
- An epic with 5 children yields **≥5 commits** (one per child, plus any extras for refactor or review feedback) — none attributed to the epic ticket.

## Detection

Determined from the project's ticket system (identified during [prep](../skills/prep/SKILL.md)):

- **ClickUp** — the ticket is a parent task with **subtasks**; children are the subtasks, in board order.
- **GitHub** — the ticket is labeled/formatted as an epic; children are the **linked/tagged** feature issues.
- **Jira** — Epic issue type; children via Epic Link / parent.
- **Linear** — parent issue or project; children are sub-issues.
- **Azure DevOps** — Epic or Feature work item type; children via parent/child links, in backlog order.
- **Impromptu** — multiple ticket IDs passed to `/ks-ticket` directly; the children are exactly those tickets.

If a single ticket has **no children**, it is not an epic — fall back to the normal single-ticket flow.

## One Branch, One PR

- Cut **one branch** for the epic (e.g. `feature/<epic-slug>`) from the default branch, once.
- Every child commits onto that branch. The PR is opened **only after** the last child is done and the in-depth review has run.

## Externalized Run State (survives compaction and session breaks)

Long runs must not live only in conversation memory. At run start, write two files to a **gitignored** `.ks/` directory in the project (add `.ks/` to `.gitignore` on first use — run state is never committed):

- `.ks/epic-<id>-state.json` — the child list in delivery order, each with `id`, `title`, `status` (`pending` / `in-progress` / `in-review` / `blocked: <reason>`), and `commit` once delivered. JSON on purpose: state stays machine-checkable and is harder to accidentally rewrite than prose.
- `.ks/epic-<id>-progress.txt` — appended one-line notes: decisions taken, blockers hit, anything the next session needs.

Update both as each child advances. **Resume ritual** (new session, or after compaction): read the state file, then `git log --oneline -20`, reconcile the two (git is the truth for what landed), and continue from the first non-done child — never re-derive the plan from memory.

## Gate Between Children

After each child's commit is pushed, verify the **full quality gate** ([Quality Gate](quality-gate.md)) before touching the next child — and when the epic branch already has an open PR (stacked delivery), also confirm `gh pr checks` is green. **Child N+1 never starts while child N is red.** A red gate is child N's problem to finish, not a note to leave behind.

## Self-Unblock, Then Park

When a child blocks, don't stop the run for an answer the run can produce:

1. Re-read the child's Developer Notes and the project's **decisions register** (where one exists, e.g. `docs/decisions.md`) — most "blockers" are already-settled questions. Never re-litigate a settled decision without new information; when a genuinely new decision gets made mid-run, append it to the register with the date.
2. Create what's missing when the app can produce it — seeds for dev preconditions, fixtures, config — noting it in progress.txt.
3. Only then mark the child `blocked: <reason>` (mirror the reason as a ticket comment), and continue with the next child **only if it's independent**; otherwise pause the run with the state file telling the next session exactly why and where.

## Stacked Epics (dependent features, separate PRs)

When epic B depends on epic A but A can't merge first — no history rewriting, ever:

- Cut B's branch **from A's branch**; open B's PR **based on A's branch** so reviewers (and Copilot) see only B's delta.
- When A changes, sync B by **merging A into B** (never rebase), then re-verify B's gate.
- When A merges: delete A's branch **via the GitHub UI or API only** — `git push --delete` silently **closes** dependent PRs, while UI/API deletion retargets B's PR to the base branch automatically. Verify the retarget, merge the base branch into B once to absorb the landing, and size-guard B's diff before requesting its Copilot review.

## Ordered, Live-Lifecycled Delivery

Work children in **delivery order** (Deliver Without Seeding: each child is independently functional given only the children before it). The board must reflect reality **as you go** — a PM watching during the work session should see each child move *unstarted → in progress → awaiting review*, in order.

For each child, in order:

1. **Status → the project's "in progress" state.**
2. **Implement** via the produce TDD cycle → **at least one commit** referencing the child (`Refs <child-id>`) → push after each.
3. **Capture evidence** and attach it to the child ticket now **if the tool supports automated attachment** (ClickUp); otherwise **hold** it for the batch at PR time.
4. **Status → the project's "awaiting review" state.**

The actual state names and the per-tool status/attachment commands are discovered during prep — see [managing-tickets](../skills/managing-tickets/SKILL.md). Evidence buckets per [Evidence](evidence.md): **attach-as-you-go** (ClickUp, Azure DevOps, Jira); **hold-and-batch** at PR time (GitHub via browser-upload, Linear via links).

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
