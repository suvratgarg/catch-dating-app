# Deploy Runbook — May 2026 Audit Changes

**Date:** 2026-05-04
**Context:** Deploying 14 audit fixes across functions, Firestore rules, and Storage rules.
**Prerequisite:** All changes are on the current branch and have passed `flutter analyze`, `npm test`, and `npm run build`.

---

## Pre-deploy checklist

- [ ] `cd functions && npm test` passes (24 tests)
- [ ] `npm run build` succeeds
- [ ] `flutter analyze` returns zero errors
- [ ] Read this entire runbook before starting

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

## Step 4: Deploy Firestore rules

```bash
./tool/firebase_with_env.sh dev deploy --only firestore:rules
```

Verify in dev (run the app, edit a profile, create a club) before proceeding:

```bash
./tool/firebase_with_env.sh staging deploy --only firestore:rules
./tool/firebase_with_env.sh prod deploy --only firestore:rules
```

The `firebase.json` predeploy hook runs `npm test` (which includes the Firestore rules emulator tests) before deploying. A failure here blocks the deploy — that's intentional. Do not use `--no-verify`.

---

## Step 5: Deploy Storage rules

```bash
./tool/firebase_with_env.sh dev deploy --only storage
./tool/firebase_with_env.sh staging deploy --only storage
./tool/firebase_with_env.sh prod deploy --only storage
```

Verification: upload a chat image in the dev emulator and verify it appears in Storage at `chats/{matchId}/images/{fileName}`.

---

## Step 6: Deploy Functions

This is the largest deploy — new functions, modified functions, and new npm dependencies.

```bash
# Build and deploy to dev first
cd functions
npm run build
cd ..
./tool/firebase_with_env.sh dev deploy --only functions
```

The `firebase.json` predeploy hook runs lint + build before deploying. If it fails, fix the issue (do not skip hooks).

After dev deploy succeeds and passes smoke tests:

```bash
./tool/firebase_with_env.sh staging deploy --only functions
```

After staging deploy succeeds:

```bash
./tool/firebase_with_env.sh prod deploy --only functions
```

### Sync callable invokers after prod deploy

Cloud Run invoker permissions don't always propagate during deploy. Run the sync script:

```bash
cd functions
npm run sync:callable-invokers -- catchdates-dev catchdates-staging catch-dating-app-64e51
```

---

## Step 7: Full deploy (all surfaces at once)

After the initial staggered deploy, future changes can be deployed together:

```bash
./tool/firebase_with_env.sh dev deploy --only functions,firestore:rules,storage
```

---

## Step 8: Smoke tests (dev)

Run through these flows after deploying to dev:

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
5. Verify `attendedUserIds` updated in Firestore

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
| `moderateChatMessage` | Firestore trigger | `chats/{matchId}/messages/{id}` onCreate |
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
- `chats/{matchId}/images/` path (read/write restricted to match participants)

### New Firestore documents (manual creation required)
- `config/cities` — city list for validation + picker
- TTL policy on `rateLimits.expiresAt` (Firebase Console)
