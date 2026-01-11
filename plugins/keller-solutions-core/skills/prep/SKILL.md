---
name: prep
description: Orient yourself to the project and prepare the development environment. Run this at the start of every work session. Works standalone or as part of /ks-feature workflow.
version: 1.0.0
argument-hint: "[optional: path to project]"
---

# Prepare

Orient yourself to the project and prepare the development environment for productive work.

## Core Principle

**Never start coding without understanding where you are and ensuring the environment is ready.**

Preparation prevents wasted effort, ensures you're working from the latest code, and helps you understand the context before making changes.

---

## Phase 1: Project Orientation

### Step 1.1: Detect Project Type

Examine the project root to understand the tech stack:

```bash
# Check for language/framework markers
ls -la | head -20
```

**Detection patterns:**

| Marker File | Stack |
|-------------|-------|
| `Gemfile` + `config/application.rb` | Rails |
| `Gemfile` (no Rails) | Ruby (Sinatra, etc.) |
| `package.json` + `next.config.*` | Next.js |
| `package.json` + `astro.config.*` | Astro |
| `package.json` + `vite.config.*` | Vite/React |
| `composer.json` + `artisan` | Laravel |
| `composer.json` + `core/` | Drupal |
| `wp-config.php` or `composer.json` + `wordpress` | WordPress |
| `*.csproj` or `*.sln` | .NET |

### Step 1.2: Read Core Documentation

Read these files in order (if they exist):

1. **README.md** - Project purpose, setup instructions, tech stack
2. **CONTRIBUTING.md** - Development workflow and standards
3. **CLAUDE.md** - AI-specific guidance and commands
4. **docs/coding-guidelines.md** - Coding standards (if referenced)
5. **docs/domain-model.md** - Domain entities (if referenced)

```bash
# Check what documentation exists
ls README.md CONTRIBUTING.md CLAUDE.md docs/*.md 2>/dev/null
```

### Step 1.3: Review Architecture Decisions

Check for ADRs (Architecture Decision Records):

```bash
# List existing ADRs
ls docs/adr/*.md 2>/dev/null | head -20
```

Skim ADR titles to understand key decisions that have been made.

### Step 1.4: Identify Default Branch

```bash
# Get the default branch name
git remote show origin | grep "HEAD branch" | cut -d: -f2 | tr -d ' '
```

Common patterns:

- `main` - Modern default
- `develop` - GitFlow integration branch (usually the working branch)
- `master` - Legacy default

**Note**: In GitFlow projects, `develop` is typically where feature work happens.

### Step 1.5: Report Project Summary

After orientation, output a brief summary:

```markdown
## Project Summary

**Name**: [project name]
**Stack**: [detected stack]
**Default Branch**: [branch name]
**Key Docs**: [list of important docs found]
**ADRs**: [count] architecture decisions recorded

Ready to proceed with environment preparation.
```

---

## Phase 2: Environment Preparation

### Step 2.1: Switch to Default Branch

```bash
# Switch to develop (or main if no develop)
git checkout develop 2>/dev/null || git checkout main

# Pull latest changes (fast-forward only)
git pull --ff-only
```

### Step 2.2: Clean Up Stale Branches

Remove local branches that no longer exist on origin:

```bash
# Prune remote-tracking branches
git fetch --prune

# Delete merged local branches (except main/develop)
git branch --merged | grep -v -E '^\*|main|develop|master' | while read branch; do git branch -d "$branch" 2>/dev/null || true; done
```

### Step 2.3: Check Dependency Freshness

**The 24-Hour Rule**: Dependencies should be updated at least daily or at the start of each feature branch.

For **Ruby/Rails**:

```bash
# Check when Gemfile.lock was last modified
stat -f "%Sm" Gemfile.lock 2>/dev/null || stat -c "%y" Gemfile.lock 2>/dev/null
```

For **JavaScript/Node**:

```bash
# Check package-lock.json or yarn.lock
stat -f "%Sm" package-lock.json 2>/dev/null || stat -f "%Sm" yarn.lock 2>/dev/null
```

### Step 2.4: Update Dependencies (if needed)

**Ruby/Rails:**

```bash
bundle install
# Or for full update:
bundle update
```

**JavaScript/Node:**

```bash
npm install
# Or for full update:
npm update
```

**PHP/Composer:**

```bash
composer install
# Or for full update:
composer update
```

**.NET:**

```bash
dotnet restore
```

### Step 2.5: Verify Database (if applicable)

For database-backed applications:

**Rails:**

```bash
bin/rails db:migrate:status
# Run pending migrations if needed:
bin/rails db:migrate
```

**Laravel:**

```bash
php artisan migrate:status
```

### Step 2.6: Run Test Suite

Verify the codebase is in a known-good state:

**Rails:**

```bash
bin/rails test
```

**JavaScript:**

```bash
npm test
```

**Laravel:**

```bash
php artisan test
```

**.NET:**

```bash
dotnet test
```

If tests fail, **stop and fix before proceeding**.

### Step 2.7: Determine AI Visibility Preference

Check if AI attribution should be visible or invisible in this project:

1. Check if CLAUDE.md is in .gitignore:

   ```bash
   grep -i "claude.md" .gitignore
   ```

2. Check commit history for AI co-authorship:

   ```bash
   git log -10 --format="%B" | grep -i "co-authored"
   ```

3. Record the preference for use in later phases.

---

## Phase 3: Ready Report

Output a readiness summary:

```markdown
## Environment Ready

**Branch**: [current branch]
**Dependencies**: [installed/updated]
**Database**: [migrated/n/a]
**Tests**: [passing/failing - count]
**AI Visibility**: [visible/invisible/unknown]

Ready to proceed with:
- `/ks-plan` - Create a story and ticket
- `/ks-produce` - Work on an existing ticket
```

---

## Standalone Usage

When invoked directly (`/ks-prep`), this skill:

1. Performs full orientation and preparation
2. Reports the project summary
3. Ends without proceeding to next phase

## Workflow Usage

When invoked as part of `/ks-feature` or `/ks-ticket`:

1. Performs full orientation and preparation
2. Stores context for subsequent skills
3. Automatically proceeds to next phase

---

## Error Handling

### Tests Failing

If tests fail after pulling latest:

1. Report the failure
2. Ask if this is expected (known CI issue)
3. If unexpected, stop and investigate

### Merge Conflicts

If conflicts occur during pull:

1. Report the conflict
2. Ask for guidance before resolving

### Missing Dependencies

If dependency installation fails:

1. Report the error
2. Check for required system dependencies
3. Provide guidance based on error messages

---

## Framework-Specific Notes

### Rails Projects

- Use `bin/setup` if available for one-command setup
- Check for `bin/dev` vs `bin/rails server`
- Look for Solid Queue/Cable/Cache configuration

### Next.js/React Projects

- Check for `.env.local` requirements
- Verify Node version matches `.nvmrc` or `package.json`
- Run `npm run build` to catch build errors early

### Laravel Projects

- Check for `.env` file (copy from `.env.example`)
- Run `php artisan key:generate` if needed
- Check for queue worker requirements

### WordPress Projects

- Check for local environment (Local, DDEV, wp-env)
- Verify database connection
- Check for WP-CLI availability
