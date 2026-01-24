# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-01-24

### Added

- **managing-tickets** skill - Unified interface for project management tools (GitHub Issues, Jira, ClickUp, Linear)
- Detection logic for identifying which tool a project uses
- 1Password integration for secure credential management
- Comprehensive CRUD operations for all supported tools
- CHANGELOG freshness verification in `prep` skill (cross-checks git tags and commits)
- CHANGELOG update step in `produce` skill (Keep a Changelog format)
- CHANGELOG verification in `present` skill (checks before PR creation, warns about CI validation)
- Development Context summary in `prep` skill with user confirmation pause
- Consolidated display of ticket system, test status, AI visibility, and CHANGELOG status

### Changed

- Updated `plan` skill to reference `managing-tickets` for ticket creation
- Updated `produce` skill to reference `managing-tickets` for status updates
- Updated `present` skill to reference `managing-tickets` for PR linking
- Updated `publish` skill to reference `managing-tickets` for release notifications
- Reduced duplication by consolidating tool-specific commands into single reference

### Skills (6)

- **prep** - Environment preparation and project orientation
- **plan** - Story writing and ticket creation
- **produce** - TDD implementation workflow
- **present** - PR creation and feedback loop
- **publish** - Release and deployment workflow
- **managing-tickets** - Unified project management tool interface

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
