---
name: lean-diff
description: Strip a commit or pull request down to only the code, tests and comments it needs. Measures the diff (additions-to-deletions ratio, whitespace and reorder noise, test and comment weight), runs the new tests against the pre-change code (a test that passed before the change wasn't important), then makes relevance, necessity and test-pruning passes. Use before every commit and before opening or updating a PR, or when asked to "lean this out", "check the diff", "strip it down", "what's the ratio", or review a change for unnecessary tests. Works standalone or inside produce (each commit) and present (the PR).
version: 1.0.0
argument-hint: "['staged' | base branch | A...B range]"
---

# Lean Diff

A reviewer should find nothing in a diff they could delete. Every commit and every PR is held to three checks:

1. **Relevance.** Every change belongs to this commit's ticket. Anything else is removed or goes in its own commit.
2. **Ratio.** Compare additions to deletions. No extraneous changes, especially whitespace changes or reordering.
3. **Economy.** Add only what is necessary, as simply as possible. Take every chance to simplify.

AI-assisted changes tend to run long: extra tests, defensive code, narrating comments. This skill is the counterweight.

## Core Principle

**If a test passed before the change, it wasn't important.** A test earns its place by failing without the change and passing with it.

## When

- **Before each commit (produce):** `lean-diff.py --staged`. History is never rewritten ([Git Integrity](../../references/git-integrity.md)), so the cleanup happens before the commit, not after. Under red/green/refactor some cleanup waits for the refactor step.
- **At the PR (present):** `lean-diff.py` for the branch total, then `lean-diff.py --commits` for each commit. This is the hardest pass, on the additions and the ratio. Run it before the PR opens and again after any feedback commits.

## Step 1: Measure

The script is `scripts/lean-diff.py` in this skill's directory:

```bash
python3 <skill-dir>/scripts/lean-diff.py --staged      # what is about to be committed
python3 <skill-dir>/scripts/lean-diff.py               # branch vs origin's default branch
python3 <skill-dir>/scripts/lean-diff.py A...B         # any range, e.g. a merged PR
python3 <skill-dir>/scripts/lean-diff.py --commits     # one report per commit, no test run
# --no-tests skips the before/after test run
```

It prints:

- **Size:** +/- for each file, the totals and the additions-to-deletions ratio, test lines against code lines, and the number of comments added in code.
- **Noise:** whitespace-only lines, lines removed and re-added unchanged, end-of-file newline changes, lockfile churn, and generated-file churn.
- **Before/after:** the test cases the diff added, run against the pre-change code. For `--staged` that code is HEAD; for a branch or range it is the merge base. It runs in a temporary worktree with the new test files on top, using node --test, jest, vitest, minitest, rspec or pytest. Each test is reported as `passed before: cut`, `failed before`, `errored before`, or `no result`.

It exits 1 when it finds noise or a test that passed before. It measures; the judgement is the steps below.

## Step 2: Relevance

Read the diff hunk by hunk against the ticket and its acceptance criteria. For a hunk that doesn't trace:

- Revert it if it isn't needed.
- If it's worth keeping, such as a real cleanup or a fix for something else, unstage it (`git restore --staged -p`) and commit it separately, or move it to its own PR.

## Step 3: Noise

Revert everything the script flagged: whitespace, blank lines, reordering, end-of-file newlines, incidental formatting. Keep one only when the repo's own formatter or linter produces it, or when the ticket is about it. A reorder that changes behavior is not noise; the code should say why. A lockfile changes only with a dependency change the ticket requires.

## Step 4: Necessity

For each added block, ask what breaks if it's deleted. If nothing does, delete it.

- **Code:** a helper that duplicates an existing one or the standard library; an abstraction, option or config key with one caller; guards for states that can't happen; dead branches; logging and error handling the surrounding code wouldn't have.
- **Comments:** keep only the "why" the code can't say. Cut comments that narrate the next line, restate a name, or record history ("changed to X"). Git holds the history.
- **Docs and CHANGELOG:** one entry, sized to the change.

Match the surrounding code. Don't add a check, a type, a comment or a layer the neighbouring code wouldn't have.

## Step 5: Tests

**Cut every test the script marked `passed before`.** It doesn't test this change. The one exception is a pure refactor ticket, where passing before and after is the point; ask before cutting there.

Look into each `errored before` or `no result` line before trusting the run. It may be the environment (a database or dependency missing in the worktree) or a test name the script couldn't match.

A test that failed before isn't automatically needed, because it may fail only because a method doesn't exist yet. Keep one test for each behavior, and cut:

- a test that asserts the same behavior again by another path or layer, with no new failure mode;
- tests of framework, library or language behavior;
- tautological tests: asserting an assignment, mirroring the implementation, or one that can't fail (for example an `assert.fail` inside code whose `catch` swallows it);
- tests of private details that would break on a harmless refactor;
- loops and permutations where one representative case and the edge that matters would do;
- setup, fixtures and helpers left unused after the cuts.

Then run the suite with coverage. If a cut drops coverage below the project's standard ([Test Coverage Philosophy](../../references/test-coverage-philosophy.md)), the test wasn't redundant. Restore it, unless the uncovered code is itself unnecessary; then delete the code. Never delete a test to make a failure pass.

## Step 6: Simplify and re-measure

Inside the code this ticket touches, take the simpler shape when one exists: inline a one-hop wrapper, reuse what's there, flatten a branch. Cleanup outside the ticket's code goes in its own commit. Run the script again.

## Report

Lead with before and after: `+584/-37 → +NNN/-NN`, with test and code lines for each. Then one line per cut with its reason, and anything large that stays, with why. If the diff was already lean, say so. Don't manufacture findings; no cut beats a speculative one.

## Guardrails

- Behavior doesn't change. This is subtraction and simplification, not a redesign. Public contracts, migrations and architecture questions go to the developer.
- Check every use, including indirect ones, before removing anything as unused.
- Never amend, squash or force-push to tidy up. Fix forward with a new commit.
- There is no line budget. A large ratio is a reason to look closer, not a verdict. As a starting point, more than about two test lines per code line, or an all-additions diff, earns a second read of steps 4 and 5.

## Standalone Usage

```text
/ks-lean-diff staged        # before a commit
/ks-lean-diff               # the current branch
/ks-lean-diff main...HEAD   # an explicit range
```

## Workflow Usage

- **produce:** Step 3.4 runs it on the staged changes before each commit; Step 4.4 runs it on the branch.
- **present:** Step 1.2 runs the full pass and reports the before/after line in the ready notification.
