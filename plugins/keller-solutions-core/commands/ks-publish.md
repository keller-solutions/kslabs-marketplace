---
name: ks-publish
description: Release, deploy, and verify. Takes merged code through release and production verification.
argument-hint: "[version or 'auto']"
---

# Publish Release

Run the publish skill standalone:

`skill: publish $ARGUMENTS`

This will:

1. Gather changes since last release
2. Determine version bump (auto-detects from conventional commits)
3. Create release branch and tag
4. Create GitHub release with notes
5. Trigger deployment
6. Verify in production (smoke tests)
7. Notify stakeholders
8. Clean up release branch
