# Firebase Environment Current State

Last verified: 2026-05-21

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

Cloud Billing API is enabled in `dev`, `staging`, and `prod` as of
2026-05-20. Firebase CLI deploys query billing status during Functions deploys,
so disabling `cloudbilling.googleapis.com` breaks GitHub OIDC deploy jobs even
when the service account authentication itself succeeds.

The latest automatic `Firebase Dev Deploy` run on `main`
(`26191578234`, commit `228060a4`) passed. The earlier Cloud Billing API
blocker is resolved in dev/staging/prod, and the local wrapper expands the
logical `functions` target to explicit `functions:<name>` targets so CI does
not prompt to delete legacy live Functions.

GitHub branch protection for `main` currently requires strict status checks for
Flutter analysis/tests, Functions lint/tests, Firestore rules tests, web build,
Android debug APK, and iOS simulator build. GitHub environments `dev`,
`staging`, and `prod` exist; `prod` requires reviewer approval.

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

The release candidate commit `d61fb162` was promoted to staging and prod on
2026-05-20 through GitHub Actions after release-readiness checks passed:

- Staging deploy run `26183750439` deployed Functions, Firestore indexes,
  Firestore rules, and Storage rules.
- Prod deploy run `26184087586` deployed the same targets after the prod
  environment approval gate.

Later commits through `228060a4` were GitHub Actions workflow/runtime updates
only. No additional Firebase staging/prod deploy is required for those commits.

## Functions

Functions were checked through Cloud Functions on 2026-05-20. The current
release-candidate `functions/src/index.ts` export set was deployed explicitly to
dev, staging, and prod, including the co-host management and demo-ops callables.

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

App code enables Crashlytics and Analytics collection automatically only for
production release builds without emulators. For dev/staging release-like
evidence, set `ENABLE_OBSERVABILITY_COLLECTION=true`; to emit a single
dashboard smoke event, also set `EMIT_OBSERVABILITY_SMOKE_EVENT=true`. The smoke
path emits a nonfatal Crashlytics event with reason
`Observability smoke event` and an Analytics event named
`observability_smoke`. Auth UID sync updates both Crashlytics and Analytics user
IDs in the app shell. DebugView and Crashlytics dashboard proof are still
required before treating observability as operationally complete.

GA4 BigQuery export is separate from the Firestore BigQuery export extensions.
The current Google OAuth token can verify Firebase Analytics linkage, but the
local ADC token does not have Analytics Admin scopes for listing or creating GA4
BigQuery links. Reauthorizing local ADC with `analytics.edit` did not complete
during this pass. `bq ls` currently shows only `catch_marketplace_metrics` in
dev, staging, and prod; there is no `analytics_*` GA4 export dataset yet. Use
Firebase/Analytics Console or a service account granted GA4 Admin/Editor access
before marking GA4 BigQuery export complete. The existing
`catch_marketplace_metrics` datasets are in `asia-south1`.

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

The app reads the force-update gate from Firebase Remote Config during startup.
All three projects have the checked-in `firebase/remote_config.template.json`
baseline published as of 2026-05-20:

- `min_version`: `0.0.0`
- `min_build_android`: `0`
- `min_build_ios`: `0`
- `min_build_web`: `0`
- `min_build_macos`: `0`
- `store_url_android`: empty until the Play listing URL exists
- `store_url_ios`: empty until the App Store listing URL exists

The app uses the platform-specific minimum build first, then falls back to
`minVersion` only when the platform minimum build is unset. Loading and error
states are surfaced by the app shell. The checked-in template is deliberately
non-blocking; raise `min_build_*` only after a compatible binary is available
through the relevant store/distribution channel.

Production release builds throttle Remote Config fetches to a one-hour minimum
interval. Debug, emulator, dev, and staging builds keep a zero interval for QA.

## App Store Connect And TestFlight

The GitHub `prod` environment has the required App Store Connect secret names:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`

The repository can verify workflow wiring and secret presence, but it cannot
verify App Store Connect account settings, TestFlight groups, export-compliance
answers, privacy forms, Xcode Cloud start conditions, or review metadata without
direct App Store Connect access.

Xcode Cloud is the canonical TestFlight uploader as of 2026-05-21. App Store
Connect/Xcode Cloud has proven TestFlight upload/install/launch and iOS Maps
behavior. The old blind 12 a.m. schedule has been removed from the live
`Default` workflow; it now starts on branch changes to `main`, auto-cancels
older same-branch builds, and filters to app-shipping file/folder rules. GitHub
Actions keeps a manual iOS archive/export workflow; its TestFlight upload input
is break-glass only.

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
