# Dress rehearsal runtime parity design QA

- Source visual truth: `/Users/suvratgarg/.codex/generated_images/01a01faf-d9ef-75f0-b23f-06b9bbd2a047/exec-8067de10-a8ed-4c10-b203-360565d2a31c.png`
- Implementation, Room light: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01faf-d9ef-75f0-b23f-06b9bbd2a047/dress_rehearsal_runtime_room_light.png`
- Implementation, Room dark: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01faf-d9ef-75f0-b23f-06b9bbd2a047/dress_rehearsal_runtime_room_dark.png`
- Implementation, Practice tools light: `/Users/suvratgarg/.codex/visualizations/2026/08/20/01a01faf-d9ef-75f0-b23f-06b9bbd2a047/dress_rehearsal_practice_tools_light.png`
- State: running late-arrival scenario, canonical Host Live > Room workspace, 24 synthetic guests, 6 tables, virtual time 7:42 PM.
- Source pixels: 852 x 1846. The source is treated as an approximately 2x-density 426 x 923 CSS reference.
- Implementation pixels/CSS viewport: 402 x 874 at deviceScaleFactor 1 and capture pixel ratio 1.
- Density normalization: the two full views were inspected together at their full aspect ratios. Exact pixel-overlay comparison was not used because the source and canonical iPhone 17 Pro capture differ by 24 CSS pixels in width and 49 CSS pixels in height.

## Findings

- [P1] Rehearsal Room placement is not yet a persisted rehearsal mutation.
  - Location: Host Live > Room, selected synthetic guest controls.
  - Evidence: the source shows Maya selected with `Move to Table 4`; the implementation intentionally renders the real Room map read-only because the existing rehearsal actor contract does not persist `layoutUnitId` or `confirmedLayoutUnitId` mutations.
  - Impact: hosts can learn where Room lives and how its real topology reads, but cannot yet complete the source's placement task without risking a UI-only move that disappears on the next session refresh.
  - Fix: add a session-bound, revision-checked rehearsal spatial-placement action; project its persisted actor placement fields back into canonical assignments; then enable the production `onPreviewSpatial`, `onReassignSpatial`, confirm, and release callbacks.

- [P3] Synthetic profiles use the canonical initials fallback instead of the source's full avatar treatment.
  - Location: Room table seats.
  - Evidence: the source uses colored photo-like avatars; the implementation uses the real runtime's no-photo initials fallback because rehearsal actors currently contain no image projection.
  - Impact: the map is truthful but visually less lifelike than the target.
  - Follow-up: add safe synthetic avatar assets to the rehearsal projection rather than drawing or inventing avatar art in the Room widget.

## Required fidelity surfaces

- Fonts and typography: the implementation uses the current production Host runtime typography rather than the mock's older/larger editorial treatment. This is intentional runtime parity. Coach title wrapping was corrected in pass 2 by using the synthetic guest's first name and allowing two body lines.
- Spacing and layout rhythm: the source is roomier because its normalized viewport is larger. The production runtime remains legible at 402 x 874; persistent controls do not horizontally overflow, and Room content remains scrollable above the Coach dock.
- Colors and visual tokens: rehearsal coral is confined to the practice band and Coach task state. The underlying runtime stays on canonical semantic light/dark tokens.
- Image quality and asset fidelity: no handcrafted or fake raster/vector asset was substituted. Canonical initials are used until the rehearsal actor contract owns safe synthetic avatars.
- Copy and content: `REHEARSAL`, `Synthetic guests`, virtual time, production Setup/Live/Report and Now/Guests/Room labels, Coach task, and Practice tools are all explicit. The production Room summary reports 23 placed and 3 unconfirmed because `placed` means every assignment with a layout unit; the source's 20 placed appears to use `placed` as confirmed, so production semantics are retained.

## Focused evidence

- Header/band: verified event identity, mode boundary, virtual clock, production tab hierarchy, and overflow tool access in both light and dark captures.
- Room/Coach: verified six-table topology, confirmed/unconfirmed rings, late-arrival Coach task, button fit, and scroll boundary. The missing persisted placement control is the blocking difference.
- Practice tools: verified the sheet opens over the runtime and exposes frozen setup, live companion QR/link controls, virtual event controls below the fold, and deterministic replay tools through scrolling.

## Comparison history

1. Pass 1 found truncated Coach guidance and a two-line full-name objective at 402 px.
2. The Coach now uses the synthetic guest's first name and permits two guidance lines.
3. Pass 2 confirms the full sentence is visible without horizontal overflow. The persisted Room placement action remains the P1 blocker.

## Implementation checklist

1. Add revision-checked rehearsal spatial placement to the callable and Firestore contracts.
2. Persist and project current-round and pinned placement state.
3. Enable the canonical Room callbacks only when the mutation is available.
4. Add widget, controller, callable, and capture coverage for move, confirm, release, stale-revision, reset, and fork behavior.
5. Re-run equal-state Room capture comparison and change `final result` only after the source interaction can complete truthfully.

final result: blocked
