# Event Success Hardening Tracker

Started: 2026-05-21

Scope: `lib/event_success/**`, adjacent event creation flows, Firestore rules,
Functions contracts, seed/demo coverage, and user-facing event-success copy.

## Product Assumptions

- Safety and comfort feedback is Catch-private first. Hosts should not see raw
  safety notes or personally identifying safety details.
- Host reporting should teach the host how to run a better event, not expose
  individual attendee intelligence.
- Compatibility and reveal can be delightful for the right format, but should be
  positioned as conversation context, not romantic certainty or algorithmic
  destiny.
- The attendee-facing language should feel consumer, warm, and human. Avoid
  internal labels such as `event success`, `module`, `ranking`, `scorecard`,
  `structure config`, `compatibility signal`, and `run-of-show` unless the
  reader is a host in an advanced setup context.
- Social runs should stay lightweight. More cinematic reveal/compatibility
  tooling belongs in structured formats such as singles mixers, racket pair
  rotations, dinner tables, and quiz/team events.
- Singles mixer and live reveal are core launch behavior and flagship product
  bets. They should receive high-priority QA, demo coverage, and UX polish.
- Host setup does not need to become a simplistic default-only mode, but it
  must follow progressive disclosure so the first screen feels calm and
  decision-light.
- "Help me meet someone" without a specific selected attendee is not in scope
  for now. Keep it as a later product idea, not a launch requirement.

## Decisions Needed From Suvrat

- [ ] Should a safety/comfort concern always create a Catch-private report, or
  should the attendee explicitly choose between host feedback and safety report?
- [ ] Should hosts ever see free-text attendee notes, or should notes remain
  hidden/summarized until an anonymity threshold is met?
- [ ] Do we need event-level safety reports without a specific target user?
- [x] Is singles mixer/live reveal a core launch bet or a pilot-only format?
  - Answered 2026-05-21: Core launch behavior and flagship feature. Prioritize
    this path highly.
- [x] Should host help support a soft "help me meet someone" request, not only a
  specific-person request?
- [ ] Later idea: revisit soft host-help requests after the launch version of
  specific-person host help is polished.
- [ ] What should the host analytics anonymity threshold be: 3, 5, or dynamic by
  event size?

## P0 Implementation

- [x] Split raw attendee feedback from host-readable coaching data.
  - Done 2026-05-21: Host report now reads `eventSuccessScorecards/{eventId}`;
    raw `eventSuccessFeedback` is owner-private in rules.
- [x] Route safety/comfort concerns into a protected Catch-private safety path.
  - Done 2026-05-21: Safety feedback mirrors into server-owned
    `eventSafetyReports/{feedbackId}` for Catch review.
- [x] Stop hosts from reading `privateNote` and raw safety details.
  - Done 2026-05-21: Hosts can read aggregate scorecards only; raw feedback
    and safety reports are no longer host-readable client surfaces.
- [x] Make event creation and event-success plan creation atomic in the
  `createEvent` callable.
  - Done 2026-05-21: `CreateEventCallablePayload` now accepts
    `eventSuccessDefaults`; Functions creates `eventSuccessPlans/{eventId}` in
    the same transaction as `events/{eventId}` and rejects pre-existing plan
    conflicts before writing the event.
- [x] Add missing schema contracts for event-success edge collections:
  preferences, compatibility responses, wingman requests, assignments, and
  scorecards.
- [x] Add generated validator and Dart registry fixture coverage for the new
  event-success contracts.
  - Done 2026-05-21: Added JSON schemas, generated TypeScript/Dart registry
    entries, valid fixtures, and schema validator tests.
- [x] Move wingman request submit/withdraw writes behind server-owned callables.
  - Done 2026-05-21: Clients now call
    `submitEventSuccessWingmanRequest`/`withdrawEventSuccessWingmanRequest`;
    Firestore rules reject direct client creates and updates.

## P1 Implementation

- [x] Move wingman candidate discovery to a callable so the backend owns
  eligibility, blocks, attendance, and privacy.
  - Done 2026-05-21: `fetchEventSuccessWingmanCandidates` now requires auth,
    live event state, saved host setup, checked-in attendance, dating/cohort
    eligibility, and no block edge before returning public profiles.
- [x] Apply progressive disclosure to host setup so the primary path is calmer
  while advanced controls remain available.
  - Done 2026-05-21: Host setup now shows essentials first and places event
    structure, tool selection, and delivery tuning behind expandable sections.
- [x] Rewrite attendee-facing event-success copy to be human and consumer-grade.
  - Done 2026-05-21: Replaced internal launch-copy leaks across companion, host,
    defaults, live reveal, recommendation reasons, and error-action strings:
    `event success`, `ranking`, `algorithmic suggestions`, `compatibility
    signal`, `assignment layer`, `questionnaire`, `run-of-show`, `scorecard`,
    and `pilot` no longer appear in the primary user-facing paths.
- [x] Add flagship singles mixer/live reveal QA coverage.
  - Done 2026-05-21: Manual QA now includes a Singles mixer scenario and a
    widget test that drives questionnaire, live countdown, and reveal states.

## P2 Implementation

- [x] Decompose oversized presentation files into host, companion, reveal, and
  shared widget slices.
  - Done 2026-05-21: Split the host panel into setup/live/report/override/shared
    part files, split the attendee companion into shared/questionnaire/live-card/
    wingman/feedback part files, and split the live reveal card into host,
    attendee, actions, shared widget, and copy-helper part files. Public import
    points remain stable.
- [x] Add seed/demo coverage for event-success plans, preferences, assignments,
  compatibility responses, wingman requests, feedback, and scorecards.
  - Done 2026-05-21: World seeding now creates deterministic singles-mixer
    live-reveal events plus event-success plan, preference, quick-question,
    assignment, wingman-request, private-feedback, and aggregate scorecard docs.
    Event-success schemas now accept internal demo metadata so seeded docs remain
    cleanup-safe.
- [x] Re-run the full focused verification matrix and stamp the audit registry.
  - Done 2026-05-21: Focused Flutter, Functions, schema, seed dry-run, scanner,
    and diff checks passed. `dart tool/audit_registry.dart mark-pass` stamped
    44 tracked paths for `event-success-hardening-2026-05-21`; newly introduced
    contract files were skipped by the registry because they are not yet tracked
    until a later refresh/staging pass sees them as tracked files.

## Working Notes

- 2026-05-21: Initial hardening plan created. Start with P0 safety/feedback
  boundary because it affects trust, rules, product analytics, and host report
  correctness.
- 2026-05-21: First batch complete. The main new issue discovered during
  verification is that the broader Storage rules suite fails on pre-existing
  Firestore-backed storage lookups; focused Firestore rules pass.
- 2026-05-21: Event creation no longer depends on a client-owned second write
  for the live guide plan. The implementation keeps host editing client-side for
  existing plans, but initial plan creation is server-owned.
- 2026-05-21: Wingman request writes are now server-owned. Candidate discovery
  is still client-side and remains open as a separate eligibility/privacy
  hardening item.
- 2026-05-21: Wingman candidate discovery is now server-owned as well. This
  closes the specific-person host-help privacy gap; the broader product
  question about "help me meet someone" remains a separate UX decision.
- 2026-05-21: Suvrat confirmed singles mixer/live reveal is a flagship launch
  behavior. Manual QA now includes this scenario instead of treating reveal as
  only racket/quiz tooling.
- 2026-05-21: Suvrat does not want soft "help me meet someone" requests for
  launch. Keep it as a later product idea only.
- 2026-05-21: Host setup should use progressive disclosure, not necessarily a
  simplistic default-only mode.
- 2026-05-21: Second copy pass also fixed a host UX contradiction where the
  frozen setup notice said setup could be changed even though the screen was
  already locked.
- 2026-05-21: Smoke demo seed now includes the flagship singles/live-reveal
  surface (`eventSuccessPlans`, preferences, compatibility responses,
  assignments, feedback, wingman requests, and scorecards), so QA can dogfood
  the real data path rather than only the lab preview.
- 2026-05-21: Event-success presentation architecture now has stable public root
  files with smaller implementation parts. This closes the immediate oversized
  host/companion/reveal file concern without changing route imports.

## Verification Log

- 2026-05-21: `node tool/validate_schema_contracts.mjs` passed.
- 2026-05-21: `node tool/generate_schema_contracts.mjs --check` passed.
- 2026-05-21: `npm --prefix functions run build` passed.
- 2026-05-21: `node --test functions/lib/shared/schemaContracts.test.js functions/lib/marketplace/eventSuccessScorecards.test.js` passed.
- 2026-05-21: `flutter test test/core/schema_contracts_generated_test.dart` passed.
- 2026-05-21: `flutter test test/event_success/event_success_live_screens_test.dart` passed.
- 2026-05-21: `flutter analyze lib/event_success lib/events/presentation/widgets/event_policy_step.dart test/event_success test/core/schema_contracts_generated_test.dart` passed.
- 2026-05-21: `firebase emulators:exec --only firestore "node --test --test-concurrency=1 functions/test/firestore.rules.test.cjs"` passed.
- 2026-05-21: Broader `firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"` failed in existing Storage rules tests, while Firestore/event-success tests passed.
- 2026-05-21: `flutter test test/events/create_event_controller_test.dart test/core/callable_dto_contracts_test.dart test/events/event_repository_test.dart test/core/schema_contracts_generated_test.dart` passed.
- 2026-05-21: `flutter analyze lib/events/data/event_callable_dtos.dart lib/events/data/event_repository.dart lib/events/presentation/create_event_controller.dart test/events/create_event_controller_test.dart test/core/callable_dto_contracts_test.dart test/events/events_test_helpers.dart test/events/event_repository_test.dart` passed.
- 2026-05-21: `npm --prefix functions run lint` passed.
- 2026-05-21: `node --test functions/lib/events/mutateEvent.test.js functions/lib/marketplace/eventSuccessScorecards.test.js functions/lib/shared/schemaContracts.test.js` passed.
- 2026-05-21: `node --test functions/lib/eventSuccess/wingmanRequests.test.js functions/lib/events/mutateEvent.test.js functions/lib/marketplace/eventSuccessScorecards.test.js functions/lib/shared/schemaContracts.test.js` passed.
- 2026-05-21: `flutter test test/event_success/event_success_repository_test.dart test/core/schema_contracts_generated_test.dart` passed.
- 2026-05-21: `flutter test test/event_success/event_success_live_screens_test.dart` passed after updating the widget test to exercise the callable-owned wingman path.
- 2026-05-21: Final focused matrix passed:
  `node tool/validate_schema_contracts.mjs`;
  `node tool/generate_schema_contracts.mjs --check`;
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node --test functions/lib/eventSuccess/wingmanRequests.test.js functions/lib/events/mutateEvent.test.js functions/lib/marketplace/eventSuccessScorecards.test.js functions/lib/shared/schemaContracts.test.js`;
  `flutter test test/event_success/event_success_repository_test.dart test/event_success/event_success_live_screens_test.dart test/events/create_event_controller_test.dart test/core/callable_dto_contracts_test.dart test/events/event_repository_test.dart test/core/schema_contracts_generated_test.dart`;
  scoped `flutter analyze`;
  `firebase emulators:exec --only firestore "node --test --test-concurrency=1 functions/test/firestore.rules.test.cjs"`.
- 2026-05-21: Candidate callable batch passed:
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node --test functions/lib/eventSuccess/wingmanRequests.test.js`;
  `flutter test test/event_success/event_success_repository_test.dart`;
  `flutter test test/event_success/event_success_live_screens_test.dart`.
- 2026-05-21: Post-cleanup focused Flutter/rules pass:
  scoped `flutter analyze`;
  `flutter test test/event_success/event_success_repository_test.dart test/event_success/event_success_live_screens_test.dart test/events/create_event_controller_test.dart test/core/callable_dto_contracts_test.dart test/events/event_repository_test.dart test/core/schema_contracts_generated_test.dart`;
  `firebase emulators:exec --only firestore "node --test --test-concurrency=1 functions/test/firestore.rules.test.cjs"`.
- 2026-05-21: Progressive disclosure and flagship QA pass:
  `flutter test test/event_success/event_success_live_screens_test.dart`;
  `flutter test test/event_success/event_success_manual_qa_screen_test.dart`;
  `flutter test test/event_success/event_success_live_screens_test.dart test/event_success/event_success_manual_qa_screen_test.dart`;
  `flutter analyze lib/event_success/presentation/event_success_host_screen.dart lib/event_success/presentation/event_success_manual_qa_screen.dart test/event_success/event_success_live_screens_test.dart test/event_success/event_success_manual_qa_screen_test.dart`.
- 2026-05-21: User-facing copy pass:
  `flutter test test/event_success/event_success_live_screens_test.dart test/event_success/event_success_manual_qa_screen_test.dart`;
  `flutter analyze lib/event_success/domain/event_success_models.dart lib/event_success/domain/event_success_playbooks.dart lib/event_success/domain/event_success_feature_state.dart lib/event_success/domain/event_success_compatibility_response.dart lib/event_success/domain/event_success_activity_profile.dart lib/event_success/domain/event_success_coach.dart lib/event_success/domain/event_success_event_preview.dart lib/event_success/data/event_success_repository.dart lib/event_success/presentation/event_success_feature_blocks.dart lib/event_success/presentation/event_success_host_screen.dart lib/event_success/presentation/event_success_defaults_panel.dart lib/event_success/presentation/event_success_questionnaire_config_editor.dart lib/event_success/presentation/event_success_companion_screen.dart lib/event_success/presentation/event_success_live_reveal_card.dart lib/event_success/presentation/event_success_controller.dart test/event_success/event_success_live_screens_test.dart test/event_success/event_success_manual_qa_screen_test.dart`.
- 2026-05-21: Seed/demo event-success pass:
  `node tool/validate_schema_contracts.mjs`;
  `node tool/generate_schema_contracts.mjs --check`;
  `node --test tool/seed_demo_data_schema.test.mjs`;
  `flutter test test/core/schema_contracts_generated_test.dart`;
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node tool/seed_demo_data.mjs --scenario smoke --json` dry-run, with
  event-success smoke counts of 6 plans, 24 preferences, 24 compatibility
  responses, 24 assignments, 12 feedback docs, 3 wingman requests, and 3
  scorecards.
- 2026-05-21: Presentation decomposition pass:
  `dart format` on host, companion, and reveal part files;
  `flutter analyze --no-fatal-infos lib/event_success test/event_success test/core/schema_contracts_generated_test.dart`;
  `flutter test test/event_success/event_success_repository_test.dart test/event_success/event_success_live_screens_test.dart test/event_success/event_success_manual_qa_screen_test.dart test/core/schema_contracts_generated_test.dart`;
  `bash tool/widget_cleanup_scan.sh`;
  `git diff --check`.
- 2026-05-21: Final focused matrix:
  `node tool/validate_schema_contracts.mjs`;
  `node tool/generate_schema_contracts.mjs --check`;
  `node --test tool/seed_demo_data_schema.test.mjs`;
  `node tool/seed_demo_data.mjs --scenario smoke --json`;
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`.
- 2026-05-21: Audit registry closeout:
  `dart tool/audit_registry.dart refresh`;
  `dart tool/audit_registry.dart rules --status active`;
  `dart tool/audit_registry.dart mark-pass --pass event-success-hardening-2026-05-21 ...` stamped 44 tracked paths;
  `dart tool/audit_registry.dart report` passed and reported 980 tracked files.
