# Lib Feature Completeness Matrix

Date: 2026-04-28

Status updated: 2026-04-30. This is a current feature/product gap map, not a
Firebase environment source of truth. For Firebase state, read
[`firebase_environment_current_state.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/firebase_environment_current_state.md).

This matrix maps current `lib/` feature folders against the design handoff and
backend dependencies. Status values are intentionally conservative.

## Summary

| Area | Status | Notes |
| --- | --- | --- |
| Auth | Mostly built | Phone OTP is the only intended sign-in path. Dev/staging/prod Firebase Auth are configured; real-number OTP still needs quota/cooldown validation on device. |
| Onboarding | Mostly built | Seven-step flow exists and maps well to the handoff. Needs final visual fidelity pass and production OTP behavior validation. |
| Dashboard | Partial | Empty/full dashboard exist. Calendar/map quick actions are still non-routed coming-soon surfaces. |
| Run clubs | Mostly built | Directory/detail/create-club/share exist. Firestore rules now match the current model and member-count write path. Needs live create/join/leave smoke tests. |
| Runs | Partial | Detail, share, saved-run toggle, booking, waitlist, create-run wizard, map-location picker, and payment integration exist. Missing route drawing, recurring runs, and success/manage states. |
| Calendar | Built | Timeline and agenda routes exist, backed by signed-up runs. Needs visual QA and broader data smoke tests. |
| Catches/swipes | Partial | Hub, deck, 24-hour window domain, attended-run candidate queue, block filtering, tap-through public profiles, match modal, and recap screen exist. Needs live post-run smoke test. |
| Matches/chats | Mostly built | Inbox/chat, notifications, block action, report action, and blocked-match state exist. Needs deeper moderation/admin workflow. |
| Profile | Partial | Self profile, edit profile, other-user public profile, Settings/Safety, blocked accounts, reporting, and account deletion now exist. |
| Payments | Mostly built | Razorpay order/verify/history exists, Functions tests pass, Razorpay Functions secrets are configured, and payment Functions are deployed. Needs live payment smoke test before launch. |
| Force update | Built | Provider and update-required screen exist. Needs remote config/app-version document verification in Firebase. |
| Image uploads | Built | Reusable upload repository/grid/controller exist. Needs Storage rules review before production. |
| Reviews | Built | Club review UI/repository exist. Needs privacy behavior for deleted users. |
| Public profile | Built | Backend-owned projection exists. Needs blocked/deleted read behavior. |
| Core/theme/widgets | Mostly built | Catch tokens and many handoff primitives exist. Needs visual fidelity screenshots against handoff. |
| Routing | Mostly built | Main five-tab shell plus settings, filters, activity, calendar, map, run recap, other profile, match modal, and create-run success/manage surfaces exist. Host manage still needs a durable routed stream-backed flow for existing runs. |

## Design Handoff Coverage

The handoff lists 37 mobile screens. Current routes cover the core loop, but
these screen groups are not fully represented:

- Home runs: feed variant is not a top-level routed experience.
- Create run: success and host manage states.
- Create run: advanced controls such as recurring runs, cover upload, waitlist toggle, price pills, Razorpay fee math, and follower notification toggle.
- Blocking/reporting/account deletion: first production safety slice is now
  represented in route map and backend code.

## Firebase/Console Dependencies

- Dev, staging, and prod Firebase projects are configured and mapped in
  `.firebaserc`.
- Dart options and native/web Firebase config files exist for all three
  environments.
- India-first Firebase region decision: use `asia-south1` (Mumbai) for the
  default Firestore database and Cloud Functions.
- Cloud Functions are deployed in `asia-south1` for dev, staging, and prod.
- Hosting is deployed and `catchdates.com` is connected; its API rewrite points
  at the deployed `joinWaitlist` Function in `asia-south1`.
- App Check is registered for Android Play Integrity, iOS/macOS App Attest, and
  web reCAPTCHA Enterprise in all three environments.
- Firestore, Storage, Auth, and callable Functions enforce App Check.
- FCM HTTP v1 is enabled, iOS APNs auth keys are present where verified, and web
  push public VAPID keys are in the checked-in dart-define files.
- Android upload-key SHA-1/SHA-256 fingerprints are registered on dev, staging,
  and prod Firebase Android apps. Play app-signing fingerprints remain pending
  until Play Console enrollment.
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

1. Run live backend smoke tests for booking/payment/block/report/delete and
   run-club create/join/leave flows in dev/staging.
2. Finish store-channel validation work: TestFlight upload/install, Play
   Console enrollment/internal testing, and Play app-signing fingerprints in
   Firebase. Local iOS export, Android upload AAB signing, and direct macOS
   Developer ID distribution are setup-ready in the active release tracker.
3. Validate real phone OTP, photo upload, FCM token delivery, and push
   notification delivery on signed devices.
4. Add a moderation/admin review workflow for `reports`.
5. Decide whether saved runs/bookmarks are in scope; if yes, add the storage
   model and list/discovery surfaces.
6. Add durable visual/golden coverage for the highest-value design-handoff
   screens.
