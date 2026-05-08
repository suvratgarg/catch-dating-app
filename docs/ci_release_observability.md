---
doc_id: ci_release_observability
version: 1.0.0
updated: 2026-05-09
owner: recursive_audit_loop
status: active
---

# CI, Release, And Observability Gates

This document is the source of truth for the repo-side automation that supports
release readiness. Physical-device smoke testing is intentionally tracked
outside this document.

## Required PR Checks

Configure GitHub branch protection for `main` to require these checks before
merge:

- `Analyze & test`
- `Lint & test Functions`
- `test`
- `Web build`
- `Android debug APK`
- `iOS simulator build`

`test` is the job name from the Firestore rules workflow. If GitHub displays
the full workflow-qualified names in branch protection, choose the matching
entries under:

- `Flutter CI`
- `Functions CI`
- `Firestore Rules Tests`
- `App Build Matrix`

## Workflows

| Workflow | Trigger | Purpose |
|---|---|---|
| `.github/workflows/flutter-ci.yml` | PRs and pushes to `main` | Flutter analysis, full unit/widget suite, generated Firestore type drift check. |
| `.github/workflows/functions-ci.yml` | Functions/rules/schema PRs and pushes to `main` | Functions lint/test plus Firestore contract check on Node 24. |
| `.github/workflows/firestore-rules-ci.yml` | Rules/schema PRs and pushes to `main` | Firestore contract check plus emulator-backed rules tests. |
| `.github/workflows/app-build-matrix.yml` | App/platform PRs, pushes to `main`, manual | Dev web, Android debug APK, and iOS simulator build gates. |
| `.github/workflows/firebase-deploy.yml` | Manual only | Deploy selected Firebase targets to `dev`, `staging`, or `prod` after contract, Functions, and rules checks pass. |
| `.github/workflows/data-validation.yml` | Nightly plus manual | Read-only Firestore data validation, defaulting to production on the nightly schedule. |
| `.github/workflows/release-readiness.yml` | Manual only | Pre-release gate for staging/prod config, tests, rules, Functions, contract, and web release build. |
| `.github/workflows/observability-evidence.yml` | Manual only | Records Crashlytics and Analytics dashboard evidence in a durable Actions run summary. |

## Required GitHub Secrets

Firebase workflows need one service-account JSON secret per environment:

- `FIREBASE_SERVICE_ACCOUNT_DEV`
- `FIREBASE_SERVICE_ACCOUNT_STAGING`
- `FIREBASE_SERVICE_ACCOUNT_PROD`

Use service accounts with the minimum roles needed for the workflow:

- Data validation: read-only Firestore access.
- Deploy: Firebase deploy permissions for the selected targets.

Keep deploy workflows protected with GitHub Environments named `dev`,
`staging`, and `prod`. Require manual reviewers for `prod`.

## Release Evidence That Still Needs Human Confirmation

These cannot be proven by repository files alone:

- TestFlight upload and install evidence.
- Play internal testing evidence.
- Crashlytics issue visibility and symbolication evidence.
- Analytics DebugView event evidence.
- Store metadata, screenshots, privacy forms, support URL, privacy policy, and
  terms URL.

Use `Release Readiness` before starting store submission, then run
`Observability Evidence` after generating Crashlytics and Analytics dashboard
proof.
