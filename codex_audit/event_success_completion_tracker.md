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
- [x] Connect attendee wingman request state to host/report surfaces.
- [x] Refactor setup around product layers and saved event structure config.
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
- Post-event swiping remains in the normal swipe/match pipeline. Event-success
  owns explicit wingman requests and host feedback/reporting only.
- Attendee companion is intentionally hidden until a saved
  `eventSuccessPlans/{eventId}` document exists. Do not fall back to generated
  defaults on attendee routes; the host setup screen may preview defaults before
  saving.
- Current event-success tools are grouped under product layers instead of
  treated as independent features: event structure, roster/attendance,
  assignments, compatibility, live reveal, conversation prompts, post-event
  matching, host coach, and safety. Host setup now persists
  `structureConfig` with unit type, unit size, optional unit count, rotation
  cadence, and reveal countdown.
- V1 micro-pods and guided rotations are server-owned, block-aware, opt-out
  aware, and prioritize interested-in pairings. Guided rotations now use the
  saved structure cadence when present, falling back to 15 minutes for legacy
  plans. Hosts can override generated rotations through a server-owned callable;
  block, opt-out, eligibility, duplicate, and duration constraints remain
  non-overridable. Scheduler balancing favors compatible underexposed attendees
  before already-served attendees continue consuming all remaining
  mutual-interest pairs.
- Live reveal is host-owned state on `eventSuccessPlans/{eventId}`:
  `revealStatus`, `activeRevealRoundIndex`, `revealStartedAt`, and
  `revealEndsAt`. Hosts can drop the saved countdown, reveal a round instantly,
  or reset the reveal flow. Attendee companion cards for live-reveal formats
  hide pod/rotation details until the current round is unlocked. V1 is a
  synchronized facilitation layer, not hard secrecy; assignment docs remain
  readable to the assigned attendee under the existing event-success read
  policy. True anti-snooping secrecy would require just-in-time assignment
  publication or a separate draft/published assignment contract.
- Host-assisted wingman requests are explicit consent documents, not private
  swipe leakage. Attendees can ask the host for help with one
  checked-in target during the live event; hosts see consented active requests
  and can use rotation overrides or in-room facilitation. The target is not
  notified by this surface.
- The conversation layer compresses live prompts and post-match openers into
  one production surface. V1 cue decks are derived from the saved playbook,
  active run-of-show step, and event format, so there is no extra questionnaire
  persistence or private-answer visibility risk.
- Compatibility questionnaire answers are event-scoped, attendee-owned, and
  host-private. The default product mode uses answers for clues/explanations
  only. Hosts can explicitly turn on `compatibilityAffectsRanking`, allowing
  the server generator to boost already-eligible guided-rotation pairs after
  interested-in scoring, blocks, eligibility, and opt-outs have been enforced.
- Host analytics stays inside the existing event-success read model for V1. The
  report and coach now use feedback response, assignment coverage, assignment
  opt-outs, and active wingman requests from the already-loaded roster,
  assignment, preference, request, and feedback streams instead of creating a
  separate analytics collection.
- Manual QA now has a dev/staging split-screen harness at
  `/dev/event-success-manual-qa`, reachable from Settings -> Development. It
  renders the production host panel and attendee companion from the same fixture
  state across social run, racket pair, quiz team, and mixer reveal scenarios.
  Use `docs/event_success_manual_qa.md` as the checklist. Write-path QA still
  requires a real dev/staging event.
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
- Guided rotations pass 2026-05-21:
  `flutter analyze lib/event_success test/event_success`;
  `flutter test test/event_success/event_success_assignment_test.dart test/event_success/event_success_runtime_test.dart test/event_success/event_success_repository_test.dart test/event_success/event_success_live_screens_test.dart`;
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node --test functions/lib/eventSuccess/*.test.js`;
  `npm --prefix functions test`;
  `firebase emulators:exec --only firestore "node --test --test-concurrency=1 functions/test/firestore.rules.test.cjs"`;
  `bash tool/widget_cleanup_scan.sh`;
  `git diff --check`;
  `dart tool/audit_registry.dart refresh`;
  `dart tool/audit_registry.dart mark-pass --pass event-success-guided-rotations-2026-05-21 ...`;
  `dart tool/audit_registry.dart report`.
- Host rotation override pass 2026-05-21:
  `node tool/generate_schema_contracts.mjs --check`;
  `node tool/validate_schema_contracts.mjs`;
  `flutter analyze lib/event_success test/event_success`;
  `flutter test test/event_success/event_success_assignment_test.dart test/event_success/event_success_runtime_test.dart test/event_success/event_success_repository_test.dart test/event_success/event_success_live_screens_test.dart`;
  `flutter test test/core/schema_contracts_generated_test.dart`;
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node --test functions/lib/eventSuccess/*.test.js`;
  `npm --prefix functions test`;
  `firebase emulators:exec --only firestore "node --test --test-concurrency=1 functions/test/firestore.rules.test.cjs"`;
  `bash tool/widget_cleanup_scan.sh`;
  `git diff --check`;
  `dart tool/audit_registry.dart refresh`;
  `dart tool/audit_registry.dart mark-pass --pass event-success-rotation-overrides-2026-05-21 ...`;
  `dart tool/audit_registry.dart report`.
- Edit-after-generate V1 boundary 2026-05-21:
  `node tool/generate_schema_contracts.mjs`;
  `node tool/generate_schema_contracts.mjs --check`;
  `node tool/validate_schema_contracts.mjs`;
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node --test functions/lib/eventSuccess/*.test.js`;
  `flutter test test/core/schema_contracts_generated_test.dart`;
  `flutter analyze lib/event_success test/event_success`;
  `flutter test test/event_success/event_success_assignment_test.dart test/event_success/event_success_runtime_test.dart test/event_success/event_success_repository_test.dart test/event_success/event_success_live_screens_test.dart`;
  `npm --prefix functions test`;
  `flutter test test/event_success/event_success_live_screens_test.dart`
  after adding the edit-after-generate UI guard;
  `flutter test test/event_success/event_success_live_screens_test.dart`
  after adding the host-edited rotations badge.
- Fairness-aware rotation balancing 2026-05-21:
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node --test functions/lib/eventSuccess/*.test.js`.
- Architecture layer and structure config reset 2026-05-21:
  `dart run build_runner build --delete-conflicting-outputs`;
  `flutter analyze lib/event_success test/event_success`;
  `flutter test test/event_success/event_success_playbooks_test.dart test/event_success/event_success_repository_test.dart test/event_success/event_success_runtime_test.dart test/event_success/event_success_assignment_test.dart`;
  `flutter test test/event_success/event_success_live_screens_test.dart test/event_success/event_success_lab_screen_test.dart test/event_success/event_success_event_preview_test.dart`;
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node --test functions/lib/eventSuccess/*.test.js`;
  `firebase emulators:exec --project demo-catch-rules --only firestore,storage "npm --prefix functions run test:rules"`.
- Live reveal layer 2026-05-21:
  Matchbox research source: https://match.box/;
  `dart run build_runner build --delete-conflicting-outputs`;
  `flutter analyze lib/event_success test/event_success`;
  `flutter test test/event_success`;
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `npm --prefix functions test`;
  `node --test functions/lib/eventSuccess/*.test.js`;
  `firebase emulators:exec --project demo-catch-rules --only firestore,storage "npm --prefix functions run test:rules"`;
  `bash tool/widget_cleanup_scan.sh`;
  `git diff --check`;
  `dart tool/audit_registry.dart mark-pass --pass event-success-live-reveal-2026-05-21 ...`;
  `dart tool/audit_registry.dart report`.
- Host-assisted wingman request layer 2026-05-21:
  `dart run build_runner build --delete-conflicting-outputs`;
  `dart format lib/event_success/data/event_success_repository.dart lib/event_success/domain/event_success_runtime.dart lib/event_success/domain/event_success_playbooks.dart lib/event_success/domain/event_success_wingman_request.dart lib/event_success/event_success.dart lib/event_success/presentation/event_success_companion_screen.dart lib/event_success/presentation/event_success_controller.dart lib/event_success/presentation/event_success_defaults_panel.dart lib/event_success/presentation/event_success_host_screen.dart test/event_success/event_success_repository_test.dart test/event_success/event_success_live_screens_test.dart`;
  `flutter analyze lib/event_success test/event_success`;
  `flutter test test/event_success/event_success_repository_test.dart test/event_success/event_success_runtime_test.dart test/event_success/event_success_live_screens_test.dart`;
  `flutter test test/event_success`;
  `firebase emulators:exec --project demo-catch-rules --only firestore,storage "npm --prefix functions run test:rules"`;
  `bash tool/widget_cleanup_scan.sh`;
  `git diff --check`;
  `dart tool/audit_registry.dart mark-pass --pass event-success-wingman-requests-2026-05-21 ...`;
  `dart tool/audit_registry.dart refresh`;
  `dart tool/audit_registry.dart report`.
- Conversation cue layer 2026-05-21:
  `dart format lib/event_success/domain/event_success_conversation_cue.dart lib/event_success/domain/event_success_runtime.dart lib/event_success/event_success.dart lib/event_success/presentation/event_success_feature_blocks.dart lib/event_success/presentation/event_success_companion_screen.dart lib/event_success/presentation/event_success_host_screen.dart test/event_success/event_success_runtime_test.dart test/event_success/event_success_live_screens_test.dart`;
  `flutter analyze lib/event_success test/event_success`;
  `flutter test test/event_success/event_success_runtime_test.dart test/event_success/event_success_live_screens_test.dart`;
  `flutter test test/event_success`;
  `bash tool/widget_cleanup_scan.sh`;
  `git diff --check`;
  `dart tool/audit_registry.dart refresh`;
  `dart tool/audit_registry.dart mark-pass --pass event-success-wingman-query-and-conversation-cues-2026-05-21 ...`;
  `dart tool/audit_registry.dart report`.
- Compatibility questionnaire and optional ranking 2026-05-21:
  `dart run build_runner build --delete-conflicting-outputs`;
  `dart format lib/event_success/domain/event_success_compatibility_response.dart lib/event_success/domain/event_success_feature_state.dart lib/event_success/domain/event_success_plan.dart lib/event_success/domain/event_success_defaults.dart lib/event_success/domain/event_success_runtime.dart lib/event_success/event_success.dart lib/event_success/data/event_success_repository.dart lib/event_success/presentation/event_success_controller.dart lib/event_success/presentation/event_success_companion_screen.dart lib/event_success/presentation/event_success_host_screen.dart lib/event_success/presentation/event_success_live_reveal_card.dart test/event_success/event_success_repository_test.dart test/event_success/event_success_runtime_test.dart test/event_success/event_success_live_screens_test.dart`;
  `flutter analyze lib/event_success test/event_success`;
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `flutter test test/event_success`;
  `node --test functions/lib/eventSuccess/*.test.js`;
  `firebase emulators:exec --project demo-catch-rules --only firestore,storage "npm --prefix functions run test:rules"`;
  `bash tool/widget_cleanup_scan.sh`;
  `git diff --check`.
- Host analytics signal quality 2026-05-21:
  `dart format lib/event_success/domain/event_success_models.dart lib/event_success/domain/event_success_plan.dart lib/event_success/domain/event_success_coach.dart lib/event_success/presentation/event_success_host_screen.dart lib/event_success/presentation/event_success_feature_blocks.dart test/event_success/event_success_playbooks_test.dart test/event_success/event_success_live_screens_test.dart`;
  `flutter analyze lib/event_success test/event_success`;
  `flutter test test/event_success/event_success_playbooks_test.dart test/event_success/event_success_live_screens_test.dart`;
  `flutter test test/event_success`;
  `git diff --check`;
  `bash tool/widget_cleanup_scan.sh`;
  `dart tool/audit_registry.dart refresh`;
  `dart tool/audit_registry.dart mark-pass --pass event-success-host-analytics-signal-quality-2026-05-21 ...`;
  `dart tool/audit_registry.dart report`.
- Manual QA harness 2026-05-21:
  `dart format lib/event_success/presentation/event_success_manual_qa_screen.dart lib/event_success/event_success.dart lib/routing/go_router.dart lib/safety/presentation/settings_keys.dart lib/safety/presentation/settings_screen.dart test/event_success/event_success_manual_qa_screen_test.dart test/safety/settings_screen_test.dart docs/event_success_manual_qa.md`;
  `flutter analyze lib/event_success/presentation/event_success_manual_qa_screen.dart lib/event_success/event_success.dart lib/routing/go_router.dart lib/safety/presentation/settings_keys.dart lib/safety/presentation/settings_screen.dart test/event_success/event_success_manual_qa_screen_test.dart test/safety/settings_screen_test.dart`;
  `flutter test test/event_success/event_success_manual_qa_screen_test.dart test/safety/settings_screen_test.dart`.

## Remaining Watch Items

- The dev/staging event-success lab can keep WIP labels for product review; do
  not treat those as production blockers.
- Before adding another live module, define its privacy, safety, backend
  ownership, and Firestore read/write behavior in the same pass.
- V1 micro-pods and guided rotations are server-owned, block-aware, and
  attendee opt-out aware. Host override edits now exist for generated rounds;
  blank manual schedule creation is intentionally deferred for V1. Richer
  balancing now includes exposure-aware break rotation; future passes can still
  tune cohort-specific targets and questionnaire boost weights after live host
  review.
- Live reveal currently gates details in the app UI but does not make prewritten
  assignment documents cryptographically secret from their assigned attendee.
  If hosts need hard reveal secrecy, publish assignments per round from a
  host-only draft source in a later pass.
- The legacy `distanceKm` and `pace` fields still exist for schema continuity.
  Non-distance formats currently write `distanceKm: 0` and `pace: easy`; fully
  making route metrics optional should be a dedicated schema migration.
