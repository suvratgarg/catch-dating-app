# Catch Project Context

This file is a technical working document for future Codex sessions. If you are about to make changes in this repo, read this first, then jump to the relevant feature files.

## 1. What the app is

Catch is a Flutter app for meeting people through run clubs.

Core product loop:

1. A user signs in with email/password or phone OTP.
2. The user completes an onboarding flow with dating + running preferences.
3. The user browses run clubs by city, joins clubs, and views scheduled runs.
4. A club host creates clubs and creates runs.
5. Users book a run.
   - Free runs use a callable Cloud Function.
   - Paid runs use Razorpay on Android/iOS, then a Cloud Function verifies payment and signs the user up.
6. After the run ends, the host manually marks attendance.
7. Attendees can swipe on other attendees from that run during a 24-hour window.
8. Mutual likes create matches automatically.
9. Matches can chat, receive push notifications, and leave reviews.

This is India-focused today:

- Onboarding phone auth assumes `+91`.
- Cities are hardcoded Indian cities in [`lib/core/indian_city.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/indian_city.dart).
- Payments are in INR via Razorpay.

## 2. Tech stack

Client:

- Flutter
- Riverpod + riverpod_generator
- GoRouter
- Freezed + json_serializable
- Firebase Auth / Firestore / Storage / Functions / Messaging
- Razorpay (`razorpay_flutter`)
- `flutter_map` + OpenStreetMap tiles
- `google_fonts`

Backend:

- Firebase Cloud Functions v2
- Firestore triggers + callable HTTPS functions
- Firebase Admin SDK
- Razorpay server SDK

Design system:

- Theme tokens in [`lib/core/theme/catch_tokens.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/theme/catch_tokens.dart)
- Typography helpers in [`lib/core/theme/catch_text_styles.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/theme/catch_text_styles.dart)
- App theme in [`lib/theme/app_theme.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/theme/app_theme.dart)

## 3. High-level architecture

The app follows a consistent feature-first structure:

- `lib/<feature>/domain`: Freezed models, enums, pure domain logic
- `lib/<feature>/data`: repositories and Riverpod providers
- `lib/<feature>/presentation`: screens, controllers, widgets

Important cross-cutting patterns:

- Repositories wrap Firebase APIs and expose typed reads/writes.
- Riverpod providers expose streams/futures and combine feature state.
- Mutations use `flutter_riverpod/experimental/mutation.dart`.
- Navigation is centralized in [`lib/routing/go_router.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/routing/go_router.dart).
- The authenticated app uses a 5-tab `StatefulShellRoute`.
- Models are serialized with Freezed + JSON; generated files live next to source files.

Entry points:

- App bootstrap: [`lib/main.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/main.dart)
- App widget: [`lib/app.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/app.dart)
- Router: [`lib/routing/go_router.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/routing/go_router.dart)
- Bottom-tab shell: [`lib/core/presentation/app_shell.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/presentation/app_shell.dart)

## 4. Runtime behavior

### 4.1 App startup

Startup flow in [`lib/main.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/main.dart):

- Initializes Firebase.
- Optionally points Auth, Firestore, Storage, and Functions at emulators.
- Registers global error handlers.
- Builds a custom Riverpod `ProviderContainer`.
- Optionally overrides `uidProvider` and `appUserStreamProvider` when `BYPASS_AUTH=true`.

### 4.2 Auth and routing

Auth repository:

- [`lib/auth/auth_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/auth/auth_repository.dart)

Auth UI:

- Email/password screen: [`lib/auth/presentation/auth_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/auth/presentation/auth_screen.dart)
- Auth controller: [`lib/auth/presentation/auth_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/auth/presentation/auth_controller.dart)

Router rules:

- Unauthenticated users are sent to `/auth`.
- Authenticated users with no usable profile doc are sent to `/onboarding`.
- Users with `profileComplete == false` are also sent to `/onboarding`.
- Fully set up users are sent to `/`.

## 5. Route map

Defined in [`lib/routing/go_router.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/routing/go_router.dart).

Standalone routes:

- `/auth`
- `/onboarding`
- `/edit-profile`
- `/payment-history`

Tabbed shell routes:

- `/` → Dashboard
- `/clubs` → Run clubs list
- `/clubs/run-clubs/:runClubId` → Club detail
- `/clubs/run-clubs/:runClubId/runs/:runId` → Run detail
- `/clubs/create-run-club` → Create club
- `/clubs/run-clubs/:runClubId/create-run` → Create run
- `/catches` → Attended runs eligible for swiping
- `/catches/:runId` → Swipe deck for a specific run
- `/chats` → Matches list
- `/chats/:matchId` → Chat
- `/you` → Profile

## 6. Main user journeys

### 6.1 Onboarding

Files:

- Screen: [`lib/onboarding/presentation/onboarding_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/onboarding/presentation/onboarding_screen.dart)
- Controller: [`lib/onboarding/presentation/onboarding_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/onboarding/presentation/onboarding_controller.dart)

Steps:

1. Welcome
2. Phone
3. OTP
4. Name + DOB
5. Gender + interest
6. Photos
7. Running preferences

Behavior:

- Phone auth prepends `+91`.
- If a user already exists in Firebase Auth but has no profile doc, onboarding jumps directly to profile steps.
- Completing onboarding writes a full `users/{uid}` doc and sets `profileComplete=true`.

### 6.2 Dashboard

Files:

- Screen: [`lib/dashboard/presentation/dashboard_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/dashboard/presentation/dashboard_screen.dart)
- Empty state: [`lib/dashboard/presentation/widgets/dashboard_empty.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/dashboard/presentation/widgets/dashboard_empty.dart)
- Full state: [`lib/dashboard/presentation/widgets/dashboard_full.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/dashboard/presentation/widgets/dashboard_full.dart)

Behavior:

- Shows `DashboardEmpty` when the user has no signed-up runs.
- Shows `DashboardFull` once the user has at least one signed-up run.

Dashboard sections:

- Next booked run
- Swipe-window callout for the latest attended run still within 24 hours
- Quick actions
- Weekly distance summary
- Recommended upcoming runs from followed clubs

### 6.3 Run club discovery

Files:

- Screen: [`lib/run_clubs/presentation/run_clubs_list_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/run_clubs/presentation/run_clubs_list_screen.dart)
- State/view model: [`lib/run_clubs/presentation/run_clubs_list_state.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/run_clubs/presentation/run_clubs_list_state.dart)

Behavior:

- Browsing is city-based, defaulting to Mumbai.
- Search is client-side and filters by club name, area, host name, and tags.
- Clubs are partitioned into:
  - `joinedClubs`
  - `discoverClubs`
- The file explicitly marks the filtered provider as the future “Algolia swap point”.

### 6.4 Club detail and hosting

Files:

- Screen: [`lib/run_clubs/presentation/run_club_detail_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/run_clubs/presentation/run_club_detail_screen.dart)
- Controller/view model: [`lib/run_clubs/presentation/run_club_detail_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/run_clubs/presentation/run_club_detail_controller.dart)
- UI body: [`lib/run_clubs/presentation/widgets/club_detail_body.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/run_clubs/presentation/widgets/club_detail_body.dart)

Behavior:

- Shows club details, schedule, reviews, and membership controls.
- Hosts see host stats and a floating create-run action.
- Non-host members can join/leave the club.
- Club reviews are gated by membership and hidden for the host.

### 6.5 Run creation and booking

Files:

- Create run screen: [`lib/runs/presentation/create_run_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/runs/presentation/create_run_screen.dart)
- Create run controller: [`lib/runs/presentation/create_run_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/runs/presentation/create_run_controller.dart)
- Run detail screen: [`lib/runs/presentation/run_detail_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/runs/presentation/run_detail_screen.dart)
- Run detail CTA logic: [`lib/runs/presentation/widgets/run_detail_cta.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/runs/presentation/widgets/run_detail_cta.dart)
- Booking controller: [`lib/runs/presentation/run_booking_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/runs/presentation/run_booking_controller.dart)

Run creation:

- Host-only
- 4-step wizard:
  1. When
  2. Where
  3. Run details
  4. Eligibility rules

Eligibility constraints:

- `minAge`
- `maxAge`
- `maxMen`
- `maxWomen`

Run detail CTA states are derived from `run.statusFor(appUser)`:

- eligible
- signed up
- full
- waitlisted
- attended
- past
- ineligible

### 6.6 Swiping, matching, chatting

Swipe files:

- Hub: [`lib/swipes/presentation/swipe_hub_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/swipes/presentation/swipe_hub_screen.dart)
- Deck: [`lib/swipes/presentation/swipe_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/swipes/presentation/swipe_screen.dart)
- Queue: [`lib/swipes/presentation/swipe_queue_notifier.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/swipes/presentation/swipe_queue_notifier.dart)
- Candidate selection: [`lib/swipes/data/swipe_candidate_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/swipes/data/swipe_candidate_repository.dart)

Swipe candidate rules:

- Start from `run.attendedUserIds`.
- Remove current user.
- Remove users already swiped on.
- Fetch public profiles in batches.
- Filter by current user’s age and gender preferences.

Important: swiping depends entirely on `attendedUserIds` being populated.

Matching files:

- Match repo: [`lib/matches/data/match_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/matches/data/match_repository.dart)
- Matches list: [`lib/chats/presentation/matches_list_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/chats/presentation/matches_list_screen.dart)
- Chat repo: [`lib/chats/data/chat_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/chats/data/chat_repository.dart)
- Chat screen: [`lib/chats/presentation/chat_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/chats/presentation/chat_screen.dart)

Behavior:

- Mutual likes create a deterministic match doc.
- Chats are stored under `chats/{matchId}/messages`.
- Opening/leaving chat resets the current user’s unread count.
- The bottom nav chat tab shows total unread across all matches.

### 6.7 Reviews

Files:

- Repo: [`lib/reviews/data/reviews_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/reviews/data/reviews_repository.dart)
- UI: [`lib/reviews/presentation/reviews_section.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/reviews/presentation/reviews_section.dart)
- Controller: [`lib/reviews/presentation/write_review_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/reviews/presentation/write_review_controller.dart)

Behavior:

- Club review CTA requires membership and hides for the host.
- Run review CTA requires attendance.
- UI previews 5 reviews, then shows “See all”.

### 6.8 Profile and image uploads

Files:

- Profile screen: [`lib/profile/presentation/profile_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/profile/presentation/profile_screen.dart)
- Edit controller: [`lib/profile/presentation/edit_profile_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/profile/presentation/edit_profile_controller.dart)
- Upload controller: [`lib/image_uploads/presentation/photo_upload_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/image_uploads/presentation/photo_upload_controller.dart)
- Upload repo: [`lib/image_uploads/data/image_upload_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/image_uploads/data/image_upload_repository.dart)

Behavior:

- Photos upload to Firebase Storage and then update `users/{uid}.photoUrls`.
- Public profile photo URLs are mirrored by a Cloud Function once the user profile is complete.
- Profile screen has two tabs:
  - editable profile view
  - public preview view

### 6.9 Payments and force-update

Payments:

- Payment repo: [`lib/payments/data/payment_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/payments/data/payment_repository.dart)
- History repo: [`lib/payments/data/payment_history_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/payments/data/payment_history_repository.dart)
- History screen: [`lib/payments/presentation/payment_history_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/payments/presentation/payment_history_screen.dart)

Behavior:

- Paid booking is supported only on Android and iOS.
- Web and macOS deliberately disable paid booking.
- Payment history shows Firestore `payments` docs and resolves the run title from `runs/{activityId}`.

Force update:

- Config repo: [`lib/force_update/data/app_version_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/force_update/data/app_version_repository.dart)
- Decision provider: [`lib/force_update/data/force_update_provider.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/force_update/data/force_update_provider.dart)

Behavior:

- Reads `config/app_config`.
- Compares running app version with remote `minVersion`.
- If below minimum, the app renders `UpdateRequiredScreen`.

### 6.10 Push notifications

Files:

- FCM service: [`lib/core/fcm_service.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/fcm_service.dart)

Behavior:

- Initialized from `AppShell` after auth shell mounts.
- Stores `fcmToken` into `users/{uid}`.
- Handles notification tap routing to `/chats/:matchId`.
- Requires provisioning and/or flags depending on platform.

## 7. Firestore data model

Private user data:

- `users/{uid}`
  - source of truth for onboarding/profile
  - includes dating prefs, running prefs, `followedRunClubIds`, `photoUrls`, optional `fcmToken`

Public user projection:

- `publicProfiles/{uid}`
  - generated from `users/{uid}` once `profileComplete == true`
  - contains only public-facing fields such as `name`, `age`, `bio`, and public attributes

Run clubs:

- `runClubs/{clubId}`
  - club metadata, host, membership, rating summary, imagery

Runs:

- `runs/{runId}`
  - schedule, location, price, constraints
  - booking arrays:
    - `signedUpUserIds`
    - `attendedUserIds`
    - `waitlistUserIds`
  - `genderCounts` is a denormalized map maintained by sign-up/cancel flows

Payments:

- `payments/{paymentId}`
  - written by backend
  - used for history and refunds

Swipes:

- `swipes/{userId}/outgoing/{targetId}`
  - one outgoing swipe doc per target user

Matches:

- `matches/{matchId}`
  - deterministic match ID from sorted user IDs
  - stores unread counts and last-message summary

Chats:

- `chats/{matchId}/messages/{messageId}`

Reviews:

- `reviews/{reviewId}`

Remote config:

- `config/app_config`

The TypeScript mirror of the Firestore schema is:

- [`functions/src/types/firestore.ts`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/src/types/firestore.ts)

If you change a Dart model that a Cloud Function reads or writes, update the TS type mirror too.

## 8. Backend contract

Cloud Functions entrypoint:

- [`functions/src/index.ts`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/src/index.ts)

Callable functions:

- `createRazorpayOrder`
  - validates auth and run availability
  - creates Razorpay order
- `verifyRazorpayPayment`
  - verifies signature
  - attempts sign-up
  - refunds immediately if sign-up fails after payment
  - records payment doc
- `signUpForFreeRun`
  - validates free run
  - reuses shared sign-up logic
- `cancelRunSignUp`
  - removes user from sign-up
  - decrements gender counts
  - promotes first eligible waitlisted user
  - attempts Razorpay refund if paid
- `markRunAttendance`
  - host-only
  - can run only after run end
  - copies signed-up users into `attendedUserIds`

Firestore triggers:

- `createUserDocument`
  - blocking auth trigger
  - creates an initial `users/{uid}` doc when Firebase Auth user is created
- `syncPublicProfile`
  - mirrors `users/{uid}` to `publicProfiles/{uid}` once profile is complete
- `onSwipeCreated`
  - creates a match on mutual likes
- `onMatchCreated`
  - sends match push notifications
- `onMessageCreated`
  - increments unread count and sends message push notification
- `syncRunClubReviewStats`
  - recalculates `runClubs/{clubId}.rating` and `reviewCount`

## 9. Security rules

Files:

- Firestore rules: [`firestore.rules`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firestore.rules)
- Storage rules: [`storage.rules`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/storage.rules)

Summary:

- Most Firestore reads require auth.
- Users can write only their own `users/{uid}` docs.
- `publicProfiles` are read-only to clients.
- `payments` are backend-write-only.
- `matches` are backend-write-only.
- `chats` are writable only by match participants.
- `swipes` are writable only by the owner of the outgoing subcollection.
- Storage is currently permissive for any authenticated user.

## 10. Maps and location

Location picking uses:

- [`lib/runs/presentation/location_picker_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/runs/presentation/location_picker_screen.dart)

Important notes:

- Uses `flutter_map` with OpenStreetMap tiles.
- No Google Maps SDK is involved.
- Selected run start locations are stored as raw lat/lng numbers on the run doc.

## 11. Dev commands

Basic:

```bash
flutter pub get
flutter analyze
flutter test
```

Run app:

```bash
flutter run
```

Use emulators:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

Bypass auth:

```bash
flutter run --dart-define=BYPASS_AUTH=true
```

Push messaging:

```bash
flutter run --dart-define=ENABLE_PUSH_MESSAGING=true
```

Regenerate Riverpod/Freezed/Envied code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Functions:

```bash
cd functions
npm install
```

Useful local docs:

- Repo readme: [`README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/README.md)
- Test plan: [`TESTS.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/TESTS.md)
- Audit tracker: [`CLAUDE.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/CLAUDE.md)

## 12. Generated files and codegen rules

Generated files are committed. Common patterns:

- `*.g.dart`
- `*.freezed.dart`

If you change any of the following, run `build_runner`:

- Riverpod annotations
- Freezed models
- JSON-serializable models
- Envied config

Do not hand-edit generated files.

## 13. What to read for common tasks

If you need to change auth/onboarding:

- `lib/auth/**`
- `lib/onboarding/**`
- `lib/app_user/**`
- `lib/public_profile/**`

If you need to change run club discovery or hosting:

- `lib/run_clubs/**`

If you need to change booking, eligibility, or attendance:

- `lib/runs/**`
- `functions/src/runs/**`
- `lib/payments/**`
- `functions/src/payments/**`

If you need to change swipe/match/chat behavior:

- `lib/swipes/**`
- `lib/matches/**`
- `lib/chats/**`
- `functions/src/matching/**`

If you need to change reviews:

- `lib/reviews/**`
- `functions/src/reviews/**`

If you need to change push notifications:

- `lib/core/fcm_service.dart`
- `functions/src/matching/onMatchCreated.ts`
- `functions/src/matching/onMessageCreated.ts`

If you need to change force-update:

- `lib/force_update/**`
- Firestore `config/app_config`

## 14. Current sharp edges and likely gotchas

These are the most important things for future Codex sessions to know before editing.

### 14.1 `runClubs` schema is out of sync across client, rules, and TS types

The current Dart `RunClub` model contains fields such as:

- `area`
- `hostName`
- `hostAvatarUrl`
- `memberCount`
- `nextRunAt`
- `nextRunLabel`

But the current Firestore rules and TS interface still reflect an older shape.

Files involved:

- Dart model: [`lib/run_clubs/domain/run_club.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/run_clubs/domain/run_club.dart)
- Rules: [`firestore.rules`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firestore.rules)
- TS types: [`functions/src/types/firestore.ts`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/src/types/firestore.ts)

Impact:

- Creating/updating clubs may fail against real rules unless the deployed rules are newer than this file.
- Future backend changes can easily drift if the TS types are not updated.

### 14.2 Review identity is club-scoped, not truly run-scoped

Review document IDs are deterministic per `(runClubId, reviewerUserId)`:

- [`lib/reviews/domain/review_document_id.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/reviews/domain/review_document_id.dart)

Impact:

- A user can only have one review doc per club.
- Run-level reviews still reuse that same club-scoped ID.
- If product intent is “one review per run”, the ID strategy, repo, and rules all need to change.

### 14.3 Auth bootstrap likely does not match `AppUser` decoding

`createUserDocument` writes a minimal `users/{uid}` document, but `AppUser.fromJson` expects many required fields.

Files:

- Trigger: [`functions/src/index.ts`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/src/index.ts)
- App user model: [`lib/app_user/domain/app_user.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/app_user/domain/app_user.dart)
- App user repo: [`lib/app_user/data/app_user_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/app_user/data/app_user_repository.dart)

Impact:

- Email sign-up and partially created user docs may be fragile until this contract is made explicit.

### 14.4 `BYPASS_AUTH` is only a partial client override

`BYPASS_AUTH` overrides `uidProvider` and `appUserStreamProvider` only. It does not create a real Firebase Auth session.

Impact:

- Router and some UI can work.
- Firestore rules, callable functions, and other auth-backed operations may still fail because Firebase itself is unauthenticated.

### 14.5 Attendance is manual, not automatic

Swiping depends on `attendedUserIds`, and those are only populated when the host calls `markRunAttendance`.

Impact:

- If hosts do not mark attendance, swiping and attendance-based features appear empty.

### 14.6 Firestore indexes file is empty

[`firestore.indexes.json`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firestore.indexes.json) currently has no composite indexes, but the app uses several queries that typically require them.

Impact:

- Real environments may rely on indexes created manually in Firebase Console and not exported back into the repo.

### 14.7 A few UI actions are intentionally unfinished

Known stubs:

- Share button on run detail
- Bookmark/save button on run detail
- Dashboard quick actions for Map view and Calendar

Files:

- [`lib/runs/presentation/widgets/run_detail_body.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/runs/presentation/widgets/run_detail_body.dart)
- [`lib/dashboard/presentation/widgets/quick_actions.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/dashboard/presentation/widgets/quick_actions.dart)

## 15. Testing status

- There is a strong test plan in [`TESTS.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/TESTS.md).
- Many planned tests are still unchecked.
- Existing repo analysis output in [`flutter_analyze_report.txt`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/flutter_analyze_report.txt) shows only directive-ordering infos at the time it was generated.

## 16. Suggested workflow for future Codex prompts

When working in this repo:

1. Read this file.
2. Read the feature’s `domain`, `data`, and `presentation` files together.
3. If a change touches a model used by Cloud Functions, update both Dart and `functions/src/types/firestore.ts`.
4. If a change touches rules-sensitive documents, check `firestore.rules` immediately.
5. Run `build_runner` after annotation/model changes.
6. Prefer updating repository/controller layers instead of pushing Firebase calls directly into widgets.
7. Treat the sharp edges above as real until verified in code or in the deployed Firebase project.

## 17. Non-production directories

These look like support material, not runtime app code:

- `design_handoff_catch_dating_app/`
- `catch-dating-app/`

They may still be useful as design reference, but primary product code lives in `lib/` and `functions/`.

