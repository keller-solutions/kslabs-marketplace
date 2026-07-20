# The Evidence Contract

## What Evidence Is

Proof a reviewer can see: for every UI acceptance criterion, a screenshot (or short recording) that **visibly demonstrates that criterion** — the element present, the state changed, the flow completed. A test-runner transcript is a gate artifact, not evidence. One story may need several shots; a shot that doesn't show the criterion's elements is the wrong shot and gets replaced.

## Captured on Real Data

- **Production-realistic data only.** A hand-seeded demo row proves the demo, not the feature (a lookup "verified" against one seeded record 500'd on the first real input). Walk the story the way plan's Deliver Without Seeding intends: preconditions created through the app.
- **Never invent external-system identifiers.** Unconfirmed foreign IDs read as pending/blank — a fabricated UUID becomes tomorrow's phantom bug.
- **Fixtures must be unmistakable.** A test image visually identical to the default state makes working software look broken; pick fixtures that prove themselves at a glance.
- **Verification data survives until the human is done.** Never clean up seeded/verification state until the developer confirms they've finished looking — deleting it mid-review crashes the very page being verified.

## Where Evidence Lives

- Save to a declared working folder — `evidence/<ticket-id>/` — and **echo the paths** in the report so nothing "lands somewhere findable" only in theory.
- **Never commit evidence to the repository.** Add `evidence/` to `.gitignore` on first use.
- Delete stale/superseded shots when replacing them; attach the current truth only.

## Attaching, Per Tool

| Tool | Mechanism |
|------|-----------|
| ClickUp | Attach as you go: `curl -X POST .../task/{id}/attachment -H "Authorization: $CLICKUP_API_TOKEN" -F "attachment=@evidence/EADEV-180.png"` |
| Azure DevOps | Two-step REST: `POST {org}/{project}/_apis/wit/attachments?fileName=...` (body = file) → `PATCH` the work item adding an `AttachedFile` relation to the returned URL |
| Jira | `curl -X POST .../rest/api/3/issue/{key}/attachments -H "X-Atlassian-Token: no-check" -F "file=@..."` |
| GitHub | No public upload API. Sanctioned path: browser automation performs the real UI upload and harvests the persistent `user-attachments` URL (inherits repo visibility — private stays private) for the PR/issue body. Fallback: CI-artifact link. Prefer Mermaid/text when a diagram beats a pixel. |
| Linear | Post links (external upload requires GraphQL file upload; hold-and-link at PR time) |

Epic Mode buckets: attach-as-you-go where the API allows (ClickUp, ADO, Jira); hold-and-batch at PR time for the rest.

**Revisit note:** the GitHub mechanism is a workaround for a missing API — recheck for a supported attachments endpoint periodically and upgrade when one ships.
