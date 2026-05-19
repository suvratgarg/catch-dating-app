# Firebase Environment Current State

Last verified: 2026-05-20

This is the canonical handoff note for the current Firebase/App Check/Functions
setup. Older audit files may describe earlier gaps that have since been closed.

## Projects

| Environment | Firebase project | Project number | Notes |
| --- | --- | --- | --- |
| `dev` | `catchdates-dev` | `619661127800` | App Check and Functions are configured for debugging release-like builds. |
| `staging` | `catchdates-staging` | `822303414140` | Mirrors dev/prod topology for pre-release validation. |
| `prod` | `catch-dating-app-64e51` | `574779808785` | Current production candidate project. |

There is no separate `developer` Firebase project in the repo. Local developer
builds use `APP_ENV=dev` plus debug App Check providers when Flutter is running
in debug mode or emulator mode.

## GitHub Deploy Auth

GitHub Actions Firebase deploy and data-validation workflows use keyless Google
Cloud auth through GitHub OIDC. The repo has environment variables configured
for `dev`, `staging`, and `prod`:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

Each environment points at a dedicated `github-actions-deploy` service account
in the matching Google Cloud project. The service accounts are trusted only
through the repo-restricted `suvratgarg/catch-dating-app` OIDC provider.

The deploy service accounts have the same verified project role set in all
three projects:

- `roles/artifactregistry.admin`
- `roles/cloudbuild.builds.editor`
- `roles/cloudfunctions.admin`
- `roles/cloudscheduler.admin`
- `roles/datastore.indexAdmin`
- `roles/datastore.viewer`
- `roles/eventarc.admin`
- `roles/firebase.viewer`
- `roles/firebaserules.admin`
- `roles/iam.serviceAccountUser`
- `roles/pubsub.admin`
- `roles/run.admin`
- `roles/secretmanager.viewer`
- `roles/serviceusage.serviceUsageViewer`

## App Registrations

Each Firebase project should have exactly one current app registration per
shipping platform:

- Android: package `com.catchdates.app`
- iOS/macOS: bundle ID `com.catchdates.app`
- Web: current Catch web app

The Firebase project/app registration check was rerun on 2026-05-20. Each
environment has exactly one active Android, one active iOS, and one active web
app registration for the expected project and package/bundle IDs. Production
currently has exactly these active app registrations:

| Display name | App ID | Platform |
| --- | --- | --- |
| `Catch Prod Android` | `1:574779808785:android:81edbfa0d4aba7c48ea5b0` | Android |
| `Catch Prod iOS` | `1:574779808785:ios:49b1ce51418604b78ea5b0` | iOS |
| `Catch Prod Web` | `1:574779808785:web:0c3bd6aa7d98590f8ea5b0` | Web |

Legacy prod registrations for `com.example.catch_dating_app`,
`com.example.catchDatingApp`, and the old `Catch Windows Web` web app were
removed on 2026-04-30. Firebase keeps removed app registrations restorable for
30 days before permanent deletion.

## App Check

Android, iOS, and web are registered in App Check for `dev`, `staging`, and
`prod`.

| Platform | Dev provider | Staging provider | Prod provider |
| --- | --- | --- | --- |
| Android | Play Integrity | Play Integrity | Play Integrity |
| iOS/macOS | App Attest | App Attest | App Attest |
| Web | reCAPTCHA Enterprise | reCAPTCHA Enterprise | reCAPTCHA Enterprise |

Firebase App Check service enforcement was verified through the App Check REST
API on 2026-05-20. Firestore, Storage, and Firebase Auth are enforced in all
three projects:

- Cloud Firestore: `ENFORCED`
- Cloud Storage: `ENFORCED`
- Firebase Authentication: `ENFORCED`

Provider configs are present for Android Play Integrity, iOS App Attest, and
web reCAPTCHA Enterprise in `dev`, `staging`, and `prod`. The Google Places API
is listed as `UNENFORCED` in the dev App Check services response; Places access
from the app still goes through App Check-protected callable Functions and the
server-side `GOOGLE_MAPS_PLACES_API_KEY` secret.

Callable Cloud Functions are configured with `enforceAppCheck: true`. The public
marketing waitlist HTTP endpoint remains public by design. It uses an explicit
origin allowlist for Catch domains, Firebase Hosting domains, and local preview
origins; add reCAPTCHA Enterprise assessment or Cloud Armor if it becomes a spam
target.

Local web debug runs follow Firebase's documented debug-provider flow:
`web/index.html` sets `self.FIREBASE_APPCHECK_DEBUG_TOKEN = true` only for
`localhost`, `127.0.0.1`, and `::1`. The generated browser debug token was
registered on the dev web app on 2026-05-01. Do not commit raw debug tokens.

Local physical iPhone debug runs use the Apple debug App Check provider. The
debug token printed by Flutter must be registered on the matching dev iOS app in
Firebase Console. `./tool/flutter_with_env.sh` also forwards a local
`FIREBASE_APP_CHECK_DEBUG_TOKEN` environment variable as a Dart define so a
registered token can be reused without committing it.

Firestore rules are deployed and aligned across all three projects as of
2026-05-01. The live dev and staging rules were stale before this pass and did
not allow the public `config/app_config` force-update read; both now include the
checked-in `document == 'app_config'` read rule. Prod already had that rule.

## Functions

Functions were checked through Cloud Functions on 2026-05-20.

- `dev`: 64 app-owned functions plus 24 BigQuery extension functions.
- `staging`: 64 app-owned functions plus 24 BigQuery extension functions.
- `prod`: current event/club functions are deployed alongside legacy run and
  run-club functions, so the current Flutter app can call the prod backend.

The legacy prod run/run-club functions remain deployed for backward
compatibility. Do not delete them until old clients no longer need them and a
deliberate cleanup plan is in place.

Dev and staging reuse the current Razorpay test-mode secrets from prod because
no live Razorpay dashboard credentials are in use yet.

Before real payments launch, replace this with explicit environment-owned
Razorpay secrets and document whether each project uses Razorpay test or live
mode.

## BigQuery And Analytics

`dev`, `staging`, and `prod` have the `catch_marketplace_metrics` BigQuery
dataset and the six Firestore BigQuery export extension instances declared in
`firebase.json` / `extensions/*.env`:

- `bq-event-success-feedback`
- `bq-event-success-scorecards`
- `bq-participant-marketplace-metrics`
- `bq-participant-metric-counters`
- `bq-participant-momentum`
- `bq-participant-signal-facts`

Firebase Analytics is wired in app code and all three Firebase projects are
linked to Google Analytics account `365970973` as of 2026-05-20:

| Environment | GA4 property | Web measurement ID |
| --- | --- | --- |
| `dev` | `538364226` (`catchdates-dev`) | `G-TCR62QJVH9` |
| `staging` | `538360932` (`catchdates-staging`) | `G-LL66RSRVJP` |
| `prod` | `526484083` (`catch-dating-app-64e51`) | `G-CH7WMQY5FV` |

The dev/staging web measurement IDs are checked into
`lib/firebase_options_<env>.dart` and `firebase/<env>/web/firebase-messaging-sw.js`.
The active root `web/firebase-messaging-sw.js` is aligned to dev.

Fresh iOS and Android SDK config downloads still report Analytics as
disabled/missing analytics service metadata even though the Firebase Management
API reports Android/iOS stream mappings. Treat DebugView evidence as pending
until a real release-like app build is observed in Firebase Analytics.

GA4 BigQuery export is separate from the Firestore BigQuery export extensions.
The current Google OAuth token can verify Firebase Analytics linkage, but it
does not have Analytics Admin scopes for listing or creating GA4 BigQuery links.
`bq ls` currently shows only `catch_marketplace_metrics` in dev, staging, and
prod; there is no `analytics_*` GA4 export dataset yet. Use Firebase/Analytics
Console or a service account granted GA4 Admin/Editor access before marking GA4
BigQuery export complete.

## Firestore And Storage

All three Firestore databases are native mode in `asia-south1`, and all three
projects currently have 28 composite indexes. The Firestore TTL policy for
`rateLimits.expiresAt` is `ACTIVE` in `dev`, `staging`, and `prod`.

Storage bucket locations are not fully aligned:

- `dev`: default Firebase Storage bucket in `ASIA-SOUTH1`
- `staging`: default Firebase Storage bucket in `ASIA-SOUTH1`
- `prod`: default Firebase Storage bucket in `US-CENTRAL1`

Firebase Storage bucket location cannot be changed in place. If data locality or
latency matters for prod media, plan a separate bucket/migration decision rather
than treating this as a simple config edit.

## Force Update Config

All three projects have Firestore document `config/app_config` seeded for the
current `1.0.0+1` app build:

- `minVersion`: `1.0.0`
- `minBuildAndroid`: `1`
- `minBuildIos`: `1`
- `minBuildWeb`: `1`
- `minBuildMacos`: `1`
- `storeUrlAndroid`: empty until the Play listing URL exists
- `storeUrlIos`: empty until the App Store listing URL exists

The app uses the platform-specific minimum build first, then falls back to
`minVersion` only when the platform minimum build is unset. Loading and error
states are surfaced by the app shell; a failed config read now shows a blocking
retry screen instead of silently allowing startup.

Runtime check completed on 2026-05-01 for local dev web:

- Raising dev `minBuildWeb`/`minVersion` above the current build showed the
  blocking update-required screen.
- Resetting dev to `minBuildWeb: 1` and `minVersion: 1.0.0` restored normal
  onboarding startup.

## Local Config Rules

The canonical Firebase config files live under `firebase/<env>/`.

The root active files are mutable working copies:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`
- `web/firebase-messaging-sw.js`

Use `./tool/flutter_with_env.sh <env> ...` or
`./tool/use_firebase_environment.sh <env>` to keep root files aligned with the
Dart `APP_ENV` define file. Run
`./tool/validate_firebase_environment.sh <env>` before diagnosing Firebase
runtime issues.

## Known Cleanup Candidates

- Raw audit logs under `codex_audit/**/logs/` are ignored for future runs. Keep
  concise markdown summaries and commit raw logs only when they are needed as
  evidence.
- macOS release hardening/notarization is no longer a Firebase/setup blocker.
  The current direct-distribution state lives in
  `codex_audit/release_setup_2026-04-30/current_release_setup_audit.md` and is
  Developer ID signed, timestamped, notarized, stapled, and Gatekeeper accepted.
