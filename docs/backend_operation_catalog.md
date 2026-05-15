---
doc_id: backend_operation_catalog
version: 1.2.0
updated: 2026-05-12
owner: recursive_audit_loop
status: active
---

# Backend Operation Catalog

## Read Policy

Read this before changing Cloud Functions, Firestore rules, repository writes,
callable interfaces, trigger-owned projections, payments, safety workflows, or
notification fan-out. Treat `tool/firestore_contract.json` as the
machine-readable ownership contract and this document as the human map.

## Operating Rules

- Public projections such as `publicProfiles/{uid}` are backend-owned. The
  client reads them but must not write them directly.
- Multi-document product mutations should be callable-owned unless the direct
  Firestore rule is narrow, owner-scoped, and easy to test.
- Trigger-owned derived fields must be idempotent or recomputed from source
  documents.
- Direct client writes require explicit Firestore rules tests for ownership,
  field allowlists, and path/data identity where relevant.
- Storage writes count as backend-surface operations. If a Storage upload also
  changes Firestore, the Firestore write owner must be documented separately.

## Boundary Decision Guide

Use direct client edge writes only when the write is the user's own narrow
source-of-truth action and Firestore rules can prove the full invariant from
the path, authenticated UID, allowlisted fields, and small cross-doc checks.
Good examples are saved runs, outgoing swipes, and match-scoped chat messages.

Keep callables when the server must decide whether the mutation is valid across
multiple documents, hidden safety state, capacity, schedule conflicts, payment
state, role/host authority, rate limits, or account lifecycle. Good examples
are run-club membership, run creation, booking, waitlist, attendance, reviews,
payments, safety actions, and account deletion.

Use Firestore triggers for projections and side effects after a canonical edge
or entity write exists. Triggers must either recompute from source documents or
use an idempotency receipt when retrying an increment-like update could double
count. Parent relationship projections such as `memberCount` and `nextRunAt`
should be repairable from edge/source documents.

## Interface Types

| Interface | Meaning | Primary enforcement |
|---|---|---|
| Direct Firestore | Flutter repository writes a document directly. | Firestore rules and rules tests. |
| Callable Function | Flutter repository/controller calls a Firebase callable. | Auth, App Check, Zod validation, Admin SDK writes, tests. |
| Firestore Trigger | Function reacts to document create/write. | Source document rules plus trigger idempotency. |
| Storage Trigger | Function reacts to Storage object finalize/delete. | Storage rules plus trigger validation/moderation. |
| HTTP Function | External web/client POST endpoint. | CORS, validation, rate limiting, server writes. |
| Server/Admin Only | No client write surface. | Firestore rules deny client writes. |

## Current Audit Findings

| Priority | Finding | Status |
|---|---|---|
| P0 | `tool/firestore_contract.json` was stale for `users/{uid}.firstName`, `lastName`, and `displayName`; the generated Functions type and Firestore rules already had the fields. | Fixed in this pass. |
| P0 | Account deletion anonymized `name` but did not clear retained `firstName`, `lastName`, or `displayName` on `users/{uid}`. | Fixed in this pass. |
| P1 | `RATE_LIMITS` declared several callable limits that were not applied at the handlers: `verifyRazorpayPayment`, `cancelRunSignUp`, `joinRunWaitlist`, `blockUser`, `unblockUser`, and `requestAccountDeletion`. `updateUserProfile` also had no configured limit. | Fixed. All listed handlers now call `checkRateLimit`; `updateUserProfile` is 60/minute to allow brisk field-by-field editing without leaving profile writes unbounded. |
| P2 | The machine-readable contract records operations by collection, but not the Dart initiator method for every operation. | This doc fills the human map; a later tooling pass can validate Dart initiators automatically. |
| P2 | Notification fan-out now has a durable backend-owned in-app timeline for match, message, new club run, run signup, waitlist-promotion, upcoming run reminder, run schedule/location updates, and run cancellation events. | Implemented; keep adding new categories through the same Functions-owned interface. |
| P1 | Edge documents were the source of truth, but run-club parent projections relied only on callable updates or batch repair tools. | Fixed. `syncRunClubMemberStats` recomputes `memberCount` from active membership edges, and `syncRunClubNextRun` recomputes `nextRunAt` / `nextRunLabel` from active future run documents. Run callables also refresh the next-run projection before returning. |

## Cloud Functions Inventory

| Function | Type | Initiator | Writes | Notes |
|---|---|---|---|---|
| `updateUserProfile` | Callable | `UserProfileRepository.updateUserProfile` | `users/{uid}` | Validates profile patches with generated Ajv contract validators; owns complex profile edits after initial create; rate-limited at 60/minute. |
| `syncPublicProfile` | Firestore trigger on `users/{uid}` writes | Backend | `publicProfiles/{uid}` set/delete, hosted `runClubs/{clubId}.hostName` / `hostAvatarUrl` updates, authored `reviews/{reviewId}.reviewerName` updates | Sole owner of current user-identity projections. Uses `displayName`, then first name, then legacy fallback; projects grouped `profilePhotos` plus legacy `photoUrls`/`photoThumbnailUrls` compatibility arrays for tiny avatar surfaces. Existing stale public profiles can be repaired with `node tool/recompute_public_profiles.mjs --env dev --apply`; existing stale run-club host projections can be repaired with `node tool/recompute_run_club_host_profiles.mjs --env dev --apply`; existing stale review author names can be repaired with `node tool/recompute_review_author_profiles.mjs --env dev --apply` after `npm --prefix functions run build`. |
| `generateProfilePhotoThumbnail` | Storage trigger on `users/{uid}/photos/{fileName}` finalize | Backend | Storage `users/{uid}/photoThumbnails/{fileName}`, `users/{uid}.photoThumbnailUrls`, `users/{uid}.profilePhotos` | Generates 160px JPEG thumbnails for avatar-scale surfaces. Dashboard/run-detail hype avatars must use thumbnail URLs, not full profile photos. Existing beta data can be backfilled with `npm run backfill:profile-thumbnails -- --apply` after setting `FIREBASE_STORAGE_BUCKET`; the script now updates grouped `profilePhotos` as well as legacy thumbnail arrays. |
| `createRunClub` | Callable | `RunClubsRepository.createRunClub` | `runClubs/{clubId}`, `runClubMemberships/{clubId_uid}`, `runClubHostClaims/{uid}` | Server derives host identity from authenticated user using the shared public profile projection helper; initializes lifecycle fields as active/unarchived; the membership edge is the source of truth and `memberCount` is the parent aggregate. `runClubHostClaims/{uid}` enforces the current product rule that a user can host at most one run club. |
| `updateRunClub` | Callable | `RunClubsRepository.updateRunClub` | `runClubs/{clubId}` descriptive fields | Host-only profile edit seam. Direct client updates to `runClubs/{clubId}` are denied so Zod owns field validation and aggregate/projection fields stay backend-owned. |
| `joinRunClub` | Callable | `RunClubsRepository.joinClub` | `runClubMemberships/{clubId_uid}`, `runClubs/{clubId}.memberCount` | Multi-doc membership mutation; does not mirror membership into user or club arrays. `syncRunClubMemberStats` repairs the parent count from active membership edges after any membership write. |
| `leaveRunClub` | Callable | `RunClubsRepository.leaveClub` | `runClubMemberships/{clubId_uid}`, `runClubs/{clubId}.memberCount` | Rejects host leaving their own club; does not mirror membership into user or club arrays. `syncRunClubMemberStats` repairs the parent count from active membership edges after any membership write. |
| `syncRunClubMemberStats` | Firestore trigger on `runClubMemberships/{membershipId}` write | Backend | `runClubs/{clubId}.memberCount` | Recomputes active membership count from edge documents. This makes duplicate trigger delivery safe and repairs stale callable-era or manually drifted parent projections. |
| `archiveRunClub` | Callable | Backend-ready; host UI queued | `runClubs/{clubId}.status/archived/archivedAt/archiveReason` | Host-only archive seam for clubs with history. Prevent browse/search usage once client filters are added; hard delete is reserved for unused clubs. |
| `deleteRunClub` | Callable | Backend-ready; host/admin UI queued | `runClubs/{clubId}` delete, host `runClubMemberships/{clubId_uid}` delete, `runClubHostClaims/{uid}` delete | Host-only hard delete for never-used clubs. Rejects clubs with runs, payments, reviews, or non-host members; releases the one-club host claim only after the hard delete is allowed. |
| `createRun` | Callable | `RunRepository.createRun` | `runs/{runId}`, `runClubs/{clubId}.nextRunAt/nextRunLabel`, `notifications/{uid}/items/{notificationId}`, FCM to active club members with run-reminder pushes enabled | Host authority is verified server-side from the run club; initializes run lifecycle as `active` plus participation count projections to zero; refreshes the club next-run projection before returning; new-run notification fan-out is best-effort after the run document commits. |
| `updateRun` | Callable | `RunRepository.updateRunDetails` | `runs/{runId}`, `runClubs/{clubId}.nextRunAt/nextRunLabel`, `notifications/{uid}/items/{notificationId}`, FCM to signed-up/waitlisted participants for schedule/location changes | Host-editable schedule/descriptive fields only. Descriptive-only edits do not notify participants; schedule/location changes produce deterministic `runUpdated_${runId}` items. Cancelled runs cannot be edited. |
| `cancelRun` | Callable | Backend-ready; host UI and cancellation policy are queued | `runs/{runId}.status/cancelledAt/cancellationReason`, `runClubs/{clubId}.nextRunAt/nextRunLabel`, `notifications/{uid}/items/{notificationId}`, FCM to signed-up/waitlisted participants | Host-only cancellation seam. Marks the canonical run as cancelled, refreshes the club next-run projection, and fans out deterministic `runCancelled_${runId}` activity. Refund/payment policy and host UI are intentionally not exposed yet. |
| `deleteRun` | Callable | Backend-ready; host/admin UI queued | `runs/{runId}` delete, `runClubs/{clubId}.nextRunAt/nextRunLabel` refresh | Host-only hard delete for unused runs. Rejects runs with participations, payments, or reviews; use `cancelRun` for runs with history. |
| `syncRunClubNextRun` | Firestore trigger on `runs/{runId}` write | Backend | `runClubs/{clubId}.nextRunAt`, `nextRunLabel` | Recomputes the earliest future active run for affected clubs from `runs`. This keeps club list/detail projections in sync after create, update, cancellation, deletion, retries, or repair tooling. |
| `signUpForFreeRun` | Callable | `PaymentRepository.bookFreeRun` | `runParticipations/{runId_uid}`, `runs/{runId}.bookedCount`, `runs/{runId}.waitlistedCount`, `runs/{runId}.genderCounts`, `notifications/{uid}/items/{notificationId}` | Delegates core booking to `signUpUserForRun`; writes an in-app booking confirmation or waitlist-promotion activity item. |
| `createRazorpayOrder` | Callable | `PaymentRepository.processPayment` | Razorpay order only | Uses trusted run price and server-side secrets; rejects cancelled runs before creating an order. |
| `verifyRazorpayPayment` | Callable | Razorpay success callback in `PaymentRepository` | `payments/{paymentId}`, `runParticipations/{runId_uid}`, run count/gender projections, `notifications/{uid}/items/{notificationId}` | Rate-limited before signature validation or Razorpay fetch; verifies signature, books paid run, and writes an in-app booking confirmation. |
| `cancelRunSignUp` | Callable | `RunRepository.cancelSignUpViaFunction` | `runParticipations/{runId_uid}`, `runs/{runId}.bookedCount`, `runs/{runId}.waitlistedCount`, `runs/{runId}.genderCounts`, `payments/{paymentId}` refund status, `notifications/{uid}/items/{notificationId}`, FCM to promoted waitlisted user | Rate-limited before payment lookup; may promote a waitlisted runner and refund paid bookings; writes exact count projections after promotion math. |
| `joinRunWaitlist` | Callable | `RunRepository.joinWaitlistViaFunction` | `runParticipations/{runId_uid}`, `runs/{runId}.waitlistedCount` | Rate-limited before transaction work; server checks block boundary without exposing block state in rules. |
| `leaveRunWaitlist` | Callable | `RunRepository.leaveWaitlist` | `runParticipations/{runId_uid}`, `runs/{runId}.waitlistedCount` | Rate-limited before transaction work; marks the caller's waitlist edge cancelled. |
| `markRunAttendance` | Callable | `RunRepository.markAttendance` | `runParticipations/{runId_uid}`, `runs/{runId}.checkedInCount` | Host-only attendance toggle. |
| `selfCheckInAttendance` | Callable | `RunRepository.selfCheckInAttendance` | `runParticipations/{runId_uid}`, `runs/{runId}.checkedInCount` | Participant self-check only; verifies sign-up, time window, and location where available. |
| `onSwipeCreated` | Firestore trigger on `swipes/{uid}/outgoing/{targetId}` create | Backend | `matches/{matchId}` | Deterministic match ID; creates a match only for reciprocal likes. Writes `runIds` so a match can track every shared run over time. |
| `onMatchCreated` | Firestore trigger on `matches/{matchId}` create | Backend | `notifications/{uid}/items/{notificationId}`, FCM | Writes deterministic match activity notifications for both participants and sends push notifications when tokens exist. |
| `onMessageCreated` | Firestore trigger on `matches/{matchId}/messages/{messageId}` create | Backend | `matches/{matchId}`, `functionEventReceipts/{receiptId}`, `notifications/{uid}/items/{notificationId}`, FCM | Idempotency receipt prevents duplicate metadata writes; writes unread as a 0/1 conversation flag for the recipient and clears the sender's unread flag. Deterministic notification ID prevents duplicate activity rows. |
| `moderateChatMessage` | Firestore trigger on match-scoped message create | Backend | `matches/{matchId}/messages/{messageId}`, `moderationFlags/{id}` | Deterministic moderation flag for blocked/flagged text. |
| `moderatePhotoOnUpload` | Storage trigger | Backend | `moderationFlags/{id}`, `users/{uid}.profilePhotos`, legacy photo arrays, Storage delete | Deletes unsafe uploaded profile photos and removes the matching grouped photo plus compatibility array entries from the private profile. |
| `createRunReview` | Callable | `ReviewsRepository.addReview` | `reviews/{runId~uid}` | Attended-run review create. Server verifies the `runParticipations/{runId_uid}` edge, derives public reviewer name with the shared profile projection helper, and writes the deterministic review doc. |
| `updateRunReview` | Callable | `ReviewsRepository.updateReview` | `reviews/{reviewId}.rating/comment/updatedAt` | Author-only review edit. |
| `deleteRunReview` | Callable | `ReviewsRepository.deleteReview` | `reviews/{reviewId}` delete | Author-only review delete. `syncRunClubReviewStats` recomputes aggregate rating/count after deletion. |
| `syncRunClubReviewStats` | Firestore trigger on `reviews/{reviewId}` write | Backend | `runClubs/{clubId}.rating`, `reviewCount` | Recomputes aggregate state, so duplicate trigger delivery is safe. |
| `blockUser` | Callable | `SafetyRepository.blockUser` | `blocks/{blocker}__{target}`, `matches/{matchId}` status | Rate-limited before writes; backend-owned safety edge and match closure. |
| `unblockUser` | Callable | `SafetyRepository.unblockUser` | `blocks/{blocker}__{target}` delete | Rate-limited before delete; removes directed block edge. |
| `onBlockCreated` | Firestore trigger on `blocks/{blockId}` create | Backend | `matches/{matchId}` status | Secondary safety guard to close matches after block edge writes. |
| `reportUser` | Callable | `SafetyRepository.reportUser` | `reports/{autoId}` | Bounded report payload. |
| `requestAccountDeletion` | Callable | `SafetyRepository.requestAccountDeletion` | `deletedUsers/{uid}`, `users/{uid}`, `publicProfiles/{uid}`, Storage deletes, Auth delete, relationship cleanup across memberships, participations, saved runs, swipes, matches, reviews, payments, notifications, blocks, and reports | Rate-limited before destructive work; backend-only account deletion/anonymization. Deletes original profile photos plus thumbnail URLs and uses relationship-doc queries instead of scanning parent arrays. |
| `joinWaitlist` | HTTP function | Marketing site/waitlist form | `launchWaitlist/{emailHash}` | Public endpoint with CORS and IP rate limiting. |

## Direct Client Firestore Writes

| Dart initiator | Collection/path | Operation | Rule owner | Keep direct? |
|---|---|---|---|---|
| `UserProfileRepository.setUserProfile` | `users/{uid}` | Initial profile create after onboarding identity step. | Owner create plus full shape validation. | Yes. This is initial owner-owned profile creation. |
| `SavedRunRepository.watchSavedRun` / `saveRun` / `unsaveRun` | `savedRuns/{uid_runId}` | Render, save, or unsave one run for the current user. | Owner direct edge read/create/delete with deterministic ids. | Yes. No user-profile projection is maintained. |
| `FcmService._saveToken` | `users/{uid}.fcmToken` | Store current push token. | Owner direct update of only `fcmToken`. | Yes. Runtime token update. |
| `OnboardingDraftRepository.saveDraft/deleteDraft` | `onboarding_drafts/{uid}` | Private draft set/delete. | Owner-only, intentionally extensible. | Yes. Private volatile draft state. |
| `SwipeRepository.recordSwipe` | `swipes/{uid}/outgoing/{targetId}` | Create own outgoing swipe. | Path/data identity, attended-run, block, and payload rules. | Yes. Match creation remains trigger-owned. |
| `ChatRepository.sendMessage` | `matches/{matchId}/messages/{id}` | Create text message. | Match participant create only. | Yes. Match preview/unread/moderation are trigger-owned. |
| `ChatController.sendImage` / `ChatRepository.sendImageMessage` | Storage `matches/{matchId}/images/*`, then `matches/{matchId}/messages/{id}` | Shared `ImageUploadRepository` picks/compresses/uploads the chat image; repository writes the image message. | Storage rules prove match participation from `user1Id`/`user2Id` with legacy `participantIds` fallback; message create rules prove active match participation before Firestore write. | Yes. Media picking/compression is centralized with profile/onboarding/run-club image upload policy. |
| `MatchRepository.resetUnread` | `matches/{matchId}.unreadCounts.{uid}` | Reset own unread count to zero. | Participant narrow update. | Yes. |

## Backend-Owned Collections And Fields

| Path/field | Owner | Client rule |
|---|---|---|
| `publicProfiles/{uid}` | `syncPublicProfile` trigger | Read-only to clients. |
| `runClubMemberships/{clubId_uid}` | Run-club membership callables | Direct client writes denied. |
| `runClubHostClaims/{uid}` | `createRunClub` callable | Server-only host lock; direct client reads/writes denied. |
| `runClubs/{clubId}` writes | Run-club create/update/archive/delete callables plus review-stat trigger | Direct client writes denied. |
| `users/{uid}.deleted`, `deletedAt` | Account deletion callable | Direct client writes denied. |
| `runClubs/{clubId}.memberCount` | Run-club membership callables plus `syncRunClubMemberStats` repair trigger | Direct client writes denied. |
| `runClubs/{clubId}.rating`, `reviewCount` | `syncRunClubReviewStats` trigger | Direct client writes denied. |
| `runClubs/{clubId}.nextRunAt`, `nextRunLabel` | Run callables plus `syncRunClubNextRun` projection trigger | Direct client writes denied. |
| `runClubs/{clubId}.status`, `archived`, `archivedAt`, `archiveReason` | `archiveRunClub` callable | Direct client writes denied. |
| `runs/{runId}.bookedCount`, `waitlistedCount`, `checkedInCount`, `genderCounts` | Booking, waitlist, attendance, payment callables | Direct client writes denied. |
| `runs/{runId}.status`, `cancelledAt`, `cancellationReason` | `createRun` / `cancelRun` / `deleteRun` callables | Direct client writes denied. |
| `runParticipations/{runId_uid}` | Booking, waitlist, attendance, cancellation, account deletion callables. Run detail reads current-viewer CTA/review state from this edge; shared signed-up/attended run streams query it by user/status; host attendance management, swipe candidate generation, and run recap derive roster/check-in state from run participation statuses. | Direct client writes denied. |
| `payments/{paymentId}` | Payment verification/cancel callables | Direct client writes denied. |
| `reviews/{reviewId}` writes | Review mutation callables plus review-stat trigger | Direct client writes denied. |
| `matches/{matchId}` create/status/preview/unread flags | Matching/message/block triggers | Direct client creation denied; only participant unread reset allowed. Match documents use `runIds` as the shared-run history; Dart reads legacy `runId` while older seeded/live data is being cleaned up. |

## User Identity Projection Inventory

| Projection | Source | Sync owner | Repair / validation |
|---|---|---|---|
| `publicProfiles/{uid}.name`, `profilePhotos`, legacy photo arrays, and public profile fields | `users/{uid}` | `syncPublicProfile` | Firestore trigger plus `tool/validate_firestore_data.mjs` profile checks and `tool/recompute_public_profiles.mjs` repair. |
| `runClubs/{clubId}.hostName`, `hostAvatarUrl` | Host `users/{hostUserId}` | `createRunClub` on create, then `syncPublicProfile` on profile writes | `tool/recompute_run_club_host_profiles.mjs`; validator emits `run-club-host-name-drift` / `run-club-host-avatar-drift`. |
| `reviews/{reviewId}.reviewerName` | Reviewer `users/{reviewerUserId}` | `createRunReview` on create, then `syncPublicProfile` on profile writes | `tool/recompute_review_author_profiles.mjs`; validator emits `reviewer-name-drift`. |
| `notifications/{uid}/items/{id}.actorName`, notification `title`/`body` with names | Event-time public profile at notification creation | Notification trigger/callable that created the event | Historical notification copy. Do not back-update unless product decides notifications should become live profile cards. |
| `matches/{matchId}.lastMessagePreview` | Latest message content | `onMessageCreated` | Message-content preview snapshot, not a user profile projection. |
| `runParticipations/{runId_uid}.genderAtSignup`, `runs/{runId}.genderCounts` | User profile at booking/attendance time | Booking/attendance callables and aggregate repair tools | Signup-time constraint snapshot; do not rewrite after profile edits. `tool/repair_future_run_attendance.mjs` downgrades stale future-run `attended` edges to `signedUp`, fixes affected aggregates, and deletes invalid swipe artifacts. |
| `notifications/{uid}/items/{notificationId}` | Match/message triggers, create-run fan-out, host run update/cancellation, and booking/cancellation callables now; remaining run producers should use the same backend-owned helper. | Owner can read own items and update only `readAt`; client create/delete/content edits are denied. |
| `blocks/{blockId}` | Safety callables | Direct client writes denied. |
| `reports/{reportId}` | Safety callable | Direct client writes denied. |
| `moderationFlags/{id}` | Moderation triggers | Direct client writes denied. |
| `deletedUsers/{uid}` | Account deletion callable | Direct client writes denied. |
| `rateLimits/{key}` | Rate-limit helper | Direct client writes denied. |
| `functionEventReceipts/{id}` | Idempotent triggers | Direct client writes denied. |

## Notification Timeline

Durable in-app activity lives under
`notifications/{uid}/items/{notificationId}`. Notification content and routing
metadata are backend-owned; clients can read their own timeline and mark items
read by updating only `readAt`.

| Moment | Current owner | Durable item | Push | Status |
|---|---|---|---|---|
| New match | `onMatchCreated` | Yes, deterministic `match_${matchId}` item for each participant. | Yes when `prefsNewCatches != false` and token exists. | Implemented. |
| New chat message | `onMessageCreated` | Yes, deterministic `message_${matchId}_${messageId}` item for the recipient. | Yes when `prefsMessages != false` and token exists. | Implemented. |
| Upcoming run reminder | `sendRunReminders` scheduled Function every 15 minutes. | Yes, deterministic `runReminder_${runId}` item for signed-up participants in the reminder window. | Yes when `prefsRunReminders != false` and token exists. | Implemented. |
| Run signup | `signUpUserForRun` via `signUpForFreeRun` and `verifyRazorpayPayment` | Yes, deterministic `runSignup_${runId}` item for the booked user. | No; this is normally caused by the user's active booking action. | Implemented. |
| Waitlist promotion | `signUpUserForRun` when a waitlisted user books, and `cancelRunSignUp` when a cancellation promotes the first eligible waitlisted user. | Yes, deterministic `waitlistPromotion_${runId}` item for the promoted user. | Yes when promotion happens from another user's cancellation, `prefsRunStatusUpdates != false`, and token exists. | Implemented. |
| Run schedule/location change | `updateRun` callable best-effort fan-out after the run update commits. | Yes, deterministic `runUpdated_${runId}` item for signed-up and waitlisted participants. | Yes when `prefsRunStatusUpdates != false` and token exists. | Implemented. |
| Run cancellation | `cancelRun` callable best-effort fan-out after the run status update commits. | Yes, deterministic `runCancelled_${runId}` item for signed-up and waitlisted participants. | Yes when `prefsRunStatusUpdates != false` and token exists. | Backend implemented; host UI/policy queued. |
| New run posted by followed club | `createRun` callable best-effort fan-out after the run commits | Yes, deterministic `clubUpdate_${runId}` item for active club members, excluding the host. | Two-tier: activity for active members; push only when membership `pushNotificationsEnabled == true`, `prefsClubUpdates != false`, and token exists. | Implemented. |

When adding a new producer, write the timeline item through
`functions/src/shared/notifications.ts`, keep IDs deterministic where the
source event has a stable ID, add Functions tests for duplicate delivery, add a
rules test if the client read/update contract changes, and extend
`tool/firestore_contract.json`.

Internal demo tooling marks source documents with `demoOps`, `demoOpsId`,
`demoOpsCommand`, `seedPrefix`, and `synthetic`. Trigger-owned notification
projections should copy those fields through
`functions/src/shared/demoMetadata.ts` so cleanup and single-user reset commands
can remove derived demo activity precisely.
