---
name: story-create
description: This skill creates GitHub issues using the "In order to / As a / I want" story format. Use when starting a new feature to create a properly formatted story with acceptance criteria. Follows story-writing-guide.md conventions.
version: 0.1.0
argument-hint: "[feature description]"
---

# Story Create

Create a GitHub issue using the proper story format following the Story Writing Guide.

## Feature Description

<feature_description> #$ARGUMENTS </feature_description>

**If empty, ask:** "What feature would you like to build? Describe the user need and expected outcome."

## Story Format

Stories follow the "In order to / As a / I want" format (NOT "As a / I want / So that"):

```markdown
**In order to** [business value - why this matters]
**As a** [specific persona in context]
**I want** [user-facing capability]

## Acceptance Criteria

- [ ] [Observable outcome 1]
- [ ] [Observable outcome 2]
- [ ] [Observable outcome 3]
- [ ] [Observable outcome 4]
```

## Workflow

### Step 1: Read Story Writing Guide (if exists)

```bash
# Check for project-specific guide
if [ -f "docs/story-writing-guide.md" ]; then
  cat docs/story-writing-guide.md
fi
```

Read the guide to understand project conventions.

### Step 2: Craft the Story

Based on the feature description, create a story following these rules:

**The WHY (In order to)**
- Express genuine business value
- NOT a restatement of the feature
- Test: Can you delete "I want" and still understand why this matters?

**The WHO (As a)**
- Be specific with context-illuminating adjectives
- NOT generic "As a user"
- Examples: "first-time user unfamiliar with...", "returning user on the dashboard"

**The WHAT (I want)**
- Start with a verb describing user action
- NOT system behavior
- User-centric: "I want to see...", "I want to filter...", "I want to export..."

**Acceptance Criteria**
- 4-8 criteria per story
- Each independently verifiable
- Observable outcomes, NOT implementation details
- A PM should be able to verify by looking at the screen

### Step 3: Create Title

Combine WHO and WHAT into a scannable title:

```
[Who] [action] [where]
```

Examples:
- "User sees projects on dashboard"
- "Consultant filters issues by severity"
- "Developer exports scan results as PDF"

### Step 4: Validate Before Creating

Checklist:
- [ ] WHY expresses value (not restated WHAT)
- [ ] WHO is specific (not generic "user")
- [ ] WHAT describes user action (not system behavior)
- [ ] One context, one action, one outcome
- [ ] 4-8 acceptance criteria
- [ ] Each criterion is objectively verifiable
- [ ] Title is unique and searchable

### Step 5: Create GitHub Issue

```bash
gh issue create \
  --title "[Who] [action] [where]" \
  --body "$(cat <<'EOF'
**In order to** [business value]
**As a** [specific persona in context]
**I want** [user-facing capability]

## Acceptance Criteria

- [ ] [Observable outcome 1]
- [ ] [Observable outcome 2]
- [ ] [Observable outcome 3]
- [ ] [Observable outcome 4]

## Developer Notes

[Optional: technical guidance, pattern references]
EOF
)"
```

### Step 6: Capture Issue Number

Store the issue number from the output for use in:
- Branch naming: `feature/issue-123-description`
- Commit references: `Refs #123`
- PR linking: `Refs #123`

## Output

Report the created issue:

```
Story Created

Issue: #[number]
Title: [title]
URL: [github url]

Ready to create feature branch with: feature/[description]
```

## Anti-Patterns to Avoid

**The Restatement** - WHY just restates WHAT:
```
# Bad
In order to see my projects
As a user
I want to view a list of my projects

# Good
In order to quickly find and resume work
As a returning user
I want to see my recent projects on the dashboard
```

**The Kitchen Sink** - Story does too much:
```
# Bad
As a user, I want to manage my projects

# Good: Separate stories
- User creates a new project
- User renames a project
- User archives a project
```

**The Vague Criterion**:
```
# Bad
- Page loads quickly
- UI looks good

# Good
- Page loads in under 2 seconds
- Error messages appear in red below the field
```

## Notes

- Stories are promissory notes for conversations, not specifications
- The card captures WHAT to discuss; conversation reveals HOW to build
- One context, one action, one outcome per story
- Each acceptance criterion maps to at least one test
