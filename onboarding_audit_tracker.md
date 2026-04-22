# Onboarding Audit Tracker

This file tracks the onboarding audit so a future Codex session can resume quickly.

## Goal

- Create a reusable Flutter feature audit skill
- Use that skill to audit `lib/onboarding`
- Fix clear onboarding issues found during the audit
- Add focused regression/widget tests
- Verify with scoped analyze/test commands

## Status

- [x] Create reusable skill scaffold in `~/.codex/skills/flutter-feature-audit`
- [x] Write the skill workflow and checklist
- [x] Audit onboarding flow, pages, controller, and adjacent integrations
- [x] Fix high-confidence onboarding issues
- [x] Add focused onboarding widget/controller tests
- [x] Run final scoped verification and update this tracker

## Findings

- `WelcomePage` used `Navigator.pop()` for the sign-in CTA, which could fail when onboarding was reached via router navigation instead of a push stack.
- `NameDobPage` allowed invalid manually-entered phone numbers as long as the field was non-empty.
- `OtpPage` labeled its secondary action as "Resend code" even though it only returned users to the phone step.
- `PhonePage` and `OtpPage` surfaced raw Firebase exception strings instead of readable messages.
- Coverage for onboarding was very thin before this pass; only targeted `sendOtp` controller tests existed.

## Verification

- `flutter test test/onboarding`
- `flutter test test/onboarding/onboarding_controller_test.dart test/onboarding/onboarding_widgets_test.dart`
- `flutter test --coverage test/onboarding/onboarding_controller_test.dart test/onboarding/onboarding_widgets_test.dart`
- `flutter analyze lib/auth/presentation/auth_error_message.dart lib/onboarding test/onboarding`

## Coverage Snapshot

- `welcome_page.dart`: 100.0%
- `name_dob_page.dart`: 94.4%
- `otp_page.dart`: 81.5%
- `phone_page.dart`: 83.3%
- `onboarding_controller.dart`: 31.7%
- Broader onboarding coverage is still light for `onboarding_screen.dart`, `gender_interest_page.dart`, `photos_page.dart`, and `running_prefs_page.dart`.

## Files Touched

- `lib/auth/presentation/auth_error_message.dart`
- `lib/onboarding/presentation/pages/name_dob_page.dart`
- `lib/onboarding/presentation/pages/otp_page.dart`
- `lib/onboarding/presentation/pages/phone_page.dart`
- `lib/onboarding/presentation/pages/welcome_page.dart`
- `test/onboarding/onboarding_controller_test.dart`
- `test/onboarding/onboarding_widgets_test.dart`

## Resume Notes

- The reusable skill lives at `~/.codex/skills/flutter-feature-audit`.
- The bundled validator script exists, but `quick_validate.py` currently cannot run in this environment because `PyYAML` is unavailable to `python3`.
- The repo already had unrelated dirty files before this onboarding pass. Do not reset the worktree.
