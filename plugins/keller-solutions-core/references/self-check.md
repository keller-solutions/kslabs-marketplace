# Self-Check: Every Skill Verifies Itself Before Claiming Completion

## The Pattern

Every ks skill ends by printing its own checklist **with honest verdicts** — ✓ only for items actually done and observed, ✗ (with one line of why) for anything skipped, failed, or not applicable-but-unrecorded. The checklist is the skill's contract; the verdicts are its testimony.

**An ✗ forbids completion wording.** A report with any failing item is titled as *status*, not completion — "Implementation Status", not "Implementation Complete"; "PR Status", not "PR Ready" — and its last line names exactly what remains. The words "complete", "done", and "ready" are earned by an all-✓ checklist, never by proximity to the end of the work.

Standard verdict items (each skill's own report lists its specifics): story format valid · ticket created in the right system · status lifecycled live · full gate run and green (CI parity) · evidence captured and attached · fidelity pass done · CHANGELOG updated (where one exists) · dependencies actually updated (not merely installed) · stack review run · Copilot loop closed (requested, addressed, replied) · PR checks green.

## Surviving Compaction

Checklist state must outlive the conversation. In epic runs, write verdicts into the `.ks/epic-<id>-state.json` child entry as they resolve ([Epic Mode](epic-mode.md)); in single-story runs, the printed report in the transcript plus the ticket comment carry them. After compaction or resume, re-derive verdicts from artifacts (git log, `gh pr checks`, ticket state) — never from memory of having printed them.

## The Enforcement Ladder

Printed checklists advise; they don't enforce — instruction text fades (long sessions compact; prose gets skimmed). The ladder, weakest to strongest:

1. **The printed verdict checklist** (this document) — visible honesty, cheap.
2. **Guardrail hooks** — deterministic denials of never-events and completion-claim checks that inspect the actual state (see the plugin's `hooks/`).
3. **A goal condition** for long runs — the run's completion condition re-checked each turn against artifacts, not intent.
4. **Fresh-context verification** — for epics, a verification pass that sees only the diff, the tickets, and the checklist, and confirms each verdict independently. What it can't confirm, it marks ✗.

Skills print (1) always; epic runs add (3) and (4); (2) ships with the plugin and applies everywhere.
