---
name: present
description: Self-review, create PR, and handle the feedback loop. Takes implemented code through review, PR creation, evidence gathering, and responding to every piece of feedback. Works standalone or as part of /ks-feature or /ks-ticket workflow.
version: 1.0.0
argument-hint: "[PR number or 'current']"
---

# Present

Present your work through self-review, PR creation, and the feedback loop.

## Core Principle

**Never ignore feedback. Every comment gets a response.**

If you agree with feedback, make the change and reply with the commit link. If you disagree, reply with clear rationale. This ensures every piece of feedback is acknowledged and addressed.

---

## Phase 1: Self-Review

### Step 1.1: Review All Changes

Before creating a PR, examine every change:

```bash
# View all changes from develop
git diff develop...HEAD

# List all modified files
git diff --name-only develop...HEAD

# View commit history
git log develop..HEAD --oneline
```

### Step 1.2: Self-Review Checklist

For each changed file, verify:

- [ ] Change relates directly to the ticket
- [ ] No accidental inclusions (unrelated files)
- [ ] No debug code (`console.log`, `binding.pry`, `puts`)
- [ ] No commented-out code
- [ ] Naming is clear and consistent
- [ ] Comments explain WHY (not WHAT)
- [ ] Tests cover the changes
- [ ] DRY opportunities identified
- [ ] F5 Principle preserved (new dependencies in package manager, env vars documented)

### Step 1.3: Run Quality Checks

Final verification before PR:

```bash
# All tests
bin/rails test

# All linters
bin/lint

# Security scan
bin/brakeman
```

All must pass before creating PR.

---

## Phase 2: Evidence Gathering

### Step 2.1: Record Video Walkthrough (Optional)

Use `/compound-engineering:feature-video` to record a demonstration:

- Show the feature working
- Walk through key user flows
- Demonstrate acceptance criteria being met

### Step 2.2: Take Screenshots

Capture before/after screenshots for UI changes:

```bash
# Take screenshot using browser tools or
# Use Playwright for automated screenshots
```

### Step 2.3: Document Test Results

```bash
# Get test summary
bin/rails test 2>&1 | tail -20
```

---

## Phase 3: Create Pull Request

### Step 3.1: Determine Target Branch

```bash
# Feature branches → develop
# Hotfix branches → main
TARGET_BRANCH="develop"
```

### Step 3.2: Create PR

```bash
gh pr create \
  --base develop \
  --title "feat(scope): brief description" \
  --body "$(cat <<'EOF'
## Summary

[Brief description of what this PR does and why]

## Changes

- [Change 1]
- [Change 2]
- [Change 3]

## Test Plan

- [ ] Unit tests added/updated
- [ ] Manual testing performed
- [ ] Verified acceptance criteria

## Screenshots

[Include if UI changes]

## Checklist

- [ ] Tests pass
- [ ] Linters pass
- [ ] Self-review complete

Refs #[TICKET_NUMBER]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Step 3.3: Get PR Details

```bash
PR_NUMBER=$(gh pr view --json number -q '.number')
PR_URL=$(gh pr view --json url -q '.url')
echo "PR created: $PR_URL"
```

---

## Phase 4: Review Environment (if applicable)

### Step 4.1: Verify in Staging

If the project has preview deployments:

```bash
# Wait for deployment
gh pr checks $PR_NUMBER

# Get preview URL (project-specific)
```

### Step 4.2: Run Browser Tests

If applicable, run Playwright tests:

```bash
/compound-engineering:playwright-test
```

---

## Phase 5: Feedback Loop

### Step 5.1: Wait for Copilot Review

Monitor for automated review:

```bash
# Check for reviews
gh pr view $PR_NUMBER --json reviews -q '.reviews[] | select(.author.login == "copilot")'
```

### Step 5.2: Get All Comments

```bash
# Get PR comments
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments \
  --jq '.[] | {id: .id, path: .path, line: .line, body: .body, user: .user.login}'

# Get review comments
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/reviews \
  --jq '.[] | {id: .id, body: .body, user: .user.login, state: .state}'
```

### Step 5.3: Evaluate Each Comment

For each piece of feedback, determine the appropriate response.

#### If You AGREE With the Feedback

1. **Make the change**
2. **Commit with descriptive message**

   ```bash
   git add .
   git commit -m "$(cat <<'EOF'
   fix(scope): address review feedback

   [Description of what changed]

   Refs #[TICKET_NUMBER]

   Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
   EOF
   )"
   ```

3. **Push the commit**

   ```bash
   git push
   ```

4. **Get the commit SHA**

   ```bash
   COMMIT_SHA=$(git rev-parse --short HEAD)
   ```

5. **Reply to the comment**

   ```bash
   gh api -X POST repos/{owner}/{repo}/pulls/$PR_NUMBER/comments/{comment_id}/replies \
     -f body="Addressed with the help of Claude Code in $COMMIT_SHA. [1-2 sentence summary]."
   ```

#### If You DISAGREE With the Feedback

1. **Identify the relevant guideline or pattern**
2. **Reply with clear rationale**

   ```bash
   gh api -X POST repos/{owner}/{repo}/pulls/$PR_NUMBER/comments/{comment_id}/replies \
     -f body="This follows [specific guideline/pattern]. [Clear explanation]. See [reference if applicable]."
   ```

### Step 5.4: Response Templates

**For accepted feedback:**

```text
Addressed with the help of Claude Code in [commit-sha]. [Summary of change].
```

Examples:

- "Addressed with the help of Claude Code in a1b2c3d. Added error handling for nil case."
- "Addressed with the help of Claude Code in e4f5g6h. Extracted validation to a private method."

**For declined feedback:**

```text
This [pattern/approach] follows [guideline/convention]. [Explanation]. [Reference if applicable].
```

Examples:

- "This follows the existing pattern in `app/services/`. Changing would create inconsistency."
- "Per our coding guidelines, we extract methods on the second use. This is currently used only once."

### Step 5.5: Verify All Comments Addressed

```bash
# Check for unresolved comments
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments \
  --jq '[.[] | select(.in_reply_to_id == null)] | length'
```

If unresolved comments remain, repeat the evaluation.

### Step 5.6: Run Final Checks

After making changes:

```bash
bin/rails test
bin/lint
```

---

## Phase 6: Ready for Merge

### Step 6.1: Verify All Checks Pass

```bash
gh pr checks $PR_NUMBER
```

### Step 6.2: Get Final PR Status

```bash
PR_URL=$(gh pr view --json url -q '.url')
PR_TITLE=$(gh pr view --json title -q '.title')
PR_BRANCH=$(gh pr view --json headRefName -q '.headRefName')
```

### Step 6.3: Present Ready Notification

**Claude does not merge PRs.** Output notification for user:

```markdown
---

## PR Ready for Final Review

**PR**: [PR_URL]
**Title**: [PR_TITLE]
**Branch**: [PR_BRANCH] → develop

### Summary

[Brief description of what was built and why]

### Completed Checklist

- [x] Story created following story-writing-guide
- [x] Feature branch from develop
- [x] TDD approach (tests written first)
- [x] All acceptance criteria implemented
- [x] Tests pass
- [x] Linting passes
- [x] Copilot review feedback addressed
- [x] All PR comments responded to

### Files Changed

- [List of key files modified]

### Ready for Your Review

Please review the PR and merge when satisfied.

**To merge:** `gh pr merge [PR_NUMBER] --squash --delete-branch`

---
```

---

## Standalone Usage

When invoked directly (`/ks-present`):

1. Performs self-review
2. Creates PR (if not already created)
3. Gathers evidence
4. Handles feedback loop
5. Notifies when ready for merge

## Workflow Usage

When invoked as part of `/ks-feature` or `/ks-ticket`:

1. Receives context from previous skill
2. Creates PR
3. Handles complete feedback loop
4. Notifies user when ready for final review and merge

---

## Handling Different Comment Types

### Line Comments

Specific code suggestions - usually accept and implement.

### General Review Comments

Architectural or design feedback - evaluate against guidelines.

### Nitpicks

Style preferences - accept unless conflicts with project style guide.

### Questions

Clarification requests - reply with explanation (no code change needed).

---

## API Reference

**Reply to a review comment:**

```bash
gh api -X POST repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
  -f body="Your reply here"
```

**Get comment IDs:**

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '.[] | "\(.id) \(.path):\(.line)"'
```

**Resolve a review thread:**

```bash
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "THREAD_ID"}) {
      thread { isResolved }
    }
  }
'
```

---

## Leveraging compound-engineering

This skill integrates with compound-engineering commands:

- `/compound-engineering:feature-video` - Record video walkthrough
- `/compound-engineering:playwright-test` - Run browser tests
- `/compound-engineering:resolve_todo_parallel` - Address multiple findings
- `/compound-engineering:resolve_pr_parallel` - Parallel PR comment resolution

---

## More Information

- [The F5 Principle](../references/f5-manifesto.md) - "If it isn't scripted, it's magic—bad magic"
- [Guiding Principles](../references/guiding-principles.md) - The six principles
- [Git Integrity](../references/git-integrity.md) - "Thou Shalt Not Lie"
