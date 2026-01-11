# README Template

A comprehensive template for project READMEs, synthesized from analysis of 75+ projects and industry best practices.

---

# [Project Name]

[![Tests](https://shields.io/badge/tests-passing-green)][ci-link]
[![Coverage](https://shields.io/badge/coverage-98%25-brightgreen)][coverage-link]
[![License](https://shields.io/badge/license-MIT-blue)][license-link]

[One sentence explaining what this project does and why it exists.]

![Screenshot or GIF demo](docs/screenshot.png)

## Key Features

- [Feature 1: brief value proposition]
- [Feature 2: brief value proposition]
- [Feature 3: brief value proposition]

## Quick Start

Get running in under 5 minutes:

```bash
git clone [repository-url]
cd [project-name]
bin/setup
bin/dev
```

Visit `http://localhost:3000` to see it running.

## System Requirements

- [Language] [version] (we recommend [version manager])
- [Database] [version]+
- [Other required services]

## Installation

### Dependencies

```bash
bundle install    # Ruby dependencies
npm install       # JavaScript dependencies
```

### Environment

Copy the example environment file and configure:

```bash
cp .env.example .env
```

Required environment variables:

| Variable | Description | Where to get it |
|----------|-------------|-----------------|
| `DATABASE_URL` | PostgreSQL connection | Local: auto-configured |
| `API_KEY` | External service key | [Service dashboard URL] |

### Database

```bash
bin/rails db:setup    # Creates, migrates, and seeds
```

## Development

### Running Locally

```bash
bin/dev               # Starts server with asset compilation
```

In separate terminals (if needed):

```bash
bin/rails server      # Web server only
bin/rails jobs:work   # Background jobs
```

### Testing

```bash
bin/rails test                    # Full test suite with coverage
NO_COVERAGE=true bin/rails test   # Fast mode (skips coverage)
bin/rails test:system             # Browser tests
bin/rails test test/models/user_test.rb:42  # Single test by line
```

### Code Quality

```bash
bin/lint              # All linters (Rubocop, ESLint, etc.)
bin/rubocop -a        # Ruby linting with autofix
```

Git hooks run linters automatically on staged files before commit.

### Common Tasks

```bash
bin/rails console     # Interactive console
bin/rails db:migrate  # Run pending migrations
bin/rails routes      # List all routes
```

## Architecture

```text
app/
├── controllers/      # HTTP request handling
├── models/           # Domain logic and database
├── services/         # Complex business operations
├── jobs/             # Background processing
└── views/            # Templates and partials

docs/
├── adr/              # Architecture Decision Records
└── [topic].md        # Additional documentation
```

### Domain Model

[Brief explanation of core entities and their relationships, or link to docs/domain-model.md]

## Deployment

### Staging

```bash
git push staging main    # Deploy to staging
```

Verify at: https://staging.example.com

### Production

```bash
bin/deploy              # Or: git push production main
```

**Pre-deploy checklist:**

- [ ] All tests passing locally
- [ ] Reviewed on staging
- [ ] Database migrations are backward-compatible

Verify at: https://example.com

### Environment URLs

| Environment | URL | Notes |
|-------------|-----|-------|
| Development | http://localhost:3000 | |
| Staging | https://staging.example.com | Auto-deploys from `develop` |
| Production | https://example.com | Manual deploy |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow and guidelines.

For AI-assisted development, see [CLAUDE.md](CLAUDE.md).

## License

[License type] - see [LICENSE](LICENSE) for details.

---

<!-- Reference Links -->
[ci-link]: https://github.com/owner/repo/actions
[coverage-link]: https://qlty.sh/orgs/owner/projects/repo
[license-link]: LICENSE

---

# README Writing Guidelines

## The Core Principle

**Can a new developer be productive in under 5 minutes?**

The best READMEs treat onboarding as a design problem. Every section should answer a question the reader is likely to have, in the order they're likely to ask it.

## Section Order (Golden Path)

1. **Title + Badges + One-liner** - What is this?
2. **Screenshot/GIF** - What does it look like?
3. **Key Features** - Why should I care?
4. **Quick Start** - How do I try it NOW?
5. **System Requirements** - What do I need installed?
6. **Installation** - Detailed setup steps
7. **Development** - How do I work on this?
8. **Architecture** - How is it organized?
9. **Deployment** - Where does it run?
10. **Contributing** - How do I help?
11. **License** - Legal stuff

## Effective Patterns

### Lead with Purpose

```markdown
# Project Name

Accessibility auditing tool that scans websites and reports WCAG violations.
```

Not:

```markdown
# Project Name

This repository contains the source code for...
```

### The One-Command Ideal

```markdown
Run `bin/setup` to install dependencies, configure the database, and start the server.
```

If your project can't do this, work toward it.

### Show Expected Output

```ruby
User.group_by_day(:created_at).count
# => { Sun, 01 Jan 2024 => 5, Mon, 02 Jan 2024 => 3 }
```

### Options Approach for Diverse Teams

```markdown
### Option 1: Docker Setup (Recommended)
...

### Option 2: Local Setup (Without Docker)
...
```

### Proactive Troubleshooting

```markdown
**Note:** If `rbenv install` fails on macOS, run `brew install openssl readline` first.
```

### Environment Variables with Context

| Variable | Description | Where to get it |
|----------|-------------|-----------------|
| `STRIPE_KEY` | Payment processing | [Stripe Dashboard](https://dashboard.stripe.com/apikeys) |

Not just a list of variable names.

## Badge Best Practices

- **Limit to 2-4 badges** - More dilutes their impact
- **Prioritize**: Build status, coverage, license
- **Use Shields.io** for consistent styling
- **Dynamic over static** - Use badges that auto-update

## What NOT to Include

- **Roadmap/Future features** - Use GitHub Issues/Projects
- **Internal processes** - Put in CONTRIBUTING.md
- **AI instructions** - Put in CLAUDE.md
- **Detailed API docs** - Put in docs/ or use YARD/JSDoc
- **Placeholder content** - "TODO: Add description here" is worse than nothing

## Anti-Patterns to Avoid

1. **Wall of badges** - Stop at 4
2. **Installation-only README** - Missing the "why" and usage
3. **Default framework boilerplate** - Rails' "Things you may want to cover" is a red flag
4. **Assumed knowledge** - Don't assume they know your tooling
5. **Outdated information** - Screenshots and examples that no longer match
6. **No deployment section** - Even for libraries, explain how to release

## Sources

This template synthesizes patterns from:

- Andrew Kane's gem READMEs (searchkick, chartkick, blazer)
- GitHub's official README documentation
- Make a README (makeareadme.com)
- 75+ analyzed project READMEs from Keller Solutions archives
- Standard README specification
