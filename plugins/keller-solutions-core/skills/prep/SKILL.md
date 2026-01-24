---
name: prep
description: Orient yourself to the project and prepare the development environment. Run this at the start of every work session. Works standalone or as part of /ks-feature workflow.
version: 1.0.0
argument-hint: "[optional: path to project]"
---

# Prepare

Orient yourself to the project and prepare the development environment for productive work.

## Core Principle

**After cloning and running setup, the application should just work.**

This skill embodies the F5 Principle: clone, setup, run. No magic incantations, no tribal knowledge, no hunting down a senior developer for secret steps.

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

### Step 2.1: Run Setup Script (The F5 Principle)

Check for and run the project's setup script. A well-maintained project should have one command that handles everything:

```bash
# Check for setup script
ls bin/setup script/setup package.json composer.json 2>/dev/null
```

**Run the appropriate setup command**:

| Project Type | Setup Command | What It Does |
|--------------|---------------|--------------|
| Rails | `bin/setup` | Bundle, database, seeds, assets |
| Node.js | `npm run setup` or `npm install` | Install dependencies, setup |
| Laravel | `composer install && php artisan migrate:fresh --seed` | Dependencies, database |
| .NET | `dotnet restore && dotnet build` | NuGet restore, build |
| WordPress | `wp-env start` or equivalent | Docker, database |

**If setup fails**: This is a signal. Either dependencies are missing, or the project doesn't follow the F5 principle. Document what was needed and consider adding a proper setup script.

### Step 2.2: Switch to Default Branch

```bash
# Switch to develop (or main if no develop)
git checkout develop 2>/dev/null || git checkout main

# Pull latest changes (fast-forward only)
git pull --ff-only
```

### Step 2.3: Clean Up Stale Branches

Remove local branches that no longer exist on origin:

```bash
# Prune remote-tracking branches
git fetch --prune

# Delete merged local branches (except main/develop)
git branch --merged | grep -v -E '^\*|main|develop|master' | while read branch; do git branch -d "$branch" 2>/dev/null || true; done
```

### Step 2.4: Check Dependency Freshness

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

### Step 2.5: Update Dependencies (if needed)

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

### Step 2.6: Verify Database (if applicable)

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

### Step 2.7: Run Test Suite

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

### Step 2.8: Determine AI Visibility Preference

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

### Step 2.9: Verify CHANGELOG Freshness

Check if the CHANGELOG is up to date with recent work.

#### Check for CHANGELOG

```bash
# Find CHANGELOG file (common naming conventions)
CHANGELOG_FILE=$(ls CHANGELOG.md CHANGELOG HISTORY.md CHANGES.md 2>/dev/null | head -1)
echo "CHANGELOG: ${CHANGELOG_FILE:-not found}"
```

#### Cross-Check Against Git Tags

```bash
# Get latest git tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")

# Get version from CHANGELOG (first version header)
CHANGELOG_VERSION=$(grep -E "^## \[?[0-9]+\.[0-9]+\.[0-9]+\]?" "$CHANGELOG_FILE" 2>/dev/null | head -1 | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")

echo "Latest tag: $LATEST_TAG"
echo "CHANGELOG version: $CHANGELOG_VERSION"
```

#### Check for Unreleased Changes

```bash
# Count commits since last tag
COMMITS_SINCE_TAG=$(git rev-list "${LATEST_TAG}"..HEAD --count 2>/dev/null || echo "0")

# Check if CHANGELOG has [Unreleased] section with content
HAS_UNRELEASED=$(grep -A 5 "## \[Unreleased\]" "$CHANGELOG_FILE" 2>/dev/null | grep -E "^### " | wc -l)

echo "Commits since $LATEST_TAG: $COMMITS_SINCE_TAG"
echo "Unreleased sections: $HAS_UNRELEASED"
```

#### Report CHANGELOG Status

If discrepancies are found, suggest updating:

```markdown
## CHANGELOG Status

**Latest Tag**: v1.0.0
**CHANGELOG Version**: 1.0.0
**Commits Since Tag**: 15
**Unreleased Section**: Empty

⚠️ **Suggestion**: CHANGELOG may need updating. There are 15 commits since the last release with no [Unreleased] entries. Consider documenting recent changes before starting new work.

To view recent commits:
git log v1.0.0..HEAD --oneline
```

**CHANGELOG is current when:**

- Latest tag version matches CHANGELOG's first version section, AND
- Either no commits since tag, OR [Unreleased] section has entries

---

## Phase 3: Ready Report

Output a brief readiness summary:

```markdown
## Environment Ready

**Branch**: [current branch]
**Dependencies**: [installed/updated]
**Database**: [migrated/n/a]
**Tests**: [passing/failing - count]
```

---

## Phase 4: Development Context Summary

After environment preparation, present a consolidated summary of key development choices that will impact subsequent skills.

### Output Format

```markdown
---

## Development Context

These settings will be used throughout the workflow:

| Setting | Value | Impact |
|---------|-------|--------|
| **Ticket System** | [GitHub Issues / Jira / ClickUp / Linear / None] | Where tickets are created and updated |
| **Test Suite** | [Passing (N tests) / Failing / None] | Must pass before PR |
| **Coverage** | [X% / Not reported / N/A] | Quality gate threshold |
| **AI Visibility** | [Visible / Invisible] | Co-authored-by in commits |
| **CHANGELOG** | [Current / Needs update / Not found] | Must update before PR |

### What This Means

- Commits will [include/exclude] `Co-Authored-By: Claude` attribution
- Tickets will be [created in X / managed manually]
- CHANGELOG [is current / should be updated during produce]
- Test coverage [meets standards / should be monitored]

---

**Ready to proceed?** Review the settings above. If anything looks incorrect, address it now before starting work.
```

### Detect Ticket Management System

```bash
# Detection (matches managing-tickets skill logic)
gh issue list --limit 1 2>/dev/null && echo "GitHub Issues"
([ -f ".jira" ] || grep -q "jira" .env 2>/dev/null) && echo "Jira"
([ -f ".clickup" ] || grep -q "clickup" .env 2>/dev/null || [ -n "$CLICKUP_API_TOKEN" ]) && echo "ClickUp"
[ -f ".linear" ] && echo "Linear"
```

### Capture Test Suite Status

```bash
# Rails - run tests and capture result
bin/rails test 2>&1 | tee /tmp/test_output.txt
TESTS_PASSED=$?
TEST_COUNT=$(grep -E "^[0-9]+ (tests|runs)" /tmp/test_output.txt | head -1)
COVERAGE=$(grep -E "Coverage|LOC" /tmp/test_output.txt | head -1)

# JavaScript
npm test 2>&1 | tee /tmp/test_output.txt
```

### Store Context for Subsequent Skills

These values should be remembered and applied in produce/present:

- **AI_VISIBLE**: Include Co-Authored-By in commits
- **TICKET_SYSTEM**: Which tool to use for ticket operations
- **CHANGELOG_STATUS**: Whether to prompt for updates
- **TESTS_PASSING**: Whether tests were green at start

---

## Standalone Usage

When invoked directly (`/ks-prep`), this skill:

1. Performs full orientation and preparation
2. Reports the development context summary
3. Ends without proceeding to next phase

## Workflow Usage

When invoked as part of `/ks-feature` or `/ks-ticket`:

1. Performs full orientation and preparation
2. Presents development context summary
3. **Pauses for user confirmation** before proceeding
4. Stores context for subsequent skills
5. Proceeds to next phase after confirmation

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

| Framework | Setup | Dev Server |
|-----------|-------|------------|
| Rails | `bin/setup` | `bin/dev` |
| Next.js/React | `npm install` | `npm run dev` |
| Laravel | `composer install && php artisan migrate:fresh --seed` | `php artisan serve` |
| .NET | `dotnet restore && dotnet build` | `dotnet run` |
| WordPress | `wp-env start` | (included) |

---

## Diagnosing F5 Violations

When preparation fails, diagnose the root cause:

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| "It works on my machine" | Undocumented dependencies | Add to setup script |
| "Ask [person] for the database" | No seed data | Create `db:seed` task |
| "You need to install X manually" | Missing from setup | Add to `bin/setup` |
| "Run these 5 commands first" | No setup script | Create one |
| "Check the wiki" | Setup not scripted | Script it |

---

## More Information

- [The F5 Principle](../references/f5-manifesto.md) - "If it isn't scripted, it's magic—bad magic"
- [Guiding Principles](../references/guiding-principles.md) - The six principles
- [AI Visibility](../references/ai-visibility.md) - Attribution preferences
