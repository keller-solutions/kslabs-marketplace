---
name: ks-present
description: Self-review, create PR, and handle the complete feedback loop.
argument-hint: "[PR number or 'current']"
---

# Present Work

Run the present skill standalone:

`skill: present $ARGUMENTS`

This will:

1. Perform self-review of all changes
2. Run quality checks (tests, linters)
3. Create PR with summary and test plan
4. Wait for Copilot review
5. For each comment:
   - If agree: make change, commit, reply with commit SHA
   - If disagree: reply with clear rationale
6. Notify when PR is ready for final review
