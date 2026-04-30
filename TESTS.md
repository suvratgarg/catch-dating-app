# Catch Test Status

Last updated: 2026-05-01

This file is the current test-suite inventory. The old 112-item aspirational
checklist has been retired because many of those tests now exist under different
names and more feature coverage has been added.

## Verification Commands

Use these commands for normal local verification:

```bash
flutter analyze
flutter test --concurrency=1
npm --prefix functions run lint
npm --prefix functions test
./tool/validate_firebase_environment.sh <active-env>
```

## Last Verification

Documentation cleanup pass, 2026-04-30:

- `git diff --check` passed.
- `./tool/validate_firebase_environment.sh prod` passed.
- `npm --prefix functions run lint` passed.
- `npm --prefix functions test` passed: 23 tests.
- `flutter analyze` passed: no issues.

Notes:

- Cross-platform release/setup build evidence lives in
  [`codex_audit/release_setup_2026-04-30/current_release_setup_audit.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/release_setup_2026-04-30/current_release_setup_audit.md).
- Prefer `flutter test --concurrency=1` for the broad suite. A previous fully
  parallel `flutter test` run exposed a `two_dimensional_scrollables`/TableView
  isolation issue in `test/run_clubs/run_clubs_widgets_test.dart`; that file
  passes by itself and the serialized suite passed in the iOS readiness pass.
- `./tool/validate_firebase_environment.sh <env>` checks the current root
  Firebase files against one environment. Run
  `./tool/use_firebase_environment.sh <env>` first when switching.
- Functions `npm test` intentionally runs the normal unit/guard suite. The
  Firestore emulator rules test remains available separately through
  `functions/test/firestore.rules.test.cjs`.
- The App Check callable guard lives at
  [`functions/test/callable-app-check.test.cjs`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/test/callable-app-check.test.cjs)
  and fails if a callable endpoint bypasses the shared App Check options.

## Current Flutter Test Inventory

| Area | Test files |
| --- | --- |
| Analytics | `test/analytics/app_analytics_test.dart` |
| Auth | `test/auth/auth_repository_test.dart`, `test/auth/presentation/auth_error_message_test.dart` |
| Core config | `test/core/app_config_test.dart` |
| Dashboard | `test/dashboard/dashboard_screen_test.dart`, `test/dashboard/dashboard_full_view_model_test.dart` |
| Error logging | `test/exceptions/error_logger_test.dart` |
| Force update | `test/force_update/version_test.dart` |
| Image uploads | `test/image_uploads/photo_upload_controller_test.dart` |
| Onboarding | `test/onboarding/onboarding_controller_test.dart`, `test/onboarding/onboarding_step_test.dart`, `test/onboarding/onboarding_widgets_test.dart` |
| Payments | `test/payments/payment_history_repository_test.dart`, `test/payments/payment_history_screen_test.dart`, `test/payments/payment_repository_test.dart` |
| Profile | `test/profile/edit_profile_form_data_test.dart`, `test/profile/edit_profile_screen_test.dart`, `test/profile/profile_validation_test.dart`, `test/profile/profile_widgets_test.dart` |
| Reviews | `test/reviews/review_document_id_test.dart` |
| Routing | `test/routing/router_redirect_test.dart`, `test/routing/router_widgets_test.dart` |
| Run clubs | `test/run_clubs/run_clubs_controllers_test.dart`, `test/run_clubs/run_clubs_flow_test.dart`, `test/run_clubs/run_clubs_list_controller_test.dart`, `test/run_clubs/run_clubs_repository_test.dart`, `test/run_clubs/run_clubs_widgets_test.dart` |
| Runs | `test/runs/create_run_controller_test.dart`, `test/runs/create_run_screen_test.dart`, `test/runs/location_picker_screen_test.dart`, `test/runs/run_booking_controller_test.dart`, `test/runs/run_detail_controller_test.dart`, `test/runs/run_detail_widgets_test.dart`, `test/runs/run_domain_test.dart`, `test/runs/run_eligibility_test.dart`, `test/runs/run_formatters_test.dart`, `test/runs/run_repository_test.dart`, `test/runs/runs_domain_helpers_test.dart`, `test/runs/runs_widgets_test.dart` |
| Swipes | `test/swipes/profile_card_content_test.dart`, `test/swipes/swipe_candidate_repository_preferences_test.dart`, `test/swipes/swipe_candidate_repository_test.dart`, `test/swipes/swipe_empty_content_test.dart`, `test/swipes/swipe_queue_notifier_test.dart`, `test/swipes/swipe_window_test.dart` |
| Chats and matches | `test/chats/chat_list_tile_test.dart`, `test/chats/chat_message_test.dart`, `test/chats/chat_repository_test.dart`, `test/chats/chat_screen_test.dart`, `test/chats/fcm_service_test.dart`, `test/chats/match_repository_test.dart`, `test/chats/matches_list_screen_test.dart`, `test/chats/message_bubble_test.dart` |
| User profile | `test/user_profile/user_profile_domain_test.dart`, `test/user_profile/user_profile_repository_test.dart` |

## Current Functions Test Inventory

| Area | Test files |
| --- | --- |
| App Check guard | `functions/test/callable-app-check.test.cjs` |
| Payments | `functions/src/payments/paymentValidation.test.ts`, `functions/src/payments/createRazorpayOrder.test.ts`, `functions/src/payments/verifyRazorpayPayment.test.ts` |
| Safety | `functions/src/safety/accountDeletion.test.ts`, `functions/src/safety/blocking.test.ts`, `functions/src/safety/reporting.test.ts` |
| Waitlist HTTP endpoint | `functions/src/waitlist/joinWaitlist.test.ts` |
| Firestore rules emulator | `functions/test/firestore.rules.test.cjs` |

## Known Gaps

- There is still no dedicated end-to-end device test flow for real phone OTP,
  photo upload, push token delivery, and a complete booking/swipe/chat loop.
- App Store/TestFlight and Play internal testing still need store-distributed
  smoke tests.
- The design-handoff visual gallery exists, but there is no durable golden-test
  suite comparing key 390 x 844 screens against the handoff.
- Functions rules emulator coverage exists for high-risk paths, but it is not
  part of default `npm test`.

## Historical Trackers

The old feature-specific tracker files are archived under
[`codex_audit/archive/root_trackers/`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/archive/root_trackers/).
Use them as historical evidence only; this file is the current test inventory.
