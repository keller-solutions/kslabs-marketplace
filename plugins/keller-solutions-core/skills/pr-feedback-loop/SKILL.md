---
name: pr-feedback-loop
description: This skill handles the PR review feedback loop with Copilot and reviewers. Use after creating a PR to wait for reviews, evaluate feedback, make changes, and reply to every comment with either a commit link or rationale for not changing.
version: 0.1.0
argument-hint: "[PR number or 'current']"
---

# PR Feedback Loop

Handle the complete PR review feedback cycle: wait for reviews, evaluate feedback, respond to every comment.

## PR Target

<pr_input> #$ARGUMENTS </pr_input>

**If empty:** Use current branch's PR or ask for PR number.

## Core Principle

**NEVER ignore feedback.** Every comment gets a response:
- If you **AGREE**: Make the change, push, reply with commit link
- If you **DISAGREE**: Reply with rationale referencing guidelines/patterns

## Workflow

### Step 1: Get PR Context

```bash
# Get current PR number
PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null)

# If not on a PR branch, ask for PR number
if [ -z "$PR_NUMBER" ]; then
  echo "Not on a PR branch. Please provide PR number."
  exit 1
fi

# Get PR details
gh pr view $PR_NUMBER --json title,body,url,reviews,comments
```

### Step 2: Wait for Copilot Review

Check if Copilot has reviewed:

```bash
# Check for reviews
gh pr view $PR_NUMBER --json reviews -q '.reviews[] | select(.author.login == "copilot") | .body'

# If no Copilot review yet, wait and check again
echo "Waiting for Copilot review..."
```

Poll periodically until Copilot review appears or user indicates to proceed.

### Step 3: Get All Unresolved Comments

```bash
# Get all PR comments with their IDs
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments \
  --jq '.[] | {id: .id, path: .path, line: .line, body: .body, user: .user.login}'

# Get review comments
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/reviews \
  --jq '.[] | {id: .id, body: .body, user: .user.login, state: .state}'
```

### Step 4: Evaluate Each Comment

For each comment, determine the appropriate response:

#### If You AGREE With the Feedback

1. **Make the requested change**
2. **Commit with descriptive message**
   ```bash
   git add .
   git commit -m "$(cat <<'EOF'
   fix(scope): address review feedback

   [Brief description of what changed]

   Refs #[issue_number]

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
5. **Reply to the comment with commit link**
   ```bash
   gh api -X POST repos/{owner}/{repo}/pulls/$PR_NUMBER/comments/{comment_id}/replies \
     -f body="Addressed with the help of Claude Code in $COMMIT_SHA. [1-2 sentence summary of what changed]."
   ```

#### If You DISAGREE With the Feedback

1. **Identify the relevant guideline or pattern**
2. **Reply with clear rationale**
   ```bash
   gh api -X POST repos/{owner}/{repo}/pulls/$PR_NUMBER/comments/{comment_id}/replies \
     -f body="This follows [specific guideline/pattern]. [Clear explanation of why current approach is preferred]. See [reference if applicable]."
   ```

### Step 5: Reply Format Templates

**For accepted feedback:**
```
Addressed with the help of Claude Code in [commit-sha]. [Summary of change].
```

Examples:
- "Addressed with the help of Claude Code in a1b2c3d. Added error handling for nil case."
- "Addressed with the help of Claude Code in e4f5g6h. Extracted validation to a private method."
- "Addressed with the help of Claude Code in i7j8k9l. Renamed variable to be more descriptive."

**For declined feedback:**
```
This [pattern/approach] follows [guideline/convention]. [Explanation]. [Reference if applicable].
```

Examples:
- "This follows the existing pattern in `app/services/` where we use service objects for complex operations. Changing this would create inconsistency."
- "Per our coding guidelines (docs/coding-guidelines.md), we extract methods on the second use, not the first. This is currently used only once."
- "The current approach follows Rails conventions for controller actions. See DHH's recommendations on thin controllers."

### Step 6: Verify All Comments Addressed

```bash
# Re-check for any remaining unresolved comments
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments \
  --jq '[.[] | select(.in_reply_to_id == null)] | length'
```

If unresolved comments remain, repeat Steps 4-5.

### Step 7: Run Final Checks

```bash
# Ensure tests still pass after changes
bin/rails test

# Ensure linting passes
bin/lint
```

## Output

After completing the feedback loop:

```
PR Feedback Loop Complete

PR: #[number]
Comments Addressed: [count]
- Accepted: [count] (changes committed)
- Declined: [count] (rationale provided)

All feedback has been responded to.
Ready for final review.
```

## Handling Different Comment Types

### Line Comments
Specific code suggestions - usually accept and implement.

### General Review Comments
Architectural or design feedback - evaluate against guidelines.

### Nitpicks
Style preferences - accept unless conflicts with project style guide.

### Questions
Clarification requests - reply with explanation (no code change needed).

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

**Resolve a review thread (mark as resolved):**
```bash
# Note: This marks the thread as resolved in GitHub UI
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "THREAD_ID"}) {
      thread { isResolved }
    }
  }
'
```

## Notes

- Always push after making changes before replying
- Include the commit SHA in your reply so reviewers can verify
- Keep replies concise but informative
- Reference specific guidelines when declining feedback
- Multiple small commits are fine - each addresses specific feedback
