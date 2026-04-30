# Onboarding Audit Tracker

This file tracks the onboarding audit so a future Codex session can resume quickly.

## Goal

- Create a reusable Flutter feature audit skill
- Use that skill to audit `lib/onboarding`
- Improve onboarding code quality and organization across the folder
- Add broader controller/widget regression coverage
- Verify with scoped analyze/test/coverage commands

## Status

- [x] Create reusable skill scaffold in `~/.codex/skills/flutter-feature-audit`
- [x] Write the skill workflow and checklist
- [x] Audit onboarding flow, pages, controller, and adjacent integrations
- [x] Fix high-confidence onboarding issues
- [x] Refactor controller/page organization for clearer state handling
- [x] Add broader onboarding controller/widget regression tests
- [ ] Reach full onboarding source-file coverage
- [x] Run scoped verification and update this tracker

## Findings

- `WelcomePage` used `Navigator.pop()` for the sign-in CTA, which could fail when onboarding was reached via router navigation instead of a push stack.
- `NameDobPage` allowed invalid manually-entered phone numbers as long as the field was non-empty.
- `OtpPage` labeled its secondary action as "Resend code" even though it only returned users to the phone step.
- `PhonePage` and `OtpPage` surfaced raw Firebase exception strings instead of readable messages.
- `OnboardingController` had several fragile paths: null assertions on OTP/profile state, implicit UID fallback to `''`, and phone verification inferred from "phone number is non-empty" instead of explicit state.
- `NameDobPage`, `GenderInterestPage`, and `RunningPrefsPage` did not reliably restore saved onboarding state when users revisited those steps.
- `WelcomePage` unnecessarily depended on the full router file just to reach `/auth`, which made onboarding tests sensitive to unrelated router breakage elsewhere in the repo.
- Coverage is much better than the first pass, but it is still not full: `onboarding_screen.dart` is untested and `running_prefs_page.dart` remains effectively uncovered because the direct widget harness kept the Flutter test loop alive.

## Changes Made

- Added explicit onboarding state structure around `OnboardingStep`, `OnboardingProfileDraft`, and `phoneVerified`.
- Hardened `OnboardingController` with:
  - explicit signed-in/profile-draft validation
  - friendly state errors for missing OTP/profile state
  - normalized phone formatting
  - age validation before profile save
  - `syncEntryStep()` for cleaner onboarding entry logic
- Improved page organization and UX:
  - `WelcomePage` now routes to `/auth` without importing the full router
  - `PhonePage`, `OtpPage`, and `NameDobPage` only autofocus on their active step
  - `NameDobPage` restores saved draft values and keeps manual numbers editable unless OTP-verified
  - `GenderInterestPage` uses form validation instead of ad-hoc local error strings
  - `PhotosPage` explains why continue is disabled and avoids stacking snackbars
  - `RunningPrefsPage` uses shared chip components and friendlier mutation errors
- Added/expanded tests for:
  - controller step sync, OTP flow, profile save, and completion
  - onboarding step/back-navigation helper logic
  - welcome, phone, OTP, name/DOB, gender-interest, and photos widgets

## Verification

- `flutter analyze lib/auth/presentation/auth_error_message.dart lib/onboarding test/onboarding`
- `flutter test test/onboarding/onboarding_controller_test.dart test/onboarding/onboarding_step_test.dart test/onboarding/onboarding_widgets_test.dart`
- `flutter test --coverage test/onboarding/onboarding_controller_test.dart test/onboarding/onboarding_step_test.dart test/onboarding/onboarding_widgets_test.dart`

## Coverage Snapshot

- `onboarding_step.dart`: 100.0%
- `onboarding_profile_draft.dart`: 100.0%
- `welcome_page.dart`: 100.0%
- `name_dob_page.dart`: 100.0%
- `onboarding_controller.dart`: 94.8%
- `phone_page.dart`: 82.0%
- `photos_page.dart`: 79.5%
- `otp_page.dart`: 76.4%
- `gender_interest_page.dart`: 64.2%
- `onboarding_screen.dart`: 0.0%
- `running_prefs_page.dart`: 1.3%

## Remaining Gap

- The onboarding folder is materially improved, but it is **not** at full source-file coverage yet.
- The hardest remaining gap is widget-level coverage for `onboarding_screen.dart` and `running_prefs_page.dart`.
- Direct widget tests against those two surfaces repeatedly kept the Flutter test loop alive in this environment. I removed the unstable `onboarding_screen_test.dart` attempt rather than leave a hanging test file checked in.
- A future pass should either:
  - further simplify `OnboardingScreen`/`RunningPrefsPage` lifecycle behavior for testability, or
  - introduce narrower helper seams so those files can be exercised without spinning up the full page lifecycle.

## Files Touched

- `lib/auth/presentation/auth_error_message.dart`
- `lib/onboarding/presentation/onboarding_controller.dart`
- `lib/onboarding/presentation/onboarding_profile_draft.dart`
- `lib/onboarding/presentation/onboarding_step.dart`
- `lib/onboarding/presentation/onboarding_screen.dart`
- `lib/onboarding/presentation/pages/gender_interest_page.dart`
- `lib/onboarding/presentation/pages/name_dob_page.dart`
- `lib/onboarding/presentation/pages/otp_page.dart`
- `lib/onboarding/presentation/pages/phone_page.dart`
- `lib/onboarding/presentation/pages/photos_page.dart`
- `lib/onboarding/presentation/pages/running_prefs_page.dart`
- `lib/onboarding/presentation/pages/welcome_page.dart`
- `lib/onboarding/presentation/widgets/onboarding_step_header.dart`
- `test/onboarding/onboarding_controller_test.dart`
- `test/onboarding/onboarding_step_test.dart`
- `test/onboarding/onboarding_test_helpers.dart`
- `test/onboarding/onboarding_widgets_test.dart`

## Resume Notes

- The reusable skill lives at `~/.codex/skills/flutter-feature-audit`.
- The bundled validator script exists, but `quick_validate.py` currently cannot run in this environment because `PyYAML` is unavailable to `python3`.
- The broader app router is currently broken against a `run_clubs/presentation` folder reorg (`go_router.dart` still imports old file paths). Onboarding tests were isolated from that dependency by removing `WelcomePage`'s router import.
- The repo already had unrelated dirty files before this onboarding pass. Do not reset the worktree.
