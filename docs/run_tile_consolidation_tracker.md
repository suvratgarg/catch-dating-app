---
doc_id: run_tile_consolidation_tracker
version: 0.3.0
updated: 2026-05-14
owner: codex
status: completed
---

# Run Tile Consolidation Tracker

## Goal

Create one run-tile catalog that can render run cards consistently across
Dashboard, Recommendations, Map view, Calendar, Saved runs, and Run club detail
without hardcoded content heights or widget-local product logic.

## Surface Rules

- Dashboard upcoming hero: booked future runs. Whole tile opens run detail.
  Show booked state, countdown/date/time, meeting point, distance/pace, roster
  count, and carousel position.
- Dashboard recommendations: unbooked eligible future runs. Whole tile opens run
  detail. Show recommendation reason, club, time, meeting point, distance, pace,
  price, and signup count.
- Map nearby runs: mixed joined, saved, and recommended future runs. Tile tap
  selects/recenters the map; the explicit View run button opens detail. Show
  relationship status, club if known, time, location, distance, pace, price,
  signup count, and no-pin state when needed.
- Calendar: planned runs only: joined runs plus future saved runs. Show club
  name because this is a global surface, plus JOINED/SAVED/PAST state.
- Saved runs: saved run list. Show club name, saved/past state, time/location,
  distance, pace, price, and signup count.
- Run club detail schedule: club context is already known. Omit club name and
  show compact schedule facts. Whole tile opens run detail.

## Implementation Queue

1. [x] Add shared `RunTileData`, status mapping, and tile variants under
   `lib/runs/presentation/widgets/run_tiles/`.
2. [x] Replace `RunAgendaRunCard` internals with the agenda tile while preserving
   its public tap API for existing tests/routes.
3. [x] Add a club-name lookup provider so Calendar, Saved runs, and Map can display
   club names without adding new denormalized fields to `runs`.
4. [x] Replace Dashboard recommendation cards with the shared rail tile.
5. [x] Replace Dashboard upcoming hero card internals with the shared hero tile.
6. [x] Replace Map sheet chips with the shared map tile and relationship-aware map
   item model.
7. [x] Remove or deprecate the obsolete generic `RunCard` once production usage is
   fully migrated.
8. [x] Update widget catalog and audit registry, then run focused tests, analyzer,
   and widget cleanup scanner.

## Verification Log

- `flutter analyze --no-fatal-infos` on the touched run tile, dashboard,
  calendar, saved-runs, and map files passed before tests.
- `flutter test test/runs/runs_widgets_test.dart test/runs/run_map_view_model_test.dart test/runs/run_map_screen_test.dart test/runs/saved_runs_screen_test.dart test/calendar/calendar_screen_test.dart test/dashboard/next_run_hero_test.dart` passed after adding club-name lookup test fakes and relationship-state assertions.
- `flutter test test/dashboard/dashboard_screen_test.dart test/dashboard/next_run_hero_test.dart` passed after updating the dashboard recommendation assertion to the shared compact distance label.
- `flutter test` passed: 729 tests.
- `flutter analyze --no-fatal-infos` on the focused run tile, dashboard, map,
  calendar, saved-runs, routing, and create-run test/code set passed with no
  issues.
- `bash tool/widget_cleanup_scan.sh` passed as a triage scan. Remaining matches
  are existing broad spacing/decorated-surface backlog plus expected new hits for
  the feature-owned `runClubNameLookupProvider`, the horizontal dashboard hero
  `GestureDetector`, and decorative internals inside the shared run tile catalog.
- `dart tool/audit_registry.dart refresh` refreshed 736 file entries.
- `dart tool/audit_registry.dart mark-pass --pass 2026-05-14-run-tile-catalog ...`
  stamped 32 touched paths.
- `dart tool/audit_registry.dart report` completed after the stamp.

## Open Notes

- No Firestore data migration is expected for the first pass. Club labels can be
  joined at view-model/provider seams from `runClubId`.
- Tiles should display relationship state and route to detail; booking,
  waitlist, cancellation, attendance, and eligibility mutations remain owned by
  run detail and host tools.
- The generic `lib/core/widgets/run_card.dart` has been removed after migrating
  production run-card usage to the shared run tile variants.
