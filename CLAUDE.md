# Keller Solutions Marketplace

This is a Claude Code plugin marketplace for distributing custom skills.

## Repository Structure

- `.claude-plugin/marketplace.json` - Marketplace catalog
- `plugins/` - Plugin directories
- `plugins/*/skills/` - Skill definitions (SKILL.md files)

## Development Commands

```bash
# Validate all JSON files
for file in $(find . -name "*.json" -type f); do python3 -m json.tool "$file" > /dev/null; done

# Add a new skill
cp -r plugins/keller-solutions-core/skills/skill-template plugins/keller-solutions-core/skills/new-skill
```

## Conventions

- Use GitFlow branching (main, develop, feature/*)
- Conventional commits (feat:, fix:, docs:)
- Semantic versioning for plugins and skills
- Keep SKILL.md files under 500 lines

## Available Marketplace Operations

Agents can:
- Search plugins: Read `.claude-plugin/marketplace.json`
- Install plugin: Copy to `~/.claude/plugins/`
- Create skill: Copy from `skill-template`, validate, commit
- Validate skill: Check SKILL.md frontmatter and structure

## Skill Authoring

1. Use gerund naming: `processing-pdfs`, `analyzing-code`
2. Description formula: `[What it does]. Use when [trigger conditions].`
3. Include Quick Start section
4. Provide concrete examples with input/output
5. Keep under 500 lines
