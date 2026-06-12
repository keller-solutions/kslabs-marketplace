---
name: plan
description: Write great stories and create tickets. Transforms feature descriptions into well-structured stories with proper narrative, acceptance criteria, and ticket creation. Works standalone or as part of /ks-feature workflow.
version: 1.1.0
argument-hint: "<feature description>"
---

# Plan

Write great stories and create tickets that produce clean, reviewable code.

## Core Principle

**Stories are promissory notes for conversations, not specifications.**

The card captures *what* to discuss; the conversation reveals *how* to build it. Well-written stories produce well-scoped, reviewable pull requests.

---

## Phase 1: Understand the Request

### Step 1.1: Parse the Feature Description

Extract from the user's input:

- **The goal**: What do they want to accomplish?
- **The context**: Where does this happen?
- **The user**: Who benefits from this?
- **Any constraints**: Performance, compatibility, security

### Step 1.2: Ground in the Sources

Before writing, read what already defines the work:

- Requirements documents, designs/wireframes, and prototypes
- The existing architecture and precedents (how similar features are already built in this codebase)

Source material varies—sometimes polished wireframes and a design handoff, sometimes only a written spec, sometimes nothing but the description in the prompt. The method is the same regardless: **break whatever material you have down to its key interactions**, and card each as one context, one action, one outcome. Richer sources mean more verbatim Content and tighter References; thinner sources mean more decisions to make and log. What never changes is the decomposition—and the QA pass at the end to confirm you applied it consistently.

Read designs **just in time**: review the relevant screen in full immediately before writing its story—not from memory of an earlier skim.

When sources conflict, establish a precedence order (typically: most recent client-reviewed design > wireframes > written requirements) and flag material conflicts to the user.

### Step 1.3: Ask Questions as They Arise—Decide and Log the Rest

Don't try to determine every question in advance; real questions surface while writing. When one arises:

- **Genuine product or scope decision, or conflicting sources**: stop and ask the user, focused on the story at hand.
- **Low-stakes or cosmetic call**: decide it yourself and log it in a **Planning Decisions** list (decision / rationale / date) for the user to ratify at the end.

If the initial description is too vague to start at all, ask focused questions first:

```markdown
Before I write the story, I need to clarify a few things:

1. **Who is the primary user?** (e.g., first-time user, returning user, admin)
2. **What's the business value?** (Why does this matter?)
3. **Any specific requirements?** (Performance, accessibility, mobile)
```

Only ask questions that will change the story. Don't ask for the sake of asking.

---

## Phase 2: Write the Story

### The Story Format

Every feature story uses this format:

```markdown
Title: [Who] [action] [where]

**In order to** [business value - WHY]
**As a** [specific persona in context - WHO]
**I want** [user-facing capability - WHAT]

## Acceptance Criteria

- [ ] [Observable outcome 1]
- [ ] [Observable outcome 2]
- [ ] [Observable outcome 3]
- [ ] [Observable outcome 4]
```

### Writing the Narrative

**Order matters**: In order to → As a → I want

This forces justification before description. If you can't articulate the value, the story shouldn't exist.

#### The WHY (In order to)

Express genuine business value, not restatement of the feature:

```markdown
# Bad: restates the WHAT
In order to see a list of projects

# Good: expresses actual value
In order to quickly resume work on recent audits
```

**Test**: Delete the "I want" clause. Can you still understand why this matters?

#### The WHO (As a)

Be specific. Use adjectives that illuminate context:

```markdown
# Vague
As a user...

# Specific
As a first-time user unfamiliar with accessibility terminology...
As a busy consultant running audits for multiple clients...
As a developer reviewing scan results during a sprint...
```

**Stay on the user's side of the glass.** The persona is always someone using the product—never the developer building the feature, the platform itself, or a back-office system/vendor:

```markdown
# Banned personas
As a developer... (building this feature)
As the platform...
As the system...
As a [your company] staff member... (when your company isn't the product's user)
```

(A developer is a legitimate persona only when developers are the product's end users.) If no honest user persona exists, the work is a Chore (see Story Types)—never invent a fake narrative. Frame groundwork as the user-visible capability it enables wherever honestly possible: a data sync exists so "a member sees up-to-date availability," not so "the system has a mirror."

#### The WHAT (I want)

Start with a verb describing what the user can do:

```markdown
# User-centric (good)
I want to see my projects listed by last activity
I want to filter issues by severity

# System-centric (avoid)
I want the system to query the database
I want an API endpoint for projects
```

### Writing Acceptance Criteria

**Guidelines**:

- 4-8 criteria per story
- Each criterion is independently verifiable
- Written as observable outcomes, not implementation steps
- Verifiable by a non-developer using only a browser

```markdown
# Good: observable outcomes (verifiable in browser)
- [ ] Projects header is visible
- [ ] Each project shows name and last scan date
- [ ] Projects are sorted by last activity (most recent first)
- [ ] Clicking a project navigates to the project detail page

# Bad: implementation details (requires reading code)
- [ ] Query uses ORDER BY updated_at DESC
- [ ] Projects are rendered using the ProjectCard component
```

**The Browser Test**: Can a non-developer accept or reject this story by using the application in their browser, the same way an end-user would? If verification requires reading code, database queries, or server logs, rewrite the criteria.

**Annotations**: For complex features, annotate criteria with `(required)`, `(optional)`, or `(conditionally required)` to clarify expectations. Use sparingly—most criteria are implicitly required.

---

## Phase 3: Apply the Cardinal Rule

### One Context, One Action, One Outcome

A story describes a single user doing a single thing to achieve a single result.

**Same action, different contexts = different stories**:

- User on desktop sees navigation
- User on mobile sees navigation (hamburger menu)

**Same context, different actions = different stories**:

- User on scan page sees summary
- User on scan page filters issues

**Same action, different outcomes = different stories**:

- User exports results as PDF
- User exports results as CSV

### Split Large Stories

If a story has more than 8 acceptance criteria, split it:

```markdown
# Too large
Story: User manages projects
(What does "manages" mean? Create? Edit? Delete? Archive?)

# Split properly
Story 1: User creates a new project
Story 2: User renames a project
Story 3: User archives a project
Story 4: User deletes an archived project
```

---

## Phase 4: Check Against Anti-Patterns

Before finalizing, verify the story avoids these issues:

### The Restatement

WHY is just WHAT in different words.

### The Kitchen Sink

Story tries to do too much.

### The Implementation Story

Describes technical work instead of user value.

### The Premature Reference

References UI elements that don't exist yet.

### The Vague Criterion

Criteria that can't be objectively verified.

### The Fake Persona

"As the platform" / "As the system" / "As a developer" (building the feature). If there's no honest user persona, it's a Chore.

### The Placeholder

A story with no acceptance criteria. If you can't state observable outcomes yet, you haven't finished the conversation the card promises.

### The Forward Dependency

Acceptance depends on a story that hasn't shipped yet (see Deliver Without Seeding).

### The Hidden Plumbing

Chores creeping past 10% of the story set—user value is being hidden in technical work. Reframe groundwork as the capability it enables.

### The Wireframe Dump

The first story for a page builds every element the wireframe shows, with siblings linked to `#` "for now." Each element ships with the story that wires it up (see Elements Ship With Their Stories).

---

## Phase 5: Create the Ticket

Use the [managing-tickets](../managing-tickets/SKILL.md) skill for tool-specific commands.

### Detect Project Management Tool

First, detect which tool the project uses:

```bash
# See managing-tickets skill for full detection script
gh issue list --limit 1 2>/dev/null && echo "TOOL=github"
```

### Create the Ticket

Use the appropriate command for your project's tool:

**GitHub Issues:**

```bash
gh issue create \
  --title "User sees project list on dashboard" \
  --body "$(cat <<'EOF'
**In order to** quickly resume work on recent audits
**As a** returning user on the dashboard
**I want** to see my projects listed by last activity

## Acceptance Criteria

- [ ] Projects section header is visible
- [ ] Each project shows name and last scan date
- [ ] Projects are sorted by last activity (most recent first)
- [ ] Clicking a project navigates to the project detail page
- [ ] Empty state shown when no projects exist

## Developer Notes

See existing dashboard patterns in `app/views/dashboard/`.
EOF
)"
```

For **Jira**, **ClickUp**, or **Linear**, see the [managing-tickets](../managing-tickets/SKILL.md) skill for detailed commands.

### Link to Epic (if applicable)

```bash
gh issue edit [ISSUE_NUMBER] --add-label "epic:dashboard-improvements"
```

---

## Phase 6: Output the Result

Present the created story:

```markdown
## Story Created

**Issue**: #[NUMBER]
**Title**: [TITLE]
**URL**: [URL]

### Narrative

**In order to** [WHY]
**As a** [WHO]
**I want** [WHAT]

### Acceptance Criteria

1. [Criterion 1]
2. [Criterion 2]
3. [Criterion 3]
4. [Criterion 4]

Ready to proceed with `/ks-produce` to implement this story.
```

---

## Standalone Usage

When invoked directly (`/ks-plan <description>`):

1. Asks clarifying questions if needed
2. Writes the story
3. Creates the ticket
4. Outputs the result
5. Ends without proceeding to next phase

## Workflow Usage

When invoked as part of `/ks-feature`:

1. Asks clarifying questions if needed
2. Writes the story
3. Creates the ticket
4. Stores the ticket number for subsequent skills
5. Automatically proceeds to `/ks-produce`

---

## Story Types

### Features

Deliver user-visible value. Use full narrative format.

### Bugs

Something that worked before is now broken.

```markdown
Title: [Describes incorrect behavior]

**Steps to reproduce:**
1. Navigate to /scans/123/issues
2. Filter by severity: "critical"
3. Page 1 shows only critical issues (correct)
4. Click "Next" to page 2
5. Page 2 shows all issues (incorrect)

**Expected:** Page 2 shows only critical issues
```

### Chores

Groundwork that genuinely cannot be framed as user-visible value verifiable in a browser. A chore gets a one-line **purpose tied to the user value it unlocks** and **completion criteria a reviewer can check**—no fake user narrative.

```markdown
Title: Chore: Vendor data sync foundation

**Purpose:** every dashboard story reads from a local mirror of the
vendor's data; this lays the sync engine those stories stand on.

**Completion criteria**
- [ ] A recurring job mirrors vendor records locally
- [ ] Re-running the job is idempotent
- [ ] Each run records counts a reviewer can inspect
```

Keep chores **under 10% of total stories**. Above that, you're hiding user value in plumbing—reframe (see The Hidden Plumbing).

---

## Deliver Without Seeding

**Every story must be acceptable using only what the application—as built by the stories before it—can produce.** A reviewer should never need console commands, fixtures, or hand-seeded data to accept a story, unless that is absolutely unavoidable (e.g., data only an external system can originate).

This is why delivery order matters: each story creates the conditions the next one needs. A story may never depend on a later story.

CRUD is the everyday case. Order it **add → index → detail → edit → delete**: the Add story is how the reviewer gets a record to look at, so it ships first—even when "first" means the section is nothing but an Add button landing on a bare confirmation page. The index arrives in the next story. You can't edit what nothing created.

The same logic reaches well beyond CRUD:

- A notifications story comes after the story for the action that generates notifications.
- An approval-queue story comes after the submission flow that fills the queue.
- A report story comes after the entry flows that populate its data.
- A search story comes after the stories that create something searchable.

**The Seeding Test**: Walk the acceptance criteria as the reviewer. For every precondition ("a project exists", "a request is pending"), can you create it in the browser using only earlier stories? If not, reorder. If reordering is truly impossible, state the seeding requirement explicitly in Developer Notes—and treat it as a smell.

Each mutating story should include confirmation feedback: "[Item name] was created/updated/deleted."

---

## Elements Ship With Their Stories

The flip side of Deliver Without Seeding: just as a story may not lean on later stories, it may not ship fragments of them either. **A UI element appears only when the story that makes it work ships.** Never add a placeholder button, nav item, or link to `#` because the design shows one—that's pre-optimization (Guiding Principle #3), and dead links get reported as bugs.

A wireframe or comp is a map of where future stories will land, not a checklist for the first story to touch that page. The screen accretes element by element as its stories ship.

Write stories knowing this and they describe elements differently: the story that delivers a destination also delivers its entry point, and an early criterion asserts the element appears. The classic example is the About page. The global-nav About link is not part of a "build the nav" story—it ships with the story that gives it somewhere to go:

```markdown
Title: User visits the About Us page

**In order to** learn more about the company
**As a** user on any page in the site
**I want** to view the About Us page

## Acceptance Criteria

- [ ] About Us link is present in the global nav
- [ ] Clicking About Us takes me to the About Us page
- [ ] I see the About Us headline and copy with images specified in the copy doc
```

A second entry point is a second story (different context—see the Cardinal Rule):

```markdown
Title: User visits the About Us page from the footer

**In order to** quickly access the About page without scrolling back to the top
**As a** user at the bottom of any page in the site
**I want** to visit the About Us page

## Acceptance Criteria

- [ ] About Us link is present in the footer nav
- [ ] Clicking About Us takes me to the About Us page
```

---

## Story Map Mode

For a single feature, the phases above run once and end in a ticket. For a **feature set**—a new portal, a new client area, anything spanning multiple screens or producing a large batch of stories—switch to story-map mode and write the full map as markdown **before** any tickets exist.

### Structure

- **Epics**: coherent, independently understandable slices of the platform, each with a one-line goal, in delivery order. Foundation epics (shell/layout, data sync, auth) come first; then configuration/admin surfaces; then consumer flows—per Deliver Without Seeding, there's nothing to consume until someone can configure it.
- **Continuous numbering**: number epics continuously across all files; story IDs are `<epic>.<story>` (e.g. `13.9`), globally unique, and must never collide with design screen codes (A1–A8, B1–B5). Once IDs are referenced elsewhere (estimates, decision logs), **never renumber**—a new story takes the next free number in its epic.
- **Granularity**: if a calibration helps, 5–8 epics with 30–50 stories is not unreasonable for a two-portal platform—but that is guidance, not a cap and not a target. Be detailed and thorough and let the count land where it lands.

### Coverage Tables

For each screen, enumerate **every element**—nav items, buttons, filters, tables, modals, steppers, empty states, error states, status chips, bulk flows—and assign each to exactly one story (or explicitly to a shared/foundation story). Record this in a Screen Coverage appendix, one table per screen (`element → story ID`). **An element with no story is a gap**: write the story or ask.

A screen's first story does not ship the whole screen. Per Elements Ship With Their Stories, each interactive affordance appears only when its story ships—the coverage table records where, and the screen accretes story by story.

When the source is a spec or a prose description rather than screens, the unit of coverage is the **interaction**: enumerate every action the source implies and assign each to exactly one story. An uncovered interaction is a gap all the same.

### The Sync Rule

When a story uncovers functionality that changes the architecture, update the architecture document **first**, then repair every already-written story affected by the change, **before** writing the next story. The architecture document and the story map must match in both directions at all times.

### The Checkpoint

Pause for explicit user sign-off between architecture and storycarding. Surface any decision that would contaminate many stories (e.g., the auth model) at this checkpoint. If the user leaves it open, card to the current design and tag affected stories (e.g. `⟨blocked on auth decision⟩`) rather than stalling.

### The QA Pass

A long carding session drifts: the perspective rule applied rigorously at story 3 gets sloppy by story 33, terminology shifts ("member" becomes "user"), criteria counts creep, Content starts absorbing copy no criterion asserts. The stories written last must obey the rules as strictly as the stories written first—so before presenting the map, re-read the whole set with fresh eyes:

1. **Checklist**: re-read every file end to end; dedupe overlapping stories; verify every story passes the Story Checklist—paying particular attention to the latest-written stories, where drift concentrates.
2. **Consistency**: personas, terminology, ID format, Content/Reference conventions, and criteria granularity match across the entire set.
3. **Order**: walk the delivery order start to finish and confirm each story is acceptable given only the stories before it—the Seeding Test at map scale. No forward dependencies, no placeholder elements shipped early.
4. **Coverage**: every coverage table is complete and each row points at the story where the element (or interaction) actually ships.
5. **Cross-references**: bidirectional ("ships with story X" appears in both stories).
6. **Chore ratio**: under 10%.
7. **Summarize**: epic list with story counts (chores broken out, with the ratio), open questions needing answers, and Planning Decisions to ratify.

Run the QA pass whenever a session produces more than a handful of stories, even outside full story-map mode.

### Tickets Come Last

In story-map mode, do **not** create tickets while carding. Write the markdown, get the map ratified, then batch-create tickets with [managing-tickets](../managing-tickets/SKILL.md).

---

## Story Template (Quick Reference)

```markdown
Title: [Who] [action] [where]

**In order to** [business value]
**As a** [specific persona in context]
**I want** [user-facing capability]

## Acceptance Criteria

- [ ] [Observable outcome 1]
- [ ] [Observable outcome 2]
- [ ] [Observable outcome 3]
- [ ] [Observable outcome 4]

## Content

[Only copy an acceptance criterion asserts verbatim—button labels,
headlines, error/empty-state/confirmation messages]

## References

[Specific artifact + location: screen IDs, design files, source docs]

## Developer Notes

[Technical guidance that doesn't belong in acceptance criteria]
```

### Content

Only copy that an acceptance criterion asserts **verbatim**—button labels, headlines, error/empty-state/confirmation messages. For everything else, point References at the design source instead of transcribing it. Content strings are externalized to locale/data files at build time.

### Developer Notes

Technical context that helps implementation but shouldn't pollute acceptance criteria. Keep criteria browser-verifiable; put implementation hints here.

**Good**: "Standard OneTrust implementation", "Card is sticky on scroll", "See patterns in `app/views/dashboard/`"

**Not Developer Notes**: Observable behavior like "Button is visible" belongs in criteria.

### References

Include links to design assets when available—Figma, prototypes, spreadsheets with calculation logic. This keeps stories self-contained and reduces back-and-forth.

Cite the specific artifact and location, never a bare link or screen code: "Wireframe B2 p.4", "A3 Registrations — bulk add flow", "Figma: Checkout / payment error state".

---

## Story Checklist

For a single story, this checklist is the QA. When a session produces a batch of stories, also run the QA Pass (see Story Map Mode) to catch drift across the set.

Before creating the ticket, verify:

- [ ] WHY expresses value (not restated WHAT)
- [ ] WHO is specific (not generic "user") and on the user's side of the glass (not developer/platform/system)
- [ ] WHAT describes user action (not system behavior)
- [ ] One context, one action, one outcome
- [ ] 4-8 acceptance criteria
- [ ] Each criterion is verifiable in a browser by a non-developer
- [ ] Acceptable using only what earlier stories built—no seeded data, no forward dependencies
- [ ] Entry points (nav links, buttons) are criteria on the story that delivers their destination—no placeholder elements shipped early
- [ ] No references to non-existent UI elements
- [ ] Content holds only copy a criterion asserts verbatim, specified for externalization
- [ ] Design references cite the specific artifact and location
- [ ] Developer notes for technical context (not observable behavior)
- [ ] Title is unique and searchable

---

## More Information

- [Guiding Principles](../references/guiding-principles.md) - The six principles
- [The F5 Principle](../references/f5-manifesto.md) - "If it isn't scripted, it's magic—bad magic"
