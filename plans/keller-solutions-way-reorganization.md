# The Keller Solutions Way - Plugin Reorganization Plan

## Overview

Transform the keller-solutions-core plugin into a comprehensive methodology encapsulating 30 years of development experience. The methodology is framework-agnostic, adapting to whatever project is at hand while maintaining consistent principles.

## The 5 P's of The Keller Solutions Way

| Phase | Skill | Command | Purpose |
|-------|-------|---------|---------|
| 1. **Prepare** | `keller-solutions-core:prep` | `/ks-prep` | Orient and ready the environment |
| 2. **Plan** | `keller-solutions-core:plan` | `/ks-plan` | Write stories, create tickets |
| 3. **Produce** | `keller-solutions-core:produce` | `/ks-produce` | TDD implementation following principles |
| 4. **Present** | `keller-solutions-core:present` | `/ks-present` | Self-review, PR, feedback loop |
| 5. **Publish** | `keller-solutions-core:publish` | `/ks-publish` | Release, deploy, verify |

### Potential Future P's (Preserving Alliteration)

| Phase | Purpose | When to Add |
|-------|---------|-------------|
| **Protect** | Security review, vulnerability scanning | When security workflows mature |
| **Preserve** | Documentation, knowledge capture, compounding | When docs workflow needed |
| **Patrol** | Monitoring, maintenance, health checks | When ops workflows needed |

## Workflow Commands

| Command | Skills Used | Purpose |
|---------|-------------|---------|
| `/ks-feature [description]` | Prepare→Plan→Produce→Present | Full feature from idea to PR |
| `/ks-ticket [ticket-number]` | Prepare→Produce→Present | Work existing ticket to PR |
| `/lg [description]` | (alias to `/ks-feature`) | Legacy command, maintained for compatibility |

---

## Directory Structure

```
plugins/keller-solutions-core/
├── .claude-plugin/
│   └── plugin.json                    # Updated metadata
├── README.md                          # Plugin documentation
│
├── commands/
│   ├── ks-feature.md                  # Full workflow (Prepare→Plan→Produce→Present)
│   ├── ks-ticket.md                   # Ticket workflow (Prepare→Produce→Present)
│   ├── lg.md                          # Alias to ks-feature (legacy compatibility)
│   ├── ks-prep.md                     # Invoke prep skill
│   ├── ks-plan.md                     # Invoke plan skill
│   ├── ks-produce.md                  # Invoke produce skill
│   ├── ks-present.md                  # Invoke present skill
│   └── ks-publish.md                  # Invoke publish skill
│
├── skills/
│   ├── prep/
│   │   ├── SKILL.md                   # Prepare the work
│   │   └── references/
│   │       ├── project-orientation.md
│   │       └── environment-setup.md
│   │
│   ├── plan/
│   │   ├── SKILL.md                   # Plan the work
│   │   ├── references/
│   │   │   └── story-writing-guide.md # From kslabs-a11y-audit
│   │   └── templates/
│   │       └── story-template.md
│   │
│   ├── produce/
│   │   ├── SKILL.md                   # Produce the work
│   │   └── references/
│   │       ├── coding-guidelines.md   # From kslabs-a11y-audit
│   │       ├── tdd-philosophy.md
│   │       ├── conventional-commits.md
│   │       └── git-integrity.md       # "Thou shall not lie"
│   │       # Note: ADR template referenced from templates/ADR-template.md
│   │
│   ├── present/
│   │   ├── SKILL.md                   # Present the work
│   │   ├── references/
│   │   │   ├── self-review-checklist.md
│   │   │   └── feedback-response.md
│   │   └── templates/
│   │       └── pr-template.md
│   │
│   └── publish/
│       ├── SKILL.md                   # Publish the work
│       └── references/
│           ├── release-notes.md
│           └── deployment-verification.md
│
├── references/                        # Shared across all skills
│   ├── guiding-principles.md          # KS Guiding Principles
│   ├── ai-visibility.md               # Up-front vs behind-the-scenes
│   ├── test-coverage-philosophy.md    # 100% coverage philosophy
│   └── frameworks/
│       ├── ruby/
│       │   ├── rails.md               # Tier 1: Primary stack
│       │   ├── common-ruby.md         # Shared Ruby patterns (Bundler, RuboCop, etc.)
│       │   └── sinatra.md             # Lightweight Ruby
│       ├── javascript/
│       │   ├── react.md               # React + TypeScript
│       │   ├── astro.md               # Astro framework
│       │   ├── nextjs.md              # Next.js patterns
│       │   └── common-js.md           # Shared JS/TS patterns (ESLint, Prettier, Jest)
│       ├── php/
│       │   ├── laravel.md             # Laravel framework
│       │   ├── drupal.md              # Drupal CMS
│       │   ├── wordpress.md           # WordPress CMS
│       │   └── common-php.md          # Shared PHP patterns (PSR-12, Composer, PHPUnit)
│       └── dotnet/
│           ├── aspnet-core.md         # ASP.NET Core MVC/API
│           └── common-dotnet.md       # Shared .NET patterns (xUnit, StyleCop)
│
└── templates/                         # Project scaffolding templates
    ├── README-template.md
    ├── CONTRIBUTING-template.md
    ├── CLAUDE-template.md
    └── ADR-template.md
```

---

## Phase 1: Shared References & Templates

Create foundational documents that all skills reference.

### 1.1 Guiding Principles (`references/guiding-principles.md`)

Core principles that govern all work:
- DRY (Don't Repeat Yourself)
- Separate Code from Content
- Avoid Pre-Optimization
- Keep Code Tidy
- Maintain Consistency
- Make It Understandable
- Comments explain WHY, not WHAT

### 1.2 AI Visibility (`references/ai-visibility.md`)

How to determine and respect client preferences:
- Check CLAUDE.md in .gitignore
- Look at commit history for AI references
- Check PR descriptions
- When in doubt, ask and record answer

### 1.3 Test Coverage Philosophy (`references/test-coverage-philosophy.md`) ✅ CREATED

Based on: ["Test Coverage Only Matters if at 100 Percent"](https://www.dein.fr/posts/2019-09-06-test-coverage-only-matters-if-at-100-percent)

**Key insight**: 100% coverage doesn't mean every line is executed in tests—it means every line is **accounted for** (tested OR explicitly excluded with justification).

Contents:
- Why 100% accountability matters
- Being intentional about exclusions
- **How to exclude code by language** (Ruby, JS/TS, PHP, C#)
- Documentation requirements for exclusions
- The ratchet principle

### 1.4 Git Integrity (`references/git-integrity.md`)

"Thou shall not lie" principle:
- No squash merges (preserve history)
- No rebasing shared branches
- No amending pushed commits
- Why history matters

### 1.5 Framework Examples (Priority Order)

Concrete examples for common stacks, ordered by Keller Solutions usage:

**Tier 1: Rails** (Most comprehensive - primary stack)
- Gemfile for dependencies
- Minitest or RSpec for testing
- RuboCop + rubocop-rails-omakase for linting
- ERB Lint for view templates
- Brakeman for security scanning
- SimpleCov for coverage
- Solid Queue/Cable/Cache patterns
- Hotwire (Turbo + Stimulus) for frontend

**Tier 2: React/TypeScript** (Comprehensive)
- package.json for dependencies
- Jest + React Testing Library for testing
- ESLint + Prettier for linting
- TypeScript strict mode configuration
- Vite or Next.js patterns
- Component architecture patterns

**Tier 3: PHP Frameworks** (Growing coverage)
- **Laravel**: composer.json, PHPUnit, Pint (Laravel's PHP-CS-Fixer), Pest
- **Drupal**: composer.json, PHPUnit, Drupal Coder (PHPCS), Drush
- **WordPress**: composer.json, PHPUnit, PHPCS + WordPress Coding Standards
- Common PHP: PSR-12 standards, Psalm/PHPStan for static analysis

**Tier 4: .NET** (Basic coverage)
- .csproj for project configuration
- xUnit or NUnit for testing
- StyleCop or dotnet-format for linting
- Entity Framework patterns
- ASP.NET Core MVC/API patterns

### 1.6 Templates

- **README-template.md**: Standard project README structure
- **CONTRIBUTING-template.md**: How to contribute
- **CLAUDE-template.md**: AI assistant configuration
- **ADR-template.md**: Architecture Decision Records

---

## Phase 2: Skill 1 - Prepare (`skills/prep/`)

### SKILL.md Content

**Purpose**: Orient yourself to the project and prepare the environment.

**Two main sections**:

1. **Project Orientation**
   - Read README.md for language, frameworks, tools
   - Read CONTRIBUTING.md for processes
   - Read CLAUDE.md for AI-specific guidance
   - Note the default branch
   - Review /docs folder and ADRs

2. **Environment Preparation**
   - Return to default branch, pull latest
   - Clean up stale branches
   - Run test suite (verify known-good state)
   - Check dependency freshness (24-hour rule)
   - Update dependencies if needed

**Key behaviors**:
- Detect project type automatically (Rails, React, etc.)
- Adapt commands to detected stack
- Report project summary after orientation

---

## Phase 3: Skill 2 - Plan (`skills/plan/`)

### SKILL.md Content

**Purpose**: Write great stories and publish tickets.

**Key sections**:

1. **Story Writing Guide** (from kslabs-a11y-audit)
   - "In order to / As a / I want" format
   - WHY before WHAT
   - Specific personas
   - 4-8 acceptance criteria
   - Observable outcomes

2. **Ticket Creation**
   - Detect project management tool (GitHub, Linear, Jira)
   - Use appropriate API/CLI
   - Link to epics if applicable
   - Apply labels/tags

**Templates**:
- Story template with all required sections
- Bug report template
- Chore template

---

## Phase 4: Skill 3 - Produce (`skills/produce/`)

### SKILL.md Content

**Purpose**: TDD implementation following KS principles.

**Key sections**:

1. **Pre-flight Checks**
   - Ensure prep has been run
   - Determine AI visibility preference
   - Verify working from a ticket
   - Create/verify appropriate branch

2. **Execution Planning**
   - Build execution plan from ticket
   - Consult existing ADRs
   - Create new ADR if architectural decision needed

3. **TDD Process**
   - Write test for each acceptance criterion
   - Red → Green → Refactor cycle
   - Add unit tests as you go deeper
   - Maintain coverage standards

4. **Quality Gates**
   - All linters pass
   - All tests pass
   - Coverage maintained
   - README updated if new libraries/linters added

5. **Commits**
   - Conventional commits (Keller Solutions way)
   - Git integrity (no squash/rebase/amend)
   - Reference tickets with `Refs #`

**Incorporated from /lg**:
- `/workflows:plan` for execution planning
- `/compound-engineering:deepen-plan` for research
- `/workflows:work` for TDD implementation
- `/workflows:review` for self-review
- `/compound-engineering:resolve_todo_parallel` for findings
- `/compound-engineering:lint` for quality

---

## Phase 5: Skill 4 - Present (`skills/present/`)

### SKILL.md Content

**Purpose**: Self-review, create PR, handle feedback.

**Key sections**:

1. **Self-Check**
   - Review all staged changes
   - Verify every change relates to ticket
   - Look for DRY opportunities
   - Check for accidental inclusions

2. **Evidence Gathering**
   - Record video walkthrough
   - Capture screenshots
   - Document test results

3. **PR Creation**
   - Use KS PR template
   - Reference all tickets
   - Include evidence
   - Target default branch

4. **Review Environment** (if applicable)
   - Verify in review server
   - Run Playwright tests

5. **Feedback Loop**
   - Collect Copilot feedback
   - Respond to every comment:
     - Agree: commit + reply with SHA
     - Disagree: reply with rationale
   - Iterate until resolved

6. **Post-Merge**
   - Verify on staging
   - Configure sample data
   - Attach evidence to ticket
   - Mark ready for acceptance

**Incorporated from /lg**:
- `/compound-engineering:feature-video`
- `/compound-engineering:playwright-test`
- `skill: pr-feedback-loop`
- `skill: pr-ready`

---

## Phase 6: Skill 5 - Publish (`skills/publish/`)

### SKILL.md Content

**Purpose**: Release, deploy, verify.

**Key sections**:

1. **Release Preparation**
   - Generate release notes from conventional commits
   - Review changelog
   - Determine version bump (semver)

2. **GitHub Release**
   - Draft release with notes
   - Tag version
   - Attach artifacts if applicable

3. **Deployment**
   - Initiate deployment (project-specific)
   - Monitor deployment status

4. **Verification**
   - Smoke test all tickets in release
   - Verify on production
   - Document any issues

---

## Phase 7: Workflow Commands

### `/ks-feature` (commands/ks-feature.md)

Full workflow for new features (idea → PR):

```markdown
1. `/ralph-wiggum:ralph-loop "complete feature workflow" --completion-promise "DONE"`
2. `/ks-prep` - Prepare the work (orient + environment)
3. `/ks-plan $ARGUMENTS` - Plan the work (create ticket)
4. `/ks-produce` - Produce the work (TDD implementation)
5. `/ks-present` - Present the work (PR + feedback loop)
6. Output `<promise>DONE</promise>` when PR is ready for merge
```

### `/ks-ticket` (commands/ks-ticket.md)

Work an existing ticket (ticket → PR):

```markdown
1. `/ralph-wiggum:ralph-loop "complete ticket workflow" --completion-promise "DONE"`
2. `/ks-prep` - Prepare the work (orient + environment)
3. `/ks-produce $ARGUMENTS` - Produce the work (ticket number passed)
4. `/ks-present` - Present the work (PR + feedback loop)
5. Output `<promise>DONE</promise>` when PR is ready for merge
```

### `/lg` (commands/lg.md)

Legacy alias maintained for compatibility:

```markdown
# Alias to /ks-feature
Run `/ks-feature $ARGUMENTS`
```

---

## Phase 8: Migration & Cleanup

### Files to Remove

- `skills/session-start/` → Merged into `prep`
- `skills/story-create/` → Merged into `plan`
- `skills/feature-branch/` → Merged into `produce`
- `skills/pr-feedback-loop/` → Merged into `present`
- `skills/pr-ready/` → Merged into `present`
- `commands/lg.md` → Replaced by `ks-feature` and `ks-ticket`

### Files to Keep

- `skills/marketplace-ops/` - Utility skill
- `skills/skill-template/` - Reference for creating skills

---

## Implementation Order

1. **Create shared references** (`references/`)
2. **Create templates** (`templates/`)
3. **Create Skill 1: Prepare** (`skills/prep/`)
4. **Create Skill 2: Plan** (`skills/plan/`)
5. **Create Skill 3: Produce** (`skills/produce/`)
6. **Create Skill 4: Present** (`skills/present/`)
7. **Create Skill 5: Publish** (`skills/publish/`)
8. **Create commands** for each skill
9. **Create workflow commands** (`ks-feature`, `ks-ticket`)
10. **Update plugin.json** with new metadata
11. **Update README.md** with documentation
12. **Remove deprecated files**

---

## Content Sources

| Content | Source | Status |
|---------|--------|--------|
| Story Writing Guide | `kslabs-a11y-audit/docs/story-writing-guide.md` | To copy |
| Coding Guidelines | `kslabs-a11y-audit/docs/coding-guidelines.md` | To copy |
| ADR Template | `kslabs-a11y-audit/docs/adr/0000-template.md` | To copy |
| Workflow patterns | `kslabs-a11y-audit/CLAUDE.md` | To reference |
| Test Coverage Philosophy | [dein.fr article](https://www.dein.fr/posts/2019-09-06-test-coverage-only-matters-if-at-100-percent) + KS adaptations | ✅ Created |
| PR feedback process | Created `pr-feedback-loop` skill | To merge into Present |
| Git integrity | New (based on user input) | To create |
| AI visibility | New (based on user input) | To create |

---

## Decisions Made

| Question | Decision |
|----------|----------|
| **Alliteration** | ✅ Prepare, Plan, Produce, Present, Publish (with future P's: Protect, Preserve, Patrol) |
| **Command naming** | ✅ `/ks-` prefix for all commands (reinforces Keller Solutions branding) |
| **Legacy `/lg`** | ✅ Keep as alias to `/ks-feature` |
| **Framework priority** | ✅ Tier 1: Rails → Tier 2: React/TS → Tier 3: PHP (Laravel, Drupal, WordPress) → Tier 4: .NET |
| **Framework structure** | ✅ Language folders with framework subfiles (ruby/, javascript/, php/, dotnet/) |

## Additional Decisions

| Question | Decision |
|----------|----------|
| **ADR template location** | ✅ Single location in `templates/` - skills reference it, no duplication |
| **Standalone skills** | ✅ Yes - `/ks-prep`, `/ks-plan`, etc. work standalone AND in workflows |
| **compound-engineering dependency** | ✅ Leverage as dependency - benefit from enhancements, don't maintain duplicate code |

### Plugin Dependencies

```json
{
  "dependencies": {
    "compound-engineering": "^2.0.0",
    "ralph-wiggum": "^1.0.0"
  }
}
```

---

## Estimated Effort

| Phase | Files | Complexity | Notes |
|-------|-------|------------|-------|
| Shared references | 4 | Medium | guiding-principles, ai-visibility, test-coverage, git-integrity |
| Framework docs | 12 | Medium | 4 languages × 3 files each (common + frameworks) |
| Templates | 4 | Low | README, CONTRIBUTING, CLAUDE, ADR templates |
| Skill 1: Prepare | 3 | Medium | SKILL.md + 2 references |
| Skill 2: Plan | 4 | Medium | SKILL.md + story guide + templates |
| Skill 3: Produce | 6 | High | SKILL.md + coding guidelines + TDD + commits + git integrity + ADR |
| Skill 4: Present | 5 | High | SKILL.md + self-review + feedback + PR template |
| Skill 5: Publish | 3 | Medium | SKILL.md + release notes + deployment |
| Commands | 8 | Low | 5 skill commands + 2 workflows + 1 alias |
| Plugin metadata | 2 | Low | plugin.json + README.md |
| Cleanup | - | Low | Remove deprecated skills |

**Total**: ~51 files to create/modify

### Implementation Phases

| Phase | Description | Deliverable |
|-------|-------------|-------------|
| **Phase A** | Shared references + templates | Foundation documents |
| **Phase B** | Skills 1-2 (Prepare, Plan) | Project setup workflow |
| **Phase C** | Skills 3-4 (Produce, Present) | Core development workflow |
| **Phase D** | Skill 5 (Publish) + Commands | Complete workflow |
| **Phase E** | Framework docs (Rails first) | Tier 1 examples |
| **Phase F** | Framework docs (React/TS, PHP, .NET) | Remaining examples |
| **Phase G** | Cleanup + testing | Production ready |
