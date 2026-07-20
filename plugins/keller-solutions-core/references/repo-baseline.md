# KS Repo Baseline

Server-side and repo-level reinforcements for repos you own. **Guidance, not prescription**: each item states what it enforces and what it costs — adoption is a per-repo judgment call. Client repos get whatever subset their owner permits. prep reports which items a repo has (Development Context → Repo Baseline row).

## 1. Branch Ruleset (Settings → Rules → Rulesets)

| Rule | Enforces | Costs |
|------|----------|-------|
| Block force pushes (default-on) | Git Integrity server-side — even a bypassed local guardrail can't rewrite | Nothing |
| Require a pull request before merging | The pipeline's PR path is the only path | Solo hotfix friction (rulesets support bypass lists) |
| Required status checks | Green-before-merge enforced by GitHub, not by discipline | Checks must exist and be stable first |
| Automatically request Copilot code review | Deletes present's request step on this repo (skill then just verifies) | Per-review AI-Credit spend on every PR, incl. "review new pushes" if enabled — leave re-review to the skill's substantive-change policy |

Note: Copilot review can be *requested* by ruleset but never *required* — its reviews are comment-only and don't satisfy approval requirements. The pipeline's own poll-for-review gate stays.

## 2. `bin/ci` + gh-signoff

Adopt Rails 8.1's `bin/ci` (`app:update`, or hand-write `config/ci.rb` on 7.x) **edited from stock**: uncomment/include system tests (the stock template omits them locally while CI runs them — drift by default) and move `bundler-audit` out of the blocking steps. Then install [gh-signoff](https://github.com/basecamp/gh-signoff) so a passing local `bin/ci` posts a commit status branch protection can require — the agent's local gate becomes *recorded*, not self-reported.

**Enforces**: one command = what CI runs; verifiable local gates. **Costs**: initial file authoring per repo; keeping ci.rb and workflows in sync (prep's union-derivation flags divergence).

## 3. Dependency Automation

**Renovate with a shared preset repo** (one config governing the fleet): `vulnerabilityAlerts` (advisory PRs skip schedules and limits), `automerge` on green for lockfile-only/patch updates, `minimumReleaseAge: '3 days'` for non-security bumps. **Fallback**: Dependabot grouped security updates.

**Enforces**: advisories arrive as green bot PRs, never as red deploys (pairs with the audit-off-the-blocking-path rule in [Quality Gate](quality-gate.md)). **Costs**: preset repo setup once; PR review trickle.

## 4. `.github/copilot-instructions.md`

Tune Copilot's reviews to the house standards: the nine [Quality Dimensions](quality-dimensions.md), Git Integrity expectations, the project's stack conventions. The old character cap is gone.

**Enforces**: reviewer attention on what KS actually cares about. **Costs**: one file; occasional upkeep.

## 5. Changelog Check (repos that keep one)

A lightweight CI check (Changelog-Enforcer-style action with a `no changelog` skip label) that fails PRs touching code but not `CHANGELOG.md`.

**Enforces**: the entry-rides-with-the-story rule (#35) mechanically. **Costs**: the skip label must be applied consciously on genuinely changelog-free changes.

## Rollout

Fleet rollout is deliberate, repo by repo — start with the active SaaS products (a11y-audit, rampscope, splitwing), then quiet repos as they wake. When prep finds none of the baseline in a repo you own, it says so once in the Development Context and moves on.
