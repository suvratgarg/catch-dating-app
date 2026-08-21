# Dress rehearsal Room runtime design QA

- Source visual truth: `/Users/suvratgarg/.codex/generated_images/01a01faf-d9ef-75f0-b23f-06b9bbd2a047/exec-8067de10-a8ed-4c10-b203-360565d2a31c.png`
- Implementation, light: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01faf-d9ef-75f0-b23f-06b9bbd2a047/next-slice/host_event_rehearsal_runtime_room/light.png`
- Implementation, dark: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01faf-d9ef-75f0-b23f-06b9bbd2a047/next-slice/host_event_rehearsal_runtime_room/dark.png`
- State: running late-arrival scenario, canonical Host Live > Room workspace, 24 synthetic guests, six tables, virtual time 7:42 PM.
- Source pixels: 852 x 1846, treated as an approximately 2x 426 x 923 CSS reference.
- Implementation pixels: 1206 x 2622 from a 402 x 874 CSS viewport at capture ratio 3.
- Density normalization: both full views were opened together and compared at equivalent aspect ratio. Exact overlay was not used because the source viewport is 24 CSS pixels wider and 49 CSS pixels taller.

## Findings

- No actionable P0, P1, or P2 visual mismatch remains for this slice.
- [P3] Synthetic profiles use the canonical initials fallback rather than the source's colored avatar treatment. This remains truthful because rehearsal actors do not own image assets; no fake avatar art was introduced.

The source's persistent Setup/Live/Report rail and repeated `Room` heading are intentionally superseded by the user's latest product direction. The implementation phase-locks the running rehearsal to Live, removes the global phase rail, and uses the selected Room workspace label as the sole heading. These are accepted product corrections, not design drift.

## Required fidelity surfaces

- Fonts and typography: current production Host typography is used consistently. Hierarchy, weights, wrapping, and compact labels remain readable at 402 CSS pixels.
- Spacing and layout rhythm: the removed phase rail returns meaningful vertical space. Capacity, metrics, six-table map, legend, and Coach dock remain aligned and scroll safely within the canonical runtime.
- Colors and visual tokens: rehearsal coral is limited to the practice boundary and Coach state. Placement, confirmation, open-seat, and unavailable states use canonical semantic tokens in light and dark themes.
- Image quality and asset fidelity: there are no substituted handcrafted SVGs, CSS drawings, or placeholder images. The Room visualization is the production code-native map, and people without synthetic assets use the production initials fallback.
- Copy and content: `REHEARSAL`, `Synthetic guests`, virtual time, Now/Guests/Room, capacity, placement metrics, table labels, legend, and Coach guidance are present. Setup and Report remain reachable through rehearsal lifecycle transitions rather than persistent tabs.

## Full-view and focused comparison evidence

- Full view: the implementation preserves the reference's event identity, explicit rehearsal boundary, virtual clock, three-part live workspace, six-table topology, state legend, and Coach dock while applying the two requested hierarchy corrections.
- Focused Room region: table occupancy now derives from persisted rehearsal `layoutUnitId` and `confirmedLayoutUnitId` fields. The canonical selected-person controls support preview, current-round or pinned move, confirmation, and release; focused TypeScript and Flutter tests cover the persistence semantics and interaction seam.
- No additional crop was required because all high-risk details—navigation hierarchy, Room summary, table states, legend, and persistent Coach controls—are readable in the full implementation capture.

## Comparison history

1. The previous pass was blocked because Room placement was read-only and the source's `Move to Table 4` task could not persist truthfully.
2. This pass added a rehearsal-only, revision-fenced and idempotent spatial mutation; actor placement now projects back into the canonical Room map, including current-round, pinned, confirm, and release semantics.
3. The same pass removed the event-phase rail during the live window and removed the redundant Room heading, then recaptured light and dark states. The post-fix comparison has no actionable P0/P1/P2 finding.

## Implementation checklist

- [x] Persist Room placement only in isolated rehearsal collections.
- [x] Project persisted placement into the canonical Host runtime.
- [x] Enable preview, move, confirm, and release callbacks.
- [x] Hide Setup/Live/Report during the actual live window.
- [x] Remove the repeated Room title.
- [x] Verify light and dark captures against the reference.

final result: passed
