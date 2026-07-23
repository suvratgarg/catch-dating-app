# Event Detail design QA

## Scope

- Route state: external, source-backed Afterfly event with claim enabled and
  event reviews unavailable until the canonical review target is verified.
- Selected visual target:
  `/Users/suvratgarg/.codex/generated_images/019f9056-e21a-7731-ab50-b4e43ca1eac7/call_i0VSW82lrMOggsqECSFzII9A.png`
- Flutter mobile reference:
  `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/design/reference_screens/screen.event.detail/member_default.png`
- Desktop implementation:
  `/Users/suvratgarg/.codex/visualizations/2026/07/23/019f9056-e21a-7731-ab50-b4e43ca1eac7/event-detail-option1-desktop-final.png`
- Mobile implementation:
  `/Users/suvratgarg/.codex/visualizations/2026/07/23/019f9056-e21a-7731-ab50-b4e43ca1eac7/event-detail-option1-mobile-final.png`

## Comparison evidence

- Desktop target and implementation were inspected together in
  `event-detail-option1-comparison-desktop.png`.
- Flutter reference and mobile implementation were inspected together in
  `event-detail-option1-comparison-mobile.png`.
- The desktop Storybook route was also inspected at the top, event-facts,
  provenance, and review-section scroll positions.
- Desktop browser evidence used a 1422 by 800 viewport at device-pixel ratio
  1.8. The fixed desktop QA frame also rendered at 1440 by 1024.
- Mobile browser evidence used an exact 390 by 844 iframe at device-pixel ratio
  1.8. Body client width and scroll width were both 390 pixels.
- Tablet evidence used a 768 by 900 iframe. Body client width and scroll width
  were both 768 pixels, and the hero resolved to a single 712-pixel column.

## Findings and resolutions

1. Resolved: the former wide editorial hero did not preserve the selected
   ticket-and-rail hierarchy. The implementation now uses a media ticket plus a
   sticky organizer/action rail above 900 pixels and one column below it.
2. Resolved: a mobile adaptation could have become a compressed desktop card.
   At 390 pixels it now follows the Flutter screen's image, identity, compact
   three-fact strip, plan, and review sequence. The source CTA follows the
   ticket and the organizer panel follows the source CTA.
3. Resolved: the concept visual showed organizer metrics and an event review
   that the generated Afterfly projection does not supply. The implementation
   omits invented metrics and renders the fail-closed event-review explanation.
4. Resolved: provenance and actions are independent. The source-backed badge,
   official-source CTA, organizer link, and conditional claim link are all
   visible without implying owner verification.
5. Resolved: all layout color, type, spacing, radius, focus, and activity accent
   values resolve through Catch design tokens. The event image is a real
   generated raster asset with an explicit illustrative-media alt description;
   there is no CSS or SVG substitute.
6. Resolved: no horizontal overflow was present at desktop, tablet, or mobile.
   Long location and schedule values wrap inside their fact cells without
   overlap or clipping.

## Function and accessibility evidence

- Browser DOM inspection confirmed semantic banner, navigation, main regions,
  article, complementary panels, headings, definition lists, links, and footer.
- The organizer link was exercised from the rendered Storybook route and its
  canonical href was confirmed as `/organizers/afterfly/`.
- The official source link was confirmed as
  `https://luma.com/afterfly-takeoff-run-rave`; claim resolves to
  `/claim/?listing=afterfly`.
- The rendered page contains no booking, checkout, or sign-in control.
- The illustrative image has descriptive alt text and shared buttons retain
  the governed focus treatment and practical mobile tap height.
- Console inspection found no application error or framework exception. The
  only earlier warning came from the nested Storybook iframe trying to attach
  its developer tooling.

## Comparison history

- Pass 1: matched the chosen desktop composition and replaced the oversized
  editorial hero.
- Pass 2: moved claim to organizer identity, removed inferred metrics, and made
  event reviews capability-aware.
- Pass 3: tightened the mobile media ratio, fact strip, ordering, and action
  density; verified 390-, 768-, and desktop-width layouts.
- Pass 4: compared target and implementation in paired frames and inspected the
  lower facts, provenance, and review sections.

No P0, P1, or P2 design, behavior, accessibility, or responsive findings remain.

**Final result: passed.**
