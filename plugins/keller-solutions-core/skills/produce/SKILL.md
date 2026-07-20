---
name: produce
description: TDD implementation following Keller Solutions principles. Takes a ticket from story to working code with tests, one commit per story, and quality gates (including a review across the nine quality dimensions). Works standalone, in an epic loop, or as part of the ks-feature or ks-ticket workflow.
version: 1.4.2
argument-hint: "<ticket number or 'current'>"
---

# Produce

Implement features using Test-Driven Development, following the Keller Solutions guiding principles.

## Core Principle

**Write the test first. Make it pass. Refactor. Repeat.**

Every acceptance criterion becomes a test before it becomes code. This ensures we build only what's needed and can prove it works.

---

## Phase 1: Pre-flight Checks

### Step 1.1: Verify Prep Has Been Run

Confirm the environment is ready:

```bash
# Check we're on a feature branch (not main/develop)
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "develop" ]]; then
  echo "ERROR: On '$CURRENT_BRANCH' (not a feature branch). Run the prep workflow first."
  exit 1
fi
```

### Step 1.2: Get the Ticket

Retrieve the **full ticket body** — never plan from a title (titles-only analysis has produced materially wrong groupings, including working a ticket that was already Closed). **Blocking questions**: if the ticket number is missing or any decision needs the developer, use the platform's blocking question tool (`AskUserQuestion` in Claude Code; `request_user_input` in Codex; otherwise present numbered options in chat and wait for the reply) — never silently skip the question or choose a default on the developer's behalf:

```bash
# If ticket number provided
gh issue view [TICKET_NUMBER] --json title,body,labels,state

# If "current" or no argument, check branch name for ticket reference
# Or ask user for ticket number
```

### Step 1.3: Update Ticket Status

Move the ticket to "In Progress" **before the first line of code** — a watcher of the board should never see code appear ahead of status. See [managing-tickets](../managing-tickets/SKILL.md) for tool-specific commands.

**Quick reference:**

```bash
# GitHub
gh issue edit [TICKET_NUMBER] --add-label "status:in-progress"

# Jira
jira issue move [TICKET_KEY] "In Progress"

# ClickUp - see managing-tickets skill for full setup
curl -X PUT "https://api.clickup.com/api/v2/task/[TASK_ID]" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" -H "Content-Type: application/json" \
  -d '{"status": "in progress"}'

# Azure DevOps
az boards work-item update --id [WORK_ITEM_ID] --state "Active"
```

**Note**: Use the project's own status names (discovered during prep) and keep the ticket accurate in real time. The standard milestones:

- **In Progress**: When starting work
- **In Review / Awaiting Review**: When the PR is created (the present phase) — or, in **Epic Mode**, the moment a child's commit and evidence land, even though the single PR comes later. See [Epic Mode](../../references/epic-mode.md).
- **Done**: When merged (product owner typically handles this)

### Step 1.4: Determine AI Visibility

Check project preference (detected during prep) and apply it to **every** commit, PR body, and feedback reply — the examples in this skill show the Visible form:

- **Visible**: Include a generic co-author trailer, e.g. `Co-Authored-By: Claude <noreply@anthropic.com>` — use the coding agent's own identity, never a model-version string, which goes stale
- **Invisible**: Standard commits and replies with zero AI references — omit the trailer, the PR badge, and "with the help of Claude Code" phrasing entirely

### Step 1.5: Create/Verify Feature Branch

If not already on a feature branch:

```bash
git checkout develop
git pull origin develop
git checkout -b feature/[descriptive-name]
```

Branch naming:

- `feature/user-dashboard` - New features
- `bugfix/filter-pagination` - Bug fixes
- `hotfix/critical-security-fix` - Urgent production fixes

---

## Phase 2: Build the Execution Plan

### Step 2.1: Parse Acceptance Criteria

Extract each acceptance criterion from the ticket. Each criterion will become at least one test.

### Step 2.2: Check for Existing Patterns

Before implementing, search for related code:

```bash
# Find similar components/features
grep -r "similar_pattern" app/
```

Reference existing patterns rather than creating new ones.

### Step 2.3: Check ADRs

Review relevant Architecture Decision Records:

```bash
ls docs/adr/*.md
```

If making an architectural decision, create an ADR first (see `templates/ADR-template.md`).

### Step 2.4: Create Execution Plan

Use the ce-plan skill (compound-engineering) or create manually:

```markdown
## Execution Plan

### Ticket: #[NUMBER] - [TITLE]

**Criteria to implement:**
1. [Criterion 1] → Test: [test description]
2. [Criterion 2] → Test: [test description]
3. [Criterion 3] → Test: [test description]

**Patterns to follow:**
- [Reference to existing code/patterns]

**Files to create/modify:**
- [file1.rb]
- [file2.rb]
- [test/file1_test.rb]
```

Optionally use the ce-brainstorm skill (compound-engineering) for additional research.

---

## Phase 3: TDD Implementation

### The Red-Green-Refactor Cycle

For each acceptance criterion:

#### Step 3.1: Write a Failing Test (Red)

Write a test that describes the expected behavior:

**Rails Example:**

```ruby
# test/models/project_test.rb
test "projects are sorted by last activity" do
  old_project = projects(:old)
  new_project = projects(:new)

  old_project.update!(updated_at: 1.week.ago)
  new_project.update!(updated_at: 1.hour.ago)

  sorted = Project.by_recent_activity

  assert_equal new_project, sorted.first
  assert_equal old_project, sorted.last
end
```

**React/TypeScript Example:**

```typescript
// src/components/ProjectList.test.tsx
test('displays projects sorted by last activity', () => {
  const projects = [
    { id: 1, name: 'Old', updatedAt: '2024-01-01' },
    { id: 2, name: 'New', updatedAt: '2024-01-15' }
  ];

  render(<ProjectList projects={projects} />);

  const items = screen.getAllByRole('listitem');
  expect(items[0]).toHaveTextContent('New');
  expect(items[1]).toHaveTextContent('Old');
});
```

Run the test to confirm it fails:

```bash
# Rails
bin/rails test test/models/project_test.rb

# JavaScript
npm test -- --testPathPattern=ProjectList
```

#### Step 3.2: Make the Test Pass (Green)

Write the minimum code to make the test pass:

**Rails Example:**

```ruby
# app/models/project.rb
class Project < ApplicationRecord
  scope :by_recent_activity, -> { order(updated_at: :desc) }
end
```

Run the test to confirm it passes:

```bash
bin/rails test test/models/project_test.rb
```

#### Step 3.3: Refactor

Clean up the code while keeping tests green:

- Remove duplication
- Improve naming
- Extract methods if needed (on second use)

Run full test suite after refactoring:

```bash
bin/rails test
```

#### Step 3.4: Commit (at least once per story)

A user story yields **at least one commit — the floor, not the ceiling**. The natural rhythm is one commit when every criterion passes; additional commits are welcome (a checkpoint worth keeping, a refactor, review feedback) so long as **every commit is shippable** — it compiles and its tests pass on its own. The rare non-shippable checkpoint is prefixed `WIP:` — the exception, never the rule. History is never rewritten to tidy this up ([Git Integrity](../../references/git-integrity.md)); story-level history reads with `git log --first-parent`.

```bash
git add .
git commit -m "$(cat <<'EOF'
feat(projects): add recent activity sorting

Projects can now be sorted by last activity using the
by_recent_activity scope.

Refs #123

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
git push
```

**Commit rules:**

- **At least one commit per story** — one is the floor, not the ceiling; the story boundary stays traceable via the ticket reference on every commit
- **Every commit is shippable** — compiles, tests pass; the rare exception carries a `WIP:` prefix
- No debug code (`console.log`, `binding.pry`, `puts`) or commented-out code
- Reference the ticket in your tool's linking format — `Refs #123` (GitHub), `Refs <id>` with your tool's ID like `Refs EADEV-180` (Jira/ClickUp/Linear), or `AB#123` (Azure DevOps)
- Push after each commit (git integrity — never squash or rewrite later)

### Repeat the Cycle

Run Red-Green-Refactor across the story's criteria, commit (at least once), done. In **Epic Mode** the next story is the next child ticket on the shared epic branch — see [Epic Mode](../../references/epic-mode.md).

---

## UI Implementation: Frontend Design

When implementing user-facing UI components, invoke the frontend-design skill. Use it for new pages, components, or any work where aesthetics matter.

**Integration with TDD**: Write the test for behavior first, then use frontend-design for implementation. The test verifies *what* the UI does; frontend-design ensures it looks exceptional.

**Build only this story's slice of the design.** A wireframe or comp shows the finished page; this story's acceptance criteria define which elements exist today. Do not add placeholder nav items, buttons, or links to `#` for elements that belong to later stories—an element appears only when the story that makes it work ships (Guiding Principle #3: Avoid Pre-Optimization). If the design shows an element no criterion covers, leave it out; if a criterion seems to need an element no story delivers, raise it with the user rather than stubbing it.

---

## Phase 4: Quality Gates

### Step 4.1: Run the Full Quality Gate (CI Parity)

Run the **QUALITY_GATE derived during prep** — everything CI runs, never a subset:

```bash
bin/ci                # when the repo defines it
bin/rails test:all    # Rails fallback — plain `bin/rails test` excludes system tests
npm test              # JavaScript, plus the repo's e2e command
```

Every gate step must pass. Advisory audits (`bundle-audit`, `npm audit`) stay off the blocking path — a failing advisory becomes a proposed lockfile-bump PR, not a red gate. See [Quality Gate](../../references/quality-gate.md).

**Green is necessary, not sufficient.** Any "fixed"/"working" claim also needs runtime proof — screenshot, log line, passing repro, or the running app answering — and troubleshooting has its own tighter rules (no commits until confirmed; two failed attempts → root-cause, not a third patch). See [Verified Fixes](../../references/verified-fix.md).

### Step 4.2: Run Linters

```bash
# All linters (project-specific)
bin/lint

# Or individually:
bin/rubocop           # Ruby
npm run lint          # JavaScript
bin/brakeman          # Security scan
```

Fix any issues immediately.

### Step 4.3: Check Coverage

Verify test coverage meets standards (100%) — the report generates with the test run (`coverage/index.html`). Where total-100 is unreachable (legacy/client repos), the sanctioned fallback is 100% diff coverage, recorded in the project context.

### Step 4.4: Self-Review

Before proceeding to Present:

```bash
# View all changes
git diff develop...HEAD

# List modified files
git diff --name-only develop...HEAD
```

Check:

- [ ] Every change relates to the ticket
- [ ] No accidental inclusions
- [ ] DRY opportunities identified
- [ ] Naming is clear and consistent
- [ ] Comments explain WHY (not WHAT)
- [ ] Quality dimensions reviewed (Step 4.5)

### Step 4.5: Quality Dimensions Review

"It works" is the start of the quality conversation, not the end — a feature can pass every test and still be insecure, slow, inaccessible, invisible to search and AI, fragile under failure, careless with data, unobservable in production, or costly at scale. Before the ready report, triage which of the nine [Quality Dimensions](../../references/quality-dimensions.md) this feature touches (most touch 3–6) — **Security, Performance/CWV, Accessibility, SEO, AEO, Reliability, Privacy, Observability, Cost & Efficiency** — verify each, and record the rest as `N/A — <why>`, never skipped silently. The reference defines each and how to check it; some checks run via existing tooling (e.g. `bin/brakeman` for Security, the test suite for Reliability, a contrast/a11y check for Accessibility), and for the rest you reason from the diff. Carry the result forward — the present phase reports which applied and how each was addressed.

### Step 4.6: Update CHANGELOG

Document changes in [Keep a Changelog](https://keepachangelog.com) format before creating PR.

#### Add Entry to [Unreleased] Section

```markdown
## [Unreleased]

### Added
- New feature X for ticket #123

### Changed
- Updated behavior Y for ticket #123
```

**Categories**: Added, Changed, Deprecated, Removed, Fixed, Security

#### The Discipline

**Every change lands in `[Unreleased]`, in the same commit as the story it documents** — the changelog entry is part of the work, not an afterthought commit. In repos that keep a changelog, the self-check fails a story that changed code but not the changelog. Repos without one: say so once in the ready report (adoption is a per-repo decision to surface, never to force) and move on.

```bash
# Find changelog file (CHANGELOG.md is most common)
CHANGELOG_FILE=$(ls CHANGELOG.md CHANGELOG HISTORY.md CHANGES.md 2>/dev/null | head -1)

# Check structure, then include the edit in the story's commit
grep -E "^## \[" "$CHANGELOG_FILE" | head -3
```

At release time, publish promotes `[Unreleased]` into the new version section — entries written now, curated then.

---

## Phase 5: Ready Report

Print the checklist below with **honest ✓/✗ verdicts** ([Self-Check](../../references/self-check.md)). Any ✗ retitles this "Implementation Status" — the words "complete"/"done" are earned by an all-✓ list, and the last line names what remains.

Output implementation summary:

```markdown
## Implementation Complete

**Ticket**: #[NUMBER] - [TITLE]
**Branch**: [BRANCH_NAME]

### Criteria Implemented

- [x] [Criterion 1] - implemented in [commit]
- [x] [Criterion 2] - implemented in [commit]
- [x] [Criterion 3] - implemented in [commit]

### Quality Gates

- [x] All tests passing ([count] tests)
- [x] Linters passing
- [x] Coverage at [X]%
- [x] Quality dimensions reviewed ([applicable ones, e.g. Security, Accessibility, Reliability])

### Files Changed

- [file1.rb] - [brief description]
- [file2.rb] - [brief description]
- [test/file1_test.rb] - [brief description]

Ready to proceed with the ks-present workflow to create PR and handle review.
```

---

## Standalone Usage

When invoked directly (the ks-produce workflow with a ticket number or 'current'):

1. Performs pre-flight checks
2. Builds execution plan
3. Implements using TDD
4. Runs quality gates
5. Reports completion
6. Ends without proceeding to next phase

## Workflow Usage

When invoked as part of the ks-feature or ks-ticket workflow:

1. Receives ticket from previous skill
2. Implements using TDD
3. Runs quality gates
4. Automatically proceeds to the present phase

---

## The Six Principles (Quick Reference)

Apply these principles with every commit. See [Guiding Principles](../../references/guiding-principles.md) for details.

1. **DRY**: Extract on the second use, not the first
2. **Separate Code From Content**: No literal strings in views, use i18n
3. **Avoid Pre-Optimization**: Build only what the story requires—no placeholder UI for later stories
4. **Keep Code Tidy**: No commented-out code, no debug traces
5. **Maintain Consistency**: Follow established patterns everywhere
6. **Make It Understandable**: Spell out names, code is read more than written

---

## Git Integrity

**Never put yourself in a position where you have to force push.** Push after each commit. No rebasing, amending, or squashing pushed commits. See [Git Integrity](../../references/git-integrity.md) for details.

---

## Maintaining the F5 Principle

Every feature should preserve the F5 principle: clone, setup, run. See [The F5 Principle](../../references/f5-manifesto.md) for full details.

**Before completing a feature, verify:**

- New dependencies added via package manager (not manual install)
- New env vars documented in `.env.example`
- Database changes handled by migrations
- External services have mock/stub options for development

**The test**: Can a new developer run `bin/setup && bin/dev` without additional steps?

---

## Leveraging Dependent Plugins

This skill integrates with skills from dependent plugins:

### compound-engineering

Verified against compound-engineering **3.19.0** (v3 renamed everything to `ce-*`). If a helper skill is missing in your install, do the step manually — the process stands without the helper.

- `ce-plan` - Detailed execution planning
- `ce-brainstorm` - Research and idea development
- `ce-work` - TDD implementation assistance
- `ce-code-review` - Self-review before PR
- `ce-resolve-pr-feedback` - Address review findings
- `ce-simplify-code` - Simplification pass on the final diff

### frontend-design

- `frontend-design` - Create distinctive, production-grade UI components. Use whenever implementing visual interfaces — it prevents generic "AI slop" aesthetics and produces polished designs with intentional typography, color, and motion.

---

## More Information

- [The F5 Principle](../../references/f5-manifesto.md) - "If it isn't scripted, it's magic—bad magic"
- [Guiding Principles](../../references/guiding-principles.md) - The six principles
- [Quality Dimensions](../../references/quality-dimensions.md) - The nine dimensions every feature is evaluated against
- [Epic Mode](../../references/epic-mode.md) - One commit per child story; whole epic in one branch/PR
- [Git Integrity](../../references/git-integrity.md) - "Thou Shalt Not Lie"
- [Test Coverage Philosophy](../../references/test-coverage-philosophy.md) - Why 100% coverage matters
