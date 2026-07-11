---
doc_id: backend_operation_catalog
version: 1.2.7
updated: 2026-07-10
owner: recursive_audit_loop
status: active
---

# Backend Operation Catalog

## Read Policy

Read this before changing Cloud Functions, Firestore rules, repository writes,
callable interfaces, trigger-owned projections, payments, safety workflows, or
notification fan-out. Treat `tool/contracts/firestore_contract.json` as the
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
Good examples are saved events, outgoing profile decisions, and match-scoped chat messages.

Keep callables when the server must decide whether the mutation is valid across
multiple documents, hidden safety state, capacity, schedule conflicts, payment
state, role/host authority, rate limits, or account lifecycle. Good examples
are event-club membership, event creation, booking, waitlist, attendance, reviews,
payments, safety actions, and account deletion.

Use Firestore triggers for projections and side effects after a canonical edge
or entity write exists. Triggers must either recompute from source documents or
use an idempotency receipt when retrying an increment-like update could double
count. Parent relationship projections such as `memberCount` and `nextEventAt`
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
| P0 | `tool/contracts/firestore_contract.json` was stale for `users/{uid}.firstName`, `lastName`, and `displayName`; the generated Functions type and Firestore rules already had the fields. | Fixed in this pass. |
| P0 | Account deletion anonymized `name` but did not clear retained `firstName`, `lastName`, or `displayName` on `users/{uid}`. | Fixed in this pass. |
| P1 | `RATE_LIMITS` declared several callable limits that were not applied at the handlers: `verifyRazorpayPayment`, `cancelEventSignUp`, `joinEventWaitlist`, `blockUser`, `unblockUser`, and `requestAccountDeletion`. `updateUserProfile` also had no configured limit. | Fixed. All listed handlers now call `checkRateLimit`; `updateUserProfile` is 60/minute to allow brisk field-by-field editing without leaving profile writes unbounded. |
| P2 | The machine-readable contract records operations by collection, but not the Dart initiator method for every operation. | This doc fills the human map; a later tooling pass can validate Dart initiators automatically. |
| P2 | Notification fan-out now has a durable backend-owned in-app timeline for match, message, new club event, event signup, waitlist-promotion, upcoming event reminder, event schedule/location updates, and event cancellation events. | Implemented; keep adding new categories through the same Functions-owned interface. |
| P1 | Edge documents were the source of truth, but event-club parent projections relied only on callable updates or batch repair tools. | Fixed. `syncClubMemberStats` recomputes `memberCount` from active membership edges, and `syncClubNextEvent` recomputes `nextEventAt` / `nextEventLabel` from active future event documents. Event callables also refresh the next-event projection before returning. |

## Cloud Functions Inventory

| Function | Type | Initiator | Writes | Notes |
|---|---|---|---|---|
| `updateUserProfile` | Callable | `UserProfileRepository.updateUserProfile` | `users/{uid}` | Validates profile patches with generated Ajv contract validators; owns complex profile edits after initial create; rate-limited at 60/minute. |
| `syncPublicProfile` | Firestore trigger on `users/{uid}` writes | Backend | `publicProfiles/{uid}` set/delete, authored `reviews/{reviewId}.reviewerName` updates | Sole owner of dating/user-identity projections. Uses `displayName`, then first name, then legacy fallback; projects grouped `profilePhotos` and nested `activityPreferences.running`. It must not update club host identity. Existing stale public profiles can be repaired with `node tool/data/recompute_public_profiles.mjs --env dev --apply`; existing stale review author names can be repaired with `node tool/data/recompute_review_author_profiles.mjs --env dev --apply` after `npm --prefix functions run build`. |
| `syncHostProfile` | Firestore trigger on `hostProfiles/{uid}` writes | Backend | hosted `clubs/{clubId}.hostName`, `hostAvatarUrl`, `hostProfiles[]` | Sole owner of professional host display projections. Uses `hostProfiles/{uid}` only, never the dating public/private profile. Existing stale club host projections can be repaired with `node tool/data/recompute_club_host_profiles.mjs --env dev --apply`; legacy clubs without host profile docs preserve their existing club host snapshot fallback. |
| `generateProfilePhotoThumbnail` | Storage trigger on `users/{uid}/photos/{fileName}` finalize | Backend | Storage `users/{uid}/photoThumbnails/{fileName}`, `users/{uid}.profilePhotos` | Generates 160px JPEG thumbnails for avatar-scale surfaces. Dashboard/event-detail hype avatars must use thumbnail URLs, not full profile photos. Existing beta data can be backfilled with `npm --prefix functions run backfill:profile-thumbnails -- --apply` after setting `FIREBASE_STORAGE_BUCKET`; the script updates grouped `profilePhotos`. |
| `createClub` | Callable | `ClubsRepository.createClub` | `clubs/{clubId}`, `clubMemberships/{clubId_uid}`, `clubHostClaims/{uid}`, optional `hostProfiles/{uid}` seed | Server derives host identity from `hostProfiles/{uid}` with migration fallback only when seeding a missing professional host profile; a complete dating profile is not required. Initializes lifecycle fields as active/unarchived; the membership edge is the source of truth and `memberCount` is the parent aggregate. `clubHostClaims/{uid}` enforces the current product rule that a user can host at most one club. |
| `updateClub` | Callable | `ClubsRepository.updateClub` | `clubs/{clubId}` descriptive fields | Host-only profile edit seam. Direct client updates to `clubs/{clubId}` are denied so Zod owns field validation and aggregate/projection fields stay backend-owned. |
| `requestClubClaim` | Callable | Public organizer claim form | `clubClaimRequests/{requestId}`, `clubs/{clubId}.claim` | Auth-backed public claim request. Does not grant ownership; records requester identity/proof fields and moves the club claim state to pending while programmatic ownership and hidden app visibility remain in place. |
| `adminDecideClubClaim` | Callable | Admin organizer claim queue | `clubClaimRequests/{requestId}`, `clubs/{clubId}.ownerUserId/hostUserId/hostUserIds/hostProfiles/ownership/claim`, `notifications/{uid}/items/{notificationId}` | Admin-only approval/rejection seam. Approval makes the requester the canonical owner/host for the existing club document and writes deterministic owner-facing activity. |
| `adminSetClubIndexStatus` | Callable | Admin organizer index-review queue | `clubs/{clubId}.publicPage`, `clubs/{clubId}.publicPage.indexReview` | Admin-only promotion/hold seam for programmatic organizer pages. Records source-evidence, media-rights, cadence, and owner/contact review before a generated page becomes indexable. |
| `setReviewResponse` | Callable | Claimed organizer review UI | `reviews/{reviewId}.ownerResponse` | Server-owned owner response on public review documents. Only claimed hosts for the owning club can write responses; app and website render the canonical review snapshot. |
| `joinClub` | Callable | `ClubsRepository.joinClub` | `clubMemberships/{clubId_uid}`, `clubs/{clubId}.memberCount` | Multi-doc membership mutation; does not mirror membership into user or club arrays. `syncClubMemberStats` repairs the parent count from active membership edges after any membership write. |
| `leaveClub` | Callable | `ClubsRepository.leaveClub` | `clubMemberships/{clubId_uid}`, `clubs/{clubId}.memberCount` | Rejects host leaving their own club; does not mirror membership into user or club arrays. `syncClubMemberStats` repairs the parent count from active membership edges after any membership write. |
| `createClubPost` | Callable | `ClubPostsRepository.createPost` | `clubs/{clubId}/posts/{postId}`, `notifications/{uid}/items/{notificationId}`, FCM to active club members with club-update pushes enabled | Host-only follower update seam. Validates generated payload schema, verifies host authority, checks optional linked event belongs to the same club, enforces three active posts per rolling seven days, writes the canonical server-owned post, and fans out deterministic `clubUpdate_${postId}` activity. |
| `startClubHostConversation` | Callable | `ClubHostContactController.startConversation` from club or event detail | `matches/{opaqueScopedId}` | Validates the generated optional `eventId`, verifies the target is a current club host, checks the block/deleted-user boundary, and—when event-scoped—verifies the event belongs to the club. New ids are deterministic over club, optional event, and participant pair; event inquiries never reuse dating matches or general inquiries. New documents keep `lastMessagePreview` null until an actual message, and the action has an explicit five-per-minute limit. Legacy pair-id general `clubHostInquiry` threads are reused for continuity. The client retries without `eventId` only when the older callable returns the exact additional-property schema diagnostic, allowing a backend-first two-phase rollout without masking new authorization errors. |
| `syncClubMemberStats` | Firestore trigger on `clubMemberships/{membershipId}` write | Backend | `clubs/{clubId}.memberCount` | Recomputes active membership count from edge documents. This makes duplicate trigger delivery safe and repairs stale callable-era or manually drifted parent projections. |
| `archiveClub` | Callable | Backend-ready; host UI queued | `clubs/{clubId}.status/archived/archivedAt/archiveReason` | Host-only archive seam for clubs with history. Prevent browse/search usage once client filters are added; hard delete is reserved for unused clubs. |
| `deleteClub` | Callable | Backend-ready; host/admin UI queued | `clubs/{clubId}` delete, host `clubMemberships/{clubId_uid}` delete, `clubHostClaims/{uid}` delete | Host-only hard delete for never-used clubs. Rejects clubs with events, payments, reviews, or non-host members; releases the one-club host claim only after the hard delete is allowed. |
| `createEvent` | Callable | `EventRepository.createEvent` | `events/{eventId}`, optional `events/{eventId}.photoUrl`, `clubs/{clubId}.nextEventAt/nextEventLabel`, `notifications/{uid}/items/{notificationId}`, FCM to active club members with event-reminder pushes enabled | Host authority is verified server-side from the club; initializes event lifecycle as `active` plus participation count projections to zero; refreshes the club next-event projection before returning; new-event notification fan-out is best-effort after the event document commits. |
| `updateEvent` | Callable | `EventRepository.updateEventDetails` | `events/{eventId}`, optional `events/{eventId}.photoUrl`, `clubs/{clubId}.nextEventAt/nextEventLabel`, `notifications/{uid}/items/{notificationId}`, FCM to signed-up/waitlisted participants for schedule/location changes | Host-editable schedule/descriptive fields and photo URL only. Descriptive/photo-only edits do not notify participants; schedule/location changes produce deterministic `eventUpdated_${eventId}` items. Cancelled events cannot be edited. |
| `sendEventBroadcast` | Callable | Host Inbox broadcast composer through `EventRepository.sendEventBroadcast` | `eventBroadcasts/{broadcastId}`, `notifications/{uid}/items/{notificationId}`, preference-gated Consumer FCM | Current event hosts can send bounded, moderated event updates to a server-resolved Booked (`signedUp` plus `attended`) or Prospective (`waitlisted`) roster. Inquiry/chat membership never determines recipients. A deterministic Activity item is the durable retry boundary; per-recipient receipt evidence prevents duplicate push attempts and is retained for 90 days through Firestore TTL. The callable is rate-limited to three logical requests per host per hour. |
| `cancelEvent` | Callable | `HostEventManageScreen` | `events/{eventId}.status/cancelledAt/cancellationReason`, `clubs/{clubId}.nextEventAt/nextEventLabel`, schedule-lock release, attendee payment refund attempts, `notifications/{uid}/items/{notificationId}`, FCM to signed-up/waitlisted participants | Host-only cancellation seam. Marks the canonical event as cancelled, refreshes the club next-event projection, releases schedule locks, attempts completed attendee refunds, and fans out deterministic `eventCancelled_${eventId}` activity. The host UI is exposed from Manage event with destructive confirmation and history-retention copy. |
| `deleteEvent` | Callable | `HostEventManageScreen` | `events/{eventId}` delete, `clubs/{clubId}.nextEventAt/nextEventLabel` refresh | Host-only hard delete for unused events. The host UI exposes Delete only when visible aggregate/edge activity is absent; the callable still rejects events with participations, payments, or reviews. Use `cancelEvent` for events with history. |
| `syncClubNextEvent` | Firestore trigger on `events/{eventId}` write | Backend | `clubs/{clubId}.nextEventAt`, `nextEventLabel` | Recomputes the earliest future active event for affected clubs from `events`. This keeps club list/detail projections in sync after create, update, cancellation, deletion, retries, or repair tooling. |
| `signUpForFreeEvent` | Callable | `PaymentRepository.bookFreeEvent` | `eventParticipations/{eventId_uid}`, `events/{eventId}.bookedCount`, `events/{eventId}.waitlistedCount`, `events/{eventId}.genderCounts`, `notifications/{uid}/items/{notificationId}` | Delegates core booking to `signUpUserForEvent`; writes an in-app booking confirmation or waitlist-promotion activity item. |
| `createRazorpayOrder` | Callable | `PaymentRepository.processPayment` | Razorpay order only | Uses trusted event price and server-side secrets; rejects cancelled events before creating an order. |
| `verifyRazorpayPayment` | Callable | Razorpay success callback in `PaymentRepository` | `payments/{paymentId}`, `eventParticipations/{eventId_uid}`, event count/gender projections, `notifications/{uid}/items/{notificationId}` | Rate-limited before signature validation or Razorpay fetch; verifies signature, books paid event, and writes an in-app booking confirmation. |
| `cancelEventSignUp` | Callable | `EventRepository.cancelSignUpViaFunction` | `eventParticipations/{eventId_uid}`, `events/{eventId}.bookedCount`, `events/{eventId}.waitlistedCount`, `events/{eventId}.genderCounts`, `payments/{paymentId}` refund status, `notifications/{uid}/items/{notificationId}`, FCM to promoted waitlisted user | Rate-limited before payment lookup; may promote a waitlisted runner and refund paid bookings; writes exact count projections after promotion math. |
| `joinEventWaitlist` | Callable | `EventRepository.joinWaitlistViaFunction` | `eventParticipations/{eventId_uid}`, `events/{eventId}.waitlistedCount` | Rate-limited before transaction work; server checks block boundary without exposing block state in rules. |
| `leaveEventWaitlist` | Callable | `EventRepository.leaveWaitlist` | `eventParticipations/{eventId_uid}`, `events/{eventId}.waitlistedCount` | Rate-limited before transaction work; marks the caller's waitlist edge cancelled. |
| `markEventAttendance` | Callable | `EventRepository.markAttendance` | `eventParticipations/{eventId_uid}`, `events/{eventId}.checkedInCount` | Host-only attendance toggle. |
| `selfCheckInAttendance` | Callable | `EventRepository.selfCheckInAttendance` | `eventParticipations/{eventId_uid}`, `events/{eventId}.checkedInCount` | Participant self-check only; verifies sign-up, time window, and location where available. |
| `onSwipeCreated` | Firestore trigger on `profileDecisions/{uid}/outgoing/{targetId}` create | Backend | `matches/{matchId}` | Deterministic match ID; creates a match only for reciprocal likes. Writes `eventIds` so a match can track every shared event over time. If a legacy pair-only id is occupied by a `clubHostInquiry`, the dating match uses a separate deterministic opaque id so organizer-support messages can never be converted into dating chat history. |
| `onMatchCreated` | Firestore trigger on `matches/{matchId}` create | Backend | `notifications/{uid}/items/{notificationId}`, FCM | Writes deterministic match activity notifications for both participants and sends push notifications when tokens exist. |
| `onMessageCreated` | Firestore trigger on `matches/{matchId}/messages/{messageId}` create | Backend | `matches/{matchId}`, `functionEventReceipts/{receiptId}`, `notifications/{uid}/items/{notificationId}`, FCM | Idempotency receipt prevents duplicate metadata writes; writes unread as a 0/1 conversation flag for the recipient and clears the sender's unread flag. Deterministic notification ID prevents duplicate activity rows. Only dating matches refresh Event Success scorecards or emit participant chat-signal facts; event-scoped Host inquiries retain notification behavior without contaminating mutual-match, chat-started, or invite-link connection metrics. |
| `moderateChatMessage` | Firestore trigger on match-scoped message create | Backend | `matches/{matchId}/messages/{messageId}`, `moderationFlags/{id}` | Deterministic moderation flag for blocked/flagged text. |
| `moderatePhotoOnUpload` | Storage trigger | Backend | `moderationFlags/{id}`, `users/{uid}.profilePhotos`, Storage delete | Deletes unsafe uploaded profile photos and removes the matching grouped photo from the private profile. |
| `createEventReview` | Callable | `ReviewsRepository.addReview` | `reviews/{eventId~uid}` | Attended-event review create. Server verifies the `eventParticipations/{eventId_uid}` edge, derives public reviewer name with the shared profile projection helper, and writes the deterministic review doc. |
| `updateEventReview` | Callable | `ReviewsRepository.updateReview` | `reviews/{reviewId}.rating/comment/updatedAt` | Author-only review edit. |
| `deleteEventReview` | Callable | `ReviewsRepository.deleteReview` | `reviews/{reviewId}` delete | Author-only review delete. `syncClubReviewStats` recomputes aggregate rating/count after deletion. |
| `syncClubReviewStats` | Firestore trigger on `reviews/{reviewId}` write | Backend | `clubs/{clubId}.rating`, `reviewCount` | Recomputes aggregate state, so duplicate trigger delivery is safe. |
| `blockUser` | Callable | `SafetyRepository.blockUser` | `blocks/{blocker}__{target}`, `matches/{matchId}` status | Rate-limited before writes; backend-owned safety edge and match closure. |
| `unblockUser` | Callable | `SafetyRepository.unblockUser` | `blocks/{blocker}__{target}` delete | Rate-limited before delete; removes directed block edge. |
| `onBlockCreated` | Firestore trigger on `blocks/{blockId}` create | Backend | `matches/{matchId}` status | Secondary safety guard to close matches after block edge writes. |
| `reportUser` | Callable | `SafetyRepository.reportUser` | `reports/{autoId}` | Bounded report payload. |
| `requestAccountDeletion` | Callable | `SafetyRepository.requestAccountDeletion` | `deletedUsers/{uid}`, `users/{uid}`, `publicProfiles/{uid}`, Storage deletes, Auth delete, relationship cleanup across memberships, participations, saved events, profile decisions, matches, reviews, payments, notifications, blocks, reports, and `eventBroadcasts` | Rate-limited before destructive work; backend-only account deletion/anonymization. Writes a processing tombstone before cleanup so notification fan-out cannot race deletion, deletes host-authored broadcast receipts, removes a recipient's target identifier and delivery evidence, deletes original profile photos plus thumbnails, and uses relationship-doc queries instead of scanning parent arrays. |
| `joinWaitlist` | HTTP function | Marketing site/waitlist form | `launchWaitlist/{emailHash}` | Public endpoint with CORS and IP rate limiting. |

## Direct Client Firestore Writes

| Dart initiator | Collection/path | Operation | Rule owner | Keep direct? |
|---|---|---|---|---|
| `UserProfileRepository.setUserProfile` | `users/{uid}` | Initial profile create after onboarding identity step. | Owner create plus full shape validation. | Yes. This is initial owner-owned profile creation. |
| `SavedEventRepository.watchSavedEvent` / `saveEvent` / `unsaveEvent` | `savedEvents/{uid_eventId}` | Render, save, or unsave one event for the current user. | Owner direct edge read/create/delete with deterministic ids. | Yes. No user-profile projection is maintained. |
| `FcmService._saveToken` | `users/{uid}/pushInstallations/{installationId}` plus legacy consumer `users/{uid}.fcmToken` | Store app-role scoped push tokens for side-by-side host/consumer installs; consumer still updates the legacy field during migration. | Owner direct create/update of bounded push installation docs; legacy owner update of only `fcmToken`. | Yes. Runtime token update. |
| `OnboardingDraftRepository.saveDraft/deleteDraft` | `onboarding_drafts/{uid}` | Private draft set/delete. | Owner-only, intentionally extensible. | Yes. Private volatile draft state. |
| `SwipeRepository.recordSwipe` | `profileDecisions/{uid}/outgoing/{targetId}` | Create own outgoing profile decision. | Path/data identity, attended-event, block, and payload rules. | Yes. Match creation remains trigger-owned. |
| `ChatRepository.sendMessage` | `matches/{matchId}/messages/{id}` | Create text message. | Match participant create only. | Yes. Match preview/unread/moderation are trigger-owned. |
| `ChatController.sendImage` / `ChatRepository.sendImageMessage` | Storage `matches/{matchId}/images/*`, then `matches/{matchId}/messages/{id}` | Shared `ImageUploadRepository` picks/compresses/uploads the chat image; repository writes the image message. | Storage rules prove match participation from `user1Id`/`user2Id` with legacy `participantIds` fallback; message create rules prove active match participation before Firestore write. | Yes. Media picking/compression is centralized with profile/onboarding/event-club image upload policy. |
| `MatchRepository.resetUnread` | `matches/{matchId}.unreadCounts.{uid}` | Reset own unread count to zero. | Participant narrow update. | Yes. |

## Backend-Owned Collections And Fields

| Path/field | Owner | Client rule |
|---|---|---|
| `publicProfiles/{uid}` | `syncPublicProfile` trigger | Read-only to clients. |
| `hostProfiles/{uid}` | Host profile owner writes and `createClub`/host-management seed paths | Public readable professional host identity; owner can create/update bounded professional profile fields. Dating/profile fields are not stored here. |
| `clubMemberships/{clubId_uid}` | Event-club membership callables | Direct client writes denied. |
| `clubHostClaims/{uid}` | `createClub` callable | Server-only host lock; direct client reads/writes denied. |
| `clubs/{clubId}` writes | Event-club create/update/archive/delete callables plus review-stat trigger | Direct client writes denied. |
| `clubs/{clubId}/posts/{postId}` | `createClubPost` callable | Authenticated clients can read; direct writes denied. |
| `users/{uid}.deleted`, `deletedAt` | Account deletion callable | Direct client writes denied. |
| `clubs/{clubId}.memberCount` | Event-club membership callables plus `syncClubMemberStats` repair trigger | Direct client writes denied. |
| `clubs/{clubId}.rating`, `reviewCount` | `syncClubReviewStats` trigger | Direct client writes denied. |
| `clubs/{clubId}.nextEventAt`, `nextEventLabel` | Event callables plus `syncClubNextEvent` projection trigger | Direct client writes denied. |
| `clubs/{clubId}.status`, `archived`, `archivedAt`, `archiveReason` | `archiveClub` callable | Direct client writes denied. |
| `events/{eventId}.bookedCount`, `waitlistedCount`, `checkedInCount`, `genderCounts` | Booking, waitlist, attendance, payment callables | Direct client writes denied. |
| `events/{eventId}.status`, `cancelledAt`, `cancellationReason` | `createEvent` / `cancelEvent` / `deleteEvent` callables | Direct client writes denied. |
| `eventParticipations/{eventId_uid}` | Booking, waitlist, attendance, cancellation, account deletion callables. Event detail reads current-viewer CTA/review state from this edge; shared signed-up/attended event streams query it by user/status; host attendance management, swipe candidate generation, and event recap derive roster/check-in state from event participation statuses. | Direct client writes denied. |
| `eventBroadcasts/{broadcastId}` | `sendEventBroadcast` callable and account-deletion cleanup | Server-only operational receipt. Direct client reads and writes are denied; clients receive only sanitized callable response counts. `expiresAt` requires a 90-day Firestore TTL policy. |
| `payments/{paymentId}` | Payment verification/cancel callables | Direct client writes denied. |
| `reviews/{reviewId}` writes | Review mutation callables plus review-stat trigger | Direct client writes denied. |
| `matches/{matchId}` create/status/preview/unread flags | Matching/message/block triggers plus `startClubHostConversation` | Direct client creation denied; only participant unread reset allowed. Dating matches use `eventIds` as shared-event history. Host inquiries are independently scoped by club, optional event, and participant pair; a general inquiry keeps `eventIds` empty and must never be inferred as event-specific. The current two-participant model is a personal contacted-host thread, not a team-shared organizer inbox. Dart reads legacy `eventId` while older seeded/live data is being cleaned up. |

## User Identity Projection Inventory

| Projection | Source | Sync owner | Repair / validation |
|---|---|---|---|
| `publicProfiles/{uid}.name`, `profilePhotos`, `activityPreferences`, and public profile fields | `users/{uid}` | `syncPublicProfile` | Firestore trigger plus `tool/data/validate_firestore_data.mjs` profile checks and `tool/data/recompute_public_profiles.mjs` repair. |
| `clubs/{clubId}.hostName`, `hostAvatarUrl`, `hostProfiles[]` | `hostProfiles/{uid}` professional host profile | `createClub` on create, host-management callables on co-host changes, then `syncHostProfile` on host profile writes | `tool/data/recompute_club_host_profiles.mjs`; validator emits `event-club-host-name-drift` / `event-club-host-avatar-drift`. |
| `reviews/{reviewId}.reviewerName` | Reviewer `users/{reviewerUserId}` | `createEventReview` on create, then `syncPublicProfile` on profile writes | `tool/data/recompute_review_author_profiles.mjs`; validator emits `reviewer-name-drift`. |
| `notifications/{uid}/items/{id}.actorName`, notification `title`/`body` with names | Event-time public profile at notification creation | Notification trigger/callable that created the event | Historical notification copy. Do not back-update unless product decides notifications should become live profile cards. |
| `matches/{matchId}.lastMessagePreview` | Latest message content | `onMessageCreated` | Message-content preview snapshot, not a user profile projection. |
| `eventParticipations/{eventId_uid}.genderAtSignup`, `events/{eventId}.genderCounts` | User profile at booking/attendance time | Booking/attendance callables and aggregate repair tools | Signup-time constraint snapshot; do not rewrite after profile edits. `tool/data/repair_future_event_attendance.mjs` downgrades stale future-event `attended` edges to `signedUp`, fixes affected aggregates, and deletes invalid swipe artifacts. |
| `notifications/{uid}/items/{notificationId}` | Match/message triggers, create-event fan-out, host event update/cancellation/broadcast, and booking/cancellation callables now; remaining event producers should use the same backend-owned helper. | Owner can read own items and update only `readAt`; client create/delete/content edits are denied. |
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
| Upcoming event reminder | `sendEventReminders` scheduled Function every 15 minutes. | Yes, deterministic `runReminder_${eventId}` item for signed-up participants in the reminder window. | Yes when `prefsEventReminders != false` and token exists. | Implemented. |
| Event signup | `signUpUserForEvent` via `signUpForFreeEvent` and `verifyRazorpayPayment` | Yes, deterministic `runSignup_${eventId}` item for the booked user. | No; this is normally caused by the user's active booking action. | Implemented. |
| Waitlist promotion | `signUpUserForEvent` when a waitlisted user books, and `cancelEventSignUp` when a cancellation promotes the first eligible waitlisted user. | Yes, deterministic `waitlistPromotion_${eventId}` item for the promoted user. | Yes when promotion happens from another user's cancellation, `prefsRunStatusUpdates != false`, and token exists. | Implemented. |
| Event schedule/location change | `updateEvent` callable best-effort fan-out after the event update commits. | Yes, deterministic `eventUpdated_${eventId}` item for signed-up and waitlisted participants. | Yes when `prefsRunStatusUpdates != false` and token exists. | Implemented. |
| Host event broadcast | `sendEventBroadcast` callable from the event-scoped Host Inbox. | Yes, deterministic `eventUpdated_${broadcastId}` item for the server-resolved Booked or Prospective audience. | At most once when `prefsRunStatusUpdates != false` and a Consumer token exists; retries report unknown rather than duplicating a send. | Implemented behind `ENABLE_HOST_EVENT_BROADCAST`; production remains disabled until the live callable preflight passes. |
| Event cancellation | `cancelEvent` callable best-effort fan-out after the event status update commits. | Yes, deterministic `eventCancelled_${eventId}` item for signed-up and waitlisted participants. | Yes when `prefsRunStatusUpdates != false` and token exists. | Implemented; exposed from Host Manage with confirmation and retained-history copy. |
| New event posted by followed club | `createEvent` callable best-effort fan-out after the event commits | Yes, deterministic `clubUpdate_${eventId}` item for active club members, excluding the host. | Two-tier: activity for active members; push only when membership `pushNotificationsEnabled == true`, `prefsClubUpdates != false`, and token exists. | Implemented. |
| New follower post by followed club | `createClubPost` callable best-effort fan-out after the post commits | Yes, deterministic `clubUpdate_${postId}` item for active club members, excluding the host, with `postId` routing metadata. | Two-tier: activity for active members; push only when membership `pushNotificationsEnabled == true`, `prefsClubUpdates != false`, and token exists. | Implemented behind the `ENABLE_CLUB_POSTS` app flag. |

When adding a new producer, write the timeline item through
`functions/src/shared/notifications.ts`, keep IDs deterministic where the
source event has a stable ID, add Functions tests for duplicate delivery, add a
rules test if the client read/update contract changes, and extend
`tool/contracts/firestore_contract.json`.

Internal demo tooling marks source documents with `demoOps`, `demoOpsId`,
`demoOpsCommand`, `seedPrefix`, and `synthetic`. Trigger-owned notification
projections should copy those fields through
`functions/src/shared/demoMetadata.ts` so cleanup and single-user reset commands
can remove derived demo activity precisely.
