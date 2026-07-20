# Keller Solutions Marketplace

This is a Claude Code plugin marketplace for distributing custom skills.

## Repository Structure

- `.claude-plugin/marketplace.json` - Marketplace catalog
- `plugins/` - Plugin directories
- `plugins/*/skills/` - Skill definitions (SKILL.md files)

## Development Commands

```bash
# Validate all JSON files
for file in $(find . -name "*.json" -type f); do python3 -m json.tool "$file" > /dev/null; done

# Add a new skill
cp -r plugins/keller-solutions-core/skills/skill-template plugins/keller-solutions-core/skills/new-skill
```

## Conventions

- Use GitFlow branching (main, develop, feature/*)
- Conventional commits (feat:, fix:, docs:)
- Semantic versioning for plugins and skills
- Keep SKILL.md files under 500 lines

## Pull Request Feedback Loop (every agent, every PR — no exceptions)

Copilot auto-reviews every PR here, and its review lands minutes AFTER
`gh pr create` returns. Opening a PR is not the end of the work:

1. After opening a PR — or pushing new commits to one — run the Copilot review
   loop per `plugins/keller-solutions-core/references/copilot-review.md`: poll
   for a review on the current head SHA (bounded wait); silence is not approval.
2. Address every comment and reply in-thread to each. Never mark threads
   resolved — adequacy is the reviewer's call.
3. Re-request review only after substantive changes (reviews are usage-billed).
4. Do not report a PR "ready to merge" until the loop has run dry. The hand-back
   includes: "Copilot review: N comments — M addressed (commit SHAs), K declined
   with rationale."

This binds every agent and tool that opens or updates a PR in this repo,
whether or not the ks-present workflow is in use.

## Ticket Workflow

- Tool: GitHub Issues (this repo)
- States via labels, in order: `status:up-next` → `status:in-progress` (before first line of code) → `status:in-review` (commit + evidence landed)
- Epics: `epic` label on the parent; children listed as a task list in the epic body and each child body carries `Refs #<epic>`
- Done: human closes on merge (never Claude); comment each child with its delivering commit SHA when moving to in-review

## Available Marketplace Operations

Agents can:
- Search plugins: Read `.claude-plugin/marketplace.json`
- Install plugin: Copy to `~/.claude/plugins/`
- Create skill: Copy from `skill-template`, validate, commit
- Validate skill: Check SKILL.md frontmatter and structure

## Skill Authoring

1. Use gerund naming: `processing-pdfs`, `analyzing-code`
2. Description formula: `[What it does]. Use when [trigger conditions].`
3. Include Quick Start section
4. Provide concrete examples with input/output
5. Keep under 500 lines
