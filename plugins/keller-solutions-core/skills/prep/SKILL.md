---
name: prep
description: Orient yourself to the project and prepare the development environment. Run this at the start of every work session. Works standalone or as part of the ks-feature workflow.
version: 1.3.1
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

### Step 1.0: Fast-Path from Cached Context

Prep's findings persist between sessions — don't re-derive what's already known:

1. **Read the project's agent memory** (its memory index and any feedback/lesson notes) and the `Ticket Workflow` block in CLAUDE.md or AGENTS.md. A recorded lesson is *applied*, not rediscovered — if a note says "run X before deploy," X is now part of this session's gates.
2. **Read `.ks/context.json`** (gitignored, written by Phase 4's Store Context step below). If it exists and is fresh — no changes to CI config, CLAUDE.md, or lockfiles since it was written, and less than a week old — print its Development Context table with a "cached, verified fresh" note and skip straight to Phase 2's hygiene steps (pull, stray-state, drift, gate). Stale or absent → full orientation below, then rewrite the cache.

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
3. **CLAUDE.md / AGENTS.md** - Agent-specific guidance and commands
4. **docs/coding-guidelines.md** - Coding standards (if referenced)
5. **docs/domain-model.md** - Domain entities (if referenced)

```bash
# Check what documentation exists
ls README.md CONTRIBUTING.md CLAUDE.md AGENTS.md docs/*.md 2>/dev/null
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

### Step 2.3: Clean Up Stale State

Remove branches that no longer exist on origin — and catch what the last session left behind:

```bash
git fetch --prune
git branch --merged | grep -v -E '^\*|main|develop|master' | while read branch; do git branch -d "$branch" 2>/dev/null || true; done

git status --short                 # uncommitted work from a prior session? surface it, don't stash it silently
git log --branches --not --remotes --oneline | head -5   # committed but never pushed?
git worktree list                  # leftover worktrees?
```

**Worktree rule**: before removing a leftover worktree, check whether it ran migrations against the shared dev database (`bin/rails db:migrate:status` — Down entries whose files exist only in the worktree) and roll them back first. An orphaned worktree migration once left schema drift undetected for 18 days. Also check for orphaned dev servers (`lsof -i :3000 -i :3036 2>/dev/null`) and kill ones no session owns.

### Step 2.4: Check Dependency Freshness

**The 24-Hour Rule**: On projects that keep dependencies current, update them at the start of each dev day—small, frequent updates beat cumbersome catch-ups. Check when the lockfile last changed to see whether today's update has already happened:

```bash
# Report last-modified for whichever lockfile(s) the project has
for f in Gemfile.lock package-lock.json yarn.lock composer.lock; do
  [ -f "$f" ] && echo "$f: $(stat -f "%Sm" "$f" 2>/dev/null || stat -c "%y" "$f")"
done
```

**Opt-outs are okay.** Some projects deliberately pin versions or delegate updates to a bot (Dependabot/Renovate) or a release process. Check for a stated policy (CLAUDE.md, README, CONTRIBUTING) before assuming. If the project opts out, install to match the lockfile and move on.

### Step 2.5: Update Dependencies

**Installing is not updating**: `bundle install`/`npm install` only satisfies the existing lockfile. On projects that follow the 24-Hour Rule, run the real update at the outset of the session:

| Stack | Update command |
|-------|----------------|
| Ruby/Rails | `bundle update` |
| JavaScript/Node | `npm update` |
| PHP/Composer | `composer update` |
| .NET | `dotnet list package --outdated`, then update as needed |

Commit the updated lockfile **in the same PR as the day's work**—don't park the session waiting on a separate dependencies PR before work even starts. The test suite run in Step 2.7 verifies the update broke nothing; if it did break something, that's the 24-Hour Rule working—fix or pin the offender and note it.

### Step 2.6: Verify Database (if applicable)

For database-backed applications:

**Rails:**

```bash
bin/rails db:migrate:status        # pending migrations — and phantom ones (status without a file = drift)
git diff --stat -- db/schema.rb    # schema drift the last session left behind
bin/rails db:migrate
```

Phantom migrations or unexplained schema.rb changes are **drift** — flag and resolve them now, at session start, not weeks later in an audit.

**Laravel:**

```bash
php artisan migrate:status
```

### Step 2.7: Derive the Quality Gate, Then Run It

The local gate is whatever CI actually runs — derived from the repo, never a remembered subset:

```bash
# Sources, in precedence order — union them when they disagree
ls bin/ci config/ci.rb 2>/dev/null            # Rails 8.1 CI DSL
ls .github/workflows/*.yml 2>/dev/null        # GitHub Actions jobs that gate PRs
ls buildspec*.yml 2>/dev/null                 # CodeBuild (client deploy gates)
```

Split what you find into a **blocking gate** (tests *including system tests*, linters, static analysis — run it now; if anything fails, **stop and fix before proceeding**) and **advisory audits** (`bundle-audit`, `npm audit` — run and report, but failures become proposed fix PRs, not a broken codebase).

Fallbacks when no CI definition exists: `bin/ci` → `bin/rails test:all` (plain `bin/rails test` **excludes system tests**) → `npm test` → `php artisan test` → `dotnet test`. Full derivation and failure playbooks: [Quality Gate](../../references/quality-gate.md).

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

Verdicts are honest ([Self-Check](../../references/self-check.md)): a failing gate or unresolved drift makes this an "Environment Status" report naming what's broken — never "Environment Ready" with a caveat buried below.

Output a brief readiness summary:

```markdown
## Environment Ready

**Branch**: [current branch]
**Dependencies**: [updated / install-only (project opts out of the 24-Hour Rule)]
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
| **Ticket System** | [GitHub Issues / Jira / ClickUp / Linear / Azure DevOps / None] | Where tickets are created and updated |
| **Status Workflow** | [the project's actual state names + order, e.g. `To Do → In Progress → In Review → Done`] | Which statuses to set, and when, so the board stays accurate in real time |
| **Code Review** | [project's in-depth review, e.g. DHH for Rails / frontend review for React / code-review panel] | The stack-appropriate review run before every PR |
| **Dependency Updates** | [24-Hour Rule: updated this session / Opted out: install-only per [policy source]] | Whether each session starts with `bundle update`/`npm update` |
| **Quality Gate** | [derived commands, e.g. union of `bin/ci` + workflows] | CI-parity set; green before any done-claim |
| **Advisory Audits** | [e.g. `bundle-audit` — non-blocking] | Failures become fix PRs, never silent or blocking |
| **Coverage** | [X% / Not reported / N/A] | Quality gate threshold |
| **AI Visibility** | [Visible / Invisible] | Co-authored-by in commits |
| **CHANGELOG** | [Current / Needs update / Not found] | Must update before PR |
| **Repo Baseline** | [present items, e.g. ruleset ✓, bin/ci ✓, Renovate ✗] | Server-side reinforcements on owned repos ([Repo Baseline](../../references/repo-baseline.md)) |

### What This Means

- Commits will [include/exclude] `Co-Authored-By: Claude` attribution
- Tickets will be [created in X / managed manually]
- Dependencies [were updated and the lockfile rides in this PR / follow the project's opt-out policy]
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
([ -f ".azuredevops" ] || grep -q "AZURE_DEVOPS" .env 2>/dev/null || [ -n "$AZURE_DEVOPS_EXT_PAT" ] || git remote -v 2>/dev/null | grep -q "dev\.azure\.com") && echo "Azure DevOps"
```

### Discover the Status Workflow

**Check the project first**: a `Ticket Workflow` block in CLAUDE.md/AGENTS.md or project memory means a prior session already discovered it — read it and move on. Only discover fresh when absent, and **write the confirmed workflow back into the project** so this is the last session that has to.

Knowing the tool isn't enough — find the project's **actual status names and their order**, so produce/present (and Epic Mode) can keep tickets accurate as work progresses. See [managing-tickets](../managing-tickets/SKILL.md) for per-tool queries (ClickUp `GET /list/{id}` statuses; GitHub project columns/`status:` labels; `jira issue move` transitions; Linear workflow states; Azure DevOps process-template states / board columns). If the order is ambiguous, confirm it with the user. Record the in-progress and awaiting-review states explicitly.

### Determine the Code Review Approach

Identify the in-depth, stack-appropriate review the project expects before each PR (check CLAUDE.md / project conventions). The rule is that a review happens; the specific one is project-level — e.g. DHH-style for Rails, a frontend review for React/TS, otherwise a code-review persona panel.

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
- **QUALITY_GATE**: The derived CI-parity command set (blocking, system tests included)
- **AUDIT_CHECKS**: Advisory scans run and reported separately (non-blocking)
- **TICKET_SYSTEM**: Which tool to use for ticket operations
- **STATUS_WORKFLOW**: The project's status names + order (esp. in-progress and awaiting-review states)
- **REVIEW_APPROACH**: The in-depth stack review to run before each PR
- **DEPENDENCY_POLICY**: 24-Hour Rule (lockfile changes ride in the work PR) or opted out (and why)
- **CHANGELOG_STATUS**: Whether to prompt for updates
- **TESTS_PASSING**: Whether tests were green at start

**Persist the table**: write these values to `.ks/context.json` (gitignored) with a timestamp and the checksums of CI config, CLAUDE.md, and lockfiles — Step 1.0's fast-path reads it next session.

---

## Standalone Usage

When invoked directly (the ks-prep workflow, or a direct request to prep), this skill:

1. Performs full orientation and preparation
2. Reports the development context summary
3. Ends without proceeding to next phase

## Workflow Usage

When invoked as part of the ks-feature or ks-ticket workflow:

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

- [The F5 Principle](../../references/f5-manifesto.md) - "If it isn't scripted, it's magic—bad magic"
- [Guiding Principles](../../references/guiding-principles.md) - The six principles
- [AI Visibility](../../references/ai-visibility.md) - Attribution preferences
