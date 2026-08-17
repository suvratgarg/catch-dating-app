# Cloud Functions

Functions are deployed to `asia-south1` in all Firebase environments:

- `dev` -> `catchdates-dev`
- `staging` -> `catchdates-staging`
- `prod` -> `catch-dating-app-64e51`

Global concurrency ceiling is 50 (`maxInstances` in `src/index.ts`).
Per-function overrides can be added to individual `onCall` / `onDocumentCreated`
options when specific functions need higher or lower limits.

## Function inventory (July 2026)

### Callable (client-invoked)

| Function | File | Purpose |
|----------|------|---------|
| `createRazorpayOrder` | `src/payments/` | Create Razorpay order for paid events |
| `verifyRazorpayPayment` | `src/payments/` | Verify payment signature + sign up |
| `createEvent` / `updateEvent` / `cancelEvent` / `deleteEvent` | `src/events/` | Host-owned event mutation surface |
| `signUpForFreeEvent` | `src/events/` | Book a free event |
| `cancelEventSignUp` | `src/events/` | Cancel booking (refunds paid events) |
| `joinEventWaitlist` / `leaveEventWaitlist` | `src/events/` | Join or leave a full event's waitlist |
| `placeDetails` / `placesAutocomplete` | `src/places/` | Google Places lookup seam for event locations |
| `createClub` | `src/clubs/` | Create a club and follow it as host |
| `createOrganizer` | `src/organizers/` | Create a canonical organizer and follow it as owner |
| `updateClub` / `archiveClub` / `deleteClub` | `src/clubs/` | Host-owned club mutation surface |
| `updateOrganizer` / `archiveOrganizer` / `deleteOrganizer` | `src/organizers/` | Organizer-owned canonical mutation surface |
| `addClubHost` / `removeClubHost` | `src/clubs/` | Host management surface |
| `addOrganizerManager` / `removeOrganizerManager` / `transferOrganizerOwnership` | `src/organizers/` | Organizer team and ownership management surface |
| `joinClub` / `leaveClub` / `setClubNotificationPreference` | `src/clubs/` | Join/leave a club and manage member notifications |
| `followOrganizer` / `unfollowOrganizer` / `setOrganizerNotificationPreference` | `src/organizers/` | Follow/unfollow an organizer and manage follower notifications |
| `createClubPost` | `src/clubs/` | Host-only follower update with weekly quota and activity fan-out |
| `createOrganizerPost` | `src/organizers/` | Organizer-only follower update with quota and activity fan-out |
| `requestClubClaim` / `adminDecideClubClaim` | `src/clubs/clubClaims.ts` | Public organizer claim submission and audited admin decision |
| `requestOrganizerClaim` / `adminDecideOrganizerClaim` | `src/organizers/organizerClaims.ts` | Canonical organizer claim submission and audited admin decision |
| `startOrganizerConversation` | `src/clubs/clubHostConversations.ts` | Start or resume a viewer conversation with an organizer |
| `sendEventBroadcast` | `src/events/` | Host-only, event-scoped Activity and preference-gated push broadcast with an idempotent receipt and organizer Sends projection |
| `importEventAttendees` / `markEventAttendeeAttendance` | `src/events/eventAttendees.ts` | Import or manually add an external roster and manage operational check-in without Consumer booking |
| `registerPublicEvent` | `src/events/eventAttendees.ts` | Phone-OTP public registration for profile-optional, free, open-admission events |
| `createEventRosterHandoff` | `src/events/eventRosterHandoffs.ts` | Create a short-lived, capability-bound email or WhatsApp roster-forwarding handoff for a Host event |
| `getEventRuntimeBootstrap` / `claimEventRuntimeAccess` / `submitEventRuntimeProfile` / `checkInEventRuntime` / `approveEventRuntimeClaim` | `src/eventSuccess/eventRuntime.ts` | Run the no-download attendee bootstrap, verified roster claim or Host approval, event-scoped intake, and check-in workflow |
| `createEventVenueSession` | `src/events/venueSessions.ts` | Create a short-lived signed venue session for attendee self-check-in |
| `getEventSuccessPresenceSummary` / `heartbeatEventSuccessPresence` | `src/eventSuccess/presence.ts` | Maintain private attendee liveness and return the Host-safe presence summary |
| `resolveEventSuccessLateArrival` | `src/eventSuccess/lateArrivals.ts` | Record a revision-fenced Host resolution for a late or returning attendee |
| `getEventSuccessConversationGraph` / `submitEventSuccessConversationGraph` | `src/eventSuccess/conversationGraph.ts` | Read and submit attendee-private, consent-gated conversation outcomes |
| `setEventSuccessAccountabilityResolution` | `src/eventSuccess/accountability.ts` | Acknowledge the configured completion sweep and resolve checked-in attendees |
| `getOrganizerCrmSummary` | `src/organizers/organizerCrm.ts` | Privacy-bounded, deduplicated past-attendee and channel-readiness counts for organizer managers |
| `getEventRosterInsights` | `src/organizers/eventRosterInsights.ts` | Manager-only, event-relative customer labels for the live operational roster; incomplete identity/history fails closed and spend is limited to completed Catch payments |
| `listOrganizerContacts` / `getOrganizerContactDetail` / `createOrganizerContact` / `mutateOrganizerContact` / `createOrganizerContactNote` / `mutateOrganizerContactNote` / `exportOrganizerContacts` | `src/organizers/organizerContacts.ts` | Search, inspect, manually add, safely update, append/edit author-stamped notes, and export the organizer-owned audience directory; notes never enter exports |
| `startOrganizerContactConversation` | `src/clubs/clubHostConversations.ts` | Start or resume a conversation with a verified, unambiguous linked organizer contact |
| `mergeOrganizerContacts` / `unmergeOrganizerContacts` | `src/organizers/organizerContactMerges.ts` | Reversible manager-reviewed contact identity reconciliation |
| `listOrganizerContactMergeCandidates` / `reviewOrganizerContactMergeCandidate` | `src/organizers/organizerContactMergeReview.ts` | Review verified or proposed identity evidence, durably dismiss distinct people, and reopen only the reviewing manager's decision |
| `getOrganizerMessagingSetup` / `completeOrganizerWhatsappConnection` / `syncOrganizerWhatsappTemplates` / `sendOrganizerWhatsappTest` / `disconnectOrganizerWhatsappConnection` | `src/organizers/organizerMessagingSetup.ts` | Connect and verify an organizer-owned Meta WhatsApp sender and synchronize approved templates |
| `upsertOrganizerCampaign` / `previewOrganizerCampaign` / `approveOrganizerCampaign` / `cancelOrganizerCampaign` / `getOrganizerCampaignReport` | `src/organizers/organizerCampaigns.ts` | Draft, freeze, approve, cancel, and report consent-gated organizer campaigns |
| `listOrganizerCampaigns` | `src/organizers/organizerSends.ts` | Page through the organizer's reverse-chronological Campaign and Announcement Sends history |
| `listOrganizerWhatsappThreads` / `getOrganizerWhatsappThread` / `sendOrganizerWhatsappReply` | `src/organizers/organizerWhatsappThreads.ts` | Read retained inbound WhatsApp conversations and reply only inside the current customer-service window |
| `dispatchOrganizerCampaign` | `src/organizers/organizerCampaignDispatcher.ts` | Dispatch one approved organizer campaign snapshot |
| `createAttendeeInviteLink` / `getEventInviteLinkToken` / `recordEventShareIntent` / `resolveEventInviteLanding` | `src/events/inviteLinks.ts` | Issue opaque attributable attendee links, record Catch share intent, and resolve verified invite landings |
| `getOrganizerProviderSetup` / `connectOrganizerLumaProvider` / `listOrganizerLumaEvents` / `syncOrganizerProviderEvent` / `disconnectOrganizerProvider` | `src/organizers/organizerProviderSetup.ts` | Configure, inspect, synchronize, and disconnect supported external booking providers |
| `getEventOperatorAccess` / `listEventStaff` / `grantEventStaff` / `revokeEventStaff` | `src/events/eventStaff.ts` | Grant and inspect time-bounded event staff access |
| `setEventAttendeeAttendance` | `src/events/eventAttendees.ts` | Perform revision-safe, replay-safe operational attendance changes |
| `markEventAttendance` | `src/events/` | Host marks attendance |
| `selfCheckInAttendance` | `src/events/` | Participant self-check-in with GPS |
| `generateEventSuccessPods` | `src/eventSuccess/` | Generate event-success pod suggestions |
| `generateEventSuccessRotations` / `overrideEventSuccessRotations` | `src/eventSuccess/` | Generate or override revision-fenced Host-only rotation drafts |
| `controlEventSuccessLive` / `publishEventSuccessRotationRound` | `src/eventSuccess/liveControl.ts` | Revision-fenced live state and confirmed, idempotent prepared-round publication |
| `upsertEventSuccessLayout` / `getEventSuccessSpatialLayout` / `controlEventSuccessSpatial` | `src/eventSuccess/layoutAssets.ts` | Persist reusable room layouts, resolve event spatial state, and control revision-fenced live reveal placement |
| `recordEventSuccessUnitOutcomes` | `src/eventSuccess/unitOutcomes.ts` | Record revision-safe unit outcomes used by standings-backed event formats |
| `fetchEventSuccessWingmanCandidates` / `submitEventSuccessWingmanRequest` / `withdrawEventSuccessWingmanRequest` | `src/eventSuccess/` | Wingman candidate and request workflow |
| `fetchSwipeCandidates` | `src/matching/` | Resolve privacy-filtered post-event matching candidates without exposing event rosters |
| `setCrossPathsEventConsent` | `src/crossPaths/` | Store or revoke private event-level Cross Paths consent after confirmed booking |
| `getCrossPathsSuggestions` | `src/crossPaths/` | Resolve bounded, consent-safe pre-event Explore suggestions without exposing rosters or private preferences |
| `sendCrossPathsInvitation` / `respondCrossPathsInvitation` / `cancelCrossPathsInvitationOrPlan` | `src/crossPaths/` | Send, answer, or cancel event-scoped invitations, companion holds, and accepted plans |
| `createEventReview` / `updateEventReview` / `deleteEventReview` | `src/reviews/` | Review mutation surface |
| `createPublicOrganizerReview` / `listPublicOrganizerReviews` | `src/reviews/` | Create or list reviews against canonical organizers |
| `updateUserProfile` | `src/profiles/` | Profile patch callable with generated contract validation |
| `blockUser` / `unblockUser` | `src/safety/` | Block/unblock another user |
| `requestAccountDeletion` | `src/safety/` | Anonymize + delete user data |
| `reportUser` | `src/safety/` | File a safety report |
| `listSuvbotDemoActions` / `requestSuvbotDemoOperation` | `src/demoOps/` | Demo-data operation catalogue and request surface |
| `adminListCrossPathsShowcaseCandidates` / `adminSetCrossPathsShowcaseEligibility` | `src/admin/crossPathsShowcaseEligibility.ts` | Admin bounded Cross Paths showcase review queue and audited score-free eligibility decision |
| `adminListActionExecutions` | `src/admin/adminActionExecutions.ts` | Admin bounded execution-receipt register for catalog-driven action monitoring |
| `adminRecordActionExecution` | `src/admin/adminActionExecutions.ts` | Admin append-only bounded execution receipt for catalog-driven actions |
| `adminGetAdminUserRoles` | `src/admin/adminUserRoles.ts` | Admin-owner exact Firebase Auth uid role lookup |
| `adminListAdminRoleAssignments` | `src/admin/adminUserRoles.ts` | Admin-owner bounded role assignment register |
| `adminSetAdminUserRoles` | `src/admin/adminUserRoles.ts` | Admin-owner audited Firebase Auth custom-claim assignment |
| `adminGetSafetyTriageDetails` | `src/admin/safetyTriage.ts` | Admin read-only normalized safety queue detail |
| `adminAssignSafetyTriageItem` | `src/admin/safetyTriage.ts` | Admin audited safety queue assignment |
| `adminDecideSafetyTriageItem` | `src/admin/safetyTriage.ts` | Admin audited safety queue reviewed/dismissed status decision |
| `adminGetAccessApplicationDetails` | `src/admin/accessApplications.ts` | Admin read-only launch access application detail and overlap signals |
| `adminListClubClaimRequests` / `adminGetClubClaimRequestDetails` | `src/admin/clubClaimReview.ts` | Admin pending organizer claim queue and review-safe evidence detail |
| `adminListClubDetails` | `src/admin/clubDetails.ts` | Admin canonical `clubs/{id}` organizer directory |
| `adminGetClubDetails` | `src/admin/clubDetails.ts` | Admin-safe canonical organizer detail snapshot |
| `adminUpdateClubDetails` | `src/admin/clubDetails.ts` | Admin audited owner-safe organizer field patch |
| `adminSetClubIndexStatus` | `src/admin/clubIndexing.ts` | Admin audited organizer index/noindex publishing decision |
| `adminListEventDetails` | `src/admin/eventDetails.ts` | Admin canonical `events/{id}` directory for event publishing ops |
| `adminGetEventDetails` | `src/admin/eventDetails.ts` | Admin-safe canonical event detail snapshot |
| `adminUpdateEventDetails` | `src/admin/eventDetails.ts` | Admin audited safe app-facing event field patch |
| `adminListExternalEventDetails` | `src/admin/externalEventDetails.ts` | Admin read-only external event supply list for `externalEvents/{id}` |
| `adminListIntakeOperations` | `src/admin/intakeOperations.ts` | Role-gated read-only Supply Intake projection with authoritative aggregates, server-filtered human exceptions, and lazy ordinary pages |
| `adminCreateOrganizerDraftFromCandidate` | `src/admin/organizerDraftFromCandidate.ts` | Admin audited, retry-safe creation of a fail-closed organizer draft from reviewed Supply Intake evidence |
| `adminGetEventSupplyReadiness` | `src/admin/eventSupplyReadiness.ts` | Admin read-only external event import plan and preflight snapshot |
| `adminPublishExternalEvent` | `src/admin/externalEventPublishing.ts` | Admin audited publish of one preflight-approved read-only `externalEvents/{id}` document |
| `adminTakedownExternalEvent` | `src/admin/externalEventTakedown.ts` | Admin audited dry-run/apply takedown of one published external event without deleting its source or publication receipts |
| `adminGetMarketingOpsDashboard` | `src/admin/marketingOps.ts` | Admin read-only marketing ops dashboard bridge |
| `adminRecordMarketingReviewDecision` | `src/admin/marketingOps.ts` | Admin audited marketing review decision, no publish |
| `adminCreateMarketingContentDraft` | `src/admin/marketingOps.ts` | Admin editable marketing draft creation, no post publish |
| `adminListOrganizerDetails` / `adminGetOrganizerDetails` / `adminUpdateOrganizerDetails` | `src/admin/clubDetails.ts` | Admin canonical organizer directory, detail, and audited safe patch surface |

### Firestore-triggered

| Function | File | Trigger |
|----------|------|---------|
| `syncPublicProfile` | `src/profiles/` | `users/{userId}` onWrite — mirrors public fields + age gate |
| `syncClubMemberStats` | `src/clubs/` | `clubMemberships/{membershipId}` onWrite — recomputes `memberCount` |
| `syncOrganizerFollowerStats` | `src/clubs/` | `organizerFollowers/{followerId}` onWrite — recomputes canonical follower totals |
| `syncClubNextEvent` | `src/clubs/` | `events/{eventId}` onWrite — recomputes club next-event projection |
| `syncAlgoliaOrganizerIndex` | `src/search/` | `organizers/{organizerId}` onWrite — synchronizes organizer discovery search records |
| `onSwipeCreated` | `src/matching/` | `profileDecisions/{id}/outgoing/{id}` onCreate — mutual-like → match |
| `onMatchCreated` | `src/matching/` | `matches/{id}` onCreate — FCM push to both users |
| `onMessageCreated` | `src/matching/` | `matches/{id}/messages/{id}` onCreate — unread conversation flag + FCM |
| `onEventSuccessFeedbackWritten` | `src/marketplace/` | Event-success feedback write — recomputes scorecard inputs |
| `onEventSuccessConversationGraphWritten` | `src/eventSuccess/conversationGraph.ts` | Aggregates attendee-private conversation outcomes into anonymous Host scorecard counts |
| `onEventSuccessPlanLiveControlUpdated` | `src/eventSuccess/rotationDraftTrigger.ts` | Prepares guided-rotation round N+1 asynchronously after live start or round-N publication |
| `syncClubReviewStats` | `src/reviews/` | `reviews/{id}` onWrite — recalculates club rating |
| `onBlockCreated` | `src/safety/` | `blocks/{id}` onCreate — closes existing matches |
| `onCrossPathsConsentWritten` | `src/crossPaths/` | Cross Paths consent onWrite — invalidates pending invitations after revocation while preserving accepted intent |
| `onCrossPathsEventWritten` | `src/crossPaths/` | `events/{eventId}` onWrite — invalidates invitations/holds when an event becomes unavailable |
| `onCrossPathsParticipationWritten` | `src/crossPaths/` | `eventParticipations/{id}` onWrite — invalidates invitations/holds when participation ends |
| `onCrossPathsBlockCreated` | `src/crossPaths/` | `blocks/{id}` onCreate — invalidates invitations/holds and closes accepted event plans |
| `onEventParticipationRosterProjected` | `src/events/eventAttendeeProjection.ts` | `eventParticipations/{id}` onWrite — projects public display identity and booking status into the operational Host roster without disclosing private-profile contact fields |
| `onEventAttendeeAudienceProjected` | `src/organizers/organizerAudienceProjection.ts` | Event attendee writes project organizer-scoped contact and attendance history |
| `onOrganizerCommunicationPreferenceAudienceProjected` | `src/organizers/organizerAudienceProjection.ts` | Organizer communication preferences update consent-safe audience reachability |
| `onOrganizerContactEventEdgeInviteAttributed` | `src/events/eventInviteAttributionProjection.ts` | Verified invite outcomes update contact advocacy evidence |
| `onOrganizerMessagingWebhookEventCreated` | `src/organizers/organizerWhatsappWebhook.ts` | Authenticated provider receipts update campaign delivery projections without retaining message bodies |
| `moderateChatMessage` | `src/moderation/` | `matches/{id}/messages/{id}` onCreate — banned-word filter |

### Scheduled

| Function | File | Schedule |
|----------|------|----------|
| `sendEventReminders` | `src/events/` | Every 15 minutes — writes reminder activity and push notifications |
| `expireCrossPathsInvitations` | `src/crossPaths/` | Every 15 minutes — expires stale pending Cross Paths invitations |
| `expireCrossPathsPairHolds` | `src/crossPaths/` | Every 5 minutes — releases expired companion reservations and invalidates their invitation receipt |
| `dispatchScheduledOrganizerCampaigns` | `src/organizers/organizerCampaignDispatcher.ts` | Dispatches due, approved organizer campaign snapshots |

### Storage-triggered

| Function | File | Trigger |
|----------|------|---------|
| `generateProfilePhotoThumbnail` | `src/profiles/` | Profile photo finalize — creates avatar thumbnails |
| `generateOrganizerLogoThumbnail` | `src/organizers/` | Organizer logo finalize — creates canonical organizer thumbnails |
| `moderatePhotoOnUpload` | `src/moderation/` | `onObjectFinalized` — SafeSearch analysis |

### HTTP

| Function | File | Purpose |
|----------|------|---------|
| `joinWaitlist` | `src/waitlist/` | Public marketing waitlist endpoint |
| `ingestEventRosterWebhook` | `src/events/eventRosterHandoffs.ts` | Receive one HMAC-verified, provider-authenticated roster attachment through a capability-bound email or WhatsApp handoff |
| `organizerWhatsappWebhook` | `src/organizers/organizerWhatsappWebhook.ts` | Verify Meta webhook signatures and project delivery or STOP events without retaining message content |

## Shared modules

| Module | Purpose |
|--------|---------|
| `src/shared/callableOptions.ts` | App Check enforcement policy |
| `src/shared/generated/` | Contract-generated JSON Schema types, Admin SDK Firestore types, and Ajv validators |
| `src/shared/rateLimit.ts` | Per-user Firestore-transaction rate limiter + IP limiter |
| `src/shared/auth.ts` | `requireAuth()` helper (extracts uid from callable request) |
| `src/shared/validation.ts` | `validateCallableWithAjv()` — generated Ajv request body validation |
| `src/shared/dates.ts` | `computeAge()` — shared DOB → age helper |
| `src/operations/` | Portable operation models, validation, reducers, repositories, and server-only persistence ports |
| `scripts/operations/import-shadow-projection.cjs` | Dry-run-first, alias-bound and production-guarded import/repair of a canonical Supply Intake shadow export into server-only run/work-item collections |
| `src/moderation/textFilter.ts` | `moderateText()` — block/flag word list checker |

## Rate limiting

All callable functions that accept user input are rate-limited via
`checkRateLimit()` from `src/shared/rateLimit.ts`. Limits are defined in
`RATE_LIMITS` (per-action config) and enforced via Firestore transactions.
Counter documents are written to `rateLimits/{uid}_{action}_{windowKey}`.
A TTL policy on `expiresAt` auto-deletes counters after their window expires.

The `joinWaitlist` HTTP endpoint uses `checkIpRateLimit()` — an in-memory
per-IP counter (3 POSTs per hour). This does not survive cold starts.

## Content moderation

**Photos:** `moderatePhotoOnUpload` events Google Cloud Vision SafeSearch on
every Storage upload. Images with `VERY_LIKELY` adult/violent content are
deleted and removed from the user's grouped `profilePhotos`. `LIKELY`
content is flagged for human review. Requires Cloud Vision API enabled on the
GCP project.

**Text:** `moderateChatMessage` checks every chat message against a block-list
(hate speech, slurs, explicit content, self-harm) and a flag-list (profanity,
solicitation, drug references). Blocked messages are replaced with
`[message removed for review]`. Flagged messages are left intact and written
to `moderationFlags/{id}`.

Both moderation systems write to the `moderationFlags` collection (server-only,
no client read/write). See `firestore.rules` for the collection rules.

## Security Defaults

Callable app endpoints must use the shared App Check options from
`src/shared/callableOptions.ts`.

Use:

```ts
onCall(appCheckCallableOptions, handler)
onCall(appCheckCallableOptionsWithSecrets([...]), handler)
```

Do not inline `{enforceAppCheck: true, invoker: "public"}` in individual
function files. Firebase callable Gen 2 functions must be publicly invokable at
the Cloud Event/IAM layer so client SDK calls can reach the callable adapter; App
Check and Firebase Auth are then enforced by the shared callable options and
each handler. The shared options declare this intent, and the default `npm test`
suite includes a guard test that fails when an exported callable does not use
the shared App Check options.

`tool/deploy_firebase_targets.sh` synchronizes callable invokers immediately
after each successful Functions phase. The sync command discovers live Cloud
Functions v2 endpoints labeled `deployment-callable=true`, follows pagination,
and uses each exact `serviceConfig.service`; this preserves intentionally live
legacy callables without maintaining a second source list. It grants `allUsers`
only `roles/run.invoker` on those Cloud Run services and preserves existing IAM
bindings. Firebase Auth and App Check remain enforced by the callable adapter
and handler. For controlled recovery, run
`npm run sync:callable-invokers -- <project-id> [...]` directly.

The public `joinWaitlist` endpoint is an HTTPS endpoint for the marketing site,
not a Firebase callable function. It uses an explicit CORS origin allowlist for
Catch domains, Firebase Hosting domains, and local previews. Keep any future
public web-abuse controls for that endpoint separate from callable App Check
enforcement.

## Request validation

Callable functions that accept structured user input should use a generated
Ajv validator from `src/shared/generated/schemaValidators.ts` with
`validateCallableWithAjv(request, validator)` from `src/shared/validation.ts`:

```ts
import {CreateEventCallablePayload} from "../shared/generated/createEventCallablePayload";
import {validateCreateEventCallablePayload} from "../shared/generated/schemaValidators";
import {validateCallableWithAjv} from "../shared/validation";

const data = validateCallableWithAjv<CreateEventCallablePayload>(
  request,
  validateCreateEventCallablePayload,
  normalizeCreateEventPayload,
);
```

Contract sources live under `contracts/`. Regenerate TypeScript validators,
serialized document types, and Admin SDK Timestamp document types with
`node tool/contracts/generate_schema_contracts.mjs`; `./tool/check_data_contract.sh`
fails if generated output is stale. Normalization stays explicit at the callable
boundary so JSON Schema validation remains side-effect free.

Use `src/shared/generated/firestoreAdminTypes.ts` for Admin SDK reads/writes
that return live `FirebaseFirestore.Timestamp` instances. Do not add validation
logic or canonical field definitions there; add or edit the relevant schema in
`contracts/` first.

## Runtime configuration

`EVENT_SUCCESS_DRAFT_PREPARATION_ATTEMPTS` controls the bounded attempts used by
the asynchronous next-rotation draft trigger. It accepts an integer from 1 to
10 and defaults to 3 when absent or invalid. This configuration affects retry
resilience only; rotation publication never performs synchronous generation.

## Secrets

Razorpay secret definitions live in `src/payments/razorpay.ts`.

Current state: `dev`, `staging`, and `prod` use the same Razorpay test-mode
secrets because live Razorpay credentials have not been introduced yet.

Before real payments launch:

1. Create environment-owned Razorpay test/live credentials.
2. Set `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` in each Firebase project.
3. Deploy Functions for each environment.
4. Smoke test order creation, payment verification, cancellation, and refunds.

## External API dependencies

| API | Purpose | How to enable |
|-----|---------|---------------|
| Google Cloud Vision | SafeSearch photo moderation | `gcloud services enable vision.googleapis.com --project=<id>` |
| Razorpay | Payment processing | API keys in Firebase Secret Manager |

Without Cloud Vision enabled, `moderatePhotoOnUpload` fails silently on cold
start — photos are allowed but never scanned.

## Deploy runbook

For multi-surface deploys (functions + rules + storage), follow
[`docs/release_operations.md`](../docs/release_operations.md). The runbook
covers ordering dependencies (`config/cities` before rules), smoke tests, and
release evidence.

## Firestore rules

`firebase.json` includes a predeploy hook that runs Functions tests and the
Firestore rules emulator suite before every
`firebase deploy --only firestore:rules`. Broken rules fail the deploy before
reaching Firebase. The same rules tests run in CI on every PR that touches
`firestore.rules` or the schema/contract files
(`.github/workflows/firestore-rules-ci.yml`).

Rules tests live at `test/firestore.rules.test.cjs` and
`test/storage.rules.test.cjs` and use the `@firebase/rules-unit-testing`
emulators. Add test cases for any new rule conditions, especially `diff()`
checks, `hasOnly`/`hasAll` shape validation, and Storage paths that depend on
Firestore relationship documents.

Run the rules suite through the Firestore + Storage emulator wrapper unless you
already have Firestore on `127.0.0.1:8080` and Storage on `127.0.0.1:9199`.
A direct `npm run test:rules` from this directory only works when those
emulators are already running; `connect ECONNREFUSED` means the emulator
workflow is missing, not necessarily that the rules changed incorrectly.

## Commands

`npm --prefix functions test` builds TypeScript, then recursively discovers
compiled `lib/**/*.test.js` and non-rules harness specs under
`test/**/*.test.cjs`. New domain folders do not require a hand-maintained test
script. Firestore and Storage rules stay in the emulator-owned lane below.

```bash
npm --prefix functions run lint
npm --prefix functions test
firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"
./tool/firebase_with_env.sh dev deploy --only functions
./tool/firebase_with_env.sh staging deploy --only functions
./tool/firebase_with_env.sh prod deploy --only functions
./tool/firebase_with_env.sh dev deploy --only firestore:rules
./tool/firebase_with_env.sh staging deploy --only firestore:rules
./tool/firebase_with_env.sh prod deploy --only firestore:rules
npm run sync:callable-invokers -- catchdates-dev catchdates-staging catch-dating-app-64e51
```
