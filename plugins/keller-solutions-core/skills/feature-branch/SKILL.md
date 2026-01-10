---
name: feature-branch
description: This skill creates a GitFlow feature branch from the integration branch. Use after creating a story/issue to start development. Creates properly named branches following GitFlow conventions.
version: 0.1.0
argument-hint: "[branch-name or issue-number]"
---

# Feature Branch

Create a GitFlow feature branch from the integration branch (develop).

## Branch Name

<branch_input> #$ARGUMENTS </branch_input>

**If empty, ask:** "What should the branch be named? Provide a descriptive name or issue number."

## GitFlow Branch Types

| Type | Pattern | Base | Purpose |
|------|---------|------|---------|
| feature | `feature/descriptive-name` | develop | New features |
| bugfix | `bugfix/issue-123-description` | develop | Bug fixes |
| hotfix | `hotfix/critical-fix` | main | Urgent production fixes |
| release | `release/v1.2.0` | develop | Release preparation |

## Workflow

### Step 1: Determine Branch Type and Name

Based on input, create a properly formatted branch name:

**If issue number provided (e.g., "123" or "#123"):**
```
feature/issue-123-brief-description
```

**If description provided:**
```
feature/descriptive-name-here
```

**Branch naming rules:**
- Lowercase only
- Use hyphens (not underscores or spaces)
- Be descriptive but concise
- Include issue number if available

### Step 2: Ensure on Integration Branch

```bash
# Should already be on develop from session-start
current=$(git branch --show-current)
if [ "$current" != "develop" ] && [ "$current" != "main" ]; then
  echo "Warning: Not on integration branch. Switching to develop..."
  git checkout develop 2>/dev/null || git checkout main
  git pull origin $(git branch --show-current)
fi
```

### Step 3: Create Feature Branch

```bash
git checkout -b feature/[branch-name]
```

### Step 4: Confirm Creation

```bash
echo "Branch created: $(git branch --show-current)"
echo "Based on: develop"
echo "Ready to start development"
```

## Output

Report the created branch:

```
Feature Branch Created

Branch: feature/[name]
Base: develop
Issue: #[number] (if applicable)

Next steps:
1. Implement feature using TDD
2. Commit with: feat(scope): description
3. Push and create PR to develop
```

## Examples

**Input:** `user-dashboard`
**Output:** `feature/user-dashboard`

**Input:** `123`
**Output:** `feature/issue-123-[fetch title from gh]`

**Input:** `fix login bug`
**Output:** `bugfix/fix-login-bug`

**Input:** (for urgent prod fix)
**Output:** `hotfix/[description]` (from main, not develop)

## Branch Type Detection

Automatically detect branch type from input:

- Contains "fix", "bug", "broken" → `bugfix/`
- Contains "hotfix", "urgent", "critical" → `hotfix/` (base: main)
- Contains "release", "version" → `release/`
- Default → `feature/`

## Notes

- Always branch from `develop` for features and bugfixes
- Only `hotfix/` branches come from `main`
- Keep branch names short but descriptive
- Delete feature branches after PR merge (GitHub does this automatically)
