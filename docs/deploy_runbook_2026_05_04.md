---
doc_id: deploy_runbook
version: 2.1.0
updated: 2026-05-07
owner: recursive_audit_loop
status: runbook
---

# Deploy Runbook — May 2026 Relationship-Doc Release

## Read Policy

Use this for the May 2026 deployment sequence only. Re-verify branch state,
environment, Firebase project, and command outputs before running deployment
steps. Do not copy deployment notes into new trackers; update this runbook or
`docs/audit_registry/doc_versions.json`.

**Date:** 2026-05-07
**Context:** Deploying the relationship-document migration, simplified
Firestore rules, backend-owned notifications, review/run-club mutation
callables, deletion cleanup, and related app changes.
**Prerequisite:** All intended changes are on the current branch and have
passed the verification checklist below.

---

## Pre-deploy checklist

- [ ] Review `git diff --stat` and confirm the dirty tree is the intended
  release candidate.
- [ ] `dart run build_runner build --delete-conflicting-outputs` succeeds when
  generated Dart files are stale.
- [ ] `dart tool/generate_firestore_types.dart` succeeds.
- [ ] `node tool/check_firestore_contract.mjs` succeeds.
- [ ] `node --check tool/validate_firestore_data.mjs` succeeds.
- [ ] `npm --prefix functions run lint` succeeds.
- [ ] `npm --prefix functions run build` succeeds.
- [ ] `npm --prefix functions test` succeeds.
- [ ] `firebase emulators:exec --only firestore "npm --prefix functions run test:rules"` succeeds.
- [ ] Focused `flutter analyze --no-fatal-infos` for touched Flutter surfaces
  succeeds.
- [ ] Focused Flutter tests for touched surfaces succeed.
- [ ] Beta data strategy is explicit: reset beta data or run validated
  migration tooling before production users depend on the new schema.
- [ ] Remote Config force-update values are planned but not raised until a
  compatible app build is available.
- [ ] Read this entire runbook before starting.

## Relationship-Doc Release Notes

The old SQL-style relationship arrays are retired. Do not verify, preserve, or
reintroduce these fields during deploy or smoke tests:

- `users/{uid}.joinedRunClubIds`
- `users/{uid}.savedRunIds`
- `runClubs/{clubId}.memberUserIds`
- `runs/{runId}.signedUpUserIds`
- `runs/{runId}.waitlistUserIds`
- `runs/{runId}.attendedUserIds`

The release validates these relationship/action documents instead:

- `runClubMemberships/{clubId_uid}`
- `runParticipations/{runId_uid}`
- `savedRuns/{uid_runId}`
- `matches/{matchId}/messages/{messageId}`

Because Firestore rules now deny several old direct-write paths, deploy
Functions before tightening rules in each environment. Older app builds may
fail after rules deploy; use Remote Config force-update only after the new app
build is available.

---

## Step 1: Enable Cloud Vision API (one-time, per project)

The `moderatePhotoOnUpload` function uses Google Cloud Vision SafeSearch. Enable the API on each GCP project:

```bash
gcloud services enable vision.googleapis.com --project=catchdates-dev
gcloud services enable vision.googleapis.com --project=catchdates-staging
gcloud services enable vision.googleapis.com --project=catch-dating-app-64e51
```

Verify:

```bash
gcloud services list --project=catchdates-dev --enabled | grep vision
```

Without this, the Vision client throws on cold start and photo moderation silently fails open (images are allowed but never scanned).

---

## Step 2: Create `config/cities` document (BEFORE rules deploy)

**CRITICAL ORDERING:** The new `isValidCity()` Firestore rule reads from `config/cities`. If you deploy the rules before creating this document, **all profile updates and club creations will fail** because `firestore.get()` returns null and `isValidCity()` returns false for every city.

### For each environment (dev → staging → prod):

1. Open Firebase Console → Firestore → your project
2. Start a new document in the `config` collection
3. Document ID: `cities`
4. Paste this JSON:

```json
{
  "cityNames": [
    "mumbai",
    "delhi",
    "bangalore",
    "hyderabad",
    "chennai",
    "kolkata",
    "pune",
    "ahmedabad",
    "indore"
  ],
  "cities": [
    {"name": "mumbai", "label": "Mumbai", "latitude": 19.076, "longitude": 72.8777},
    {"name": "delhi", "label": "Delhi", "latitude": 28.7041, "longitude": 77.1025},
    {"name": "bangalore", "label": "Bangalore", "latitude": 12.9716, "longitude": 77.5946},
    {"name": "hyderabad", "label": "Hyderabad", "latitude": 17.385, "longitude": 78.4867},
    {"name": "chennai", "label": "Chennai", "latitude": 13.0827, "longitude": 80.2707},
    {"name": "kolkata", "label": "Kolkata", "latitude": 22.5726, "longitude": 88.3639},
    {"name": "pune", "label": "Pune", "latitude": 18.5204, "longitude": 73.8567},
    {"name": "ahmedabad", "label": "Ahmedabad", "latitude": 23.0225, "longitude": 72.5714},
    {"name": "indore", "label": "Indore", "latitude": 22.7196, "longitude": 75.8577}
  ]
}
```

5. Click Save
6. Verify the document exists in the Firestore console

### To add a city later (no deploy needed):

Add the city name to the `cityNames` array AND the full city object to the `cities` array in the same `config/cities` document. Both arrays must stay in sync — `cityNames` is what the Firestore rules validate against; `cities` is what the Dart `CityRepository` fetches.

---

## Step 3: Create TTL policy on `rateLimits` collection (one-time, per project)

Rate-limit counter documents auto-expire via the `expiresAt` field. Without the TTL policy, they accumulate indefinitely.

1. Firebase Console → Firestore → your project
2. "TTL Policies" tab → "Create TTL Policy"
3. Collection group: `rateLimits`
4. Timestamp field: `expiresAt`
5. Click Create

Do this for dev, staging, and prod.

---

## Step 4: Deploy Functions

Deploy Functions before rules so the new callable write surfaces exist before
direct client writes are denied.

```bash
npm --prefix functions run build
./tool/firebase_with_env.sh dev deploy --only functions
```

After dev smoke tests pass:

```bash
./tool/firebase_with_env.sh staging deploy --only functions
./tool/firebase_with_env.sh prod deploy --only functions
```

### Sync callable invokers after prod deploy

Cloud Run invoker permissions don't always propagate during deploy. Run the
sync script after production Functions deploy:

```bash
npm --prefix functions run sync:callable-invokers -- catchdates-dev catchdates-staging catch-dating-app-64e51
```

## Step 5: Deploy Firestore indexes

Relationship-document queries require composite indexes, especially for
`runParticipations` and notification timelines. Deploy indexes before relying
on the app in each environment.

```bash
./tool/firebase_with_env.sh dev deploy --only firestore:indexes
./tool/firebase_with_env.sh staging deploy --only firestore:indexes
./tool/firebase_with_env.sh prod deploy --only firestore:indexes
```

## Step 6: Deploy Firestore rules

```bash
./tool/firebase_with_env.sh dev deploy --only firestore:rules
```

Verify in dev before proceeding:

```bash
./tool/firebase_with_env.sh staging deploy --only firestore:rules
./tool/firebase_with_env.sh prod deploy --only firestore:rules
```

The `firebase.json` predeploy hook runs Functions tests and the Firestore rules
emulator tests before deploying. A failure here blocks the deploy; do not use
`--no-verify`.

## Step 7: Deploy Storage rules

```bash
./tool/firebase_with_env.sh dev deploy --only storage
./tool/firebase_with_env.sh staging deploy --only storage
./tool/firebase_with_env.sh prod deploy --only storage
```

Verification: upload a chat image in the dev emulator and verify it appears in Storage at `matches/{matchId}/images/{fileName}`.

## Step 8: Full deploy (future patch releases only)

After this initial staggered relationship-doc deploy, future compatible patch
releases can be deployed together:

```bash
./tool/firebase_with_env.sh dev deploy --only functions,firestore:indexes,firestore:rules,storage
```

---

## Step 9: Remote Config force-update rollout

Remote Config is not a schema migration tool. For this release it is a rollout
guard that prevents older app builds from running against the new backend
contract.

Only raise these values after the compatible app build is available:

- `min_version`
- `min_build_ios`
- `min_build_android`
- `min_build_web`
- `min_build_macos`
- `store_url_ios`
- `store_url_android`

Recommended sequence:

1. Bump `pubspec.yaml` build number for the release build.
2. Deploy backend to dev and staging.
3. Install/test the new build against dev/staging.
4. Release the compatible build to beta users.
5. Raise Remote Config minimum build values so older builds see
   `UpdateRequiredScreen`.

## Step 10: Smoke tests (dev)

Run through these flows after deploying to dev:

### Firestore mutation contract
1. Complete or edit a profile, then verify `users/{uid}` updates without
   permission errors.
2. Create a run club, then verify `runClubs/{clubId}.memberCount == 1` and
   `runClubMemberships/{clubId_uid}` exists with `role == host` and
   `status == active`.
3. Join the club as another user, then verify a second
   `runClubMemberships/{clubId_uid}` exists and `memberCount` increments.
4. Leave the club, then verify the membership edge is no longer active and
   `memberCount` matches active membership edges.
5. Create a run as the club host.
6. Book a free run through the app, then verify
   `runParticipations/{runId_uid}` exists with `status == signedUp` and
   `runs/{runId}.bookedCount` increments.
7. Complete a paid run payment and verify `verifyRazorpayPayment` creates a
   `payments/{paymentId}` record, books the run through
   `runParticipations/{runId_uid}`, and updates aggregate counts.
8. Send a chat message and verify the match preview, unread count, and
   `functionEventReceipts` receipt are written once from
   `matches/{matchId}/messages/{messageId}`.
9. Reset unread count from the matches/chats UI.
10. Block, report, and request account deletion from settings/safety flows.

### Photo moderation
1. Upload a profile photo through the app (connected to dev emulators or dev project)
2. Check Functions logs for `[moderation]` output
3. Verify no errors in the Cloud Vision API call

### City picker
1. Open the Clubs tab
2. Tap the city picker — verify all 9 cities appear
3. Switch cities — verify clubs list reloads
4. Edit profile → Location — verify city list loads from provider

### Self-check-in
1. Sign up for a free run in dev
2. Navigate to the run detail screen
3. Verify "Check in" button appears during the 30-minute window
4. Tap "Check in" — verify GPS permission request, check-in success
5. Verify `runParticipations/{runId_uid}.status == attended` and
   `runs/{runId}.checkedInCount` updates in Firestore.

### Rate limiting
1. Call `signUpForFreeRun` repeatedly (5+ times in 60 seconds)
2. Verify the 6th+ call returns `resource-exhausted` error
3. Verify `rateLimits` documents are created in Firestore

### Chat images
1. Open a chat in dev
2. Tap the image button (gallery icon)
3. Select a photo — verify upload progress indicator
4. Verify image renders inline in the message bubble
5. Verify image URL is stored in the message Firestore doc

### Age enforcement
1. Create a test user with DOB set to age 16
2. Complete onboarding — verify no public profile is created
3. Check Functions logs for: `Blocking underage public profile sync`

---

## Rollback

If something breaks in prod:

### Functions
```bash
# Deploy the previous version from the main branch
git checkout main
cd functions && npm ci && npm run build && cd ..
./tool/firebase_with_env.sh prod deploy --only functions
git checkout -  # back to your feature branch
```

### Firestore rules
```bash
git checkout main -- firestore.rules
./tool/firebase_with_env.sh prod deploy --only firestore:rules
git checkout HEAD -- firestore.rules
```

### Storage rules
```bash
git checkout main -- storage.rules
./tool/firebase_with_env.sh prod deploy --only storage
git checkout HEAD -- storage.rules
```

---

## What was deployed

### New functions
| Function | Type | Trigger |
|----------|------|---------|
| `moderatePhotoOnUpload` | Storage trigger | `onObjectFinalized` |
| `moderateChatMessage` | Firestore trigger | `matches/{matchId}/messages/{id}` onCreate |
| `selfCheckInAttendance` | Callable | Client-invoked |

### Modified functions
| Function | Changes |
|----------|---------|
| `syncPublicProfile` | Age enforcement (< 18 blocked) |
| `signUpForFreeRun` | Rate limiting via `checkRateLimit()` |
| `createRazorpayOrder` | Rate limiting in wrapper (handler unchanged) |
| `reportUser` | Rate limiting in wrapper + Zod validation (linter) |
| `joinWaitlist` | IP-based rate limiting |
| `blockUser` | `requireAuth` + `validateCallable` (linter) |
| `joinRunWaitlist` | `requireAuth` + `validateCallable` (linter) |
| Global config | `maxInstances` 10 → 50 |

### New npm dependencies
- `@google-cloud/vision` — Cloud Vision SafeSearch API
- `zod` — Runtime validation for callable request payloads

### New Firestore rules
- `moderationFlags` collection (server-write-only)
- `rateLimits` collection (server-write-only)
- `isValidCity()` function (replaces hardcoded city lists in 2 places)

### New Storage rules
- `matches/{matchId}/images/` path (read/write restricted to match participants)

### New Firestore documents (manual creation required)
- `config/cities` — city list for validation + picker
- TTL policy on `rateLimits.expiresAt` (Firebase Console)
