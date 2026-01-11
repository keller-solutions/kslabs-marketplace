# ADR Template

Architecture Decision Records (ADRs) document consequential technical decisions. This template follows the format popularized by Michael Nygard.

---

# ADR NNNN: [Short Descriptive Title]

## Status

**[Proposed | Accepted | Deprecated | Superseded]**

[If superseded: Superseded by [ADR NNNN](NNNN-title.md)]

## Date

YYYY-MM-DD (e.g., 2024-01-15)

## Context

[What is the issue that we're seeing that is motivating this decision or change?]

[Include relevant background:

- Technical constraints
- Business requirements
- Team capabilities
- Timeline pressures
- Related systems]

## Decision

[What is the change that we're proposing and/or doing?]

[Be specific:

- What technology/approach/pattern are we choosing?
- What are we NOT choosing?
- What are the boundaries of this decision?]

## Consequences

[What becomes easier or more difficult to do because of this change?]

### Positive

- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

### Negative

- [Trade-off 1]
- [Trade-off 2]

### Neutral

- [Side effect that's neither clearly positive nor negative]

## Alternatives Considered

### [Alternative 1]

[Brief description and why it was rejected]

### [Alternative 2]

[Brief description and why it was rejected]

## References

- [Link to relevant documentation]
- [Link to related discussions or issues]
- [Link to external resources consulted]

---

# ADR Guidelines

## When to Create an ADR

Create an ADR when making decisions that:

- **Affect architecture**: Technology choices, patterns, integrations
- **Are hard to reverse**: Migration costs would be high
- **Impact multiple teams or projects**: Cross-cutting concerns
- **Required research or debate**: Non-obvious choices
- **Future developers will ask "why?"**: Document the reasoning

## When NOT to Create an ADR

Skip ADRs for:

- Implementation details that can easily change
- Standard library/framework usage
- Obvious choices with no alternatives
- Temporary solutions with clear expiration

## Naming Convention

```text
NNNN-short-title.md
```

Examples:

- `0001-use-solid-queue-for-background-jobs.md`
- `0002-adopt-conventional-commits.md`
- `0003-use-turbo-frames-for-pagination.md`

## Status Lifecycle

```text
Proposed → Accepted → [Deprecated | Superseded]
```

- **Proposed**: Under discussion, not yet implemented
- **Accepted**: Decision made, implementation in progress or complete
- **Deprecated**: Decision is no longer valid/relevant
- **Superseded**: Replaced by a newer ADR (link to it)

## Writing Tips

### Context Section

- Explain the problem, not the solution
- Include constraints (time, budget, skills)
- Reference related issues or discussions
- Be honest about pressures and trade-offs

### Decision Section

- State the decision clearly in one sentence
- Explain what you're NOT doing
- Define scope and boundaries
- Include implementation notes if relevant

### Consequences Section

- Be honest about trade-offs
- Include operational impacts
- Note learning curve or training needs
- Consider future flexibility

### Alternatives Section

- Show you considered other options
- Explain why each was rejected
- This helps future readers understand the reasoning

## Example: Real ADR

```markdown
# ADR 0001: Use Solid Queue for Background Jobs

## Status

Accepted

## Date

2024-01-15

## Context

We need a background job system for accessibility scans. Requirements:
- Must handle long-running jobs (5+ minutes)
- Must support job priorities
- Should integrate with Rails 8
- Team has limited DevOps capacity

Current options in the Rails ecosystem:
- Sidekiq (Redis-based, mature)
- Solid Queue (Database-based, new in Rails 7.1)
- Good Job (Database-based, mature)

## Decision

We will use Solid Queue for background job processing.

## Consequences

### Positive
- No additional infrastructure (uses existing PostgreSQL)
- Native Rails integration
- Simpler deployment and monitoring
- Built-in mission control dashboard

### Negative
- Less battle-tested than Sidekiq
- Fewer community resources
- May need migration if we outgrow it

### Neutral
- Learning curve is similar to other job systems

## Alternatives Considered

### Sidekiq
Mature and fast, but requires Redis infrastructure we don't
want to maintain. Overkill for our job volume.

### Good Job
Solid choice, but Solid Queue has better Rails 8 integration
and is the future direction for Rails.

## References

- https://github.com/rails/solid_queue
- Rails 7.1 release notes on Solid Queue
- Discussion in #architecture Slack channel (2024-01-10)
```

## Location

ADRs live in `docs/adr/` at the project root:

```text
docs/
└── adr/
    ├── 0000-template.md
    ├── 0001-use-solid-queue.md
    ├── 0002-adopt-conventional-commits.md
    └── README.md (optional index)
```

## Periodic Review

Review ADRs quarterly to:

- Update status of deprecated decisions
- Identify decisions that need revisiting
- Ensure new team members are aware of key decisions
- Archive truly obsolete records
