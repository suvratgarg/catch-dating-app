# Event Success Completion Tracker

Status: active implementation tracker for the production event-success rollout.

Purpose: keep the remaining event-success work visible while the feature moves
from live-wired scaffolding to usable host and attendee workflows.

## Current Pass

- [x] Inspect current event-success wiring, policy detail display, and host
  manage integration.
- [x] Expand live host setup beyond module toggles.
- [x] Add user-facing event detail "What to expect" content without extra
  Firestore reads.
- [x] Connect attendee private follow-up state to feedback/report metrics.
- [x] Add targeted widget/domain/repository tests for the finished surfaces.
- [x] Update durable in-development docs and audit registry proof.

## Activity Format Refactor Pass

- [x] Add shared `ActivityKind`, `EventInteractionModel`, and
  `EventFormatSnapshot` taxonomy for event formats and health imports.
- [x] Persist `events/{eventId}.eventFormat` through Flutter DTOs, callable
  schemas, Functions normalization, generated TypeScript, and seed validation.
- [x] Update create-event UI to choose activity type and hide distance/pace for
  non-distance formats while preserving legacy distance storage.
- [x] Refactor weekly health activity from run-only distance summaries to
  generic physical activities with active-minute support.
- [x] Wire event-success playbooks and previews to the shared taxonomy.
- [x] Add targeted taxonomy, health, event-create, draft, formatter, dashboard,
  event-success, widget, and contract tests.

## Implementation Notes

- Keep low-churn listing/detail expectations on the existing event read path.
- Keep high-churn event-success setup and feedback in edge documents.
- Private crush targets remain attendee-private; host reports may show aggregate
  counts only.
- Setup fields that affect attendee expectations should be treated as frozen
  once the event starts.
- Event format is a user-visible snapshot. Treat it like listing copy: changing
  it after signups needs an explicit product decision and likely attendee
  notification.

## Current Pass Proof

- `flutter test test/event_success/event_success_live_screens_test.dart`
- `flutter test test/events/event_detail_widgets_test.dart`
- `flutter analyze --no-fatal-infos lib/event_success/presentation/event_success_controller.dart lib/event_success/presentation/event_success_host_screen.dart lib/event_success/presentation/event_success_companion_screen.dart lib/events/presentation/widgets/event_detail_overview_section.dart test/event_success/event_success_live_screens_test.dart test/events/event_detail_widgets_test.dart`
- `bash tool/widget_cleanup_scan.sh`
- `flutter analyze`
- `npm --prefix functions run lint`
- `npm --prefix functions run build`
- `flutter test test/activity/activity_taxonomy_test.dart test/health_activity/weekly_activity_summary_test.dart test/events/create_event_controller_test.dart test/events/event_formatters_test.dart test/events/event_draft_test.dart test/dashboard/dashboard_full_view_model_test.dart test/event_success/event_success_playbooks_test.dart`
- `flutter test test/dashboard/dashboard_screen_test.dart test/swipes/event_recap_screen_test.dart`
- `flutter test test/events/event_detail_widgets_test.dart test/events/events_widgets_test.dart test/events/create_event_screen_test.dart`
- `./tool/check_data_contract.sh`

## Remaining Watch Items

- The dev/staging event-success lab can keep WIP labels for product review; do
  not treat those as production blockers.
- Before adding another live module, define its privacy, safety, backend
  ownership, and Firestore read/write behavior in the same pass.
- The legacy `distanceKm` and `pace` fields still exist for schema continuity.
  Non-distance formats currently write `distanceKm: 0` and `pace: easy`; fully
  making route metrics optional should be a dedicated schema migration.
