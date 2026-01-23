# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-23

### Added

- ClickUp API instructions in all ticket-related skills
- Support for 1Password CLI token retrieval (Private vault)
- Environment variable detection for ClickUp (`CLICKUP_API_TOKEN`)
- CHANGELOG.md for version tracking
- CI/CD version sync validation (marketplace.json, plugin.json, CHANGELOG.md)
- CI/CD version bump enforcement on PRs to main
- Automatic GitHub Release creation on merge to main

### Changed

- Simplified workflow commands (removed external loop dependencies)
- Updated repository URLs to kslabs-marketplace
- Enriched marketplace.json with full plugin metadata

### Skills (5)

- **prep** - Environment preparation and project orientation
- **plan** - Story writing and ticket creation
- **produce** - TDD implementation workflow
- **present** - PR creation and feedback loop
- **publish** - Release and deployment workflow

### Commands (8)

- `/ks-feature` - Full workflow: Prep → Plan → Produce → Present
- `/ks-ticket` - Existing ticket workflow: Prep → Produce → Present
- `/ks-prep` - Standalone environment preparation
- `/ks-plan` - Standalone story and ticket creation
- `/ks-produce` - Standalone TDD implementation
- `/ks-present` - Standalone PR and feedback
- `/ks-publish` - Standalone release workflow
- `/lg` - Legacy alias for /ks-feature

## [0.2.0] - 2026-01-22

### Added

- Initial 5 P's workflow implementation
- Reference documentation (guiding principles, F5 manifesto, git integrity)
- Templates for README, CONTRIBUTING, CLAUDE.md, ADR
- GitHub and Jira integration examples

## [0.1.0] - 2026-01-09

### Added

- Initial plugin structure
- Basic skill and command framework
