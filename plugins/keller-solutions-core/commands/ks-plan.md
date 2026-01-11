---
name: ks-plan
description: Write a well-structured story and create a GitHub issue with acceptance criteria.
argument-hint: "<feature description>"
---

# Plan Feature

Run the plan skill standalone:

`skill: plan $ARGUMENTS`

This will:

1. Parse the feature description
2. Ask clarifying questions if needed
3. Write story in "In order to / As a / I want" format
4. Create acceptance criteria (verifiable by non-developer in browser)
5. Create GitHub issue
6. Report the created ticket
