---
doc_id: marketing_landing_page_tracker
version: 0.3.0
updated: 2026-05-25
owner: marketing_website
status: active
---

# Marketing Landing Page Tracker

This tracker stays active until the research direction has been approved and
the production Catch marketing site has been rebuilt, verified, and folded into
`docs/marketing_landing_page_research.md` plus `docs/marketing_app_media_pipeline.md`.

## Goal

Replace the current low-conversion website direction with a sophisticated,
consumer-grade landing page that converts both members and hosts, while also
establishing durable visual guidance for the app.

## Current Artifacts

| Artifact | Path | Status |
|---|---|---|
| Research doc | `docs/marketing_landing_page_research.md` | Updated through production rewrite |
| Screenshot catalog | `docs/visual_references/marketing_site_research/README.md` | Updated through production rewrite |
| Reference screenshots | `docs/visual_references/marketing_site_research/*.png` | Captured |
| Isolated preview UI | `website/research-preview/index.html` | Rejected; do not use as direction |
| Current homepage evidence | `docs/visual_references/marketing_site_research/current-catch-home.png` | Captured |
| Current host page evidence | `docs/visual_references/marketing_site_research/current-catch-host.png` | Captured |
| Preview screenshot | `docs/visual_references/marketing_site_research/catch-preview.png` | Captured |
| Preview mobile screenshot | `docs/visual_references/marketing_site_research/catch-preview-mobile.png` | Captured |
| Generated desktop concept | `docs/visual_references/marketing_site_research/catch-production-concept-desktop.png` | Approved direction |
| Generated mobile concept | `docs/visual_references/marketing_site_research/catch-production-concept-mobile.png` | Reference only |
| Production homepage desktop QA | `docs/visual_references/marketing_site_research/catch-production-home-desktop.png` | Captured |
| Production homepage mobile QA | `docs/visual_references/marketing_site_research/catch-production-home-mobile.png` | Captured |
| Production host desktop QA | `docs/visual_references/marketing_site_research/catch-production-host-desktop.png` | Captured |
| Production host mobile QA | `docs/visual_references/marketing_site_research/catch-production-host-mobile.png` | Captured |

## Reference Coverage

| Reference | Required by brief | Researched | Screenshot | Notes |
|---|---:|---:|---:|---|
| Matchbox | Yes | Yes | Yes | Closest event-matching reference. |
| Hinge | Yes | Yes | Yes | Dating positioning and credibility. |
| Tinder | Yes | Yes | Yes | Dating category baseline. |
| Bumble | No | Yes | Yes | Consumer app confidence and visual scale. |
| Feeld | No | Yes | Yes | Editorial, premium, adult visual tone. |
| Thursday | No | Yes | Yes | IRL dating event energy and host path. |
| Partiful Matchmaking | No | Yes | Yes | Singles events and mutual reveal flow. |
| Partiful Organizers | No | Yes | Yes | Run-club/community organizer framing. |
| Luma | No | Yes | Yes | Event software simplicity. |
| Posh | No | Yes | Blocked | Region block from India; text still accessible. |
| Eventbrite Organizer | No | Yes | Yes | Event management and creator growth. |
| Meetup Organizers | No | Yes | Yes | Local community and recurring organizer model. |
| Splash | No | Yes | Blocked | Security verification in headless mode; text still accessible. |
| Ticket Tailor | No | Yes | Partial | Screenshot rendered, but page assets were limited in headless mode. |
| DICE | No | Yes | Blocked | Security verification in headless mode; text still accessible. |
| Gametime Hero | No | Yes | Yes | Active-community host tools. |

## Decision Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-05-25 | Treat this as research and preview, not production rewrite. | User explicitly asked for reference research, documentation, preview UI, and content rationale before trying again. |
| 2026-05-25 | Keep production `website/index.html`, `website/host/index.html`, `website/styles.css`, and `website/script.js` unchanged during research. | The tree is dirty and the user wants direction before implementation. |
| 2026-05-25 | Store screenshots under `docs/visual_references/marketing_site_research/`. | Research must survive context windows and remain visually inspectable. |
| 2026-05-25 | Use an isolated `website/research-preview/` page for the next concept. | It is easy to open, screenshot, and delete or iterate without affecting Hosting. |
| 2026-05-25 | Reject the first isolated preview. | It is visually weak and incorrectly frames Catch as a pure run-club app. |
| 2026-05-25 | Re-ground the next pass in the current event-platform feature set. | Repo docs show broader activity formats, event policies, live event success, host reporting, and post-event dating. |
| 2026-05-25 | Use the production desktop concept as the visual north star. | It matches the research better than the rejected preview: dark editorial media, high-contrast lime action, multi-format story, host controls, and app/product proof. |
| 2026-05-25 | Rewrite the live static site now. | User approved production-ready implementation with temporary event media and asked not to wait for a later quality pass. |
| 2026-05-25 | Implement one responsive architecture. | `website/index.html` and `website/host/index.html` share semantic markup and `website/styles.css` handles layout through constraints and breakpoints rather than separate mobile/desktop branches. |

## Work Plan

| Step | Status | Proof |
|---|---|---|
| Inspect current Catch website files and media pipeline | Done | Read `website/index.html`, `website/host/index.html`, `website/styles.css`, `website/script.js`, and `docs/marketing_app_media_pipeline.md`. |
| Capture current Catch homepage and host page | Done | `current-catch-home.png`, `current-catch-host.png`. |
| Research at least 12 reference websites | Done | 16 references cataloged in `docs/marketing_landing_page_research.md`. |
| Capture visual references where possible | Done | 16 screenshot files plus blocked-state evidence. |
| Document findings and content rationale | Done | `docs/marketing_landing_page_research.md`. |
| Generate isolated preview UI | Rejected | `website/research-preview/index.html` remains only as discarded evidence. |
| Capture preview screenshot | Done | `docs/visual_references/marketing_site_research/catch-preview.png`. |
| Capture mobile preview screenshot | Done | `docs/visual_references/marketing_site_research/catch-preview-mobile.png`. |
| Review preview against research | Rejected | Preview still fails product positioning and brand quality despite layout fixes. |
| Reread current product docs | Done | Read `PROJECT_CONTEXT.md`, `docs/event_success.md`, `lib/event_policies/README.md`, `lib/activity/domain/activity_taxonomy.dart`, and `docs/marketing_app_media_pipeline.md`. |
| Update research with product-truth correction | Done | `docs/marketing_landing_page_research.md` now marks the run-only preview rejected and documents the current singles event-platform scope. |
| Create corrected preview UI | Done | Generated concept boards: `catch-production-concept-desktop.png`, `catch-production-concept-mobile.png`. |
| User approval before production rewrite | Done | User approved moving forward with production-ready implementation and temporary event media. |
| Production implementation | Done | Rewrote `website/index.html`, `website/host/index.html`, `website/styles.css`; added temporary hero asset; updated marketing capture manifest copy. |
| Verification | Done | `node tool/marketing/sync_website_media.mjs --check`, targeted `git diff --check`, desktop/mobile screenshots, `dart tool/audit_registry.dart refresh`, `mark-pass`, and `report`. |

## Production Rewrite Guardrails

- Do not invent social proof, press, user counts, host revenue, or match success.
- Do not ship placeholder phone mockups as the primary visual proof.
- Do not return to an orange/beige-only palette.
- Do not frame Catch as a pure run-club app.
- Do not bury the host path below member-only copy.
- Do not reduce host tooling to "publish an event"; include admission, cohort
  balance, waitlist, payments, check-in/live mode, and reporting where safe.
- Do not imply all event formats support the same live facilitation depth. Social
  runs should stay lightweight; structured mixers, racket pairs, dinners, and
  quiz/team formats can support more guided moments.
- Do not add a marketing hero that hides the next section on every viewport.
- Keep the screenshot manifest contract intact unless `docs/marketing_app_media_pipeline.md` is updated in the same pass.

## Open Questions

1. Which event formats are public-launch-ready versus roadmap-visible?
2. Should the next production site be one combined page with member and host
   paths, or retain `/host/` as a deeper host-specific conversion page?
3. Which claims are safe today: attendance-gated, mutual catch/private crush,
   host controls, live guide, event-success report, App Store/Play Store timing,
   payment?
4. Should temporary hero/event media be generated now, sourced from owned
   photos, or blocked until real assets exist?
5. Should the app theme tokens move in the same PR as the website redesign, or
   should app theming follow after website direction approval?
