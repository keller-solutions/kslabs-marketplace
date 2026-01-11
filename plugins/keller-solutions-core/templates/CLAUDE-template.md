# CLAUDE.md Template

A template for AI assistant configuration files that follow the Keller Solutions Way.

---

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Reference

```bash
# Development
bin/dev                           # Start development server
bin/rails console                 # Interactive console

# Testing
bin/rails test                    # Full test suite
bin/rails test test/models/       # Specific directory
bin/rails test test/file.rb:42    # Specific line

# Code Quality
bin/lint                          # All linters
bin/rubocop -a                    # Ruby linting with autofix
```

## Architecture Overview

- **[Framework]** [version] - [brief description]
- **[Database]** - [brief description]
- **[Frontend]** - [brief description]
- **[Background Jobs]** - [brief description]
- **[Testing]** - [brief description]

## Architecture Documentation

| Document | Purpose |
|----------|---------|
| `docs/coding-guidelines.md` | Coding principles and conventions |
| `docs/domain-model.md` | Domain entities and relationships |
| `docs/adr/` | Architecture Decision Records |

**Read these before implementing features.**

## Development Workflow

### Session Startup

Before starting any work session:

```bash
git checkout develop && git pull origin develop
gcu                               # Clean up stale branches
bundle update && npm update       # Update dependencies
git checkout -b feature/name      # Create feature branch
```

### Branching Strategy (GitFlow)

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code |
| `develop` | Integration branch |
| `feature/*` | New features |
| `bugfix/*` | Bug fixes |
| `hotfix/*` | Urgent production fixes |

### Test-Driven Development

1. Write a failing test for the acceptance criterion
2. Write minimal code to make the test pass
3. Refactor while keeping tests green
4. Repeat for each criterion

### Pre-Commit Checks

```bash
bin/rails test        # All tests pass
bin/lint              # All linters pass
```

All must pass before committing.

### Commits (Conventional Commits)

```text
<type>(<scope>): <description>

[body explaining WHY]

Refs #123

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Rules**:

- Each commit must be independently functional with passing tests
- No debug code or commented-out code
- Reference issues with `Refs #123` (not `Closes`)
- Push after each commit

### Pull Requests

- Target `develop` (or `main` for hotfixes)
- Wait for CI checks and reviewer approval
- Claude notifies when ready; user decides when to merge

### PR Feedback Response

**If you agree**: Make the change, push, reply with:
> Addressed with the help of Claude Code in [commit-sha]. [Summary]

**If you disagree**: Reply explaining why, referencing guidelines or patterns.

## Coding Principles

1. **DRY**: Extract on the second use, not the first
2. **Separate Content**: No literal strings in views, use i18n
3. **Avoid Pre-Optimization**: Build only what's needed now
4. **Keep Tidy**: No commented-out code or debug traces
5. **Maintain Consistency**: Follow established patterns
6. **Make Understandable**: Spell out names, code is read more than written

### Comments

Comments explain **why**, never **what**. If code needs a comment to explain what it does, rewrite the code.

## Key Patterns

### [Pattern Category 1]

[Description of important patterns specific to this project]

### [Pattern Category 2]

[Description of important patterns specific to this project]

## Environment Variables

| Variable | Description | Where to get it |
|----------|-------------|-----------------|
| `DATABASE_URL` | Database connection | Auto-configured locally |
| `API_KEY` | External service | [Dashboard URL] |

## Peer References

When implementing features, reference these sibling repositories:

- **[project-a]**: [What patterns to reference]
- **[project-b]**: [What patterns to reference]

---

# CLAUDE.md Guidelines

## Purpose

CLAUDE.md is the AI's guide to your project. It should contain everything an AI assistant needs to:

1. Run and test the project
2. Understand the architecture
3. Follow the team's coding conventions
4. Navigate the development workflow

## Required Sections

### 1. Quick Reference

Copy-paste commands for common tasks. AI assistants benefit from having commands in one place.

### 2. Architecture Overview

One-line descriptions of the tech stack. Help the AI understand what tools are in play.

### 3. Development Workflow

Step-by-step processes the AI should follow. Be explicit about:

- Branching strategy
- Commit format
- PR process
- Testing requirements

### 4. Coding Principles

What standards should the AI enforce? Link to detailed docs but summarize key points.

### 5. Key Patterns

Project-specific patterns the AI should follow or reference. Include file paths for examples.

### 6. Environment Variables

Don't include secrets, but list what's needed and where to get them.

## Optional Sections

- **Peer References**: Other projects with similar patterns
- **Domain Model Summary**: Core entities and relationships
- **Common Tasks**: Frequently needed workflows
- **Gotchas**: Things that trip people up

## What NOT to Include

- Secrets or credentials
- Personal information
- Detailed API documentation (link to it instead)
- Content that belongs in README or CONTRIBUTING

## Visibility Considerations

If this file is tracked in git, it's public. Consider:

- Is your team comfortable with AI assistance being visible?
- Should certain sections be in a gitignored file instead?

See [ai-visibility.md] for guidance on detecting and respecting project preferences.

## Keep It Current

CLAUDE.md should evolve with the project:

- Update commands when they change
- Add patterns as they emerge
- Remove outdated guidance
- Link to docs rather than duplicating content
