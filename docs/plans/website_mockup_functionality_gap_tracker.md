---
doc_id: website_mockup_functionality_gap_tracker
version: 0.1.3
updated: 2026-06-12
owner: marketing_web
status: active
---

# Website Mockup Functionality Gap Tracker

## Purpose

Implement the supplied Claude website mockup direction on the live Catch
marketing website without importing prototype-only code. The production site
must use Catch tokens, canonical reusable website components, generated public
projections, and existing Firebase callable boundaries.

## Implementation Principles

- Use `packages/web-config/generated/catch-tokens.css` through the existing
  `packages/web-config/styles/catch-web.css` import path.
- Prefer canonical website components over page-local markup and CSS.
- Let the Claude mockup guide visual language when it diverges from the current
  website, but keep Catch tokens as the source of truth.
- Do not import `window.ORGS`, hash routing, fabricated organizer data, or
  `image-slot` editing utilities from the prototype.
- Implement small missing behavior when it fits the current slice; append larger
  or backend-dependent work to the backlog below.

## Canonical Component Work

- [x] Create this persistent tracker.
- [x] Add a reusable website component layer under `website/src/components/`.
- [x] Route existing shared UI through canonical components:
  - [x] `SiteHeader`
  - [x] `SiteFooter`
  - [x] `ActivityMark`
  - [x] `StatusBadge`
  - [x] `ProfileStrength`
  - [x] `CaptureCard`
- [x] Add canonical discovery components:
  - [x] `PublicSearchBar`
  - [x] `PublicEventCard`
  - [x] `SectionHeader`
- [x] Restyle reusable components toward the Claude mockup's directory,
  ticket, claim, and host product language.

## Functionality Slices

- [x] Homepage: add a real event/search discovery band sourced from generated
  organizer data.
- [x] Directory: make filters URL-backed for `q`, `city`, `format`, `status`,
  `upcoming`, `rating`, and `sort`.
- [x] Directory: add event-aware search results and claim-pressure strip.
- [x] Listing: strengthen verified-vs-public review grouping and owner-response
  pressure.
- [x] Listing: add event CTAs/deep links for Catch-created public events.
- [x] Listing: implement share behavior instead of inert share controls.
- [x] Claim: add the richer pending state and "while you wait" checklist from
  the mockup.
- [x] Claim: show clear already-claimed, pending-claim, and not-found states.
- [x] Host: port "fill the room" modules for paid checkout, waitlist offers,
  and balanced cohorts into reusable host product blocks.
- [x] Host: convert the five-step create-event section into an active-step
  walkthrough with one visible description at a time and capture-backed media.
- [x] Host: keep Event Success module copy aligned with the live product module
  catalog and privacy constraints.

## Backlog / Deferred Decisions

- [ ] Decide whether the mockup's fabricated Indore organizers become real seed
  listings, demo-only fixtures, or remain excluded from production.
- [ ] Decide whether the public website should call a live public event
  projection callable, or keep all public events inside generated static JSON.
- [ ] Add an Instagram DM code verification backend path before promising that
  method as an automated claim option.
- [ ] Add new marketing capture slots only through
  `tool/marketing/capture_manifest.json` and the existing sync/export pipeline.
- [ ] Replace the proxy host-create step captures with exact create-event
  step screenshots once the UI capture catalog adds those fixtures.

## Verification Log

- 2026-06-12: `npm --prefix website run build` passed, including generated
  organizer listings, TypeScript, Vite, and postbuild metadata.
- 2026-06-12: `node tool/marketing/sync_website_media.mjs --check` passed.
- 2026-06-12: `git diff --check` passed.
- 2026-06-12: Browser-rendered `http://127.0.0.1:5176/` desktop and mobile
  checks passed for the new homepage discovery band with no horizontal
  overflow.
- 2026-06-12: Browser-rendered `/organizers/?q=techno&city=Indore&status=unclaimed&format=Run-and-rave&sort=confidence`;
  filters hydrated from the URL, AFTER FLY matched through source event
  evidence, the claim-pressure strip rendered, interactive filter changes wrote
  `upcoming=true` and `rating=4` back to the URL, and desktop/mobile overflow
  checks passed.
- 2026-06-12: Browser-rendered `/organizers/indore/afterfly-run-club/`;
  listing share control and live status region rendered on desktop/mobile with
  no horizontal overflow. Automated click was skipped to avoid opening the host
  OS share sheet; `npm --prefix website run build` typechecked the handler.
- 2026-06-12: `npm --prefix website run build` passed after the listing
  event/review slice.
- 2026-06-12: Browser-rendered `/organizers/new-york/sunday-table-club/#event-event-host-post-report`;
  the page exposed three Catch-created event action cards, per-event anchors,
  outcome/review CTAs, two app download CTAs, verified/public review lanes,
  owner-response pressure, and no desktop/mobile horizontal overflow.
- 2026-06-12: Browser-rendered `/organizers/indore/afterfly-run-club/#reviews`;
  zero-review unclaimed pages now show the claim-to-respond owner prompt and
  no horizontal overflow.
- 2026-06-12: `npm --prefix website run build` passed after the claim-state
  slice.
- 2026-06-12: Browser-rendered `/claim/?listing=club-sales-sunday-table`,
  `/claim/?listing=afterfly-run-club-indore&claimStatus=pending&requestId=req_demo_123`,
  `/claim/?listing=does-not-exist`, and `/claim/?listing=afterfly-run-club-indore`;
  already-claimed, pending, not-found, and normal claimable states rendered
  distinctly, invalid duplicate submissions were suppressed, the pending state
  showed the while-you-wait checklist, and desktop/mobile overflow checks
  passed.
- 2026-06-12: `npm --prefix website run build` passed after the host product
  module slice.
- 2026-06-12: Browser-rendered `/host/#fill-room`; paid checkout, waitlist
  offers, and balanced cohorts rendered through reusable product module cards,
  the host nav exposed the Fill room anchor, Event Success copy named the live
  module catalog and privacy boundary, and desktop/mobile overflow checks
  passed.
- 2026-06-12: Browser-rendered `/host/`; the five-step host create flow now
  reveals only the active step description, swaps all five capture slots
  (`host-create-basics`, `host-create-location`, `host-create-schedule`,
  `host-create-policy`, `host-create-guide`), loads every image, and passed
  desktop/mobile overflow checks.
