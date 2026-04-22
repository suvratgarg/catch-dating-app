# Auth Review Tracker

This file tracks the auth review/refactor so a future Codex session can resume quickly.

## Goal

- Review `lib/auth`
- Fix correctness and UX issues
- Add unit and widget tests for auth flows
- Run targeted analysis/tests with coverage

## Status

- [x] Read `PROJECT_CONTEXT.md`
- [x] Inspect auth feature files and routing/onboarding integrations
- [x] Identify initial auth bugs and coverage gaps
- [x] Finish auth code refactor and polish pass
- [x] Add auth unit tests
- [x] Add auth widget tests
- [x] Run auth-focused test suite with coverage
- [x] Run analyzer on touched files
- [x] Update this tracker with final verification notes

## Final Findings

- Phone auto-verification could crash because onboarding assumed `smsCode` is always present on auto-verified credentials.
- Sign-in UI enforced an 8-character password minimum, which can block valid Firebase email/password users.
- Auth errors were shown as raw exception strings instead of user-facing messages.
- There were no dedicated auth tests covering repository/controller/screen behavior.

## What Changed

- Normalized email input inside `AuthRepository` so callers do not need to trim manually.
- Added `signInWithCredential` to `AuthRepository`.
- Switched onboarding auto-verification to use `signInWithCredential` instead of reconstructing OTP credentials from nullable fields.
- Added reusable auth error mapping for user-facing Firebase auth messages.
- Added reusable auth form validators.
- Improved `AuthScreen` UX with autofill hints, clearer validation, mutation reset on mode toggle, and friendlier error rendering.
- Added auth repository, controller, widget, and onboarding regression tests.

## Files Touched

- `lib/auth/auth_repository.dart`
- `lib/auth/presentation/auth_error_message.dart`
- `lib/auth/presentation/auth_form_validators.dart`
- `lib/auth/presentation/auth_screen.dart`
- `lib/onboarding/presentation/onboarding_controller.dart`
- `test/auth/auth_test_helpers.dart`
- `test/auth/auth_repository_test.dart`
- `test/auth/presentation/auth_controller_test.dart`
- `test/auth/presentation/auth_screen_test.dart`
- `test/onboarding/onboarding_controller_test.dart`

## Verification

- `flutter test test/auth/auth_repository_test.dart`
- `flutter test test/auth/presentation/auth_controller_test.dart test/routing/router_redirect_test.dart`
- `flutter test test/auth/presentation/auth_screen_test.dart`
- `flutter test test/onboarding/onboarding_controller_test.dart`
- `flutter test --coverage test/auth test/onboarding/onboarding_controller_test.dart test/routing/router_redirect_test.dart`
- `flutter analyze lib/auth lib/onboarding/presentation/onboarding_controller.dart test/auth test/onboarding/onboarding_controller_test.dart`

## Coverage Notes

- Auth source files in `lib/auth` reached 100% line coverage in the generated `coverage/lcov.info` artifact.
- Generated Riverpod files (`*.g.dart`) are not a meaningful manual coverage target and were not the focus.
- `lib/onboarding/presentation/onboarding_controller.dart` now has targeted regression coverage for the phone auto-verification path, but not full-file coverage because the broader onboarding flow was outside this auth pass.

## Next Steps

- If we continue later, the next logical area is broader onboarding coverage so the rest of `OnboardingController` gets the same test depth.
- If product wants stricter email/password policy beyond Firebase defaults, enforce it intentionally in both UI and server-side auth expectations.

## Resume Notes

- The repo had unrelated dirty changes before this auth pass. Do not reset the worktree.
- Keep auth changes scoped unless a failing auth test reveals a legitimate cross-feature bug.
