# Keller Solutions Core

The Keller Solutions Way—30 years of development methodology distilled into a Claude Code plugin.

## Key Features

- **The 5 P's Workflow**: Prepare → Plan → Produce → Present → Publish
- **TDD-First Development**: Tests before code, every time
- **Git Integrity**: No squash, no rebase, no lies in your history
- **Story-Driven**: Well-structured stories produce well-scoped PRs
- **Feedback Loop**: Every PR comment gets addressed or explained

## Quick Start

Install the required marketplaces and plugins:

```bash
# 1. Install dependent marketplaces
/install-marketplace every-marketplace
/install-marketplace claude-plugins-official
/install-marketplace claude-code-plugins

# 2. Install dependent plugins
/plugin install compound-engineering@every-marketplace
/plugin install ralph-loop@claude-plugins-official
/plugin install frontend-design@claude-code-plugins

# 3. Install recommended MCPs (from compound-engineering)
# Enable context7 for documentation lookups
# Enable pw (Playwright) for browser automation

# 4. Install Keller Solutions Core
/install-marketplace keller-solutions-marketplace
/plugin install keller-solutions-core@keller-solutions-marketplace
```

## Prerequisites

### Development Tools

| Tool | Purpose |
|------|---------|
| [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli) | Markdown linting |

Install with: `npm install -g markdownlint-cli`

Run linting: `markdownlint '**/*.md' --ignore node_modules`

### Required Plugins

This plugin depends on capabilities from other plugins:

| Plugin | Marketplace | Purpose |
|--------|-------------|---------|
| compound-engineering | every-marketplace | Multi-agent workflows, code review, linting |
| ralph-loop | claude-plugins-official | Autonomous agent loop for workflow completion |
| frontend-design | claude-code-plugins | Distinctive UI implementation (used during Produce phase) |

**Recommended MCPs** (available after installing compound-engineering):

| MCP | Purpose |
|-----|---------|
| context7 | Documentation and knowledge lookups |
| pw | Playwright browser automation for screenshots and testing |

## Installation

### Option 1: Full Installation (Recommended)

Run the Quick Start commands above to install all dependencies and the plugin.

### Option 2: Minimal Installation

If you only need the core skills without dependent plugins:

```bash
/install-marketplace keller-solutions-marketplace
/plugin install keller-solutions-core@keller-solutions-marketplace
```

Note: Some skills leverage compound-engineering workflows and will have reduced functionality without it.

## Skills

### The 5 P's

| Skill | Command | Description |
|-------|---------|-------------|
| **Prepare** | `/ks-prep` | Orient to project, prepare environment |
| **Plan** | `/ks-plan` | Write stories, create tickets |
| **Produce** | `/ks-produce` | TDD implementation |
| **Present** | `/ks-present` | Self-review, create PR, feedback loop |
| **Publish** | `/ks-publish` | Release, deploy, verify |

### Workflow Commands

| Command | Description |
|---------|-------------|
| `/ks-feature` | Full workflow: Prep → Plan → Produce → Present |
| `/ks-ticket <number>` | Work on existing ticket: Prep → Produce → Present |
| `/lg` | Legacy alias for `/ks-feature` |

### Utility Skills

| Skill | Description |
|-------|-------------|
| skill-template | Template demonstrating proper SKILL.md structure |
| marketplace-ops | Programmatic marketplace operations |

## Usage

### Starting a New Feature

```bash
# Full workflow from idea to PR
/ks-feature Add user dashboard with project list
```

This runs through all phases:

1. **Prepare**: Checks environment, pulls latest, runs tests
2. **Plan**: Creates well-structured story with acceptance criteria
3. **Produce**: Implements using TDD (red-green-refactor)
4. **Present**: Creates PR and handles all feedback

### Working on an Existing Ticket

```bash
# Pick up ticket #123
/ks-ticket 123
```

Skips planning (ticket already exists) and runs:

1. **Prepare**: Environment setup
2. **Produce**: TDD implementation
3. **Present**: PR and feedback loop

### Running Skills Standalone

Each skill can run independently:

```bash
/ks-prep              # Just prepare environment
/ks-plan              # Just create a story
/ks-produce 45        # Just implement ticket #45
/ks-present           # Just create PR and handle feedback
/ks-publish auto      # Just release (auto-detects version)
```

## Directory Structure

```text
keller-solutions-core/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── prep/             # Environment preparation
│   ├── plan/             # Story writing
│   ├── produce/          # TDD implementation
│   ├── present/          # PR and feedback
│   ├── publish/          # Release workflow
│   ├── skill-template/   # Example skill
│   └── marketplace-ops/  # Marketplace utilities
├── commands/
│   └── lg.md             # Legacy command alias
├── references/
│   ├── guiding-principles.md    # The six principles
│   ├── f5-manifesto.md          # "Clone, setup, run"
│   ├── test-coverage-philosophy.md
│   ├── git-integrity.md         # "Thou Shalt Not Lie"
│   └── ai-visibility.md         # Attribution preferences
├── templates/
│   ├── README-template.md
│   ├── CONTRIBUTING-template.md
│   ├── CLAUDE-template.md
│   └── ADR-template.md
└── README.md
```

## The Keller Solutions Way

### Core Principles

1. **DRY**: Extract on the second use, not the first
2. **Separate Code from Content**: No literal strings in views
3. **Avoid Pre-Optimization**: Build only what's needed now
4. **Keep Code Tidy**: No debug code, no commented-out code
5. **Maintain Consistency**: One codebase, one style
6. **Make It Understandable**: Code should explain itself

### The F5 Principle

> "After cloning and running setup, the application should just work."

- Setup scripts handle everything (dependencies, database, seeds)
- No manual steps required beyond `bin/setup && bin/dev`
- If it isn't scripted, it's magic—bad magic

### Git Integrity

> "Never put yourself in a position where you have to force push."

- No squashing commits (destroys history)
- No rebasing pushed commits (lies about when work happened)
- No amending pushed commits
- Push after each commit

### Story Format

```text
In order to [business value]
As a [specific persona in context]
I want [user-facing capability]
```

**The Browser Test**: Can a non-developer accept or reject this story by using the application in their browser, the same way an end-user would?

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow and guidelines.

## License

MIT
