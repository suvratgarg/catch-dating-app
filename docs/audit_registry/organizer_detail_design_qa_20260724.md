# Organizer Detail design QA

## Scope

- Route: `/organizers/afterfly/`
- Selected visual target:
  `/Users/suvratgarg/.codex/generated_images/019f9056-e21a-7731-ab50-b4e43ca1eac7/call_lB4CINEPXYXWMZoRMHnctKQ8.png`
- Flutter organizer-detail reference:
  `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/design/reference_screens/screen.club.detail/member_default.png`
- Desktop implementation:
  `/Users/suvratgarg/.codex/visualizations/2026/07/23/019f9056-e21a-7731-ab50-b4e43ca1eac7/organizer-detail-option1-desktop-final.jpg`
- Mobile implementation:
  `/Users/suvratgarg/.codex/visualizations/2026/07/23/019f9056-e21a-7731-ab50-b4e43ca1eac7/organizer-detail-option1-mobile-final.jpg`
- Lower-content and sticky-rail implementation:
  `/Users/suvratgarg/.codex/visualizations/2026/07/23/019f9056-e21a-7731-ab50-b4e43ca1eac7/organizer-detail-option1-desktop-lower-final.jpg`

## Data and capability state

- AFTER FLY is source-backed, unclaimed, web-only, and not owner verified.
- The projection supplies two public sources, no published Catch events, and no
  public reviews.
- Claim requests and public organizer reviews remain disabled until their
  canonical targets are verified. The page exposes those capabilities without
  inventing readiness.
- The route contains no booking, checkout, sign-in, or account flow.

## Comparison evidence

- The generated target and desktop implementation were inspected at equivalent
  top-of-page crops. Browser evidence used a 1422 by 800 viewport.
- The responsive implementation was inspected in a fixed 390-pixel iframe.
  Body client width and scroll width were both 390 pixels, with no horizontal
  overflow.
- The lower desktop sections were inspected after reveal animation settled.
  The right action rail remained sticky while About, formats, reviews, and fit
  content scrolled in the primary column.
- The Luma source resolved to `https://luma.com/pxgmph3b`. Save was exercised
  through both pressed and unpressed states, and Share remained a real button.
- Console inspection found no application error or framework exception.

## Findings and resolutions

1. Resolved: organizer identity no longer reuses the event-ticket metaphor.
   The hero is now a landscape Catch polaroid with a white inset mat, activity
   image, mono location caption, upright Archivo name, and source provenance.
2. Resolved: the page now follows the selected wide-primary/narrow-secondary
   composition. Identity, claim/source/share/save actions, source links, and
   event state live in a sticky secondary rail.
3. Resolved: crawled and verified authority remain separate from claim status.
   AFTER FLY visibly reads source-backed, unclaimed, web-only, and ownership
   not verified rather than implying organizer control.
4. Resolved: reviews remain a first-class organizer section even when the
   capability is unavailable. The page explains the fail-closed state instead
   of hiding the feature or inventing review content.
5. Resolved: the mobile composition follows the app's organizer-detail
   hierarchy. It presents polaroid, provenance ledger, organizer identity, and
   actions before the remaining detail sections.
6. Resolved: the initial format-chip color missed WCAG contrast. Its activity
   color is now mixed with the governed text token, and all Storybook
   accessibility checks pass.

## Intentional differences from the concept render

- The production Catch header is retained instead of replacing it with the
  concept render's editorial navigation.
- The concept shows an active coral claim button. AFTER FLY's current generated
  capability is disabled, so the implementation keeps the CTA visible but
  disabled and explains why. Claim-enabled listing stories render the active
  state.
- The implementation does not fake source/action icons with text glyphs or
  one-off CSS artwork. Labels remain explicit until a governed icon primitive
  is selected.

## Verification

- Focused organizer tests: 47 passed.
- Storybook accessibility: 143 passed across 16 files.
- Marketing typecheck, production build, Storybook build, route contract,
  component registry, copy ownership, import boundaries, React primitives,
  component governance, shared UI adoption, query-state, and organizer build
  output checks passed.
- No P0, P1, or P2 behavior, accessibility, or responsive findings remain for
  this implementation pass.

## Existing Event Detail fidelity follow-up

- Owner feedback on 2026-07-24 remains open: Event Detail still has material
  fit-and-finish drift from its selected proposal.
- Revisit desktop content width, image-to-content proportions, title scale and
  wrapping, fact-strip density, organizer/action rail hierarchy, card
  finishing, and above-the-fold plan/review visibility.
- Run that as a shared finishing pass after Organizer Detail is tuned so both
  public-detail surfaces converge without transferring the organizer polaroid
  metaphor back onto event tickets.

**Final result: passed.**
