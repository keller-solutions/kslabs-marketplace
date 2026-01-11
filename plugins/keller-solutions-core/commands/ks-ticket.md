---
name: ks-ticket
description: Work on an existing ticket. Runs Prepare → Produce → Present (skips Plan).
argument-hint: "<ticket number>"
---

# Ticket Workflow

Run these skills in order. Argument is the ticket number.

## Pre-flight

1. `/ralph-loop:ralph-loop "complete all workflow steps" --completion-promise "DONE"`

## Phase 1: Prepare

2. `skill: prep` - Orient to project, switch to develop, update dependencies, verify tests pass

## Phase 2: Produce

3. Retrieve ticket #$ARGUMENTS from GitHub
4. Create feature branch from develop (use ticket title for branch name)
5. `skill: produce $ARGUMENTS` - Implement using TDD (red-green-refactor for each acceptance criterion)
6. `/compound-engineering:lint` - Run linters, fix any issues

## Phase 3: Present

7. `skill: present` - Self-review, create PR, handle feedback loop
8. `/compound-engineering:feature-video` - Record video walkthrough (optional, if UI changes)

## Completion

9. Output `<promise>DONE</promise>` when PR is ready for final review

**Start with step 1 now.**
