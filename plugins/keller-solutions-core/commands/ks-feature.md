---
name: ks-feature
description: Full feature workflow from idea to PR-ready. Runs Prepare → Plan → Produce → Present.
argument-hint: "<feature description>"
---

# Feature Workflow

Run these skills in order. Do not skip steps.

## Pre-flight

1. `/ralph-loop:ralph-loop "complete all workflow steps" --completion-promise "DONE"`

## Phase 1: Prepare

2. `skill: prep` - Orient to project, switch to develop, update dependencies, verify tests pass

## Phase 2: Plan

3. `skill: plan $ARGUMENTS` - Write story and create GitHub issue with acceptance criteria

## Phase 3: Produce

4. Create feature branch from develop
5. `skill: produce` - Implement using TDD (red-green-refactor for each criterion)
6. `/compound-engineering:lint` - Run linters, fix any issues

## Phase 4: Present

7. `skill: present` - Self-review, create PR, handle feedback loop
8. `/compound-engineering:feature-video` - Record video walkthrough (optional, if UI changes)

## Completion

9. Output `<promise>DONE</promise>` when PR is ready for final review

**Start with step 1 now.**
