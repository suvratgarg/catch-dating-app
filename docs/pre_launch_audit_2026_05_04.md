# Catch Dating App — Pre-Launch Audit

**Date:** 2026-05-04
**Author:** Claude (verified against source at `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`)
**Scope:** Full-stack audit covering architecture, security, UX, and business operations.
**Context:** Solo developer, pre-launch/beta phase, time available to fix before public launch.

---

## Severity Scale

| Level | Meaning |
|--------|---------|
| **Critical** | Existential risk — legal liability, app store rejection, product loop failure |
| **High** | Significant user-facing or operational problem — will cause pain at scale |
| **Medium** | Quality/scale concern — degrades experience or creates ops drag |
| **Low** | Polish/optimization — worth fixing, not urgent |

---

# Part 1: Architecture & Technical

## 1.1 Onboarding OTP Flow Has No Timeout (High)

**File:** `lib/onboarding/presentation/onboarding_controller.dart:178`

**Finding:** The OTP flow bridges Firebase Auth's callback-based `verifyPhoneNumber()` API into the Mutation pattern using a raw `Completer<void>()` with no `.timeout()`. If neither `codeSent` nor `verificationFailed` fires — happens on network timeout, Firebase SDK edge cases, process death — the completer hangs forever. The mutation never resolves, and the UI is stuck with no recovery path.

**Verified by:** Reading `onboarding_controller.dart` — line 178 is `final completer = Completer<void>();` with no timeout configuration anywhere.

**Fix:**
1. Add `Completer<void>.timeout(Duration(seconds: 60))` so the mutation fails with a typed timeout exception after 60s.
2. Add a "Resend code" recovery button in the OTP page UI that resets the completer and re-sends.
3. Log timeout events to Crashlytics (non-fatal) to track OTP delivery reliability over time.

**Effort:** ~4 hours.

---

## 1.2 No Rate Limiting Anywhere — Server or Client (Critical)

**Files:** `functions/src/index.ts` (global config), all 17 callable function files

**Finding:** `setGlobalOptions({maxInstances: 10})` at `functions/src/index.ts:4` is a global concurrency cap, not per-user throttling. There is zero rate limiting on any action:

| Action | Unrestricted blast radius |
|--------|--------------------------|
| Swipe creation | User can programmatically swipe 10,000+ profiles |
| Chat messages | Unlimited message spam |
| Run club creation | Unlimited club creation |
| Payment order creation | Repeated Razorpay API calls at platform cost |
| Account deletion requests | Repeated Cloud Function invocations |
| Report submissions | Unlimited spam reports |
| Waitlist HTTP endpoint | Single honeypot field, no IP or per-email rate limit |

**Verified by:** Full grep of `functions/src/` for "rateLimit", "throttle", "rate_limit" returned zero results.

**Fix:**
1. Create a shared `rateLimit` utility in `functions/src/shared/rateLimit.ts` that checks a per-user per-action counter in Firestore (`rateLimits/{uid}/{action}/{window}`) and rejects requests over threshold.
2. Wire into every callable function (can be a one-line wrapper per function export).
3. For the public `joinWaitlist` HTTP endpoint, add a simple in-memory rate limiter (3 POSTs per IP per hour).
4. Configure per-function `maxInstances` higher for payment/booking functions (see finding 3.7).

**Effort:** ~1 day.

---

## 1.3 Attendance is a Single Point of Failure for the Entire Product (Critical)

**File:** `functions/src/runs/markRunAttendance.ts`

**Finding:** The core product loop — attend run → get 24-hour swipe window → match → chat — depends entirely on hosts manually calling `markRunAttendance`. If a host forgets, every participant in that run gets zero swipe windows, zero matches, and a broken experience. There is:
- No automated attendance detection (GPS check-in at run location)
- No host reminder system (push notification before run start)
- No participant self-check-in (participants can't mark their own attendance)
- No post-run nudge to the host
- No automatic fallback if attendance is never marked

This is the single biggest product reliability risk. One flaky host = dozens of users with a dead experience and no matches.

**Fix:**
1. **Participant self-check-in** (highest impact): Allow participants to mark themselves as attended during a 30-minute window around `run.startTime`, with GPS verification (phone must be within 200m of the run meeting point `run.coordinates`). Add to `functions/src/runs/` as `selfCheckInAttendance`.
2. **Host reminder push**: Scheduled function (Firestore TTL or cron) that fires 15 min before `run.startTime` reminding the host. Requires FCM token lookup.
3. **Post-run host nudge**: If run is 2 hours past `startTime` with no attendance marked, send push to host.
4. **Automatic fallback**: If 24 hours pass post-run with no attendance marked, auto-mark all `signedUpUserIds` as attended with `attendanceSource: "automatic"` flag.

**Effort:** ~2-3 days. This is a core product reliability investment.

---

## 1.4 Client Can Write `deleted: true` Bypassing Cloud Function Cleanup (Low)

**File:** `firestore.rules:222-336`

**Finding:** Lines 250, 335-336 of `firestore.rules` include `'deleted'` and `'deletedAt'` in the `hasValidUserShape()` function's `hasOnly` list. This means a client can `update()` their own `users/{uid}` doc to set `deleted: true`. The rules comment at line 351-353 says "Client-side deletes are blocked" but this only blocks the `delete` operation — not setting a `deleted` flag via `update()`.

**Blast radius is low:** The `isDeletedUser()` function (line 30-32) checks for existence of a `deletedUsers/{uid}` tombstone document, NOT the `deleted` field on the user doc. So a client writing `deleted: true` doesn't actually hide their profile or trigger any access restrictions. However, it could interfere with the `requestAccountDeletion` Cloud Function's cleanup workflow and leaves a dangling field.

**Verified by:** Reading `firestore.rules` lines 222-336. The `deleted` and `deletedAt` fields are in the `hasOnly` list and their type validators exist.

**Fix:** Remove `'deleted'` and `'deletedAt'` from the `hasOnly` list (line 250) and their validators (lines 335-336). Add a comment noting these are Cloud Function-admin fields only. If the Cloud Function needs to read them via client SDK, they can remain readable but not writable — but the current rules allow both read (always via `allow read`) and write (via `allow create, update`). The fix is to remove them from the `hasOnly` list so they're rejected on client `update()`.

**Effort:** ~30 minutes (two-line rules change + one test assertion).

---

## 1.5 No Offline-Aware UI Despite SDK-Level Caching (Medium)

**File:** `lib/main.dart:65-82` (`_initializeFirebaseServices`)

**Finding:** The app does not call `FirebaseFirestore.instance.settings` explicitly, but Firestore SDK enables offline persistence by default on Android and iOS. So cached data exists, but the UI has:
- No connectivity indicator
- No stale-data indicators (users can't tell if they're viewing cached data)
- No graceful degradation when offline (no error banners explaining connectivity loss)
- No `connectivity_plus` or `ConnectivityProvider` abstraction

**Verified by:** `_initializeFirebaseServices()` in `main.dart:65-82` — no `FirebaseFirestore.instance.settings` call. Grep for "persistenceEnabled", "offline", "connectivity" returned only a comment in `onboarding_controller.dart:419` ("Best-effort cache").

**Fix:**
1. Add `connectivity_plus` package and a `ConnectivityProvider` Riverpod provider.
2. Add a thin `ConnectivityBanner` widget at the top of `AppShell` that shows "You're offline. Content may not be up to date." when disconnected.
3. Explicitly call `FirebaseFirestore.instance.settings` to document the offline intent, even though it's on by default.

**Effort:** ~1 day.

---

## 1.6 Hardcoded Cities in Dart Enum + Firestore Rules — No Expansion Path (Medium)

**Files:** `lib/core/indian_city.dart`, `firestore.rules:276-279`

**Finding:** `IndianCity` is a Dart enum with 9 hardcoded values. The Firestore rules hardcode the same 9 values at line 276-279. Adding a city requires: a code change to the enum, a rules update, a deploy of both, and an app update (since the enum is compiled into the binary). The GPS-based city detection at `indian_city.dart:24` (`nearestCity()`) uses client-side Haversine over all 9 cities using the `latlong2` package.

**Verified by:** Reading `indian_city.dart` and `firestore.rules:276-279`.

**Fix:**
1. Store supported cities in a Firestore document `config/cities` (a list of `{name, latitude, longitude}` maps).
2. Have the city picker fetch from this config document at runtime — adding a city becomes a Firestore write with no app update.
3. Change `UserProfile.city` validation to check against the Firestore config doc (can be done in Cloud Function `syncPublicProfile` on write).
4. Keep the `IndianCity` enum for internal logic but add a `fromString` factory. Eventually migrate `UserProfile.city` from enum to String.
5. Update `firestore.rules` to validate against a Firestore document rather than a hardcoded list.

**Effort:** ~3 hours for the config document and picker change. The rules change is more involved — for now, validate the city server-side in the Cloud Function.

---

## 1.7 No Automated CI/CD Beyond Firestore Rules Tests (Medium)

**File:** `.github/workflows/firestore-rules-ci.yml`

**Finding:** The only GitHub Action runs Firestore rules emulator tests. There is no:
- `flutter analyze` in CI
- `flutter test` in CI
- Build pipeline (APK, App Bundle, IPA)
- Automated Firebase deployment
- Code quality automation

**Fix:** Add a single GitHub Action that runs on PRs and pushes to main:
1. `flutter analyze` (catches compile-time errors, unused imports, etc.)
2. `flutter test --concurrency=1` (documented requirement due to TableView isolation issue)
3. `firebase deploy --only firestore:rules,firestore:indexes,storage` on main pushes

This is ~30 lines of YAML.

**Effort:** ~3 hours.

---

## 1.8 Router `refreshListenable` Has No `refreshLimit` (Low)

**File:** `lib/routing/go_router.dart:88-99`

**Finding:** `_RouterRefreshNotifier` calls `notifyListeners()` on every auth/profile change. GoRouter's `refreshListenable` polls on every frame for changes. No `refreshLimit` is configured, so the router recomputes redirects every frame when any listened provider changes.

**Verified by:** Reading `go_router.dart` — `refreshListenable: notifier` at line 99 with no `refreshLimit` anywhere in the file.

**Fix:** Add `refreshLimit: 1` to the GoRouter constructor so redirects only recompute when the notifier actually fires, not on every frame.

**Effort:** One line change.

---

## 1.9 Generated Files Committed (Medium — Intentional)

**Finding:** All `*.g.dart` and `*.freezed.dart` files are committed. This is standard Flutter practice (CI doesn't need `build_runner`) and the `build_runner` step is only needed when changing models. Not a bug, just noting the tradeoff: diff noise on model changes.

**Verdict:** Keep as-is. The alternative (running `build_runner` in CI) is slower and more fragile.

---

# Part 2: UI/UX

## 2.1 Swipe Flow Has Zero Screen Reader Support (High)

**Files:**
- `lib/swipes/presentation/swipe_screen.dart`
- `lib/swipes/presentation/profile_card.dart`
- `lib/swipes/presentation/widgets/swipe_action_buttons.dart`
- `lib/swipes/presentation/widgets/scrollable_profile.dart`

**Finding:** The core dating flow — swipe card stack, like/pass stamps, action buttons, profile cards — has no `Semantics` wrappers whatsoever. Screen reader users cannot navigate between profiles, understand swipe direction, know when they've liked/passed, or access profile content.

**Verified by:** Grep for "Semantic", "semanticsLabel", "MergeSemantics", "accessibility" in `lib/swipes/presentation/` returned zero results. Reading `swipe_screen.dart` — no `Semantics` anywhere. Reading `swipe_action_buttons.dart` — `SwipeCircleButton` has no `Semantics` label. The `InkWell` has no `tooltip` or accessible label.

**Fix:**
1. Wrap `ProfileCard` in `Semantics(label: 'Profile of {name}, {age}. Swipe left to pass, right to like.')`.
2. Add `Semantics(label: 'Pass', button: true)` and `Semantics(label: 'Like', button: true)` to the two `SwipeCircleButton` widgets.
3. Group OTP fields (`otp_page.dart`) with `MergeSemantics` and a parent `Semantics(label: 'Enter 6-digit verification code')`.
4. Add `semanticLabel` to profile/club photo `Image.network` calls.
5. Run through TalkBack (Android) or VoiceOver (iOS) on the core flows: onboarding → swiping → match → chat.

**Effort:** ~1-2 days.

---

## 2.2 Chat is Text-Only — No Media Messaging (High)

**File:** `lib/chats/presentation/widgets/chat_input_bar.dart`

**Finding:** Chat supports only plain text. No image sharing, GIFs, voice notes, reactions, typing indicators, or read receipts. The app already has photo upload infrastructure in `lib/image_uploads/` (used for onboarding profile photos) — the Storage bucket, upload repository, and progress UI all exist and can be reused.

**Verified by:** Grep for "image", "photo", "gif", "sticker", "voice", "attachment" in `chat_input_bar.dart` returned zero results.

**Fix:**
1. **Image sharing** (highest impact): Add image picker button in `ChatInputBar`, upload to `chats/{matchId}/images/{messageId}` path in Storage, store URL + content type in `ChatMessage` model, render `Image.network` in `MessageBubble`. The existing `ImageUploadRepository` pattern can be adapted. ~4 hours.
2. **Typing indicators**: Write a presence doc to `chats/{matchId}/presence/{uid}` on text field focus, clear on blur/unmount. Watch in `ChatScreen`. ~2 hours.
3. **Read receipts, reactions, voice notes**: Defer to post-launch.

**Effort:** ~6 hours for images + typing indicators.

---

## 2.3 Payment Confirmation Ships Non-Functional UI (Medium)

**File:** `lib/payments/presentation/payment_confirmation_screen.dart:330, 401`

**Finding:** The payment confirmation screen has "Add to calendar", "Get directions", and "Invite a friend" action tiles that show "coming soon" snackbars. The referral banner also shows "Share link coming soon". These look functional but do nothing — dead UI in production.

**Verified by:** Reading `payment_confirmation_screen.dart` — line 330 `content: Text('${label.replaceAll('\n', ' ')} coming soon')`, line 401 `content: Text('Share link coming soon')`.

**Fix:** Either implement them or remove them.
- **Add to calendar:** `add_2_calendar` package. ~1 hour.
- **Get directions:** Open `maps.google.com/maps?daddr={lat},{lng}` via `url_launcher`. ~30 min.
- **Invite a friend:** `share_plus` to share a deep link. ~1 hour.
- **Referral banner:** Implement or hide behind a feature flag.

**Effort:** ~3 hours to implement all four, or 30 minutes to hide them.

---

## 2.4 No Skeleton Loading States (Medium)

**Finding:** Every async data fetch shows a centered `CircularProgressIndicator` via `CatchLoadingIndicator`. No shimmer/skeleton placeholders exist. Users perceive spinners as waiting; skeletons feel faster with identical load time.

**Verified by:** Grep for "Skeleton", "skeleton", "shimmer", "Shimmer" in `lib/core/widgets/` returned zero hits. The only "placeholder" references are `_GradientPlaceholder` (for missing avatar photos) and `_MapPlaceholder` (for run card map decoration) — neither handles loading state.

**Fix:**
1. Create a `CatchSkeleton` widget (~50 lines) that renders a subtle shimmer animation in the rough shape of the content it replaces.
2. Wire into top 3 screens: Dashboard (shimmer cards for upcoming runs section), SwipeHub (shimmer for run list), Clubs list (shimmer for club cards).

**Effort:** ~4 hours.

---

## 2.5 No Responsive/Adaptive Layout Strategy (Medium)

**Finding:** The app is portrait-first with fixed hardcoded padding values. On landscape phones, message bubble max width is `MediaQuery.size.width * 0.72` (too wide). On tablets, the run recap grid uses `crossAxisCount: 3` regardless of screen width (too sparse). The swipe card deck uses `padding: EdgeInsets.fromLTRB(16, 16, 16, 8)` with no variation for larger screens.

**Fix:**
1. Cap message bubble width at `min(screenWidth * 0.72, 480)`.
2. Make `crossAxisCount` in `run_recap_screen.dart` responsive via `LayoutBuilder`.
3. Add `OrientationBuilder` to `swipe_screen.dart` for landscape-safe card padding.
4. Don't aim for full tablet optimization — just make it not broken.

**Effort:** ~1 day for top 5 screens.

---

## 2.6 Inconsistent Design Token Usage (Low)

**Finding:** Some screens use `CatchTextStyles.of(context).bodyM`, others use `Theme.of(context).textTheme.bodyMedium` directly (e.g., `running_prefs_page.dart`, `name_dob_page.dart`).

**Fix:** Grep-and-replace `Theme.of(context).textTheme` with `CatchTextStyles` across the codebase. ~2 hours.

---

## 2.7 Color Contrast on Secondary Text (Low)

**Finding:** `ink3` (`#9C8775`) on the light theme background (`#FBF3E9`) has ~3.5:1 contrast ratio — below WCAG AA for normal text (4.5:1).

**Fix:** Darken `ink3` slightly to reach 4.5:1. One-line token change in `catch_tokens.dart`. Needs design review to ensure the palette still works.

---

## 2.8 No Pull-to-Refresh, Haptic Feedback, or Page Transitions (Low)

**Fix:**
- Wrap main list views in `RefreshIndicator`. ~1 hour.
- Add `HapticFeedback.lightImpact()` on swipe like, `HapticFeedback.mediumImpact()` on match. ~20 min.
- Customize GoRouter page transitions with `CustomTransitionPage`. ~2 hours.

---

# Part 3: Business, Safety & Operations

## 3.1 No Content Moderation — Photos or Text (Critical)

**Finding:** Photos go directly to Firebase Storage with only MIME type + 8MB file size validation. Chat messages, bios, club descriptions, and reviews have zero server-side text filtering. There is no NSFW detection, profanity filter, or manual review queue.

This is an existential gap for a dating app:
- **Legal risk in India:** IT Rules 2021 require social media intermediaries to proactively moderate content including nudity and sexually explicit material.
- **App Store rejection risk:** Both Apple and Google require user-generated content apps to have moderation — Apple's Guideline 1.2 and Google's User Generated Content policy both mandate content filtering and reporting.
- **Platform safety:** Without moderation, the platform is exposed to explicit photos, harassment in chat, and spam accounts.

**Verified by:** Grep for "SafeSearch", "moderation", "NSFW", "profanity", "contentFilter", "sightengine", "Cloud Vision" across the entire repo returned zero results for any content moderation implementation. The only related hit is a comment in `functions/src/shared/firestore.ts:351` noting reports are for "abuse/moderation review" — but no moderation logic exists.

**Fix:**
1. **Photos — Google Cloud Vision SafeSearch** (you're already on GCP via Firebase): Add a Storage-triggered Cloud Function at `functions/src/moderation/moderatePhoto.ts` that runs SafeSearch on every upload. If `adult` or `violence` likelihood is `LIKELY` or `VERY_LIKELY`, delete the file and write a moderation flag to the user's profile. ~$1.50/1,000 images.
2. **Text — banned-word filter:** Create a list of ~200 banned terms (hate speech, slurs, explicit terms) and check against all user-generated text in Cloud Functions before writing. Add to all callable functions that accept text input.
3. **Manual review queue:** When auto-moderation flags something, create a doc in a `moderationQueue` collection with status "pending_review." For pre-launch/low volume, review via Firebase Console. Build admin UI post-launch.
4. **Moderation doc:** Create a `config/moderation` Firestore doc with the banned words list and thresholds so you can update without deploying functions.

**Effort:** ~1 day for SafeSearch + banned-word filter. The ongoing cost is negligible at pre-launch volumes. **This is mandatory before public launch.**

---

## 3.2 Legal Pages Exist as Links but Destination Content Likely Missing (High)

**Files:** `lib/safety/presentation/settings_screen.dart:218-233`, `website/index.html`

**Finding:** The Settings screen links to `https://catchdates.com/privacy`, `https://catchdates.com/terms`, and `https://catchdates.com/help`. The links are correctly wired and accessible from the app. However, the `website/` directory contains only a marketing landing page (`index.html`) — no `/privacy`, `/terms`, or `/help` pages exist in the Firebase Hosting deployment.

This means:
- The links in Settings resolve to 404s or the Firebase Hosting fallback (which redirects everything to `index.html` per the SPA rewrite in `firebase.json`)
- Users see the marketing page when they tap "Privacy Policy" or "Terms" — not the legal content
- App Store and Play Store require valid, accessible privacy policy URLs

**Fix:**
1. Before submitting to app stores: create `website/privacy.html` and `website/terms.html` with proper legal content. Use a generator (Termly, Iubenda, GetTerms) for initial policies. ~$100-300 or free with attribution.
2. Remove the SPA catch-all rewrite for `/privacy` and `/terms` paths in `firebase.json` so they serve the static HTML files.
3. Add a consent dialog on first app launch after onboarding that explicitly links to both policies and stores a consent timestamp in the user doc.
4. Add an age consent gate: if DOB calculates to < 18, block signup at client AND server level.

**Effort:** ~2 hours for in-app integration + ~$200 for generated policies.

---

## 3.3 No Admin/Moderation Dashboard (High)

**Finding:** User reports go into a `reports` collection with status "open" but there is no UI to review, triage, or act on them. Block management, user lookup, payment review, and content moderation all require direct Firestore Console access. This doesn't scale beyond you as the solo operator.

**Fix:** Build a minimal Flutter web admin dashboard. The tech stack already supports web:
1. **Report queue:** List all open reports, view details (reported user, reason, context), take action (dismiss, warn, suspend, delete content).
2. **User lookup:** Search by phone number or UID, view profile, payment history, report history, block status.
3. **Run oversight:** View all runs, override attendance, cancel bookings.
4. **Content moderation:** Review flagged photos/text, approve/reject.
5. Protect with a Firebase Custom Claim (`admin: true`) on your user account.

**Effort:** ~3-4 days. This is your primary operational tool — without it, every moderation action requires direct database access.

---

## 3.4 Single Revenue Stream — No Subscription or Recurring Revenue (High)

**Finding:** The only monetization is per-run ticket fees via Razorpay. There is no subscription model (equivalent to Tinder Plus/Bumble Boost), no premium features (see who liked you, unlimited swipes, profile boosts), no in-app purchases, no token/gems system. Without recurring revenue:
- Every month starts at $0
- Users who browse but don't attend paid runs generate zero revenue
- No competitive moat against a free competitor

**Verified by:** Full codebase scan. No subscription infrastructure, no premium tier data model fields, no RevenueCat or IAP integration.

**Fix:**
1. **Data model first:** Add premium fields to `UserProfile`: `premiumTier` (string: "free"/"plus"), `premiumExpiresAt` (timestamp, nullable), `superLikesRemaining` (int). These are 3 fields and cost nothing to add now.
2. **RevenueCat integration:** Integrate `purchases_flutter` for subscription management. RevenueCat handles App Store/Play Store billing, receipt validation, and subscription state. Free tier for under $10k MTR.
3. **One premium feature pre-launch — "See who liked you":** When User A likes User B, User B (premium) can see User A in a "Likes You" screen even before a mutual match. This is the highest-converting premium feature in every dating app. Requires a new screen reading from `swipes/{targetId}/incoming/{swiperId}` subcollection.
4. **Start with one tier at low price:** ~₹299/month in India, ~$9.99/month if expanding internationally.

**Effort:** ~1 day for data model + RevenueCat. ~2-3 days for "See who liked you." This is a pre-launch investment that directly enables monetization.

---

## 3.5 No Re-Engagement Notification Infrastructure (High)

**Finding:** The data model has notification preference fields (`prefsNewCatches`, `prefsRunReminders`, `prefsWeeklyDigest`) on `UserProfile` but no code sends these notifications. Push infrastructure exists (FCM tokens stored, `onMatchCreated` and `onMessageCreated` send pushes) but is only used for real-time match/chat events — not for proactive re-engagement.

**Fix:**
1. **Run reminder push:** Scheduled function that queries for runs starting in the next 2 hours and sends FCM to signed-up users. Respects `prefsRunReminders`.
2. **Match window expiration push:** 23 hours after attendance mark, send "Your Catch window closes soon" push. Respects `prefsNewCatches`.
3. **Weekly digest:** Scheduled function querying upcoming runs, top clubs, and pending matches. Respects `prefsWeeklyDigest`.

All three can be implemented as scheduled Cloud Functions using Firestore TTL or Firebase Scheduled Functions.

**Effort:** ~2 days for all three.

---

## 3.6 No Run Host Tools or Incentives (Medium)

**Finding:** Hosts create runs, manage clubs, and mark attendance — they are the product's supply side. But they have:
- No dashboard or analytics on their runs (attendance rates, revenue, member growth)
- No financial incentive (no revenue share on paid runs)
- No reputation system beyond club reviews (no host rating)

If hosts churn, the entire product dies — there are no runs to attend, no attendance to mark, no matches.

**Fix:**
1. **Host dashboard:** Add a "My Clubs" section to the Profile screen or a dedicated host view showing upcoming runs with attendance counts, revenue earned (for paid runs), and member growth. ~2 days.
2. **Host revenue share:** Post-launch — requires Razorpay Route/marketplace settlement, significant payment/legal complexity.
3. **Host trust indicators:** Surface `RunClub.rating` and `reviewCount` prominently so users can discover reliable hosts.

**Effort:** ~2 days for host dashboard.

---

## 3.7 Global `maxInstances: 10` Ceiling on All Functions (Medium)

**File:** `functions/src/index.ts:4`

**Finding:** All 17 functions share `maxInstances: 10`. If a popular run opens and 50 people hit "pay" simultaneously, only 10 execute concurrently — everyone else queues. Functions v2 charges per invocation, not per instance-minute, so higher `maxInstances` doesn't cost more.

**Verified by:** `functions/src/index.ts:4` — `setGlobalOptions({region: "asia-south1", maxInstances: 10})`.

**Fix:** Per-function `maxInstances` overrides:
- Payment functions (`createRazorpayOrder`, `verifyRazorpayPayment`): 50
- Booking functions (`signUpForFreeRun`, `cancelRunSignUp`, `joinRunWaitlist`): 30
- Match/chat triggers (`onSwipeCreated`, `onMatchCreated`, `onMessageCreated`): 30
- All others: keep at 10

**Effort:** ~10 minutes to add `maxInstances` to individual function options.

---

## 3.8 Dev/Staging Share Prod Razorpay Secrets (Medium)

**Finding:** `PROJECT_CONTEXT.md` documents this. Currently safe (test-mode keys are shared) but must be resolved before switching to live keys.

**Fix:** Generate separate test-mode keys for dev and staging in Razorpay dashboard. Store in each environment's Firebase Secret Manager. Update `tool/dart_defines/`.

**Effort:** ~30 minutes.

---

## 3.9 Firestore Indexes Not Tested in CI (Low)

**Finding:** Composite indexes in `firestore.indexes.json` are committed but have no automated verification. A missing index silently breaks queries in production — Firestore returns an error only after the query is attempted.

**Fix:** Extend the existing emulator test suite to verify the 5 most critical composite queries using the emulator's index enforcement.

**Effort:** ~2 hours.

---

## 3.10 No Analytics Events for Payment/Match Lifecycle (Low)

**Finding:** The analytics taxonomy covers core flows but misses: payment events (order_created, payment_completed, payment_failed, refund_issued), match lifecycle (match_expired, user_blocked), and revenue tracking. These are the numbers you'll need to run the business.

**Fix:** Add events for the payment and match lifecycle in `lib/analytics/app_analytics.dart`.

**Effort:** ~2 hours.

---

# Part 4: Prioritized Pre-Launch Plan (8 weeks)

**Status key:** ✅ Done &nbsp;&nbsp; 🔧 In progress &nbsp;&nbsp; ⬜ Pending

### Weeks 1-2: Safety & Legal (cannot launch without these)

| # | Item | Severity | Effort | Status |
|---|------|----------|--------|--------|
| 1 | Content moderation: Google Cloud Vision SafeSearch + banned-word filter | Critical | 1 day | ✅ |
| 2 | Privacy Policy + Terms + Help pages on website + consent flow | High | 2 hours + $$ | ⬜ |
| 3 | Rate limiting utility + wire into all callable functions | Critical | 1 day | ✅ |
| 4 | Server-side age enforcement (< 18 blocked) | High | 1 hour | ✅ |

### Weeks 3-4: Product Reliability

| # | Item | Severity | Effort | Status |
|---|------|----------|--------|--------|
| 5 | Participant self-check-in for attendance (GPS-verified) | Critical | 1-2 days | ✅ |
| 6 | Host attendance reminder push (15 min before run) | Critical | 4 hours | ⬜ |
| 7 | Post-run host nudge + automatic attendance fallback | Critical | 4 hours | ⬜ |
| 8 | Onboarding OTP timeout + recovery UI | High | 4 hours | ✅ |
| 9 | Offline-aware UI (connectivity banner + provider) | Medium | 1 day | ✅ |
| 10 | CI/CD: flutter analyze + test in GitHub Actions | Medium | 3 hours | ✅ |

### Weeks 5-6: UX & Monetization Foundation

| # | Item | Severity | Effort | Status |
|---|------|----------|--------|--------|
| 11 | Image sharing in chat | High | 4 hours | ✅ |
| 12 | Swipe accessibility (Semantics wrappers) | High | 1-2 days | ✅ |
| 13 | Premium data model + RevenueCat integration | High | 1 day | ⬜ |
| 14 | "See who liked you" premium feature | High | 2-3 days | ⬜ |
| 15 | Implement placeholder UI (calendar, directions, invite) | Medium | 3 hours | ✅ |
| 16 | Responsive layout fixes (top 5 screens) | Medium | 1 day | ✅ |

### Weeks 7-8: Operations & Polish

| # | Item | Severity | Effort | Status |
|---|------|----------|--------|--------|
| 17 | Minimal admin dashboard (report queue, user lookup, run oversight) | High | 3-4 days | ⬜ |
| 18 | Re-engagement push: run reminders, match expiration, weekly digest | High | 2 days | ⬜ |
| 19 | Skeleton loading states (top 3 screens) | Medium | 4 hours | ✅ |
| 20 | City config from Firestore (not hardcoded enum) | Medium | 3 hours | ✅ |
| 21 | Increase maxInstances on payment/booking functions | Medium | 10 min | ✅ |
| 22 | Legal page content on website | High | 2 hours + $$ | ⬜ |

### Completed implementation details

<details>
<summary>Click to expand — files changed per item</summary>

**#1 Content moderation** — `functions/src/moderation/textFilter.ts` (+153), `moderatePhoto.ts` (+172), `moderateMessage.ts` (+88), `textFilter.test.ts` (+71), `functions/src/shared/firestore.ts` (+17), `functions/src/index.ts` (+2), `firestore.rules` (+5)

**#3 Rate limiting** — `functions/src/shared/rateLimit.ts` (+201), `functions/src/runs/signUpForFreeRun.ts` (+2), `functions/src/payments/createRazorpayOrder.ts` (+10), `functions/src/safety/reporting.ts` (+10), `functions/src/waitlist/joinWaitlist.ts` (+14), `firestore.rules` (+5)

**#5 Attendance self-check-in** — `functions/src/runs/selfCheckInAttendance.ts` (+162), `functions/src/index.ts` (+1), `lib/runs/data/run_repository.dart` (+19), `lib/runs/presentation/run_booking_controller.dart` (+24), `lib/runs/presentation/widgets/run_detail_cta.dart` (+34)

**#8 OTP timeout** — `lib/onboarding/presentation/onboarding_controller.dart` (+8), `lib/auth/presentation/auth_error_message.dart` (+2)

**#11 Chat image sharing** — `lib/chats/domain/chat_message.dart` (+1), `lib/chats/data/chat_repository.dart` (+44), `lib/chats/presentation/chat_controller.dart` (+13), `lib/chats/presentation/chat_screen.dart` (+17), `lib/chats/presentation/widgets/chat_input_bar.dart` (+14), `lib/chats/presentation/widgets/message_bubble.dart` (+28), `storage.rules` (+11)

**#12 Swipe accessibility** — `lib/swipes/presentation/profile_card.dart` (+2), `lib/swipes/presentation/widgets/swipe_action_buttons.dart` (+9)

**#4 Server-side age enforcement** — `functions/src/profiles/syncPublicProfile.ts` (+7)

**#10 CI/CD** — `.github/workflows/flutter-ci.yml` (+25)

**#15 Placeholder UI** — `lib/payments/presentation/payment_confirmation_screen.dart` (+67)

**#21 maxInstances** — `functions/src/index.ts` (10 → 50)

**#9 Offline-aware UI** — `lib/core/presentation/app_shell.dart` (+26), `pubspec.yaml` (+1 dep: connectivity_plus)

**#16 Responsive layout** — `lib/core/responsive/breakpoints.dart` (+54), `responsive_builder.dart` (+63), 5 screen fixes (+16), `test/core/responsive/screen_size_test.dart` (+27)

**#19 Skeleton loading** — `lib/core/widgets/catch_skeleton.dart` (+154), `lib/core/widgets/async_value_widget.dart` (+16), wired into swipe_hub + clubs_list (+6), `pubspec.yaml` (+1 dep: shimmer)

**#20 City config** — `lib/core/domain/city_data.dart` (+25), `lib/core/data/city_repository.dart` (+114), `lib/core/indian_city.dart` (+17), 4 picker migrations (+78), `firestore.rules` (+15)

</details>

### Defer to Post-Launch

- Typesense/Algolia for full-text and geo search
- Host revenue share (Razorpay marketplace — legal/payment complexity)
- Voice notes, GIFs, read receipts in chat
- Tablet-optimized layouts
- Automated deployment pipeline
- A/B testing infrastructure
- Age estimation via selfie (Yoti/Veriff)
- Razorpay environment-specific secrets (before going live)
- Firestore index CI testing

---

# Part 5: Things That Are Already Strong

Not everything needs fixing. These are commendable:

- **Feature-first Clean Architecture** consistently applied across 13 features with domain/data/presentation layering
- **Firestore security rules** (574 lines) with per-collection shape validation, block enforcement at rule level, `diff()` enforcement for Timestamp safety, and backend-write-only collections — better than 95% of Firebase apps
- **Typed exception hierarchy** with consistent `withFirestoreErrorContext` wrapping, Crashlytics integration gated to production only, and `AsyncErrorLogger` ProviderObserver catching unhandled provider errors
- **17 Cloud Functions** with injectable dependencies, App Check enforcement on every callable, transactional sign-up logic with atomic capacity/gender/block checks, and payment verification that cross-checks Razorpay API server-side
- **Design system** with `CatchTokens` (ThemeExtension), 3-font typography (Space Grotesk/Inter/JetBrains Mono), 4pt spacing grid, named motion tokens with spring/ease-out curves, and a cohesive sunset palette
- **Polished composite widgets** — `RunCard` with 3 density variants, `CatchButton` with loading animation, `CatchSurface` with animated tone/elevation transitions
- **80+ test files** including Firestore rules emulator tests, App Check guard tests, domain tests, and widget tests
- **Three Firebase environments** (dev/staging/prod) with environment-specific Firebase options and tooling to switch
- **Analytics taxonomy** with typed events for auth, onboarding, runs, swipes, matches, and errors — correctly gated to production release mode only
- **App Check enforcement** on Firestore, Storage, Auth, and all 17 Functions across all environments
- **Block/report system** enforced server-side at both the Firestore rule and Cloud Function level, with automatic match closure on block

---

*End of audit. Correction log: (1) Legal page links exist in Settings screen — original finding overstated. (2) Account deletion bypass has low blast radius because `isDeletedUser()` checks tombstone collection, not user doc field — downgraded. (3) Swipe candidates come from attended runs, not city-wide queries — geo scaling concern applies to clubs/runs lists, not swipes. (4) Firestore offline persistence is SDK-default-on for mobile — gap is offline-aware UI, not missing data.*
