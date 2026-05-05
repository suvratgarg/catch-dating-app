# One Crore Compensation Bar Assessment

Date: 2026-05-05  
Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`  
Scope: Current dirty and unstaged tree, including modified, deleted, and untracked files.

## Executive Position

Based on the current codebase, I would not make an unconditional ₹1 crore or
₹2 crore per year offer.

The repository shows strong senior engineering work. It is a real full-stack
Flutter/Firebase product with meaningful architecture, tests, security rules,
Cloud Functions, payment integration, App Check, documentation, and feature
breadth. If one person genuinely wrote all of it, they are not junior.

But ₹1 crore per year in India is not just "good Flutter developer" pay. It is
senior staff, founding engineer, or engineering-lead compensation. ₹2 crore per
year is principal/VP-level compensation. At that level, the bar is not just
"can build features." The bar is:

- ships clean, production-ready work without external cleanup,
- keeps CI and release pipelines green,
- owns data/security/payment risk,
- makes architecture simpler over time,
- keeps docs and code synchronized,
- can lead other engineers,
- can run production systems and handle incidents,
- can prove business-critical impact.

The current tree does not yet demonstrate that level.

## What The Codebase Demonstrates Well

This codebase does contain evidence of strong ability:

- Feature-first Flutter structure across auth, onboarding, runs, run clubs,
  swipes, matches, chats, reviews, payments, safety, and profile.
- Modern Dart patterns: Riverpod generator, Freezed/json models, typed
  repositories, GoRouter, shared design-system primitives.
- Serious Firebase work: Firestore rules, callable Functions, triggers,
  Firebase Admin SDK, App Check, Storage, Auth, Remote Config, Crashlytics,
  Analytics.
- Payment trust-boundary work with Razorpay order creation and payment
  verification on the server.
- Backend unit tests and Firestore rules tests.
- A Firestore contract checker and data-contract documentation.
- Useful technical docs such as `PROJECT_CONTEXT.md`, controller pattern docs,
  runbooks, widget catalog, and Firestore contract tracker.

That is enough to justify a senior offer. It is not enough, in the current
state, to justify ₹1 crore or ₹2 crore without further proof.

## Current Verified Blockers

### 1. The working tree is not professionally handoff-ready

The current tree has hundreds of dirty paths: modified files, deleted docs,
deleted Dart files, new untracked Functions, new untracked Flutter files, new
test folders, generated files, and tooling changes all mixed together.

That is acceptable during active development. It is not acceptable as evidence
for a ₹1 crore engineer unless the person can also show disciplined PR slicing,
reviewable commits, and a consistently green handoff.

At this compensation level, I would expect:

- small, reviewable PRs,
- isolated backend/client/rules/doc changes,
- no stale generated files,
- no stale deleted imports,
- clear migration notes,
- every change leaving the repo green.

### 2. Flutter verification is not green

Recent local verification of the current dirty tree showed:

- `flutter analyze` fails on the full repo because `tool/visual_review_app.dart`
  still imports the deleted `package:catch_dating_app/theme/app_theme.dart` path
  and references screens that moved or were renamed.
- `flutter analyze lib test` has no compile errors, but still fails the strict
  analyzer policy with directive-ordering issues, an unnecessary import, and
  Riverpod keep-alive warnings.
- `flutter test --concurrency=1` fails in `test/safety/settings_screen_test.dart`.
  The failures include a pending Riverpod timer, missing signed-in state for a
  settings preference write, blocked-account expectations not rendering, and an
  off-screen delete-account tap.

This matters because a ₹1 crore engineer should not leave the main app/test
surface in a known failing state. The backend being green is good, but the app
side still needs cleanup.

### 3. CI is far below a staff-level production bar

The only GitHub workflow currently visible is Firestore-rules focused:

- It runs a Firestore contract check and Firestore rules emulator tests.
- It does not run `flutter analyze`.
- It does not run `flutter test`.
- It does not run Android, iOS, or web builds.
- It does not run the full Functions test suite.
- It uses Node `20` in CI while `functions/package.json` declares engine
  `node: 24`.

For a normal senior engineer, this is fixable. For a ₹1 crore engineer, this is
a direct blocker. CI is the mechanism that proves the person can maintain
quality without relying on manual cleanup.

At the ₹1 crore bar, CI should include at minimum:

- `flutter analyze`,
- full or appropriately sharded `flutter test`,
- Functions lint/build/tests,
- Firestore rules emulator tests,
- data-contract checks,
- Android release build,
- web build,
- iOS archive/export where signing is available,
- artifact retention,
- branch protection requiring green checks.

### 4. Internal tooling is stale

`tool/visual_review_app.dart` is currently stale. It imports the old theme path
and references renamed or moved UI screens.

That is not just a minor tool bug. It indicates that refactors are not updating
the full developer workflow. A high-compensation engineer should keep internal
tools working because those tools are how UI quality, design consistency, and
manual review stay cheap.

### 5. Documentation and trackers show drift

The repo has many useful docs, but there are also signs of drift:

- Many old email-draft docs are deleted in the current tree.
- Multiple audit/tracker docs coexist.
- The Firestore/Functions tracker still contains unchecked migration items even
  while code appears to have already moved run creation and host run edits to
  callables.
- Some docs explicitly warn that they are historical snapshots and must be
  re-verified before being trusted.

For a senior engineer, this is normal project evolution. For ₹1 crore+, the bar
is higher: docs should be a reliable operational source of truth, not a pile of
partly-current audit notes.

### 6. Sensitive debug logging remains in auth and startup paths

`lib/auth/presentation/auth_controller.dart` logs the national phone number,
country code, and formatted phone number during OTP send. That is personally
identifiable information.

`lib/main.dart` logs App Check setup details and warning paths during startup.
Those logs may be useful during development, but they should be deliberately
gated or removed before production.

For a dating app with phone numbers, DOB, location, photos, gender, payments,
blocking, reporting, and account deletion, privacy hygiene needs to be stricter.
At ₹1 crore+, I would expect the engineer to proactively eliminate PII logging,
add log redaction rules, and document what is safe to log.

### 7. The data model is still MVP-scale in important places

The app still uses array fields for several relationship-heavy surfaces:

- `runClubs.memberUserIds`
- `runs.signedUpUserIds`
- `runs.attendedUserIds`
- `runs.waitlistUserIds`
- `users.joinedRunClubIds`
- `users.savedRunIds`

The current contract docs acknowledge this is acceptable for MVP scale, but
that edge documents may be needed before larger clubs, high-churn runs, or
contention-heavy production usage.

This is not an immediate reason to reject the developer. But it is a reason not
to pay principal-level compensation yet. A ₹1 crore+ engineer should be able to
design and execute the next data-model migration before the current model
becomes a scaling or reliability problem.

Expected proof:

- read-only production/staging data validator,
- document-size and array-length monitoring,
- migration plan from arrays to edge documents,
- dual-write or backfill strategy,
- rollback plan,
- rules and indexes updated safely,
- measured query cost and contention risk.

### 8. Production operations are not yet demonstrated

There are useful runbooks, but the repo does not yet prove a complete
production operating model:

- no fully automated release pipeline,
- no required CI builds for every platform,
- no visible crash-free/session health gate,
- no alerting policy,
- no incident-response checklist tied to owners and severity,
- no automated rollback path,
- no production smoke-test automation,
- no demonstrated TestFlight/Play/App Store release cadence in CI.

₹1 crore+ compensation requires production ownership, not just implementation.
The person should be able to run the app as a live business system.

### 9. Test coverage is broad but not yet reliable enough

There are many Flutter tests and backend tests, which is a strength. But the
full Flutter suite currently fails. There are also signs of fragile widget
tests: off-screen taps, pending timers, and provider override drift.

At a high senior/staff level, the expectation is not just "writes tests." The
expectation is "keeps tests trustworthy."

Expected proof:

- full `flutter test --concurrency=1` green,
- no pending timers,
- no brittle off-screen taps,
- test utilities that model auth/profile state consistently,
- focused integration tests for core revenue and safety flows,
- regression tests for every high-risk bug fixed.

### 10. Architecture is good, but simplification is still incomplete

The app has good feature boundaries, but there are still surfaces that look
like an evolving solo codebase rather than a mature staff-level codebase:

- multiple controller patterns coexist,
- several large stateful screens still own a lot of orchestration,
- some generated/provider changes leave analyzer warnings,
- documentation has to explain many patterns rather than one dominant,
  enforced convention,
- visual-review tooling broke during refactors.

This is normal for a fast solo build. It is not yet the kind of simplified,
boring, self-enforcing architecture I would expect from a ₹1-2 crore engineer.

## What He Would Need To Demonstrate For ₹1 Crore

I would consider ₹1 crore only after he demonstrates the following in the
current repo, not just in conversation.

### 1. Clean technical baseline

He should get the current tree to a state where these pass from a fresh clone:

```bash
flutter analyze
flutter test --concurrency=1
npm --prefix functions run lint
npm --prefix functions run build
npm --prefix functions test
firebase emulators:exec --only firestore "npm --prefix functions run test:rules"
./tool/check_data_contract.sh
```

He should also explain each failure he fixed and why it happened.

### 2. Proper CI and release gates

He should implement CI that proves every PR is safe:

- Flutter analyze/tests,
- Functions lint/build/tests,
- Firestore rules tests,
- data-contract checks,
- Android/web builds,
- iOS build where signing allows,
- required branch protections,
- artifact upload,
- clear failure ownership.

He should align CI Node version with Functions runtime requirements.

### 3. Production-grade privacy/security posture

He should remove or gate PII/debug logging, then produce a short security note
covering:

- what data is sensitive,
- what is logged,
- what is never logged,
- App Check enforcement expectations,
- rate limits and abuse controls,
- payment trust boundaries,
- block/report/account-deletion behavior,
- data retention and deletion assumptions.

### 4. Data migration and scale ownership

He should present and, if needed, implement the next data-model plan:

- when arrays become unsafe,
- how edge docs would work,
- migration sequencing,
- indexes,
- rules changes,
- compatibility window,
- rollback,
- validation against dev/staging/prod data.

The untracked `tool/validate_firestore_data.mjs` is a good start, but for this
bar it needs to be reviewed, committed, documented, run against dev/staging,
and integrated into the release process where appropriate.

### 5. Release execution

He should personally run and document a release candidate through:

- dev deployment,
- staging deployment,
- Firebase rules/functions deployment,
- Android build,
- iOS archive/export or TestFlight path,
- web build,
- smoke tests for auth, profile, club create/join/leave, run create/book,
  payment verification, chat, block/report/delete,
- rollback plan.

### 6. Product and technical judgment

He should be able to defend:

- why each direct client write is safe or why it moved to a callable,
- why each provider is keepAlive or autoDispose,
- how payment idempotency works,
- how duplicate trigger execution is handled,
- how blocked/deleted users are protected,
- how app links and route redirects behave,
- how to diagnose a failed booking or failed OTP in production.

The standard here is not "knows the code." The standard is "can protect the
business under pressure."

### 7. Leadership evidence

If the offer is for more than an individual contributor role, he should show:

- PR review standards,
- how he would onboard another engineer,
- which parts of the architecture he would freeze,
- which parts he would refactor,
- how he prioritizes bugs vs features,
- how he handles production incidents,
- how he makes tradeoffs between launch speed and correctness.

## What Would Justify ₹2 Crore

₹2 crore requires much more than cleaning this repo.

I would expect proof of principal or engineering-lead impact:

- has shipped and operated comparable production apps at scale,
- can own architecture across multiple apps/services,
- can hire and lead engineers,
- can define engineering process,
- can make security/privacy/compliance decisions,
- can own revenue-critical payment flows,
- can drive product outcomes, not just code output,
- can reduce operational risk for the company,
- can create leverage beyond their own commits.

The current repo alone does not demonstrate that.

## Suggested Negotiation Position

Do not frame this as "you are not worth it." Frame it as:

"The codebase shows strong senior ability, but ₹1 crore is a staff/founding
engineer bar. To make that offer, I need evidence that you can leave the repo
green, own production, own release quality, own data/security risk, and lead
the engineering system around the product. Here is the concrete bar."

Reasonable offer structure:

- Base offer at a strong senior level.
- Written 60-90 day milestone plan.
- Significant raise or bonus only after the repo is green, CI is complete, a
  release candidate is shipped, and production/data/security ownership is
  demonstrated.
- Equity or success bonus can cover upside if he truly behaves like a founding
  engineer.

## Practical Trial Assignment

Before considering ₹1 crore, ask him to complete this without external cleanup:

1. Clean the dirty tree into reviewable commits or PRs.
2. Make `flutter analyze` fully green.
3. Make `flutter test --concurrency=1` fully green.
4. Fix or delete stale `tool/visual_review_app.dart`.
5. Add CI for Flutter, Functions, Firestore rules, data contracts, and builds.
6. Remove PII/debug logging from auth/startup paths.
7. Commit and document the Firestore live-data validator.
8. Run a dev/staging release-candidate checklist.
9. Present a data-model scale plan for membership/sign-up arrays.
10. Walk through one simulated incident: paid booking succeeds in Razorpay but
    app sign-up fails.

If he handles that cleanly, his case for ₹1 crore becomes much stronger.

If he cannot, the current codebase supports a senior offer, not a ₹1-2 crore
offer.
