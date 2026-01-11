# Contributing to Keller Solutions Core

## Development Setup

1. Clone the marketplace repository
2. Install markdownlint: `npm install -g markdownlint-cli`
3. Install the plugin locally for testing

## Code Quality

### Markdown Linting

All markdown files must pass linting before commit:

```bash
markdownlint '**/*.md' --ignore node_modules
```

### File Structure

- **skills/** - SKILL.md files following the skill template
- **commands/** - Command files for workflow orchestration
- **references/** - Reference documentation
- **templates/** - Project templates

## Pull Request Process

1. Create a feature branch from `develop`
2. Make your changes following the Keller Solutions Way
3. Run linting and fix any issues
4. Create a PR targeting `develop`
5. Address all review feedback

## Skill Development

When creating new skills:

1. Use `skills/skill-template/SKILL.md` as a reference
2. Include proper YAML frontmatter (name, description, version, argument-hint)
3. Follow the phase structure pattern
4. Document standalone vs. workflow usage

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```text
feat(skill): add new capability
fix(command): correct workflow step
docs(readme): update installation instructions
```

## Questions?

See the [main repository](../../README.md) for additional guidelines.
