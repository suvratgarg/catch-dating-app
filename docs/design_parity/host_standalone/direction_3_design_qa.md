# Direction 3 Control Room design QA

Date: 2026-08-11

## Compared evidence

- hierarchy source: `docs/design_parity/host_standalone/control_room_quiet_command_console.png`
- production capture: `docs/design_parity/host_standalone/control_room_direction_3_flutter.png`
- large-text capture: `docs/design_parity/host_standalone/control_room_direction_3_flutter_text_scale_2.png`
- deterministic capture id: `host_live_console`
- production viewport: iPhone 17 Pro catalog device, 402x874 with safe areas
- accessibility viewport: same device at text scale 2.0

The source and final production capture were opened together in one comparison
input after the final roster-agnostic fixture and activity pigment were applied.

## Hierarchy and fidelity

- The selected dark current-beat stage, high-contrast semantic headline, short
  Host instruction, next beat, paper supporting plane and single pigment action
  are preserved.
- Canonical Host Manage back navigation, event identity and section navigation
  remain intact rather than creating a parallel Run route.
- Guests and Help & fallback are flat divider-separated rows with canonical
  icons and working destinations. The full roster does not precede the current
  beat.
- The generated study's numbered rail, duplicate readiness block, decorative
  icon boxes, gradient and team-assignment assumptions were intentionally
  removed after adversarial review. Operational counts live once on Guests.
- The pinned `CatchBottomAction` remains reachable at standard and text scale
  2.0. At constrained height, the stage scrolls before status or task copy is
  clipped.

## Product and state truth

- The capture fixture contains 24 imported `eventAttendees`, 18 checked in,
  zero `eventParticipations`, and no required Consumer profiles.
- The production baseline exposes acknowledged, pending and failed persistence.
  Offline pending, conflict, lock, pause and true undo are not presented as
  functional production controls.
- Previous remains Previous. Immediate duplicate step actions are action-keyed,
  pending guarded and debounced; a failed write keeps the current plan state.
- Primary and final-step labels state their consequence, and the action uses the
  event activity pigment with paper text.

## Responsive and accessibility review

- Standard phone: current beat, instruction, next beat, Guests, recovery and
  the primary action are visible without requiring the roster to load.
- Text scale 2.0: no capture overflow or clipped action; content scrolls while
  the action stays pinned.
- Status includes text and an icon, activity pigment is not the only signal,
  and status changes use a semantic live region.
- Long event and step titles have deterministic truncation or reflow rules;
  interactive targets use canonical Catch controls.

## Verification evidence

- focused external-only roster and 390x812 first-viewport widget test: passed
- focused action effect and double-tap test: passed
- focused Host Manage Live-to-Guests integration test: passed
- deterministic standard and text-scale-2 captures: passed
- source and capture visual comparison: no unresolved P0, P1 or P2 mismatch

final result: passed
