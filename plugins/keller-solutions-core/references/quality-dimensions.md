# Quality Dimensions

## The Core Idea

**Functionality is necessary, not sufficient.** A feature that works can still be insecure, slow, inaccessible, invisible to search, un-citable by AI, fragile under failure, careless with data, unobservable in production, or ruinously expensive at scale. Each of those is a *dimension of quality*, and every feature should be considered against all of them.

These dimensions are not a separate audit you run at the end. They are a **lens applied throughout the work**: anticipated when planning the story, verified while producing it, and reported when presenting it.

---

## The Lens, Not a Gate

Do not run nine full audits on every one-line change. **Triage first: which dimensions does this feature actually touch?** A copy tweak touches few; a new public page touches most; a new external API call touches Reliability, Privacy, Observability, and Cost whether or not it has a UI.

The discipline is the *question*, asked every time: "Which of these does this feature affect, and have I addressed them?" An honest "not applicable" is a valid answer — a recorded one. Silence is the failure mode, not a short list.

Where these meet the workflow:

- **Plan** — for each applicable dimension, write its requirement into the story now (an acceptance criterion a reviewer can check, or a Developer Note). A screen-reader path, a rate limit, a "log the outcome" note — cheaper as a criterion than as rework.
- **Produce** — verify each applicable dimension before the ready report; fold the checks into the quality gates and self-review.
- **Present** — state in the PR which dimensions applied and how each was addressed or verified (and which were N/A and why).

---

## The Dimensions

### 1. Security
Protect against attackers and abuse.
- **Applies when:** handling user input, auth/authorization, public or token-only endpoints, secrets/credentials, rendering user-influenced content, external data.
- **Check by:** authorization scoped to the actor (no IDOR); input validated and DB-backed; no secrets in code/logs; injection-safe queries; rate limits on public endpoints; a CSP and security headers; static analysis (e.g. Brakeman) clean.

### 2. Performance / Core Web Vitals
Fast to load, smooth to interact with.
- **Applies when:** any user-facing page or asset; queries; loops over data; large payloads.
- **Check by:** LCP/CLS/INP on the affected pages; render-blocking CSS/JS/fonts minimized; no N+1 queries; assets compressed and cached; no layout shift from async content; no heavy synchronous work on input.

### 3. Accessibility (WCAG 2.2 AA)
Usable by everyone, including assistive-tech and keyboard-only users.
- **Applies when:** any UI — new or changed.
- **Check by:** semantic HTML and heading order; labels tied to inputs; full keyboard operability and visible focus (incl. forced-colors); contrast at AA (AAA for body); async updates announced via live regions; errors tied to their fields; a screen-reader/keyboard walkthrough of the real flow.

### 4. SEO
Public pages found and indexed correctly — and private pages kept out.
- **Applies when:** any routable page. Public marketing pages should be *indexable*; app and private/share pages must be *non-indexable*.
- **Check by:** unique title + description, canonical URL; `robots.txt` + sitemap; valid structured data; `noindex` (header and/or meta) on private pages — never a robots `Disallow` that hides the directive; no sensitive data in unfurl/OG tags.

### 5. AEO (Answer-Engine Optimization)
Citable and accurately represented by AI answer engines (ChatGPT, Perplexity, AI Overviews, Claude).
- **Applies when:** public marketing/content pages.
- **Check by:** answer-shaped content (the real questions, answered in plain extractable prose); an `@id`-linked JSON-LD entity graph; AI-crawler access decided in `robots.txt`; optional `llms.txt`. Private/app pages stay out of AI reach (same `noindex` posture as SEO).

### 6. Reliability
Behaves correctly under failure, not just on the happy path.
- **Applies when:** external/API calls, background jobs, data mutations, async UI, anything with a timeout or partial-failure window.
- **Check by:** errors handled with a user-honest fallback (never a silent 500 or a half-written record); timeouts and bounded retries on external calls; idempotency where a step can re-run; graceful degradation when a dependency is down; transactions around multi-step writes.

### 7. Privacy & Data Protection
Handle user data responsibly (distinct from Security — this is about *our* handling, not attackers).
- **Applies when:** PII, financial or otherwise-sensitive data, logging, analytics events, anything sent to a third party, link unfurls/previews.
- **Check by:** collect/retain the minimum; no PII or secrets in URLs, logs, or analytics; sensitive values never leak into OG/unfurl/preview surfaces; consent where required; a clear retention/deletion answer; regulatory posture (GDPR/CCPA) considered.

### 8. Observability
You can tell, in production, whether it actually works.
- **Applies when:** any non-trivial feature — especially background, async, external-dependency, or business-critical paths.
- **Check by:** structured logs at the right level (no noise, no PII); a success/usage signal (metric or event) for features whose health matters; errors surface to tracking, not just logs; you can answer "is this working right now?" without SSHing in.

### 9. Cost & Efficiency
Sustainable as usage grows (overlaps Performance, but focuses on dollars and scale).
- **Applies when:** database queries, external or LLM API calls, compute/storage, anything that scales with traffic or data volume.
- **Check by:** query count bounded (no N+1, sensible indexes); external/LLM calls minimized, cached, and rate-limited; LLM token usage and per-call cost bounded with a deadline; payload/storage sizes reasonable; no unbounded growth.

---

## Triage Step (use this at plan and produce)

1. List the dimensions this feature plausibly touches (most features touch 3–6).
2. For each touched dimension, name the concrete requirement or check.
3. Record the rest as "N/A — <one-line why>." A dimension is never skipped silently; it is either addressed or explicitly dismissed.

---

## Cross-Cutting Must-Nots

Some dimensions impose hard constraints that survive any feature's convenience:

- **Private data never becomes public** — app and token-only pages stay `noindex`; no sensitive figures in OG/unfurl tags; no PII in URLs, logs, analytics, or AI-reachable content. (Security + Privacy + SEO + AEO together.)
- **No silent failure** — a feature that can fail must say so (to the user and to monitoring), not corrupt data or vanish. (Reliability + Observability.)
- **No secrets in the repo or logs.** (Security + Privacy.)

---

## Quick Reference

| Dimension | The question to ask |
|-----------|---------------------|
| **Security** | Can an attacker reach, read, or break something they shouldn't? |
| **Performance / CWV** | Is it fast to load and smooth to use on a mid-range phone? |
| **Accessibility** | Can a keyboard-only and a screen-reader user complete this? |
| **SEO** | Are public pages indexable and private pages kept out? |
| **AEO** | Can an AI answer engine cite this accurately — and not reach private data? |
| **Reliability** | What happens when a dependency, the network, or the input fails? |
| **Privacy** | Are we collecting, logging, and exposing the minimum, and nothing sensitive? |
| **Observability** | Could I tell in production whether this is working? |
| **Cost & Efficiency** | What does this cost per request, and how does it grow with scale? |

---

## The Bottom Line

"It works" is the start of the quality conversation, not the end. Ask the nine questions of every feature, answer the ones that apply, and record the ones that don't. The cost of considering a dimension at plan time is a sentence; the cost of discovering it after launch is an incident.
