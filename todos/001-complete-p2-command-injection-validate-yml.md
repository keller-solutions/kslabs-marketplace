---
status: complete
priority: p2
issue_id: "001"
tags: [code-review, security, ci]
dependencies: []
---

# Command Injection Risk in validate.yml

## Problem Statement

The `validate.yml` GitHub Actions workflow uses unquoted shell expansion in find loops, which could lead to command injection if filenames contain special characters.

## Findings

**Location:** `.github/workflows/validate.yml:30-33, 46`

**Current code:**
```bash
for file in $(find . -name "*.json" -type f); do
    echo "Validating $file"
    python3 -m json.tool "$file" > /dev/null || exit 1
done
```

**Risk:** If a file is named `$(malicious_command).json`, it could execute arbitrary commands.

## Proposed Solutions

### Option A: Use null-delimited find with while loop (Recommended)
```bash
find . -name "*.json" -type f -print0 | while IFS= read -r -d '' file; do
    echo "Validating $file"
    python3 -m json.tool "$file" > /dev/null || exit 1
done
```
- **Pros:** Safe against all special characters, industry best practice
- **Cons:** Slightly more verbose
- **Effort:** Small
- **Risk:** Low

### Option B: Use glob pattern instead of find
```bash
shopt -s globstar nullglob
for file in **/*.json; do
    echo "Validating $file"
    python3 -m json.tool "$file" > /dev/null || exit 1
done
```
- **Pros:** Simpler syntax
- **Cons:** Requires bash 4+, may miss hidden directories
- **Effort:** Small
- **Risk:** Low

## Recommended Action

Option A - Use null-delimited find with while loop

## Technical Details

**Affected files:**
- `.github/workflows/validate.yml`

## Acceptance Criteria

- [ ] All find loops use null-delimited output
- [ ] All while loops properly handle special characters
- [ ] CI still passes with valid files
- [ ] Test with filename containing spaces

## Work Log

| Date | Action | Learnings |
|------|--------|-----------|
| 2026-01-09 | Created from /workflows:review | Identified by security-sentinel agent |

## Resources

- [ShellCheck SC2044](https://www.shellcheck.net/wiki/SC2044)
- PR being reviewed: Initial setup
