# Git Integrity: Thou Shalt Not Lie

## The Core Principle

**Rewriting history is lying. Don't do it.**

Git's power comes from its ability to accurately track the evolution of code. When you rewrite history, you destroy that accuracy. You break the tools that make git valuable. You make life harder for your teammates and your future self.

---

## Inspiration

This philosophy is adapted from Paul Stadig's article **"Thou Shalt Not Lie: git rebase, amend, squash, and other lies"** (December 7, 2010).

> **Note**: The original article at `https://paul.stadig.name/2010/12/thou-shalt-not-lie-git-rebase-ammend.html` is no longer available at that URL, but can be accessed via the [Internet Archive's Wayback Machine](https://web.archive.org/web/20111028012930/http://paul.stadig.name/2010/12/thou-shalt-not-lie-git-rebase-ammend.html).

---

## The Cardinal Rule

**Never put yourself in a position where you have to force push.**

Force pushing (`git push --force`) is the clearest symptom of history rewriting. The goal isn't to know when force push is "safe"—it's to work in a way that you never need it.

### How to Avoid Force Push Situations

1. **Push immediately after committing**: Once a commit is pushed, you won't be tempted to amend it
2. **Create branches early**: Feature branches isolate your work from others
3. **Merge, don't rebase**: Merging preserves history; rebasing rewrites it
4. **Fix forward, not backward**: Made a mistake? Make a new commit to fix it
5. **Embrace the messiness**: Real development is iterative—your history should reflect that

If you find yourself reaching for `--force`, stop. Ask yourself: "What lie am I about to tell?"

---

## The Lie Detector Test

You're probably lying if any of these break:

| Git Feature | What It Does | How Lies Break It |
|-------------|--------------|-------------------|
| `git branch --contains` | Shows which branches contain a commit | Can't find commits that were rewritten |
| `git blame` | Shows who wrote each line and when | Points to fake commits, wrong authors |
| `git bisect` | Binary search to find where bugs were introduced | Fails if rewritten commits don't compile |
| `git rerere` | Remembers how you resolved conflicts | Can't recognize rewritten commits |

**The ultimate tell**: If you need `git push --force`, you're lying.

---

## The Four Lies

### 1. Squash Merging is a Lie

```bash
# DON'T DO THIS
git merge --squash feature-branch
```

**What it does**: Takes all commits from a branch, combines them into one, applies that single commit.

**The lie**: "I had a flash of brilliance and did everything right the first time."

**What breaks**:

- `git branch --contains feature-branch` can't tell you where your work was merged
- `git blame` points to a fake commit, not the person who actually wrote the code
- `git rerere` can't help you re-resolve conflicts because the SHAs are different
- When QA asks "Is feature X deployed?", you have to go spelunking through logs

**The truth**: Development is iterative. You made mistakes. You fixed them. That history is valuable.

### 2. Rebasing is a Lie

```bash
# DON'T DO THIS
git rebase main
```

**What it does**: Replays your commits on top of another branch, creating entirely new commits.

**The lie**: "I was working from main the whole time."

**What breaks**:

- Every rebased commit gets a new SHA—the original commits no longer exist
- **Timestamps are replaced**: The new commits get new timestamps, falsifying when the work actually happened. A feature developed over two weeks now appears to have been written in an afternoon
- Commit messages may no longer make sense in their new context
- Code may not compile at each commit (breaks `git bisect`)
- Tests may not pass at each commit
- Cherry-picking a rebased commit might break the target branch
- The apparent timeline of development is fabricated—making it impossible to understand the true sequence of events

**The truth**: Each commit was born in a specific context at a specific time. Yanking it out and pretending it happened differently is lying about when and how the work was done.

### 3. Amending is a Lie

```bash
# DON'T DO THIS (after pushing)
git commit --amend
git push --force origin feature-branch
```

**What it does**: Modifies the most recent commit—changes content, message, or both.

**The lie**: "That typo never happened."

**What breaks**:

- `git branch --contains` can't find the original commit
- Forces you to `push --force`, which overwrites shared history
- Teammates who pulled the original commit now have conflicts

**The truth**: You made a typo. You fixed it. Two commits. That's what happened.

### 4. Selective Retroactive Commits *Can* Be a Lie

```bash
# PROBLEMATIC EXAMPLE
git add foo.rb
git commit -m "Refactor foo"
git add bar.rb
git commit -m "Refactor bar"
# When foo.rb depends on bar.rb and won't compile alone
```

**When it's a lie**: Creating commits that don't compile or pass tests individually. If `foo.rb` depends on changes in `bar.rb`, separating them creates broken intermediate states that break `git bisect` and cherry-picking.

**When it's acceptable**: Separating unrelated changes into their own commits using `git add -p` is **encouraged**. If you fixed a typo while working on a feature, pulling that typo fix into its own commit is good practice—it keeps commits focused and makes the history clearer.

```bash
# GOOD: Separating unrelated changes
git add -p  # Stage only the typo fix
git commit -m "fix: correct typo in README"
git add .   # Stage the feature work
git commit -m "feat: add user dashboard"
```

**The rule**: Each commit must compile and pass tests independently. If you can split changes cleanly without breaking this rule, do so.

---

## Why History Matters to Future You

### For Debugging

When something breaks in production six months from now, you'll need to find out:

- When was it introduced?
- Who introduced it?
- What was the context?

`git bisect` can answer these questions in minutes—but only if every commit compiles and passes tests. Rewritten history breaks this. Future you will curse present you for destroying the breadcrumbs.

### For Understanding

Six months from now, you'll look at code and wonder "why is it like this?" `git blame` tells you who to ask and links to the commit message explaining the reasoning—but only if the history is accurate. Future you depends on present you to preserve this context.

### For Accountability

Accurate attribution matters for:

- Code reviews
- Knowledge transfer
- Understanding who has context on specific changes

When future you (or future teammate) needs to understand why code exists, the history should point to the real author with the real context.

### For Conflict Resolution

When resolving merge conflicts, you need to understand:

- What was the intent of each change?
- Does the merged code compile?
- Do the tests pass?

If commits don't compile or pass tests individually, you can't intelligently resolve conflicts. Future you inherits this mess.

---

## The Keller Solutions Way

### Do This Instead

**Instead of squash merging**: Use regular merges. The commit history is valuable.

```bash
# DO THIS
git checkout main
git merge --no-ff feature-branch
```

**Instead of rebasing**: Merge the target branch into your feature branch.

```bash
# DO THIS
git checkout feature-branch
git merge main
```

**Instead of amending pushed commits**: Make a new commit.

```bash
# DO THIS
git commit -m "fix: correct typo in previous commit"
```

**Instead of selective retroactive commits**: Commit as you go, or commit everything together.

```bash
# DO THIS - commit related changes together
git add foo.rb bar.rb
git commit -m "refactor: extract shared logic from foo and bar"
```

### The Commit Discipline

1. **Commit early, commit often**: Small, frequent commits are easier to understand
2. **Push immediately**: Once pushed, you won't be tempted to rewrite
3. **Each commit should compile and pass tests**: If it doesn't, you're setting traps for future you
4. **Commit what you did, when you did it**: Don't rewrite history to look smarter
5. **Write meaningful commit messages**: Future you will thank present you

---

## When Lying Might Be Acceptable

We're not absolutists. There are narrow cases where rewriting is acceptable:

### Before Pushing

If you haven't pushed yet, the history is still local. You can:

- Amend the last commit to fix a typo
- Interactive rebase to clean up a messy local history
- Squash fixup commits

**But**: Even locally, ensure every commit compiles and passes tests. And push soon—don't let unpushed commits accumulate.

### Integration Branches

Integration branches (QA, staging, etc.) have different expectations:

- They're temporary holding areas
- No one bases work on them
- History may need manipulation for cherry-picking features

**But**: Production branches (main, master, develop) should never have rewritten history.

### The Rule of Thumb

> **Don't rewrite history for anything that's been pushed to a shared branch.**

If others might have pulled it, don't change it.

---

## Enforcement

### Git Configuration

Prevent accidental force pushes:

```bash
# Disable force push to protected branches
git config --global push.default simple
```

### Branch Protection (GitHub)

- Enable "Require linear history" = OFF (we want merge commits)
- Enable "Do not allow bypassing the above settings"
- Disable "Allow force pushes"
- Disable "Allow deletions" for main/develop

### Code Review Checklist

- [ ] No `--force` pushes in the PR
- [ ] Each commit compiles independently
- [ ] Each commit passes tests independently
- [ ] Commit messages accurately describe what happened

---

## Summary

| Action | Verdict | Why |
|--------|---------|-----|
| `git merge --squash` | Avoid | Destroys commit history, breaks blame/bisect |
| `git rebase` (after push) | Never | Rewrites shared history, falsifies timestamps, breaks everything |
| `git rebase` (local only) | Sparingly | OK if commits still compile/test |
| `git commit --amend` (after push) | Never | Forces push --force |
| `git commit --amend` (local only) | OK | Just don't push then amend |
| `git push --force` | Never (on shared branches) | Overwrites others' work |
| Selective retroactive commits | OK if clean | Each commit must compile and pass tests |

---

## The Bottom Line

**Your git history is a gift to future you.**

Every commit is a breadcrumb. Every merge is a signpost. Every message is a note from past you explaining what you were thinking. Every timestamp is a marker of when you actually did the work.

When you rewrite history, you're stealing from future you. You're erasing the context that will help you debug, understand, and maintain this code months or years from now.

Don't lie. Push early. Embrace the mess. Future you will thank present you.

---

## Further Reading

- [Thou Shalt Not Lie: git rebase, amend, squash, and other lies](https://web.archive.org/web/20111028012930/http://paul.stadig.name/2010/12/thou-shalt-not-lie-git-rebase-ammend.html) - Paul Stadig (via Wayback Machine)
- [A successful Git branching model (GitFlow)](https://nvie.com/posts/a-successful-git-branching-model/) - Vincent Driessen
- [Test Coverage Only Matters if at 100 Percent](https://www.dein.fr/posts/2019-09-06-test-coverage-only-matters-if-at-100-percent) - Xavier Noria
