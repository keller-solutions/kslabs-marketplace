---
name: ks-produce
description: Implement a ticket using Test-Driven Development. Red-green-refactor for each criterion.
argument-hint: "<ticket number or 'current'>"
---

# Produce Feature

Run the produce skill standalone:

`skill: produce $ARGUMENTS`

This will:

1. Verify environment is prepared as described in the /ks-prep command
2. Retrieve the ticket and parse acceptance criteria
3. For each criterion:
   - Write a failing test (Red)
   - Write minimal code to pass (Green)
   - Refactor while keeping tests green
   - Commit and push
4. Run all quality gates (tests, linters, coverage)
5. Report implementation status
