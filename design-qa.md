# Dress rehearsal canonical Room runtime design QA

- Source visual truth: `/Users/suvratgarg/.codex/generated_images/01a01faf-d9ef-75f0-b23f-06b9bbd2a047/exec-8067de10-a8ed-4c10-b203-360565d2a31c.png`
- Final implementation, light: `/private/tmp/catch-rehearsal-final-captures-v4/host_event_rehearsal_runtime_room/light.png`
- Final implementation, dark: `/private/tmp/catch-rehearsal-final-captures-v4/host_event_rehearsal_runtime_room/dark.png`
- Final normalized comparison: `/private/tmp/catch-rehearsal-final-captures-v4/host_event_rehearsal_runtime_room/light-normalized.png`
- Accessibility evidence: `/private/tmp/catch-rehearsal-modernized-captures-text2-final/host_event_rehearsal_runtime_room/dark.png`
- State: placement practice task, canonical Host Live > Room workspace, 24 synthetic guests, six tables, virtual time 7:42 PM.
- Source pixels: 852 x 1846, treated as a 2x 426 x 923 CSS reference.
- Implementation pixels: 1206 x 2622 from a 402 x 874 CSS viewport at capture ratio 3.
- Density normalization: final light implementation was resampled to 852 x 1846 and opened in the same comparison input as the source. The aspect ratios match; the source represents a slightly larger logical viewport.

## Findings

- No actionable P0, P1, or P2 visual or responsive mismatch remains for this slice.
- [P3] The Coach explanation truncates after one line at the 402 CSS-pixel viewport. The task title and both controls remain complete; the full explanation is available through `Why?`.
- [P3] Synthetic profiles use the canonical initials fallback rather than the source's decorative gradient avatar treatment. This is truthful production behavior because the fixture has no profile image asset.

The source's persistent Setup/Live/Report rail and repeated `Room` heading are intentionally superseded by the approved product direction. A running event or rehearsal is phase-locked to Live, and Room is named once by the workspace selector. Setup and Report remain reachable in rehearsal lifecycle states without consuming live runtime space.

## Required fidelity surfaces

- Fonts and typography: production Host display and UI voices are preserved. The event title is compact at normal scale, reflows without truncation at 2x text, task copy uses a two-line ceiling, and control labels retain practical optical weight.
- Spacing and layout rhythm: the removed phase rail returns vertical space. The selected-person action is promoted ahead of the map and stays inline at the standard phone width; secondary confirm/release actions move to the lower overflow so the name no longer wraps.
- Colors and visual tokens: rehearsal coral is confined to the practice boundary and Coach state. Placement, confirmation, open-seat, unavailable, surface, border, and selected-workspace states use canonical semantic tokens in both themes.
- Image quality and asset fidelity: there are no substituted handcrafted SVGs, emoji, CSS drawings, or fake profile images. The physical layout is the production code-native Room map, and missing profile images use the production initials fallback.
- Copy and content: event identity, `REHEARSAL`, `Synthetic guests`, virtual time, Now/Guests/Room, capacity, placement metrics, selected guest, move action, scope, table labels, and Coach task are present and coherent.
- Icons and affordances: canonical Catch icon assets are used for back, guests, time, Room, Coach, unavailable units, and overflow. Selected pills, buttons, and menus retain visible hit areas and state contrast.
- Responsiveness and accessibility: light/dark 402 x 874 CSS captures pass without overflow. A 2x text-scale capture reflows the title, rehearsal band, tabs, and metrics, and collapses Coach by default to preserve workspace access.

## Full-view and focused comparison evidence

- Full view: source and final normalized implementation were opened together. Both preserve event identity, a distinct rehearsal boundary, virtual clock, three-part live workspace, placement summary, six-table topology, selected guest action, and fixed Coach guidance.
- Focused Room region: the final card keeps Maya Shah, assignment state, current table, `Move to Table 4`, scope, and overflow actions readable before the same canonical map used on event day. The map retains row, table, court, and zone layout semantics rather than flattening every event into the mockup's six round tables.
- Focused responsive region: the 2x text-scale light/dark capture was inspected for title, rehearsal band, workspace labels, metric reflow, and Coach obstruction. No render overflow remains.

## Comparison history

1. Earlier implementation evidence was blocked because Room placement was read-only. The persisted rehearsal-only, revision-fenced spatial mutation and canonical runtime adapter added preview, move, confirm, and release behavior.
2. The first modernization comparison found a P2 live-shell hierarchy issue: the phase rail and repeated Room title consumed scarce runtime space. Both were removed while rehearsal lifecycle access remained available outside the running state.
3. The 2x text-scale pass found a P2 truncated title and a render overflow. The accessible header now uses a smaller fully scaled UI title, supports three lines, reserves measured height, and captures cleanly.
4. The first final-density pass found P2 density drift: Maya's name wrapped and the Coach task title truncated. The selected card now stays inline above 300 local pixels, moves secondary actions beside the scope control, and allows a two-line Coach title.
5. The final light/dark capture and normalized source comparison show the previous P2 findings resolved. Remaining differences are the approved lifecycle hierarchy changes, production data/state differences, or P3 fixture polish.

## Implementation checklist

- [x] Reuse the canonical Event Success runtime for rehearsal.
- [x] Preserve isolated, persisted Room preview/move/confirm/release controls.
- [x] Hide Setup/Live/Report during the live window and remove the duplicate Room heading.
- [x] Keep Now, Guests, and Room as operational workspace controls.
- [x] Make Coach task-aware and responsive without replacing production controls.
- [x] Verify normal-density light/dark and 2x text-scale captures.
- [x] Compare the source and final implementation in the same normalized visual input.

final result: passed
