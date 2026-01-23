# Keller Solutions Marketplace

[![Validate](https://github.com/keller-solutions/marketplace/actions/workflows/validate.yml/badge.svg)](https://github.com/keller-solutions/marketplace/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Curated Claude Code skills and plugins from Keller Solutions.

## Installation

Add this marketplace to Claude Code:

```bash
/plugin marketplace add keller-solutions/kslabs-marketplace
```

Then install a plugin:

```bash
/plugin install keller-solutions-core@kslabs-marketplace
```

## Available Plugins

| Plugin | Description | Category |
|--------|-------------|----------|
| keller-solutions-core | Core skills and utilities | development |

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for the complete guide, including:

- Development setup
- How to create skills and plugins
- Version management and release process
- Pull request guidelines
- CI/CD pipeline details

### Quick Start for Contributors

1. Fork and clone the repository
2. Create a feature branch from `main`
3. Make your changes (bump version if adding features)
4. Submit a PR targeting `main`

### Version Requirements

PRs to `main` must include a version bump. Update these three files:

| File | What to update |
|------|----------------|
| `.claude-plugin/marketplace.json` | `.version` and `.plugins[].version` |
| `plugins/{name}/.claude-plugin/plugin.json` | `.version` |
| `plugins/{name}/CHANGELOG.md` | Add new `## [x.y.z]` section |

When merged, a GitHub Release is created automatically.

## License

MIT
