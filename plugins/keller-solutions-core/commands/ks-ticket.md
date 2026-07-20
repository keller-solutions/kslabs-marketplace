---
name: ks-ticket
description: Work on existing tickets. Runs Prepare → Produce → Present (skips Plan). Accepts one ticket, several tickets (impromptu epic), or an epic/parent ticket.
argument-hint: "<ticket number(s)>"
---

# Ticket Workflow

Run the ticket workflow skill:

`skill: ticket $ARGUMENTS`

This infers the delivery shape from the arguments (single ticket, impromptu epic, or epic with children), confirms it in one line, then runs prep, produce, and present — summarizing the results at the end.
