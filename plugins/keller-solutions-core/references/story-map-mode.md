# Story Map Mode

For a single feature, the plan skill's phases run once and end in a ticket. For a **feature set**—a new portal, a new client area, anything spanning multiple screens or producing a large batch of stories—switch to story-map mode and write the full map as markdown **before** any tickets exist.

All of the plan skill's rules apply to every story in the map: the narrative format, the Cardinal Rule, Deliver Without Seeding, Elements Ship With Their Stories, the perspective rule, and the Story Checklist. This document covers what changes at map scale.

## Structure

- **Epics**: coherent, independently understandable slices of the platform, each with a one-line goal, in delivery order. Foundation epics (shell/layout, data sync, auth) come first; then configuration/admin surfaces; then consumer flows—per Deliver Without Seeding, there's nothing to consume until someone can configure it.
- **Continuous numbering**: number epics continuously across all files; story IDs are `<epic>.<story>` (e.g. `13.9`), globally unique, and must never collide with design screen codes (A1–A8, B1–B5). Once IDs are referenced elsewhere (estimates, decision logs), **never renumber**—a new story takes the next free number in its epic.
- **Granularity**: if a calibration helps, 5–8 epics with 30–50 stories is not unreasonable for a two-portal platform—but that is guidance, not a cap and not a target. Be detailed and thorough and let the count land where it lands.

## Coverage Tables

For each screen, enumerate **every element**—nav items, buttons, filters, tables, modals, steppers, empty states, error states, status chips, bulk flows—and assign each to exactly one story (or explicitly to a shared/foundation story). Record this in a Screen Coverage appendix, one table per screen (`element → story ID`). **An element with no story is a gap**: write the story or ask.

A screen's first story does not ship the whole screen. Per Elements Ship With Their Stories, each interactive affordance appears only when its story ships—the coverage table records where, and the screen accretes story by story.

When the source is a spec or a prose description rather than screens, the unit of coverage is the **interaction**: enumerate every action the source implies and assign each to exactly one story. An uncovered interaction is a gap all the same.

## The Sync Rule

When a story uncovers functionality that changes the architecture, update the architecture document **first**, then repair every already-written story affected by the change, **before** writing the next story. The architecture document and the story map must match in both directions at all times.

## The Checkpoint

Pause for explicit user sign-off between architecture and storycarding. Surface any decision that would contaminate many stories (e.g., the auth model) at this checkpoint. If the user leaves it open, card to the current design and tag affected stories (e.g. `⟨blocked on auth decision⟩`) rather than stalling.

## The QA Pass

A long carding session drifts: the perspective rule applied rigorously at story 3 gets sloppy by story 33, terminology shifts ("member" becomes "user"), criteria counts creep, Content starts absorbing copy no criterion asserts. The stories written last must obey the rules as strictly as the stories written first—so before presenting the map, re-read the whole set with fresh eyes:

1. **Checklist**: re-read every file end to end; dedupe overlapping stories; verify every story passes the Story Checklist—paying particular attention to the latest-written stories, where drift concentrates.
2. **Consistency**: personas, terminology, ID format, Content/Reference conventions, and criteria granularity match across the entire set.
3. **Order**: walk the delivery order start to finish and confirm each story is acceptable given only the stories before it—the Seeding Test at map scale. No forward dependencies, no placeholder elements shipped early.
4. **Coverage**: every coverage table is complete and each row points at the story where the element (or interaction) actually ships.
5. **Cross-references**: bidirectional ("ships with story X" appears in both stories).
6. **Chore ratio**: under 10%.
7. **Summarize**: epic list with story counts (chores broken out, with the ratio), open questions needing answers, and Planning Decisions to ratify.

Run the QA pass whenever a session produces more than a handful of stories, even outside full story-map mode.

## Tickets Come Last

In story-map mode, do **not** create tickets while carding. Write the markdown, get the map ratified, then batch-create tickets with the managing-tickets skill.
