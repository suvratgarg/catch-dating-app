# Lib Feature Completeness Matrix

Date: 2026-04-28

This matrix maps current `lib/` feature folders against the design handoff and
backend dependencies. Status values are intentionally conservative.

## Summary

| Area | Status | Notes |
| --- | --- | --- |
| Auth | Partial | Email/password and phone-OTP UI exist, but production Firebase Auth provider configuration must be verified. |
| Onboarding | Mostly built | Seven-step flow exists and maps well to the handoff. Needs final visual fidelity pass and production OTP behavior validation. |
| Dashboard | Partial | Empty/full dashboard exist. Calendar/map quick actions are still non-routed coming-soon surfaces. |
| Run clubs | Mostly built | Directory/detail/create-club/share exist. Firestore rules now match the current model and member-count write path. Needs live create/join/leave smoke tests. |
| Runs | Partial | Detail, share, saved-run toggle, booking, waitlist, create-run wizard, map-location picker, and payment integration exist. Missing route drawing, recurring runs, and success/manage states. |
| Calendar | Missing | Handoff screens 36/37 are not implemented as routes or feature folders. |
| Catches/swipes | Partial | Hub, deck, 24-hour window domain, attended-run candidate queue, block filtering, and tap-through public profiles exist. Missing match celebration modal and recap screen. |
| Matches/chats | Mostly built | Inbox/chat, notifications, block action, report action, and blocked-match state exist. Needs deeper moderation/admin workflow. |
| Profile | Partial | Self profile, edit profile, other-user public profile, Settings/Safety, blocked accounts, reporting, and account deletion now exist. |
| Payments | Mostly built | Razorpay order/verify/history exists, Functions tests pass, Razorpay Functions secrets are configured, and payment Functions are deployed. Needs live payment smoke test before launch. |
| Force update | Built | Provider and update-required screen exist. Needs remote config/app-version document verification in Firebase. |
| Image uploads | Built | Reusable upload repository/grid/controller exist. Needs Storage rules review before production. |
| Reviews | Built | Club review UI/repository exist. Needs privacy behavior for deleted users. |
| Public profile | Built | Backend-owned projection exists. Needs blocked/deleted read behavior. |
| Core/theme/widgets | Mostly built | Catch tokens and many handoff primitives exist. Needs visual fidelity screenshots against handoff. |
| Routing | Partial | Main five-tab shell exists. Missing settings, filters, notifications, calendar, run recap, match modal, other profile, host manage/success routes. |

## Design Handoff Coverage

The handoff lists 37 mobile screens. Current routes cover the core loop, but
these screen groups are not fully represented:

- Settings & utilities: Filters and Notifications.
- Calendar: day timeline and week agenda.
- Home runs: feed/map variants are not top-level routed experiences.
- Create run: success and host manage states.
- Catches: match modal and run recap.
- Profile: other-user public profile view.
- Blocking/reporting/account deletion: first production safety slice is now
  represented in route map and backend code.

## Firebase/Console Dependencies

- The local app has only the `dev` Firebase options fully configured.
- `staging` and `prod` Firebase options are fail-fast placeholders.
- India-first Firebase region decision: use `asia-south1` (Mumbai) for the
  default Firestore database and Cloud Functions. Local config is aligned to
  that region.
- The Firebase console for `catch-dating-app-64e51` now has a default Cloud
  Firestore database in `asia-south1` (Mumbai), created in Standard edition and
  production mode.
- Cloud Functions are deployed in `asia-south1`; all 17 expected Functions are
  visible from `firebase functions:list`.
- Hosting is deployed and `catchdates.com` is connected; its API rewrite now
  points at the deployed `joinWaitlist` Function in `asia-south1`.
- Hardened `storage.rules` have been deployed after the console inspection.
- App Check is partially configured: iOS uses App Attest, Android uses Play
  Integrity, and the Flutter client initializes `firebase_app_check`. Web App
  Check, debug-token registration from real devices, and enforcement remain
  pending.
- FCM HTTP v1 is enabled and iOS APNs auth keys are present. Web Push
  certificates appear empty.
- Android debug SHA-1/SHA-256 fingerprints are registered. Release signing
  fingerprints remain pending.
- Firebase CLI has been reauthenticated as `suvrat.garg@gmail.com`.
- `firestore.indexes.json` includes the app's known compound query indexes and
  has been deployed.
- `storage.rules` restricts uploads to authenticated user photos and host-owned
  run-club covers and has been deployed.
- `firebase.json` now deploys only the real `functions/` codebase. The empty
  starter `catch-dating-app/` Functions source is no longer included.
- `firestore.rules` now includes block/deleted-user rules and validates the
  current `runClubs` model shape, including `area`, host display fields,
  counters, tags, and next-run metadata.
- Firestore rules emulator coverage exists for the highest-risk run-club and
  safety/privacy paths via `npm --prefix functions run test:rules`, executed
  inside `firebase emulators:exec --only firestore`.

## High-Priority Missing Work

1. Resolve the Google Cloud console account verification warning.
2. Add Android release SHA-1/SHA-256 fingerprints once release signing is finalized.
3. Finish App Check web provider/debug-token setup, then enforce only after smoke tests pass.
4. Run live backend smoke tests for booking/payment/block/report/delete and run-club create/join/leave flows.
5. Repair iOS Xcode destination discovery and macOS signing for local builds.
6. Add a moderation/admin review workflow for `reports`.
7. Add calendar/timeline and host manage routes if those are still launch scope.
8. Add saved-runs discovery/list surfaces if saved runs are intended to be more than a detail-page toggle.
