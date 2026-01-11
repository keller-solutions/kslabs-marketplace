---
name: ks-prep
description: Prepare the development environment. Orient to project, update dependencies, verify tests.
argument-hint: "[optional: path to project]"
---

# Prepare Environment

Run the prep skill standalone:

`skill: prep $ARGUMENTS`

This will:

1. Detect project type and read core documentation
2. Switch to develop branch and pull latest
3. Clean up stale local branches
4. Update dependencies
5. Run test suite to verify environment
6. Report readiness status
