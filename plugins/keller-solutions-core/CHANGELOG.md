# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Guardrail hooks** — the plugin now ships deterministic enforcement in
  `hooks/`: `gh pr merge` (any form) and force pushes are denied with
  what-to-do-instead reasons; CLI remote-branch deletion (closes dependent
  PRs) and direct commits on main/develop ask first. Only universally-safe
  rules are always-on; pipeline-specific gates belong in skill-scoped
  hooks. Honest limits plus copy-paste user-settings deny rules (plugins
  cannot ship permission rules) documented in the new
  `references/guardrails.md`. Script verified against seven test cases;
  `claude plugin validate` passes. (#31)

### Changed

- **Quality gates now mirror CI exactly** — prep derives the gate from the
  repo's own CI definitions (`bin/ci`/`config/ci.rb`, GitHub workflows,
  CodeBuild specs; union when they disagree) and records it as
  `QUALITY_GATE` (blocking, system tests included) plus `AUDIT_CHECKS`
  (advisory). Produce and present run that derived gate — never plain
  `bin/rails test`, which excludes system tests. Present never reports the
  workflow complete while any PR check fails: pre-existing failures get the
  named-advisory playbook (separate lockfile-bump PR + merge order); in Epic
  Mode the next child is blocked while the current child's checks are red;
  stacked children absorb base fixes by merge, never rebase. New reference:
  `references/quality-gate.md`. (#22)
- **Copilot review loop is autonomous** — present size-guards the diff
  (300-file limit), requests the review itself (`gh pr edit --add-reviewer
  @copilot`, REST fallback, dedupe by head SHA), polls to completion with a
  bounded timeout, addresses every comment with in-thread replies, and
  reports counts in the hand-back. Thread resolution stays with the
  reviewer — never marked resolved by the skill; repos requiring resolution
  are called out in the hand-back. Re-reviews requested only for
  substantive changes (reviews are usage-billed). New reference:
  `references/copilot-review.md`. (#21)
- **"Fixed" now requires runtime proof** — produce's gate states that a
  green suite is necessary, not sufficient: fix claims carry a screenshot,
  log line, passing repro, or a response from the running app.
  Troubleshooting mode: no commits until the human confirms (WIP prefix for
  rare checkpoints); two failed attempts → root-cause, never a third
  symptom-chase; external-system claims need receipts and
  correlation ≠ causation. Coverage fallback recorded: 100% diff coverage
  where total-100 is unreachable. CLAUDE template gains a Troubleshooting
  Discipline section. New reference: `references/verified-fix.md`. (#23)
- **Evidence is contractual** — per-criterion visible proof captured on
  production-realistic data (no invented external IDs; unmistakable
  fixtures), saved to a gitignored `evidence/<ticket>/` with paths echoed,
  attached to the ticket/PR and never committed. Attach-as-you-go now
  includes Azure DevOps and Jira alongside ClickUp; GitHub uses the
  browser-upload `user-attachments` path (CI-artifact fallback;
  Mermaid/text when a diagram beats a pixel). Verification data survives
  until the developer confirms done. New reference:
  `references/evidence.md`. (#24)
- **Stories carry their visual reference; UI verifies against it** — plan
  attaches the cropped wireframe/comp region to the ticket at carding time
  (when sources exist; never blocks when they don't), and present gains a
  Design-Fidelity Pass: side-by-side against the ticket's attachment, a
  "more like this" sweep when a miss is found, and a sibling-surface sweep
  when shared partials/patterns change. (#25)
- **Ticket lifecycle is live and remembered** — In Progress lands before
  the first line of code; full work-item bodies are fetched before any
  planning or grouping (titles mislead); every hand-back names the ticket
  ID; and the first confirmed discovery of a project's status workflow is
  written back into that project (CLAUDE.md `Ticket Workflow` block or
  project memory) so it is never rediscovered. prep reads the documented
  workflow first. Applied to this repo's own CLAUDE.md. (#26)
- **ks-ticket infers the delivery shape** — a parent ticket with children
  is an epic; multiple ticket IDs in any phrasing are an impromptu epic
  (same treatment, the given tickets as children); a lone childless ticket
  runs the single flow. Natural-language modifiers honored, never
  required ("stack this on #N", "hold the PR until I say"); the inferred
  shape is confirmed in one line before work starts; every shape inherits
  the full process. Epic Mode defines impromptu epics, and its evidence
  buckets now match the evidence reference (ADO/Jira attach-as-you-go). (#27)
- **Epic Mode is hardened for long and overnight runs** — run state
  externalized to gitignored `.ks/` files (JSON child list + progress
  notes) with a git-log-first resume ritual that survives compaction and
  session breaks; a hard gate between children (N+1 never starts while N
  is red); self-unblock rules (consult the decisions register, create
  producible preconditions, only then park `blocked:<reason>` with a
  ticket comment); and no-rewrite stacked-epic mechanics (branch from the
  parent epic, sync by merge, delete merged bases via UI/API only — CLI
  branch deletion closes dependent PRs — verify retarget, size-guard the
  delta). Replaces the hand-written overnight brief ritual. (#28)
- **Commit granularity: one per story is the floor, not the ceiling** —
  additional commits welcome; every commit shippable (compiles, tests
  pass) with `WIP:` prefixing the rare exception; never squash or rewrite.
  Git Integrity gains the `--first-parent` discipline: story-level log and
  bisect on merge-commit history — the standing answer to "squash for a
  clean log" — plus the agent-era rationale that granular unrewritten
  history doubles as machine-readable memory. (#29)
- **Every skill self-checks before claiming completion** — all six skills
  end their reports with honest ✓/✗ verdicts; any ✗ retitles the report as
  *status* ("Implementation Status", "PR Status", "Environment Status",
  "Release Status") and names what remains — "complete/done/ready" is
  earned by an all-✓ list. Plan's Story Checklist blocks ticket creation
  on an ✗. Verdicts persist to epic run state and re-derive from artifacts
  after compaction. The enforcement ladder (printed checklist → guardrail
  hooks → goal condition → fresh-context verification) is documented in
  the new `references/self-check.md`. (#30)
- **Attribution and branch targets resolve from the project, not
  templates** — attribution is generic (`Co-Authored-By: Claude`, never a
  model-version string) and fully conditional on the project's visibility
  preference (Invisible projects get zero AI references anywhere); present
  detects the target branch (develop when it exists, else the repo's
  default; hotfixes → main; stacked epics → parent branch) instead of
  hardcoding develop; and the hand-back's merge guidance now matches
  doctrine — merge commit, UI/API branch deletion, no squash (the old
  `gh pr merge --squash --delete-branch` suggestion contradicted Git
  Integrity). (#32)
- **Dependent-plugin references verified current** — compound-engineering
  v3 renamed its commands to `ce-*`: produce and present now point at
  `/ce-plan`, `/ce-brainstorm`, `/ce-work`, `/ce-code-review`,
  `/ce-resolve-pr-feedback`, `/ce-simplify-code`, `/ce-test-browser`
  (verified against installed 3.19.0), with a stated rule that a missing
  helper never blocks — do the step manually. README records tested
  dependency versions. (#33)
- **Git Integrity covers the previously-silent cases** — a client-policy
  override clause (avoid squash, but the client's repo convention wins,
  recorded once in project context); a "Stacking Without Lying" recipe
  (branch from parent, sync by merge, UI/API-only base deletion since CLI
  deletion closes dependent PRs, verify retarget) with the note that
  mainstream stacking tools all rebase — which is why we don't use them.
  (#34; joins #29's `--first-parent` discipline and WIP convention)
- **CHANGELOG discipline is part of the work** — the `[Unreleased]` entry
  rides in the same commit as the story it documents; in repos with a
  changelog, the self-check fails a story that changed code but not the
  changelog; repos without one are surfaced once, never forced. publish
  gains Step 2.0: promote `[Unreleased]` into the versioned section with
  human curation (optional `git cliff --unreleased` keepachangelog
  drafting). (#35)
- **prep is reality-checked, cached, and a bookend** — Step 1.0 reads
  project memory (lessons applied, not rediscovered) and a `.ks/`
  context cache with a staleness check, fast-pathing repeat sessions;
  stale-state cleanup now catches uncommitted/unpushed work, orphaned dev
  servers, and leftover worktrees (rolling back their shared-dev-DB
  migrations first — an orphaned migration once drifted for 18 days);
  the database step flags phantom migrations and schema drift at session
  start. present and publish close by offering the "next thing" prep
  pass, making prep both ends of the session. (#38)
- **publish triggers naturally and verifies to completion** — "cut a
  release"-style phrasing invokes it (no exact command); deployment is
  watched to a terminal state (Heroku release polling with failure output
  fetched — a failed release phase means not deployed); smoke includes a
  health-endpoint check and deployed-version-vs-tag comparison; error
  monitoring gets concrete Sentry release/deploy marking and a
  crash-free-rate check after a bake period. The local GitFlow release
  merge is documented as sanctioned ritual, distinct from PR merges
  (always the developer's act). (#39)

## [1.5.0] - 2026-07-02

### Added

- **Azure DevOps support** — new project management tool option across the
  workflow. The managing-tickets skill gains a full Azure DevOps section
  (`az boards` via the Azure DevOps CLI extension, authenticated with a
  Personal Access Token through `AZURE_DEVOPS_EXT_PAT`): create/read work
  items, update state, comment via `--discussion`, and `AB#[ID]` PR
  auto-linking. Detection (prep + managing-tickets) recognizes
  `.azuredevops`, `.env` references, `AZURE_DEVOPS_EXT_PAT`, or a
  `dev.azure.com` git remote. Epic Mode maps Epic/Feature work items with
  parent/child links; plan, produce, present, and publish reference the new
  tool in their quick references.

### Changed

- **Credential management** — Apple Keychain (`security` CLI) is now the
  preferred token store, reflecting the move away from 1Password; 1Password
  remains in use as a fallback. Tokens resolve environment variable →
  Apple Keychain → 1Password via a shared `get_token` pattern in the
  managing-tickets skill.

## [1.4.0] - 2026-06-17

### Added

- **Epic Mode** reference (`references/epic-mode.md`) — delivering an epic/parent
  ticket as a single branch and a single PR: detect the epic and its children,
  iterate the produce skill over each child **in order** (one commit per child,
  status kept live, evidence captured as each child is done), run the project's
  in-depth stack review, then present **once**.
- **prep** skill - now discovers the project's **status workflow** (actual state
  names + order) and **code-review approach**, surfaced in the Development Context.
- **managing-tickets** skill - adds status-workflow discovery, an evidence
  attachment operation per tool (ClickUp attaches as you go; GitHub/Jira/Linear
  hold-and-batch), and an epic lifecycle section.

### Changed

- **produce** skill - commit rule corrected to **one commit per user story**
  (not per acceptance criterion); a story with 6 criteria is still 1 commit. Adds
  Epic Mode awareness (reuse the epic branch, set child status to awaiting-review
  when its commit lands).
- **present** skill - adds an in-depth, stack-appropriate review (e.g. DHH for
  Rails) before **every** PR; the specific review is a project-level
  determination. In Epic Mode, present runs once for the whole epic.
- **ks-ticket** command - detects an epic/parent ticket and routes to Epic Mode
  (one branch/PR, ordered child iteration); single tickets are unchanged.

## [1.3.0] - 2026-06-14

### Added

- **Quality Dimensions** reference (`references/quality-dimensions.md`) — the nine
  dimensions every feature is evaluated against: Security, Performance/CWV,
  Accessibility, SEO, AEO, Reliability, Privacy, Observability, and Cost & Efficiency.
  Framed as a per-feature lens (triage to what the feature touches; record the rest
  as N/A), applied across plan → produce → present rather than a separate end audit.

### Changed

- **plan** skill - Phase 1 now includes a quality-dimensions pass (Step 1.4):
  applicable dimensions become acceptance criteria (browser-verifiable) or Developer
  Notes up front; added to the Story Checklist.
- **produce** skill - Phase 4 gains a Quality Dimensions Review (Step 4.5) before the
  ready report; added to the self-review checklist and the ready report's quality gates.
- **present** skill - the PR body now carries a Quality Dimensions section (which
  applied and how each was addressed/verified, the rest N/A); added to the self-review
  and ready-for-merge checklists.

## [1.2.1] - 2026-06-12

### Changed

- **present** skill - Improved PR comment reply instructions
  - Explicit step to read `references/ai-visibility.md` for response format
  - Clarified that replies must go directly to each comment thread (not general PR comments)
  - Added `gh api` command example for replying to review comments

## [1.2.0] - 2026-06-12

### Added

- **plan** skill: perspective rule—personas stay on the user's side of the glass; developer/platform/system personas are banned, with groundwork reframed as the capability it enables
- **plan** skill: source-grounding step (read requirements/designs/architecture before writing, just-in-time design reading, source precedence for conflicts)
- **plan** skill: ask-as-they-arise question protocol—decide low-stakes calls and log them as Planning Decisions for ratification; ask only on genuine product/scope decisions or conflicting sources
- **plan** skill: new anti-patterns—The Fake Persona, The Placeholder, The Forward Dependency, The Hidden Plumbing
- **plan** skill: **Story Map Mode** (new `references/story-map-mode.md`) for multi-screen feature sets—epics with continuous numbering, coverage tables (element/interaction → story ID), architecture sync rule, pre-storycarding checkpoint, end-of-session QA pass, tickets created only after ratification
- **plan** skill: source-agnostic decomposition—wireframes, specs, or a bare prompt description all break down to key interactions carded as one context, one action, one outcome
- **plan** skill: QA Pass targets drift—consistency of personas/terminology/conventions across the set, delivery-order walk (the Seeding Test at map scale), with extra scrutiny on the latest-written stories
- **plan** skill: **Elements Ship With Their Stories** section—a UI element appears only when the story that makes it work ships; the story delivering a destination also delivers its entry point (About Us nav-link example), and each additional entry point is its own story
- **plan** skill: The Wireframe Dump anti-pattern—building every element a wireframe shows before the stories that wire them up
- **produce** skill: build only this story's slice of the design—no placeholder nav items, buttons, or `#` links for elements that belong to later stories
- **present** skill: walk the story as the user before gathering evidence—browser only, no Rails console; seeding not anticipated in the story's Developer Notes is a flag to resolve before review

### Fixed

- **prep** skill: installing is not updating—on projects following the 24-Hour Rule, run the real update (`bundle update`/`npm update`/`composer update`) at the start of each work session and commit the lockfile in the same PR as the day's work; projects may opt out via a stated policy (pins, Dependabot/Renovate, release process)
- **prep** skill: Development Context summary gains a Dependency Updates row (24-Hour Rule vs. opt-out with policy source) so the update policy is verified and visible alongside Ticket System, AI Visibility, and CHANGELOG status
- **prep** skill: lockfile freshness check now reports whichever lockfile the project has (Gemfile.lock, package-lock.json, yarn.lock, composer.lock) instead of only Gemfile.lock
- All skills: repaired `../references/` links, which resolved to a non-existent `skills/references/` path—correct path from a skill directory is `../../references/`

### Changed

- **plan** skill: replaced the CRUD-ordering section with the general **Deliver Without Seeding** principle—every story should be acceptable using only what earlier stories built, with seeding a last resort called out in Developer Notes; CRUD (add → index → detail → edit → delete) is the worked example
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
