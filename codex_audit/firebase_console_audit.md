# Firebase Console Audit

Date: 2026-04-28

Project inspected in Chrome:
- Project ID: `catch-dating-app-64e51`
- Project name: `catch-dating-app`
- Project number: `574779808785`
- Billing plan: Blaze
- Environment type: Unspecified

Note: later environment-scaffolding work added a separate dev Firebase project,
`catchdates-dev`, with native package IDs such as `com.catchdates.app.dev`.
This console audit describes the inspected `catch-dating-app-64e51` project and
should not be read as proof that the newer `catchdates-dev` project has the
same APNs/App Check/SHA setup.

This was a read-only console inspection. I did not create databases, edit rules,
change providers, generate keys, or deploy anything from the console.

## Executive Summary

The Firebase project is not ready for the Flutter app's current backend surface.
The largest blocker is that Cloud Firestore is not initialized in the console,
while the app and Cloud Functions depend on Firestore for nearly every core
feature. Cloud Functions also shows no deployed functions, so local booking,
payment, matching, notification, public profile, blocking, and account deletion
logic is not active in this Firebase project yet.

The most urgent security issue is Storage: the console currently shows broad
test-mode style Storage rules, while the local repository now contains hardened
`storage.rules`. Those local rules need to be deployed after Firebase CLI
reauthentication.

## Product Status By Firebase Area

| Area | Console status | Impact |
| --- | --- | --- |
| Authentication | Initialized. Email/password and Phone are enabled. Three Email-provider users are visible. Android debug and upload-key SHA-1/SHA-256 fingerprints are now registered. | Basic auth exists. After Play App Signing enrollment, add the Play app-signing certificate fingerprints too. |
| Cloud Firestore | Initialized on 2026-04-28 as the default database in `asia-south1` (Mumbai), Standard edition, production mode. Firestore rules and indexes were deployed from this repo. | Database creation and rules/index deployment blockers are closed. |
| Cloud Storage | Initialized with bucket `catch-dating-app-64e51.firebasestorage.app`; top-level `users/` folder exists. Hardened repo rules were deployed after the console inspection. | Initial broad/test-mode rules gap is closed by CLI deploy. Recheck console Rules tab after future deploys. |
| Cloud Functions | All 17 expected repo Functions are deployed in `asia-south1`, verified by `firebase functions:list`. | Core backend is live. Live product smoke tests are still needed for payments, booking, blocking, reports, and account deletion. |
| Cloud Messaging | FCM HTTP v1 API is enabled. Sender ID is `574779808785`. APNs auth key ID `78HUQYZ2ZR` with Team ID `2HQBK4UMUT` is uploaded for both development and production on the old iOS app and the new `com.catchdates.app` iOS app. Dev Web Push has a VAPID key. | Validate production push on a real signed iPhone build after Apple Developer capabilities/provisioning are refreshed for `com.catchdates.app`. |
| Hosting | Hosting is deployed. Current release hash visible as `843463`, deployed by `Suvrat.garg@gmail.com` on 2026-03-02 at 3:08 PM. Default Firebase domains and `catchdates.com` are connected. | Marketing/hosting surface exists. The `/api/join-waitlist` rewrite now points at the deployed `joinWaitlist` Function in `asia-south1`. |
| App Check | New Android app `com.catchdates.app` is registered with Play Integrity. New iOS app `com.catchdates.app` is registered with App Attest. Flutter initializes `firebase_app_check` for native and web targets. Web and the stale Windows web app remain unregistered. | Do not enable enforcement until web reCAPTCHA Enterprise is decided, debug tokens are registered from real devices, and live smoke tests pass. |
| Registered apps | Original Android/iOS apps, new `com.catchdates.app` Android/iOS dev apps, web, and a web-style `windows` app are registered. | Windows registration looks stale or unexplained now that Windows is not a supported target. |

## Registered Apps

- Android: `Catch dev Android`, package `com.catchdates.app`, app ID `1:574779808785:android:81edbfa0d4aba7c48ea5b0`.
- iOS: `Catch dev iOS`, bundle ID `com.catchdates.app`, app ID `1:574779808785:ios:49b1ce51418604b78ea5b0`.
- Original Android: `catch_dating_app (android)`, package `com.example.catch_dating_app`, app ID `1:574779808785:android:8d7b61e9d54592f68ea5b0`.
- Original iOS: `catch_dating_app (ios)`, bundle ID `com.example.catchDatingApp`.
- Web: `catch_dating_app (web)`.
- Web-style Windows app: `catch_dating_app (windows)`.

Android debug fingerprints registered on the original Android app on 2026-04-28 and copied to the new `com.catchdates.app` Android app on 2026-04-29:
- SHA-1: `6F:D9:D4:35:F1:8A:53:43:81:F3:E8:C0:43:60:3C:A5:98:7A:5D:A0`
- SHA-256: `F0:E1:D3:E1:2C:44:3C:00:EC:AC:33:45:96:46:73:D5:B3:A1:F4:6F:1D:59:AB:AD:CD:19:CF:14:26:F2:30:02`

Android upload-key fingerprints registered on the dev, staging, and production Firebase Android apps on 2026-04-29:
- SHA-1: `F3:71:52:37:15:35:E0:2E:4A:F8:C6:A7:D9:E1:DA:BB:B7:AA:56:37`
- SHA-256: `30:88:F7:63:A6:0F:D9:F7:CA:99:20:4D:6A:68:EF:93:A3:02:63:A6:97:E5:63:EF:88:3B:29:DB:BC:7A:E2:3E`

After Play App Signing enrollment, add the Play app-signing certificate SHA-1 and SHA-256 fingerprints before relying on phone auth, Android App Check, or any future Google sign-in for Play-distributed production builds.

## Current Repo Alignment

Local repository state after this audit:
- `firestore.rules` includes block/deleted-user safety rules.
- `firestore.indexes.json` now contains composite indexes for known app query shapes.
- `storage.rules` is hardened for authenticated user photos and host-owned run club media.
- `firebase.json` deploys the real `functions/` codebase and no longer includes the empty starter Functions source.
- `joinWaitlist` is configured for `asia-south1` in both `firebase.json` Hosting rewrites and `functions/src/waitlist/joinWaitlist.ts`.
- Flutter initializes `firebase_app_check` after `Firebase.initializeApp`.

The console is now aligned with the repo for the app's core backend surface.
Firestore and Storage rules, Firestore indexes, Razorpay Functions secrets, and
Cloud Functions were deployed/configured after Firebase CLI reauthentication.

## Launch-Critical Actions

1. Resolve the Google Cloud console account verification warning.
2. Add Android release SHA-1/SHA-256 fingerprints once release signing is finalized.
3. Register App Check web provider with reCAPTCHA Enterprise if web debugging should hit protected Firebase services.
4. Register debug App Check tokens from real development devices/simulators before enforcing.
5. Generate/import Web Push certificates if web notification debugging is in scope.
6. Set the Firebase project environment type intentionally, likely `Development` for this dev project.
7. Remove or document the stale `catch_dating_app (windows)` app registration.

## Important Constraint

Firestore region is a lasting project decision. For India-first launch, the
repo is now aligned on `asia-south1` (Mumbai): `firebase.json` uses it for the
default Firestore database, Cloud Functions global options use it, Flutter
callables use it, and the Hosting waitlist rewrite was already using it.

Created in console on 2026-04-28:
- Edition: Standard
- Database ID: `(default)`
- Location: `asia-south1` (Mumbai)
- Initial rules mode: production mode

CLI reauth completed on 2026-04-28 as `suvrat.garg@gmail.com`.
`firebase firestore:databases:list --project catch-dating-app-64e51` verified
`projects/catch-dating-app-64e51/databases/(default)`.

Deployed on 2026-04-28:
- Firestore rules
- Firestore indexes
- Storage rules

Functions dry run status:
- Predeploy lint/build passed.
- Cloud Build, Artifact Registry, and Firebase Extensions APIs were enabled
  during deploy preparation.
- Deploy analysis stopped because Secret Manager API is disabled and the code
  references `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET`.

Update: Secret Manager API was enabled through Google Cloud Console. Both
Razorpay secrets were created as version 1 from `/Users/suvratgarg/Downloads/rzp-key.csv`
without printing values in terminal output.

Functions deployment status:
- First deploy was partial because initial 2nd-gen Cloud Run/Eventarc setup
  returned transient 500/503/permission-propagation errors.
- Retry deployed the remaining Functions.
- `firebase functions:list --project catch-dating-app-64e51` verified all 17
  expected Functions in `asia-south1`.
- Artifact Registry cleanup policy is configured for
  `projects/catch-dating-app-64e51/locations/asia-south1/repositories/gcf-artifacts`
  to delete images older than 7 days.
- Temporary local Razorpay secret files created under `/private/tmp` were
  deleted after upload.
