---
status: pending
priority: p3
issue_id: "002"
tags: [code-review, security, ci]
dependencies: []
---

# Pin GitHub Actions to SHA

## Problem Statement

GitHub Actions in validate.yml use version tags (`@v5`) instead of commit SHAs, which could be vulnerable to tag hijacking attacks.

## Findings

**Location:** `.github/workflows/validate.yml:24, 40, 79`

**Current:**
```yaml
uses: actions/checkout@v5
```

**Recommended:**
```yaml
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

## Proposed Solutions

### Option A: Pin to SHA with version comment (Recommended)
- **Pros:** Maximum security, clear version documentation
- **Cons:** Harder to update
- **Effort:** Small
- **Risk:** Low

## Acceptance Criteria

- [ ] All actions pinned to SHA
- [ ] Version comment included for each

## Work Log

| Date | Action | Learnings |
|------|--------|-----------|
| 2026-01-09 | Created from /workflows:review | Identified by security-sentinel agent |
