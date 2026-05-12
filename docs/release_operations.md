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
