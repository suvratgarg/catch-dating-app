---
doc_id: firestore_contract_tracker
version: 2.2.17
updated: 2026-05-08
owner: recursive_audit_loop
status: active
---

# Firestore, Functions, and Data Contract Cleanup Tracker

## Read Policy

Read this before Firestore rules, Functions mutation, schema-sync, or data
contract work. Stamp touched files against this doc version in the audit
registry when applying contract rules.

## User Instructions

The goal of this pass is to clean up Firestore rules, Cloud Functions mutation
boundaries, Dart/TypeScript schema drift, and operational safeguards so
production data is not broken by brittle client writes or stale rules.

Create this tracker in `docs/` and use it as the source of truth. Work through
each task one at a time. After each pass, verify the work with focused analyze,
tests, rules tests, Functions checks, or other relevant commands before moving
on. Do not skip steps. If new risks or required tasks are discovered, append
them here and keep the tracker self-documenting so it becomes better guidance
over time rather than a static checklist.

If the conversation context closes, restart from this file, `PROJECT_CONTEXT.md`,
`functions/README.md`, `firebase/README.md`, and the current `git status`.

## Operating Rules For This Pass

- Preserve unrelated dirty worktree changes. Do not revert files just because
  they were already modified before this pass.
- Keep multi-document business mutations out of direct client Firestore writes
  unless there is a clear, documented reason.
- Prefer boring Firestore rules: authentication, ownership, field allowlists,
  and narrow direct-write validation. Put business workflows in callables or
  triggers.
- Keep Dart models, generated Functions TypeScript interfaces, Firestore rules,
  rules tests, callable validation, and docs aligned in the same pass.
- Run Firestore rules tests under the Firestore emulator. From the repo root,
  use:

  ```bash
  firebase emulators:exec --only firestore "npm --prefix functions run test:rules"
  ```

  The standalone `npm run test:rules` / `node --test
  test/firestore.rules.test.cjs` command expects a Firestore emulator already
  listening on `127.0.0.1:8080`. If it fails with `connect ECONNREFUSED
  127.0.0.1:8080`, treat that as an emulator-workflow failure first, not a
  rules regression.
- After every implementation slice, update this tracker with:
  - what changed,
  - what was verified,
  - what failed or remains risky,
  - what task should run next.
- Add migration notes before tightening rules around data that may already
  exist in production.

## Current Diagnosis

The app has multiple contracts for the same Firestore documents:

- Dart Freezed/json_serializable domain models.
- Generated Functions TypeScript interfaces in `functions/src/shared/firestore.ts`.
- Handwritten Firestore rule shape checks in `firestore.rules`.
- Rules emulator fixtures in `functions/test/firestore.rules.test.cjs`.
- Callable input validation in Functions.
- Live Firestore documents in dev/staging/prod.
- Client repository mutation methods.

## 2026-05-07 Relationship Rules And Deletion Slice

- Added callable-owned `leaveRunWaitlist` and removed the last direct client
  run update path. Direct `runs/{runId}` updates are now denied.
- Removed saved-run profile projection writes. `SavedRunRepository` writes only
  `savedRuns/{uid_runId}` and rules deny direct private-profile projection
  changes.
- Swipes and reviews now use `runParticipations/{runId_uid}` attendance edges
  for eligibility instead of run roster projections. Private `users/{uid}`
  reads are owner-only; app-facing discovery should use `publicProfiles`.
- `requestAccountDeletion` now performs query-driven cleanup across
  memberships, participations, saved runs, swipes, matches, reviews, payments,
  notifications, blocks, and reports before anonymizing the private profile and
  deleting Auth.
- Added backend lifecycle surfaces:
  - `deleteRun` hard-deletes only unused hosted runs with no participations,
    payments, or reviews.
  - `archiveRunClub` marks clubs archived.
  - `deleteRunClub` hard-deletes only never-used clubs with no runs, payments,
    reviews, or non-host members.
- Added `RunClubLifecycleStatus`, `archived`, `archivedAt`, and
  `archiveReason` to the Dart/Functions schema contract.
- Relationship participant/member/saved-run arrays have been retired from
  generated models, Functions write paths, Firestore rules, active tooling, and
  active tests. Relationship state now lives only in edge documents plus
  callable-owned aggregate counts on canonical parent documents.

`tool/generate_firestore_types.dart` already protects Dart-to-TypeScript drift,
and CI checks that generated output is committed. It does not protect
Firestore rules drift, callable validation drift, live data migrations, or
operation ownership drift.

## Recent Contract Notes

### 2026-05-08: Functions Queue Hardening Slice

- Added a testable `onSwipeCreatedHandler` seam and focused tests for
  reciprocal match creation plus blocked-match suppression. The Firestore
  trigger remains a thin adapter over the handler.
- Tightened the moderation text filter so single-word block/flag terms match
  whole words instead of arbitrary substrings. This avoids false positives such
  as blocking benign references to "Pakistan" while preserving explicit listed
  term and phrase matching.
- Changed Razorpay signature verification to use `crypto.timingSafeEqual`
  through `verifyPaymentSignatureWithSecret`, with tests for valid and malformed
  signatures.
- Added a testable `signUpForFreeRunHandler` seam. The callable now trims and
  rejects blank `runId` values, rate-limits before reading run docs, verifies
  the run is free, and delegates booking to the shared sign-up helper.
- Report writes now trim bounded optional fields and omit blank optional notes
  instead of storing raw whitespace.
- Added a testable `syncRunClubReviewStatsHandler` seam. The review aggregate
  trigger now remains a thin adapter while focused tests cover rating/count
  recompute, last-review deletion reset, and review moves between clubs.
- Fixed the Functions test entrypoint to include compiled review tests through
  `lib/reviews/*.test.js`, so review trigger coverage is part of the normal
  `npm --prefix functions test` command.
- Added aggregate repair tooling for post-relationship-migration data:
  - `tool/recompute_run_club_member_counts.mjs` recomputes
    `runClubs/{clubId}.memberCount` from active
    `runClubMemberships/{clubId_uid}` edge documents.
  - `tool/recompute_run_aggregate_counts.mjs` recomputes
    `runs/{runId}.bookedCount`, `checkedInCount`, `waitlistedCount`, and
    `genderCounts` from `runParticipations/{runId_uid}` edge documents.
  - `tool/validate_firestore_data.mjs` now reports member/run aggregate drift
    by comparing parent projections to the current edge-document source of
    truth.
- Dev data repair completed after the edge-document migration:
  - `node tool/recompute_run_club_member_counts.mjs --env dev --json` found 2
    stale run-club count projections and 0 membership edges.
  - `node tool/recompute_run_club_member_counts.mjs --env dev --apply`
    reset both stale `memberCount` projections to 0.
  - `node tool/recompute_run_aggregate_counts.mjs --env dev --json` found 4
    stale run aggregate projections and 0 participation edges.
  - `node tool/recompute_run_aggregate_counts.mjs --env dev --apply`
    reset those run count projections and `genderCounts` from the edge source.
  - `node tool/validate_firestore_data.mjs --env dev --json` then scanned 10
    docs with 0 errors and 0 warnings.
- Verification: `npm --prefix functions run lint` and
  `npm --prefix functions test` passed, focused review tests passed through
  `node --test functions/lib/reviews/*.test.js`, aggregate repair tool tests
  passed through `node --test tool/recompute_run_club_member_counts.test.mjs
  tool/recompute_run_aggregate_counts.test.mjs`, and dev live-data validation
  passed with 0 errors / 0 warnings.
- Next Functions queue: add handler seams and focused tests for remaining
  trigger/direct callable files that are not yet covered by the normal suite,
  starting with `syncPublicProfile`, `moderateChatMessage`,
  `moderatePhotoOnUpload`, `joinRunWaitlist` / `leaveRunWaitlist`,
  `cancelRunSignUp`, `markRunAttendance`, and `selfCheckInAttendance`.

### 2026-05-07: Relationship Array Retirement

- Removed run-club membership arrays, run participation arrays, and saved-run
  arrays from Dart domain models, generated Functions types, Cloud Functions
  writes, Firestore rules, active validation tooling, and active tests.
- Booking, waitlist, cancellation, attendance, and self-check-in Functions now
  read roster state from `runParticipations` and maintain only
  `bookedCount`, `waitlistedCount`, `checkedInCount`, and `genderCounts` on
  `runs/{runId}`.
- Run-club create/join/leave Functions now read membership state from
  `runClubMemberships` and maintain only `memberCount` on
  `runClubs/{clubId}`.
- `users/{uid}` no longer carries run-club membership or saved-run projections.

### 2026-05-07: Notification Preferences, Club Bell, And Run Reminders

- Added granular user notification preferences to `users/{uid}`:
  `prefsMessages`, `prefsRunStatusUpdates`, and `prefsClubUpdates`, while
  retaining `prefsNewCatches`, `prefsRunReminders`, and `prefsWeeklyDigest`.
- Added `runClubMemberships/{clubId_uid}.pushNotificationsEnabled` as the
  per-club bell opt-in. Active membership still means club updates appear in
  Activity; the bell gates FCM push for non-critical club updates.
- Added `setRunClubNotificationPreference` callable so the client does not
  write membership-edge notification flags directly.
- Added scheduled `sendRunReminders`, which creates deterministic
  `runReminder_${runId}` durable items and pushes roughly 15 minutes before a
  signed-up run starts. Existing durable reminder docs suppress duplicate local
  derived rows in the Activity tab.
- Updated push policy: matches use `prefsNewCatches`, messages use
  `prefsMessages`, reminders use `prefsRunReminders`, schedule/cancellation and
  waitlist promotion use `prefsRunStatusUpdates`, and club updates require both
  `prefsClubUpdates` and the per-club bell.

### 2026-05-07: Run Schedule-Change And Cancellation Notifications

- Added canonical run lifecycle fields to `Run`: `status`, `cancelledAt`, and
  `cancellationReason`. Existing reads default missing `status` to `active` in
  Dart for legacy/beta data tolerance.
- `createRun` initializes lifecycle fields as active. `cancelRun` is now a
  host-only callable that marks the run cancelled and fans out deterministic
  `runCancelled_${runId}` durable activity items plus push notifications to
  signed-up and waitlisted participants.
- `updateRun` now fans out deterministic `runUpdated_${runId}` activity items
  and push notifications only when schedule/location fields change. Copy-only
  edits stay quiet.
- Cancelled runs are blocked from new free signups, paid order creation,
  waitlist joins, host attendance toggles, and self-check-in.
- Remaining product debt: define cancellation/refund policy, add host-facing
  cancellation UI, and decide how cancelled runs should render on list/detail
  surfaces.

### 2026-05-07: Club Hosted-Run Notifications

- Extended `NOTIFICATIONS-QUEUE` to new runs posted by followed clubs.
- `createRun` now performs best-effort fan-out after the run document commits:
  active `runClubMemberships` members receive deterministic
  `clubUpdate_${runId}` activity items, while the host is excluded.
- Push is now sent only to active members with an FCM token, global
  `prefsClubUpdates != false`, and per-membership
  `pushNotificationsEnabled == true`; the durable in-app item is written
  regardless of push preference.
- Remaining notification producers from this note were completed in the
  notification preferences/reminder pass above.

### 2026-05-07: Run Signup And Waitlist Promotion Notifications

- Extended the durable activity timeline to run booking state changes.
- `signUpUserForRun` now writes a deterministic `runSignup_${runId}` activity
  item for normal booking confirmations and a `waitlistPromotion_${runId}` item
  when the user was waitlisted before the successful signup.
- `cancelRunSignUp` now writes a `waitlistPromotion_${runId}` activity item
  for the waitlisted user it promotes, and sends a push notification to that
  user when an FCM token is available.
- Self-initiated booking confirmations remain in-app only to avoid a redundant
  push for the action the user just performed.
- Remaining notification producers from this note were completed in later
  2026-05-07 notification slices.

### 2026-05-07: Durable Activity Notifications

- Started `NOTIFICATIONS-QUEUE` with a backend-owned durable activity timeline
  at `notifications/{uid}/items/{notificationId}`.
- Added generated Dart and Functions contracts for `ActivityNotification`.
- `onMatchCreated` now writes deterministic match activity items for both
  participants and sends push notifications through the shared notification
  helper.
- `onMessageCreated` now writes deterministic recipient activity items in the
  same transaction that updates unread counts and event receipts.
- The Home Activity tab now reads `watchActivityNotificationsProvider(uid)`
  for durable match/message activity and keeps deriving upcoming run reminders
  locally until run producers are implemented.
- Firestore rules allow users to read only their own notification timeline and
  update only `readAt`; client-created notification items and content edits are
  denied.
- Remaining notification producers after this foundation pass were upcoming run
  reminders, signup/waitlist promotion, run cancellation/schedule changes, and
  club/hosted-run updates. Signup/waitlist promotion was implemented in the
  following slice above.

### 2026-05-06: Callable Rate Limit Enforcement

- Closed `FUNCTIONS-RATE-LIMIT-001`: every callable named in the Functions
  audit now enforces its declared shared rate limit before expensive or
  destructive work.
- Added enforcement to `verifyRazorpayPayment`, `cancelRunSignUp`,
  `joinRunWaitlist`, `blockUser`, `unblockUser`, and
  `requestAccountDeletion`.
- Added `updateUserProfile` to `RATE_LIMITS` at 60 requests/minute. This keeps
  profile edit sheets responsive for field-by-field saves while preventing an
  unbounded write loop.
- Added focused Functions tests for the handler seams that can prove ordering:
  payment verification stops before signature/Razorpay fetch, profile updates
  stop before writes, safety block/unblock stop before writes/deletes, and
  account deletion stops before storage/Auth/Firestore destructive work.

### 2026-05-06: Functions Architecture And Operation Catalog Audit

- Added `docs/backend_operation_catalog.md` as the human-readable catalog of
  backend write initiators, Cloud Function ownership, direct Firestore writes,
  trigger-owned projections, server-only collections, and notification starting
  points.
- `tool/firestore_contract.json` remains the machine-readable source for
  collection operation ownership and rules-sensitive field groups.
- Fixed contract drift: `users/{uid}.firstName`, `lastName`, and `displayName`
  were present in Dart, generated Functions TypeScript, and Firestore rules but
  missing from `tool/firestore_contract.json`.
- Fixed account deletion anonymization: retained `users/{uid}` docs now clear
  `firstName`, `lastName`, and `displayName` in addition to legacy `name`.
- Functions build and unit tests passed, and the contract checker now passes.

Follow-up debt:

- `NOTIFICATIONS-QUEUE`: durable activity timeline exists for match/message
  events; add the remaining run and club producers through the same
  backend-owned helper.

### 2026-05-06: UserProfile.displayName

- `users/{uid}.displayName` is now the editable public display name.
- Onboarding initializes it from first name; edit profile can change it later.
- It is required for new profile creation and must contain non-whitespace text.
- `syncPublicProfile` writes public profile `name` from `displayName`, then
  falls back to first name, then legacy full-name first token.
- `lastName` remains private identity data and must not be used for public
  profile rendering.
- Contract pass checklist for this field: Dart `UserProfile`, generated
  Freezed/json, generated `functions/src/shared/firestore.ts`, callable Zod
  validation, Firestore rules, rules fixture, onboarding tests, profile widget
  tests, and domain tests.

### 2026-05-06: Relationship Documents And Match-Scoped Messages

- Added `docs/firestore_relationship_documents_migration.md` as the active
  tracker for relationship/action docs, match-scoped messages, migration
  tooling, and deletion/anonymization payoff.
- Added generated Dart/TypeScript models for `RunClubMembership`,
  `RunParticipation`, and `SavedRun`.
- `ChatMessage` now lives under
  `matches/{matchId}/messages/{messageId}` instead of the legacy
  `chats/{matchId}/messages/{messageId}` namespace.
- Cloud Functions now write `runClubMemberships` for club create/join/leave and
  `runParticipations` for signup, waitlist, cancellation, host attendance, and
  participant self-check-in.
- Dashboard, Run Clubs list/detail, and Run Map membership reads now use
  `runClubMemberships`.
- `savedRuns/{uid_runId}` is now the owner-owned saved-run edge. Run detail
  reads saved state from the edge document; save/unsave do not mirror to the
  private user profile.
- Run detail reads the current viewer's booking, waitlist, attendance, and
  review-gate state from `runParticipations/{runId_uid}`. The run participant
  aggregate fields are count projections only.
- `watchSignedUpRunsProvider` and `watchAttendedRunsProvider` now read
  `runParticipations` by user/status and then watch matching run documents by
  ID. Dashboard, Calendar, Run Map, Activity, and Swipe Hub use those
  edge-backed streams without changing their screen-level provider contracts.
- Host attendance management now reads roster and checked-in state from
  `runParticipations` through `AttendanceSheetViewModel`.
- Swipe candidate generation, swipe empty-state attendance gating, and run
  recap attendee/checked-in state now read `runParticipations`.
- Swipe and review Firestore rules now use `runParticipations` for attendance
  eligibility. `users/{uid}` private reads are owner-only; app-facing discovery
  must use `publicProfiles/{uid}`.
- Run participation count projections are now explicit `runs/{runId}` fields:
  `bookedCount`, `waitlistedCount`, and `checkedInCount`. Create/signup,
  payment verification, waitlist, cancellation, host attendance, and self
  check-in Functions maintain these fields. `WhoIsRunning` and
  `HostRunManageScreen` use
  `runParticipations` for exact rosters; list/stat surfaces use count
  projections. Production UI grep for direct participant-array reads is clean
  apart from generated `Run` serialization.
- Firestore rules and emulator tests now cover relationship-doc read/write
  ownership and match-scoped message creation.
- `tool/firestore_relationship_migration.mjs` now only copies legacy
  `chats/{matchId}/messages` into `matches/{matchId}/messages`; it no longer
  reconstructs edge docs from retired arrays.
- `tool/validate_firestore_data.mjs` validates relationship edges and parent
  aggregates instead of parent relationship arrays.

Follow-up debt:

- `RELATIONSHIP-DOC-MIGRATION`: keep on watch for regressions; do not re-add
  relationship arrays to models, Functions, rules, active tooling, or tests.
- `DELETE-METHODOLOGY-QUEUE`: rewrite account/run/club deletion around
  relationship-doc queries.
- `MIGRATION-VALIDATION-001`: add migration apply count validation and seeded
  fixture tests before running apply on shared beta data.

## Phases

### Phase 0: Tracker And Baseline

- [x] Create this tracker.
- [x] Record current dirty-worktree boundaries before editing implementation
  files.
- [x] Run or record focused baseline checks for the current Firestore/Functions
  surface.
- [x] Update stale docs references from `functions/src/types/firestore.ts` to
  `functions/src/shared/firestore.ts`.

### Phase 1: Move Run Club Membership To Cloud Functions

- [x] Add `createRunClub` callable so initial club creation and host membership
  projection are server-owned.
- [x] Add `joinRunClub` callable.
- [x] Add `leaveRunClub` callable.
- [x] Use shared callable App Check options.
- [x] Use shared auth and validation helpers.
- [x] Use shared callable rate limiting for create/join/leave club operations.
- [x] Make both callables idempotent.
- [x] Create/update `runClubMemberships/{clubId_uid}`.
- [x] Update `runClubs/{clubId}.memberCount`.
- [x] Retire profile and club membership arrays.
- [x] Reject deleted users and missing/incomplete profiles.
- [x] Add Function unit tests for success, idempotency, missing docs, and
  invalid input.
- [x] Update Flutter repository/client methods to call Functions.
- [x] Update Flutter tests.
- [x] Tighten Firestore rules so `runClubs` creation and membership state are
  callable-owned.
- [x] Fully retire direct profile membership projection updates.
- [x] Update rules tests for denied direct membership writes and allowed
  callable-admin effects via seeded data.
- [x] Verify:
  - [x] `npm --prefix functions run lint`
  - [x] `npm --prefix functions run build`
  - [x] `npm --prefix functions test`
  - [x] `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`
  - [x] Focused `flutter analyze`
  - [x] Focused `flutter test`

### Phase 2: Repository Mutation Boundary Audit

- [x] Inventory every direct client Firestore write.
- [x] Classify each as client-owned, callable-owned, trigger-owned, or legacy.
- [x] Remove or deprecate legacy direct write methods that are no longer used.
- [x] Decide whether `leaveWaitlist` should move to a callable.
- [x] Decide whether `createRun`, and host edits should remain client-direct
  or move to callables.
- [x] Move run-club profile edits and review mutations to callables so rules
  no longer duplicate those validation contracts.
- [x] Document final mutation ownership in this file and `PROJECT_CONTEXT.md`.
- [x] Verify focused analyze/tests after each migrated mutation.

#### Direct Client Write Inventory

Client-owned and acceptable for now:

- `lib/user_profile/data/user_profile_repository.dart`
  - `setUserProfile`, profile field updates, photo URLs, profile-complete flag,
    saved-run array changes, and notification preferences.
  - Rationale: owner-only profile/preference writes are narrow and rules
    validate shape/field ownership.
- `lib/onboarding/data/onboarding_draft_repository.dart`
  - owner-only draft set/delete.
  - Rationale: private per-user draft state; rules are owner-only.
- `lib/chats/data/chat_repository.dart`
  - create chat message only.
  - Rationale: message create is participant-owned; match preview/unread are
    now server-owned by `onMessageCreated`.
- `lib/matches/data/match_repository.dart`
  - reset own unread count to zero.
  - Rationale: narrow participant-owned update; rules restrict the exact map
    key and value.
- `lib/swipes/data/swipe_repository.dart`
  - create own outgoing swipe.
  - Rationale: owner-only create; match creation remains trigger-owned.
- `lib/core/fcm_service.dart`
  - update own `fcmToken`.
  - Rationale: runtime token only; rules allow only this field.

Callable-owned after Phase 1:

- `lib/run_clubs/data/run_clubs_repository.dart`
  - `createRunClub`, `updateRunClub`, `joinClub`, `leaveClub`.
  - Rationale: each writes server-derived fields, aggregate projections, or
    host-authorized profile data that should be Zod-validated server-side.
- `lib/reviews/data/reviews_repository.dart`
  - `createRunReview`, `updateRunReview`, `deleteRunReview`.
  - Rationale: review mutations derive public reviewer name, verify attended
    run participation, enforce ownership, and leave aggregate stats to the
    recompute trigger.

Resolved mutation boundaries:

- `lib/run_clubs/data/run_clubs_repository.dart`
  - `updateRunClub`.
  - Decision: keep direct for now. It is host-owned, single-document, and rules
    freeze membership/rating/derived fields.
- `lib/runs/data/run_repository.dart`
  - `createRun`, host run details update, `leaveWaitlist`.
  - Decision: `createRun` and host run details updates moved to callables in
    Phase 9 so host authority, run/club consistency, and server-owned booking
    state are enforced on the backend. `leaveWaitlist` is now callable-owned
    as well, so clients no longer update `runs/{runId}` directly for waitlist
    state.

Removed or denied:

- `lib/runs/data/run_repository.dart`
  - `signUpForRun`.
  - Decision: removed. Direct `signedUpUserIds` updates bypass capacity, gender
    counts, payments, block checks, and server validation.
- `runClubs` and `runs` direct deletes.
  - Decision: denied in rules and removed from the run-clubs repository API
    where present. Deletes need backend cleanup/refund behavior before they are
    safe to expose.

### Phase 3: Data Contract Tooling

- [x] Fix `tool/generate_firestore_types.dart` so generated
  `functions/src/shared/firestore.ts` is lint-compliant instead of requiring
  manual generated-file formatting.
- [x] Add a canonical Firestore contract artifact under `tool/`.
- [x] Encode collection paths, document owner, readable fields, client-writable
  fields, server-owned fields, nullable fields, and migration notes.
- [x] Extend or complement `tool/generate_firestore_types.dart` so contract
  checks cover rules-sensitive schema metadata.
- [x] Add `tool/check_data_contract.sh`.
- [x] Make the checker run:
  - [x] Dart-to-TypeScript generation drift check.
  - [x] Firestore rules tests.
  - [x] Functions build/lint/tests.
  - [x] Focused Flutter checks where practical.
- [x] Add CI triggers so model/domain/schema changes run Firestore rules tests.
- [x] Verify CI-relevant commands locally.

### Phase 4: Rules Simplification And Shape Validation Strategy

- [x] Review every `hasValid*Shape` function in `firestore.rules`.
- [x] Split high-risk direct-write validation into:
  - [x] document shape,
  - [x] client-create contract,
  - [x] client-update contract,
  - [x] server-owned fields.
- [x] Make optional/new fields tolerant during rollout windows.
- [x] Add comments for every intentional legacy field tolerance.
- [x] Add rules tests for missing optional fields, new optional fields, and
  denied server-owned fields.
- [x] Verify rules tests after each collection group.

Notes:

- `users/{uid}` still validates the full shape on create, but owner profile
  updates now validate field ownership instead of the entire document. This
  avoids Firestore's rules expression ceiling and prevents server-owned retained
  fields such as `deleted`/`deletedAt` from breaking unrelated profile edits.
- `runClubs/{clubId}` direct writes are denied; create/update/archive/delete
  and membership remain callable-owned.
- `onboarding_drafts/{uid}` is intentionally forward-compatible because it is
  private owner-only draft state and changes quickly with onboarding.

### Phase 5: Trigger Idempotency And Derived Data Safety

- [x] Audit Firestore triggers that increment, denormalize, or fan out writes.
- [x] Add idempotency guards or recompute strategies where duplicate events
  could corrupt data.
- [x] Pay special attention to message unread counts, review stats, block
  effects, and public profile sync.
- [x] Add tests for duplicate event handling where feasible.
- [x] Verify Functions tests/build/lint.

Notes:

- `onMessageCreated` now writes `functionEventReceipts/{receiptId}` in the same
  transaction as the match preview/unread-count update so trigger retries do
  not double-increment unread counts.
- `syncRunClubReviewStats` and `syncPublicProfile` recompute/set final state,
  so duplicate events are naturally idempotent.
- `onSwipeCreated` uses deterministic match IDs and `create()`, so duplicate
  trigger execution does not duplicate matches.
- `moderateChatMessage` now uses deterministic moderation flag IDs for chat
  messages so retries do not create duplicate ops tickets.

### Phase 6: Data Model Migration Decision

- [x] Decide whether current arrays are acceptable for expected production
  scale.
- [x] If arrays remain, document limits and monitoring signals.
- [ ] If edge docs are needed, design:
  - [ ] `runClubMemberships/{clubId_uid}`,
  - [ ] `runSignups/{runId_uid}` or equivalent,
  - [ ] backfill scripts,
  - [ ] dual-read/write rollout,
  - [ ] final rules tightening.
- [ ] Do not tighten production rules until migration safety is documented and
  verified against live-like fixtures.

Decision:

- Keep membership/sign-up arrays for this pass now that multi-document
  mutations are callable-owned and idempotent. This is acceptable for MVP-scale
  clubs/runs where member and attendee counts are modest.
- Revisit edge documents before large clubs, high-churn events, or anything
  approaching Firestore's 1 MiB document limit or sustained contention on the
  same run/club document. Monitor document size, transaction contention, and
  permission-denied/write-failed Analytics spikes.

### Phase 7: Operational Cleanup

- [x] Fix docs that conflict about committed App Check debug tokens.
- [x] Decide whether debug tokens should be removed from checked-in
  `tool/dart_defines/dev.json`.
- [x] Ensure deploy runbooks mention required data seeds and rollback order.
- [x] Ensure rules deploy predeploy checks actually run rules tests, not only
  Functions tests.
- [x] Add a production smoke-test checklist for:
  - [x] profile update,
  - [x] create club,
  - [x] join club,
  - [x] leave club,
  - [x] create run,
  - [x] book free run,
  - [x] paid run payment verification,
  - [x] chat send,
  - [x] unread reset,
  - [x] block/report/account deletion.

Notes:

- Removed the checked-in dev App Check debug token. Local device debug tokens
  should be exported via `FIREBASE_APP_CHECK_DEBUG_TOKEN`.
- Firestore deploy predeploy now runs the rules emulator suite, not only
  Functions tests.

### Phase 8: Extended Contract Hardening Review

These tasks come from the second-pass contract review after the basic
Firestore/Functions cleanup passed. They should be handled incrementally with
focused tests after each slice, then a final `./tool/check_data_contract.sh`.

- [x] P1: Tighten `runs/{runId}` host updates. The current host update branch
  only blocks `signedUpUserIds`, `attendedUserIds`, and `genderCounts`, which
  still lets hosts directly change `waitlistUserIds`, `runClubId`,
  `capacityLimit`, `priceInPaise`, and `constraints` after creation. That
  weakens the callable-owned booking/waitlist contract and makes direct
  waitlist self-removal less meaningful. Follow-up complete: waitlist
  self-removal is now callable-owned too, and direct `runs/{runId}` updates are
  denied.
- [x] P1: Validate `swipes/{userId}/outgoing/{targetId}` create payloads. Rules
  currently check owner, deleted-target state, and block state, but not
  `direction`, `runId`, path/data identity, allowed fields, or extra fields. The
  `onSwipeCreated` trigger trusts `direction` and `runId`, so malformed client
  data can create malformed or surprising match records.
- [x] P1: Revisit `users/{uid}` owner profile update validation. The current
  update path validates changed field names but not changed value types. That
  intentionally reduced rollout brittleness, but it also lets a bad client write
  wrong-shaped values that can break decoders or derived triggers such as
  `syncPublicProfile`, which calls `user.dateOfBirth.toDate()`.
- [x] P2: Make `tool/check_firestore_contract.mjs` operation-aware. It currently
  verifies paths, model files, field groups, generated TS interfaces, and
  exported Functions. It does not assert allowed operations, update allowlists,
  path/data consistency, or required negative rules tests, so green contract
  checks can miss rule semantics.
- [x] P2: Resolve the onboarding-draft contract mismatch. The JSON contract
  lists a fixed `onboarding_drafts` field set, while rules intentionally validate
  only `step` for forward-compatible owner-private draft state. Either the
  contract should encode the document as extensible or the rules should enforce
  the fixed field set.
- [x] P2: Clean the run-club creation Flutter API. `RunClubsRepository` still
  accepts `hostUserId`, `hostName`, and `hostAvatarUrl` even though the
  `createRunClub` callable ignores client host identity and derives host fields
  from `users/{uid}`. The server behavior is correct, but the Dart API contract
  is misleading.
- [x] P2: Include moderation tests in `npm test`. The package test script runs
  matching, payments, run-clubs, safety, waitlist, and callable App Check tests,
  but omits compiled moderation tests even though
  `functions/src/moderation/textFilter.test.ts` exists.

Notes:

- Do not start data migration design in this phase. Keep the focus on contract
  correctness and developer ergonomics.
- Prefer rules tests that prove the rejected mutation for each security
  boundary. If a rule becomes too complex, move the operation to a callable with
  Zod validation rather than making Firestore rules brittle again.
- Keep direct writes only where they are owner-scoped, single-document, and
  straightforward to express in rules.

### Phase 9: Approved Contract Follow-Through

These decisions were approved after the Phase 8 review. Work through them in
small slices because they touch backend authorization, UI affordances, rules,
client repository contracts, and live-data readiness.

- [x] Block hosts from leaving their own run club.
  - [x] Reject host leave attempts in the `leaveRunClub` callable.
  - [x] Verify the host detail UI does not expose a leave-club action.
  - [x] Add/adjust tests for both backend rejection and UI hiding.
- [x] Enforce one review per user per run.
  - [x] Use deterministic review IDs derived from `runId` and
    `reviewerUserId`.
  - [x] Update the repository read/write path so it no longer needs a query to
    find the current user's review for a run.
  - [x] Tighten Firestore rules so review document IDs match the deterministic
    contract and review creates require a run-scoped review.
  - [x] Add rules and Dart tests for allowed deterministic creates and denied
    malformed/random-ID creates.
- [x] Move run creation and host run edits toward callable-owned mutation
  contracts.
  - [x] Design/implement `createRun` callable validation that derives host
    authority from the authenticated user and their hosted club.
  - [x] Design/implement host run edit callable validation for schedule and
    descriptive fields while keeping booking, payment, eligibility, attendance,
    and ownership fields server-owned.
  - [x] Update `RunRepository`, controllers, tests, and Firestore rules so
    clients do not directly mutate sensitive run state.
- [x] Add live-data validation tooling before migration.
  - [x] Add a read-only Firestore validation script that checks document shape,
    required fields, array lengths, approximate document size, and edge-case
    values across users, run clubs, runs, reviews, swipes, matches, chats, and
    onboarding drafts.
  - [x] Support dev/staging project selection and emulator mode without
    hard-coding production credentials.
  - [x] Document how to run the validator and how to interpret failures before
    tightening production/staging rules.
- [x] Prepare but do not rush live migration.
  - [x] Run validation against dev/staging first.
  - [x] Inspect the small current production dataset before writing migration
    code.
  - [x] Add migration scripts only after validation output identifies the
    concrete data drift to repair.
  - [ ] Deploy code/rules/functions to dev and staging before production.

Approved decisions:

- Hosts cannot leave clubs they host, and the app should not show hosts a
  leave-club button.
- Reviews should be one per user per run; deterministic IDs are acceptable.
- Run creation and host run edits should move to callable-owned contracts.
- Validation, size, and array-length scripts should be added now; real-data
  migration can follow once the current data drift is known.
- Dev and staging are acceptable deployment targets for this cleanup after local
  verification and environment wiring checks.

## Verification Log

Append newest entries at the top.

- 2026-05-05: Deleted all live review test data after mapping dependencies.
  Added `tool/delete_firestore_reviews.mjs`, a dry-run-first Admin SDK cleanup
  tool that maps all `reviews/{id}` docs, affected `runClubs`, affected `runs`,
  reviewer `users`, detected review-reference fields, and required
  `runClubs.rating`/`reviewCount` resets before applying deletion with
  `--apply --confirm-delete-all-reviews`. Live dry-runs showed that all current
  dev/prod reviews were legacy club-scoped reviews without `runId`; no affected
  run documents or user documents contained review reference fields. Applied
  cleanup to dev and prod. Dev deleted 3 reviews and reset
  `runClubs/frrOLITIukUcUCFFFACS` from rating 3.6666666666666665/reviewCount 3
  to 0/0. Prod deleted 5 reviews and reset
  `runClubs/CPEXusszu0gnrZANT8fE`, `runClubs/Zvm256jqQmL5de98KIoj`,
  `runClubs/fJlZbx9BewUXsOZwQKv3`, and
  `runClubs/kqadT73GGy1o0VRlo98I` to rating 0/reviewCount 0. Staging had no
  reviews. Post-cleanup validation passed:
  `node tool/validate_firestore_data.mjs --env dev --json` scanned 9 docs with
  0 errors and 0 warnings;
  `node tool/validate_firestore_data.mjs --env prod --json` scanned 29 docs
  with 0 errors and 0 warnings. Final local verification passed:
  `./tool/check_data_contract.sh` completed generated TypeScript drift check,
  generator analysis, Firestore contract metadata check, validator/cleanup
  script syntax checks, Functions lint/tests, Firestore rules emulator tests,
  focused Flutter analysis, and focused Flutter tests.
- 2026-05-05: ADC configured and read-only live validation completed.
  `gcloud auth application-default login` saved credentials at
  `~/.config/gcloud/application_default_credentials.json`, and
  `gcloud auth application-default set-quota-project catchdates-dev` attached a
  quota project. Validation results:
  `node tool/validate_firestore_data.mjs --env dev --json` scanned 12 docs with
  0 errors and 3 legacy review warnings;
  `node tool/validate_firestore_data.mjs --env staging --json` scanned 0 docs
  with 0 errors and 0 warnings;
  `node tool/validate_firestore_data.mjs --env prod --json` scanned 34 docs
  with 0 errors and 5 legacy review warnings. The only live-data migration
  surface found so far is old club-scoped reviews without `runId`.
- 2026-05-05: Attempted read-only live validation for dev with
  `node tool/validate_firestore_data.mjs --env dev --json`. The Firebase CLI is
  logged in and can list dev/staging/prod projects, but the Admin SDK validator
  could not load Application Default Credentials because neither
  `GOOGLE_APPLICATION_CREDENTIALS` nor
  `~/.config/gcloud/application_default_credentials.json` is configured in this
  shell. `firebase/README.md` now documents the credential requirement. Next
  step: configure ADC or a read-only service account, then run dev and staging
  validation before migration or deploy.
- 2026-05-05: Phase 9 final full data-contract verification passed:
  `./tool/check_data_contract.sh` completed generated TypeScript drift check,
  generator analysis, operation-aware Firestore contract metadata check,
  Firestore data validator syntax check, Functions lint, Functions tests
  including run mutation tests, Firestore rules emulator tests, focused Flutter
  analysis, and focused Flutter repository tests.
- 2026-05-05: Phase 9 live-data validation tooling added. The read-only
  `tool/validate_firestore_data.mjs` script resolves project aliases from
  `.firebaserc`, supports emulator mode, checks required field types,
  approximate document size, high-growth array lengths, deterministic review
  IDs, path/data identity, and cross-document references across users,
  public profiles, run clubs, runs, reviews, swipes, matches, chat messages,
  and onboarding drafts. `firebase/README.md` now documents the commands.
  Verification passed:
  `node --check tool/validate_firestore_data.mjs`;
  `node tool/validate_firestore_data.mjs --help`;
  `firebase emulators:exec --only firestore "node tool/validate_firestore_data.mjs --env dev --emulator --json"`.
- 2026-05-05: Phase 9 run mutation callable migration completed. Added
  `createRun` and `updateRun` callables with Zod validation, host authority
  checks, rate limiting, server-owned booking arrays, and transport-safe epoch
  millis for timestamps. `RunRepository.createRun` now calls `createRun`, and
  `updateRunDetails` calls `updateRun`. Firestore rules now deny direct run
  creates and direct host detail edits. A later relationship-doc slice moved
  waitlist self-removal behind `leaveRunWaitlist` as well. Verification passed:
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node --test functions/lib/runs/mutateRun.test.js`;
  `node tool/check_firestore_contract.mjs`;
  `flutter analyze lib/runs/data/run_repository.dart lib/runs/presentation/create_run_controller.dart test/runs/run_repository_test.dart test/runs/create_run_controller_test.dart`;
  `flutter test test/runs/run_repository_test.dart test/runs/create_run_controller_test.dart`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`;
  `npm --prefix functions test`.
- 2026-05-05: Phase 9 deterministic run reviews completed. Review creates now
  use `runId~reviewerUserId` document IDs, `watchUserReviewForRun` reads the
  deterministic document directly, club pages show read-only review aggregates,
  and Firestore rules require deterministic run-scoped review creates from
  attended users with matching user names. Verification passed:
  `node tool/check_firestore_contract.mjs`;
  `flutter analyze lib/reviews/data/reviews_repository.dart lib/reviews/presentation/reviews_section.dart test/reviews/reviews_repository_test.dart test/runs/run_detail_widgets_test.dart test/run_clubs/run_clubs_widgets_test.dart`;
  `flutter test test/reviews/reviews_repository_test.dart`;
  `flutter test test/run_clubs/run_clubs_widgets_test.dart --plain-name "ClubDetailBody keeps club review aggregate read-only"`;
  `flutter test test/runs/run_detail_widgets_test.dart --plain-name "renders detail sections and review CTA when attended"`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`.
- 2026-05-05: Phase 9 host leave guard completed. The `leaveRunClub`
  callable now rejects attempts by `hostUserId`, and the host club detail
  widget test explicitly verifies that hosts do not see `Leave club`.
  Verification passed:
  `npm --prefix functions run build`;
  `node --test functions/lib/runClubs/membership.test.js`;
  `flutter analyze lib/run_clubs/presentation/detail/widgets/club_detail_body.dart test/run_clubs/run_clubs_widgets_test.dart`;
  `flutter test test/run_clubs/run_clubs_widgets_test.dart --plain-name "ClubDetailBody host view exposes edit and create navigation"`.
- 2026-05-05: Phase 8 final full data-contract verification passed:
  `./tool/check_data_contract.sh` completed generated TypeScript drift check,
  generator analysis, operation-aware Firestore contract metadata check,
  Functions lint, Functions tests including moderation/profile tests, Firestore
  rules emulator tests, focused Flutter analysis, and focused Flutter tests.
- 2026-05-05: Phase 8 Functions test entrypoint cleanup completed.
  `npm --prefix functions test` now includes compiled moderation tests and the
  new profile callable tests. Verification passed:
  `npm --prefix functions test` (50 tests).
- 2026-05-05: Phase 8 run-club creation Flutter API cleanup completed.
  `RunClubsRepository.createRunClub` no longer accepts client-provided
  `hostUserId`, `hostName`, or `hostAvatarUrl`; the create controller no longer
  reads the current user profile just to pass ignored host fields; server-side
  `createRunClub` remains the authority for host identity/projection fields.
  Verification passed:
  `flutter analyze lib/run_clubs/data/run_clubs_repository.dart lib/run_clubs/presentation/create/create_run_club_controller.dart test/run_clubs/run_clubs_repository_test.dart test/run_clubs/run_clubs_test_helpers.dart`;
  `flutter test test/run_clubs/run_clubs_repository_test.dart`.
- 2026-05-05: Phase 8 operation-aware contract tooling and onboarding contract
  alignment completed. `tool/firestore_contract.json` is now schema version 2
  and records operation ownership, callable names, allowed/denied fields,
  path/data identity fields, required rules snippets, and required rules test
  names for high-risk surfaces. The checker now validates operation metadata,
  exported callable names, operation field groups, rule snippets, and rules test
  names. Onboarding drafts are now documented as intentionally extensible with
  only `step` as the required routing field. Verification passed:
  `node tool/check_firestore_contract.mjs`.
- 2026-05-05: Phase 8 profile update contract hardening completed. Complex
  owner profile edits now go through the `updateUserProfile` callable with Zod
  validation and Admin SDK writes. Firestore rules now keep initial profile
  create full-shape validated while limiting direct user updates to cheap
  runtime fields. Later relationship-doc cleanup reduced this to `fcmToken`
  only. Flutter `UserProfileRepository`
  now delegates profile patches/photo updates/profile completion to the callable
  and normalizes timestamp values for callable transport. Verification passed:
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node --test functions/lib/profiles/updateUserProfile.test.js`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`;
  `flutter analyze lib/user_profile/data/user_profile_repository.dart test/user_profile/user_profile_repository_test.dart`;
  `flutter test test/user_profile/user_profile_repository_test.dart`.
- 2026-05-05: Phase 8 swipe contract hardening completed. Direct swipe creates
  now require exact payload keys, path/data identity, valid `like`/`pass`
  direction, timestamp `createdAt`, a non-deleted target with a public profile,
  an existing run, both users with attended `runParticipations`, and no block
  edge between them. Verification passed:
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`.
- 2026-05-05: Phase 8 run host update hardening completed. Host direct edits are
  now limited to schedule/descriptive fields; booking-sensitive fields
  (`waitlistUserIds`, `signedUpUserIds`, `attendedUserIds`, `genderCounts`),
  ownership fields (`runClubId`), and payment/eligibility fields
  (`capacityLimit`, `priceInPaise`, `constraints`) are denied for direct host
  updates. Verification passed:
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`.
- 2026-05-05: Final full data-contract verification passed after all Phase
  4-7 edits: `./tool/check_data_contract.sh` completed generator drift check,
  generator analyze, Firestore contract check, Functions lint/tests, Firestore
  rules emulator tests, focused Flutter analyze, and focused Flutter tests.
- 2026-05-05: Phase 4-7 hardening completed for the current pass. Simplified
  user, run-club, and onboarding-draft rules to avoid brittle full-shape
  validation on rapidly evolving owner-owned updates; added lifecycle-field,
  forward-compatible draft, host club update, and server-owned receipt rules
  tests; added idempotency receipts for `onMessageCreated`; made chat-message
  moderation flags deterministic; removed the checked-in App Check debug token;
  fixed Firestore predeploy to run emulator rules tests; and expanded the deploy
  smoke checklist. Verification passed:
  `npm --prefix functions run lint`;
  `npm --prefix functions test`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`;
  `node tool/check_firestore_contract.mjs`;
  JSON parse checks for `firebase.json`, `tool/dart_defines/dev.json`, and
  `tool/firestore_contract.json`.
- 2026-05-05: Phase 3 data-contract tooling completed. Added
  `tool/firestore_contract.json` as the canonical Firestore ownership contract,
  added `tool/check_firestore_contract.mjs` to verify rules path matches,
  generated TS interfaces, Dart model paths, exported Functions, and ownership
  field groups, wired the checker into `tool/check_data_contract.sh`, and made
  Firestore rules CI run the contract checker plus emulator rules tests for
  schema/tooling changes. Also added shared callable rate limiting to
  `createRunClub`, `joinRunClub`, and `leaveRunClub`. Verification passed:
  `npm --prefix functions run lint`;
  `npm --prefix functions test`;
  `node tool/check_firestore_contract.mjs`;
  `./tool/check_data_contract.sh` (generator drift, generator analyze,
  contract metadata, Functions lint/tests, rules emulator tests, focused
  Flutter analyze, focused Flutter tests).
- 2026-05-05: Tracker created. No implementation verification required yet.
- 2026-05-05: Phase 2 direct mutation audit completed for current high-risk
  surfaces. Removed legacy `RunRepository.signUpForRun`, denied direct
  `runClubs`/`runs` deletes in rules, removed `RunClubsRepository.deleteRunClub`,
  and documented the then-current direct-write boundaries. `createRun` and
  `leaveWaitlist` have since moved to callables; `updateRunClub` remains the
  intentional direct host-owned edit seam. Verification passed:
  `flutter analyze lib/runs/data/run_repository.dart test/runs/run_repository_test.dart lib/run_clubs/data/run_clubs_repository.dart test/run_clubs/run_clubs_repository_test.dart test/run_clubs/run_clubs_test_helpers.dart`;
  `flutter test test/runs/run_repository_test.dart test/run_clubs/run_clubs_repository_test.dart`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`.
- 2026-05-05: Phase 1 run-club membership callable migration completed.
  Added `createRunClub`, `joinRunClub`, and `leaveRunClub` callables under
  `functions/src/runClubs/`, exported them from Functions, added unit tests,
  changed Flutter `RunClubsRepository` create/join/leave methods to call
  Functions, updated run-clubs controller/widget/repository tests, and denied
  direct `runClubs` create/membership writes plus direct
  `users.joinedRunClubIds` updates in rules.
  Verification passed:
  `npm --prefix functions run lint`;
  `npm --prefix functions run build`;
  `npm --prefix functions test`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`;
  focused `flutter analyze`;
  focused `flutter test`.
  Deploy-order note: deploy Functions and the Flutter client path before or
  together with the tightened Firestore rules. The new rules deny the old
  direct client `runClubs` create/join/leave path.
- 2026-05-05: Phase 0 baseline passed after fixing generated TS lint output.
  Commands:
  `dart tool/generate_firestore_types.dart`;
  `dart analyze tool/generate_firestore_types.dart`;
  `npm --prefix functions run lint`;
  `npm --prefix functions run build`;
  `npm --prefix functions test`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`;
  `flutter analyze lib/run_clubs/data/run_clubs_repository.dart lib/run_clubs/presentation/detail/run_club_membership_controller.dart lib/run_clubs/presentation/list/run_clubs_list_controller.dart test/run_clubs/run_clubs_repository_test.dart test/run_clubs/run_clubs_list_controller_test.dart`;
  `flutter test test/run_clubs/run_clubs_repository_test.dart test/run_clubs/run_clubs_list_controller_test.dart`.
- 2026-05-05: Baseline initially failed at
  `npm --prefix functions run lint` because `tool/generate_firestore_types.dart`
  generated max-len violations in `functions/src/shared/firestore.ts`.
  Fixed the generator to wrap long JSDoc/property union lines, regenerated the
  TS file, and verified lint/build/tests/rules.
- 2026-05-05: Phase 0 dirty-worktree boundary recorded. The repo already had
  broad modified/deleted/untracked files across `docs/`, `lib/`, generated
  Dart, tests, rules, and Functions before new implementation work in this
  pass. Treat unrelated dirty files as user/work-in-progress state.
- 2026-05-05: Updated stale `PROJECT_CONTEXT.md` references from
  `functions/src/types/firestore.ts` to generated
  `functions/src/shared/firestore.ts`.

## Open Questions And Decisions

- Decision: relationship arrays are retired; edge documents own many-to-many
  state.
- Decision: `updateRunClub` is callable-owned. Direct run-club writes are
  denied in Firestore rules.
- Decision: checked-in App Check debug tokens are removed; use local
  `FIREBASE_APP_CHECK_DEBUG_TOKEN` environment variables instead.
