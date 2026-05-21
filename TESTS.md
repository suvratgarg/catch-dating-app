# Catch Test Status

Last updated: 2026-05-21

This file is the human-readable test policy and inventory. It should not try to
hand-maintain every test filename; the repo changes too quickly for that to stay
true. Use the commands below for the live list.

## Live Inventory Commands

```bash
find test -maxdepth 2 -type f -name '*test.dart' | sort
find functions -path '*test*' -type f | sort
```

Normal local verification:

```bash
flutter analyze
flutter test --concurrency=1
npm --prefix functions run lint
npm --prefix functions test
./tool/validate_firebase_environment.sh <active-env>
```

Rules tests need the Firestore and Storage emulators unless they are already
running:

```bash
firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"
```

## Current Test Areas

Flutter coverage currently spans analytics, auth, dashboard, events, clubs,
event-success surfaces, force update, image uploads, locations, onboarding,
payments, profile/user profile, public profile, reviews, routing, safety,
swipes/catches, chats/matches, and shared UI primitives.

Functions coverage currently spans callable App Check guards, payments, event
booking/waitlist/cancellation paths, clubs, event success, places, safety,
waitlist HTTP, Firestore rules, and Storage rules.

The audit registry stores detailed pass evidence in
`docs/audit_registry/passes.jsonl` and per-file status in
`docs/audit_registry/files.jsonl`. Use those for historical proof instead of
recreating long Markdown checklists.

## Known Gaps

- No default end-to-end device test covers real phone OTP, photo upload, push
  delivery, Razorpay checkout, and the full booking -> catches -> chat loop.
- Store-distributed smokes still need Play internal testing and deliberate
  TestFlight/Xcode Cloud evidence when release-critical settings change.
- Golden testing is intentionally limited; visual regression coverage is not a
  durable substitute for device QA on the core 390 x 844 surfaces yet.
- Live-service checks for App Check, Analytics DebugView, Crashlytics
  symbolication, native maps, and push should stay out of the default PR suite
  until they have stable credentials, fixtures, cleanup, and run targets.

## Policy

- Prefer focused tests near the feature that owns the behavior.
- Add emulator-backed rules tests for every Firestore or Storage rule change.
- Add repository/controller tests when moving behavior out of widgets.
- Do not add another root-level aspirational checklist. If a new gap needs to
  survive across sessions, add it to the relevant durable doc or the audit
  registry backlog with a stable id.
