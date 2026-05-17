# Photo Grid Editing Tracker

Started: 2026-05-17

## Scope

Implement the profile photo grid overhaul across onboarding, edit profile,
profile preview/public profile, and backend contracts.

## Requirements

- [x] Move profile photo min/max/display policy to a contract-backed source of truth.
- [x] Enforce max six and minimum two photos consistently in app and backend.
- [x] Add delete support with guardrails for completed profiles.
- [x] Add long-press reorder support.
- [x] Replace the separate photo-caption editor rows with per-photo edit flow.
- [x] Add a photo editor screen with crop preview, prompt dropdown, and caption field.
- [x] Render photo captions/prompts on profile preview/public/swipe profile surfaces.
- [x] Keep `profilePhotos` canonical while maintaining legacy `photoUrls`,
      `photoThumbnailUrls`, and `photoPrompts` compatibility writes.
- [x] Harden thumbnail/moderation triggers so reorder does not break source-path matching.
- [x] Add focused unit/widget/Functions/rules tests.

## Progress

- 2026-05-17: Tracker created. Current worktree already had unrelated dirty
  event/safety/config changes; this pass should avoid reverting or depending on
  them.
- 2026-05-17: Added contract-backed profile photo policy, regenerated schema
  contracts, and updated Firestore rule/test max photo bounds to six.
- 2026-05-17: Added shared Dart policy constants, grouped-photo delete,
  replace, reorder, and caption helpers, plus controller methods for
  save/delete/reorder.
- 2026-05-17: Reworked onboarding and profile edit grids to open the per-photo
  editor, show delete affordances, and support long-press drag reorder.
- 2026-05-17: Added the crop/preview editor screen with prompt dropdown and
  caption field. Removed the separate edit-profile photo-caption section.
- 2026-05-17: Rendered primary and secondary photo prompts on swipe/profile
  photo sections and used caption text in photo reaction previews.
- 2026-05-17: Hardened `updateUserProfile`, thumbnail generation, moderation,
  and public-profile projection around the canonical `profilePhotos` array.

## Verification Log

- `node tool/generate_schema_contracts.mjs --check` passed.
- `node tool/check_firestore_rules_semantics.mjs` passed.
- `dart analyze` passed.
- `npm --prefix functions run build` passed.
- `npm --prefix functions test` passed.
- Focused Flutter tests passed:
  `test/core/schema_contracts_generated_test.dart`,
  `test/image_uploads/photo_grid_test.dart`,
  `test/image_uploads/photo_upload_controller_test.dart`,
  `test/user_profile/user_profile_domain_test.dart`,
  `test/swipes/profile_card_content_test.dart`,
  `test/swipes/profile_card_widget_test.dart`,
  `test/public_profile/profile_insights_test.dart`,
  `test/onboarding/onboarding_widgets_test.dart`,
  `test/profile/profile_widgets_test.dart`.
- `npm --prefix functions run test:rules` needs emulators; without emulators it
  fails with `ECONNREFUSED 127.0.0.1:8080`. Running via
  `firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"`
  starts the emulators; Firestore rules pass, but pre-existing Storage rules
  tests fail on Firestore lookup null errors in chat/run image rules.

## Resume Notes

- The photo grid feature work is implemented and verified except for the
  unrelated Storage rules emulator failures noted above.
- Current worktree still contains unrelated event/safety/config dirty files
  that predated this pass.
