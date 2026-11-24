---
name: ks-lean-diff
description: Strip a commit or PR down to only the code, tests and comments it needs.
argument-hint: "['staged' | base branch | A...B range]"
---

# Lean Diff

Run the lean-diff skill standalone:

`skill: lean-diff $ARGUMENTS`

This will:

1. Measure the diff: +/- ratio, test and comment weight, whitespace and reorder noise
2. Run the new tests against the pre-change code and flag any that already passed
3. Check every hunk against the ticket
4. Cut unnecessary code, comments and tests
5. Report before and after
