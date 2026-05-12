---
doc_id: release_operations
version: 1.0.0
updated: 2026-05-12
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
| `.github/workflows/firebase-deploy.yml` | Manual deploy of selected Firebase targets to dev, staging, or prod. |
| `.github/workflows/data-validation.yml` | Read-only Firestore data validation, nightly and manual. |
| `.github/workflows/release-readiness.yml` | Manual staging/prod release gate. |
| `.github/workflows/observability-evidence.yml` | Manual Crashlytics and Analytics evidence capture. |

## Required Secrets And Environments

Firebase workflows need one service-account JSON secret per environment:

- `FIREBASE_SERVICE_ACCOUNT_DEV`
- `FIREBASE_SERVICE_ACCOUNT_STAGING`
- `FIREBASE_SERVICE_ACCOUNT_PROD`

Use GitHub Environments named `dev`, `staging`, and `prod`. Require manual
reviewers for `prod`.

## Pre-Deploy Checklist

- Review `git diff --stat` and confirm the dirty tree is the intended release
  candidate.
- Run code generation if generated Dart or Firestore TS types are stale.
- Run `./tool/check_data_contract.sh`.
- Run focused Flutter analysis/tests for touched surfaces.
- Run `npm --prefix functions run lint`.
- Run `npm --prefix functions test`.
- Run Firestore rules tests through the emulator:
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`.
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
./tool/firebase_with_env.sh dev deploy --only functions
./tool/firebase_with_env.sh dev deploy --only firestore:indexes
./tool/firebase_with_env.sh dev deploy --only firestore:rules
./tool/firebase_with_env.sh dev deploy --only storage
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
- Create/join/leave run club.
- Create run, join free run, paid booking where enabled, waitlist, cancellation.
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
- Dashboard: empty state, booked-run state, activity tab, next-run CTA,
  swipe-window CTA, and recommended-run navigation.
- Run clubs: city selection, search, joined/discover partitioning, club detail,
  create club, edit club, join, leave, and host-only affordances.
- Runs: create run, run detail, free booking, paid booking handoff, waitlist,
  cancellation, self check-in, host attendance, map view, and location picker.
- Catches and swipes: eligible attended-run list, swipe deck, empty candidate
  states, like/pass decisions, match creation result, and run recap.
- Chats: matches list, search, chat route hydration, message send, unread reset,
  block/report, and push/FCM route handling.
- Payments and reviews: payment confirmation, payment history, review prompt,
  create/update/delete review, and post-run review visibility.
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
| Image picker and Storage upload | App-shell integration covers picking a run-club cover through the full routed UI and passing uploaded URL into create-club submission with a fake upload repository. | Pick media through the native picker and upload to Firebase Storage under enforced Storage/App Check rules. | iOS/Android simulator/device with photo-library permission and Firebase Storage in dev/staging. |
| Real map rendering | Create-run integration opens the map picker and selects a map coordinate through the `GoogleMap` widget callback. | Render real map tiles/markers and verify Places-backed search/details on the target app build. | iOS/Android simulator/device with configured Google Maps/Places keys and network access. |
| Razorpay checkout UI | App-shell integration covers paid booking handoff and confirmation with a fake payment repository; payment repository tests cover typed Razorpay success/error callbacks and callable verification contract. | Open the native Razorpay checkout sheet, complete/cancel a test payment, and verify post-payment booking state. | iOS/Android device or simulator supported by `razorpay_flutter`, with Razorpay test keys and callable Functions. |
| Analytics DebugView | App-shell integration verifies route screen views reach `AppAnalytics`; unit tests cover event sanitization and collection gating. | See expected auth/routing/booking/review events in Firebase Analytics DebugView for a real build. | Debug or release-like app build connected to Firebase Analytics DebugView for the target app id. |
| Crashlytics visibility | App-shell integration verifies the authenticated uid is attached to the crash reporter on cold launch; unit tests cover fatal/error reporting paths. | Trigger a non-production test crash/non-fatal error and confirm it appears with expected custom keys and symbolication. | Release-like iOS/Android build with Crashlytics collection enabled for dev/staging and dSYM/mapping upload configured. |

Do not make these live-service tests block every PR until they have stable
fixtures, reset/cleanup steps, and documented credentials. Prefer a separate
manual or scheduled workflow that records release evidence.

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
