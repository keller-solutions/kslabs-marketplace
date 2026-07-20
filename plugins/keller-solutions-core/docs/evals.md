# Evals: Regression-Testing the Pipeline

Skill edits break processes the way code edits break features — and deserve the same tests. Three layers:

## 1. Deterministic tests (run in CI, every PR)

- `hooks/scripts/test-guardrails.sh` — 14 cases against the guardrail hook (deny merge/force-push including plus-refspec and compound commands, ask on branch-delete, pass-through on benign commands, quoted mentions, and tag deletions).
- `claude plugin validate --strict` — manifest and structure linting.
- JSON validation across the repo.

These run in `.github/workflows/validate-plugin.yml` and gate PRs.

## 2. Behavioral evals (run on demand against skill changes)

Each skill carries `evals/evals.json`: golden prompts with expected behaviors, covering the gates this plugin exists to enforce — Copilot loop autonomy, green-before-done, runtime-proof fixes, read-only investigations, lifecycle timing, CI-parity gates, natural release triggers.

Run them with the official **skill-creator** eval runner (`/plugin install skill-creator@claude-plugins-official`), which executes each case in an isolated subagent and grades assertions; validate case files against the runner's current schema on first use and adjust shape if it has evolved. For a quick manual pass without the runner: open a fresh session, paste the case's prompt in the relevant project state, and grade the expected behaviors by hand.

## 3. The retro rule: every lesson becomes an eval

When a session produces a correction ("you didn't request the review", "that's not how we do it"), the fix lands twice: in the skill text **and** as an eval case, so the regression can't return silently. Add the case in the same PR as the skill change — the eval is the lesson's test.

## Baseline comparison

When judging whether a skill change helps, compare against a no-skill baseline in a fresh session (the skill-creator benchmark flow supports with/without runs and blind A/B between skill versions).
