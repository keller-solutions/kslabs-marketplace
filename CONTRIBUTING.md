# Contributing to Keller Solutions Marketplace

Thank you for your interest in contributing! This guide covers everything you need to know to contribute skills, plugins, or improvements to the marketplace.

## Table of Contents

- [Development Setup](#development-setup)
- [Repository Structure](#repository-structure)
- [Contributing Skills](#contributing-skills)
- [Contributing Plugins](#contributing-plugins)
- [Version Management](#version-management)
- [Release Process](#release-process)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Code Quality](#code-quality)
- [CI/CD Pipeline](#cicd-pipeline)

## Development Setup

### Prerequisites

- Git
- Node.js (for markdownlint)
- Python 3 (for JSON validation)
- GitHub CLI (`gh`)

### Setup Steps

```bash
# Clone the repository
git clone https://github.com/keller-solutions/kslabs-marketplace.git
cd kslabs-marketplace

# Install markdownlint
npm install -g markdownlint-cli

# Validate your setup
for file in $(find . -name "*.json" -type f); do python3 -m json.tool "$file" > /dev/null; done
markdownlint '**/*.md' --ignore node_modules
```

## Repository Structure

```text
kslabs-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace catalog (version here!)
├── .github/
│   └── workflows/
│       ├── validate.yml      # PR validation checks
│       └── release.yml       # Auto-release on merge to main
├── plugins/
│   └── keller-solutions-core/
│       ├── .claude-plugin/
│       │   └── plugin.json   # Plugin manifest (version here!)
│       ├── skills/           # SKILL.md files
│       ├── commands/         # Workflow commands
│       ├── references/       # Reference documentation
│       ├── templates/        # Project templates
│       ├── CHANGELOG.md      # Version history (version here!)
│       └── README.md
├── CONTRIBUTING.md           # This file
├── CLAUDE.md                 # Claude Code instructions
└── README.md                 # Marketplace overview
```

## Contributing Skills

### Skill Requirements

| Requirement | Details |
|-------------|---------|
| Name | Lowercase with hyphens, max 64 characters |
| Location | `plugins/{plugin-name}/skills/{skill-name}/SKILL.md` |
| Frontmatter | Must include `name`, `description`, `version` |
| Line limit | Under 500 lines |
| License | MIT or compatible |

### Creating a New Skill

1. Copy the template:

   ```bash
   cp -r plugins/keller-solutions-core/skills/skill-template \
         plugins/keller-solutions-core/skills/your-skill-name
   ```

2. Edit `SKILL.md` with proper frontmatter:

   ```yaml
   ---
   name: your-skill-name
   description: What it does. Use when [trigger conditions].
   version: 1.0.0
   argument-hint: "[optional arguments]"
   ---
   ```

3. Follow the phase structure pattern used in other skills

4. Include concrete examples with input/output

5. Document standalone vs. workflow usage if applicable

### Skill Description Formula

```text
[What it does]. Use when [trigger conditions].
```

Examples:

- "Prepare development environment. Use when starting a new work session."
- "Create pull requests with feedback handling. Use after implementing a feature."

## Contributing Plugins

### Plugin Requirements

| Requirement | Details |
|-------------|---------|
| Name | Lowercase with hyphens |
| Location | `plugins/{plugin-name}/` |
| Manifest | `.claude-plugin/plugin.json` |
| README | Required with installation and usage instructions |
| CHANGELOG | Required, following Keep a Changelog format |

### Plugin Manifest (plugin.json)

```json
{
  "name": "your-plugin-name",
  "version": "1.0.0",
  "description": "Brief description of the plugin",
  "author": {
    "name": "Your Name",
    "email": "you@example.com",
    "url": "https://github.com/you"
  },
  "homepage": "https://github.com/...",
  "repository": "https://github.com/...",
  "license": "MIT",
  "keywords": ["claude-code", "skills", ...]
}
```

### Registering in Marketplace

Add your plugin to `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "your-plugin-name",
      "description": "Brief description",
      "version": "1.0.0",
      "source": "./plugins/your-plugin-name",
      "category": "development",
      "tags": ["tag1", "tag2"],
      "author": { ... },
      "homepage": "..."
    }
  ]
}
```

## Version Management

### Version Locations

Versions must be synchronized across three files:

| File | Field |
|------|-------|
| `.claude-plugin/marketplace.json` | `.version` and `.plugins[].version` |
| `plugins/{name}/.claude-plugin/plugin.json` | `.version` |
| `plugins/{name}/CHANGELOG.md` | Latest `## [x.y.z]` heading |

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/):

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Breaking changes | MAJOR | 1.0.0 → 2.0.0 |
| New features | MINOR | 1.0.0 → 1.1.0 |
| Bug fixes | PATCH | 1.0.0 → 1.0.1 |

### CHANGELOG Format

Follow [Keep a Changelog](https://keepachangelog.com/):

```markdown
## [1.1.0] - 2026-01-24

### Added
- New feature description

### Changed
- Modified behavior description

### Fixed
- Bug fix description
```

## Release Process

### For Contributors

1. **Create feature branch** from `main`:

   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/your-feature
   ```

2. **Make your changes**

3. **Bump version** in all three locations:
   - `.claude-plugin/marketplace.json`
   - `plugins/{name}/.claude-plugin/plugin.json`
   - `plugins/{name}/CHANGELOG.md`

4. **Commit with conventional format**:

   ```bash
   git commit -m "feat(skill): add new capability"
   ```

5. **Push and create PR** targeting `main`:

   ```bash
   git push -u origin feature/your-feature
   gh pr create --base main
   ```

6. **CI will verify**:
   - All versions are synchronized
   - Version is bumped (different from main)
   - New version is greater than current main version

### Automatic Release

When your PR is merged to `main`:

1. The release workflow automatically triggers
2. Extracts version from `marketplace.json`
3. Extracts release notes from `CHANGELOG.md`
4. Creates GitHub Release with tag `v{version}`
5. Skips if tag already exists (idempotent)

### Manual Release (Maintainers Only)

If automatic release fails:

```bash
# Get version
VERSION=$(jq -r '.version' .claude-plugin/marketplace.json)

# Create and push tag
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin "v$VERSION"

# Create GitHub release
gh release create "v$VERSION" --title "v$VERSION" --notes-file release_notes.md
```

## Pull Request Guidelines

### Branch Naming

```text
feature/description    # New features
fix/description        # Bug fixes
docs/description       # Documentation only
chore/description      # Maintenance tasks
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```text
feat(scope): add new capability
fix(scope): correct bug in feature
docs(scope): update documentation
chore(scope): maintenance task
```

Examples:

```text
feat(skill): add publish skill for release workflow
fix(present): correct GitHub API URL for PR comments
docs(readme): add installation instructions
chore(ci): add version sync validation
```

### PR Requirements

- [ ] Version bumped in all three locations
- [ ] CHANGELOG updated with changes
- [ ] All CI checks pass
- [ ] Self-review completed
- [ ] Responds to all review feedback

### PR Description Template

```markdown
## Summary
Brief description of changes

## Changes
- Change 1
- Change 2

## Test Plan
- [ ] How you tested
- [ ] What to verify

## Checklist
- [ ] Version bumped
- [ ] CHANGELOG updated
- [ ] CI passes
```

## Code Quality

### Markdown Linting

All markdown files must pass linting:

```bash
markdownlint '**/*.md' --ignore node_modules
```

### JSON Validation

All JSON files must be valid:

```bash
for file in $(find . -name "*.json" -type f); do
  python3 -m json.tool "$file" > /dev/null || echo "Invalid: $file"
done
```

### SKILL.md Requirements

- Valid YAML frontmatter with required fields
- Under 500 lines
- Clear phase structure
- Concrete examples
- No hardcoded secrets

## CI/CD Pipeline

### Validation Checks (validate.yml)

Runs on all PRs and pushes:

| Check | Description |
|-------|-------------|
| Validate JSON | Syntax validation of all `.json` files |
| Version Sync Check | Ensures marketplace, plugin, and changelog versions match |
| Version Bump Required | PRs to main must increment version |
| Validate Skills | Checks SKILL.md frontmatter and line count |
| Security Scan | Detects potential secrets and credentials |

### Release Workflow (release.yml)

Runs on merge to `main`:

1. Extracts version from `marketplace.json`
2. Checks if tag already exists (skip if so)
3. Extracts release notes from `CHANGELOG.md`
4. Creates GitHub Release with tag

### Workflow Diagram

```text
PR to main
    │
    ├── Validate JSON ────────────┐
    ├── Version Sync Check ───────┤
    ├── Version Bump Required ────┼── All must pass
    ├── Validate Skills ──────────┤
    └── Security Scan ────────────┘
                                  │
                                  ▼
                            Merge to main
                                  │
                                  ▼
                         Release Workflow
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
              Tag exists?                 Tag doesn't exist
                    │                           │
                    ▼                           ▼
                  Skip                   Create Release
                                              │
                                              ▼
                                     GitHub Release v{x.y.z}
```

## Questions?

- Open an issue for questions or suggestions
- See individual plugin READMEs for plugin-specific guidance
- Check existing skills for patterns and examples

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
