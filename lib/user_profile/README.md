# User Profile

User profile owns the private `users/{uid}` profile, profile editing, preview
data, and the source fields that feed public profile projection.

## Current Contract

- Public profile name should come from `displayName`, with legacy fallbacks
  only while old data exists.
- Last name is private and should not become a public profile field by default.
- Date of birth and gender are identity fields, not casual profile text.
- Schema changes belong in `contracts/` first, then generated Dart/TypeScript
  outputs and rules/tests should be updated through `docs/data_contracts.md`.

## Verified Open Issues

Verified against `lib/user_profile/presentation/widgets/profile_tab.dart`,
`lib/user_profile/domain/user_profile.dart`, and
`test/profile/profile_widgets_test.dart` on 2026-06-29:

1. `Phone` is display-only in Profile. There is still no profile-local Firebase
   Auth phone re-verification/change flow, so keep it readonly unless an OTP
   re-verification flow updates the Auth credential first.
2. `Date of birth` is still display-only. Decide whether corrections go
   through an in-app support flow, admin review, or a carefully constrained
   editor.
3. `Gender` is still display-only. Decide whether corrections go through
   support/admin review or a constrained editor.
4. `UserProfile` still carries legacy `name` alongside `firstName`,
   `lastName`, and `displayName`. Pick the canonical storage contract and plan
   the migration before removing compatibility fallbacks.

## Re-Audit Rule

Do not reuse old pre-rename run/club profile-adjacent audit findings without a
fresh read of current `lib/events/**`, `lib/clubs/**`, `lib/user_profile/**`,
tests, and relevant Functions. Notification and map preferences have moved
toward Settings, so old "not exposed" claims need live verification.
