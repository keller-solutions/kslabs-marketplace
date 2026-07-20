---
name: present
description: Self-review, create PR, and handle the feedback loop. Takes implemented code through an in-depth stack review, PR creation (one PR per epic), evidence gathering, a quality-dimensions report, and responding to every piece of feedback. Works standalone or as part of the ks-feature or ks-ticket workflow.
version: 1.4.1
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
- [ ] Quality dimensions reviewed — see [Quality Dimensions](../../references/quality-dimensions.md); report the result in the PR (Step 3.2)
- [ ] In-depth stack-appropriate review run on the final diff (Step 1.5)

### Step 1.3: Run the Full Quality Gate

Final verification before PR — the same **QUALITY_GATE derived during prep** that produce ran, at full CI parity (system tests included):

```bash
{ if [ -x bin/ci ]; then bin/ci; else bin/rails test:all; fi; } \
  && bin/lint \
  && bin/brakeman   # && chain: a red gate halts here — nothing runs past a failure
```

All must pass before creating PR. Advisory audit failures don't block — they become a proposed fix PR ([Quality Gate](../../references/quality-gate.md)).

### Step 1.4: Verify CHANGELOG Updated

Before creating a PR, ensure CHANGELOG reflects the changes.

```bash
# Check if CHANGELOG was modified in this branch (use develop or main as base)
git diff develop...HEAD --name-only | grep -i changelog

# If not modified, check if CI validates CHANGELOG
grep -ri "changelog" .github/workflows/ 2>/dev/null | grep -v "#"
```

**If CI validates CHANGELOG** (like `Version Bump Required` checks):

The PR will fail if CHANGELOG isn't updated. Add an entry now:

```bash
# View what to document
git log develop..HEAD --oneline

# Edit CHANGELOG.md with [Unreleased] or new version section
```

**Warning signs:** code changed but CHANGELOG unchanged; `.github/workflows/` has changelog validation; previous PRs failed on version/changelog checks. If any apply, update the CHANGELOG before creating the PR to avoid CI failures.

### Step 1.5: In-Depth Stack Review

Before opening the PR, run an in-depth review **appropriate to the project's stack** on the final diff. **That a review happens is the rule; which review is a project-level determination** (surfaced during prep) — for example, a DHH-style review for Rails, a frontend review for React/TS, or a code-review persona panel otherwise. This matters on every PR and especially on an Epic PR that delivers many stories at once. Address findings before creating the PR.

---

## Phase 2: Evidence Gathering

### Step 2.1: Walk the Story as the User

Before gathering evidence, complete every step of the story yourself using only the tools an average user has—a browser, not the Rails console. Each acceptance criterion should be reachable that way, with preconditions created through the application itself (per the plan skill's Deliver Without Seeding principle). Use **production-realistic data** — never a lone seeded demo row, never invented external-system IDs — and leave verification data in place until the developer confirms they're done looking.

If a step can't be completed without seeding, check the story's Developer Notes: anticipated seeding should be called out there. If it isn't, flag it before asking a reviewer to accept—either the delivery order needs fixing or the note is missing.

### Step 2.2: Record Video Walkthrough (Optional)

Record a walkthrough with your screen tooling, or drive the flow with browser automation (the ce-test-browser skill from compound-engineering, or the agent-browser skill) and capture it — demonstrating key user flows and acceptance criteria being met.

### Step 2.3: Capture Evidence Per Criterion

For each UI acceptance criterion, capture a screenshot (or short recording) that **visibly demonstrates that criterion** — before/after for changes to existing UI. Save to `evidence/<ticket-id>/` (gitignored — evidence is attached, never committed), echo the file paths in the report, replace stale shots, and attach per the tool's mechanism. Contract and per-tool mechanics: [Evidence](../../references/evidence.md).

### Step 2.4: Design-Fidelity Pass (UI stories)

Compare the implementation **side-by-side against the ticket's attached visual reference** — colors, icons, sizing, spacing — and fix or list every discrepancy. One miss found means a proactive "more like this" sweep across the same screen. When the change touched a shared partial/pattern, sweep the sibling surfaces: find every other render site and verify each matches. No attached reference (the common case)? Verify against the acceptance criteria alone — this pass never blocks.

### Step 2.5: Document Test Results

Capture a test summary for the PR body: `bin/rails test:all 2>&1 | tail -20`

---

## Phase 3: Create Pull Request

**Epic Mode:** present runs **once** for the whole epic. The single PR references every child (`Refs <child-id> …`) and the epic; batch-attach any held evidence to its child ticket now; aggregate the Quality Dimensions across children. See [Epic Mode](../../references/epic-mode.md).

### Step 3.1: Determine Target Branch

Detect — never assume `develop` (repos differ; a wrong base has forced retargeting before):

```bash
# GitFlow repos target develop when it exists; otherwise the repo's default branch.
# Hotfixes target main. Stacked epics target the parent epic's branch (see Epic Mode).
DEFAULT_BRANCH=$(git remote show origin | sed -n 's/.*HEAD branch: //p')
git show-ref --verify --quiet refs/remotes/origin/develop && TARGET_BRANCH="develop" || TARGET_BRANCH="$DEFAULT_BRANCH"
```

### Step 3.2: Create PR

The AI badge line below appears on **Visible** projects only — omit it entirely when the project's AI-visibility preference (from prep) is Invisible ([AI Visibility](../../references/ai-visibility.md)). The badge and reply templates show the Claude Code form; under a different coding agent, substitute that agent's own attribution — never claim a tool that wasn't used.

```bash
gh pr create \
  --base "$TARGET_BRANCH" \
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

## Quality Dimensions

Which applied and how each was addressed/verified; mark the rest N/A (see references/quality-dimensions.md):

- [e.g. Security] — [how addressed / verified]
- N/A: [dimensions that don't apply to this change]

## Screenshots

[Include if UI changes]

## Checklist

- [ ] Tests pass
- [ ] Linters pass
- [ ] Self-review complete
- [ ] Quality dimensions reviewed

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

### Step 3.4: Link PR to Task

Link the PR to your project management tool. See [managing-tickets](../managing-tickets/SKILL.md) for tool-specific commands.

**GitHub Issues:** Use `Refs #[NUMBER]` in PR body (automatic linking).

**Jira/ClickUp/Linear/Azure DevOps:** Add PR link as comment and update status to "In Review":

```bash
# Example for ClickUp - see managing-tickets for full setup
curl -X POST "https://api.clickup.com/api/v2/task/[TASK_ID]/comment" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"comment_text\": \"PR created: ${PR_URL}\"}"

curl -X PUT "https://api.clickup.com/api/v2/task/[TASK_ID]" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"status": "in review"}'

# Example for Azure DevOps (or reference AB#[ID] in the PR title/description);
# set the project's awaiting-review state — the Agile template calls it "Resolved"
az boards work-item update --id [WORK_ITEM_ID] \
  --state "Resolved" --discussion "PR created: ${PR_URL}"
```

---

## Phase 4: Review Environment (if applicable)

If the project has preview deployments, verify the change in staging (`gh pr checks $PR_NUMBER`, then open the project-specific preview URL). Run browser tests where applicable (the ce-test-browser skill).

---

## Phase 5: Feedback Loop

### Step 5.1: Request and Await the Copilot Review

Requesting the review is part of presenting — never wait to be asked, and never skip it. Full mechanics (size limits, retry, dedupe, polling): [Copilot Review](../../references/copilot-review.md).

```bash
# Size guard first (300-file hard limit; huge diffs time out — propose a split instead)
gh pr view $PR_NUMBER --json changedFiles,additions,deletions -q '"\(.changedFiles) files +\(.additions) -\(.deletions)"'

# Request (gh ≥ 2.88; retry once on the pending-review transient; REST fallback in the reference)
gh pr edit $PR_NUMBER --add-reviewer @copilot

# Await: poll for the bot's review of the CURRENT head SHA, bounded timeout —
# report a no-show rather than proceeding silently
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

   Co-Authored-By: Claude <noreply@anthropic.com>
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

Example: "Addressed with the help of Claude Code in a1b2c3d. Added error handling for the nil case."

**For declined feedback:**

```text
This [pattern/approach] follows [guideline/convention]. [Explanation]. [Reference if applicable].
```

Example: "This follows the existing pattern in `app/services/`. Changing would create inconsistency."

### Step 5.5: Verify All Comments Addressed

```bash
# Check for unresolved comments
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments \
  --jq '[.[] | select(.in_reply_to_id == null)] | length'
```

If unaddressed comments remain, repeat the evaluation.

**Thread resolution belongs to the reviewer — never mark threads resolved.** The commenter judges whether the response was adequate: a human reviewer resolves or replies again; since Copilot can't resolve, the developer resolves while reviewing (or merges past open threads). If the repo requires resolved threads before merge, say so in the hand-back.

**Re-request economics:** after feedback commits, request a fresh Copilot review only for substantive changes (new logic, changed approach) — reviews are usage-billed; typo-level follow-ups ride to the human review.

### Step 5.6: Run Final Checks

After making changes, re-run the full gate — feedback commits don't get a lighter bar:

```bash
{ if [ -x bin/ci ]; then bin/ci; else bin/rails test:all; fi; } && bin/lint
```

---

## Phase 6: Ready for Merge

### Step 6.1: Verify All Checks Pass — Green Before Done

```bash
gh pr checks $PR_NUMBER --watch
```

**Never report the workflow complete while any check is failing** — pre-existing failures included ("unrelated to this feature" is not an exemption; all PRs end green). For failures that predate the branch, follow the [Quality Gate](../../references/quality-gate.md) playbook: name the check, propose the lockfile-bump PR and merge order, and hold. In Epic Mode the next child does not start while this one's checks are red; stacked children absorb base fixes by merging the base in (never rebasing) and re-verifying.

### Step 6.2: Get Final PR Status

```bash
PR_URL=$(gh pr view --json url -q '.url')
PR_TITLE=$(gh pr view --json title -q '.title')
PR_BRANCH=$(gh pr view --json headRefName -q '.headRefName')
```

### Step 6.3: Present Ready Notification

**The agent does not merge PRs.** The checklist below carries **honest ✓/✗ verdicts** ([Self-Check](../../references/self-check.md)) — any ✗ retitles this "PR Status", names what remains, and defers the words "ready for review". Output notification for user:

```markdown
---

## PR Ready for Final Review

**Ticket**: [TICKET_ID] — [TICKET_TITLE]
**PR**: [PR_URL]
**Title**: [PR_TITLE]
**Branch**: [PR_BRANCH] → [TARGET_BRANCH]

### Summary

[Brief description of what was built and why]

### Completed Checklist

- [x] Story created following story-writing-guide
- [x] Feature branch from develop
- [x] TDD approach (tests written first)
- [x] All acceptance criteria implemented
- [x] Tests pass
- [x] Linting passes
- [x] Quality dimensions reviewed and reported in the PR
- [x] In-depth stack-appropriate review completed before the PR
- [x] Copilot review: [N] comments — [M] addressed (commit SHAs), [K] declined with rationale
- [x] All PR comments replied to in-thread [; repo requires thread resolution — resolve as you review]

### Files Changed

- [List of key files modified]

### Ready for Your Review

Please review the PR and merge when satisfied.

**To merge** (your act — the agent never merges): use the **merge-commit** method, then delete the branch **via the GitHub UI/API** (auto-retargets any dependent PRs; CLI deletion closes them). No squash — history stays honest ([Git Integrity](../../references/git-integrity.md)).

*Bookend*: once handed back, offer to run the prep workflow — "getting ready for the next thing" — so stray state, drift, and dependencies are settled before the next session starts.

---
```

---

## Standalone Usage

When invoked directly (the ks-present workflow):

1. Performs self-review
2. Creates PR (if not already created)
3. Gathers evidence
4. Handles feedback loop
5. Notifies when ready for merge

## Workflow Usage

When invoked as part of the ks-feature or ks-ticket workflow:

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

**Resolving threads:** not ours — resolution belongs to the reviewer (Step 5.5).

---

## Leveraging compound-engineering

This skill integrates with compound-engineering skills:

Verified against compound-engineering **3.19.0**; missing helpers never block — do the step manually.

- `ce-test-browser` - Diff-scoped browser QA of the change
- `ce-resolve-pr-feedback` - Address PR review findings
- `ce-code-review` - In-depth review pass

---

## More Information

- [The F5 Principle](../../references/f5-manifesto.md) - "If it isn't scripted, it's magic—bad magic"
- [Guiding Principles](../../references/guiding-principles.md) - The six principles
- [Quality Dimensions](../../references/quality-dimensions.md) - The nine dimensions to report in every PR
- [Epic Mode](../../references/epic-mode.md) - Delivering an epic as a single branch and PR
- [Git Integrity](../../references/git-integrity.md) - "Thou Shalt Not Lie"
