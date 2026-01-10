---
name: session-start
description: This skill prepares the development environment for a new work session. Use when starting work, beginning a new feature, or ensuring you have the latest code. Switches to the integration branch (develop), pulls latest changes, cleans up stale branches, and updates dependencies.
version: 0.1.0
---

# Session Start

Prepare your development environment for a new work session following GitFlow conventions.

## What This Skill Does

1. **Switch to integration branch** - Checks out `develop` (falls back to `main`)
2. **Pull latest changes** - Fetches and pulls from origin
3. **Cleanup stale branches** - Removes local branches deleted from remote
4. **Update dependencies** - Runs `bundle update` and `npm update`

## Usage

Invoke this skill at the start of any development session or before creating a new feature branch.

## Workflow

### Step 1: Switch to Integration Branch

```bash
# Try develop first (GitFlow), fall back to main
git checkout develop 2>/dev/null || git checkout main
```

### Step 2: Pull Latest Changes

```bash
git pull origin $(git branch --show-current)
```

### Step 3: Cleanup Stale Branches

Remove local branches that have been deleted from the remote:

```bash
git fetch --prune
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D 2>/dev/null || true
```

### Step 4: Update Dependencies

```bash
# Ruby dependencies
bundle update 2>/dev/null || true

# JavaScript dependencies
npm update 2>/dev/null || true
```

### Step 5: Confirm Ready

Report the current state:

```bash
echo "Current branch: $(git branch --show-current)"
echo "Latest commit: $(git log -1 --oneline)"
git status --short
```

## Output

After completion, report:

```
Session Ready

Branch: develop
Latest: [commit hash] [commit message]
Status: Clean (or list uncommitted changes)

Ready to create feature branch or start work.
```

## When to Use

- Starting a new development session
- Before creating a new feature branch
- After returning from a break
- When you want to ensure you have the latest code

## Notes

- This skill assumes GitFlow with `develop` as the integration branch
- Falls back to `main` if `develop` doesn't exist
- Safe to run multiple times - idempotent operations
- Dependency updates are optional (won't fail if bundle/npm not available)
