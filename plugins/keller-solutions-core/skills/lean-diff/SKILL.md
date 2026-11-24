---
name: lean-diff
description: Strip a commit or PR down to only the code, tests and comments it needs. Checks relevance to the ticket, the additions-to-deletions ratio, whitespace and reorder noise, and whether each new test failed before the change. Use before every commit and PR, or when asked to "lean this out", "check the diff" or find unnecessary tests. Works standalone or inside produce and present.
version: 1.0.0
argument-hint: "['staged' or base branch]"
---

# Lean Diff

A reviewer should find nothing in the diff they could delete. It runs in two modes:

- **Staged** (before each commit): steps 1-4 on `--cached`.
- **Branch** (before the PR): steps 1-5 on `BASE...HEAD`. `BASE` is the PR's target branch, or else the repo default: `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.

## 1. Measure

```bash
git diff --stat --cached                       # staged; branch: git diff --stat BASE...HEAD
git diff --stat --cached -w --ignore-blank-lines
```

Any difference between the two outputs is whitespace noise. The exception is files where indentation matters (Python, YAML, Makefiles); there it may be logic.

## 2. Relevance

Every hunk traces to the ticket. Unstage what doesn't (`git restore --staged -p`) and commit it separately. Never discard it.

## 3. Noise

Undo whitespace, blank-line, reordering and formatting changes the ticket doesn't need. Keep anything produced by the repo's formatter, linter or package manager, and any reorder that changes behavior.

## 4. Necessity

For each added line, ask what it serves: a test, an acceptance criterion, or a quality dimension such as security, accessibility or observability. If it serves none of them, delete it. The usual cuts:

- duplicated helpers;
- one-caller abstractions and options;
- guards for states the code itself rules out (keep validation of outside input);
- comments that narrate instead of explaining why.

## 5. Tests: a test that passed before the change wasn't important

Skip this step for tests you watched fail in TDD's red step. Also skip it when the change includes migrations, because the old schema would overwrite the shared test database.

Otherwise, run only the added test cases, never whole changed files, against the pre-change code:

```bash
pre=$(git merge-base BASE HEAD); wt=$(mktemp -d)
git worktree add -q --detach "$wt" "$pre" &&
  git -C "$wt" checkout "$(git rev-parse HEAD)" -- <added or modified test files> &&
  (cd "$wt/<package dir>" && <test command filtered to the added cases>)
git worktree remove --force "$wt"
```

- **A test counts as failing only on an assertion.** An import, load or missing-file error proves nothing. Fix the setup (for example, link `node_modules`) or judge that test by hand.
- **Coverage must still meet the project standard after every cut.** Never delete a test to make a failure pass.
- **Cut each added test that passes,** unless one of these holds:
  - it is the only coverage for new lines;
  - it encodes an acceptance criterion;
  - it is a characterization test;
  - the ticket is a refactor, upgrade or performance change.

  Note any you keep in the report.
- **Of the tests that fail, keep one per behavior.** Cut duplicates, tests of framework behavior, and tests that can't fail.

## Report

Rerun the tests and measure again. Report before and after (`+584/-37 → +NNN/-NN`), with one line for each cut and each passing test kept. Fix forward with new commits. Never amend or force-push ([Git Integrity](../../references/git-integrity.md)).
