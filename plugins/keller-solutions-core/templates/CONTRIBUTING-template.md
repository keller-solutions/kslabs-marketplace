# CONTRIBUTING Template

A template for contributing guidelines that follows the Keller Solutions Way.

---

# Contributing to [Project Name]

Thank you for considering a contribution! This document outlines the development workflow, coding standards, and how to submit changes.

## Getting Started

1. Read the [README.md](README.md) for setup instructions
2. Review [CLAUDE.md](CLAUDE.md) for AI-assisted development guidance (if applicable)
3. Check [existing issues](link-to-issues) before creating new ones

## Development Workflow

We follow [GitFlow](https://nvie.com/posts/a-successful-git-branching-model/) branching:

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code |
| `develop` | Integration branch for features |
| `feature/*` | New features |
| `bugfix/*` | Bug fixes |
| `hotfix/*` | Urgent production fixes |

### Starting Work

```bash
# Ensure you're on develop with latest changes
git checkout develop
git pull origin develop

# Create a feature branch
git checkout -b feature/descriptive-name
```

### Before Committing

Run the full quality check:

```bash
bin/rails test         # All tests pass
bin/lint               # All linters pass
```

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/) format:

```text
<type>(<scope>): <description>

[optional body explaining WHY]

Refs #123
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change that neither fixes nor adds
- `test`: Adding or updating tests
- `chore`: Build process, dependencies, tooling

**Examples:**

```text
feat(auth): add Google OAuth2 integration

Implements OAuth2 flow with PKCE for enhanced security.
Users can now sign in with their Google accounts.

Refs #45
```

```text
fix(scan): prevent duplicate violations in report

Refs #67
```

### Commit Guidelines

- Each commit should be independently functional
- All tests must pass at each commit
- No debug code (`console.log`, `binding.pry`, `puts`)
- No commented-out code
- Reference issues with `Refs #123` (not `Closes` or `Fixes`)

## Pull Requests

### Creating a PR

1. Push your feature branch
2. Open a PR against `develop` (or `main` for hotfixes)
3. Fill out the PR template completely
4. Wait for CI checks to pass
5. Request review

### PR Description Format

```markdown
## Summary

[Brief description of what this PR does]

## Changes

- [Change 1]
- [Change 2]

## Test Plan

- [ ] Unit tests added/updated
- [ ] Manual testing performed
- [ ] Verified on [staging/local]

## Screenshots

[If UI changes, include before/after screenshots]

Refs #123
```

### Review Process

- All PRs require at least one approval
- Address all review comments before merging
- Squash merge to `develop`, merge commit for releases

## Code Standards

### The Six Principles

1. **DRY**: Extract on the second use, not the first
2. **Separate Code From Content**: Use i18n, no literal strings in views
3. **Avoid Pre-Optimization**: Build what's needed now
4. **Keep Code Tidy**: No dead code, debug traces, or incomplete features
5. **Maintain Consistency**: Follow established patterns
6. **Make It Understandable**: Spell out names, code is read more than written

### Comments

- Comments explain **why**, never **what**
- If code needs a comment to explain what it does, rewrite the code
- Acceptable: Business reasons, constraints, warnings, TODOs with issue links

### Testing

- Write tests first (TDD when possible)
- Each acceptance criterion maps to at least one test
- Target 100% code coverage
- Use fixtures for stable test data

## Reporting Issues

### Bug Reports

Before filing, check if the issue already exists.

Include:

- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots/logs if applicable
- Environment details (OS, browser, version)

### Feature Requests

Use the proposal template. Include:

- Problem you're trying to solve
- Proposed solution
- Alternatives considered

## Questions?

- Check [docs/](docs/) for additional documentation
- Review [Architecture Decision Records](docs/adr/) for context on past decisions
- Open a discussion or reach out to maintainers

---

# CONTRIBUTING Guidelines

## What to Include

1. **Setup pointer** - Link to README, don't duplicate
2. **Branching strategy** - How branches are named and used
3. **Commit format** - Conventional commits or project standard
4. **PR process** - How to submit and what to expect
5. **Code standards** - Link to guidelines or summarize key points
6. **Issue templates** - How to report bugs and request features

## What NOT to Include

- Detailed setup instructions (put in README)
- AI-specific guidance (put in CLAUDE.md)
- Architecture decisions (put in docs/adr/)
- API documentation (put in docs/ or inline)

## Tone

- Welcoming but professional
- Assume good intentions
- Be specific about expectations
- Explain the "why" behind requirements
