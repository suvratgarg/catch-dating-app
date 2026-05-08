---
doc_id: firestore_relationship_documents_migration
version: 1.0.14
updated: 2026-05-08
owner: recursive_audit_loop
status: active
---

# Firestore Relationship Documents Migration

## Read Policy

Read this before changing relationship arrays, match/chat storage, Firestore
rules, Cloud Functions relationship mutations, data migration scripts, account
deletion cleanup, or list/detail reads that depend on membership, signup,
attendance, waitlist, saved-run, match, or chat-message state.

This is the source of truth for moving Catch away from SQL-style relationship
arrays and toward Firestore-native relationship/action documents.

## Goal

Replace high-cardinality many-to-many arrays with queryable relationship
documents, move chat messages under their owning match thread, and use the new
shape as the basis for production-grade deletion and anonymization.

The app is still pre-launch, so beta data can be migrated or reset if needed.
Even so, use migration discipline: dry-run first, validate counts, write
idempotently, and record verification.

## Operating Rules

- Root-level relationship documents are the default for many-to-many state that
  must be queried by either side of the relationship.
- Keep canonical entity documents focused on entity profile/details and
  aggregate counts, not full hidden ID lists.
- Keep small fixed preference arrays embedded on `users/{uid}` when they are not
  relationship indexes.
- Firestore `where` queries are not joins. Relationship docs may store IDs and
  intentionally small display snapshots, but full public profile data still
  comes from `publicProfiles/{uid}`.
- Multi-document relationship writes should be callable-owned unless the direct
  Firestore rule is owner-scoped, narrow, and easy to prove in emulator tests.
- Relationship arrays are retired. Do not add them back to Flutter models,
  Functions writes, Firestore rules, active tooling, or tests.
- Every implementation slice must update:
  - `tool/firestore_contract.json`,
  - `docs/backend_operation_catalog.md`,
  - this tracker,
  - generated Dart/TypeScript files when models change,
  - rules/tests for any changed write surface.

## Current State Inventory

### Canonical Entities

| Path | Role | Current concern |
|---|---|---|
| `users/{uid}` | Private user profile/account source of truth. | Does not store run-club membership or saved-run projections. |
| `publicProfiles/{uid}` | Backend-derived public profile projection. | Good shape; keep backend-owned. |
| `runClubs/{clubId}` | Run club profile/details. | Stores descriptive data plus `memberCount`; membership identity lives in `runClubMemberships`. |
| `runClubHostClaims/{uid}` | Server-owned host lock. | Enforces one hosted run club per user without scanning client-side state or trusting hidden UI affordances. |
| `runs/{runId}` | Run details and host-owned schedule fields. | Stores aggregate `bookedCount`, `waitlistedCount`, `checkedInCount`, and `genderCounts`; roster identity lives in `runParticipations`. |
| `matches/{matchId}` | Match/chat thread header. | Good owner for thread metadata; messages currently live in a parallel `chats` namespace. |
| `payments/{paymentId}` | Payment event/receipt. | Already action-like. Keep as document. |
| `reviews/{reviewId}` | Review action document. | Already action-like. Keep as document. |

### Existing Action/Edge Documents

| Path | Role | Decision |
|---|---|---|
| `swipes/{uid}/outgoing/{targetId}` | User-owned outgoing swipe action. | Keep. Reciprocal likes derive matches. |
| `matches/{matchId}` | Derived reciprocal relationship/thread header. | Keep. Move messages underneath it. |
| `chats/{matchId}/messages/{messageId}` | Chat message timeline. | Migrate to `matches/{matchId}/messages/{messageId}`. |
| `blocks/{blocker}__{blocked}` | Directed safety edge. | Keep. |
| `reports/{reportId}` | Safety report action. | Keep server-owned. |
| `moderationFlags/{flagId}` | Moderation event/projection. | Keep server-owned. |
| `deletedUsers/{uid}` | Account-deletion tombstone. | Keep server-owned. |

### Retired Array-Backed Relationships

| Retired field | Target relationship document | Notes |
|---|---|---|
| `users/{uid}.joinedRunClubIds` | `runClubMemberships/{clubId_uid}` | Query by `uid` for my clubs and by `clubId` for members. |
| `runClubs/{clubId}.memberUserIds` | `runClubMemberships/{clubId_uid}` | Replace hidden ID array with `memberCount` aggregate plus member query. |
| `users/{uid}.savedRunIds` | `savedRuns/{uid_runId}` | Owner-owned relationship, likely safe as direct create/delete with narrow rules. |
| `runs/{runId}.signedUpUserIds` | `runParticipations/{runId_uid}` | Status `signedUp`; aggregate count stays on run. |
| `runs/{runId}.waitlistUserIds` | `runParticipations/{runId_uid}` | Status `waitlisted`; order via timestamp. |
| `runs/{runId}.attendedUserIds` | `runParticipations/{runId_uid}` | Attendance fields live on participation edge. |

### Embedded Arrays To Keep

Keep these on profile/public-profile documents because they are small
preferences, not relationship indexes:

- `interestedInGenders`
- `languages`
- `preferredDistances`
- `runningReasons`
- `photoUrls` for now

Keep `matches.unreadCounts` as a bounded two-participant map.

## Target State Schema

### `runClubMemberships/{clubId_uid}`

Server-owned membership edge.

Required fields:

- `clubId`
- `uid`
- `role`: `host` or `member`
- `status`: `active`, `left`, `deleted`
- `joinedAt`
- `leftAt`
- `deletedAt`

### `runClubHostClaims/{uid}`

Server-owned uniqueness lock for the current one-hosted-club product rule.

Required fields:

- `uid`
- `clubId`
- `createdAt`

Rules:

- Client reads and writes are denied.
- `createRunClub` creates the claim in the same transaction as the run club and
  host membership edge.
- `deleteRunClub` deletes the claim only when an unused club is hard-deleted,
  so a host can create another club after removing a club that never acquired
  history.
- Existing beta data should either be reset or backfilled with host-claim docs
  before production users rely on the invariant.

Optional display snapshot fields may be added only if a member list needs to
avoid fetching full public profiles for every row.

### `runParticipations/{runId_uid}`

Server-owned run participation edge.

Required fields:

- `runId`
- `runClubId`
- `uid`
- `status`: `signedUp`, `waitlisted`, `attended`, `cancelled`, `deleted`
- `createdAt`
- `updatedAt`

Context fields:

- `signedUpAt`
- `waitlistedAt`
- `attendedAt`
- `cancelledAt`
- `deletedAt`
- `genderAtSignup`
- `paymentId`

### `savedRuns/{uid_runId}`

Owner-owned saved-run edge.

Required fields:

- `uid`
- `runId`
- `savedAt`

Optional fields:

- `removedAt` if we choose soft-delete history over hard delete.

### `matches/{matchId}/messages/{messageId}`

Client-created message under the owning match/thread document.

Fields remain:

- `senderId`
- `text`
- `imageUrl`
- `sentAt`

`matches/{matchId}` remains the thread header and owns:

- participants
- match status
- block status
- last message preview/time/sender
- unread counts

## Migration Checklist

### Phase 0: Tracker And Contract Baseline

- [x] Create this tracker.
- [x] Add this tracker to doc summaries/version metadata if required by the
  audit registry.
- [x] Update `docs/backend_operation_catalog.md` with the target schema.
- [x] Update `tool/firestore_contract.json` with relationship collections and
  match-scoped messages.
- [x] Record direct client writes and retire relationship compatibility arrays.

### Phase 1: Models And Generated Contracts

- [x] Add Dart Freezed/json_serializable models:
  - `RunClubMembership`
  - `RunParticipation`
  - `SavedRun`
- [x] Update Firestore type generation config for new models and new message
  path.
- [x] Regenerate Dart and Functions TypeScript outputs.
- [ ] Add domain serialization tests.

### Phase 2: Match-Scoped Messages

- [x] Move message repository path from
  `chats/{matchId}/messages/{messageId}` to
  `matches/{matchId}/messages/{messageId}`.
- [x] Update message Storage path if needed.
- [x] Update `onMessageCreated` trigger path.
- [x] Update `moderateChatMessage` trigger path.
- [x] Update Firestore rules and rules tests.
- [x] Add optional migration script support for copying old chat messages.

### Phase 3: Club Membership Edges

- [x] Add membership repository/provider seams in Flutter.
- [x] Update `createRunClub`, `joinRunClub`, and `leaveRunClub` to write
  `runClubMemberships`.
- [x] Retire `users.joinedRunClubIds` and `runClubs.memberUserIds` from
  models, Functions, rules, active tooling, and tests.
- [x] Update rules and tests for server-owned membership docs.
- [x] Move Dashboard, Run Clubs list/detail, and Run Map membership reads to
  `runClubMemberships` and `memberCount`.
- [x] Remove compatibility membership arrays/writes.

### Phase 4: Run Participation Edges

- [x] Add participation repository/provider seams in Flutter.
- [x] Update signup, payment verification, waitlist, cancellation, host
  attendance, and self-check-in Functions to write `runParticipations`.
- [x] Retire run participation arrays from models, Functions, rules, active
  tooling, and tests.
- [x] Add aggregate fields or formalize existing derived counts.
- [x] Update rules and tests for server-owned participation docs.
- [x] Move run-detail current-viewer booking, waitlist, attendance, and
  review-gate state to `runParticipations/{runId_uid}`.
- [x] Move shared signed-up and attended run stream providers to
  `runParticipations` edge queries plus run document watches.
- [x] Move attendance management roster/check-in state to
  `runParticipations` edge queries.
- [x] Move swipe candidate generation, swipe empty-state attendance gating, and
  run recap attendee/checked-in state to `runParticipations`.
- [x] Move presentation roster/count reads off run participant arrays:
  `WhoIsRunning` and `HostRunManageScreen` use edge-derived rosters, while
  list/stat surfaces read `Run` aggregate count projections.
- [x] Move remaining roster/count projections off participant arrays.

### Phase 5: Saved Run Edges

- [x] Add saved-run repository/provider seam.
- [x] Move save/unsave writes to `savedRuns/{uid_runId}`.
- [x] Decide hard delete versus soft delete for unsave.
- [x] Update rules and tests for owner-owned saved-run docs.
- [x] Move run-detail saved-state UI reads off `users.savedRunIds`.
- [x] Retire `users.savedRunIds` from models, rules, active tooling, and tests.

### Phase 6: Migration Tooling

- [x] Retire array-to-edge reconstruction tooling.
- [x] Keep legacy chat-message copy support for `chats/{matchId}/messages` to
  `matches/{matchId}/messages`.
- [x] Validate aggregate counts and edge references with
  `tool/validate_firestore_data.mjs` instead of reconstructing from arrays.
- [x] Add a beta-reset fallback note that requires explicit human approval
  before deleting beta accounts or clearing production-like data.

### Beta Data Release Strategy

This release does not preserve retired compatibility arrays. The deploy path is
therefore:

1. Deploy Functions first so callable-owned relationship writes exist.
2. Deploy Firestore indexes and rules after Functions.
3. Validate existing data with `node --check tool/validate_firestore_data.mjs`
   before deploy and run live environment smoke tests after deploy.
4. For beta accounts with stale array-era data, prefer a reset/re-sign-up path
   over reintroducing compatibility writes. Any destructive beta reset still
   requires explicit human approval before data is deleted.
5. Legacy chat message copy support remains available for the old
   `chats/{matchId}/messages` namespace, but new writes use
   `matches/{matchId}/messages`.

### Phase 7: Delete/Anonymize Cleanup

- [ ] Rewrite account deletion to query relationship docs by `uid`.
- [ ] Add run deletion plan that queries `runParticipations`, payments,
  reviews, swipes, and matches by run.
- [ ] Add club deletion plan that queries `runClubMemberships`, runs, reviews,
  and aggregate projections by club.
- [ ] Keep review deletion/anonymization consistent with the error/data
  contract decisions already documented.

### Phase 8: Compatibility Array Retirement

- [x] Remove array dependencies from Flutter models/read paths.
- [x] Remove array writes from Functions.
- [x] Tighten rules so retired array fields are no longer valid schema.
- [x] Update validation tooling to validate edge documents and aggregate counts.
- [x] Remove active tests/tooling that used old array vocabulary.

## 2026-05-07 Approval Packet And Implementation Status

This section began as the no-code approval packet for the relationship-array
retirement slice. The slice is now implemented in production code, Functions,
rules, active tooling, and active tests.

### Current Findings

Relationship-document reads are now in good shape for the main app surfaces:
run-club membership, run participation, saved runs, and match-scoped messages
have repository/provider seams, and production UI no longer directly reads run
participant arrays for booking/attendance/waitlist state.

The remaining complexity comes from two places:

1. Private profile reads can still be tightened further after public-profile
   usage is rechecked.
2. Deletion/anonymization is only partially implemented. The relationship-doc
   migration makes the comprehensive version much easier, but account/run/club
   deletion still needs explicit server-side graph cleanup.

### Unreviewed Functions Audit

| File | Current behavior | Proposed action |
|---|---|---|
| `functions/src/matching/onSwipeCreated.ts` | Creates a deterministic `matches/{matchId}` document when reciprocal outgoing likes exist. It trusts swipe rules for eligibility and checks blocks before creating the match. | Keep the match trigger. Add a small deletion/public-profile guard before match creation so a stale reciprocal swipe cannot create a match after either user has been deleted. Consider recording an idempotency receipt only if future side effects expand beyond deterministic `create()`. |
| `functions/src/moderation/textFilter.ts` | Local block/flag word filter for user-generated text. No relationship-doc impact. | No schema work. Later moderation cleanup can improve word-boundary matching and runtime-configurable lists, but it is outside this migration. |
| `functions/src/payments/razorpay.ts` | Secret-backed Razorpay client factory and signature verification helper. | No relationship-doc work. Keep as shared payment infrastructure. |
| `functions/src/reviews/syncRunClubReviewStats.ts` | Recomputes `runClubs.rating` and `reviewCount` from `reviews` after create/update/delete. | Keep the recompute trigger as the aggregate safety net for callable-owned review mutations. If account deletion anonymizes instead of deletes reviews, no rating recompute is needed. |
| `functions/src/runs/signUpForFreeRun.ts` | Callable wrapper for free-run booking. Delegates to `signUpUserForRun`, which writes `runParticipations` and run count/gender projections only. | Keep wrapper. Shared booking logic now uses `runParticipations` as the only roster source. |
| `functions/src/runs/joinRunWaitlist.ts` | `joinRunWaitlist` and `leaveRunWaitlist` write `runParticipations/{runId_uid}` and maintain `runs.waitlistedCount`. | Keep callables. Direct client `runs/{runId}` waitlist updates are removed. |
| `functions/src/runs/cancelRunSignUp.ts` | Callable cancels the caller's participation, optionally promotes a waitlisted user, refunds paid bookings, updates `runParticipations`, and maintains run count/gender projections. | Keep callable. Promotion now queries waitlisted participation edges instead of reading a run array. |
| `functions/src/runClubs/membership.ts` | Callables write `runClubMemberships` and maintain `runClubs.memberCount`. Per-club push opt-in is callable-owned. | Keep callables. No user or club membership arrays are mirrored. |
| `functions/src/safety/reporting.ts` | Callable writes server-owned `reports`. It rate-limits authenticated users before the handler writes. | No relationship-doc work. Keep server-owned reports. |
| `functions/src/shared/auth.ts` | Shared callable auth guard. | No change. |
| `functions/src/shared/callableOptions.ts` | Shared App Check callable options. | No change. |
| `functions/src/shared/validation.ts` | Shared Zod callable and Firestore document validation helpers. | No change. Continue using this before adding deletion callables. |
| `functions/src/shared/relationshipDocuments.ts` | Central deterministic IDs and relationship patches. | Extend this with deletion/archive patches, for example `deletedRunClubMembershipPatch` and `deletedRunParticipationPatch`, instead of hand-building deletion state in multiple callables. |

### Firestore Rules Simplification Plan

Your premise is correct: the rules can become much simpler once relationship
documents are the source of truth and multi-document workflows are callable
owned. The safest simplification order is:

1. Done: add `leaveRunWaitlist` callable.
   - Replace `RunRepository.leaveWaitlist` direct `runs/{runId}` update.
   - Remove the only direct user update rule on `runs/{runId}`.
   - Result: clients read runs but never write runs.

2. Done: remove `users.savedRunIds` compatibility projection writes.
   - `savedRuns/{uid_runId}` already owns saved-run state.
   - Remove the batch update to `users/{uid}.savedRunIds` in
     `SavedRunRepository`.
   - Remove `isValidSavedRunIdsUpdate()` from rules.
   - Result: direct `users/{uid}` updates are limited to `fcmToken` only.

3. Done: switch rules attendance gates to `runParticipations`.
   - Replace the `runs.attendedUserIds` fallback in `hasAttendedRun`.
   - Update swipe and review rules tests to seed
     `runParticipations/{runId_uid}` with `status == attended`.
   - Result: rules stop reading hidden participant arrays for swipe/review
     eligibility.

4. Tighten private profile reads.
   - Change `users/{uid}` read from "any authenticated non-blocked user" to
     owner-only, after confirming all public surfaces use
     `publicProfiles/{uid}`.
   - Keep Functions unaffected because Admin SDK bypasses client rules.
   - Review rules can validate reviewer display name from `publicProfiles` if
     review writes remain direct.
   - Result: private profile fields such as email, DOB, phone, preferences,
     notification settings, and private identity data are no longer readable by
     other users.

5. Tighten membership-edge reads.
   - Current rule allows any authenticated user to read active
     `runClubMemberships`.
   - Production code currently relies primarily on user-owned membership
     queries and direct current-user membership docs. If public member lists are
     not a product requirement, restrict reads to the membership owner and club
     host.
   - If member lists are required, render them through public profile snapshots
     and deliberately document that active membership is public.

6. Done: delete dead relationship-array helpers from rules.
   - Removed the old direct-write run-club shape/update helpers from rules.
   - Run-club host update validation moved to `updateRunClub`.
   - Remove array-era denial tests once the corresponding fields are no longer
     accepted by the schema.

7. Done: move reviews callable-owned.
   - `createRunReview`, `updateRunReview`, and `deleteRunReview` own review
     mutations.
   - Rules deny direct review writes; the trigger remains the aggregate
     recompute safety net.

### Rules That Should Remain Narrow Direct Writes

Do not over-centralize these unless a concrete product need appears:

- `onboarding_drafts/{uid}` owner-only drafts.
- `savedRuns/{uid_runId}` owner create/delete.
- `swipes/{uid}/outgoing/{targetId}` owner create, because match creation is
  trigger-owned and the rule can stay deterministic.
- `matches/{matchId}/messages/{messageId}` participant create, because preview,
  unread count, notifications, and moderation are trigger-owned.
- `matches/{matchId}.unreadCounts.{uid}` participant reset to zero.
- `notifications/{uid}/items/{notificationId}.readAt` owner mark-read.
- `users/{uid}.fcmToken` owner runtime update.

### Deletion Flow Status

| Flow | Current status | Production-grade status |
|---|---|---|
| Delete account | `requestAccountDeletion` now writes `deletedUsers/{uid}`, deletes Storage profile photos and `publicProfiles/{uid}`, anonymizes `users/{uid}`, deletes Auth, and query-cleans memberships, participations, saved runs, swipes, matches, reviews, payments, notifications, blocks, and reports. | Backend implemented. Remaining product decisions: exact message retention/anonymization policy, payment retention wording, and admin observability/receipts. |
| Delete review | Exists as `deleteRunReview`, an author-only callable delete of `reviews/{runId~uid}`. `syncRunClubReviewStats` recomputes run-club rating/count after deletion. | Backend implemented. The premise that review IDs are duplicated on run/user docs is not true in the current model. Remaining work is any UI/product policy around edit/delete affordances. |
| Delete run | `cancelRun` handles runs with history. `deleteRun` now hard-deletes only unused hosted runs with no participations, payments, or reviews. Direct deletes stay denied. | Backend implemented. Remaining work: host UI/policy copy, refund policy, saved-run/swipe/match cleanup if we later allow broader run deletion. |
| Delete run club | `archiveRunClub` now marks hosted clubs archived. `deleteRunClub` hard-deletes only never-used clubs with no runs, payments, reviews, or non-host members, then removes the host claim. Direct deletes stay denied. | Backend implemented. Remaining work: host UI, browse/search filters for archived clubs, future-run cancellation/refund policy for archived active clubs. |

### Deletion Implementation Plan

1. Add shared deletion utilities.
   - Query helpers for `runClubMemberships`, `runParticipations`,
     `savedRuns`, `reviews`, `matches`, `swipes`, `payments`, `notifications`,
     and Storage.
   - BulkWriter or chunked batched writes with explicit operation receipts.
   - Idempotent patches so retries do not corrupt counts.

2. [x] Rewrite account deletion around relationship docs.
   - Marks `deletedUsers/{uid}` and deletes `publicProfiles/{uid}` plus
     Storage profile photos.
   - Deletes `savedRuns` owned by `uid`.
   - Marks `runClubMemberships` for `uid` as `deleted` and decrements active
     `memberCount`.
   - Marks `runParticipations` for `uid` as `deleted` and decrements count
     projections.
   - Deletes outgoing swipes and incoming swipes targeting `uid`.
   - Closes matches containing `uid` by setting `status: blocked` and clearing
     unread counts.
   - Anonymizes retained reviews by `reviewerUserId == uid`.
   - Retains payment records with `userDeleted` metadata.
   - Deletes owned notifications, block edges involving `uid`, and clears FCM.
   - Marks reports involving `uid` with deleted-user reviewer context.
   - Anonymizes private `users/{uid}` and deletes Auth user last.

3. [x] Add run deletion/cancellation policy.
   - If a run has participations, payments, or reviews, use `cancelRun`; do not
     hard delete.
   - If a run has no participations, payments, or reviews, `deleteRun` allows
     host-owned hard delete.
   - Broader cleanup graph remains deferred until product asks for deleting
     historical runs rather than cancelling them.

4. [x] Add run-club archive/delete policy.
   - `archiveRunClub` marks a hosted club archived for clubs with history.
   - `deleteRunClub` hard-deletes only never-used clubs with no runs, payments,
     reviews, or non-host members.
   - Client browse/search filters and host UI are still queued.

5. [x] Review deletion policy.
   - `deleteRunReview` owns author validation and document deletion.
   - Keep `syncRunClubReviewStats` as the aggregate recompute safety net.

### Proposed Approval Queue

1. [x] Rules simplification slice A: add `leaveRunWaitlist` callable and
   remove the last direct run update rule.
2. [x] Rules simplification slice B: remove `users.savedRunIds` projection
   writes and the saved-run profile update rule.
3. [x] Rules simplification slice C: switch swipe eligibility rules to
   `runParticipations` only and tighten `users/{uid}` reads to owner-only.
4. [x] Rules simplification slice D: move run-club profile edits and review
   mutations to callables, then deny direct writes in rules.
5. Compatibility retirement slice: remove participant/member/saved arrays from
   Functions writes, generated contracts, validation tooling, and tests after
   beta migration/reset approval.
5. [x] Deletion slice A: rewrite account deletion around relationship-doc
   queries.
6. [x] Deletion slice B: implement run cancellation/delete policy and
   host/admin callable surface.
7. [x] Deletion slice C: implement run-club archive/delete policy and backend
   callable surface.

## Deletion Payoff

### Account Deletion

After relationship migration, account deletion becomes query-driven:

- `runClubMemberships.where('uid', '==', uid)` for clubs the user joined.
- `runParticipations.where('uid', '==', uid)` for signup, waitlist,
  attendance, cancellation, and refund-review context.
- `savedRuns.where('uid', '==', uid)` for saved runs.
- `reviews.where('reviewerUserId', '==', uid)` for anonymized retained reviews.
- `payments.where('userId', '==', uid)` for retained financial records.
- `matches.where('user1Id', '==', uid)` and `matches.where('user2Id', '==',
  uid)` for thread closure/anonymization.
- `swipes/{uid}/outgoing` and collection-group outgoing swipes where
  `targetId == uid` for swipe cleanup.

This removes the need to scan every club/run/user document to remove one UID
from arrays.

### Run Deletion

Run deletion becomes bounded by:

- `runParticipations.where('runId', '==', runId)`
- `payments.where('runId', '==', runId)`
- `reviews.where('runId', '==', runId)`
- `swipes` or `matches` where `runId == runId`, if product policy requires
  cleanup

### Run Club Deletion

Club deletion becomes bounded by:

- `runClubMemberships.where('clubId', '==', clubId)`
- `runs.where('runClubId', '==', clubId)`
- `reviews.where('runClubId', '==', clubId)`
- derived rating/count projections

### Chat/Match Deletion

Moving messages under `matches/{matchId}/messages` keeps the match/thread
header and its message timeline together. Closed anonymized threads no longer
leave a separate `chats/{matchId}` namespace to reason about.

## Verification Log

Record every pass here with commands, result, and remaining gaps.

| Date | Scope | Verification | Result |
|---|---|---|---|
| 2026-05-08 | Aggregate projection repair after edge-document migration | `node tool/recompute_run_club_member_counts.mjs --env dev --json`; `node tool/recompute_run_club_member_counts.mjs --env dev --apply`; `node tool/recompute_run_aggregate_counts.mjs --env dev --json`; `node tool/recompute_run_aggregate_counts.mjs --env dev --apply`; `node tool/validate_firestore_data.mjs --env dev --json`; `node --test tool/recompute_run_club_member_counts.test.mjs tool/recompute_run_aggregate_counts.test.mjs`; `npm --prefix functions test` | Passed. Dev had 0 membership edges and 0 participation edges after compatibility-array retirement, so stale parent projections were reset from the edge-doc source of truth: 2 run-club `memberCount` repairs and 4 run aggregate repairs. Validator now checks parent count drift against `runClubMemberships` and `runParticipations`; dev validation scanned 10 docs with 0 errors and 0 warnings. |
| 2026-05-06 | Tracker creation | Document created before code edits. | Complete. |
| 2026-05-06 | Relationship models, edge write paths, match-scoped messages, rules, and migration scaffolding | `flutter analyze --no-fatal-infos ...`; `flutter test test/chats/chat_repository_test.dart test/runs/run_detail_controller_test.dart test/runs/run_detail_widgets_test.dart`; `npm --prefix functions run lint`; `npm --prefix functions run build`; `npm --prefix functions test`; `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`; `node --check tool/firestore_relationship_migration.mjs`; `node --check tool/validate_firestore_data.mjs` | Passed. Superseded by the 2026-05-07 retirement pass for compatibility-array removal. Remaining non-array gaps are deletion UI/product policy and any migration/reset decision for beta data. |
| 2026-05-06 | Saved-run read migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/runs/run_detail_controller_test.dart test/runs/run_detail_widgets_test.dart`; `flutter analyze --no-fatal-infos lib/runs/data/saved_run_repository.dart lib/runs/presentation/run_detail_view_model.dart lib/runs/presentation/run_detail_screen.dart lib/runs/presentation/widgets/run_detail_body.dart lib/user_profile/data/user_profile_repository.dart test/runs/run_detail_controller_test.dart test/runs/run_detail_widgets_test.dart` | Passed. Run detail now reads saved state from `savedRuns/{uid_runId}` through the view-model seam. Superseded by later rows for run-club membership, run participation, and final array retirement. |
| 2026-05-06 | Run-club membership read migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/run_clubs/run_clubs_list_controller_test.dart test/run_clubs/run_clubs_controllers_test.dart test/dashboard/dashboard_screen_test.dart test/runs/run_map_view_model_test.dart test/runs/run_repository_test.dart`; `flutter analyze --no-fatal-infos ...`; `rg -n "joinedRunClubIds|memberUserIds|hasMember\\(" lib/dashboard lib/run_clubs/presentation lib/runs/presentation/run_map_view_model.dart lib/runs/data/run_repository.dart` | Passed. Dashboard recommendations, Run Clubs list/detail membership state, and Run Map recommendations now read membership edges. Production presentation/view-model grep for old membership arrays is clean; remaining relationship-array UI work is run participation. |
| 2026-05-06 | Run-detail participation read migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/runs/run_detail_controller_test.dart test/runs/run_detail_widgets_test.dart`; `flutter analyze --no-fatal-infos lib/runs/presentation/run_detail_view_model.dart lib/runs/presentation/run_detail_screen.dart lib/runs/presentation/widgets/run_detail_body.dart lib/runs/presentation/widgets/run_detail_cta.dart lib/runs/presentation/widgets/run_detail_social_section.dart lib/runs/presentation/run_arrival_action.dart test/runs/run_detail_controller_test.dart test/runs/run_detail_widgets_test.dart` | Passed. Run detail now uses the viewer's `RunParticipation` edge for booking/waitlist/attendance CTA state and review eligibility. Superseded by later rows for dashboard/calendar, attendance, swipe, roster/count, and final array retirement. |
| 2026-05-06 | Signed-up and attended run stream migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/runs/run_repository_test.dart test/dashboard/dashboard_screen_test.dart test/calendar/calendar_screen_test.dart test/runs/run_map_view_model_test.dart test/swipes/swipe_hub_screen_test.dart`; `flutter analyze --no-fatal-infos lib/runs/data/run_repository.dart test/runs/run_repository_test.dart test/calendar/calendar_screen_test.dart test/dashboard/dashboard_screen_test.dart test/runs/run_map_view_model_test.dart test/swipes/swipe_hub_screen_test.dart` | Passed. `watchSignedUpRunsProvider` and `watchAttendedRunsProvider` now query `runParticipations` by user/status, then watch matching run documents by ID. Superseded by later rows for attendance, swipe, roster/count, and final array retirement. |
| 2026-05-06 | Attendance management participation read migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/runs/attendance_sheet_screen_test.dart`; `flutter analyze --no-fatal-infos lib/runs/presentation/attendance_sheet_screen.dart lib/runs/presentation/attendance_sheet_view_model.dart test/runs/attendance_sheet_screen_test.dart`; `rg -n "run\\.signedUpUserIds|run\\.attendedUserIds|run\\.waitlistUserIds|run\\.(isSignedUp|hasAttended|isOnWaitlist|statusFor|eligibilityFor)" lib/runs/presentation/attendance_sheet_screen.dart lib/runs/presentation/attendance_sheet_view_model.dart` | Passed. Host attendance now uses `AttendanceSheetViewModel`, which derives roster and checked-in state from `runParticipations` statuses. Superseded by later rows for swipe, roster/count, and final array retirement. |
| 2026-05-06 | Swipe candidate and recap participation read migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/swipes/swipe_candidate_repository_test.dart test/swipes/swipe_candidate_repository_preferences_test.dart test/swipes/swipe_empty_content_test.dart test/swipes/swipe_queue_notifier_test.dart test/swipes/run_recap_screen_test.dart test/runs/attendance_sheet_screen_test.dart`; `flutter analyze --no-fatal-infos lib/runs/data/run_participation_repository.dart lib/swipes/data/swipe_candidate_repository.dart lib/swipes/presentation/swipe_empty_content.dart lib/swipes/presentation/swipe_screen.dart lib/swipes/presentation/run_recap_screen.dart lib/swipes/presentation/run_recap_view_model.dart lib/swipes/presentation/run_recap_view_model.g.dart test/runs/runs_test_helpers.dart test/swipes/swipe_candidate_repository_test.dart test/swipes/swipe_candidate_repository_preferences_test.dart test/swipes/swipe_empty_content_test.dart test/swipes/run_recap_screen_test.dart`; `rg -n "run\\.hasAttended|run\\.attendedUserIds" lib/swipes/data/swipe_candidate_repository.dart lib/swipes/presentation/swipe_empty_content.dart lib/swipes/presentation/swipe_screen.dart lib/swipes/presentation/run_recap_screen.dart lib/swipes/presentation/run_recap_view_model.dart` | Passed. Swipe candidate generation now fetches attended participants from `runParticipations`, `SwipeScreen` passes the viewer's participation edge into empty-state copy, and `RunRecapViewModel` derives the vibe roster plus checked-in count from participation statuses. Superseded by later rows for roster/count and final array retirement. |
| 2026-05-06 | Run participation roster/count projection migration | `dart run build_runner build --delete-conflicting-outputs`; `dart tool/generate_firestore_types.dart`; `node tool/check_firestore_contract.mjs`; `npm --prefix functions run lint`; `npm --prefix functions run build`; `npm --prefix functions test`; focused Flutter tests for who-is-running, host roster, host stats, swipes, attendance, and dashboard; `flutter analyze --no-fatal-infos ...`; `rg -n "\\.signedUpUserIds|\\.attendedUserIds|\\.waitlistUserIds" lib -g'*.dart'` | Passed for touched behavior. `Run` now exposes `bookedCount`, `waitlistedCount`, and `checkedInCount` projections; Functions maintain them on create/signup/waitlist/cancel/attendance/self-check-in; `WhoIsRunning` and `HostRunManageScreen` read exact edge rosters. Superseded by the 2026-05-07 retirement pass for generated model/tool/test cleanup. |
| 2026-05-07 | Relationship compatibility array retirement | `dart run build_runner build --delete-conflicting-outputs`; `dart tool/generate_firestore_types.dart`; `node tool/check_firestore_contract.mjs`; `node --check tool/validate_firestore_data.mjs`; `node --check tool/firestore_relationship_migration.mjs`; `npm --prefix functions run lint`; `npm --prefix functions run build`; `npm --prefix functions test`; `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`; focused Flutter analyze/tests; `rg -n "signedUpUserIds|waitlistUserIds|attendedUserIds|memberUserIds|joinedRunClubIds|savedRunIds" lib functions/src functions/test test tool firestore.rules firestore.indexes.json` | Passed. Production source, Functions, Firestore rules/indexes, generated contract tooling, migration/validation tooling, and active tests no longer contain or preserve the retired relationship array fields. |
| 2026-05-07 | Pre-deploy relationship-doc verification | `dart run build_runner build --delete-conflicting-outputs`; `dart tool/generate_firestore_types.dart`; `node tool/check_firestore_contract.mjs`; `node --check tool/validate_firestore_data.mjs`; `node --check tool/firestore_relationship_migration.mjs`; `npm --prefix functions run lint`; `npm --prefix functions run build`; `npm --prefix functions test`; `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`; `flutter analyze --no-fatal-infos`; `flutter test -j 1`; focused calendar, match-celebration, run-draft, run-club, profile, and run tests. | Passed. Fixed time-coupled calendar/run-draft fixtures and a scroll-target miss in the match celebration test before deploy. Beta data strategy is reset or validated edge docs, not compatibility-array preservation. |
| 2026-05-07 | Firebase deploy | `./tool/firebase_with_env.sh dev deploy --only functions`; `./tool/firebase_with_env.sh dev deploy --only firestore:indexes`; `./tool/firebase_with_env.sh dev deploy --only firestore:rules`; same sequence for `staging` and `prod`. | Passed. Functions, Firestore indexes, and Firestore rules deployed to `catchdates-dev`, `catchdates-staging`, and `catch-dating-app-64e51`. Storage rules were not deployed because `storage.rules` was unchanged. Post-deploy callable invoker sync was not run because it grants public Cloud Run invoker IAM and needs explicit human approval. |
