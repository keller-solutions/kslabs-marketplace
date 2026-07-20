# The Copilot Review Loop

Requesting the review is part of presenting — the developer never prompts for it. The loop: size-check → request → await → address every comment → reply in-thread → report. Merging, and judging whether a response was adequate, stay human.

## Size Guard (before requesting)

Copilot hard-fails past **300 changed files** and times out on very large diffs (a ~20k-line PR has failed in practice). Check first; over the line, propose a split (a stack boundary, a wave boundary) instead of a doomed request:

```bash
gh pr view $PR_NUMBER --json changedFiles,additions,deletions \
  -q '"files: \(.changedFiles)  +\(.additions) -\(.deletions)"'
```

## Requesting

```bash
# Primary (gh ≥ 2.88)
gh pr edit $PR_NUMBER --add-reviewer @copilot

# Known transient (cli#11245): errors while a prior Copilot review is pending — retry once.
# Fallback (documented REST path):
gh api -X POST repos/{owner}/{repo}/pulls/$PR_NUMBER/requested_reviewers \
  -f "reviewers[]=copilot-pull-request-reviewer[bot]"
```

Skip the request when the current head SHA already has a Copilot review (dedupe). On KS-owned repos, a branch ruleset ("Automatically request Copilot code review") can make the request automatic — the skill's request step then simply verifies it happened.

## Awaiting Completion

While queued, the bot sits in `requested_reviewers` — but **leaving the queue does not mean done**: on repos where Copilot review runs as an Actions workflow, the bot drops out of `requested_reviewers` while a "Copilot Code Review" run is still queued/executing. Check three signals before declaring a no-show: the reviews list (head SHA), `requested_reviewers`, and `gh run list` for a Copilot Code Review workflow in queued/in_progress. Poll on a sensible interval with a bounded timeout; a true no-show (no review, empty queue, no running workflow) gets reported — never proceed silently:

```bash
HEAD_SHA=$(git rev-parse HEAD)
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/reviews --paginate \
  --jq ".[] | select(.user.login == \"copilot-pull-request-reviewer[bot]\" and .commit_id == \"$HEAD_SHA\") | .state"
```

## Re-Request Economics

Copilot reviews are usage-billed (AI Credits). After feedback commits, re-request **only for substantive changes** — new logic, a changed approach — not for every fix push. Typo-level follow-ups ride to the human review without a fresh robot pass.

## Thread Resolution Belongs to the Reviewer

Reply to every comment (house format, per [AI Visibility](ai-visibility.md)); **never mark threads resolved**. The commenter judges adequacy: a human reviewer resolves or responds; Copilot can't resolve, so the developer resolves while reviewing or merges past open threads. If the repo's rules *require* resolved threads before merge, state that in the hand-back so the developer resolves as they review. (Replies go to top-level comment IDs — the REST replies endpoint doesn't nest deeper.)

## Reporting

The hand-back always includes: `Copilot review: N comments — M addressed (with commit SHAs), K declined with rationale`, plus the required-resolution note when it applies.
