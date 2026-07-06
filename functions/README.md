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
| `updateClub` / `archiveClub` / `deleteClub` | `src/clubs/` | Host-owned club mutation surface |
| `addClubHost` / `removeClubHost` | `src/clubs/` | Host management surface |
| `joinClub` / `leaveClub` / `setClubNotificationPreference` | `src/clubs/` | Join/leave a club and manage member notifications |
| `createClubPost` | `src/clubs/` | Host-only follower update with weekly quota and activity fan-out |
| `markEventAttendance` | `src/events/` | Host marks attendance |
| `selfCheckInAttendance` | `src/events/` | Participant self-check-in with GPS |
| `generateEventSuccessPods` | `src/eventSuccess/` | Generate event-success pod suggestions |
| `generateEventSuccessRotations` / `overrideEventSuccessRotations` | `src/eventSuccess/` | Generate or override event-success rotations |
| `fetchEventSuccessWingmanCandidates` / `submitEventSuccessWingmanRequest` / `withdrawEventSuccessWingmanRequest` | `src/eventSuccess/` | Wingman candidate and request workflow |
| `createEventReview` / `updateEventReview` / `deleteEventReview` | `src/reviews/` | Review mutation surface |
| `updateUserProfile` | `src/profiles/` | Profile patch callable with generated contract validation |
| `blockUser` / `unblockUser` | `src/safety/` | Block/unblock another user |
| `requestAccountDeletion` | `src/safety/` | Anonymize + delete user data |
| `reportUser` | `src/safety/` | File a safety report |
| `listSuvbotDemoActions` / `requestSuvbotDemoOperation` | `src/demoOps/` | Demo-data operation catalogue and request surface |
| `adminGetAdminUserRoles` | `src/admin/adminUserRoles.ts` | Admin-owner exact Firebase Auth uid role lookup |
| `adminListAdminRoleAssignments` | `src/admin/adminUserRoles.ts` | Admin-owner bounded role assignment register |
| `adminSetAdminUserRoles` | `src/admin/adminUserRoles.ts` | Admin-owner audited Firebase Auth custom-claim assignment |
| `adminGetSafetyTriageDetails` | `src/admin/safetyTriage.ts` | Admin read-only normalized safety queue detail |
| `adminAssignSafetyTriageItem` | `src/admin/safetyTriage.ts` | Admin audited safety queue assignment |
| `adminDecideSafetyTriageItem` | `src/admin/safetyTriage.ts` | Admin audited safety queue reviewed/dismissed status decision |
| `adminGetAccessApplicationDetails` | `src/admin/accessApplications.ts` | Admin read-only launch access application detail and overlap signals |
| `adminListClubDetails` | `src/admin/clubDetails.ts` | Admin canonical `clubs/{id}` organizer directory |
| `adminGetClubDetails` | `src/admin/clubDetails.ts` | Admin-safe canonical organizer detail snapshot |
| `adminUpdateClubDetails` | `src/admin/clubDetails.ts` | Admin audited owner-safe organizer field patch |
| `adminSetClubIndexStatus` | `src/admin/clubIndexing.ts` | Admin audited organizer index/noindex publishing decision |
| `adminListEventDetails` | `src/admin/eventDetails.ts` | Admin canonical `events/{id}` directory for event publishing ops |
| `adminGetEventDetails` | `src/admin/eventDetails.ts` | Admin-safe canonical event detail snapshot |
| `adminUpdateEventDetails` | `src/admin/eventDetails.ts` | Admin audited safe app-facing event field patch |
| `adminListExternalEventDetails` | `src/admin/externalEventDetails.ts` | Admin read-only external event supply list for `externalEvents/{id}` |
| `adminGetEventSupplyReadiness` | `src/admin/eventSupplyReadiness.ts` | Admin read-only external event import plan and preflight snapshot |
| `adminPublishExternalEvent` | `src/admin/externalEventPublishing.ts` | Admin audited publish of one preflight-approved read-only `externalEvents/{id}` document |
| `adminGetMarketingOpsDashboard` | `src/admin/marketingOps.ts` | Admin read-only marketing ops dashboard bridge |
| `adminRecordMarketingReviewDecision` | `src/admin/marketingOps.ts` | Admin audited marketing review decision, no publish |
| `adminCreateMarketingContentDraft` | `src/admin/marketingOps.ts` | Admin editable marketing draft creation, no post publish |

### Firestore-triggered

| Function | File | Trigger |
|----------|------|---------|
| `syncPublicProfile` | `src/profiles/` | `users/{userId}` onWrite — mirrors public fields + age gate |
| `syncClubMemberStats` | `src/clubs/` | `clubMemberships/{membershipId}` onWrite — recomputes `memberCount` |
| `syncClubNextEvent` | `src/clubs/` | `events/{eventId}` onWrite — recomputes club next-event projection |
| `onSwipeCreated` | `src/matching/` | `profileDecisions/{id}/outgoing/{id}` onCreate — mutual-like → match |
| `onMatchCreated` | `src/matching/` | `matches/{id}` onCreate — FCM push to both users |
| `onMessageCreated` | `src/matching/` | `matches/{id}/messages/{id}` onCreate — unread conversation flag + FCM |
| `onEventSuccessFeedbackWritten` | `src/marketplace/` | Event-success feedback write — recomputes scorecard inputs |
| `syncClubReviewStats` | `src/reviews/` | `reviews/{id}` onWrite — recalculates club rating |
| `onBlockCreated` | `src/safety/` | `blocks/{id}` onCreate — closes existing matches |
| `moderateChatMessage` | `src/moderation/` | `matches/{id}/messages/{id}` onCreate — banned-word filter |

### Scheduled

| Function | File | Schedule |
|----------|------|----------|
| `sendEventReminders` | `src/events/` | Every 15 minutes — writes reminder activity and push notifications |

### Storage-triggered

| Function | File | Trigger |
|----------|------|---------|
| `generateProfilePhotoThumbnail` | `src/profiles/` | Profile photo finalize — creates avatar thumbnails |
| `moderatePhotoOnUpload` | `src/moderation/` | `onObjectFinalized` — SafeSearch analysis |

### HTTP

| Function | File | Purpose |
|----------|------|---------|
| `joinWaitlist` | `src/waitlist/` | Public marketing waitlist endpoint |

## Shared modules

| Module | Purpose |
|--------|---------|
| `src/shared/callableOptions.ts` | App Check enforcement policy |
| `src/shared/generated/` | Contract-generated JSON Schema types, Admin SDK Firestore types, and Ajv validators |
| `src/shared/rateLimit.ts` | Per-user Firestore-transaction rate limiter + IP limiter |
| `src/shared/auth.ts` | `requireAuth()` helper (extracts uid from callable request) |
| `src/shared/validation.ts` | `validateCallableWithAjv()` — generated Ajv request body validation |
| `src/shared/dates.ts` | `computeAge()` — shared DOB → age helper |
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

After deploying callable Functions, run `npm run sync:callable-invokers -- \
<project-id> [...]`. Current callable deployment manifests do not reliably
propagate `invoker` onto the underlying Cloud Event services, and a missing
binding shows up as a Cloud Event/GFE HTML 401/403 before Firebase callable
handling. The sync command grants `allUsers` only the `roles/event.invoker`
permission on the callable Cloud Event services; it does not bypass Firebase Auth
or App Check.

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
