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
- [ ] Finish auth code refactor and polish pass
- [ ] Add auth unit tests
- [ ] Add auth widget tests
- [ ] Run auth-focused test suite with coverage
- [ ] Run analyzer on touched files
- [ ] Update this tracker with final verification notes

## Findings So Far

- Phone auto-verification could crash because onboarding assumed `smsCode` is always present on auto-verified credentials.
- Sign-in UI enforced an 8-character password minimum, which can block valid Firebase email/password users.
- Auth errors were shown as raw exception strings instead of user-facing messages.
- There were no dedicated auth tests covering repository/controller/screen behavior.

## Files Touched

- `lib/auth/auth_repository.dart`
- `lib/auth/presentation/auth_error_message.dart`
- `lib/auth/presentation/auth_form_validators.dart`
- `lib/auth/presentation/auth_screen.dart`
- `lib/onboarding/presentation/onboarding_controller.dart`

## Next Steps

- Add repository tests with fake `FirebaseAuth`
- Add controller tests with provider overrides
- Add widget tests for sign-in/sign-up flows, error handling, pending state, and phone navigation
- Run `flutter test --coverage` for auth-related tests
- Run `flutter analyze` on touched files

## Resume Notes

- The repo had unrelated dirty changes before this auth pass. Do not reset the worktree.
- Keep auth changes scoped unless a failing auth test reveals a legitimate cross-feature bug.
