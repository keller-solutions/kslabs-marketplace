---
name: produce
description: TDD implementation following Keller Solutions principles. Takes a ticket from story to working code with tests, proper commits, and quality gates. Works standalone or as part of /ks-feature or /ks-ticket workflow.
version: 1.0.0
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
  echo "ERROR: On '$CURRENT_BRANCH' (not a feature branch). Run /ks-prep first."
  exit 1
fi
```

### Step 1.2: Get the Ticket

Retrieve the ticket to implement:

```bash
# If ticket number provided
gh issue view [TICKET_NUMBER] --json title,body,labels

# If "current" or no argument, check branch name for ticket reference
# Or ask user for ticket number
```

### Step 1.3: Update Ticket Status

Move the ticket to "In Progress" to signal work has started. See [managing-tickets](../managing-tickets/SKILL.md) for tool-specific commands.

**Quick reference:**

```bash
# GitHub
gh issue edit [TICKET_NUMBER] --add-label "status:in-progress"

# Jira
jira issue move [TICKET_KEY] "In Progress"

# ClickUp - see managing-tickets skill for full setup
curl -X PUT "https://api.clickup.com/api/v2/task/[TASK_ID]" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"status": "in progress"}'
```

**Note**: Update the ticket status at each major milestone:

- **In Progress**: When starting work
- **In Review**: When PR is created (see `/ks-present`)
- **Done**: When merged (product owner typically handles this)

### Step 1.4: Determine AI Visibility

Check project preference (detected during prep):

- **Visible**: Include `Co-Authored-By` in commits
- **Invisible**: Standard commits without AI attribution

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

Use `/workflows:plan` or create manually:

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

Optionally use `/compound-engineering:deepen-plan` for additional research.

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

#### Step 3.4: Commit

After each criterion is implemented and tests pass:

```bash
git add .
git commit -m "$(cat <<'EOF'
feat(projects): add recent activity sorting

Projects can now be sorted by last activity using the
by_recent_activity scope.

Refs #123

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
git push
```

**Commit rules:**

- Each commit is independently functional with passing tests
- No debug code (`console.log`, `binding.pry`, `puts`)
- No commented-out code
- Reference ticket with `Refs #123`
- Push after each commit (git integrity)

### Repeat for Each Criterion

Continue the Red-Green-Refactor cycle until all acceptance criteria are implemented.

---

## UI Implementation: Frontend Design

When implementing user-facing UI components, invoke `/frontend-design`. Use it for new pages, components, or any work where aesthetics matter.

**Integration with TDD**: Write the test for behavior first, then use frontend-design for implementation. The test verifies *what* the UI does; frontend-design ensures it looks exceptional.

---

## Phase 4: Quality Gates

### Step 4.1: Run All Tests

```bash
# Rails
bin/rails test

# JavaScript
npm test

# System tests (if applicable)
bin/rails test:system
```

All tests must pass.

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

Verify test coverage meets standards (100%):

```bash
# Coverage report is typically generated with test run
open coverage/index.html
```

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

### Step 4.5: Update CHANGELOG

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

#### Validate and Commit

```bash
# Find changelog file (CHANGELOG.md is most common)
CHANGELOG_FILE=$(ls CHANGELOG.md CHANGELOG HISTORY.md CHANGES.md 2>/dev/null | head -1)

# Check structure
grep -E "^## \[" "$CHANGELOG_FILE" | head -3

# Commit update
git add "$CHANGELOG_FILE" && git commit -m "docs(changelog): document changes for #[TICKET]" && git push
```

---

## Phase 5: Ready Report

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

### Files Changed

- [file1.rb] - [brief description]
- [file2.rb] - [brief description]
- [test/file1_test.rb] - [brief description]

Ready to proceed with `/ks-present` to create PR and handle review.
```

---

## Standalone Usage

When invoked directly (`/ks-produce <ticket>`):

1. Performs pre-flight checks
2. Builds execution plan
3. Implements using TDD
4. Runs quality gates
5. Reports completion
6. Ends without proceeding to next phase

## Workflow Usage

When invoked as part of `/ks-feature` or `/ks-ticket`:

1. Receives ticket from previous skill
2. Implements using TDD
3. Runs quality gates
4. Automatically proceeds to `/ks-present`

---

## The Six Principles (Quick Reference)

Apply these principles with every commit. See [Guiding Principles](../references/guiding-principles.md) for details.

1. **DRY**: Extract on the second use, not the first
2. **Separate Code From Content**: No literal strings in views, use i18n
3. **Avoid Pre-Optimization**: Build only what the story requires
4. **Keep Code Tidy**: No commented-out code, no debug traces
5. **Maintain Consistency**: Follow established patterns everywhere
6. **Make It Understandable**: Spell out names, code is read more than written

---

## Git Integrity

**Never put yourself in a position where you have to force push.** Push after each commit. No rebasing, amending, or squashing pushed commits. See [Git Integrity](../references/git-integrity.md) for details.

---

## Maintaining the F5 Principle

Every feature should preserve the F5 principle: clone, setup, run. See [The F5 Principle](../references/f5-manifesto.md) for full details.

**Before completing a feature, verify:**

- New dependencies added via package manager (not manual install)
- New env vars documented in `.env.example`
- Database changes handled by migrations
- External services have mock/stub options for development

**The test**: Can a new developer run `bin/setup && bin/dev` without additional steps?

---

## Leveraging Dependent Plugins

This skill integrates with commands from dependent plugins:

### compound-engineering

- `/workflows:plan` - Detailed execution planning
- `/compound-engineering:deepen-plan` - Research and best practices
- `/workflows:work` - TDD implementation assistance
- `/workflows:review` - Self-review before PR
- `/compound-engineering:resolve_todo_parallel` - Address review findings
- `/compound-engineering:lint` - Run all linters

### frontend-design

- `/frontend-design` - Create distinctive, production-grade UI components

Use frontend-design whenever implementing visual interfaces. It prevents generic "AI slop" aesthetics and produces memorable, polished designs with intentional typography, color, and motion.

---

## More Information

- [The F5 Principle](../references/f5-manifesto.md) - "If it isn't scripted, it's magic—bad magic"
- [Guiding Principles](../references/guiding-principles.md) - The six principles
- [Git Integrity](../references/git-integrity.md) - "Thou Shalt Not Lie"
- [Test Coverage Philosophy](../references/test-coverage-philosophy.md) - Why 100% coverage matters
