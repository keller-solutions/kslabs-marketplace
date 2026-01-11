---
name: marketplace-ops
description: This skill enables programmatic marketplace operations for agents. Use when searching plugins, installing from marketplace, creating new skills, or validating skill structure.
version: 0.1.0
allowed-tools: Read, Glob, Grep, Bash
---

# Marketplace Operations

This skill enables agents to interact with the Keller Solutions Marketplace programmatically.

## Quick Start

To search for plugins:

```text
Read .claude-plugin/marketplace.json and filter plugins by category
```

## Instructions

### Search Marketplace

To find plugins:

1. Read `.claude-plugin/marketplace.json`
2. Parse the `plugins` array
3. Filter by `category` or search `description`

### Install Plugin

To install a plugin:

1. Identify plugin source path from marketplace.json
2. Copy plugin directory to `~/.claude/plugins/<plugin-name>/`
3. The plugin will be available on next Claude Code session

### Create New Skill

To create a skill:

1. Create directory: `plugins/<plugin>/skills/<skill-name>/`
2. Copy `skill-template/SKILL.md` to new directory
3. Edit frontmatter: name, description, version
4. Add skill content
5. Validate before committing

### Validate Skill

Check these requirements:

- [ ] SKILL.md exists in skill directory
- [ ] Frontmatter has `name` and `description`
- [ ] Name matches directory name (lowercase, hyphens)
- [ ] Name is max 64 characters
- [ ] Version follows semver if present
- [ ] Body is under 500 lines

## Examples

**Example 1: Find Development Plugins**
Input: Agent needs to find development-related plugins
Output:

```bash
# Read marketplace.json and filter
cat .claude-plugin/marketplace.json | jq '.plugins[] | select(.category == "development")'
```

**Example 2: Validate Skill Structure**
Input: Agent creates a new skill and needs to validate it
Output:

```bash
# Check SKILL.md exists and has required frontmatter
if [ -f "skills/my-skill/SKILL.md" ]; then
  head -20 skills/my-skill/SKILL.md | grep -E "^name:|^description:"
fi
```

## Guidelines

- Always validate skills before committing
- Use the skill-template as a starting point
- Keep skill names lowercase with hyphens
- Include trigger keywords in descriptions
