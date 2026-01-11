# AI Visibility Preferences

## The Core Question

**Should AI assistance be visible in this project's history?**

Some teams want transparency: "Co-Authored-By: Claude" in commits, "with the help of Claude Code" in PR responses. Other teams prefer AI assistance to remain behind the scenes—the work speaks for itself.

Neither approach is wrong. What matters is respecting the project's established preference.

---

## Detection Methods

Before committing or responding to PRs, determine the project's AI visibility preference.

### 1. Check CLAUDE.md for Explicit Instructions

Look for AI attribution guidance in the project's CLAUDE.md file:

```bash
# Search for visibility preferences
grep -i "co-authored\|attribution\|claude\|ai\|visibility" CLAUDE.md
```

Explicit statements might include:

- "Include Co-Authored-By for all AI-assisted commits"
- "Do not reference AI assistance in commits or PRs"
- "AI attribution is optional"

### 2. Check if CLAUDE.md is in .gitignore

```bash
grep -i "claude.md\|CLAUDE.md" .gitignore
```

**If CLAUDE.md is gitignored**: The team likely prefers AI assistance to be invisible. They're using Claude but not making it part of the public repository.

**If CLAUDE.md is tracked**: The team is comfortable with AI visibility being part of the repository.

### 3. Review Commit History

```bash
# Look for AI co-author patterns
git log --oneline -20 | xargs -I {} git show {} --format="%b" | grep -i "co-authored\|claude\|ai\|gpt"

# Or check recent commits directly
git log -10 --format="%B" | grep -i "co-authored"
```

If previous commits include AI co-authorship, continue that pattern.

### 4. Review PR Descriptions and Comments

```bash
# Check recent PRs for AI mentions
gh pr list --limit 10 --json title,body | jq '.[].body' | grep -i "claude\|ai\|generated"
```

If PR descriptions mention AI assistance ("with Claude Code help", "AI-assisted"), maintain that visibility.

### 5. When In Doubt, Ask

If you can't determine the preference, ask directly and record the answer:

```markdown
## Quick Question

I noticed this project doesn't have explicit guidance on AI attribution in commits and PRs.

**Options:**
1. **Visible**: Include "Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>" in commits and mention AI assistance in PR feedback responses
2. **Invisible**: No AI attribution—commits and PRs appear as standard human work
3. **Mixed**: AI attribution in commits but not in PR comments (or vice versa)

Which approach fits this project's culture?
```

---

## Visibility Modes

### Up-Front (Visible)

AI assistance is transparent and documented.

**In commits:**

```text
feat(auth): add OAuth2 integration

Implements Google OAuth2 flow with PKCE for enhanced security.
Uses OmniAuth gem for provider abstraction.

Refs #123

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**In PR feedback responses:**

```text
Addressed with the help of Claude Code in a1b2c3d.
Added error handling for the nil case as suggested.
```

**In PR descriptions:**

```markdown
## Summary

Added user authentication using Google OAuth2.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Behind-the-Scenes (Invisible)

AI assistance is used but not documented.

**In commits:**

```text
feat(auth): add OAuth2 integration

Implements Google OAuth2 flow with PKCE for enhanced security.
Uses OmniAuth gem for provider abstraction.

Refs #123
```

**In PR feedback responses:**

```text
Addressed in a1b2c3d. Added error handling for the nil case.
```

**In PR descriptions:**

```markdown
## Summary

Added user authentication using Google OAuth2.
```

---

## Recording the Preference

Once determined, record the preference in the project's CLAUDE.md:

```markdown
## AI Visibility

This project uses **[visible/invisible]** AI attribution:
- Commits: [Include/Exclude] Co-Authored-By
- PR responses: [Include/Exclude] "with Claude Code" references
- PR descriptions: [Include/Exclude] AI generation badge
```

This prevents re-discovery on each session.

---

## Why This Matters

### For Visible Teams

- **Transparency**: Stakeholders know how work is being done
- **Attribution**: Fair credit for AI-assisted work
- **Compliance**: Some industries require disclosure of AI use
- **Learning**: Helps team members learn from AI-assisted patterns

### For Invisible Teams

- **Simplicity**: Clean commit history without metadata
- **Client preference**: Some clients prefer not to know
- **Cultural fit**: Team prefers focus on outcomes, not methods
- **Privacy**: AI usage is a tool choice, not a public statement

---

## Consistency Is Key

Whatever the project's preference, apply it consistently:

- Don't mix visible and invisible patterns in the same project
- Don't change preferences mid-feature
- When joining a project, detect and follow existing patterns

---

## Quick Reference

| Signal | Likely Preference |
|--------|-------------------|
| CLAUDE.md in .gitignore | Invisible |
| CLAUDE.md tracked in repo | Visible |
| Co-Authored-By in commit history | Visible |
| No AI references in git history | Invisible |
| AI badges in PR descriptions | Visible |
| Clean PR descriptions | Invisible |
| Explicit guidance in CLAUDE.md | Follow the guidance |

---

## The Bottom Line

Respect the project's culture. Detect, don't assume. When uncertain, ask. Once determined, stay consistent.

AI assistance is a tool. How that tool's use is communicated should match the team's values and practices.
