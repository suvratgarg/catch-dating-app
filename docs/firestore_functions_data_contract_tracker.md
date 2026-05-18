---
doc_id: firestore_contract_tracker
version: 2.3.2
updated: 2026-05-17
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
- Event Firestore rules tests under the Firestore emulator. From the repo root,
  use:

  ```bash
  firebase emulators:exec --only firestore "npm --prefix functions run test:rules"
  ```

  The standalone `npm event test:rules` / `node --test
  test/firestore.rules.test.cjs` command expects a Firestore emulator already
  listening on `127.0.0.1:8080`. If it fails with `connect ECONNREFUSED
  127.0.0.1:8080`, treat that as an emulator-workflow failure first, not a
  rules regression.
- After every implementation slice, update this tracker with:
  - what changed,
  - what was verified,
  - what failed or remains risky,
  - what task should event next.
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

## Firestore Type Generation

`tool/generate_firestore_types.dart` generates
`functions/src/shared/firestore.ts` from Dart domain models plus
`tool/firestore_ts_overlay.json`.

Use this workflow whenever a Dart Firestore model, server-only overlay field, or
Functions document interface changes:

```bash
dart tool/generate_firestore_types.dart
npm --prefix functions run build
```

CI also events the generator and fails if `functions/src/shared/firestore.ts`
differs from the committed output. Do not hand-edit the generated TypeScript
file. Add server-only fields or interfaces to `tool/firestore_ts_overlay.json`
instead.

The old standalone Firestore type-sync explainer was removed during the docs
consolidation pass; this tracker now owns that workflow.

## 2026-05-07 Relationship Rules And Deletion Slice

- Added callable-owned `leaveEventWaitlist` and removed the last direct client
  event update path. Direct `events/{eventId}` updates are now denied.
- Removed saved-event profile projection writes. `SavedEventRepository` writes only
  `savedEvents/{uid_eventId}` and rules deny direct private-profile projection
  changes.
- Swipes and reviews now use `eventParticipations/{eventId_uid}` attendance edges
  for eligibility instead of event roster projections. Private `users/{uid}`
  reads are owner-only; app-facing discovery should use `publicProfiles`.
- `requestAccountDeletion` now performs query-driven cleanup across
  memberships, participations, saved events, swipes, matches, reviews, payments,
  notifications, blocks, and reports before anonymizing the private profile and
  deleting Auth.
- Added backend lifecycle surfaces:
  - `deleteEvent` hard-deletes only unused hosted events with no participations,
    payments, or reviews.
  - `archiveClub` marks clubs archived.
  - `deleteClub` hard-deletes only never-used clubs with no events, payments,
    reviews, or non-host members.
- Added `ClubLifecycleStatus`, `archived`, `archivedAt`, and
  `archiveReason` to the Dart/Functions schema contract.
- Relationship participant/member/saved-event arrays have been retired from
  generated models, Functions write paths, Firestore rules, active tooling, and
  active tests. Relationship state now lives only in edge documents plus
  callable-owned aggregate counts on canonical parent documents.

`tool/generate_firestore_types.dart` already protects Dart-to-TypeScript drift,
and CI checks that generated output is committed. It does not protect
Firestore rules drift, callable validation drift, live data migrations, or
operation ownership drift.

## Recent Contract Notes

### 2026-05-12: Edge-Owned Event-Club Projection Slice

- Added `syncClubMemberStats`, a Firestore trigger on
  `clubMemberships/{membershipId}` writes. It recomputes
  `clubs/{clubId}.memberCount` from active membership edge documents so
  duplicate trigger delivery and stale callable-era parent projections are
  corrected from the source of truth.
- Added `syncClubNextEvent`, a Firestore trigger on `events/{eventId}` writes.
  It recomputes `clubs/{clubId}.nextEventAt` and `nextEventLabel` from active
  future events. `createEvent`, `updateEvent`, `cancelEvent`, and `deleteEvent` also
  refresh this projection after their transaction commits so manual UI flows do
  not wait on eventual trigger delivery.
- `createClub` now initializes lifecycle fields (`status`, `archived`,
  `archivedAt`, `archiveReason`) so newly created clubs match the generated
  Dart/Functions schema contract.
- Updated `firestore.indexes.json` with the event projection query index:
  `events(clubId ASC, status ASC, startTime ASC)`.
- Decision retained: membership, booking, waitlist, attendance, payments,
  reviews, event lifecycle, and club lifecycle remain callable-owned because
  they enforce multi-document product invariants. Direct client edge writes are
  still reserved for narrow owner-scoped actions such as swipes, saved events,
  and chat messages.

### 2026-05-08: Chat Thread Preview And Match Event History Slice

- Replaced the app-facing match event pointer with `eventIds`, while preserving
  Dart reads for legacy `eventId` documents during the cleanup window.
- Functions matching/message notifications now derive the latest shared event
  from `eventIds`, and demo data writes deterministic `eventIds` so seeded chats do
  not imply a separate conversation per message.
- `ChatsListViewModel` is the collapse boundary for duplicated active match
  documents. It renders one thread preview per other user, aggregates unread
  counts, separates no-message matches into the new-match rail, and keeps raw
  match/profile lookups out of chat row widgets.
- Chat messages allow nullable `sentAt` while server timestamps are pending;
  the UI renders a sending state instead of crashing or overflowing on null
  timestamps.

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
- Added a testable `signUpForFreeEventHandler` seam. The callable now trims and
  rejects blank `eventId` values, rate-limits before reading event docs, verifies
  the event is free, and delegates booking to the shared sign-up helper.
- Report writes now trim bounded optional fields and omit blank optional notes
  instead of storing raw whitespace.
- Added a testable `syncClubReviewStatsHandler` seam. The review aggregate
  trigger now remains a thin adapter while focused tests cover rating/count
  recompute, last-review deletion reset, and review moves between clubs.
- Fixed the Functions test entrypoint to include compiled review tests through
  `lib/reviews/*.test.js`, so review trigger coverage is part of the normal
  `npm --prefix functions test` command.
- Added aggregate repair tooling for post-relationship-migration data:
  - `tool/recompute_club_member_counts.mjs` recomputes
    `clubs/{clubId}.memberCount` from active
    `clubMemberships/{clubId_uid}` edge documents.
  - `tool/recompute_run_aggregate_counts.mjs` recomputes
    `events/{eventId}.bookedCount`, `checkedInCount`, `waitlistedCount`, and
    `genderCounts` from `eventParticipations/{eventId_uid}` edge documents.
  - `tool/validate_firestore_data.mjs` now reports member/event aggregate drift
    by comparing parent projections to the current edge-document source of
    truth.
- Dev data repair completed after the edge-document migration:
  - `node tool/recompute_club_member_counts.mjs --env dev --json` found 2
    stale event-club count projections and 0 membership edges.
  - `node tool/recompute_club_member_counts.mjs --env dev --apply`
    reset both stale `memberCount` projections to 0.
  - `node tool/recompute_run_aggregate_counts.mjs --env dev --json` found 4
    stale event aggregate projections and 0 participation edges.
  - `node tool/recompute_run_aggregate_counts.mjs --env dev --apply`
    reset those event count projections and `genderCounts` from the edge source.
  - `node tool/validate_firestore_data.mjs --env dev --json` then scanned 10
    docs with 0 errors and 0 warnings.
- Verification: `npm --prefix functions run lint` and
  `npm --prefix functions test` passed, focused review tests passed through
  `node --test functions/lib/reviews/*.test.js`, aggregate repair tool tests
  passed through `node --test tool/recompute_club_member_counts.test.mjs
  tool/recompute_run_aggregate_counts.test.mjs`, and dev live-data validation
  passed with 0 errors / 0 warnings.
- Next Functions queue: add handler seams and focused tests for remaining
  trigger/direct callable files that are not yet covered by the normal suite,
  starting with `syncPublicProfile`, `moderateChatMessage`,
  `moderatePhotoOnUpload`, `joinEventWaitlist` / `leaveEventWaitlist`,
  `cancelEventSignUp`, `markEventAttendance`, and `selfCheckInAttendance`.

### 2026-05-07: Relationship Array Retirement

- Removed event-club membership arrays, event participation arrays, and saved-event
  arrays from Dart domain models, generated Functions types, Cloud Functions
  writes, Firestore rules, active validation tooling, and active tests.
- Booking, waitlist, cancellation, attendance, and self-check-in Functions now
  read roster state from `eventParticipations` and maintain only
  `bookedCount`, `waitlistedCount`, `checkedInCount`, and `genderCounts` on
  `events/{eventId}`.
- Event-club create/join/leave Functions now read membership state from
  `clubMemberships` and maintain only `memberCount` on
  `clubs/{clubId}`.
- `users/{uid}` no longer carries event-club membership or saved-event projections.

### 2026-05-07: Notification Preferences, Club Bell, And Event Reminders

- Added granular user notification preferences to `users/{uid}`:
  `prefsMessages`, `prefsRunStatusUpdates`, and `prefsClubUpdates`, while
  retaining `prefsNewCatches`, `prefsEventReminders`, and `prefsWeeklyDigest`.
- Added `clubMemberships/{clubId_uid}.pushNotificationsEnabled` as the
  per-club bell opt-in. Active membership still means club updates appear in
  Activity; the bell gates FCM push for non-critical club updates.
- Added `setClubNotificationPreference` callable so the client does not
  write membership-edge notification flags directly.
- Added scheduled `sendEventReminders`, which creates deterministic
  `runReminder_${eventId}` durable items and pushes roughly 15 minutes before a
  signed-up event starts. Existing durable reminder docs suppress duplicate local
  derived rows in the Activity tab.
- Updated push policy: matches use `prefsNewCatches`, messages use
  `prefsMessages`, reminders use `prefsEventReminders`, schedule/cancellation and
  waitlist promotion use `prefsRunStatusUpdates`, and club updates require both
  `prefsClubUpdates` and the per-club bell.

### 2026-05-07: Event Schedule-Change And Cancellation Notifications

- Added canonical event lifecycle fields to `Event`: `status`, `cancelledAt`, and
  `cancellationReason`. Existing reads default missing `status` to `active` in
  Dart for legacy/beta data tolerance.
- `createEvent` initializes lifecycle fields as active. `cancelEvent` is now a
  host-only callable that marks the event cancelled and fans out deterministic
  `runCancelled_${eventId}` durable activity items plus push notifications to
  signed-up and waitlisted participants.
- `updateEvent` now fans out deterministic `runUpdated_${eventId}` activity items
  and push notifications only when schedule/location fields change. Copy-only
  edits stay quiet.
- Cancelled events are blocked from new free signups, paid order creation,
  waitlist joins, host attendance toggles, and self-check-in.
- Remaining product debt: define cancellation/refund policy, add host-facing
  cancellation UI, and decide how cancelled events should render on list/detail
  surfaces.

### 2026-05-07: Club Hosted-Event Notifications

- Extended `NOTIFICATIONS-QUEUE` to new events posted by followed clubs.
- `createEvent` now performs best-effort fan-out after the event document commits:
  active `clubMemberships` members receive deterministic
  `clubUpdate_${eventId}` activity items, while the host is excluded.
- Push is now sent only to active members with an FCM token, global
  `prefsClubUpdates != false`, and per-membership
  `pushNotificationsEnabled == true`; the durable in-app item is written
  regardless of push preference.
- Remaining notification producers from this note were completed in the
  notification preferences/reminder pass above.

### 2026-05-07: Event Signup And Waitlist Promotion Notifications

- Extended the durable activity timeline to event booking state changes.
- `signUpUserForEvent` now writes a deterministic `runSignup_${eventId}` activity
  item for normal booking confirmations and a `waitlistPromotion_${eventId}` item
  when the user was waitlisted before the successful signup.
- `cancelEventSignUp` now writes a `waitlistPromotion_${eventId}` activity item
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
  for durable match/message activity and keeps deriving upcoming event reminders
  locally until event producers are implemented.
- Firestore rules allow users to read only their own notification timeline and
  update only `readAt`; client-created notification items and content edits are
  denied.
- Remaining notification producers after this foundation pass were upcoming event
  reminders, signup/waitlist promotion, event cancellation/schedule changes, and
  club/hosted-event updates. Signup/waitlist promotion was implemented in the
  following slice above.

### 2026-05-06: Callable Rate Limit Enforcement

- Closed `FUNCTIONS-RATE-LIMIT-001`: every callable named in the Functions
  audit now enforces its declared shared rate limit before expensive or
  destructive work.
- Added enforcement to `verifyRazorpayPayment`, `cancelEventSignUp`,
  `joinEventWaitlist`, `blockUser`, `unblockUser`, and
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
  events; add the remaining event and club producers through the same
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
- Added generated Dart/TypeScript models for `ClubMembership`,
  `EventParticipation`, and `SavedEvent`.
- `ChatMessage` now lives under
  `matches/{matchId}/messages/{messageId}` instead of the legacy
  `chats/{matchId}/messages/{messageId}` namespace.
- Cloud Functions now write `clubMemberships` for club create/join/leave and
  `eventParticipations` for signup, waitlist, cancellation, host attendance, and
  participant self-check-in.
- Dashboard, Clubs list/detail, and Event Map membership reads now use
  `clubMemberships`.
- `savedEvents/{uid_eventId}` is now the owner-owned saved-event edge. Event detail
  reads saved state from the edge document; save/unsave do not mirror to the
  private user profile.
- Event detail reads the current viewer's booking, waitlist, attendance, and
  review-gate state from `eventParticipations/{eventId_uid}`. The event participant
  aggregate fields are count projections only.
- `watchSignedUpEventsProvider` and `watchAttendedEventsProvider` now read
  `eventParticipations` by user/status and then watch matching event documents by
  ID. Dashboard, Calendar, Event Map, Activity, and Swipe Hub use those
  edge-backed streams without changing their screen-level provider contracts.
- Host attendance management now reads roster and checked-in state from
  `eventParticipations` through `AttendanceSheetViewModel`.
- Swipe candidate generation, swipe empty-state attendance gating, and event
  recap attendee/checked-in state now read `eventParticipations`.
- Swipe and review Firestore rules now use `eventParticipations` for attendance
  eligibility. `users/{uid}` private reads are owner-only; app-facing discovery
  must use `publicProfiles/{uid}`.
- Event participation count projections are now explicit `events/{eventId}` fields:
  `bookedCount`, `waitlistedCount`, and `checkedInCount`. Create/signup,
  payment verification, waitlist, cancellation, host attendance, and self
  check-in Functions maintain these fields. `WhoIsRunning` and
  `HostRunManageScreen` use
  `eventParticipations` for exact rosters; list/stat surfaces use count
  projections. Production UI grep for direct participant-array reads is clean
  apart from generated `Event` serialization.
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
- `DELETE-METHODOLOGY-QUEUE`: rewrite account/event/club deletion around
  relationship-doc queries.
- `MIGRATION-VALIDATION-001`: add migration apply count validation and seeded
  fixture tests before running apply on shared beta data.

## Phases

### Phase 0: Tracker And Baseline

- [x] Create this tracker.
- [x] Record current dirty-worktree boundaries before editing implementation
  files.
- [x] Event or record focused baseline checks for the current Firestore/Functions
  surface.
- [x] Update stale docs references from `functions/src/types/firestore.ts` to
  `functions/src/shared/firestore.ts`.

### Phase 1: Move Club Membership To Cloud Functions

- [x] Add `createClub` callable so initial club creation and host membership
  projection are server-owned.
- [x] Add `joinClub` callable.
- [x] Add `leaveClub` callable.
- [x] Use shared callable App Check options.
- [x] Use shared auth and validation helpers.
- [x] Use shared callable rate limiting for create/join/leave club operations.
- [x] Make both callables idempotent.
- [x] Create/update `clubMemberships/{clubId_uid}`.
- [x] Update `clubs/{clubId}.memberCount`.
- [x] Retire profile and club membership arrays.
- [x] Reject deleted users and missing/incomplete profiles.
- [x] Add Function unit tests for success, idempotency, missing docs, and
  invalid input.
- [x] Update Flutter repository/client methods to call Functions.
- [x] Update Flutter tests.
- [x] Tighten Firestore rules so `clubs` creation and membership state are
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
- [x] Decide whether `createEvent`, and host edits should remain client-direct
  or move to callables.
- [x] Move event-club profile edits and review mutations to callables so rules
  no longer duplicate those validation contracts.
- [x] Document final mutation ownership in this file and `PROJECT_CONTEXT.md`.
- [x] Verify focused analyze/tests after each migrated mutation.

#### Direct Client Write Inventory

Client-owned and acceptable for now:

- `lib/user_profile/data/user_profile_repository.dart`
  - `setUserProfile`, profile field updates, photo URLs, profile-complete flag,
    saved-event array changes, and notification preferences.
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

- `lib/clubs/data/clubs_repository.dart`
  - `createClub`, `updateClub`, `joinClub`, `leaveClub`.
  - Rationale: each writes server-derived fields, aggregate projections, or
    host-authorized profile data that should be Zod-validated server-side.
- `lib/reviews/data/reviews_repository.dart`
  - `createEventReview`, `updateEventReview`, `deleteEventReview`.
  - Rationale: review mutations derive public reviewer name, verify attended
    event participation, enforce ownership, and leave aggregate stats to the
    recompute trigger.

Resolved mutation boundaries:

- `lib/clubs/data/clubs_repository.dart`
  - `updateClub`.
  - Decision: keep direct for now. It is host-owned, single-document, and rules
    freeze membership/rating/derived fields.
- `lib/events/data/event_repository.dart`
  - `createEvent`, host event details update, `leaveWaitlist`.
  - Decision: `createEvent` and host event details updates moved to callables in
    Phase 9 so host authority, event/club consistency, and server-owned booking
    state are enforced on the backend. `leaveWaitlist` is now callable-owned
    as well, so clients no longer update `events/{eventId}` directly for waitlist
    state.

Removed or denied:

- `lib/events/data/event_repository.dart`
  - `signUpForRun`.
  - Decision: removed. Direct `signedUpUserIds` updates bypass capacity, gender
    counts, payments, block checks, and server validation.
- `clubs` and `events` direct deletes.
  - Decision: denied in rules and removed from the event-clubs repository API
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
- [x] Make the checker event:
  - [x] Dart-to-TypeScript generation drift check.
  - [x] Firestore rules tests.
  - [x] Functions build/lint/tests.
  - [x] Focused Flutter checks where practical.
- [x] Add CI triggers so model/domain/schema changes event Firestore rules tests.
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
- `clubs/{clubId}` direct writes are denied; create/update/archive/delete
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
- `syncClubReviewStats` and `syncPublicProfile` recompute/set final state,
  so duplicate events are naturally idempotent.
- `onSwipeCreated` uses deterministic match IDs and `create()`, so duplicate
  trigger execution does not duplicate matches.
- `moderateChatMessage` now uses deterministic moderation flag IDs for chat
  messages so retries do not create duplicate ops tickets.

### Phase 6: Data Model Migration Decision

- [x] Decide whether current arrays are acceptable for expected production
  scale.
- [x] If arrays remain, document limits and monitoring signals.
- [x] If edge docs are needed, design and implement:
  - [x] `clubMemberships/{clubId_uid}`,
  - [x] `eventParticipations/{eventId_uid}`,
  - [x] `savedEvents/{uid_eventId}`,
  - [x] match-scoped `matches/{matchId}/messages/{messageId}`,
  - [x] validation tooling and beta-reset fallback notes,
  - [x] final rules tightening for retired relationship arrays.
- [x] Do not tighten production rules until migration safety is documented and
  verified against live-like fixtures.

Decision:

- The original "keep arrays for this pass" decision has been superseded by the
  relationship-document migration. `docs/firestore_relationship_documents_migration.md`
  is now the durable owner for the edge-doc model, beta reset strategy,
  validation tooling, and deletion/anonymization payoff.
- Parent `clubs` and `events` retain aggregate projections only, such as
  `memberCount`, `bookedCount`, `waitlistedCount`, `checkedInCount`, and
  `genderCounts`. Do not reintroduce relationship arrays to active models,
  Functions, rules, validation tooling, or tests.

### Phase 7: Operational Cleanup

- [x] Fix docs that conflict about committed App Check debug tokens.
- [x] Decide whether debug tokens should be removed from checked-in
  `tool/dart_defines/dev.json`.
- [x] Ensure deploy runbooks mention required data seeds and rollback order.
- [x] Ensure rules deploy predeploy checks actually event rules tests, not only
  Functions tests.
- [x] Add a production smoke-test checklist for:
  - [x] profile update,
  - [x] create club,
  - [x] join club,
  - [x] leave club,
  - [x] create event,
  - [x] book free event,
  - [x] paid event payment verification,
  - [x] chat send,
  - [x] unread reset,
  - [x] block/report/account deletion.

Notes:

- Removed the checked-in dev App Check debug token. Local device debug tokens
  should be exported via `FIREBASE_APP_CHECK_DEBUG_TOKEN`.
- Firestore deploy predeploy now events the rules emulator suite, not only
  Functions tests.

### Phase 8: Extended Contract Hardening Review

These tasks come from the second-pass contract review after the basic
Firestore/Functions cleanup passed. They should be handled incrementally with
focused tests after each slice, then a final `./tool/check_data_contract.sh`.

- [x] P1: Tighten `events/{eventId}` host updates. The current host update branch
  only blocks `signedUpUserIds`, `attendedUserIds`, and `genderCounts`, which
  still lets hosts directly change `waitlistUserIds`, `clubId`,
  `capacityLimit`, `priceInPaise`, and `constraints` after creation. That
  weakens the callable-owned booking/waitlist contract and makes direct
  waitlist self-removal less meaningful. Follow-up complete: waitlist
  self-removal is now callable-owned too, and direct `events/{eventId}` updates are
  denied.
- [x] P1: Validate `swipes/{userId}/outgoing/{targetId}` create payloads. Rules
  currently check owner, deleted-target state, and block state, but not
  `direction`, `eventId`, path/data identity, allowed fields, or extra fields. The
  `onSwipeCreated` trigger trusts `direction` and `eventId`, so malformed client
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
- [x] P2: Clean the event-club creation Flutter API. `ClubsRepository` still
  accepts `hostUserId`, `hostName`, and `hostAvatarUrl` even though the
  `createClub` callable ignores client host identity and derives host fields
  from `users/{uid}`. The server behavior is correct, but the Dart API contract
  is misleading.
- [x] P2: Include moderation tests in `npm test`. The package test script events
  matching, payments, event-clubs, safety, waitlist, and callable App Check tests,
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

- [x] Block hosts from leaving their own club.
  - [x] Reject host leave attempts in the `leaveClub` callable.
  - [x] Verify the host detail UI does not expose a leave-club action.
  - [x] Add/adjust tests for both backend rejection and UI hiding.
- [x] Enforce one review per user per event.
  - [x] Use deterministic review IDs derived from `eventId` and
    `reviewerUserId`.
  - [x] Update the repository read/write path so it no longer needs a query to
    find the current user's review for a event.
  - [x] Tighten Firestore rules so review document IDs match the deterministic
    contract and review creates require a event-scoped review.
  - [x] Add rules and Dart tests for allowed deterministic creates and denied
    malformed/random-ID creates.
- [x] Move event creation and host event edits toward callable-owned mutation
  contracts.
  - [x] Design/implement `createEvent` callable validation that derives host
    authority from the authenticated user and their hosted club.
  - [x] Design/implement host event edit callable validation for schedule and
    descriptive fields while keeping booking, payment, eligibility, attendance,
    and ownership fields server-owned.
  - [x] Update `EventRepository`, controllers, tests, and Firestore rules so
    clients do not directly mutate sensitive event state.
- [x] Add live-data validation tooling before migration.
  - [x] Add a read-only Firestore validation script that checks document shape,
    required fields, array lengths, approximate document size, and edge-case
    values across users, clubs, events, reviews, swipes, matches, chats, and
    onboarding drafts.
  - [x] Support dev/staging project selection and emulator mode without
    hard-coding production credentials.
  - [x] Document how to event the validator and how to interpret failures before
    tightening production/staging rules.
- [x] Prepare but do not rush live migration.
  - [x] Event validation against dev/staging first.
  - [x] Inspect the small current production dataset before writing migration
    code.
  - [x] Add migration scripts only after validation output identifies the
    concrete data drift to repair.
  - [ ] Deploy code/rules/functions to dev and staging before production.

Approved decisions:

- Hosts cannot leave clubs they host, and the app should not show hosts a
  leave-club button.
- Reviews should be one per user per event; deterministic IDs are acceptable.
- Event creation and host event edits should move to callable-owned contracts.
- Validation, size, and array-length scripts should be added now; real-data
  migration can follow once the current data drift is known.
- Dev and staging are acceptable deployment targets for this cleanup after local
  verification and environment wiring checks.

## Verification Log

Append newest entries at the top.

- 2026-05-05: Deleted all live review test data after mapping dependencies.
  Added `tool/delete_firestore_reviews.mjs`, a dry-run-first Admin SDK cleanup
  tool that maps all `reviews/{id}` docs, affected `clubs`, affected `events`,
  reviewer `users`, detected review-reference fields, and required
  `clubs.rating`/`reviewCount` resets before applying deletion with
  `--apply --confirm-delete-all-reviews`. Live dry-runs showed that all current
  dev/prod reviews were legacy club-scoped reviews without `eventId`; no affected
  event documents or user documents contained review reference fields. Applied
  cleanup to dev and prod. Dev deleted 3 reviews and reset
  `clubs/frrOLITIukUcUCFFFACS` from rating 3.6666666666666665/reviewCount 3
  to 0/0. Prod deleted 5 reviews and reset
  `clubs/CPEXusszu0gnrZANT8fE`, `clubs/Zvm256jqQmL5de98KIoj`,
  `clubs/fJlZbx9BewUXsOZwQKv3`, and
  `clubs/kqadT73GGy1o0VRlo98I` to rating 0/reviewCount 0. Staging had no
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
  surface found so far is old club-scoped reviews without `eventId`.
- 2026-05-05: Attempted read-only live validation for dev with
  `node tool/validate_firestore_data.mjs --env dev --json`. The Firebase CLI is
  logged in and can list dev/staging/prod projects, but the Admin SDK validator
  could not load Application Default Credentials because neither
  `GOOGLE_APPLICATION_CREDENTIALS` nor
  `~/.config/gcloud/application_default_credentials.json` is configured in this
  shell. `firebase/README.md` now documents the credential requirement. Next
  step: configure ADC or a read-only service account, then event dev and staging
  validation before migration or deploy.
- 2026-05-05: Phase 9 final full data-contract verification passed:
  `./tool/check_data_contract.sh` completed generated TypeScript drift check,
  generator analysis, operation-aware Firestore contract metadata check,
  Firestore data validator syntax check, Functions lint, Functions tests
  including event mutation tests, Firestore rules emulator tests, focused Flutter
  analysis, and focused Flutter repository tests.
- 2026-05-05: Phase 9 live-data validation tooling added. The read-only
  `tool/validate_firestore_data.mjs` script resolves project aliases from
  `.firebaserc`, supports emulator mode, checks required field types,
  approximate document size, high-growth array lengths, deterministic review
  IDs, path/data identity, and cross-document references across users,
  public profiles, clubs, events, reviews, swipes, matches, chat messages,
  and onboarding drafts. `firebase/README.md` now documents the commands.
  Verification passed:
  `node --check tool/validate_firestore_data.mjs`;
  `node tool/validate_firestore_data.mjs --help`;
  `firebase emulators:exec --only firestore "node tool/validate_firestore_data.mjs --env dev --emulator --json"`.
- 2026-05-05: Phase 9 event mutation callable migration completed. Added
  `createEvent` and `updateEvent` callables with Zod validation, host authority
  checks, rate limiting, server-owned booking arrays, and transport-safe epoch
  millis for timestamps. `EventRepository.createEvent` now calls `createEvent`, and
  `updateEventDetails` calls `updateEvent`. Firestore rules now deny direct event
  creates and direct host detail edits. A later relationship-doc slice moved
  waitlist self-removal behind `leaveEventWaitlist` as well. Verification passed:
  `npm --prefix functions run build`;
  `npm --prefix functions run lint`;
  `node --test functions/lib/events/mutateRun.test.js`;
  `node tool/check_firestore_contract.mjs`;
  `flutter analyze lib/events/data/event_repository.dart lib/events/presentation/create_event_controller.dart test/events/event_repository_test.dart test/events/create_event_controller_test.dart`;
  `flutter test test/events/event_repository_test.dart test/events/create_event_controller_test.dart`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`;
  `npm --prefix functions test`.
- 2026-05-05: Phase 9 deterministic event reviews completed. Review creates now
  use `eventId~reviewerUserId` document IDs, `watchUserReviewForRun` reads the
  deterministic document directly, club pages show read-only review aggregates,
  and Firestore rules require deterministic event-scoped review creates from
  attended users with matching user names. Verification passed:
  `node tool/check_firestore_contract.mjs`;
  `flutter analyze lib/reviews/data/reviews_repository.dart lib/reviews/presentation/reviews_section.dart test/reviews/reviews_repository_test.dart test/events/event_detail_widgets_test.dart test/clubs/clubs_widgets_test.dart`;
  `flutter test test/reviews/reviews_repository_test.dart`;
  `flutter test test/clubs/clubs_widgets_test.dart --plain-name "ClubDetailBody keeps club review aggregate read-only"`;
  `flutter test test/events/event_detail_widgets_test.dart --plain-name "renders detail sections and review CTA when attended"`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`.
- 2026-05-05: Phase 9 host leave guard completed. The `leaveClub`
  callable now rejects attempts by `hostUserId`, and the host club detail
  widget test explicitly verifies that hosts do not see `Leave club`.
  Verification passed:
  `npm --prefix functions run build`;
  `node --test functions/lib/clubs/membership.test.js`;
  `flutter analyze lib/clubs/presentation/detail/widgets/club_detail_body.dart test/clubs/clubs_widgets_test.dart`;
  `flutter test test/clubs/clubs_widgets_test.dart --plain-name "ClubDetailBody host view exposes edit and create navigation"`.
- 2026-05-05: Phase 8 final full data-contract verification passed:
  `./tool/check_data_contract.sh` completed generated TypeScript drift check,
  generator analysis, operation-aware Firestore contract metadata check,
  Functions lint, Functions tests including moderation/profile tests, Firestore
  rules emulator tests, focused Flutter analysis, and focused Flutter tests.
- 2026-05-05: Phase 8 Functions test entrypoint cleanup completed.
  `npm --prefix functions test` now includes compiled moderation tests and the
  new profile callable tests. Verification passed:
  `npm --prefix functions test` (50 tests).
- 2026-05-05: Phase 8 event-club creation Flutter API cleanup completed.
  `ClubsRepository.createClub` no longer accepts client-provided
  `hostUserId`, `hostName`, or `hostAvatarUrl`; the create controller no longer
  reads the current user profile just to pass ignored host fields; server-side
  `createClub` remains the authority for host identity/projection fields.
  Verification passed:
  `flutter analyze lib/clubs/data/clubs_repository.dart lib/clubs/presentation/create/create_club_controller.dart test/clubs/clubs_repository_test.dart test/clubs/clubs_test_helpers.dart`;
  `flutter test test/clubs/clubs_repository_test.dart`.
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
  an existing event, both users with attended `eventParticipations`, and no block
  edge between them. Verification passed:
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`.
- 2026-05-05: Phase 8 event host update hardening completed. Host direct edits are
  now limited to schedule/descriptive fields; booking-sensitive fields
  (`waitlistUserIds`, `signedUpUserIds`, `attendedUserIds`, `genderCounts`),
  ownership fields (`clubId`), and payment/eligibility fields
  (`capacityLimit`, `priceInPaise`, `constraints`) are denied for direct host
  updates. Verification passed:
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`.
- 2026-05-05: Final full data-contract verification passed after all Phase
  4-7 edits: `./tool/check_data_contract.sh` completed generator drift check,
  generator analyze, Firestore contract check, Functions lint/tests, Firestore
  rules emulator tests, focused Flutter analyze, and focused Flutter tests.
- 2026-05-05: Phase 4-7 hardening completed for the current pass. Simplified
  user, event-club, and onboarding-draft rules to avoid brittle full-shape
  validation on rapidly evolving owner-owned updates; added lifecycle-field,
  forward-compatible draft, host club update, and server-owned receipt rules
  tests; added idempotency receipts for `onMessageCreated`; made chat-message
  moderation flags deterministic; removed the checked-in App Check debug token;
  fixed Firestore predeploy to event emulator rules tests; and expanded the deploy
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
  Firestore rules CI event the contract checker plus emulator rules tests for
  schema/tooling changes. Also added shared callable rate limiting to
  `createClub`, `joinClub`, and `leaveClub`. Verification passed:
  `npm --prefix functions run lint`;
  `npm --prefix functions test`;
  `node tool/check_firestore_contract.mjs`;
  `./tool/check_data_contract.sh` (generator drift, generator analyze,
  contract metadata, Functions lint/tests, rules emulator tests, focused
  Flutter analyze, focused Flutter tests).
- 2026-05-05: Tracker created. No implementation verification required yet.
- 2026-05-05: Phase 2 direct mutation audit completed for current high-risk
  surfaces. Removed legacy `EventRepository.signUpForRun`, denied direct
  `clubs`/`events` deletes in rules, removed `ClubsRepository.deleteClub`,
  and documented the then-current direct-write boundaries. `createEvent` and
  `leaveWaitlist` have since moved to callables; `updateClub` remains the
  intentional direct host-owned edit seam. Verification passed:
  `flutter analyze lib/events/data/event_repository.dart test/events/event_repository_test.dart lib/clubs/data/clubs_repository.dart test/clubs/clubs_repository_test.dart test/clubs/clubs_test_helpers.dart`;
  `flutter test test/events/event_repository_test.dart test/clubs/clubs_repository_test.dart`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`.
- 2026-05-05: Phase 1 event-club membership callable migration completed.
  Added `createClub`, `joinClub`, and `leaveClub` callables under
  `functions/src/clubs/`, exported them from Functions, added unit tests,
  changed Flutter `ClubsRepository` create/join/leave methods to call
  Functions, updated event-clubs controller/widget/repository tests, and denied
  direct `clubs` create/membership writes plus direct
  `users.joinedClubIds` updates in rules.
  Verification passed:
  `npm --prefix functions run lint`;
  `npm --prefix functions run build`;
  `npm --prefix functions test`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`;
  focused `flutter analyze`;
  focused `flutter test`.
  Deploy-order note: deploy Functions and the Flutter client path before or
  together with the tightened Firestore rules. The new rules deny the old
  direct client `clubs` create/join/leave path.
- 2026-05-05: Phase 0 baseline passed after fixing generated TS lint output.
  Commands:
  `dart tool/generate_firestore_types.dart`;
  `dart analyze tool/generate_firestore_types.dart`;
  `npm --prefix functions run lint`;
  `npm --prefix functions run build`;
  `npm --prefix functions test`;
  `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`;
  `flutter analyze lib/clubs/data/clubs_repository.dart lib/clubs/presentation/detail/club_membership_controller.dart lib/clubs/presentation/list/clubs_list_controller.dart test/clubs/clubs_repository_test.dart test/clubs/clubs_list_controller_test.dart`;
  `flutter test test/clubs/clubs_repository_test.dart test/clubs/clubs_list_controller_test.dart`.
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
- Decision: `updateClub` is callable-owned. Direct event-club writes are
  denied in Firestore rules.
- Decision: checked-in App Check debug tokens are removed; use local
  `FIREBASE_APP_CHECK_DEBUG_TOKEN` environment variables instead.
