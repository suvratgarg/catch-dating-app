# Catch Project Context

This file is a technical working document for future Codex sessions. If you are about to make changes in this repo, read this first, then jump to the relevant feature files.

## 1. What the app is

Catch is a Flutter app for meeting people through clubs.

Core product loop:

1. A user signs in with a verified phone OTP.
2. The user completes an onboarding flow with dating + running preferences.
3. The user browses clubs by city, joins clubs, and views scheduled events.
4. A club host creates clubs and events through callable Cloud Functions.
5. Users book an event.
   - Free events use a callable Cloud Function.
   - Paid events use Razorpay on Android/iOS, then a Cloud Function verifies payment and signs the user up.
6. After the event ends, the host manually marks attendance.
7. Attendees can swipe on other attendees from that event during a 24-hour window.
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
- Spacing helpers in [`lib/core/theme/catch_spacing.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/theme/catch_spacing.dart)
- Typography helpers in [`lib/core/theme/catch_text_styles.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/theme/catch_text_styles.dart)
- App theme in [`lib/core/theme/app_theme.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/theme/app_theme.dart)

## 3. High-level architecture

The app follows a consistent feature-first structure:

- `lib/<feature>/domain`: Freezed models, enums, pure domain logic
- `lib/<feature>/data`: repositories and Riverpod providers
- `lib/<feature>/presentation`: screens, controllers, widgets

Important cross-cutting patterns:

- Repositories wrap Firebase APIs and expose typed reads/writes.
- **Firestore partial updates use `DocumentReference.update()` with specific
  field maps (or `FieldValue` operations) rather than reading a full document
  and writing it back with `set()`. This avoids a `Timestamp → DateTime →
  Timestamp` round-trip that loses nanosecond precision and trips Firestore
  rule `diff()` checks. See §18 for the full error handling conventions.**
- Riverpod providers expose streams/futures and combine feature state.
- Mutations use `flutter_riverpod/experimental/mutation.dart`.
  Use `mutationErrorMessage()` from `lib/core/widgets/mutation_error_util.dart`
  for all mutation error display — never show raw `error.toString()`.
- Navigation is centralized in [`lib/routing/go_router.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/routing/go_router.dart).
- The authenticated app uses a 5-tab `StatefulShellRoute`.
- Models are serialized with Freezed + JSON; generated files live next to source files.

Entry points:

- App bootstrap: [`lib/main.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/main.dart)
- App widget: [`lib/app.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/app.dart)
- Router: [`lib/routing/go_router.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/routing/go_router.dart)
- Bottom-tab shell: [`lib/core/presentation/app_shell.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/presentation/app_shell.dart)

Error handling:

- [`lib/core/firestore_error_message.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/firestore_error_message.dart) — translates Firebase error codes to user messages
- [`lib/core/firestore_error_util.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/firestore_error_util.dart) — structured error-context wrapper for repository methods
- [`lib/core/widgets/mutation_error_util.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/widgets/mutation_error_util.dart) — unified mutation error display helper
- [`lib/exceptions/app_exception.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/exceptions/app_exception.dart) — typed `FirestoreWriteException` and `DocumentNotFoundException`

## 4. Runtime behavior

### 4.1 App startup

Startup flow in [`lib/main.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/main.dart):

- Resolves the app environment from `APP_ENV` (`dev`, `staging`, or `prod`).
- Initializes Firebase from the matching `lib/firebase_options_<env>.dart` file.
- Optionally points Auth, Firestore, Storage, and Functions at emulators.
- Registers global error handlers.
- Boots the app inside Riverpod `ProviderScope`.

Firebase App Check is activated immediately after Firebase initialization.
Debug Flutter builds use debug providers; production web uses reCAPTCHA
Enterprise, Android uses Play Integrity, and iOS/macOS uses App Attest. Local
web debug events also set Firebase's documented `FIREBASE_APPCHECK_DEBUG_TOKEN`
flag in `web/index.html` for localhost/loopback origins only.

### 4.2 Auth and routing

Auth repository:

- [`lib/auth/auth_repository.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/auth/auth_repository.dart)

Auth UI:

- Phone entry and OTP verification live inside onboarding:
  - [`lib/onboarding/presentation/pages/phone_page.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/onboarding/presentation/pages/phone_page.dart)
  - [`lib/onboarding/presentation/pages/otp_page.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/onboarding/presentation/pages/otp_page.dart)

Router rules:

- Unauthenticated users are sent directly to `/onboarding`.
- `/auth` is kept only as a legacy redirect to `/onboarding`.
- Authenticated users with no usable profile doc are sent to `/onboarding`.
- Users with `profileComplete == false` are also sent to `/onboarding`.
- Fully set up users are sent to `/`.

## 5. Route map

Defined in [`lib/routing/go_router.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/routing/go_router.dart).

Standalone routes:

- `/loading` → transient loading screen during auth resolution
- `/auth` → legacy redirect to `/onboarding`
- `/onboarding`
- `/calendar` → calendar timeline/agenda view of signed-up events
- `/activity` → activity/notifications feed
- `/filters` → swipe filter preferences (age, pace, distance, gender)
- `/map` → full-screen event map with pinned events
- `/payment-history`
- `/payment-confirmation` → post-payment status (uses extra data)
- `/settings` → safety/settings/account controls
- `/dev/event-policy-lab` → dev/staging-only static event policy lab
- `/dev/event-success-lab` → dev/staging-only event-success feature lab
- `/dev/event-success-preview/:clubId/:eventId` → dev/staging-only contextual
  success preview for a real event
- `/clubs/:clubId/events/:eventId/manage` → canonical Host Manage workspace for
  overview, attendance correction, cancellation/deletion, and event-success tools
- `/clubs/:clubId/events/:eventId/edit` → host-only edit form for published
  event operational details
- `/dashboard/clubs/:clubId/events/:eventId/manage` → legacy/deep-link alias
  into canonical Host Manage
- `/dashboard/clubs/:clubId/events/:eventId/success` → legacy/deep-link alias
  into Host Manage with the Event success section selected
- `/profiles/:uid` → public profile of any user

Tabbed shell routes:

- `/` → Dashboard
- `/clubs` → Clubs list
- `/clubs/:clubId` → Club detail
- `/clubs/:clubId/edit` → Edit club
- `/clubs/:clubId/events/:eventId` → Event detail
- `/clubs/:clubId/events/:eventId/attendance` → legacy/deep-link alias into
  Host Manage with the Attendance section selected
- `/clubs/:clubId/events/:eventId/companion` → attendee event-success
  companion for the booked/attended event
- `/clubs/create-club` → Create club
- `/clubs/:clubId/create-event` → Create event
- `/catches` → Attended events eligible for swiping
- `/catches/:eventId` → Swipe deck for a specific event
- `/catches/:eventId/recap` → Post-event recap
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

- Shows `DashboardEmpty` when the user has no signed-up events.
- Shows `DashboardFull` once the user has at least one signed-up event.

Dashboard sections:

- Next booked event
- Swipe-window callout for the latest attended event still within 24 hours
- Quick actions
- Weekly distance summary
- Recommended upcoming events from followed clubs

### 6.3 Club discovery

Files:

- Screen: [`lib/clubs/presentation/clubs_list_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/clubs/presentation/clubs_list_screen.dart)
- State/view model: [`lib/clubs/presentation/clubs_list_state.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/clubs/presentation/clubs_list_state.dart)

Behavior:

- Browsing is city-based, with GPS auto-detecting the nearest city on first launch. Falls back to Mumbai when GPS is unavailable or denied.
- Search is client-side and filters by club name, area, host name, and tags.
- Clubs are partitioned into:
  - `joinedClubs`
  - `discoverClubs`
- The file explicitly marks the filtered provider as the future “Algolia swap point”.

### 6.4 Club detail and hosting

Files:

- Screen: [`lib/clubs/presentation/club_detail_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/clubs/presentation/club_detail_screen.dart)
- Controller/view model: [`lib/clubs/presentation/club_detail_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/clubs/presentation/club_detail_controller.dart)
- UI body: [`lib/clubs/presentation/widgets/club_detail_body.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/clubs/presentation/widgets/club_detail_body.dart)

Behavior:

- Shows club details, schedule, aggregate reviews, and membership controls.
- Hosts see host stats and create/edit tools, but they cannot leave a club they
  host.
- Non-host members can join/leave the club.
- Club pages show review aggregates only. Review writes are event-scoped from the
  event detail page.

### 6.5 Event creation and booking

Files:

- Create event screen: [`lib/events/presentation/create_event_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/events/presentation/create_event_screen.dart)
- Create event controller: [`lib/events/presentation/create_event_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/events/presentation/create_event_controller.dart)
- Event detail screen: [`lib/events/presentation/event_detail_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/events/presentation/event_detail_screen.dart)
- Event detail CTA logic: [`lib/events/presentation/widgets/event_detail_cta.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/events/presentation/widgets/event_detail_cta.dart)
- Booking controller: [`lib/events/presentation/run_booking_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/events/presentation/run_booking_controller.dart)

Event creation:

- Host-only through the `createEvent` callable.
- 4-step wizard:
  1. Event details
  2. Where
  3. When
  4. Event policy

Event policy:

- `lib/event_policies/**` is the in-progress policy engine for the singles
  event-platform model. It is now wired into the first production migration
  path and should not be removed as dead code.
- New event creation writes an `EventPolicyBundle` snapshot with admission,
  waitlist, pricing, cancellation, and settlement policy. The wizard currently
  supports open capacity, balanced singles, and fixed cohort caps, plus bounded
  cancellation policies.
- `Event.capacityLimit`, `Event.priceInPaise`, and `EventConstraints` remain
  backward-compatible projections for legacy documents and UI surfaces during
  migration. Do not remove them until the backend, rules, and client have a
  completed migration plan.
- Booking/payment Cloud Functions use backend-owned policy helpers for
  admission, cohort counts, viewer-specific price quotes, waitlist movement,
  and host-cancellation refunds. Pricing/admission truth must stay server-side.
- `lib/event_policies/domain/event_policy_preview.dart` contains deterministic
  preview fixtures for host configuration testing. It renders sample attendee
  cohorts into admission, waitlist, manual-review, price-quote, cancellation,
  and host-payout settlement outcomes.
- Keep the model boundaries explicit: `EventPolicyBundle` owns admission,
  pricing, cancellation, and settlement policy axes for new events. Host
  cancellation always makes attendees complete, and platform settlement is
  modeled as host payout after event completion.
- `lib/event_policies/presentation/event_policy_lab_screen.dart` renders those
  fixtures behind the dev/staging-only `/dev/event-policy-lab` route. The
  Settings screen links to it only when `AppConfig.enableEventPolicyLab` is true.
  The lab remains read-only/static; production testing should use the normal
  create-event flow.
- The development tracker is
  [`codex_audit/event_policy_engine_in_development.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/event_policy_engine_in_development.md).

Parallel event-success work:

- `lib/event_success/**` is an in-development live event success layer for the
  future event-platform model. It now has production route entry points from
  host event management and attendee event detail, while the dev/staging lab and
  contextual preview remain available for product iteration.
- Live state is intentionally separate from `events/{eventId}`: host setup and
  live step state live in `eventSuccessPlans/{eventId}`, while attendee
  post-event feedback lives in `eventSuccessFeedback/{eventId_uid}`.
- The private-crush action reuses the existing swipe/profile-decision pipeline
  so reciprocal interest can still become a match; host reports must only use
  aggregate/decomposed feedback and never expose private target identities.
- The first pass models host playbooks, social intensity, check-in, crowd
  balance, micro-pods, social missions, rotations, private crushes, contextual
  openers, decomposed feedback, host analytics, and safety controls.
- Movement-heavy events like events should keep live structure light; stationary
  formats can support more guided or algorithmic modules. Safety, privacy,
  block/report behavior, attendee visibility, and opt-outs remain the main
  product hardening axes before aggressive expansion of live modules.
- `lib/event_success/domain/event_success_event_preview.dart` adapts today's
  `Event`, `Club`, and roster counts into the existing preview blocks. It owns
  no persistence and exists only so host setup, live mode, attendee companion,
  and post-event report ideas can be reviewed against real events.
- The development tracker is
  [`codex_audit/event_success_layer_in_development.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/event_success_layer_in_development.md).

Event detail CTA states are derived from `event.statusFor(userProfile)`:

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

- Start from `eventParticipations` for the selected event with `status == attended`.
- Require the current user to have an attended participation edge for that event.
- Remove current user.
- Remove users already swiped on.
- Remove blocked users.
- Fetch public profiles in batches.
- Filter by current user’s age and gender preferences.

Important: swiping depends on attended `eventParticipations` being populated and
kept consistent with event aggregate counts.

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

- Reviews are event-scoped: one deterministic `reviews/{eventId~reviewerUserId}`
  document per user per event.
- Club pages show aggregate reviews for the club but do not expose a club-level
  write CTA.
- Event review CTA requires attendance.
- UI previews 5 reviews, then shows “See all”.

### 6.8 Profile and image uploads

Files:

- Profile screen: [`lib/user_profile/presentation/profile_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/user_profile/presentation/profile_screen.dart)
- Edit controller: [`lib/user_profile/presentation/profile_edit_controller.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/user_profile/presentation/profile_edit_controller.dart)
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
- Payment history shows Firestore `payments` docs and resolves the event title from `events/{eventId}`.

Force update:

- Config provider: [`lib/force_update/data/app_version_config_provider.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/force_update/data/app_version_config_provider.dart)
- Decision provider: [`lib/force_update/data/force_update_provider.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/force_update/data/force_update_provider.dart)
- Diagnostics: [`lib/force_update/presentation/force_update_diagnostics.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/force_update/presentation/force_update_diagnostics.dart)
- Platform resolver: [`lib/force_update/domain/platform_build_resolver.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/force_update/domain/platform_build_resolver.dart)

Behavior:

- Reads version gates from Firebase Remote Config (initialized in `main.dart`).
- Compares the running build number with the platform-specific remote minimum:
  `minBuildAndroid`, `minBuildIos`, `minBuildWeb`, or `minBuildMacos`.
- Falls back to semantic `minVersion` only when the current platform has no
  minimum build configured.
- If below minimum, the app renders `UpdateRequiredScreen`.
- If the config/version check is loading or fails, the app shell blocks
  normal startup with a loading indicator or retry screen instead of silently
  bypassing the compatibility gate.
- On foreground (resume), the app re-fetches Remote Config so the gate stays
  fresh during long-running sessions.

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
  - includes dating prefs, running prefs, `joinedClubIds`, `photoUrls`, optional `fcmToken`
  - optional `latitude`/`longitude` for proximity features (collected once via device GPS)

Public user projection:

- `publicProfiles/{uid}`
  - generated from `users/{uid}` once `profileComplete == true`
  - contains only public-facing fields such as `name`, `age`, `bio`, public attributes, and optional `latitude`/`longitude`

Clubs:

- `clubs/{clubId}`
  - club metadata, host, membership, rating summary, imagery

Events:

- `events/{eventId}`
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

The generated TypeScript mirror of the Firestore schema is:

- [`functions/src/shared/firestore.ts`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/src/shared/firestore.ts)

If you change a Dart model that a Cloud Function reads or writes, event
`dart tool/generate_firestore_types.dart` and commit the generated TS mirror.

## 8. Backend contract

Cloud Functions entrypoint:

- [`functions/src/index.ts`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/src/index.ts)

Callable functions:

- `createRazorpayOrder`
  - validates auth and event availability
  - creates Razorpay order
- `verifyRazorpayPayment`
  - verifies signature
  - attempts sign-up
  - refunds immediately if sign-up fails after payment
  - records payment doc
- `signUpForFreeEvent`
  - validates free event
  - reuses shared sign-up logic
- `createEvent`
  - host-only event creation
  - derives host authority from the authenticated user and `clubs/{clubId}`
  - initializes booking, attendance, waitlist, and gender count state server-side
- `updateEvent`
  - host-only schedule/descriptive event edits
  - keeps event ownership, capacity, payment, eligibility, booking, attendance,
    waitlist, and gender counts out of direct client writes
- `cancelEventSignUp`
  - removes user from sign-up
  - decrements gender counts
  - promotes first eligible waitlisted user
  - attempts Razorpay refund if paid
- `joinEventWaitlist`
  - adds user to an event's waitlist
- `createClub`
  - creates the club, derives host name/avatar from `users/{uid}`, and mirrors
    host membership onto `users/{uid}.joinedClubIds`
- `joinClub` / `leaveClub`
  - atomically maintain `clubs/{clubId}.memberUserIds`,
    `clubs/{clubId}.memberCount`, and `users/{uid}.joinedClubIds`
  - direct client updates to club membership fields are denied by rules
- `markEventAttendance`
  - host-only
  - can event only after event end
  - copies signed-up users into `attendedUserIds`
- `blockUser`
  - creates a block edge between two users
  - enforces symmetric discovery/communication barriers
- `unblockUser`
  - removes a previously created block edge
- `requestAccountDeletion`
  - anonymizes the retained `users/{uid}` doc
  - deletes profile photos from Storage
  - writes a `deletedUsers/{uid}` tombstone
- `reportUser`
  - creates server-owned `reports` document
  - trims and bounds report text before write

HTTPS endpoint (not callable):

- `joinWaitlist`
  - public marketing waitlist endpoint
  - CORS origin allowlist for Catch domains, Firebase Hosting domains, and local previews

Firestore triggers:

- `syncPublicProfile`
  - mirrors `users/{uid}` to `publicProfiles/{uid}` once profile is complete
- `onSwipeCreated`
  - creates a match on mutual likes
- `onMatchCreated`
  - sends match push notifications
- `onMessageCreated`
  - idempotently updates match preview/unread counts using
    `functionEventReceipts/{receiptId}`
  - sends message push notification after the metadata transaction applies
- `syncClubReviewStats`
  - recalculates `clubs/{clubId}.rating` and `reviewCount`
- `onBlockCreated`
  - closes any existing match/chat between the two users on block creation

## 9. Security rules

Files:

- Firestore rules: [`firestore.rules`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firestore.rules)
- Storage rules: [`storage.rules`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/storage.rules)
- Firestore ownership contract:
  [`tool/firestore_contract.json`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/firestore_contract.json)
- Repeatable data-contract check:
  [`tool/check_data_contract.sh`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/check_data_contract.sh)

Summary:

- Most Firestore reads require auth.
- Users can write only their own `users/{uid}` docs.
- `users/{uid}.joinedClubIds`, club creation, club membership, event
  creation, and host event edits are backend-owned through callables.
- `publicProfiles` are read-only to clients.
- `payments` are backend-write-only.
- `matches` are backend-write-only.
- `functionEventReceipts` are backend-write-only idempotency receipts for
  retry-safe triggers.
- `chats` are writable only by match participants.
- `swipes` are writable only by the owner of the outgoing subcollection.
- Direct event and club deletes are denied until backend cleanup/refund behavior
  exists.
- Storage is currently permissive for any authenticated user.

## 10. Maps and location

GPS / device location:

- [`lib/core/device_location.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/device_location.dart) — `DeviceLocation` provider, the single source of truth for device GPS. Uses `geolocator` with low accuracy + 10 s timeout. Returns `LocationCoordinate?` (null on permission denial or error). Cached per session via `keepAlive: true`.
- [`lib/core/location_service.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/location_service.dart) — `LocationInitializer` provider, collects GPS once and writes `latitude`/`longitude` (and nearest `IndianCity` if not set) to the user's Firestore doc. Watched from `app.dart` so it fires on every app launch.
- [`lib/core/indian_city.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/indian_city.dart) — `IndianCity` enum carries lat/lng coordinates per city plus a deprecated `nearestCity(LocationCoordinate)` static method. New code should prefer the runtime `CityRepository` path.

City auto-select:

- `SelectedClubCity` in [`lib/clubs/presentation/list/clubs_list_view_model.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/clubs/presentation/list/clubs_list_view_model.dart) has an `autoSelectCity()` method that sets the city from GPS but never overrides a manual user pick (tracked with an internal `_userSelected` flag).
- The clubs header watches `DeviceLocation` and calls `autoSelectCity` when GPS resolves (or via post-frame callback for already-resolved GPS).

Distance on profile cards:

- [`lib/swipes/presentation/profile_card_content.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/swipes/presentation/profile_card_content.dart) — `ProfileCardContent.fromProfile()` intentionally does not expose exact distance on public swipe cards because public profiles no longer carry exact user coordinates.
- [`lib/swipes/presentation/widgets/scrollable_profile.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/swipes/presentation/widgets/scrollable_profile.dart) — renders public profile content without requesting device location.

Map center fallback:

- [`lib/events/presentation/location_picker_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/events/presentation/location_picker_screen.dart) — `_pickLocation()` in `CreateEventScreen` uses device GPS as the initial map center when no prior pin exists.
- [`lib/events/presentation/event_map_screen.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/events/presentation/event_map_screen.dart) — `_EventsMap` falls back to device GPS center when no events with coordinates are available.

All map UIs use:

- `google_maps_flutter` for in-app maps.
- Google Maps URLs for external turn-by-turn directions.

Location data model:

- `users/{uid}` carries optional private `latitude`/`longitude` (nullable doubles).
- `publicProfiles/{uid}` carries coarse city only; exact user coordinates are not projected.
- `events/{eventId}` stores required `startingPointLat`/`startingPointLng` for new events.
- Flutter app/domain code uses `LocationCoordinate`; Google Maps `LatLng` is confined to adapter/UI SDK edges.

No geohash, GeoPoint, or server-side proximity queries are used — all distance math is client-side. If server-side "within X km" queries are needed later, add a geohash field in a separate migration.

## 11. Dev commands

Basic:

```bash
flutter pub get
flutter analyze
flutter test
```

Run app:

```bash
./tool/flutter_with_env.sh dev run
```

Preferred environment-aware runs:

```bash
./tool/flutter_with_env.sh dev run
./tool/flutter_with_env.sh staging run
./tool/flutter_with_env.sh prod run
```

Switch active native/web Firebase files:

```bash
./tool/use_firebase_environment.sh dev
./tool/use_firebase_environment.sh staging
./tool/use_firebase_environment.sh prod
```

Use emulators:

```bash
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
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

Firebase deploys by alias:

```bash
./tool/firebase_with_env.sh dev deploy --only functions,firestore,storage
./tool/firebase_with_env.sh staging deploy --only functions
./tool/firebase_with_env.sh prod deploy --only functions
```

Useful local docs:

- Repo readme: [`README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/README.md)
- Test plan: [`TESTS.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/TESTS.md)
- Firebase environments: [`firebase/README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firebase/README.md)
- Functions runbook: [`functions/README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/README.md)
- Audit/doc index: [`codex_audit/README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/codex_audit/README.md)

## 12. Generated files and codegen rules

Generated files are committed. Common patterns:

- `*.g.dart`
- `*.freezed.dart`

If you change any of the following, event `build_runner`:

- Riverpod annotations
- Freezed models
- JSON-serializable models
- Envied config

Do not hand-edit generated files.

## 13. What to read for common tasks

If you need to change auth/onboarding:

- `lib/auth/**`
- `lib/onboarding/**`
- `lib/user_profile/**`
- `lib/public_profile/**`

If you need to change club discovery or hosting:

- `lib/clubs/**`

If you need to change booking, eligibility, or attendance:

- `lib/events/**`
- `functions/src/events/**`
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
- Firebase Remote Config template (in the Firebase Console)

## 14. Current sharp edges and likely gotchas

These are the most important things for future Codex sessions to know before editing.

### 14.1 Keep `clubs` schema aligned across client, rules, and Functions

The current Dart `Club` model, Firestore ownership contract, Firestore
rules, rules tests, and Functions shared TS interface are aligned for fields
such as:

- `area`
- `hostName`
- `hostAvatarUrl`
- `memberCount`
- `nextEventAt`
- `nextEventLabel`

Files involved:

- Dart model: [`lib/clubs/domain/club.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/clubs/domain/club.dart)
- Rules: [`firestore.rules`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firestore.rules)
- TS types: [`functions/src/shared/firestore.ts`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/src/shared/firestore.ts)
- Ownership contract: [`tool/firestore_contract.json`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/firestore_contract.json)
- Rules tests: [`functions/test/firestore.rules.test.cjs`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/functions/test/firestore.rules.test.cjs)
- Combined checker: [`tool/check_data_contract.sh`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/check_data_contract.sh)

Impact:

- Future backend changes can easily drift if the TS types are not updated.
- When changing `Club`, update the Dart model, ownership contract, rules
  validation, Functions TS type, and rules tests in the same pass.

### 14.2 Review identity is event-scoped

Review document IDs are deterministic per `(eventId, reviewerUserId)` using
`eventId~reviewerUserId`.

Impact:

- A user can have one review per event.
- New review creates require `eventId`, matching path/data identity, matching
  reviewer name, and attended-event membership in Firestore rules.
- Club pages aggregate event reviews for display but do not create club-level
  reviews.
- Existing random-ID or missing-`eventId` reviews should be found by
  `node tool/validate_firestore_data.mjs --env <env>` and migrated or archived
  before tightening production data further.

### 14.3 Auth is phone-only and onboarding owns profile creation

Firebase phone OTP signs the user in first. Onboarding then writes the full
`users/{uid}` profile document once the required profile fields are collected.
The profile `email` field is optional and defaults to an empty string.

### 14.4 Attendance is manual, not automatic

Swiping depends on `attendedUserIds`, and those are only populated when the host calls `markEventAttendance`.

Impact:

- If hosts do not mark attendance, swiping and attendance-based features appear empty.

### 14.6 Firestore indexes are repo-managed

[`firestore.indexes.json`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firestore.indexes.json) contains the app's known composite indexes and should be deployed with the rules/storage runbook.

Impact:

- If a query fails in a real environment with an index error, add the generated index definition to this file rather than relying on a console-only index.

### 14.7 Previously stubbed UI actions are now routed or backed by data

Current status:

- Share button on event detail opens the native share sheet.
- Bookmark/save button on event detail writes `users/{uid}.savedEventIds`.
- Dashboard quick actions for Map view and Calendar route to real screens.

Files:

- [`lib/events/presentation/widgets/event_detail_body.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/events/presentation/widgets/event_detail_body.dart)
- [`lib/dashboard/presentation/widgets/quick_actions.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/dashboard/presentation/widgets/quick_actions.dart)

### 14.8 Firebase environments are real, but root config files are mutable

The repo now supports real `dev`, `staging`, and `prod` Firebase projects:

- `dev`: `catchdates-dev`
- `staging`: `catchdates-staging`
- `prod`: `catch-dating-app-64e51`

All three have Android, iOS/macOS, and web app registrations, App Check
providers, App Check enforcement for Firestore, Storage, Auth, and callable
Functions. The local Functions entrypoint currently exports 20 v2 Functions in
`asia-south1`; the deployed count can lag until the next environment deploy.
The previous 17-Function set was redeployed and re-listed across dev, staging,
and prod on 2026-05-01. Firestore rules are also deployed and aligned across
all three projects; dev and staging were updated on 2026-05-01.

Files involved:

- [`lib/core/app_config.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/app_config.dart)
- [`tool/dart_defines/dev.json`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/dart_defines/dev.json)
- [`tool/dart_defines/staging.json`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/dart_defines/staging.json)
- [`tool/dart_defines/prod.json`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/dart_defines/prod.json)
- [`lib/firebase_options_dev.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/firebase_options_dev.dart)
- [`lib/firebase_options_staging.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/firebase_options_staging.dart)
- [`lib/firebase_options_prod.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/firebase_options_prod.dart)
- [`firebase/README.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/firebase/README.md)
- [`tool/use_firebase_environment.sh`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/use_firebase_environment.sh)
- [`tool/validate_firebase_environment.sh`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/tool/validate_firebase_environment.sh)

Impact:

- The root native/web Firebase files are working copies. Always use
  `./tool/flutter_with_env.sh <env> ...` or
  `./tool/use_firebase_environment.sh <env>` before environment-specific
  debugging.
- Event `./tool/validate_firebase_environment.sh <env>` when Firebase runtime
  behavior looks wrong.
- Dev and staging currently reuse prod Razorpay test-mode secrets. Replace them
  with environment-owned secrets before live payments.

## 15. Testing status

- [`TESTS.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/TESTS.md) now tracks the current test-suite inventory instead of the old aspirational checklist.
- Recent broad verification included `flutter analyze`, `flutter test --concurrency=1`, Functions lint/tests, Firestore rules tests, live Functions deploy/list checks, and Firebase environment validation.
- Default fully parallel `flutter test` has previously exposed a `two_dimensional_scrollables`/TableView isolation issue in an clubs widget test; use the documented serialized command for broad verification until that is resolved.

## 16. Suggested workflow for future Codex prompts

When working in this repo:

1. Read this file.
2. Read the feature’s `domain`, `data`, and `presentation` files together.
3. If a change touches a model used by Cloud Functions, update Dart, run
   `dart tool/generate_firestore_types.dart`, and commit
   `functions/src/shared/firestore.ts`.
4. If a change touches rules-sensitive documents, check `firestore.rules` immediately.
5. Run `build_runner` after annotation/model changes.
6. Prefer updating repository/controller layers instead of pushing Firebase calls directly into widgets.
7. Before committing or opening a PR, follow the branch hygiene rule in
   [`docs/release_operations.md`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/docs/release_operations.md):
   fetch `origin/main`, verify the current branch is not behind it, and do not
   reuse a PR branch after it has been merged.
8. Treat the sharp edges above as real until verified in code or in the deployed Firebase project.

## 17. Non-production directories

These look like support material, not runtime app code:

- `design_handoff_catch_dating_app/`
- `catch-dating-app/`

They may still be useful as design reference, but primary product code lives in `lib/` and `functions/`.

## 18. Firestore error handling conventions

Firebase security rules are the last line of defense — the app must handle rule
rejections gracefully so users (and developers) aren't left guessing.

### Rules

- **Never silently swallow Firestore write errors.** Let `FirebaseException`
  propagate to the UI layer. The `AsyncErrorLogger` ProviderObserver catches
  unhandled errors and reports them to Crashlytics automatically.
- **Use `firestoreErrorMessage()` for user-facing messages.** Located in
  [`lib/core/firestore_error_message.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/firestore_error_message.dart).
  It translates `FirebaseException` codes (`permission-denied`, `unavailable`,
  `deadline-exceeded`, etc.) to human-readable messages. In debug mode it
  appends the Firebase error code so developers can diagnose issues without
  recompiling.
- **Use `withFirestoreErrorContext()` for structured logging.** Located in
  [`lib/core/firestore_error_util.dart`](/Users/suvratgarg/Development/catch-dating-app/catch_dating_app/lib/core/firestore_error_util.dart).
  Wrap Firestore write operations to catch `FirebaseException` and rethrow
  as `FirestoreWriteException` with collection/action context.
- **Use `FieldValue` operations instead of full-document `set()` for partial
  updates.** Reading a document, modifying one field in Dart, and writing it
  back causes a `Timestamp → DateTime → Timestamp` round-trip that loses
  nanosecond precision. The Firestore `diff()` function in the rules sees
  this as a spurious field change and rejects the write. Use
  `transaction.update()` with `FieldValue.arrayUnion` / `FieldValue.increment`
  to touch only the fields that need to change.
- **Mutation-driven UIs should use `firestoreErrorMessage()` for error
  display.** Don't show `error.toString()` to users — it's either raw
  exception text or uselessly truncated. The `ErrorBanner` widget and
  `listenForMutationErrorSnackbar` utility are the right display channels.
- **Firestore rules tests and the contract checker event in CI** on every PR
  that touches rules, schema, or contract files. Keep
  `functions/test/firestore.rules.test.cjs` and `tool/firestore_contract.json`
  in sync with rule changes.
- **Log Firestore write failures to Analytics** via
  `AppAnalytics.logFirestoreWriteFailed()` so permission spikes and quota
  issues are visible in dashboards, not just Crashlytics.

### Common Firestore error codes

| Code | Meaning | User sees |
|------|---------|-----------|
| `permission-denied` | Rules rejected the write | "You don't have permission..." |
| `unavailable` | Network/Firestore down | "We're having trouble connecting..." |
| `deadline-exceeded` | Request timed out | "The request timed out..." |
| `unauthenticated` | Auth token expired/missing | "Please sign in again..." |
| `not-found` | Document doesn't exist | "The data you're looking for..." |
| `resource-exhausted` | Quota exceeded | "We're experiencing high traffic..." |

### Debugging permission-denied in development

1. Check the debug-mode error banner — it shows `[DEBUG Firestore <code>]`
   with the server-side message.
2. Event `cd functions && node --test test/firestore.rules.test.cjs` to
   reproduce the failing operation against the local rules.
3. Use the Firebase Console > Firestore > Rules > Rules Playground to
   simulate the exact document path and auth state.
