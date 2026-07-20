# Verified Fixes: Runtime Proof or It Isn't Fixed

## The Core Rule

**A green test suite is not a working application.** "Fixed", "working", and "done" are claims about runtime behavior, so they require runtime evidence — observed, not inferred:

- a screenshot of the feature doing the thing,
- a log line showing the corrected behavior,
- a passing reproduction of the original failure, or
- an HTTP response from the running app (at minimum, the root URL answering — a suite can pass while the app 404s).

Report the evidence with the claim. No evidence, no claim — say "the change is in; verifying now" instead.

## Troubleshooting Mode

The moment work shifts from building to diagnosing, the rules tighten:

1. **No commits until the human confirms the fix works.** Diagnosis produces experiments, not history. (A rare checkpoint worth keeping mid-hunt is committed with a `WIP` prefix — the exception, never the rule.)
2. **Two failed attempts ends the patch loop.** Stop, list the plausible causes, say which the evidence supports, and pick the root-cause path — never a third symptom-chase. ("Take a step back" should come from the process, not the user.)
3. **Reproduce before fixing when feasible.** A fix for an unreproduced bug is a guess wearing a commit message.

## Receipts for External Claims

Claims about external systems — vendor APIs, consoles, third-party behavior — cite current documentation or observed request/response pairs:

- Never assert a vendor UI control or setting exists without doc or API proof.
- Fetch current docs before walking anyone through a vendor console; instructions drift.
- **Correlation is not causation**: a timing coincidence ("it broke after the cutover") is a hypothesis to test against logs and timestamp windows, not a diagnosis to report.

## Where This Applies

Everywhere — produce's quality gates link here, but the rule governs any session: bug hunts, client incident triage, config debugging. It exists because the most-corrected behavior across nine months of session history was claiming "fixed" one step before proof.
