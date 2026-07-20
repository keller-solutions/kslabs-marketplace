# The Quality Gate: CI Parity

## The Core Rule

**The local gate is whatever CI actually runs — derived, not remembered.** A green local run that skipped what CI runs is not a gate; it's a guess. And nothing reports "done", "complete", or "ready" while any gate step — local or on the PR — is red.

## Deriving the Gate (during prep)

Read the repo's own definitions, in this order, and take the **union** when they disagree:

1. `bin/ci` / `config/ci.rb` — Rails 8.1 CI DSL. Trust it only after checking it against the workflow: the stock Rails template ships with system tests commented out locally while the generated workflow runs them in a separate job.
2. `.github/workflows/*.yml` — every job that gates PRs, including org-level required checks.
3. `buildspec*.yml` / CodeBuild definitions — client repos often gate deploys here (the classic: `bundle-audit check --update` failing a deploy with zero code changes).

Record the result in the Development Context as two lists:

- **QUALITY_GATE (blocking)**: tests including system tests, linters, static analysis, coverage checks. All must pass before any done-claim.
- **AUDIT_CHECKS (advisory)**: dependency/vulnerability scans (`bundle-audit`, `npm audit`, importmap audit). Run and report them — but a failing advisory is an *event*, not a broken codebase (see playbook below).

Fallbacks when no CI definition exists: `bin/ci` → `bin/rails test:all` (plain `bin/rails test` **excludes system tests** — never treat it as the full gate) → `npm test` + the repo's e2e command → `php artisan test` → `dotnet test`.

## Green Before Done (during present)

After the PR exists:

```bash
gh pr checks [PR_NUMBER] --watch
```

- **Never** report the workflow complete, or hand the PR back, while any check is failing — "entirely unrelated to this feature" is not an exemption. All PRs end green.
- In Epic Mode, child N+1 does not start while child N's checks are red.
- A stacked child absorbs base fixes by **merging the base branch in** (never rebasing), then re-verifying its checks.

## Stalled Checks: Check the Platform First

When checks sit queued/pending abnormally long (more than ~10 minutes with nothing in progress), **check GitHub's status page before diagnosing locally**:

```bash
curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.description'
curl -s https://www.githubstatus.com/api/v2/incidents/unresolved.json | jq -r '.incidents[].name'
```

An active Actions incident is the answer more often than anything in the repo — report it as the cause, keep the watcher running, and don't churn the queue with re-pushes. (Also keep workflows self-cleaning: a `concurrency` group with `cancel-in-progress` so superseded-commit runs never stack up behind the current one.)

## Pre-Existing Failure Playbook

When a check fails for reasons that predate the branch (a fresh advisory, an org-wide scan):

1. Say so explicitly — name the failing check and why it's pre-existing.
2. Propose the fix as its own PR (typically a lockfile-only bump to the minimum patched version).
3. Propose the merge order (fix PR first, then update this branch from the base and re-verify).
4. Do not proceed to the next story/epic until the plan is agreed or the checks are green.

## Advisory Audits Stay Off the Blocking Path

Security scans belong in the gate as *reporters*, not *blockers*: an overnight CVE should arrive as a green lockfile-bump PR (dependency bot or the playbook above), never as a mysterious red deploy. When adding `bin/ci` to a repo, move audit steps to a non-blocking section or a scheduled workflow.

## Recording the Gate (optional, KS-owned repos)

`gh-signoff` (Basecamp) posts a passing local `bin/ci` as a commit status that branch protection can require — turning the local run into a *recorded* gate instead of a self-reported claim. See [Repo Baseline](repo-baseline.md).
