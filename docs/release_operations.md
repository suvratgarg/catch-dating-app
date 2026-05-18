---
doc_id: release_operations
version: 1.3.1
updated: 2026-05-18
owner: recursive_audit_loop
status: active
---

# Release Operations

This is the durable owner for CI gates, Firebase deployment ordering, and
release-readiness evidence. It replaces dated one-off runbooks and should stay
short enough to be read before a deploy.

## Required PR Checks

Configure GitHub branch protection for `main` to require:

- Flutter analysis and tests.
- Functions lint/build/tests.
- Firestore rules emulator tests.
- Web build.
- Android debug APK build.
- iOS simulator build.

The current workflows are:

| Workflow | Purpose |
|---|---|
| `.github/workflows/flutter-ci.yml` | Flutter analysis, unit/widget tests, generated Firestore type drift check. |
| `.github/workflows/functions-ci.yml` | Functions lint/test plus Firestore contract check on Node 24. |
| `.github/workflows/firestore-rules-ci.yml` | Firestore contract check plus emulator-backed rules tests. |
| `.github/workflows/app-build-matrix.yml` | Dev web, Android debug APK, and iOS simulator build gates. |
| `.github/workflows/firebase-dev-deploy.yml` | Automatic dev Firebase deploy after `main` is green. |
| `.github/workflows/firebase-deploy.yml` | Manual deploy of selected Firebase targets to dev, staging, or prod. Keep staging/prod explicit. |
| `.github/workflows/data-validation.yml` | Read-only Firestore data validation, nightly and manual. |
| `.github/workflows/release-readiness.yml` | Manual staging/prod release gate. |
| `.github/workflows/ios-testflight-release.yml` | Manual prod iOS archive/export gate, with optional TestFlight upload. |
| `.github/workflows/observability-evidence.yml` | Manual Crashlytics and Analytics evidence capture. |

## Git Branch Hygiene

Treat PR branches as single-use. After a PR branch is merged into `main`, do
not keep committing to that same branch for the next slice of work. GitHub adds
a merge commit to `main`, and a reused branch can look locally ahead while still
missing the new `origin/main` merge commit. That produces repeat PR conflicts
and huge compare diffs.

Before staging or opening a PR:

1. Run `git fetch origin main`.
2. Check `git rev-list --left-right --count origin/main...HEAD`.
3. If the first number is not `0`, the current branch is behind `origin/main`;
   start a fresh `codex/<task>` branch from `origin/main` or rebase before new
   work.
4. If the branch already has a merged or conflicted PR, prefer a fresh branch
   from `origin/main` and cherry-pick only the still-needed commits.

Do not trust stale local `main` for this check. Use `origin/main` as the source
of truth, and close any superseded conflicted PR after the replacement branch is
published.

## Required Secrets And Environments

Firebase workflows need one service-account JSON secret per environment:

- `FIREBASE_SERVICE_ACCOUNT_DEV`
- `FIREBASE_SERVICE_ACCOUNT_STAGING`
- `FIREBASE_SERVICE_ACCOUNT_PROD`

Use GitHub Environments named `dev`, `staging`, and `prod`. Require manual
reviewers for `prod`.

The manual `iOS TestFlight Release` workflow also needs these repository or
`prod` environment secrets:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`
- `GOOGLE_MAPS_IOS_API_KEY_PROD`

`APP_STORE_CONNECT_API_KEY_BASE64` is the base64-encoded contents of the
downloaded `AuthKey_<key-id>.p8` file. Keep the raw `.p8` out of git; it is
ignored by `.gitignore` and should live only in secure local storage and GitHub
Actions secrets.

## CD Policy

Firebase CD is intentionally asymmetric by environment:

- `dev` deploys automatically from `main` after the required CI/build workflows
  for that exact commit pass.
- `staging` deploys only through the manual `Firebase Deploy` workflow.
- `prod` deploys only through the manual `Firebase Deploy` workflow and should
  require GitHub Environment reviewer approval.

The automatic dev deploy is a backend deploy, not a store release. It deploys
Functions, Firestore indexes, Firestore rules, and Storage rules in the safe
order. Mobile app binaries, TestFlight, Play internal testing, Hosting, and
observability evidence remain separate release steps unless explicitly added to
the selected manual deploy targets.

If the automatic dev deploy fails, fix the branch with a new PR rather than
rerunning deploys against a stale commit. Use the manual `Firebase Deploy`
workflow for intentional redeploys or environment-specific recovery.

## App Version And Force-Update Gate

Every store release candidate that may be enforced through Remote Config must
increment the `pubspec.yaml` build number. The marketing version can stay stable
when the release is compatibility or migration focused, but the build number
must still move so Firebase Remote Config can target old binaries precisely.

Current release candidate:

```text
version: 1.0.1+3
```

Flutter maps this to:

- Android `versionCode`: `3`
- iOS `CFBundleVersion`: `3`
- macOS `CFBundleVersion`: `3`

After the compatible binary is available to users, raise only the platform keys
for platforms included in that release:

```text
min_build_ios = 2
min_build_android = 2
min_build_macos = 2
```

Keep `min_version` broad unless the release intentionally changes the public
marketing version. Use the platform build gates for schema/API compatibility
work because they are less ambiguous than semantic version strings.

For storage/API migrations such as `swipes` to `profileDecisions`:

1. Deploy backend support that can tolerate both old and new clients.
2. Ship the client release with dual-read/dual-write support.
3. Wait until the released build is actually available through the relevant
   store or distribution channel.
4. Raise the Remote Config `min_build_*` value for released platforms.
5. Rerun the migration parity gate, for example:
   `node tool/validate_profile_decision_migration.mjs --env prod --require-parity`.
6. Cut over backend triggers or remove legacy write support only after the
   parity gate passes with the force-update gate in place.

Remote Config shortens the compatibility window, but it does not eliminate it
at release time. A client can start offline, fetch can fail, and store rollout
timing can lag. Keep legacy-compatible reads/writes until the explicit parity
and force-update cutover step is complete.

## Pre-Deploy Checklist

- Review `git diff --stat` and confirm the dirty tree is the intended release
  candidate.
- Run code generation if generated Dart or Firestore TS types are stale.
- Run `./tool/check_data_contract.sh`.
- Run focused Flutter analysis/tests for touched surfaces.
- Run `npm --prefix functions run lint`.
- Run `npm --prefix functions test`.
- Run Firestore rules tests through the emulator:
  `firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"`.
- Make the beta data strategy explicit: reset demo data or validate migration
  tooling before production users depend on the new schema.
- Confirm Remote Config force-update values are planned but not raised until a
  compatible app build is available.

## One-Time Environment Setup

Before rules or Functions depend on them, each Firebase/GCP environment needs:

- Cloud Vision API enabled for photo moderation.
- `config/cities` Firestore document with `cityNames` and full city objects.
- Firestore TTL policy on `rateLimits.expiresAt`.
- Firebase Functions secrets for payment, maps/places, and any other
  environment-owned provider keys.
- Google Maps SDK/Places APIs enabled and key restrictions configured as
  described in `docs/location_stack_plan.md`.

## Firebase Deploy Order

For backend/schema-affecting releases, deploy in this order per environment:

1. Functions.
2. Firestore indexes.
3. Firestore rules.
4. Storage rules.
5. Hosting or app surfaces, when applicable.

Deploy Functions before tightening rules when a release moves writes behind new
callables. Do not use Remote Config as a schema migration tool; use it only to
block older app builds after the compatible build is available.

Typical commands:

```bash
./tool/deploy_firebase_targets.sh dev functions,firestore:indexes,firestore:rules,storage
./tool/deploy_firebase_targets.sh staging functions,firestore:indexes,firestore:rules,storage
./tool/deploy_firebase_targets.sh prod functions,firestore:indexes,firestore:rules,storage
```

After production Functions deploys, sync callable invokers if needed:

```bash
npm --prefix functions run sync:callable-invokers -- \
  catchdates-dev catchdates-staging catch-dating-app-64e51
```

## Smoke Tests

After a backend deploy, smoke test:

- Phone sign-in and onboarding continuation.
- Profile edit and public profile projection.
- Create/join/leave club.
- Create event, join free event, paid booking where enabled, waitlist, cancellation.
- Self check-in and host attendance.
- Swipe, match, chat message, unread count, block/report.
- Payment history, review prompt, notifications.
- Demo-data validation for the affected environment when demo tooling changed.

## Automated Integration Test Backlog

Feature-flow integration tests should cover the same user journeys as the
manual smoke checklist, with Firebase, payment, notification, location, and
image-picker side effects replaced unless the test is explicitly device or
emulator backed.

- Auth and onboarding: phone entry, OTP continuation, profile-step resume,
  required-field validation, photo/running preference completion, and redirect
  to the authenticated shell.
- Routing and app shell: unauthenticated redirects, authenticated redirects,
  five-tab navigation, top-level route back behavior, FCM/deep-link chat routes,
  and inactive-tab stream gating.
- Dashboard: empty state, booked-event state, activity tab, next-event CTA,
  swipe-window CTA, and recommended-event navigation.
- Clubs: city selection, search, joined/discover partitioning, club detail,
  create club, edit club, join, leave, and host-only affordances.
- Events: create event, event detail, free booking, paid booking handoff, waitlist,
  cancellation, self check-in, host attendance, map view, and location picker.
- Catches and swipes: eligible attended-event list, swipe deck, empty candidate
  states, like/pass decisions, match creation result, and event recap.
- Chats: matches list, search, chat route hydration, message send, unread reset,
  block/report, and push/FCM route handling.
- Payments and reviews: payment confirmation, payment history, review prompt,
  create/update/delete review, and post-event review visibility.
- Profile and settings: inline profile edits, photo upload replacement,
  public-profile projection, notification preferences, sign out, and account
  deletion/anonymization entry points.
- Platform/device flows: App Check, real phone auth, push permission/token
  registration, image upload, real map rendering, Razorpay checkout, analytics
  DebugView, and Crashlytics visibility.

### Current Pending Integration Tests

Last updated: 2026-05-13.

The local app-shell suite in `integration_test/app_shell_smoke_test.dart`
currently covers the deterministic feature-flow surface with service side
effects faked at repository/provider boundaries. Keep these pending tests out
of the default local suite unless they are made emulator-backed or gated behind
an explicit device/live-service test target.

| Area | Local code-side coverage now present | Pending test/evidence | Required environment |
| --- | --- | --- | --- |
| App Check | Backend errors map App Check failures; app bootstrap activates App Check in `main.dart`. | Prove enforced App Check accepts the app's token and rejects missing/invalid tokens for Auth, Firestore, Storage, and callable Functions. | Firebase dev/staging project with App Check enforcement enabled plus registered debug token or release attestation. |
| Real phone auth | App-shell integration covers phone entry, OTP continuation, and repository calls with a fake auth repository. | Complete a real OTP send and sign-in against Firebase Auth. | Physical iOS/Android device or Firebase Auth emulator; use a Firebase test phone number for repeatability. |
| Push permission and token registration | App-shell integration verifies authenticated shell invokes FCM initialization; routing tests cover FCM chat route handling; backend notification producers are covered separately. | Grant/deny notification permission, save a real FCM token to `users/{uid}.fcmToken`, receive a push, and tap it into the intended route. | iOS/Android device or simulator with push support and Firebase Messaging configured for the target app id. |
| Image picker and Storage upload | App-shell integration covers picking a club cover through the full routed UI and passing uploaded URL into create-club submission with a fake upload repository. | Pick media through the native picker and upload to Firebase Storage under enforced Storage/App Check rules. | iOS/Android simulator/device with photo-library permission and Firebase Storage in dev/staging. |
| Real map rendering | Create-event integration opens the map picker and selects a map coordinate through the `GoogleMap` widget callback. | Render real map tiles/markers and verify Places-backed search/details on the target app build. | iOS/Android simulator/device with configured Google Maps/Places keys and network access. |
| Razorpay checkout UI | App-shell integration covers paid booking handoff and confirmation with a fake payment repository; payment repository tests cover typed Razorpay success/error callbacks and callable verification contract. | Open the native Razorpay checkout sheet, complete/cancel a test payment, and verify post-payment booking state. | iOS/Android device or simulator supported by `razorpay_flutter`, with Razorpay test keys and callable Functions. |
| Analytics DebugView | App-shell integration verifies route screen views reach `AppAnalytics`; unit tests cover event sanitization and collection gating. | See expected auth/routing/booking/review events in Firebase Analytics DebugView for a real build. | Debug or release-like app build connected to Firebase Analytics DebugView for the target app id. |
| Crashlytics visibility | App-shell integration verifies the authenticated uid is attached to the crash reporter on cold launch; unit tests cover fatal/error reporting paths. | Trigger a non-production test crash/non-fatal error and confirm it appears with expected custom keys and symbolication. | Release-like iOS/Android build with Crashlytics collection enabled for dev/staging and dSYM/mapping upload configured. |

Do not make these live-service tests block every PR until they have stable
fixtures, reset/cleanup steps, and documented credentials. Prefer a separate
manual or scheduled workflow that records release evidence.

## iOS TestFlight Release

Run `Release Readiness` first. Then run `iOS TestFlight Release` from GitHub
Actions. Leave `upload_to_testflight` off when you only want a signed IPA
artifact and entitlement proof. Turn it on only when the exact commit is the
release candidate to send to App Store Connect.

The workflow uses App Store Connect API key authentication for
`xcodebuild -allowProvisioningUpdates`, exports with
`ios/ExportOptions.prod.plist`, verifies the exported profile contains
HealthKit, checks the signed app contains HealthKit and Associated Domains, and
stores the IPA as a short-lived GitHub Actions artifact.

## Human Release Evidence

These still require human confirmation outside repository checks:

- TestFlight upload, install, and launch evidence.
- Play internal testing evidence.
- Crashlytics visibility and symbolication evidence.
- Analytics DebugView event evidence.
- Store metadata, screenshots, privacy forms, support URL, privacy policy, and
  terms URL.

Run `Release Readiness` before store submission and `Observability Evidence`
after generating Crashlytics/Analytics proof.
