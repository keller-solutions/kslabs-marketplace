# Keller Solutions Marketplace

[![Validate](https://github.com/keller-solutions/keller-solutions-marketplace/actions/workflows/validate.yml/badge.svg)](https://github.com/keller-solutions/keller-solutions-marketplace/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Curated Claude Code skills and plugins from Keller Solutions.

## Installation

Add this marketplace to Claude Code:

```bash
/plugin marketplace add keller-solutions/keller-solutions-marketplace
```

Then install a plugin:

```bash
/plugin install keller-solutions-core@keller-solutions-marketplace
```

## Available Plugins

| Plugin | Description | Category |
|--------|-------------|----------|
| keller-solutions-core | Core skills and utilities | development |

## Contributing

We welcome contributions! To add a new skill:

1. **Fork this repository**
2. **Create your skill directory**: `plugins/keller-solutions-core/skills/your-skill-name/`
3. **Copy the template**: Use `skill-template` as a starting point
4. **Write your SKILL.md** with:
   - Valid YAML frontmatter (name, description)
   - Description with trigger keywords
   - Quick Start section
   - Clear instructions
   - Concrete examples
5. **Validate**: Ensure frontmatter is valid and content is under 500 lines
6. **Submit a PR**

### Skill Requirements

- [ ] Name: lowercase with hyphens, max 64 characters
- [ ] Description: includes what it does AND when to use it
- [ ] Body: under 500 lines
- [ ] Examples: concrete input/output pairs
- [ ] License: MIT or compatible

See `plugins/keller-solutions-core/skills/skill-template/SKILL.md` for a complete example.

## License

MIT
