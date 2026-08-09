---
doc_id: backend_operation_catalog
version: 1.8.1
updated: 2026-08-09
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

## Durable Operations Platform

Long-running, resumable admin workflows use the canonical contracts under
`contracts/operations/` and the server-only collections below. Direct client
reads and writes are denied; a separately authorized worker owns mutations.
The current admin callable is a role-gated, rate-limited read projection only.

| Collection | Record | Owner |
|---|---|---|
| `operationRuns/{runId}` | Frozen scope, budgets, counters, checkpoint, and terminal state | Trusted operations worker |
| `operationWorkItems/{workItemId}` | One exclusive primary stage plus orthogonal task/blocker flags | Trusted operations worker |
| `operationActionReceipts/{actionId}` | Immutable idempotency and action evidence | Trusted operations worker |
| `operationDecisions/{decisionId}` | Revision-bound proposed or accepted decision | Trusted worker or reviewed admin path |
| `operationLeases/{leaseId}` | Fenced worker ownership and heartbeat | Trusted operations worker |
| `operationPublicationPlans/{publicationPlanId}` | Hash-bound preflight plan; not publication authority by itself | Trusted publisher boundary |
| `operationRuleProposals/{ruleProposalId}` | Evidence-derived extractor/rule proposal | Trusted learning worker |
| `operationRuleEvaluations/{ruleEvaluationId}` | Replay, holdout, shadow, and canary metrics | Trusted evaluation worker |
| `adminActionExecutions/{executionId}` | Hash-only start/terminal receipt for one agent CLI admin action | Role-gated admin execution callables |

`contracts/admin/admin_action_catalog.json` binds every callable-backed admin
GUI action to the same stable CLI action id, role set, request schema, GUI
route, risk, confirmation policy, and contract-loop example. The catalog does
not bypass a callable: live CLI execution still uses Firebase Auth, App Check,
the callable's own role/rate/validation/transaction boundary, and a remotely
visible execution receipt. Mutation commands remain dry-run until both action
and target confirmations match the validated payload. Timeouts or malformed
transport responses terminate as `indeterminate` so an agent must reconcile the
target before deciding whether a retry is safe.

`adminListIntakeOperations` reads runs and work items for workflow
`supply-intake`. It grants no run-request, network, model, rule-deployment, or
public-write capability. The four persisted primary stages are exactly
`incoming`, `verify`, `resolve`, and `ready`; publication and terminal outcomes
remain lifecycle state rather than additional tabs.

Organizer Intake reads the latest immutable organizer-only run for each launch
market through that callable. Search candidates remain review work items in
`operationWorkItems`. A reviewed, net-new candidate may cross the separate
`adminCreateOrganizerDraftFromCandidate` boundary, which creates only an
unclaimed, hidden, source-backed `organizers/{opaqueAutoId}` draft plus a
compatibility `clubs/{opaqueAutoId}` document. The operator reviews a separate
public slug; the callable reserves that route transactionally and stores the
slug plus target-field provenance in the curation receipt. Unsupported public
copy and locality remain blank. It cannot publish, index, crawl, expose the
organizer in-app, or assign ownership. Exact retries reuse the deterministic
receipt. Organizer Intake
joins those receipts through `adminListIntakeOperations`, so completed
handoffs remain in Ready after refresh. `contracts/admin/admin_live_data_sources.json`
is the checked route inventory for every Admin tab and sub-workspace.

`functions/scripts/operations/import-shadow-projection.cjs` is the only shipped
local-to-Firestore bridge. It is dry-run by default and requires explicit apply,
an environment whose configured alias exactly matches the project id,
project-aware production confirmation, and matching run confirmation. It
revalidates contracts, shadow authority, joins, totals, hashes, and the frozen
work-item budget; creates `operationWorkItems` before `operationRuns`; repairs
missing items on exact replay; rejects changed records; and never writes a
public product collection. Imported run ids are immutable snapshots. Whole-run
stage and human-review aggregates are stored in run metadata and are required
for reads. The callable supports a canonical `humanReviewRequired` server
filter backed by the `taskFlags` array index; that filter cannot be combined
with unindexed stage/entity/lifecycle filters. The admin controller eagerly
hydrates only that exception lane and lazily pages ordinary inventory, while
`loadedRunCount`, `nextRunCursor`, and `nextWorkItemCursor` describe loaded
inventory honestly. The 10,000-item run cap, 200-item pages, and 120/minute read
limit are cross-contract tested.

The portable work-item schema remains workflow-neutral; the Supply Intake
callable rejects any work item outside its four-stage vocabulary. Local
reconciliation creates a new immutable child run bound to the source plan and
inventory hashes, so imported snapshots are never updated in place. The shipped
promotion command creates only a blocked review receipt; it does not create an
`operationPublicationPlans` record or execute a public write.

## Current Audit Findings

| Priority | Finding | Status |
|---|---|---|
| P0 | `tool/contracts/firestore_contract.json` was stale for `users/{uid}.firstName`, `lastName`, and `displayName`; the generated Functions type and Firestore rules already had the fields. | Fixed in this pass. |
| P0 | Account deletion anonymized `name` but did not clear retained `firstName`, `lastName`, or `displayName` on `users/{uid}`. | Fixed in this pass. |
| P1 | `RATE_LIMITS` declared several callable limits that were not applied at the handlers: `verifyRazorpayPayment`, `cancelEventSignUp`, `joinEventWaitlist`, `blockUser`, `unblockUser`, and `requestAccountDeletion`. `updateUserProfile` also had no configured limit. | Fixed. All listed handlers now call `checkRateLimit`; `updateUserProfile` is 60/minute to allow brisk field-by-field editing without leaving profile writes unbounded. |
| P2 | The machine-readable contract records operations by collection, but not the Dart initiator method for every operation. | This doc fills the human map; a later tooling pass can validate Dart initiators automatically. |
| P2 | Notification fan-out now has a durable backend-owned in-app timeline for match, message, new club event, event signup, waitlist-promotion, upcoming event reminder, event schedule/location updates, and event cancellation events. | Implemented; keep adding new categories through the same Functions-owned interface. |
| P1 | Edge documents were the source of truth, but event-club parent projections relied only on callable updates or batch repair tools. | Fixed. `syncClubMemberStats` recomputes `memberCount` from active membership edges, and `syncClubNextEvent` recomputes `nextEventAt` / `nextEventLabel` from active future event documents. Event callables also refresh the next-event projection before returning. |
| P0 | Historical events split attendee-facing venue text and coordinates across nullable legacy fields, so enforcing a required structured location in every Dart read would make unrepaired records unreadable. | Strict on new and edited writes, discovery, and self-check-in; compatibility-deferred for Dart deserialization only. Dev is 146/146 structured. The refreshed 2026-07-16 production dry run found 272 events: 125 valid, 138 deterministically repairable, and 9 unresolved coordinate blockers with no warnings; no production writes were applied. Keep `Event.meetingLocation` nullable until the production repair and follow-up validation complete, as tracked in `contracts/migrations/event_meeting_location.json`. |

## Cloud Functions Inventory

Organizer authority is canonical. Club-named functions and paths in this
inventory are released-client compatibility projections only; new initiators
use the organizer-named operations below. The migration and retirement boundary
is `docs/migrations/clubs_to_organizers.md`.

| Function | Type | Initiator | Writes | Notes |
|---|---|---|---|---|
| `updateUserProfile` | Callable | `UserProfileRepository.updateUserProfile` | `users/{uid}` | Validates profile patches with generated Ajv contract validators; owns complex profile edits after initial create; rate-limited at 60/minute. |
| `syncPublicProfile` | Firestore trigger on `users/{uid}` writes | Backend | `publicProfiles/{uid}` set/delete, authored `reviews/{reviewId}.reviewerName` updates | Sole owner of dating/user-identity projections. Uses `displayName`, then first name, then legacy fallback; projects grouped `profilePhotos` and nested `activityPreferences.running`. It must not update organizer-manager identity. Existing stale public profiles can be repaired with `node tool/data/recompute_public_profiles.mjs --env dev --apply`; existing stale review author names can be repaired with `node tool/data/recompute_review_author_profiles.mjs --env dev --apply` after `npm --prefix functions run build`. |
| `syncHostProfile` | Firestore trigger on `hostProfiles/{uid}` writes | Backend | hosted `organizers/{organizerId}.hostName`, `hostAvatarUrl`, `hostProfiles[]` plus legacy club shadow | Sole owner of professional host display projections. Uses `hostProfiles/{uid}` only, never the dating public/private profile. |
| `generateProfilePhotoThumbnail` | Storage trigger on `users/{uid}/photos/{fileName}` finalize | Backend | Storage `users/{uid}/photoThumbnails/{fileName}`, `users/{uid}.profilePhotos` | Generates 160px JPEG thumbnails for avatar-scale surfaces. Dashboard/event-detail hype avatars must use thumbnail URLs, not full profile photos. Existing beta data can be backfilled with `npm --prefix functions run backfill:profile-thumbnails -- --apply` after setting `FIREBASE_STORAGE_BUCKET`; the script updates grouped `profilePhotos`. |
| `createOrganizer` | Callable | Flutter organizer repository | `organizers/{organizerId}`, owner `organizerTeamMemberships/{organizerId_uid}`, optional host profile seed, legacy shadows | Creates any supported organizer subtype, records type audit fields, and starts a draft organizer public route. |
| `updateOrganizer` / `archiveOrganizer` / `deleteOrganizer` | Callable | Flutter Hosts organizer workspace | `organizers/{organizerId}` plus legacy shadow | Organizer-manager descriptive updates; owner-only type changes; safe archive/delete lifecycle. |
| `followOrganizer` / `unfollowOrganizer` / `setOrganizerNotificationPreference` | Callable | Flutter consumer organizer surfaces | `organizerFollows/{organizerId_uid}` and `organizers/{organizerId}.followerCount` plus legacy shadows | Canonical consumer relationship; never stored in entity/user arrays. |
| `addOrganizerManager` / `removeOrganizerManager` / `transferOrganizerOwnership` | Callable | Flutter Hosts team workspace | `organizerTeamMemberships`, organizer ownership/host projections, legacy shadows | Owner-controlled team membership and audited ownership transfer. |
| `createOrganizerPost` | Callable | Flutter organizer posts repository | `organizers/{organizerId}/posts/{postId}`, organizer notifications, legacy shadows | Manager-authored, bounded follower update. |
| `requestOrganizerClaim` / `adminDecideOrganizerClaim` | Callable | Website claim flow / admin claim queue | `organizerClaimRequests`, canonical organizer ownership/claim fields, team membership, notifications, legacy shadows | Claim submission never grants access; role-gated admin decision owns transfer. |
| `createPublicOrganizerReview` / `listPublicOrganizerReviews` | Callable | Public website listing | `reviews/{reviewId}` with `organizerId` and compatibility `clubId` | Public review scope is bound to a published canonical organizer route. |
| `adminGetOrganizerDetails` / `adminListOrganizerDetails` / `adminUpdateOrganizerDetails` | Callable | React admin Organizers workspace | canonical organizer read/update projections plus audited legacy shadow | Organizer-named admin wire contract; internal `AdminClub*` adapters are transitional only. |
| `adminDecideOrganizerEventCandidate` | Callable | React Organizer Intake review | `organizerEventCandidateReviewDecisions/{candidateId}` | Records approve/reject plus one explicit resolved/waived decision for every governed import blocker. A waiver must reference the accepted matching policy-gap decision. |
| `adminPublishExternalEvent` | Callable | React Events external-supply workspace | `externalEvents/{eventId}`, `externalEventPublicationReceipts/{receiptId}` | Dry-run/apply authority for one reviewed outbound-only event. Enforces market identity, organizer capability/visibility ceiling, exact blocker decisions, immutable idempotency, and never writes canonical `events`. |
| `adminTakedownExternalEvent` | Callable | React Events external-supply workspace | `externalEvents/{eventId}`, `externalEventPublicationReceipts/{receiptId}` | Dry-run/apply takedown; preserves the record and attribution, records takedown metadata, and is idempotent. |
| `createClub`, `updateClub`, `archiveClub`, `deleteClub`, `joinClub`, `leaveClub`, `createClubPost`, `requestClubClaim`, `adminDecideClubClaim` | Callable compatibility wrappers | Released clients only | legacy club projection and/or canonical organizer adapter | No new client may adopt these names. Remove only after released-client and remote-parity evidence. |
| `setReviewResponse` | Callable | Claimed organizer review UI | `reviews/{reviewId}.ownerResponse` | Server-owned owner response on public review documents. Only managers for the owning organizer can write responses; app and website render the canonical review snapshot. |
| `startOrganizerConversation` | Callable | `ClubHostContactController.startConversation` compatibility controller from organizer or event detail | `matches/{opaqueScopedId}` | Validates `organizerId` and optional `eventId`, prefers canonical organizer-manager authority with a legacy-club fallback during backfill, and checks the block/deleted-user boundary. New documents carry both `organizerId` and the compatibility `clubId`; legacy pair-id `clubHostInquiry` threads remain reusable. `startClubHostConversation` is a released-client wrapper only. |
| `syncClubMemberStats` | Legacy Firestore trigger on `clubMemberships/{membershipId}` write | Backend | compatibility `clubs/{clubId}.memberCount` | Maintains the released-client projection only. Canonical follower counts are owned by `syncOrganizerFollowerStats` on `organizerFollows`; no new consumer may depend on this legacy trigger. |
| `createEvent` | Callable | `EventRepository.createEvent` | `events/{eventId}` with `organizerId`, organizer next-event projection, organizer-follower notifications, compatibility mirrors | Organizer-manager authority is verified server-side; the callable requires and canonicalizes an exact `meetingLocation`, initializes event lifecycle/count projections, and refreshes the organizer next-event projection. |
| `updateEvent` | Callable | `EventRepository.updateEventDetails` | `events/{eventId}`, organizer next-event projection, participant notifications | Host-editable schedule/descriptive fields and photo URL only. Every edit persists exact structured location plus legacy mirrors; schedule/location changes produce deterministic activity. |
| `adminUpdateEventDetails` | Admin callable | Admin Event Details editor | `events/{eventId}`, `adminAuditLogs/{id}` | Admin and Admin Owner may toggle the default-false `crossPathsDiscoveryEnabled` pilot gate. Enablement fails closed unless the event is active, at least six hours away, in `in-mh-mumbai`, has companion inventory disabled, and fewer than three other upcoming events are selected. The audit note remains mandatory. Disabling invalidates pending Cross Paths invitations while preserving accepted plans. |
| `sendEventBroadcast` | Callable | Host Inbox broadcast composer through `EventRepository.sendEventBroadcast` | `eventBroadcasts/{broadcastId}`, `notifications/{uid}/items/{notificationId}`, preference-gated Consumer FCM | Current event hosts can send bounded, moderated event updates to a server-resolved Booked (`signedUp` plus `attended`) or Prospective (`waitlisted`) roster. Inquiry/chat membership never determines recipients. A deterministic Activity item is the durable retry boundary; per-recipient receipt evidence prevents duplicate push attempts and is retained for 90 days through Firestore TTL. The callable is rate-limited to three logical requests per host per hour. |
| `cancelEvent` | Callable | `HostEventManageScreen` | event cancellation fields, organizer next-event projection, canonical schedule-lock release, refunds, participant notifications | Organizer-manager cancellation seam with retained history. |
| `deleteEvent` | Callable | `HostEventManageScreen` | event delete and organizer next-event refresh | Hard delete only for unused events; events with history are cancelled. |
| `syncClubNextEvent` | Firestore trigger on `events/{eventId}` write | Backend | canonical organizer and legacy club next-event projections | Compatibility-named trigger that queries `events.organizerId` and recomputes the organizer projection. |
| `signUpForFreeEvent` | Callable | `PaymentRepository.bookFreeEvent` | `eventParticipations/{eventId_uid}`, event booking/pair aggregate projections, optional `crossPathsPairHolds/{holdId}`, optional Cross Paths event plan, `notifications/{uid}/items/{notificationId}` | Delegates core booking to `signUpUserForEvent`; an active caller-owned companion hold uses its frozen quote and converts atomically into a canonical booking plus event plan after live attendee consent/participation and safety revalidation. |
| `createRazorpayOrder` | Callable | `PaymentRepository.processPayment` | Razorpay order and optional Cross Paths hold attribution | Uses trusted event price and server-side secrets; rejects cancelled events before creating an order. An active caller-owned companion hold freezes price and is carried through fulfillment without widening payment authority. |
| `verifyRazorpayPayment` | Callable | Razorpay success callback in `PaymentRepository` | `payments/{paymentId}`, `eventParticipations/{eventId_uid}`, event count/gender projections, `notifications/{uid}/items/{notificationId}` | Rate-limited before signature validation or Razorpay fetch; verifies signature, books paid event, and writes an in-app booking confirmation. |
| `cancelEventSignUp` | Callable | `EventRepository.cancelSignUpViaFunction` | `eventParticipations/{eventId_uid}`, `events/{eventId}.bookedCount`, `events/{eventId}.waitlistedCount`, `events/{eventId}.genderCounts`, `payments/{paymentId}` refund status, `notifications/{uid}/items/{notificationId}`, FCM to promoted waitlisted user | Rate-limited before payment lookup; may promote a waitlisted runner and refund paid bookings; writes exact count projections after promotion math. |
| `joinEventWaitlist` | Callable | `EventRepository.joinWaitlistViaFunction` | `eventParticipations/{eventId_uid}`, `events/{eventId}.waitlistedCount` | Rate-limited before transaction work; server checks block boundary without exposing block state in rules. |
| `leaveEventWaitlist` | Callable | `EventRepository.leaveWaitlist` | `eventParticipations/{eventId_uid}`, `events/{eventId}.waitlistedCount` | Rate-limited before transaction work; marks the caller's waitlist edge cancelled. |
| `markEventAttendance` | Callable | `EventRepository.markAttendance` | `eventParticipations/{eventId_uid}`, `events/{eventId}.checkedInCount` | Host-only attendance toggle. |
| `selfCheckInAttendance` | Callable | `EventRepository.selfCheckInAttendance` | `eventParticipations/{eventId_uid}`, `events/{eventId}.checkedInCount` | Participant self-check only; verifies sign-up and the time window, then requires exact structured or legacy coordinates and enforces proximity. Missing event coordinates fail closed. |
| `fetchSwipeCandidates` | Callable | `SwipeCandidateRepository`, Event Recap, post-event attendee avatars | `events/{eventId}`, `eventParticipations`, `users`, `publicProfiles`, `profileDecisions`, `blocks` (read only) | App-Check-protected, rate-limited post-event resolver. Fails closed outside the 24-hour Catch window or without attended viewer state, and returns only public projections that pass reciprocal gender/age preferences, prior-decision exclusion, and blocks in both directions. Raw roster identities are never returned. |
| `setCrossPathsEventConsent` | Callable | `CrossPathsRepository.setEventConsent` from Event Detail | `eventCrossPathsConsents/{eventId_uid}`; reads `users/{uid}`, `events/{eventId}`, and `eventParticipations/{eventId_uid}` | App-Check-protected and rate-limited. Acts only for the caller. Enabling requires an explicit private global opt-in, current terms, an Admin-selected active upcoming Mumbai event, and the caller's confirmed `signedUp` participation. Disabling remains available after eligibility disappears. The response contains only event id, enabled state, and terms version. |
| `getCrossPathsSuggestions` | Callable | Cross Paths Explore provider | Reads bounded `events`, confirmed `eventParticipations`, private `users`, `publicProfiles`, `eventCrossPathsConsents`, `crossPathsShowcaseEligibility`, safety/match boundaries, and `crossPathsSuggestionExposures`; creates deterministic exposure receipts | App-Check-protected, explicitly rate-limited, and roster-private. Ignores every real event whose Admin-owned selected-event switch is absent/false or whose market is not `in-mh-mumbai`; then revalidates booking availability, consent, reciprocal compatibility, showcase approval, and safety before returning at most two sanitized person/event projections with a ten-minute signed token. Never returns roster identities or private preference values. |
| `sendCrossPathsInvitation` | Callable | Cross Paths profile preview | `crossPathsInvitations/{eventId_senderUid}`, recipient Activity notification and optional push; reads invitation token claims, event, participations, users, public profiles, consents, showcase eligibility, safety state, policy inventory, and existing invitations/plans | App-Check-protected, signing-key-backed, and rate-limited. Creates at most one sender invitation per event after transactional revalidation. The recipient must be signed up; the sender must be signed up or currently admissible through explicitly reserved companion inventory. Sending alone never books or holds a seat and never alters waitlist rank. |
| `respondCrossPathsInvitation` | Callable | Invitation detail / Activity | Invitation transition, optional `crossPathsPairHolds/{holdId}`, optional deterministic event plan, competing invitation invalidation, sender Activity notification and optional push | Recipient-only, idempotent, and rate-limited. Acceptance repeats eligibility and safety checks. A booked sender receives the event plan immediately; an eligible unbooked sender receives one short-lived companion hold and no conversation until canonical checkout succeeds. |
| `cancelCrossPathsInvitationOrPlan` | Callable | Explore/profile preview, invitation detail, event-plan chat | Pending cancellation or accepted invalidation, event-plan closure, and optional pair-hold release | Participant-scoped, idempotent, and rate-limited. A sender may cancel pending intent; either participant may close an accepted plan or hold. Confirmed event participation remains canonical; pair inventory accounting is released without changing waitlist rank. |
| `expireCrossPathsInvitations` | Scheduled every 15 minutes | Backend | Pending `crossPathsInvitations` whose `expiresAt` has elapsed | Bounded server-owned expiry transition; requires the `status + expiresAt` index and does not touch accepted plans. |
| `expireCrossPathsPairHolds` | Scheduled every 5 minutes | Backend | Active `crossPathsPairHolds` whose `expiresAt` has elapsed plus event held aggregates and invitation state | Bounded, idempotent release. Returns the reserved companion seat, records `hold_expired`, and never cancels the already confirmed attendee or moves either member on a waitlist. |
| `onCrossPathsParticipationWritten` | Firestore trigger on `eventParticipations/{participationId}` | Backend | Invitations and accepted event plans for the member/event | Loss of `signedUp` state invalidates pending invitations and closes accepted plans without changing canonical booking counters. |
| `onCrossPathsConsentWritten` | Firestore trigger on `eventCrossPathsConsents/{consentId}` | Backend | Pending invitations for the member/event | Defense-in-depth for consent writes outside the callable. Revocation invalidates pending invitations but deliberately preserves explicitly accepted plans. |
| `onCrossPathsEventWritten` | Firestore trigger on `events/{eventId}` | Backend | Invitations and accepted event plans for the event | Event cancellation/unavailability invalidates pending invitations and closes accepted plans. |
| `onCrossPathsBlockCreated` | Firestore trigger on `blocks/{blockId}` | Backend | Invitations and event plans for the blocked pair | Immediately invalidates pending invitations and closes accepted event plans in addition to the existing dating-match safety closure. |
| `adminListCrossPathsShowcaseCandidates` | Admin callable | `/cross-paths` Admin review workspace and guarded CLI action | Reads bounded `publicProfiles/{uid}` pages plus server-only `crossPathsShowcaseEligibility/{uid}` | App-Check-protected, rate-limited, and role-gated to Admin, Admin Owner, Safety Reviewer, or Support. Returns only public profile evidence, coarse objective blockers, fingerprint, and effective review status. It returns no consent, roster, preference, popularity, or attractiveness score. |
| `adminSetCrossPathsShowcaseEligibility` | Admin callable | `/cross-paths` Admin review workspace and guarded CLI action | `crossPathsShowcaseEligibility/{uid}`, `adminAuditLogs/{id}`; reads `publicProfiles/{uid}` transactionally | App-Check-protected, rate-limited, and restricted to Admin, Admin Owner, or Safety Reviewer. Approval requires neutral objective readiness and all human checklist items, increments review version, binds the decision to the current SHA-256 profile fingerprint, and writes a coarse audit entry without profile media or private data. |
| `onSwipeCreated` | Firestore trigger on `profileDecisions/{uid}/outgoing/{targetId}` create | Backend | `matches/{matchId}` | Deterministic match ID; creates a match only for reciprocal likes. Writes `eventIds` so a match can track every shared event over time. If a legacy pair-only id is occupied by a `clubHostInquiry`, the dating match uses a separate deterministic opaque id so organizer-support messages can never be converted into dating chat history. |
| `onMatchCreated` | Firestore trigger on `matches/{matchId}` create | Backend | `notifications/{uid}/items/{notificationId}`, FCM | Writes deterministic match activity notifications for both participants and sends push notifications when tokens exist. |
| `onMessageCreated` | Firestore trigger on `matches/{matchId}/messages/{messageId}` create | Backend | `matches/{matchId}`, `functionEventReceipts/{receiptId}`, `notifications/{uid}/items/{notificationId}`, FCM | Idempotency receipt prevents duplicate metadata writes; writes unread as a 0/1 conversation flag for the recipient and clears the sender's unread flag. Deterministic notification ID prevents duplicate activity rows. Only dating matches refresh Event Success scorecards or emit participant chat-signal facts; event-scoped Host inquiries retain notification behavior without contaminating mutual-match, chat-started, or invite-link connection metrics. |
| `moderateChatMessage` | Firestore trigger on match-scoped message create | Backend | `matches/{matchId}/messages/{messageId}`, `moderationFlags/{id}` | Deterministic moderation flag for blocked/flagged text. |
| `moderatePhotoOnUpload` | Storage trigger | Backend | `moderationFlags/{id}`, `users/{uid}.profilePhotos`, Storage delete | Deletes unsafe uploaded profile photos and removes the matching grouped photo from the private profile. |
| `createEventReview` | Callable | `ReviewsRepository.addReview` | `reviews/{eventId~uid}` | Attended-event review create. Server verifies the `eventParticipations/{eventId_uid}` edge, derives public reviewer name with the shared profile projection helper, and writes the deterministic review doc. |
| `updateEventReview` | Callable | `ReviewsRepository.updateReview` | `reviews/{reviewId}.rating/comment/updatedAt` | Author-only review edit. |
| `deleteEventReview` | Callable | `ReviewsRepository.deleteReview` | `reviews/{reviewId}` delete | Author-only review delete. `syncClubReviewStats` recomputes aggregate rating/count after deletion. |
| `syncClubReviewStats` | Firestore trigger on `reviews/{reviewId}` write | Backend | `organizers/{organizerId}.rating/reviewCount/verifiedReviewCount` plus legacy shadow | Compatibility-named trigger that queries `reviews.organizerId`; duplicate delivery is safe. |
| `blockUser` | Callable | `SafetyRepository.blockUser` | `blocks/{blocker}__{target}`, `matches/{matchId}` status | Rate-limited before writes; backend-owned safety edge and match closure. |
| `unblockUser` | Callable | `SafetyRepository.unblockUser` | `blocks/{blocker}__{target}` delete | Rate-limited before delete; removes directed block edge. |
| `onBlockCreated` | Firestore trigger on `blocks/{blockId}` create | Backend | `matches/{matchId}` status | Secondary safety guard to close matches after block edge writes. |
| `reportUser` | Callable | `SafetyRepository.reportUser` | `reports/{autoId}` | Bounded report payload. |
| `requestAccountDeletion` | Callable | `SafetyRepository.requestAccountDeletion` | `deletedUsers/{uid}`, `users/{uid}`, `publicProfiles/{uid}`, `crossPathsShowcaseEligibility/{uid}`, Storage deletes, Auth delete, relationship cleanup across memberships, participations, Cross Paths consents/exposures/invitations/pair holds/event plans, saved events, profile decisions, matches, reviews, payments, notifications, blocks, reports, and `eventBroadcasts` | Rate-limited before destructive work; backend-only account deletion/anonymization. Writes a processing tombstone before cleanup so notification fan-out cannot race deletion; clears both private Cross Paths preferences, consent edges, showcase eligibility, suggestion receipts, participant invitations, and active companion reservations, while existing match cleanup closes event plans. It also deletes host-authored broadcast receipts, removes a recipient's target identifier and delivery evidence, deletes original profile photos plus thumbnails, and uses relationship-doc queries instead of scanning parent arrays. |
| `joinWaitlist` | HTTP function | Marketing member waitlist and Host application | `launchWaitlist/{emailHash}`, `marketingConversionEvents/{emailHash}` | Public endpoint with CORS and IP rate limiting; request/response shapes are versioned under `contracts/http/`, generated into website and Functions types, and validated at both boundaries. |

## Direct Client Firestore Writes

| Dart initiator | Collection/path | Operation | Rule owner | Keep direct? |
|---|---|---|---|---|
| `UserProfileRepository.setUserProfile` | `users/{uid}` | Initial profile create after onboarding identity step. | Owner create plus full shape validation. | Yes. This is initial owner-owned profile creation. |
| `SavedEventRepository.watchSavedEvent` / `saveEvent` / `unsaveEvent` | `savedEvents/{uid_eventId}` | Render, save, or unsave one event for the current user. | Owner direct edge read/create/delete with deterministic ids. | Yes. No user-profile projection is maintained. |
| `FcmService._saveToken` | `users/{uid}/pushInstallations/{installationId}` plus legacy consumer `users/{uid}.fcmToken` | Store app-role scoped push tokens for side-by-side host/consumer installs; consumer attempts both representations independently so one rollout-era denial cannot suppress the other write. | Owner direct create/update of bounded push installation docs; legacy owner update of only `fcmToken`. | Yes. Runtime token update. |
| `OnboardingDraftRepository.saveDraft/deleteDraft` | `onboarding_drafts/{uid}` | Private draft set/delete. | Owner-only, intentionally extensible. | Yes. Private volatile draft state. |
| `SwipeRepository.recordSwipe` | `profileDecisions/{uid}/outgoing/{targetId}` | Create own outgoing profile decision. | Path/data identity, attended-event, block, and payload rules. | Yes. Match creation remains trigger-owned. |
| `ChatRepository.sendMessage` | `matches/{matchId}/messages/{id}` | Create text message. | Match participant create only. | Yes. Match preview/unread/moderation are trigger-owned. |
| `ChatController.sendImage` / `ChatRepository.sendImageMessage` | Storage `matches/{matchId}/images/*`, then `matches/{matchId}/messages/{id}` | Shared `ImageUploadRepository` picks/compresses/uploads the chat image; repository writes the image message. | Storage rules prove match participation from `user1Id`/`user2Id` with legacy `participantIds` fallback; message create rules prove active match participation before Firestore write. | Yes. Media picking/compression is centralized with profile/onboarding/event-club image upload policy. |
| `MatchRepository.resetUnread` | `matches/{matchId}.unreadCounts.{uid}` | Reset own unread count to zero. | Participant narrow update. | Yes. |
| `EventSuccessRepository.savePlan` | `eventSuccessPlans/{eventId}` | Revision-checked partial update of setup-owned plan fields before the event is live. | Host-only setup update; participant activity, event start, live status, or `frozenAt` freezes setup fields. | Yes. The transaction rejects stale/frozen plans and never overwrites live-control fields. |

## Backend-Owned Collections And Fields

| Path/field | Owner | Client rule |
|---|---|---|
| `publicProfiles/{uid}` | `syncPublicProfile` trigger | Read-only to clients. |
| `hostProfiles/{uid}` | Host profile owner writes and organizer team/create seed paths | Public readable professional host identity; dating/profile fields are not stored here. |
| `organizerTeamMemberships/{organizerId_uid}` | Organizer team callables | Scoped reads; direct client writes denied. |
| `organizerFollows/{organizerId_uid}` | Organizer follow callables and account deletion | Owner-scoped reads; direct client writes denied. |
| `organizerClaimRequests/{requestId}` / `organizerScheduleLocks/{lockId}` | Organizer claim and scheduling callables | Server-only; direct client reads/writes denied. |
| `organizers/{organizerId}` writes | Organizer create/update/archive/delete, admin publishing, and projection triggers | Public read; direct client writes denied. |
| `organizers/{organizerId}/posts/{postId}` | `createOrganizerPost` callable | Authenticated clients can read; direct writes denied. |
| Legacy `clubs`, `clubMemberships`, `clubHostClaims`, `clubClaimRequests`, and `clubScheduleLocks` | Compatibility callables/projections | Not valid authority for new behavior; retirement is migration-controlled. |
| `users/{uid}.deleted`, `deletedAt` | Account deletion callable | Direct client writes denied. |
| `organizers/{organizerId}.followerCount` | Organizer follow callable plus recompute trigger | Direct client writes denied. |
| `organizers/{organizerId}.rating`, `reviewCount`, `verifiedReviewCount` | review-stat trigger | Direct client writes denied. |
| `organizers/{organizerId}.nextEventAt`, `nextEventLabel` | Event callables plus next-event trigger | Direct client writes denied. |
| `organizers/{organizerId}.status`, archive fields, and type audit fields | Organizer mutation callables | Direct client writes denied. |
| `events/{eventId}.bookedCount`, `waitlistedCount`, `checkedInCount`, `genderCounts` | Booking, waitlist, attendance, payment callables | Direct client writes denied. |
| `events/{eventId}.status`, `cancelledAt`, `cancellationReason` | `createEvent` / `cancelEvent` / `deleteEvent` callables | Direct client writes denied. |
| `eventParticipations/{eventId_uid}` | Booking, waitlist, attendance, cancellation, account deletion callables. Event detail and shared event streams read only the current viewer's edge(s); authorized event hosts retain managed-roster access. `fetchSwipeCandidates` owns identified post-event discovery for the swipe deck, Event Recap, and attendee-avatar enrichment. | Direct client writes denied. Reads allow only the participant's own edge or an authorized host for that event; arbitrary authenticated roster enumeration is denied. |
| `eventCrossPathsConsents/{eventId_uid}` | `setCrossPathsEventConsent` callable | Caller may read only their own deterministic edge, including an own-edge constrained query that returns empty when no choice exists. Direct client writes and other-member reads are denied. |
| `crossPathsShowcaseEligibility/{uid}` | `adminSetCrossPathsShowcaseEligibility` callable and account-deletion cleanup | Server-only reviewed status, coarse reasons, versions, neutral checklist, and profile fingerprint. Every client read/write is denied; authorized reviewers use the sanitized Admin callable projection. |
| `crossPathsSuggestionExposures/{exposureId}` | `getCrossPathsSuggestions` callable and account-deletion cleanup | Server-only session-idempotent exposure/fatigue receipt. Every client read/write is denied; it contains no roster projection or private preference value. `expiresAt` requires the environment's 30-day Firestore TTL policy. |
| `crossPathsPairHolds/{holdId}` | `respondCrossPathsInvitation`, canonical booking/payment fulfillment, lifecycle triggers, expiry scheduler, and account deletion | Participant-get-only, server-write-only companion reservation. `active` is not a booking; frozen quote, independent booking states, expiry/release, payment, and plan linkage remain callable-owned. List is denied and aggregate capacity lives on the event document. |
| `eventBroadcasts/{broadcastId}` | `sendEventBroadcast` callable and account-deletion cleanup | Server-only operational receipt. Direct client reads and writes are denied; clients receive only sanitized callable response counts. `expiresAt` requires a 90-day Firestore TTL policy. |
| `hostAnalyticsSnapshots/{uid}_{scopeHash}` | `getHostAnalytics` callable and account-deletion cleanup | Server-only 15-minute response cache. Identity includes the authenticated uid, current authorized clubs, absolute local-day range, granularity, preset, and IANA timezone; direct client reads and writes are denied and `expiresAt` has a Firestore TTL policy. |
| `payments/{paymentId}` | Payment verification/cancel callables | Direct client writes denied. |
| `reviews/{reviewId}` writes | Review mutation callables plus review-stat trigger | Direct client writes denied. |
| `matches/{matchId}` create/status/preview/unread flags | Matching/message/block triggers plus `startClubHostConversation` | Direct client creation denied; only participant unread reset allowed. Dating matches use `eventIds` as shared-event history. Host inquiries are independently scoped by club, optional event, and participant pair; a general inquiry keeps `eventIds` empty and must never be inferred as event-specific. The current two-participant model is a personal contacted-host thread, not a team-shared organizer inbox. Dart reads legacy `eventId` while older seeded/live data is being cleaned up. |

## User Identity Projection Inventory

| Projection | Source | Sync owner | Repair / validation |
|---|---|---|---|
| `publicProfiles/{uid}.name`, `profilePhotos`, `activityPreferences`, and public profile fields | `users/{uid}` | `syncPublicProfile` | Firestore trigger plus `tool/data/validate_firestore_data.mjs` profile checks and `tool/data/recompute_public_profiles.mjs` repair. |
| `organizers/{organizerId}.hostName`, `hostAvatarUrl`, `hostProfiles[]` | `hostProfiles/{uid}` professional host profile | `createOrganizer` on create, organizer-team callables on manager changes, then `syncHostProfile` | Legacy club projections are updated during the compatibility window. |
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
| New event posted by followed organizer | `createEvent` callable best-effort fan-out after the event commits | Yes, deterministic `organizerUpdate_${eventId}` item for active followers, excluding the host. | Two-tier: activity for followers; push only when the follow preference and user preference allow it. | Implemented. |
| New follower post by followed organizer | `createOrganizerPost` callable best-effort fan-out after the post commits | Yes, deterministic `organizerUpdate_${postId}` item for active followers, excluding the host, with `postId` routing metadata. | Two-tier: activity for followers; preference-gated push. | Implemented behind the existing posts feature flag. |

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
