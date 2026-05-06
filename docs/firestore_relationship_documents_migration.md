---
doc_id: firestore_relationship_documents_migration
version: 1.0.8
updated: 2026-05-06
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
- Compatibility arrays are temporary projections only. Do not introduce new UI
  dependencies on them.
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
| `users/{uid}` | Private user profile/account source of truth. | Stores `joinedRunClubIds` and `savedRunIds`, which are relationship indexes rather than profile fields. |
| `publicProfiles/{uid}` | Backend-derived public profile projection. | Good shape; keep backend-owned. |
| `runClubs/{clubId}` | Run club profile/details. | Stores `memberUserIds`; list/detail surfaces usually need counts, not full member IDs. |
| `runs/{runId}` | Run details and host-owned schedule fields. | Now stores aggregate `bookedCount`, `waitlistedCount`, and `checkedInCount`; legacy participant arrays remain temporary compatibility projections. |
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

### Array-Backed Relationships To Retire

| Current field | Target relationship document | Notes |
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
- [x] Record current direct client writes and compatibility arrays.

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
- [x] Keep `users.joinedRunClubIds` and `runClubs.memberUserIds` as temporary
  compatibility projections.
- [x] Update rules and tests for server-owned membership docs.
- [x] Move Dashboard, Run Clubs list/detail, and Run Map membership reads to
  `runClubMemberships` and `memberCount`.
- [ ] Remove compatibility membership arrays/writes after migration/reset
  policy is finalized.

### Phase 4: Run Participation Edges

- [x] Add participation repository/provider seams in Flutter.
- [x] Update signup, payment verification, waitlist, cancellation, host
  attendance, and self-check-in Functions to write `runParticipations`.
- [x] Keep run participation arrays as temporary compatibility projections.
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
- [ ] Move remaining roster/count projections off participant arrays.

### Phase 5: Saved Run Edges

- [x] Add saved-run repository/provider seam.
- [x] Move save/unsave writes to `savedRuns/{uid_runId}` while keeping
  `users.savedRunIds` as a temporary compatibility projection.
- [x] Decide hard delete versus soft delete for unsave.
- [x] Update rules and tests for owner-owned saved-run docs.
- [x] Move run-detail saved-state UI reads off `users.savedRunIds`.
- [ ] Remove compatibility `users.savedRunIds` writes after migration/reset
  policy is finalized.

### Phase 6: Migration Tooling

- [x] Add dry-run mode that reads old arrays and reports relationship docs to
  create.
- [x] Add apply mode that writes missing relationship docs idempotently.
- [ ] Validate aggregate counts and duplicate/missing references in migration
  apply output.
- [x] Add a beta-reset fallback note that requires explicit human approval
  before deleting beta accounts or clearing production-like data.

### Phase 7: Delete/Anonymize Cleanup

- [ ] Rewrite account deletion to query relationship docs by `uid`.
- [ ] Add run deletion plan that queries `runParticipations`, payments,
  reviews, swipes, and matches by run.
- [ ] Add club deletion plan that queries `runClubMemberships`, runs, reviews,
  and aggregate projections by club.
- [ ] Keep review deletion/anonymization consistent with the error/data
  contract decisions already documented.

### Phase 8: Compatibility Array Retirement

- [ ] Remove array dependencies from Flutter models/read paths.
- [ ] Remove array writes from Functions.
- [ ] Tighten rules so old array fields are server-owned or deleted.
- [ ] Update validation tooling to reject large stale relationship arrays.
- [ ] Archive compatibility notes after migration proof is recorded.

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
| 2026-05-06 | Tracker creation | Document created before code edits. | Complete. |
| 2026-05-06 | Relationship models, edge write paths, match-scoped messages, rules, and migration scaffolding | `flutter analyze --no-fatal-infos ...`; `flutter test test/chats/chat_repository_test.dart test/runs/run_detail_controller_test.dart test/runs/run_detail_widgets_test.dart`; `npm --prefix functions run lint`; `npm --prefix functions run build`; `npm --prefix functions test`; `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"`; `node --check tool/firestore_relationship_migration.mjs`; `node --check tool/validate_firestore_data.mjs` | Passed. Remaining gaps: UI reads still use compatibility arrays in several surfaces, migration apply needs count validation, account/run/club deletion rewrites still pending. |
| 2026-05-06 | Saved-run read migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/runs/run_detail_controller_test.dart test/runs/run_detail_widgets_test.dart`; `flutter analyze --no-fatal-infos lib/runs/data/saved_run_repository.dart lib/runs/presentation/run_detail_view_model.dart lib/runs/presentation/run_detail_screen.dart lib/runs/presentation/widgets/run_detail_body.dart lib/user_profile/data/user_profile_repository.dart test/runs/run_detail_controller_test.dart test/runs/run_detail_widgets_test.dart` | Passed. Run detail now reads saved state from `savedRuns/{uid_runId}` through the view-model seam. Remaining array-read work is run-club membership and run participation surfaces. |
| 2026-05-06 | Run-club membership read migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/run_clubs/run_clubs_list_controller_test.dart test/run_clubs/run_clubs_controllers_test.dart test/dashboard/dashboard_screen_test.dart test/runs/run_map_view_model_test.dart test/runs/run_repository_test.dart`; `flutter analyze --no-fatal-infos ...`; `rg -n "joinedRunClubIds|memberUserIds|hasMember\\(" lib/dashboard lib/run_clubs/presentation lib/runs/presentation/run_map_view_model.dart lib/runs/data/run_repository.dart` | Passed. Dashboard recommendations, Run Clubs list/detail membership state, and Run Map recommendations now read membership edges. Production presentation/view-model grep for old membership arrays is clean; remaining relationship-array UI work is run participation. |
| 2026-05-06 | Run-detail participation read migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/runs/run_detail_controller_test.dart test/runs/run_detail_widgets_test.dart`; `flutter analyze --no-fatal-infos lib/runs/presentation/run_detail_view_model.dart lib/runs/presentation/run_detail_screen.dart lib/runs/presentation/widgets/run_detail_body.dart lib/runs/presentation/widgets/run_detail_cta.dart lib/runs/presentation/widgets/run_detail_social_section.dart lib/runs/presentation/run_arrival_action.dart test/runs/run_detail_controller_test.dart test/runs/run_detail_widgets_test.dart` | Passed. Run detail now uses the viewer's `RunParticipation` edge for booking/waitlist/attendance CTA state and review eligibility. A regression test proves stale compatibility arrays do not decide current-viewer CTA state. Remaining participation-array reads are dashboard/calendar run streams, attendance management, swipe candidate/recap surfaces, and roster/count projections. |
| 2026-05-06 | Signed-up and attended run stream migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/runs/run_repository_test.dart test/dashboard/dashboard_screen_test.dart test/calendar/calendar_screen_test.dart test/runs/run_map_view_model_test.dart test/swipes/swipe_hub_screen_test.dart`; `flutter analyze --no-fatal-infos lib/runs/data/run_repository.dart test/runs/run_repository_test.dart test/calendar/calendar_screen_test.dart test/dashboard/dashboard_screen_test.dart test/runs/run_map_view_model_test.dart test/swipes/swipe_hub_screen_test.dart` | Passed. `watchSignedUpRunsProvider` and `watchAttendedRunsProvider` now query `runParticipations` by user/status, then watch matching run documents by ID. Dashboard, Calendar, Run Map, Activity, and Swipe Hub now consume edge-backed run streams through the existing provider seam. Remaining participation-array reads are attendance management, swipe candidate generation/recap, and roster/count projections. |
| 2026-05-06 | Attendance management participation read migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/runs/attendance_sheet_screen_test.dart`; `flutter analyze --no-fatal-infos lib/runs/presentation/attendance_sheet_screen.dart lib/runs/presentation/attendance_sheet_view_model.dart test/runs/attendance_sheet_screen_test.dart`; `rg -n "run\\.signedUpUserIds|run\\.attendedUserIds|run\\.waitlistUserIds|run\\.(isSignedUp|hasAttended|isOnWaitlist|statusFor|eligibilityFor)" lib/runs/presentation/attendance_sheet_screen.dart lib/runs/presentation/attendance_sheet_view_model.dart` | Passed. Host attendance now uses `AttendanceSheetViewModel`, which derives roster and checked-in state from `runParticipations` statuses. Regression tests seed stale run arrays and prove the UI ignores them. Remaining participation-array reads are swipe candidate generation/recap and roster/count projections. |
| 2026-05-06 | Swipe candidate and recap participation read migration | `dart run build_runner build --delete-conflicting-outputs`; `flutter test test/swipes/swipe_candidate_repository_test.dart test/swipes/swipe_candidate_repository_preferences_test.dart test/swipes/swipe_empty_content_test.dart test/swipes/swipe_queue_notifier_test.dart test/swipes/run_recap_screen_test.dart test/runs/attendance_sheet_screen_test.dart`; `flutter analyze --no-fatal-infos lib/runs/data/run_participation_repository.dart lib/swipes/data/swipe_candidate_repository.dart lib/swipes/presentation/swipe_empty_content.dart lib/swipes/presentation/swipe_screen.dart lib/swipes/presentation/run_recap_screen.dart lib/swipes/presentation/run_recap_view_model.dart lib/swipes/presentation/run_recap_view_model.g.dart test/runs/runs_test_helpers.dart test/swipes/swipe_candidate_repository_test.dart test/swipes/swipe_candidate_repository_preferences_test.dart test/swipes/swipe_empty_content_test.dart test/swipes/run_recap_screen_test.dart`; `rg -n "run\\.hasAttended|run\\.attendedUserIds" lib/swipes/data/swipe_candidate_repository.dart lib/swipes/presentation/swipe_empty_content.dart lib/swipes/presentation/swipe_screen.dart lib/swipes/presentation/run_recap_screen.dart lib/swipes/presentation/run_recap_view_model.dart` | Passed. Swipe candidate generation now fetches attended participants from `runParticipations`, `SwipeScreen` passes the viewer's participation edge into empty-state copy, and `RunRecapViewModel` derives the vibe roster plus checked-in count from participation statuses. Remaining participation-array reads are roster/count projections only. |
| 2026-05-06 | Run participation roster/count projection migration | `dart run build_runner build --delete-conflicting-outputs`; `dart tool/generate_firestore_types.dart`; `node tool/check_firestore_contract.mjs`; `npm --prefix functions run lint`; `npm --prefix functions run build`; `npm --prefix functions test`; focused Flutter tests for who-is-running, host roster, host stats, swipes, attendance, and dashboard; `flutter analyze --no-fatal-infos ...`; `rg -n "\\.signedUpUserIds|\\.attendedUserIds|\\.waitlistUserIds" lib -g'*.dart'` | Passed for touched behavior. `Run` now exposes `bookedCount`, `waitlistedCount`, and `checkedInCount` projections; Functions maintain them on create/signup/waitlist/cancel/attendance/self-check-in; `WhoIsRunning` and `HostRunManageScreen` read exact edge rosters. Production UI no longer directly reads participant arrays; only generated `Run` serialization keeps legacy arrays during migration. A broad run-club widget file still has an unrelated follow-button test failure outside this pass. |
