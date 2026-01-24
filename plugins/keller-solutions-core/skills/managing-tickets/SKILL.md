---
name: managing-tickets
description: Interact with project management tools (GitHub Issues, Jira, ClickUp, Linear). Use when creating tickets, updating status, adding comments, or linking PRs to tasks.
version: 1.0.0
argument-hint: "<tool> <operation> [options]"
---

# Managing Tickets

Unified interface for interacting with project management tools across the development workflow.

## Core Principle

**One skill for all ticket operations, regardless of the tool.**

Whether your project uses GitHub Issues, Jira, ClickUp, or Linear, this skill provides consistent patterns for creating, reading, updating, and linking tickets.

---

## Detecting Your Project's Tool

Before performing ticket operations, detect which tool the project uses.

### Detection Script

```bash
# Check for GitHub Issues (most common)
gh issue list --limit 1 2>/dev/null && echo "TOOL=github"

# Check for Linear
[ -f ".linear" ] && echo "TOOL=linear"

# Check for Jira
[ -f ".jira" ] || grep -q "jira" .env 2>/dev/null && echo "TOOL=jira"

# Check for ClickUp (file, .env, or environment variable)
[ -f ".clickup" ] && echo "TOOL=clickup"
grep -q "clickup" .env 2>/dev/null && echo "TOOL=clickup"
[ -n "$CLICKUP_API_TOKEN" ] && echo "TOOL=clickup"
```

### Detection Priority

1. **GitHub Issues** - Default for GitHub-hosted repos
2. **Linear** - Check for `.linear` config file
3. **Jira** - Check for `.jira` or jira references in `.env`
4. **ClickUp** - Check for `.clickup`, env file, or `CLICKUP_API_TOKEN`

---

## Credential Management

### 1Password Integration

For tools requiring API tokens, use 1Password CLI:

```bash
# ClickUp token from 1Password (Private vault)
CLICKUP_API_TOKEN="${CLICKUP_API_TOKEN:-$(op read "op://Private/CLICKUP_API_TOKEN/credential")}"

# Jira token from 1Password
JIRA_API_TOKEN="${JIRA_API_TOKEN:-$(op read "op://Private/JIRA_API_TOKEN/credential")}"

# Linear token from 1Password
LINEAR_API_KEY="${LINEAR_API_KEY:-$(op read "op://Private/LINEAR_API_KEY/credential")}"
```

### Environment Variables

Alternatively, set tokens in `.env` (not committed):

```bash
CLICKUP_API_TOKEN=pk_xxx
JIRA_API_TOKEN=xxx
LINEAR_API_KEY=lin_api_xxx
```

---

## Operations by Tool

### GitHub Issues

GitHub Issues uses the `gh` CLI, which handles authentication automatically.

#### Create Issue

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
EOF
)"
```

#### Read Issue

```bash
# View issue details
gh issue view [ISSUE_NUMBER] --json title,body,labels,state

# List issues
gh issue list --limit 20
gh issue list --label "bug"
gh issue list --assignee "@me"
```

#### Update Status

```bash
# Add status label (for GitHub Projects integration)
gh issue edit [ISSUE_NUMBER] --add-label "status:in-progress"
gh issue edit [ISSUE_NUMBER] --remove-label "status:in-progress" --add-label "status:in-review"

# Close issue
gh issue close [ISSUE_NUMBER]

# Reopen issue
gh issue reopen [ISSUE_NUMBER]
```

#### Add Comment

```bash
gh issue comment [ISSUE_NUMBER] --body "PR created: https://github.com/owner/repo/pull/123"
gh issue comment [ISSUE_NUMBER] --body "Released in v1.1.0"
```

#### Link PR to Issue

```bash
# In PR body, reference the issue
# Refs #123
# Closes #123 (auto-closes on merge)
# Fixes #123 (auto-closes on merge)
```

---

### Jira

Jira uses the [jira-cli](https://github.com/ankitpokhrel/jira-cli).

#### Create Issue

```bash
jira issue create \
  --type Story \
  --summary "User sees project list on dashboard" \
  --body "$(cat <<'EOF'
*In order to* quickly resume work on recent audits
*As a* returning user on the dashboard
*I want* to see my projects listed by last activity

h2. Acceptance Criteria

* Projects section header is visible
* Each project shows name and last scan date
* Projects are sorted by last activity (most recent first)
* Clicking a project navigates to the project detail page
* Empty state shown when no projects exist
EOF
)"
```

#### Read Issue

```bash
# View issue
jira issue view [ISSUE_KEY]

# List issues
jira issue list
jira issue list --jql "assignee = currentUser() AND status = 'In Progress'"
```

#### Update Status

```bash
# Transition issue to new status
jira issue move [ISSUE_KEY] "In Progress"
jira issue move [ISSUE_KEY] "In Review"
jira issue move [ISSUE_KEY] "Done"
```

#### Add Comment

```bash
jira issue comment add [ISSUE_KEY] "PR created: https://github.com/owner/repo/pull/123"
```

#### Link PR to Issue

```bash
# Add PR link as comment
jira issue comment add [ISSUE_KEY] "PR: https://github.com/owner/repo/pull/123"

# Or use Jira's GitHub integration if configured
```

---

### ClickUp

ClickUp uses REST API calls with `curl`.

#### Setup

```bash
# Token from env var or 1Password
CLICKUP_API_TOKEN="${CLICKUP_API_TOKEN:-$(op read "op://Private/CLICKUP_API_TOKEN/credential")}"

# Find your list ID from ClickUp URL or via API
CLICKUP_LIST_ID="your_list_id"
```

#### Create Task

```bash
curl -X POST "https://api.clickup.com/api/v2/list/${CLICKUP_LIST_ID}/task" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$(cat <<'EOF'
{
  "name": "User sees project list on dashboard",
  "markdown_description": "**In order to** quickly resume work on recent audits\n**As a** returning user on the dashboard\n**I want** to see my projects listed by last activity\n\n## Acceptance Criteria\n\n- [ ] Projects section header is visible\n- [ ] Each project shows name and last scan date\n- [ ] Projects are sorted by last activity\n- [ ] Clicking a project navigates to detail page\n- [ ] Empty state shown when no projects exist"
}
EOF
)"
```

#### Read Task

```bash
# Get task by ID (find ID in ClickUp URL: https://app.clickup.com/t/[TASK_ID])
curl -s "https://api.clickup.com/api/v2/task/[TASK_ID]" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" | jq '.name, .status.status'

# List tasks in a list
curl -s "https://api.clickup.com/api/v2/list/${CLICKUP_LIST_ID}/task" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" | jq '.tasks[] | {id, name, status: .status.status}'
```

#### Update Status

```bash
# Update task status (status names vary by workspace)
curl -X PUT "https://api.clickup.com/api/v2/task/[TASK_ID]" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"status": "in progress"}'

# Common status names: "to do", "in progress", "in review", "complete"
```

#### Add Comment

```bash
curl -X POST "https://api.clickup.com/api/v2/task/[TASK_ID]/comment" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"comment_text\": \"PR created: ${PR_URL}\"}"
```

#### Link PR to Task

```bash
# Add PR link as comment
curl -X POST "https://api.clickup.com/api/v2/task/[TASK_ID]/comment" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"comment_text\": \"PR created: ${PR_URL}\"}"

# Update status to "in review"
curl -X PUT "https://api.clickup.com/api/v2/task/[TASK_ID]" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"status": "in review"}'
```

---

### Linear

Linear uses GraphQL API or the `linear` CLI.

#### Setup

```bash
# Token from env var or 1Password
LINEAR_API_KEY="${LINEAR_API_KEY:-$(op read "op://Private/LINEAR_API_KEY/credential")}"
```

#### Create Issue

```bash
# Using Linear CLI
linear issue create \
  --title "User sees project list on dashboard" \
  --description "$(cat <<'EOF'
**In order to** quickly resume work on recent audits
**As a** returning user on the dashboard
**I want** to see my projects listed by last activity

## Acceptance Criteria

- [ ] Projects section header is visible
- [ ] Each project shows name and last scan date
- [ ] Projects are sorted by last activity
EOF
)"

# Using API
curl -X POST https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { issueCreate(input: { title: \"User sees project list\", teamId: \"TEAM_ID\" }) { issue { id identifier } } }"
  }'
```

#### Read Issue

```bash
# Using Linear CLI
linear issue view [ISSUE_ID]

# List issues
linear issue list
```

#### Update Status

```bash
# Using Linear CLI
linear issue update [ISSUE_ID] --state "In Progress"
linear issue update [ISSUE_ID] --state "In Review"
```

#### Add Comment

```bash
# Using API
curl -X POST https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { commentCreate(input: { issueId: \"ISSUE_ID\", body: \"PR created\" }) { comment { id } } }"
  }'
```

---

## Workflow Integration

This skill is referenced by other keller-solutions-core skills:

| Skill | Uses This For |
|-------|---------------|
| `/ks-plan` | Creating tickets from stories |
| `/ks-produce` | Updating status to "In Progress" |
| `/ks-present` | Linking PRs and updating to "In Review" |
| `/ks-publish` | Adding release comments |

### Status Transitions

Standard workflow status progression:

```
To Do → In Progress → In Review → Done
```

Update status at these milestones:

| Milestone | Status | Triggered By |
|-----------|--------|--------------|
| Work started | In Progress | `/ks-produce` |
| PR created | In Review | `/ks-present` |
| PR merged | Done | Product owner (manual) |

---

## Quick Reference

### GitHub Issues

```bash
gh issue create --title "..." --body "..."
gh issue view [NUMBER]
gh issue edit [NUMBER] --add-label "status:in-progress"
gh issue comment [NUMBER] --body "..."
gh issue close [NUMBER]
```

### Jira

```bash
jira issue create --type Story --summary "..." --body "..."
jira issue view [KEY]
jira issue move [KEY] "In Progress"
jira issue comment add [KEY] "..."
```

### ClickUp

```bash
# Create: POST /list/{id}/task
# Read: GET /task/{id}
# Update: PUT /task/{id}
# Comment: POST /task/{id}/comment
```

### Linear

```bash
linear issue create --title "..."
linear issue view [ID]
linear issue update [ID] --state "In Progress"
```

---

## More Information

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Jira CLI Documentation](https://github.com/ankitpokhrel/jira-cli)
- [ClickUp API Documentation](https://clickup.com/api)
- [Linear API Documentation](https://developers.linear.app/docs)
- [1Password CLI Documentation](https://developer.1password.com/docs/cli/)
