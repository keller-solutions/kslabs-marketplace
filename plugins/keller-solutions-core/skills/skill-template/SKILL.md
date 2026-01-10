---
name: skill-template
description: This skill demonstrates proper SKILL.md structure. Use as a reference when creating new skills for the Keller Solutions Marketplace.
version: 0.1.0
license: MIT
---

# Skill Template

This template demonstrates the proper structure for SKILL.md files.

## Quick Start

Copy this directory to create a new skill:
```bash
cp -r skills/skill-template skills/your-skill-name
```

Then edit `SKILL.md` with your skill's name, description, and instructions.

## Instructions

When creating a skill, follow these steps:

1. **Name your skill** - Use gerund form (verb-ing): `processing-pdfs`, `analyzing-code`
2. **Write the description** - Include what it does AND when to use it
3. **Add trigger keywords** - Help Claude discover your skill
4. **Keep it under 500 lines** - Use progressive disclosure for details

## Examples

**Example 1: Good Description**
Input: User wants to understand what makes a good skill description
Output:
```yaml
description: This skill extracts text from PDF files. Use when working with PDFs, extracting content, or processing documents.
```

**Example 2: Bad Description (avoid)**
Input: User sees a vague description
Output:
```yaml
description: Helps with documents
```

## Directory Structure

```
your-skill-name/
├── SKILL.md              # Required: Entry point (<500 lines)
├── references/           # Optional: Detailed docs (loaded when needed)
│   └── advanced.md
├── examples/             # Optional: Usage examples
│   └── basic-usage.md
└── scripts/              # Optional: Executable utilities
    └── validate.sh
```

## Frontmatter Fields

| Field | Required | Max Length | Description |
|-------|----------|------------|-------------|
| `name` | Yes | 64 chars | Lowercase, hyphens only, gerund form |
| `description` | Yes | 1024 chars | What + when + trigger keywords |
| `version` | No | - | Semantic version (e.g., 1.0.0) |
| `allowed-tools` | No | - | Comma-separated tool restrictions |
| `model` | No | - | Override session model |
| `license` | No | - | Attribution information |

## Guidelines

- Use third person in descriptions ("This skill..." not "Use this...")
- Include trigger keywords for discovery
- Keep references one level deep from SKILL.md
- Use standard markdown headings (not XML tags)
- Provide concrete input/output examples
