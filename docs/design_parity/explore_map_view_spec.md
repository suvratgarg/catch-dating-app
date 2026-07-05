---
doc_id: explore_map_view_spec
version: 1.0.0
updated: 2026-07-05
owner: design_parity_review
status: ready-for-implementation
---

# Explore Map View — Consolidation + Implementation Spec

Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`
Design SoT: `~/Downloads/Catch Design System (2)/` (the 2026-06 reorg round).

## Why this spec exists

The map feature accumulated drift across three design rounds: an early
"three-snap shared canvas + peek rail" direction (now archived in the DS
under `explorations/archived-templates/explore-redesign/`), the ratified
2026-06 direction, and a partial implementation. The ratified direction, in
the DS's own words:

> "the map answers 'where, relative to my life?' — it doesn't browse. So:
> drop the three-snap shared canvas…; map becomes a clean full-screen mode
> behind the pill. Pins carry activity color, the tappable distance ring
> stays."

and from `components/events/DateTicket/DateTicket.prompt.md`:

> "List form of the ticket metaphor… Use in date-grouped rails and **the
> map's selected-event card**."

The app already has the ratified skeleton (`ExploreMapScreen` → full-screen
`EventMapView`, activity pins, tappable distance ring, back float). What is
missing is the selection step (pin tap currently navigates straight to
detail), and what is left over is the dropped peek-rail direction's
machinery. All review decisions below are made — do not re-litigate;
escalate in receipts only where instructed.

## Required workflow

Same as prior specs: `git status --short` first, read `AGENTS.md`; commit
per part with pathspecs; sequential Flutter runs; per-part focused tests +
analyzer on touched files; widgetbook hand-edits + regen; finish with full
`flutter analyze --no-fatal-infos`, `node tool/agent/check_agent_readiness.mjs`,
`widget_catalog.md` changelog + version + `doc_versions.json` for contract
changes, and a `passes.jsonl` stamp. Never edit `packages/catch_ui_lints`.

---

## Part A — Retire the dropped-direction widgets

Verify each claim with `rg` before deleting; if any widget has production
users this spec doesn't list, STOP on that item and record an escalation in
the receipt instead of forcing.

1. **Peek-rail system** (`lib/explore/presentation/widgets/explore_peek_rail.dart`):
   `ExploreMapSheetLead`, `ExploreSelectedEventLead`, `ExploreEventTicketCard`,
   and their file-local support widgets. No screen mounts them
   (`ExploreMapScreen` does not import the file; remaining references are the
   `explore.dart` barrel and state types in `explore_screen_state.dart`).
   Delete the widgets + file; keep any state/view-model types that other
   code consumes by MOVING them into `explore_screen_state.dart` (e.g.
   `ExploreMapEventTicketState` if still referenced — check; if nothing else
   references a moved type, delete it too). Update the barrel + widgetbook.
2. **`CatchEventCard.spotlight`** (`lib/core/widgets/catch_event_activity_cards.dart`):
   its only production consumer is the peek rail. Delete the variant, its
   fields, and widgetbook states. (`CatchEventCard.ticket` stays — it is the
   DS `EventTicket`, used by the dashboard recommended rail.)
3. **`CatchEventCard.compact`**: zero production users (widgetbook only).
   The "condensed map card" role belongs to the DateTicket per the DS.
   Delete the variant + widgetbook states.
4. **`EventCompactRow`** (`lib/events/shared/event_tiles/event_compact_row.dart`):
   zero production users. Delete the widget; `EventCompactDatePill` in the
   same file — check users; if its only consumer was `EventCompactRow`,
   delete it too, otherwise leave and note in the receipt.
5. Ledger: append keep/delete outcomes for these to
   `docs/design_parity/widget_consolidation/decisions.json` following its
   existing entry schema (`decidedBy: "claude-review -> codex"`, date,
   status `executed-map-spec`), so the consolidation ledger stays the
   record of widget-count changes.

Expected: −5 to −7 public widgets, no visual change anywhere (nothing
deleted is mounted).

---

## Part B — Implement the map view per the ratified design

### Target anatomy (all states)

```
ExploreMapScreen (route, owns selection)
├── EventMapView (full-screen; loading/error/empty states as today)
│     └── EventPinsMap (pins + distance ring + camera)
├── Back float (top-left, as today)
└── Selected-event card (NEW — bottom overlay, only when a pin is selected)
      └── EventDateRailCard (the DS DateTicket)
```

### B1. Split selection from navigation

`EventMapView._selectEvent` currently sets `_selectedEventId` AND calls
`widget.onEventSelected` (which `ExploreMapScreen` uses to navigate
immediately). Change the contract:

- `EventMapView.onEventSelected` fires on pin tap with the tapped event —
  callers decide what to do; it no longer implies navigation.
- Add `EventMapView.onSelectionCleared` (VoidCallback?) fired when the map
  background is tapped while something is selected. If `EventPinsMap` has no
  background-tap callback today, add one (flutter_map's `onTap` on the map
  layer); pin taps must not double-fire it.
- Selection state stays where it lives today; `initialSelectedEventId`
  behavior (deep-link: preselect + center via `selectedEventCenter`) is
  preserved and now ALSO shows the card on first frame.
- `lib/events/presentation/event_map_screen.dart`'s other consumer
  (`EventLocationMapScreen` or any other user of `EventMapView`) must be
  checked: preserve its current navigate-on-tap behavior at ITS call site by
  keeping its `onEventSelected` handler unchanged.

### B2. The selected-event card = `EventDateRailCard`

In `ExploreMapScreen`, when an event is selected render a bottom overlay:

- Position: `Positioned(left/right: 0, bottom: 0)` → `SafeArea(top: false)`
  → padding `CatchInsets.pageBody.copyWith(top: 0)` (screen gutter, no
  extra top).
- Widget: `EventDateRailCard(event:, kicker:, onTap:, heroTag:)` with:
  - `kicker`: `'{CLUB NAME} · {distance}'` when the feed item carries
    `distanceFromUserLabel`, else the club name alone — mirror how the
    explore feed composes DateTicket kickers today (check
    `explore_event_rows.dart` and reuse its kicker helper if one exists;
    extract it rather than duplicating the format).
  - `heroTag`: `eventTicketHeroTag(event.id, 'map')` so card → detail gets
    the ticket hero transition.
  - `onTap`: the existing `_openEvent` (unchanged navigation, now one step
    later).
- The card floats over the map: give it the overlay treatment the card
  supports (its own surface + `CatchElevation.overlay`-class shadow; if
  `EventDateRailCard` exposes a notch/surface background param, set it so
  the perforation notches read against the map, matching the DS `notchBg`
  contract). If the card has no such param, add ONE optional param
  mirroring the DS DateTicket `notchBg` — do not fork the widget.
- Motion: animate card in/out with the standard motion tokens
  (`CatchMotion.fast` + standard curve; `AnimatedSwitcher` or
  slide-from-bottom — match whatever pattern `CatchBottomDock`/sheets use;
  respect `MediaQuery.disableAnimations`).
- Selecting a different pin swaps the card content (same animation).
  Background tap clears selection and dismisses the card.

### B3. Pin parity with the DS MapPin contract

DS `components/activity/MapPin`: resting pin 26, selected 38 with an "ink
flag" carrying a mono data label (`'SOCIAL RUN · 6:30 AM'` style — activity
label + start time, uppercase mono). Compare `lib/events/shared/map_pin_tile.dart`:

- Verify resting/selected extents against 26/38 (token-ize any raw values
  encountered — D1 rules apply; escalate token names if none exist).
- Verify the selected flag renders ink surface + mono label; align the
  label format to `'{ACTIVITY} · {TIME}'` uppercase if it differs.
- Pins remain the only chroma on the canvas — no new colored chrome.

### B4. States

- Loading/error/no-mapped-events/no-pins states in `EventMapView` are
  already correct — do not change their copy or composition.
- Selected state must survive a feed refresh: if the selected event
  disappears from the refreshed view model, clear selection gracefully
  (no crash, card animates out).

### B5. Tests + widgetbook

- Widget tests (new file or extend the map tests): pin tap shows the card
  and does NOT navigate; card tap navigates to event detail with the map
  hero tag; background tap dismisses; `initialSelectedEventId` shows the
  card on first frame; selected event vanishing from the view model clears
  selection.
- Widgetbook: map screen states — content, content+selected (card visible),
  the two empties; delete the retired peek-rail/spotlight/compact states.
- Run the explore + events focused suites and the strict capture catalog if
  it covers the map.

### Acceptance criteria

- Pin tap = select (flagged pin + DateTicket card); card tap = navigate
  with hero transition; background tap = dismiss. No peek rail, no
  spotlight card, anywhere.
- The card is byte-for-byte the same `EventDateRailCard` the feed uses
  (modulo the notch-background param) — one ticket system, per the DS.
- Widget count net negative (Part A) even after Part B adds zero new
  widgets (the card is reuse; only params/callbacks are added).
- All standard gates green; receipts + ledger entries recorded.

### Out of scope (recorded, do not do here)

- Dashboard `CoverStory` moment (DS composes CoverStory on catch-dashboard;
  app doesn't — separate review item).
- Club schedule's `EventAgendaTile` vs the DS club-detail composing
  `DateTicket` — belongs to the upcoming clubs design-parity exercise.
- The companion ticket "tear" animation (design gap, companion exercise).
