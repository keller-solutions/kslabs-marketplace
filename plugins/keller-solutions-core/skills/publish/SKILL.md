---
name: publish
description: Release, deploy, and verify. Takes merged code through release preparation, GitHub release creation, deployment, and production verification. Typically run after PR is merged.
version: 1.0.0
argument-hint: "[version or 'auto']"
---

# Publish

Release, deploy, and verify the work in production.

## Core Principle

**A release is not complete until it's verified in production.**

This skill handles the journey from merged code to production deployment, ensuring every release is documented, deployed, and verified.

---

## Phase 1: Release Preparation

### Step 1.1: Ensure on Correct Branch

For releases, you should be on `develop` (for regular releases) or `main` (for hotfixes):

```bash
git checkout develop
git pull origin develop
```

### Step 1.2: Gather Changes Since Last Release

```bash
# Get last release tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")

# List commits since last release
git log "${LAST_TAG}..HEAD" --oneline
```

### Step 1.3: Determine Version Bump

Follow [Semantic Versioning](https://semver.org/):

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Breaking changes | MAJOR | 1.0.0 → 2.0.0 |
| New features | MINOR | 1.0.0 → 1.1.0 |
| Bug fixes | PATCH | 1.0.0 → 1.0.1 |

**Auto-detection from conventional commits:**

- `feat:` → MINOR bump
- `fix:` → PATCH bump
- `feat!:` or `BREAKING CHANGE:` → MAJOR bump

### Step 1.4: Generate Release Notes

Extract from conventional commits:

```bash
# Features
git log "${LAST_TAG}..HEAD" --oneline | grep -E "^[a-f0-9]+ feat"

# Fixes
git log "${LAST_TAG}..HEAD" --oneline | grep -E "^[a-f0-9]+ fix"

# Breaking changes
git log "${LAST_TAG}..HEAD" --oneline | grep -E "BREAKING|!"
```

Format as release notes:

```markdown
## What's Changed

### New Features
- feat(auth): add Google OAuth2 integration (#45)
- feat(dashboard): add project list (#48)

### Bug Fixes
- fix(scan): prevent duplicate violations (#52)
- fix(auth): handle OAuth callback errors (#54)

### Breaking Changes
- None

**Full Changelog**: https://github.com/owner/repo/compare/v1.0.0...v1.1.0
```

---

## Phase 2: Create Release

### Step 2.1: Create Release Branch (GitFlow)

For planned releases:

```bash
# Create release branch
git checkout -b release/v1.1.0 develop

# Update version numbers (project-specific)
# Rails: config/version.rb
# Node: package.json
# etc.

git commit -am "chore: bump version to 1.1.0"
```

### Step 2.2: Merge to Main

```bash
# Merge release to main
git checkout main
git merge --no-ff release/v1.1.0 -m "Release v1.1.0"

# Tag the release
git tag -a v1.1.0 -m "Release v1.1.0"

# Push main and tags
git push origin main --tags
```

### Step 2.3: Back-Merge to Develop

```bash
# Ensure develop has release changes
git checkout develop
git merge --no-ff main -m "Merge release v1.1.0 back to develop"
git push origin develop
```

### Step 2.4: Create GitHub Release

```bash
gh release create v1.1.0 \
  --title "v1.1.0" \
  --notes "$(cat <<'EOF'
## What's Changed

### New Features
- feat(auth): add Google OAuth2 integration (#45)
- feat(dashboard): add project list (#48)

### Bug Fixes
- fix(scan): prevent duplicate violations (#52)

**Full Changelog**: https://github.com/owner/repo/compare/v1.0.0...v1.1.0
EOF
)"
```

---

## Phase 3: Deployment

### Step 3.1: Identify Deployment Method

Common patterns:

| Platform | Deployment Method |
|----------|-------------------|
| Heroku | `git push heroku main` or auto-deploy |
| Render | Auto-deploy on push to main |
| Vercel | Auto-deploy on push |
| AWS | CI/CD pipeline |
| Manual | SSH + pull |

### Step 3.2: Trigger Deployment

**Heroku:**

```bash
git push heroku main
```

**Auto-deploy platforms:**
Deployment triggers automatically when main is pushed.

**CI/CD:**

```bash
# Watch deployment status
gh run list --workflow=deploy
gh run watch [RUN_ID]
```

### Step 3.3: Monitor Deployment

```bash
# Wait for deployment to complete
echo "Monitoring deployment..."

# Platform-specific monitoring
# Heroku: heroku logs --tail
# Render: check dashboard
# Vercel: check deployment status
```

---

## Phase 4: Verification

### Step 4.1: Smoke Test

Verify critical paths work in production:

```markdown
## Smoke Test Checklist

- [ ] Application loads at production URL
- [ ] User can sign in
- [ ] Key features work (project-specific)
- [ ] No console errors
- [ ] No 500 errors in logs
```

### Step 4.2: Verify Released Features

For each ticket in the release:

```bash
# List tickets in release
git log v1.0.0..v1.1.0 --oneline | grep -oE "#[0-9]+" | sort -u
```

Verify each feature works as expected in production.

### Step 4.3: Check Error Monitoring

If using error monitoring (Sentry, Honeybadger, etc.):

- Check for new errors since deployment
- Verify error rates are normal
- Set up alerts for new error types

### Step 4.4: Notify Stakeholders

```markdown
## Release Notification

**Version**: v1.1.0
**Deployed**: [timestamp]
**Environment**: Production

### Changes
- [List of user-facing changes]

### Verification
- All smoke tests passing
- No new errors detected

### Links
- [Release notes URL]
- [Production URL]
```

---

## Phase 5: Post-Release

### Step 5.1: Close Related Issues

Update tickets that were released:

```bash
# Add comment to each issue
gh issue comment [ISSUE_NUMBER] --body "Released in v1.1.0"
```

Note: The product owner typically closes issues after acceptance testing.

### Step 5.2: Clean Up Release Branch

```bash
git branch -d release/v1.1.0
git push origin --delete release/v1.1.0
```

### Step 5.3: Document Any Issues

If issues were found during deployment:

- Create tickets for follow-up
- Document in release notes
- Notify relevant stakeholders

---

## Output

### Release Report

```markdown
---

## Release Complete

**Version**: v1.1.0
**Tag**: https://github.com/owner/repo/releases/tag/v1.1.0
**Deployed**: [timestamp]

### Changes Included
- feat(auth): add Google OAuth2 integration (#45)
- feat(dashboard): add project list (#48)
- fix(scan): prevent duplicate violations (#52)

### Verification Status
- [x] Deployment successful
- [x] Smoke tests passing
- [x] No new errors
- [x] Stakeholders notified

### Production URL
https://example.com

---
```

---

## Standalone Usage

When invoked directly (`/ks-publish [version]`):

1. Gathers changes since last release
2. Determines version bump
3. Creates release branch and tags
4. Deploys to production
5. Verifies deployment
6. Reports completion

## Quick Release (Hotfix)

For urgent fixes:

```bash
# Create hotfix branch from main
git checkout -b hotfix/critical-fix main

# Make fix, test, commit
git commit -am "fix: critical security issue"

# Merge to main
git checkout main
git merge --no-ff hotfix/critical-fix

# Tag and release
git tag -a v1.0.1 -m "Hotfix: critical security issue"
git push origin main --tags

# Back-merge to develop
git checkout develop
git merge main
git push origin develop

# Create GitHub release
gh release create v1.0.1 --title "v1.0.1 (Hotfix)" --notes "Critical security fix"
```

---

## Release Checklist

Before releasing:

- [ ] All tests pass on main
- [ ] Release notes prepared
- [ ] Version number updated
- [ ] Stakeholders notified of upcoming release
- [ ] Deployment plan reviewed

After releasing:

- [ ] Deployment verified
- [ ] Smoke tests pass
- [ ] No new errors
- [ ] Related issues updated
- [ ] Release branch cleaned up

---

## More Information

- [The F5 Principle](../references/f5-manifesto.md) - "If it isn't scripted, it's magic—bad magic"
- [Guiding Principles](../references/guiding-principles.md) - The six principles
- [Git Integrity](../references/git-integrity.md) - "Thou Shalt Not Lie"
