---
doc_id: backend_operation_catalog
version: 1.1.7
updated: 2026-05-06
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
| P2 | Notifications are currently only sent for chat messages. Future notification work should start from this catalog so fan-out writes and push side effects remain backend-owned. | Add `NOTIFICATIONS-QUEUE`. |

## Cloud Functions Inventory

| Function | Type | Initiator | Writes | Notes |
|---|---|---|---|---|
| `updateUserProfile` | Callable | `UserProfileRepository.updateUserProfile` | `users/{uid}` | Validates profile patches with Zod; owns complex profile edits after initial create; rate-limited at 60/minute. |
| `syncPublicProfile` | Firestore trigger on `users/{uid}` writes | Backend | `publicProfiles/{uid}` set/delete | Sole owner of public profile projection. Uses `displayName`, then first name, then legacy fallback. |
| `createRunClub` | Callable | `RunClubsRepository.createRunClub` | `runClubs/{clubId}`, `runClubMemberships/{clubId_uid}`, compatibility `users/{uid}.joinedRunClubIds` | Server derives host identity from authenticated user. |
| `joinRunClub` | Callable | `RunClubsRepository.joinClub` | `runClubMemberships/{clubId_uid}`, `runClubs/{clubId}.member*`, compatibility `users/{uid}.joinedRunClubIds` | Multi-doc membership mutation; edge document is the target source of truth. |
| `leaveRunClub` | Callable | `RunClubsRepository.leaveClub` | `runClubMemberships/{clubId_uid}`, `runClubs/{clubId}.member*`, compatibility `users/{uid}.joinedRunClubIds` | Rejects host leaving their own club. |
| `createRun` | Callable | `RunRepository.createRun` | `runs/{runId}` | Host authority is verified server-side from the run club; initializes run participation count projections to zero. |
| `updateRun` | Callable | `RunRepository.updateRunDetails` | `runs/{runId}` | Host-editable schedule/descriptive fields only. |
| `signUpForFreeRun` | Callable | `PaymentRepository.bookFreeRun` | `runParticipations/{runId_uid}`, `runs/{runId}.bookedCount`, compatibility `runs/{runId}.signedUpUserIds`, `genderCounts`, `waitlistUserIds` | Delegates core booking to `signUpUserForRun`; decrements `waitlistedCount` when promoting from waitlist. |
| `createRazorpayOrder` | Callable | `PaymentRepository.processPayment` | Razorpay order only | Uses trusted run price and server-side secrets. |
| `verifyRazorpayPayment` | Callable | Razorpay success callback in `PaymentRepository` | `payments/{paymentId}`, `runParticipations/{runId_uid}`, compatibility `runs/{runId}` booking fields, run count projections | Rate-limited before signature validation or Razorpay fetch; verifies signature and books paid run. |
| `cancelRunSignUp` | Callable | `RunRepository.cancelSignUpViaFunction` | `runParticipations/{runId_uid}`, `runs/{runId}.bookedCount`, `runs/{runId}.waitlistedCount`, compatibility arrays, `payments/{paymentId}` refund status | Rate-limited before payment lookup; may promote a waitlisted runner and refund paid bookings; writes exact count projections after promotion math. |
| `joinRunWaitlist` | Callable | `RunRepository.joinWaitlistViaFunction` | `runParticipations/{runId_uid}`, `runs/{runId}.waitlistedCount`, compatibility `runs/{runId}.waitlistUserIds` | Rate-limited before transaction work; server checks block boundary without exposing block state in rules. |
| `markRunAttendance` | Callable | `RunRepository.markAttendance` | `runParticipations/{runId_uid}`, `runs/{runId}.checkedInCount`, compatibility `runs/{runId}.attendedUserIds` | Host-only attendance toggle. |
| `selfCheckInAttendance` | Callable | `RunRepository.selfCheckInAttendance` | `runParticipations/{runId_uid}`, `runs/{runId}.checkedInCount`, compatibility `runs/{runId}.attendedUserIds` | Participant self-check only; verifies sign-up, time window, and location where available. |
| `onSwipeCreated` | Firestore trigger on `swipes/{uid}/outgoing/{targetId}` create | Backend | `matches/{matchId}` | Deterministic match ID; creates a match only for reciprocal likes. |
| `onMatchCreated` | Firestore trigger on `matches/{matchId}` create | Backend | Notifications via FCM | Sends match notification. |
| `onMessageCreated` | Firestore trigger on `matches/{matchId}/messages/{messageId}` create | Backend | `matches/{matchId}`, `functionEventReceipts/{receiptId}`, notifications | Idempotency receipt prevents duplicate unread increments. |
| `moderateChatMessage` | Firestore trigger on match-scoped message create | Backend | `matches/{matchId}/messages/{messageId}`, `moderationFlags/{id}` | Deterministic moderation flag for blocked/flagged text. |
| `moderatePhotoOnUpload` | Storage trigger | Backend | `moderationFlags/{id}`, `users/{uid}.photoUrls`, Storage delete | Deletes unsafe uploaded profile photos and removes URL from private profile. |
| `syncRunClubReviewStats` | Firestore trigger on `reviews/{reviewId}` write | Backend | `runClubs/{clubId}.rating`, `reviewCount` | Recomputes aggregate state, so duplicate trigger delivery is safe. |
| `blockUser` | Callable | `SafetyRepository.blockUser` | `blocks/{blocker}__{target}`, `matches/{matchId}` status | Rate-limited before writes; backend-owned safety edge and match closure. |
| `unblockUser` | Callable | `SafetyRepository.unblockUser` | `blocks/{blocker}__{target}` delete | Rate-limited before delete; removes directed block edge. |
| `onBlockCreated` | Firestore trigger on `blocks/{blockId}` create | Backend | `matches/{matchId}` status | Secondary safety guard to close matches after block edge writes. |
| `reportUser` | Callable | `SafetyRepository.reportUser` | `reports/{autoId}` | Bounded report payload. |
| `requestAccountDeletion` | Callable | `SafetyRepository.requestAccountDeletion` | `deletedUsers/{uid}`, `users/{uid}`, `publicProfiles/{uid}`, Storage deletes, Auth delete | Rate-limited before destructive work; backend-only account deletion/anonymization. |
| `joinWaitlist` | HTTP function | Marketing site/waitlist form | `launchWaitlist/{emailHash}` | Public endpoint with CORS and IP rate limiting. |

## Direct Client Firestore Writes

| Dart initiator | Collection/path | Operation | Rule owner | Keep direct? |
|---|---|---|---|---|
| `UserProfileRepository.setUserProfile` | `users/{uid}` | Initial profile create after onboarding identity step. | Owner create plus full shape validation. | Yes. This is initial owner-owned profile creation. |
| `SavedRunRepository.watchSavedRun` / `saveRun` / `unsaveRun` | `savedRuns/{uid_runId}` plus compatibility `users/{uid}.savedRunIds` writes | Render, save, or unsave one run for the current user. | Owner direct edge read/create/delete plus temporary projection update. | Yes during migration. Run detail already reads from `savedRuns`; retire the profile array writes after migration/reset policy is finalized. |
| `FcmService._saveToken` | `users/{uid}.fcmToken` | Store current push token. | Owner direct update of only `fcmToken`. | Yes. Runtime token update. |
| `OnboardingDraftRepository.saveDraft/deleteDraft` | `onboarding_drafts/{uid}` | Private draft set/delete. | Owner-only, intentionally extensible. | Yes. Private volatile draft state. |
| `RunClubsRepository.updateRunClub` | `runClubs/{clubId}` | Host edits descriptive club fields. | Host update allowlist freezes membership/rating fields. | Yes for now. Move to callable only if host edits become multi-doc or side-effectful. |
| `RunRepository.leaveWaitlist` | `runs/{runId}.waitlistUserIds` | Remove current user from waitlist. | Waitlisted user can remove self only. | Yes for now. Still watch because waitlist join is callable-owned. |
| `ReviewsRepository.add/update/deleteReview` | `reviews/{runId~uid}` | Run attendee creates/edits/deletes own review. | Deterministic ID, attended-run check, author ownership. | Yes. Aggregate stats are trigger-owned. |
| `SwipeRepository.recordSwipe` | `swipes/{uid}/outgoing/{targetId}` | Create own outgoing swipe. | Path/data identity, attended-run, block, and payload rules. | Yes. Match creation remains trigger-owned. |
| `ChatRepository.sendMessage` | `matches/{matchId}/messages/{id}` | Create text message. | Match participant create only. | Yes. Match preview/unread/moderation are trigger-owned. |
| `ChatRepository.sendImageMessage` | Storage `matches/{matchId}/images/*`, then `matches/{matchId}/messages/{id}` | Upload chat image and create image message. | Storage rules plus message create rules. | Yes, but future media moderation should be audited separately. |
| `MatchRepository.resetUnread` | `matches/{matchId}.unreadCounts.{uid}` | Reset own unread count to zero. | Participant narrow update. | Yes. |

## Backend-Owned Collections And Fields

| Path/field | Owner | Client rule |
|---|---|---|
| `publicProfiles/{uid}` | `syncPublicProfile` trigger | Read-only to clients. |
| `users/{uid}.joinedRunClubIds` | Run-club membership callables | Direct client writes denied. |
| `runClubMemberships/{clubId_uid}` | Run-club membership callables | Direct client writes denied. |
| `users/{uid}.deleted`, `deletedAt` | Account deletion callable | Direct client writes denied. |
| `runClubs/{clubId}.memberUserIds`, `memberCount` | Run-club membership callables | Direct client writes denied. |
| `runClubs/{clubId}.rating`, `reviewCount` | `syncRunClubReviewStats` trigger | Direct client writes denied. |
| `runs/{runId}.signedUpUserIds`, `attendedUserIds`, `genderCounts` | Booking, attendance, payment callables | Direct client writes denied. |
| `runParticipations/{runId_uid}` | Booking, waitlist, attendance, cancellation, account deletion callables. Run detail reads current-viewer CTA/review state from this edge; shared signed-up/attended run streams query it by user/status; host attendance management, swipe candidate generation, and run recap derive roster/check-in state from run participation statuses. | Direct client writes denied. |
| `payments/{paymentId}` | Payment verification/cancel callables | Direct client writes denied. |
| `matches/{matchId}` create/status/preview/unread increments | Matching/message/block triggers | Direct client creation denied; only participant unread reset allowed. |
| `blocks/{blockId}` | Safety callables | Direct client writes denied. |
| `reports/{reportId}` | Safety callable | Direct client writes denied. |
| `moderationFlags/{id}` | Moderation triggers | Direct client writes denied. |
| `deletedUsers/{uid}` | Account deletion callable | Direct client writes denied. |
| `rateLimits/{key}` | Rate-limit helper | Direct client writes denied. |
| `functionEventReceipts/{id}` | Idempotent triggers | Direct client writes denied. |

## Notification Starting Point

Current notification fan-out exists for chat-message and match events through
Functions. The next notification pass should keep notification creation
backend-owned and add a small notification operation table here before
implementation. Candidate moments:

- New chat message.
- New match.
- Upcoming run reminder.
- Run signup / waitlist promotion.
- Run cancellation or schedule change.
- Club membership or hosted-run updates.

Before adding notifications, decide whether the durable in-app timeline lives
in a Firestore collection such as `notifications/{uid}/items/{id}` or whether
some events remain push-only. If a timeline collection is added, client writes
should be denied and all fan-out should happen through Functions.
