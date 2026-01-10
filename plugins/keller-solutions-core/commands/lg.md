---
name: lg
description: Full autonomous engineering workflow with GitFlow, TDD, story writing, and PR review feedback loop
argument-hint: "[feature description]"
---

Run these steps in order. Do not skip steps.

1. `/ralph-wiggum:ralph-loop "finish all steps" --completion-promise "DONE"`
2. `skill: session-start` - Switch to develop, pull latest, cleanup stale branches, update deps
3. `skill: story-create $ARGUMENTS` - Create GitHub issue using story format
4. `skill: feature-branch` - Create GitFlow feature branch from develop
5. `/workflows:plan $ARGUMENTS` - Create implementation plan
6. `/compound-engineering:deepen-plan` - Add depth and best practices to plan
7. `/workflows:work` - Implement feature using TDD principles
8. `/workflows:review` - Multi-agent code review
9. `/compound-engineering:resolve_todo_parallel` - Address review findings
10. `/compound-engineering:lint` - Run linters before push
11. `/compound-engineering:playwright-test` - Run browser tests (if applicable)
12. `/compound-engineering:feature-video` - Record video walkthrough and add to PR
13. `skill: pr-feedback-loop` - Wait for Copilot review, respond to all comments
14. `skill: pr-ready` - Notify user PR is ready for final review
15. Output `<promise>DONE</promise>` when PR is ready

Start with step 1 now.
