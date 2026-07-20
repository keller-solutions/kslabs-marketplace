---
name: feature
description: Full feature workflow from idea to PR-ready. Runs Prepare → Plan → Produce → Present in order. Use when asked to take a feature from description to pull request (the ks-feature workflow, or its legacy alias lg).
version: 1.0.0
argument-hint: "<feature description>"
---

# Feature Workflow

Take a feature from description to PR-ready by running the four phases in order, then summarize the results at the end:

1. **Prepare** — run the [prep](../prep/SKILL.md) skill: orient to the project, prepare the environment, and present the Development Context summary. Pause for the developer's confirmation before proceeding.
2. **Plan** — run the [plan](../plan/SKILL.md) skill with the feature description: write the story, create the ticket, and store the ticket number for the next phase.
3. **Produce** — run the [produce](../produce/SKILL.md) skill on the created ticket: TDD implementation with quality gates.
4. **Present** — run the [present](../present/SKILL.md) skill: self-review, evidence, PR creation, and the complete feedback loop.

**Question-shaped input** ("estimate…", "how would we…", "what would it take") runs in the plan skill's Investigation Mode: research and report only — no ticket, no code — until the developer says build.

Every phase inherits the full process — quality gates, evidence contract, fidelity pass, review loop, live ticket lifecycle. The developer never has to restate it.
