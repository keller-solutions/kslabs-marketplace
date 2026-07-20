# Keller Solutions Core

The Keller Solutions Way—30 years of development methodology distilled into a coding-agent plugin. Works in Claude Code and, since 1.7.0, in OpenAI Codex CLI (skills and guardrail hooks; see [Codex CLI Support](#codex-cli-support)).

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

### Workflow Orchestrators

| Skill | Command | Description |
|-------|---------|-------------|
| **Feature** | `/ks-feature` | Full workflow: Prep → Plan → Produce → Present |
| **Ticket** | `/ks-ticket <number>` | Work on existing ticket(s): Prep → Produce → Present |
| — | `/lg` | Legacy alias for `/ks-feature` (Claude Code only) |

The orchestration lives in the `feature` and `ticket` skills; the `/ks-feature` and `/ks-ticket` commands are thin wrappers over them, so every workflow is reachable via skills alone (which is how Codex CLI reaches them).

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
│   └── plugin.json       # Claude Code manifest
├── .codex-plugin/
│   └── plugin.json       # Codex CLI manifest
├── skills/
│   ├── prep/             # Environment preparation
│   ├── plan/             # Story writing
│   ├── produce/          # TDD implementation
│   ├── present/          # PR and feedback
│   ├── publish/          # Release workflow
│   ├── feature/          # Orchestrator: prep → plan → produce → present
│   ├── ticket/           # Orchestrator: prep → produce → present
│   └── managing-tickets/ # Ticket-tool operations
├── commands/             # Thin wrappers over skills (Claude Code)
│   └── lg.md             # Legacy command alias
├── hooks/                # Git guardrails (PreToolUse)
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

## Codex CLI Support

Since 1.7.0 the plugin is tool-agnostic. Skills follow the open Agent Skills standard (SKILL.md with `name` + `description` frontmatter), which Codex CLI supports natively; `.codex-plugin/plugin.json` exposes the `skills/` directory and the guardrail hooks. Claude-only frontmatter keys (e.g. `argument-hint`) are ignored by Codex and are harmless.

**What works in Codex:**

- All 8 skills, including the `feature` and `ticket` workflow orchestrators (invoke explicitly with `$feature` / `$ticket`, or let Codex select them from the description).
- The git guardrail hook: Codex reads the same `hooks/hooks.json` (its PreToolUse event, matcher, and JSON stdin/stdout contract match Claude Code's), and Codex sets `CLAUDE_PLUGIN_ROOT`/`PLUGIN_ROOT` for plugin hook commands, so the `${CLAUDE_PLUGIN_ROOT}` script path resolves. The two hard denies (`gh pr merge`, force pushes) behave identically.

**Known limitations in Codex:**

- **`ask` guardrails degrade**: Codex parses `permissionDecision: "ask"` but does not support it yet, so the two confirm-first rules (CLI remote-branch deletion, direct commits on integration branches) fall through to Codex's normal approval flow instead of a targeted prompt. They harden automatically once Codex ships `ask` support.
- **No plugin dependencies**: the Codex manifest has no dependency concept, so compound-engineering, ralph-loop, and frontend-design are not pulled in. The skills already treat those as optional helpers — every step works manually when a helper is absent.
- **Slash commands are Claude Code only**: `commands/` (including `/lg`) doesn't load in Codex; use the skills directly.
- **Attribution examples**: commit/PR templates show the Claude Code attribution form; under another agent, substitute that agent's own attribution (the skills say so inline).

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

## Dependent Plugins (tested versions)

KS Core leans on optional helpers; every step works manually when a helper is absent.

| Plugin | Tested version | Used for |
|--------|----------------|----------|
| compound-engineering | 3.19.0 (`ce-*` skills, `lfg`) | planning, review, browser QA, PR-feedback helpers |
| frontend-design | 1.1.0 | distinctive UI implementation during produce |
