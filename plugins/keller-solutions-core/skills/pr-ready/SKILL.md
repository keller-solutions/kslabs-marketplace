---
name: pr-ready
description: This skill notifies the user that a PR is ready for final review and merge. Use after completing the feedback loop to summarize the work and hand off to the user. Claude does NOT merge PRs.
version: 0.1.0
argument-hint: "[PR number or 'current']"
---

# PR Ready

Notify the user that the PR is ready for their final review and merge.

## PR Target

<pr_input> #$ARGUMENTS </pr_input>

**If empty:** Use current branch's PR.

## Core Principle

**Claude does NOT merge PRs.** This skill:
1. Verifies all checks pass
2. Summarizes the completed work
3. Notifies the user the PR is ready
4. Hands off for human review and merge

## Workflow

### Step 1: Get PR Details

```bash
PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null)
PR_URL=$(gh pr view --json url -q '.url')
PR_TITLE=$(gh pr view --json title -q '.title')
PR_BRANCH=$(gh pr view --json headRefName -q '.headRefName')
PR_BASE=$(gh pr view --json baseRefName -q '.baseRefName')
```

### Step 2: Verify All Checks Pass

```bash
# Check CI status
gh pr checks $PR_NUMBER

# Verify no failing checks
FAILED=$(gh pr checks $PR_NUMBER --json state -q '[.[] | select(.state == "FAILURE")] | length')
if [ "$FAILED" -gt 0 ]; then
  echo "WARNING: $FAILED checks are failing"
fi
```

### Step 3: Get Linked Issue

```bash
# Extract issue number from PR body or commits
ISSUE_NUMBER=$(gh pr view $PR_NUMBER --json body -q '.body' | grep -oE '#[0-9]+' | head -1)
```

### Step 4: Summarize Changes

```bash
# Get files changed
gh pr view $PR_NUMBER --json files -q '.files[].path'

# Get commit count
gh pr view $PR_NUMBER --json commits -q '.commits | length'
```

### Step 5: Present Ready Notification

Output the following notification to the user:

```markdown
---

## PR Ready for Final Review

**PR:** [PR_URL]
**Title:** [PR_TITLE]
**Branch:** [PR_BRANCH] -> [PR_BASE]
**Issue:** #[ISSUE_NUMBER]

### Summary

[Brief description of what was built and why]

### Completed Checklist

- [x] Story created following story-writing-guide
- [x] Feature branch from develop
- [x] TDD approach (tests written first)
- [x] All acceptance criteria implemented
- [x] Tests pass (`bin/rails test`)
- [x] Linting passes (`bin/lint`)
- [x] Copilot review feedback addressed
- [x] All PR comments responded to

### Files Changed

[List of key files modified]

### Ready for Your Review

Please review the PR and merge when satisfied. The PR targets the `develop` branch.

**To merge:**
```bash
gh pr merge [PR_NUMBER] --squash --delete-branch
```

---
```

## Output Format

The notification should be clear and actionable:

```
PR Ready for Final Review

PR: https://github.com/owner/repo/pull/123
Title: feat(dashboard): add project list to dashboard
Branch: feature/project-dashboard -> develop
Issue: #45

Summary
Added the project list component to the dashboard, showing recent projects
sorted by last activity. Users can now quickly resume work on their audits.

Completed
- Story created following story-writing-guide
- Feature branch from develop
- TDD approach (tests written first)
- All acceptance criteria implemented
- Tests pass
- Linting passes
- Copilot review feedback addressed
- All PR comments responded to

Files Changed
- app/views/dashboard/index.html.erb
- app/controllers/dashboard_controller.rb
- app/models/project.rb
- test/controllers/dashboard_controller_test.rb

Ready for Your Review
Please review and merge when ready.
```

## What Happens Next

After this notification:
1. **User reviews** the PR manually
2. **User merges** using GitHub UI or `gh pr merge`
3. **GitHub deletes** the feature branch (if configured)
4. **User closes** the linked issue (if not auto-closed)

## Notes

- Claude never merges PRs - always hand off to human
- Include the merge command for convenience
- Summarize what was done without excessive detail
- Make it easy for user to verify completeness
- Target branch should be `develop` (GitFlow)
