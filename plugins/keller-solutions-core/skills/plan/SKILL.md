---
name: plan
description: Write great stories and create tickets. Transforms feature descriptions into well-structured stories with proper narrative, acceptance criteria, and ticket creation. Works standalone or as part of /ks-feature workflow.
version: 1.0.0
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

### Step 1.2: Ask Clarifying Questions

If the description is vague, ask focused questions:

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

Work that doesn't directly affect features.

```markdown
Title: Update dependencies

- Update Rails to latest patch version
- Update JavaScript dependencies
- Verify all tests pass
```

---

## CRUD Stories

Admin features often follow Create, Read, Update, Delete patterns. Write these as separate stories with **intentional ordering**—each story should be deliverable and acceptable using only a browser.

You can't test "edit" if nothing exists to edit. Order stories so each builds on the previous:

1. **Read** (list/empty state) → 2. **Create** → 3. **Update** (requires item) → 4. **Delete** (requires item)

Each CRUD story should include confirmation feedback: "[Item name] was created/updated/deleted."

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

[Any specific copy, to be externalized to locale/data files]

## References

[Links to design mockups, prototypes, or external documentation]

## Developer Notes

[Technical guidance that doesn't belong in acceptance criteria]
```

### Developer Notes

Technical context that helps implementation but shouldn't pollute acceptance criteria. Keep criteria browser-verifiable; put implementation hints here.

**Good**: "Standard OneTrust implementation", "Card is sticky on scroll", "See patterns in `app/views/dashboard/`"

**Not Developer Notes**: Observable behavior like "Button is visible" belongs in criteria.

### References

Include links to design assets when available—Figma, prototypes, spreadsheets with calculation logic. This keeps stories self-contained and reduces back-and-forth.

---

## Story Checklist

Before creating the ticket, verify:

- [ ] WHY expresses value (not restated WHAT)
- [ ] WHO is specific (not generic "user")
- [ ] WHAT describes user action (not system behavior)
- [ ] One context, one action, one outcome
- [ ] 4-8 acceptance criteria
- [ ] Each criterion is verifiable in a browser by a non-developer
- [ ] No references to non-existent UI elements
- [ ] Content/copy specified for externalization
- [ ] Design references included where available
- [ ] Developer notes for technical context (not observable behavior)
- [ ] Title is unique and searchable

---

## More Information

- [Guiding Principles](../references/guiding-principles.md) - The six principles
- [The F5 Principle](../references/f5-manifesto.md) - "If it isn't scripted, it's magic—bad magic"
