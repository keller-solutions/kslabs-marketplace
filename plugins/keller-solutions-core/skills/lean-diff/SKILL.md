---
name: lean-diff
description: Strip a commit or PR down to only the code, tests and comments it needs. Checks relevance to the ticket, the additions-to-deletions ratio, whitespace and reorder noise, and whether each new test failed before the change. Use before every commit and PR, or when asked to "lean this out", "check the diff" or find unnecessary tests. Works standalone or inside produce and present.
version: 1.0.0
argument-hint: "[base branch or A...B range]"
---

# Lean Diff

A reviewer should find nothing in the diff they could delete.

## 1. Measure

```bash
git diff --stat BASE...HEAD                              # size and ratio (--cached before a commit)
git diff --stat -w --ignore-blank-lines BASE...HEAD      # any difference from the line above is whitespace noise
```

## 2. Relevance

Every hunk traces to the ticket. Revert what doesn't. If it's worth keeping, commit it separately or give it its own PR.

## 3. Noise

Revert whitespace, blank-line, reordering and formatting changes, plus lockfile or generated churn the ticket doesn't require. Keep a reorder only when it changes behavior.

## 4. Necessity

For each added line, ask what breaks if it's deleted. If nothing breaks, delete it. The usual cuts:

- duplicated helpers;
- one-caller abstractions and options;
- guards for impossible states;
- comments that narrate instead of explaining why.

## 5. Tests: a test that passed before the change wasn't important

Run the new tests against the pre-change code:

```bash
pre=$(git merge-base BASE HEAD); wt=$(mktemp -d)/pre
git worktree add -q --detach "$wt" "$pre"
git -C "$wt" checkout "$(git rev-parse HEAD)" -- <new or changed test files>
(cd "$wt" && <test command> <those files>)               # link node_modules etc. if needed
git worktree remove --force "$wt"
```

Cut each added test that passes there. The exception is a pure refactor ticket; ask first. Under TDD this is the red step: a test never seen failing gets the same check.

Of the tests that fail, keep one per behavior. Cut duplicates, tests of framework behavior, and tests that can't fail. Coverage must still meet the project standard afterward. Never delete a test to make a failure pass.

## 6. Simplify

Inside the ticket's code, take the simpler shape: `/simplify` in Claude Code. Then measure again.

## Report

Give before and after (`+584/-37 → +NNN/-NN`), with one line per cut. If it was already lean, say so.

Never amend or force-push to tidy up. Fix forward with a new commit ([Git Integrity](../../references/git-integrity.md)).
