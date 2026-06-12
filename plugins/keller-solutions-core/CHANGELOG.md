# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-06-12

### Added

- **plan** skill: perspective rule—personas stay on the user's side of the glass; developer/platform/system personas are banned, with groundwork reframed as the capability it enables
- **plan** skill: source-grounding step (read requirements/designs/architecture before writing, just-in-time design reading, source precedence for conflicts)
- **plan** skill: ask-as-they-arise question protocol—decide low-stakes calls and log them as Planning Decisions for ratification; ask only on genuine product/scope decisions or conflicting sources
- **plan** skill: new anti-patterns—The Fake Persona, The Placeholder, The Forward Dependency, The Hidden Plumbing
- **plan** skill: **Story Map Mode** for multi-screen feature sets—epics with continuous numbering, coverage tables (element/interaction → story ID), architecture sync rule, pre-storycarding checkpoint, end-of-session QA pass, tickets created only after ratification
- **plan** skill: source-agnostic decomposition—wireframes, specs, or a bare prompt description all break down to key interactions carded as one context, one action, one outcome
- **plan** skill: QA Pass targets drift—consistency of personas/terminology/conventions across the set, delivery-order walk (the Seeding Test at map scale), with extra scrutiny on the latest-written stories
- **plan** skill: **Elements Ship With Their Stories** section—a UI element appears only when the story that makes it work ships; the story delivering a destination also delivers its entry point (About Us nav-link example), and each additional entry point is its own story
- **plan** skill: The Wireframe Dump anti-pattern—building every element a wireframe shows before the stories that wire them up
- **produce** skill: build only this story's slice of the design—no placeholder nav items, buttons, or `#` links for elements that belong to later stories

### Changed

- **plan** skill: replaced the CRUD-ordering section with the general **Deliver Without Seeding** principle—every story must be acceptable using only what earlier stories built, no seeded data; CRUD (add → index → detail → edit → delete) is the worked example
- **plan** skill: Chore story type tightened—one-line purpose tied to the user value it unlocks, reviewer-checkable completion criteria, no fake narrative, under 10% of total stories
- **plan** skill: Content section restricted to copy an acceptance criterion asserts verbatim; everything else points to References
- **plan** skill: References must cite the specific artifact and location (e.g. "Wireframe B2 p.4"), never a bare link or screen code
- **plan** skill: Story Checklist extended with perspective, self-sufficiency, Content, and Reference-specificity checks

## [1.1.1] - 2026-02-10

### Changed

- Migrated release workflow to org-level reusable workflow from keller-solutions/.github
- Reduced CI maintenance burden by centralizing release logic

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
