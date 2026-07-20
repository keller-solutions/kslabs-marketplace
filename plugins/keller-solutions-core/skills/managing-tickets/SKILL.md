---
name: managing-tickets
description: Interact with project management tools (GitHub Issues, Jira, ClickUp, Linear, Azure DevOps). Use when creating tickets, updating status, adding comments, or linking PRs to tasks.
version: 1.2.0
argument-hint: "<tool> <operation> [options]"
---

# Managing Tickets

Unified interface for interacting with project management tools across the development workflow.

## Core Principle

**One skill for all ticket operations, regardless of the tool.**

Whether your project uses GitHub Issues, Jira, ClickUp, Linear, or Azure DevOps, this skill provides consistent patterns for creating, reading, updating, and linking tickets.

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
([ -f ".jira" ] || grep -q "jira" .env 2>/dev/null) && echo "TOOL=jira"

# Check for ClickUp (file, .env, or environment variable)
([ -f ".clickup" ] || grep -q "clickup" .env 2>/dev/null || [ -n "$CLICKUP_API_TOKEN" ]) && echo "TOOL=clickup"

# Check for Azure DevOps (file, .env, env var, or dev.azure.com remote)
([ -f ".azuredevops" ] || grep -q "AZURE_DEVOPS" .env 2>/dev/null || [ -n "$AZURE_DEVOPS_EXT_PAT" ] \
  || git remote -v 2>/dev/null | grep -q "dev\.azure\.com") && echo "TOOL=azure-devops"
```

### Detection Priority

1. **GitHub Issues** - Default for GitHub-hosted repos
2. **Linear** - Check for `.linear` config file
3. **Jira** - Check for `.jira` or jira references in `.env`
4. **ClickUp** - Check for `.clickup`, env file, or `CLICKUP_API_TOKEN`
5. **Azure DevOps** - Check for `.azuredevops`, env file, `AZURE_DEVOPS_EXT_PAT`, or a `dev.azure.com` git remote

---

## Credential Management

Tokens resolve in this order: **environment variable → Apple Keychain → 1Password**. We have moved away from 1Password toward Apple Keychain, but both are still in use — prefer Keychain, and fall through to 1Password before giving up.

### Apple Keychain (preferred)

```bash
# Store a token once — trailing -w prompts for the secret, keeping it out of
# shell history; -U updates the entry if it already exists
security add-generic-password -U -s CLICKUP_API_TOKEN -a "$USER" -w

# Read a token
security find-generic-password -s CLICKUP_API_TOKEN -w
```

### Resolution Pattern

Falls back to 1Password (`op read`, Private vault) for tokens not yet migrated:

```bash
get_token() {
  security find-generic-password -s "$1" -w 2>/dev/null \
    || op read "op://Private/$1/credential" 2>/dev/null
}

CLICKUP_API_TOKEN="${CLICKUP_API_TOKEN:-$(get_token CLICKUP_API_TOKEN)}"
JIRA_API_TOKEN="${JIRA_API_TOKEN:-$(get_token JIRA_API_TOKEN)}"
LINEAR_API_KEY="${LINEAR_API_KEY:-$(get_token LINEAR_API_KEY)}"
AZURE_DEVOPS_EXT_PAT="${AZURE_DEVOPS_EXT_PAT:-$(get_token AZURE_DEVOPS_EXT_PAT)}"
```

### Environment Variables

Alternatively, set tokens in `.env` (not committed):

```bash
CLICKUP_API_TOKEN=pk_xxx
JIRA_API_TOKEN=xxx
LINEAR_API_KEY=lin_api_xxx
AZURE_DEVOPS_EXT_PAT=xxx
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

# Close / reopen issue
gh issue close [ISSUE_NUMBER]
gh issue reopen [ISSUE_NUMBER]
```

#### Add Comment

```bash
gh issue comment [ISSUE_NUMBER] --body "PR created: https://github.com/owner/repo/pull/123"
gh issue comment [ISSUE_NUMBER] --body "Released in v1.1.0"
```

#### Apply Labels

```bash
# Add labels during creation or to an existing issue
gh issue create --title "..." --body "..." --label "feature"
gh issue edit [ISSUE_NUMBER] --add-label "bug"
```

Common labels: `feature` (new functionality), `bug` (something broken), `chore` (maintenance), `epic:[name]` (links to parent epic).

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

#### Add Comment / Link PR

```bash
# PR links are added as comments (or use Jira's GitHub integration if configured)
jira issue comment add [ISSUE_KEY] "PR created: https://github.com/owner/repo/pull/123"
```

---

### ClickUp

ClickUp uses REST API calls with `curl`.

#### Setup

```bash
# Token from env var, Apple Keychain, or 1Password (see Credential Management)
CLICKUP_API_TOKEN="${CLICKUP_API_TOKEN:-$(get_token CLICKUP_API_TOKEN)}"

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
# Get task by ID (find ID in ClickUp URL: https://app.clickup.com/t/[TASK_ID]);
# list tasks via GET /list/{id}/task
curl -s "https://api.clickup.com/api/v2/task/[TASK_ID]" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" | jq '.name, .status.status'
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

#### Add Comment / Link PR

```bash
# PR links are added as comments; pair with an Update Status call to "in review"
curl -X POST "https://api.clickup.com/api/v2/task/[TASK_ID]/comment" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"comment_text\": \"PR created: ${PR_URL}\"}"
```

---

### Linear

Linear uses GraphQL API or the `linear` CLI.

#### Setup

```bash
# Token from env var, Apple Keychain, or 1Password (see Credential Management)
LINEAR_API_KEY="${LINEAR_API_KEY:-$(get_token LINEAR_API_KEY)}"
```

#### Create Issue

```bash
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
```

#### Read Issue

```bash
linear issue view [ISSUE_ID]
linear issue list
```

#### Update Status

```bash
linear issue update [ISSUE_ID] --state "In Progress"
linear issue update [ISSUE_ID] --state "In Review"
```

#### Add Comment / Link PR

```bash
# PR links are added as comments via the API
curl -X POST https://api.linear.app/graphql \
  -H "Authorization: ${LINEAR_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { commentCreate(input: { issueId: \"ISSUE_ID\", body: \"PR created\" }) { comment { id } } }"
  }'
```

---

### Azure DevOps

Azure DevOps uses the `az` CLI with the Azure DevOps extension, authenticated with a Personal Access Token (PAT).

#### Setup

```bash
# One-time: install the extension
az extension add --name azure-devops

# PAT from env var, Apple Keychain, or 1Password (see Credential Management);
# the az CLI picks up AZURE_DEVOPS_EXT_PAT automatically
export AZURE_DEVOPS_EXT_PAT="${AZURE_DEVOPS_EXT_PAT:-$(get_token AZURE_DEVOPS_EXT_PAT)}"

# Set defaults once per project
az devops configure --defaults organization=https://dev.azure.com/[ORG] project=[PROJECT]
```

#### Create Work Item

```bash
az boards work-item create \
  --type "User Story" \
  --title "User sees project list on dashboard" \
  --description "<b>In order to</b> quickly resume work on recent audits<br><b>As a</b> returning user on the dashboard<br><b>I want</b> to see my projects listed by last activity<br><h2>Acceptance Criteria</h2><ul><li>Projects section header is visible</li><li>Each project shows name and last scan date</li><li>Projects are sorted by last activity</li></ul>"
```

Note: work item descriptions render as HTML, not markdown.

#### Read Work Item

```bash
# View work item
az boards work-item show --id [WORK_ITEM_ID]

# List my open work items
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.AssignedTo] = @Me AND [System.State] <> 'Closed'"
```

#### Update Status

```bash
az boards work-item update --id [WORK_ITEM_ID] --state "Active"
az boards work-item update --id [WORK_ITEM_ID] --state "Resolved"

# States vary by process template (Agile: New → Active → Resolved → Closed)
```

#### Add Comment

```bash
az boards work-item update --id [WORK_ITEM_ID] --discussion "PR created: ${PR_URL}"
```

#### Link PR to Work Item

```bash
# In the PR title/description or commit message, reference the work item:
# AB#123 (auto-links; can auto-complete the work item on merge if configured)

# Or add the PR link as a comment
az boards work-item update --id [WORK_ITEM_ID] --discussion "PR: ${PR_URL}"
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

`To Do → In Progress → In Review → Done` is the *standard* ladder — the actual names vary by workspace. Discover the real ones during prep and keep tickets accurate **in real time** (a PM watching the board should see each ticket advance as you work it).

### Discovering the Status Workflow

```bash
# ClickUp — statuses available on a list
curl -s "https://api.clickup.com/api/v2/list/${CLICKUP_LIST_ID}" \
  -H "Authorization: ${CLICKUP_API_TOKEN}" | jq '.statuses[].status'

# Jira — valid transitions for an issue
jira issue move [ISSUE_KEY] --help   # or view the board's columns

# GitHub — project columns or status: labels
gh label list | grep -i status

# Azure DevOps — states follow the process template (Agile: New → Active →
# Resolved → Closed); confirm against the board columns in the web UI
```

### Attaching Evidence

Evidence is a per-criterion visible proof, captured on production-realistic data, saved to `evidence/<ticket-id>/` (gitignored, paths echoed), attached to the ticket — and **never committed to the repository**. The full contract and per-tool mechanics live in [Evidence](../../references/evidence.md).

- **Attach as you go** — ClickUp (task attachment API), Azure DevOps (attachment + `AttachedFile` relation), Jira (issue attachments endpoint).
- **Hold and batch at PR time** — GitHub (browser-upload to a `user-attachments` URL; CI-artifact link as fallback; Mermaid/text when a diagram beats a pixel) and Linear (links).

### Epic Lifecycle

An epic/parent ticket is a **grouping** — it gets no commit of its own. Its child feature tickets are the unit of work. While delivering an epic (see [epic-mode](../../references/epic-mode.md)), lifecycle **each child** through the discovered states **in order** (in-progress when started, awaiting-review when its commit + evidence land), and move the epic itself to awaiting-review when the single PR opens. On merge, children and epic move to done.

---

## Quick Reference

| Operation | GitHub | Jira | ClickUp (REST) | Linear | Azure DevOps |
|-----------|--------|------|----------------|--------|--------------|
| Create | `gh issue create` | `jira issue create` | `POST /list/{id}/task` | `linear issue create` | `az boards work-item create` |
| Read | `gh issue view` | `jira issue view` | `GET /task/{id}` | `linear issue view` | `az boards work-item show` |
| Status | `gh issue edit --add-label` | `jira issue move` | `PUT /task/{id}` | `linear issue update --state` | `az boards work-item update --state` |
| Comment | `gh issue comment` | `jira issue comment add` | `POST /task/{id}/comment` | GraphQL `commentCreate` | `az boards work-item update --discussion` |
| Close | `gh issue close` | `jira issue move [KEY] "Done"` | `PUT /task/{id}` status | `--state "Done"` | `--state "Closed"` |

---

## More Information

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Jira CLI Documentation](https://github.com/ankitpokhrel/jira-cli)
- [ClickUp API Documentation](https://clickup.com/api)
- [Linear API Documentation](https://developers.linear.app/docs)
- [Azure DevOps CLI Documentation](https://learn.microsoft.com/en-us/azure/devops/cli/)
- [Apple Keychain `security` CLI](https://ss64.com/mac/security.html)
- [1Password CLI Documentation](https://developer.1password.com/docs/cli/)
