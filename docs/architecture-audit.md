# Catch Dating App — State Management Architecture Audit

**Date:** 2026-05-03
**Last updated:** 2026-05-03
**Scope:** Complete mapping of all Riverpod providers, repositories, controllers, mutations, GoRouter routing, caching behavior, Firestore read patterns, and architectural consistency evaluation.

## Changelog

| Date | Change | Status |
|------|--------|--------|
| 2026-05-03 | Fixed raw `e.toString()` in `run_detail_screen.dart` — now uses `firestoreErrorMessage(e)` | ✅ |
| 2026-05-03 | Merged `ErrorBanner` + `CatchErrorBanner` into single canonical `ErrorBanner` with `onRetry` | ✅ |
| 2026-05-03 | Deleted dead `showSnackbarOnError` code | ✅ |
| 2026-05-03 | Converted 4 manual providers to `@riverpod` codegen (100% codegen coverage) | ✅ |
| 2026-05-03 | Added `ref.invalidateSelf()` to `OnboardingController.complete()` | ✅ |
| 2026-05-03 | Standardized error handling: `withFirestoreErrorContext` now wraps ~19 methods across 5 repos; added `PermissionException`, `NetworkException` to exception hierarchy | ✅ |
| 2026-05-03 | Added `cause` property to `AppException` for debugging | ✅ |
| 2026-05-03 | `requireSignedInUid` now throws `SignInRequiredException` instead of `StateError` | ✅ |
| 2026-05-03 | 6 silent error catch sites now log via `debugPrint('[ERROR] ...')` | ✅ |
| 2026-05-03 | Structured logging with `LogLevel` enum, `ConsoleCrashReporter` web fallback, `errorLoggerProvider` | ✅ |
| 2026-05-03 | `AsyncErrorLogger` fires `logFirestoreWriteFailed` analytics, Crashlytics user ID synced | ✅ |
| 2026-05-03 | Pre-warmed clubs list stream from AppShell (no loading flash on Clubs tab) | ✅ |
| 2026-05-03 | Documented four controller/view-model patterns with decision guide | ✅ |
| 2026-05-03 | Cache invalidation on sign-out (`userProfileStreamProvider` invalidated) | ✅ |

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Complete Provider Inventory](#complete-provider-inventory)
3. [Provider Dependency Graph](#provider-dependency-graph)
4. [Repository Layer Analysis](#repository-layer-analysis)
5. [Controller & Mutation Pattern Analysis](#controller--mutation-pattern-analysis)
6. [GoRouter & Auth Flow](#gorouter--auth-flow)
7. [Caching & KeepAlive Analysis](#caching--keepalive-analysis)
8. [Firestore Read Analysis](#firestore-read-analysis)
9. [Data Availability Guarantees](#data-availability-guarantees)
10. [Loading Indicator Map](#loading-indicator-map)
11. [Architecture Consistency Evaluation](#architecture-consistency-evaluation)
12. [Recommendations](#recommendations)
13. [How to Improve Future Queries](#how-to-improve-future-queries)

---

## Executive Summary

The app has **70 Riverpod providers** across 293 Dart source files, organized in a clean feature-first structure (`domain/` → `data/` → `presentation/`). The architecture follows a **repository pattern** where repositories wrap Firebase services and expose typed reads/writes, with **Riverpod providers** bridging repositories to the UI.

**Strengths:**
- Consistent feature-folder structure across all 10+ feature areas
- Repository pattern uniformly applied — no direct Firebase calls from widgets
- Auth routing with `?from=` resume logic is well-designed
- Use of `FieldValue` operations for partial Firestore updates (avoids timestamp round-trip bugs)
- Centralized error message translation (`firestoreErrorMessage`, `authErrorMessage`)
- `AsyncErrorLogger` ProviderObserver catches all provider-level errors globally

**Key concerns:**
- Inconsistent error handling: `withFirestoreErrorContext` used in only 1 of 16 repository write methods
- Mixed patterns for stateful logic: some use freezed state + keepAlive Notifier, others use stateless controllers + Mutations, others use AsyncNotifier
- The `userProfileStreamProvider` IS always available once auth resolves — this assumption is correct
- But many screens re-fetch or re-watch data that flows through the app shell anyway
- 34 keepAlive providers create a large memory footprint
- No structured cache invalidation strategy beyond autoDispose

---

## Complete Provider Inventory

### 1. Firebase Infrastructure (5 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 1 | `firebaseFirestoreProvider` | `Provider<FirebaseFirestore>` | Yes | — | `FirebaseFirestore.instance` |
| 2 | `firebaseAuthProvider` | `Provider<FirebaseAuth>` | Yes | — | `FirebaseAuth.instance` |
| 3 | `firebaseStorageProvider` | `Provider<FirebaseStorage>` | Yes | — | `FirebaseStorage.instance` |
| 4 | `firebaseFunctionsProvider` | `Provider<FirebaseFunctions>` | Yes | — | `FirebaseFunctions.instanceFor(region: 'asia-south1')` |
| 5 | `firebaseRemoteConfigProvider` | `Provider<FirebaseRemoteConfig>` | Yes | — | `FirebaseRemoteConfig.instance` |

**File:** `lib/core/firebase_providers.dart:12-27`

All five are pure singleton wrappers. They never dispose. They are **lazily initialized** — the first `ref.watch/read` triggers the `Firebase.instance` accessor, but that accessor is synchronous and returns an already-initialized singleton (Firebase was initialized in `main()` before `runApp`).

---

### 2. Auth Providers (3 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 6 | `authRepositoryProvider` | `Provider<AuthRepository>` | Yes | `firebaseAuthProvider` | `AuthRepository` |
| 7 | `authStateChangesProvider` | `StreamProvider<User?>` | Yes | `authRepositoryProvider` | `Stream<User?>` |
| 8 | `uidProvider` | `StreamProvider<String?>` | Yes | `authRepositoryProvider` | `Stream<String?>` |

**File:** `lib/auth/auth_repository.dart:56-66`

`uidProvider` is the **root of the auth dependency tree**. It emits:
- `AsyncLoading` — during initial Firebase Auth resolution (~100-500ms)
- `AsyncData(null)` — user signed out
- `AsyncData("abc123")` — user signed in

This provider **never emits an error** in practice (Firebase Auth streams don't error from normal auth state changes). It is consumed as `AsyncValue<String?>` everywhere.

---

### 3. User Profile Providers (2 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 9 | `userProfileRepositoryProvider` | `Provider<UserProfileRepository>` | Yes | `firebaseFirestoreProvider` | `UserProfileRepository` |
| 10 | `userProfileStreamProvider` | `StreamProvider<UserProfile?>` | Yes | `uidProvider`, `userProfileRepositoryProvider` | `Stream<UserProfile?>` |

**File:** `lib/user_profile/data/user_profile_repository.dart:76-93`

**Critical behavior:**

```
userProfileStreamProvider
  → watches uidProvider
    → if uid is AsyncLoading: emits Stream.empty() (no value yet)
    → if uid is AsyncData(null): starts watching users/{null} → emits Stream.value(null)
    → if uid is AsyncData("abc123"): starts watching users/abc123 → real-time Firestore snapshot
```

This means:
- When signed out: emits `null` immediately
- When signed in with full profile: emits `UserProfile` and stays live (re-emits on any Firestore change)
- **Once auth resolves, this provider is always available** — your assumption is correct
- The stream never completes; it stays alive until provider disposal (which never happens because keepAlive)

---

### 4. Core Infrastructure Providers (5 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 11 | `deviceLocationProvider` | `AsyncNotifierProvider<DeviceLocation, LatLng?>` | Yes | — (uses Geolocator directly) | `Future<LatLng?>` |
| 12 | `locationInitializerProvider` | `AsyncNotifierProvider<LocationInitializer, void>` | Yes | `userProfileStreamProvider`, `deviceLocationProvider`, `userProfileRepositoryProvider` | `Future<void>` |
| 13 | `fcmServiceProvider` | `Provider<FcmService>` | Yes | `FirebaseFirestore.instance` (direct) | `FcmService` |
| 14 | `appAnalyticsProvider` | `Provider<AppAnalytics>` | No | — (overridden in main) | `AppAnalytics` |
| 15 | `appVersionConfigProvider` | `Provider<AppVersionConfig>` | Yes | `firebaseRemoteConfigProvider` | `AppVersionConfig` |
| 16 | `appPackageInfoProvider` | `FutureProvider<({String version, String buildNumber})>` | Yes | — | `Future<record>` |
| 17 | `forceUpdateRequiredProvider` | `Provider<AsyncValue<bool>>` | Yes | `appVersionConfigProvider`, `appPackageInfoProvider` | `AsyncValue<bool>` |

**Files:** `lib/core/device_location.dart`, `lib/core/location_service.dart`, `lib/core/fcm_service.dart`, `lib/analytics/app_analytics.dart`, `lib/force_update/data/`

Key behavioral notes:
- `deviceLocationProvider` caches location for the session (fetches once, never re-fetches unless invalidated)
- `locationInitializerProvider` writes lat/lng to Firestore on first launch, uses `_collected` guard to prevent re-execution
- `forceUpdateRequiredProvider` blocks the entire UI tree until it resolves (watch in `app.dart`)

---

### 5. Run Clubs Providers (7 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 18 | `runClubsRepositoryProvider` | `Provider<RunClubsRepository>` | Yes | `firebaseFirestoreProvider` | `RunClubsRepository` |
| 19 | `watchRunClubProvider` | `StreamProvider<RunClub?>` (family) | No | `runClubsRepositoryProvider` | `Stream<RunClub?>` |
| 20 | `watchRunClubsByLocationProvider` | `StreamProvider<List<RunClub>>` (family) | No | `runClubsRepositoryProvider` | `Stream<List<RunClub>>` |
| 21 | `watchRunClubsByLocationSortedByRatingProvider` | `StreamProvider<List<RunClub>>` (family) | No | `runClubsRepositoryProvider` | `Stream<List<RunClub>>` |
| 22 | `fetchRunClubProvider` | `FutureProvider<RunClub?>` (family) | No | `runClubsRepositoryProvider` | `Future<RunClub?>` |
| 23 | `selectedRunClubCityProvider` | `NotifierProvider<SelectedRunClubCity, IndianCity>` | Yes | — | `IndianCity` |
| 24 | `runClubSearchQueryProvider` | `NotifierProvider<RunClubSearchQuery, String>` | Yes | — | `String` |

**File:** `lib/run_clubs/data/run_clubs_repository.dart`, `lib/run_clubs/presentation/list/run_clubs_list_view_model.dart`

Note: `watchRunClubProvider` and `watchRunClubsByLocationProvider` are **autoDispose**. They start listening when first watched and stop when the last watcher is removed (typically when the screen is popped). This means navigating Club List → Club Detail → back will **re-establish the list stream**, causing a brief loading flash.

---

### 6. Runs Providers (10 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 25 | `runRepositoryProvider` | `Provider<RunRepository>` | Yes | `firebaseFirestoreProvider`, `firebaseFunctionsProvider` | `RunRepository` |
| 26 | `watchRunProvider` | `StreamProvider<Run?>` (family) | No | `runRepositoryProvider` | `Stream<Run?>` |
| 27 | `runsForClubProvider` | `StreamProvider<List<Run>>` (family) | No | `runRepositoryProvider` | `Stream<List<Run>>` |
| 28 | `attendedRunsProvider` | `StreamProvider<List<Run>>` (family) | No | `runRepositoryProvider` | `Stream<List<Run>>` |
| 29 | `signedUpRunsProvider` | `StreamProvider<List<Run>>` (family) | No | `runRepositoryProvider` | `Stream<List<Run>>` |
| 30 | `recommendedRunsProvider` | `FutureProvider<List<Run>>` (family) | No | `runRepositoryProvider` | `Future<List<Run>>` |
| 31 | `runDraftRepositoryProvider` | `Provider<RunDraftRepository>` | Yes | — (uses SharedPreferences) | `RunDraftRepository` |
| 32 | `clubRunDraftsProvider` | `FutureProvider<List<RunDraft>>` (family) | No | `runDraftRepositoryProvider` | `Future<List<RunDraft>>` |
| 33 | `runnerProfilesProvider` | `FutureProvider<Map<String, record>>` (family) | No | `publicProfileRepositoryProvider` | `Future<Map<String, record>>` |
| 34 | `runDetailViewModelProvider` | `Provider<AsyncValue<RunDetailViewModel?>>` (family) | No | `watchRunProvider`, `userProfileStreamProvider`, `watchReviewsForRunProvider` | `AsyncValue<RunDetailViewModel?>` |

**Files:** `lib/runs/data/run_repository.dart`, `lib/runs/data/run_draft_repository.dart`, `lib/runs/presentation/run_detail_view_model.dart`, `lib/runs/presentation/widgets/who_is_running.dart`

`recommendedRunsProvider` uses a **one-time fetch** (not a stream) — it won't update if new runs are added during the session.

---

### 7. Swipe Providers (4 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 35 | `swipeRepositoryProvider` | `Provider<SwipeRepository>` | Yes | `firebaseFirestoreProvider` | `SwipeRepository` |
| 36 | `swipeCandidateRepositoryProvider` | `Provider<SwipeCandidateRepository>` | Yes | `runRepositoryProvider`, `swipeRepositoryProvider`, `publicProfileRepositoryProvider`, `safetyRepositoryProvider` | `SwipeCandidateRepository` |
| 37 | `swipeQueueNotifierProvider` | `AsyncNotifierProvider<SwipeQueueNotifier, List<PublicProfile>>` (family) | No | `userProfileStreamProvider`, `swipeCandidateRepositoryProvider`, `authRepositoryProvider`, `swipeRepositoryProvider` | `AsyncValue<List<PublicProfile>>` |
| 38 | `publicProfileRepositoryProvider` | `Provider<PublicProfileRepository>` | Yes | `firebaseFirestoreProvider` | `PublicProfileRepository` |
| 39 | `publicProfileProvider` | `StreamProvider<PublicProfile?>` (family) | No | `publicProfileRepositoryProvider` | `Stream<PublicProfile?>` |

**Files:** `lib/swipes/data/`, `lib/swipes/presentation/swipe_queue_notifier.dart`, `lib/public_profile/data/public_profile_repository.dart`

`swipeCandidateRepository` is a **composed repository** — it doesn't access Firestore directly but orchestrates 4 sub-repositories to assemble candidate profiles. This is a good pattern.

---

### 8. Match & Chat Providers (6 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 40 | `matchRepositoryProvider` | `Provider<MatchRepository>` | Yes | `firebaseFirestoreProvider` | `MatchRepository` |
| 41 | `matchesForUserProvider` | `StreamProvider<List<Match>>` (family) | No | `matchRepositoryProvider` | `Stream<List<Match>>` |
| 42 | `matchStreamProvider` | `StreamProvider.autoDispose.family<Match?, String>` | No | `matchRepositoryProvider` | `Stream<Match?>` |
| 43 | `totalUnreadCountProvider` | `Provider<int>` (family) | No | `matchesForUserProvider` | `int` |
| 44 | `chatRepositoryProvider` | `Provider<ChatRepository>` | Yes | `firebaseFirestoreProvider` | `ChatRepository` |
| 45 | `chatMessagesProvider` | `StreamProvider<List<ChatMessage>>` (family) | No | `chatRepositoryProvider` | `Stream<List<ChatMessage>>` |

**Files:** `lib/matches/data/match_repository.dart`, `lib/chats/data/chat_repository.dart`

`matchesForUserProvider` uses `Stream.multi` with **two parallel queries** (user is user1 OR user is user2) merged into one stream. This is a Firestore limitation workaround (no OR queries).

---

### 9. Reviews Providers (5 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 46 | `reviewsRepositoryProvider` | `Provider<ReviewsRepository>` | Yes | `firebaseFirestoreProvider` | `ReviewsRepository` |
| 47 | `watchReviewsForClubProvider` | `StreamProvider<List<Review>>` (family) | No | `reviewsRepositoryProvider` | `Stream<List<Review>>` |
| 48 | `watchReviewsForRunProvider` | `StreamProvider<List<Review>>` (family) | No | `reviewsRepositoryProvider` | `Stream<List<Review>>` |
| 49 | `watchReviewsByUserProvider` | `StreamProvider<List<Review>>` (family) | No | `reviewsRepositoryProvider` | `Stream<List<Review>>` |
| 50 | `watchUserReviewForClubProvider` | `StreamProvider<Review?>` (family) | No | `reviewsRepositoryProvider` | `Stream<Review?>` |

**File:** `lib/reviews/data/reviews_repository.dart`

---

### 10. Payment Providers (3 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 51 | `paymentRepositoryProvider` | `Provider<PaymentRepository>` | Yes | `firebaseFunctionsProvider` | `PaymentRepository` |
| 52 | `paymentHistoryRepositoryProvider` | `Provider<PaymentHistoryRepository>` | Yes | `firebaseFirestoreProvider` | `PaymentHistoryRepository` |
| 53 | `paymentsForUserProvider` | `StreamProvider<List<Payment>>` (family) | No | `paymentHistoryRepositoryProvider` | `Stream<List<Payment>>` |

**Files:** `lib/payments/data/payment_repository.dart`, `lib/payments/data/payment_history_repository.dart`

---

### 11. Safety Providers (2 providers) — Manual (non-codegen)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 54 | `safetyRepositoryProvider` | `Provider<SafetyRepository>` | No | `firebaseFirestoreProvider`, `firebaseFunctionsProvider`, `firebaseAuthProvider` | `SafetyRepository` |
| 55 | `blockedUsersProvider` | `StreamProvider.autoDispose<List<BlockedUser>>` | No | `uidProvider`, `safetyRepositoryProvider` | `Stream<List<BlockedUser>>` |

**File:** `lib/safety/data/safety_repository.dart`

These are the only providers not using `@riverpod` codegen. Both use manual `final provider = Provider(...)` declarations. They lack keepAlive so they are autoDispose by default.

---

### 12. Onboarding Providers (2 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 56 | `onboardingDraftRepositoryProvider` | `Provider<OnboardingDraftRepository>` | Yes | `firebaseFirestoreProvider` | `OnboardingDraftRepository` |
| 57 | `onboardingControllerProvider` | `NotifierProvider<OnboardingController, OnboardingData>` | Yes | `authRepositoryProvider`, `userProfileStreamProvider`, `userProfileRepositoryProvider`, `onboardingDraftRepositoryProvider`, `uidProvider` | `OnboardingData` |

**File:** `lib/onboarding/data/onboarding_draft_repository.dart`, `lib/onboarding/presentation/onboarding_controller.dart`

`onboardingControllerProvider` is the only stateful controller with `keepAlive: true`. This is necessary because onboarding is a multi-step flow where state must survive navigation between steps. The state is freed when the user completes onboarding and the router redirects away (though technically the provider stays alive until the app is killed since it's keepAlive).

---

### 13. Image Upload Providers (2 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 58 | `imageUploadRepositoryProvider` | `Provider<ImageUploadRepository>` | Yes | `firebaseStorageProvider` | `ImageUploadRepository` |
| 59 | `photoUploadControllerProvider` | `NotifierProvider<PhotoUploadController, PhotoUploadState>` | No | `imageUploadRepositoryProvider`, `userProfileRepositoryProvider` | `PhotoUploadState` |

**File:** `lib/image_uploads/data/image_upload_repository.dart`, `lib/image_uploads/presentation/photo_upload_controller.dart`

---

### 14. Dashboard Providers (3 providers)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 60 | `dashboardRecommendedRunsProvider` | `FutureProvider.autoDispose.family<List<Run>, DashboardRecommendationsQuery>` | No | `runRepositoryProvider` | `Future<List<Run>>` |
| 61 | `filteredRunClubsProvider` | `Provider<AsyncValue<List<RunClub>>>` | No | `selectedRunClubCityProvider`, `runClubSearchQueryProvider`, `watchRunClubsByLocationProvider` | `AsyncValue<List<RunClub>>` |
| 62 | `runClubsListViewModelProvider` | `Provider<AsyncValue<RunClubsListViewModel>>` | No | `userProfileStreamProvider`, `filteredRunClubsProvider` | `AsyncValue<RunClubsListViewModel>` |
| 63 | `runClubDetailViewModelProvider` | `Provider<AsyncValue<RunClubDetailViewModel?>>` (family) | No | `watchRunClubProvider`, `runsForClubProvider`, `watchReviewsForClubProvider`, `userProfileStreamProvider`, `uidProvider` | `AsyncValue<RunClubDetailViewModel?>` |

**File:** `lib/dashboard/presentation/dashboard_recommendations_provider.dart`, `lib/run_clubs/presentation/list/run_clubs_list_view_model.dart`, `lib/run_clubs/presentation/detail/run_club_detail_view_model.dart`

---

### 15. Controllers — Stateless Mutation Hosts (6 providers)

| # | Provider | Type | keepAlive | Depends On | Mutations |
|---|----------|------|-----------|------------|-----------|
| 64 | `createRunControllerProvider` | `NotifierProvider<CreateRunController, void>` | No | `runRepositoryProvider` | `submitMutation` (`Mutation<Run>`) |
| 65 | `runBookingControllerProvider` | `NotifierProvider<RunBookingController, void>` | No | `paymentRepositoryProvider`, `runRepositoryProvider` | `book`, `cancel`, `joinWaitlist`, `leaveWaitlist`, `markAttendance` (all `Mutation<void>`) |
| 66 | `runClubMembershipControllerProvider` | `NotifierProvider<RunClubMembershipController, void>` | No | `runClubsRepositoryProvider` | `join`, `leave` (both `Mutation<void>`) |
| 67 | `runClubsListControllerProvider` | `NotifierProvider<RunClubsListController, void>` | No | `runClubsRepositoryProvider` | `join` (`Mutation<void>`) |
| 68 | `createRunClubControllerProvider` | `NotifierProvider<CreateRunClubController, void>` | No | `imageUploadRepositoryProvider`, `runClubsRepositoryProvider`, `userProfileStreamProvider` | `submit` (`Mutation<void>`) |
| 69 | `writeReviewControllerProvider` | `NotifierProvider<WriteReviewController, void>` | No | `reviewsRepositoryProvider` | `submit`, `delete` (both `Mutation<void>`) |

---

### 16. Router Provider (1 provider)

| # | Provider | Type | keepAlive | Depends On | Returns |
|---|----------|------|-----------|------------|---------|
| 70 | `goRouterProvider` | `Provider<GoRouter>` | Yes | `appAnalyticsProvider`, `uidProvider` (listened), `userProfileStreamProvider` (listened) | `GoRouter` |

**File:** `lib/routing/go_router.dart:85-338`

---

### Summary Statistics

| Category | Count |
|----------|-------|
| **Total providers** | 70 |
| **keepAlive: true** | 34 |
| **autoDispose (no keepAlive)** | 36 |
| **Codegen (`@riverpod` / `@Riverpod`)** | 66 |
| **Manual (no codegen)** | 4 (`safetyRepositoryProvider`, `blockedUsersProvider`, `matchStreamProvider`, `appAnalyticsProvider`) |
| **StreamProvider (real-time Firestore)** | 19 |
| **FutureProvider (one-time fetch)** | 6 |
| **Provider<T> (sync or computed)** | 30 |
| **NotifierProvider (stateful)** | 8 |
| **AsyncNotifierProvider** | 4 |
| **Repository wrappers** | 15 |
| **ViewModel/computed providers** | 5 |
| **Mutation hosts (stateless controllers)** | 6 |

---

## Provider Dependency Graph

### Layer 0 — Firebase Singletons (no dependencies)
```
firebaseFirestore  firebaseAuth  firebaseStorage  firebaseFunctions  firebaseRemoteConfig
```

### Layer 1 — Repository Providers
```
authRepository ──────────────── firebaseAuth
userProfileRepository ───────── firebaseFirestore
runClubsRepository ──────────── firebaseFirestore
runRepository ───────────────── firebaseFirestore + firebaseFunctions
runDraftRepository ──────────── (SharedPreferences, no Firebase)
swipeRepository ─────────────── firebaseFirestore
matchRepository ─────────────── firebaseFirestore
chatRepository ──────────────── firebaseFirestore
paymentRepository ───────────── firebaseFunctions
paymentHistoryRepository ────── firebaseFirestore
reviewsRepository ───────────── firebaseFirestore
publicProfileRepository ─────── firebaseFirestore
imageUploadRepository ───────── firebaseStorage
onboardingDraftRepository ───── firebaseFirestore
safetyRepository ────────────── firebaseFirestore + firebaseFunctions + firebaseAuth
```

### Layer 2 — Stream Providers (real-time data)
```
authStateChanges ─────────────── authRepository
uidProvider ──────────────────── authRepository
userProfileStream ────────────── uidProvider + userProfileRepository
watchRunClub ─────────────────── runClubsRepository (family: String)
watchRunClubsByLocation ──────── runClubsRepository (family: IndianCity)
watchRun ─────────────────────── runRepository (family: String)
runsForClub ──────────────────── runRepository (family: String)
attendedRuns ─────────────────── runRepository (family: String)
signedUpRuns ─────────────────── runRepository (family: String)
matchesForUser ───────────────── matchRepository (family: String)
chatMessages ─────────────────── chatRepository (family: String)
paymentsForUser ──────────────── paymentHistoryRepository (family: String)
watchReviewsForClub ──────────── reviewsRepository (family: String)
watchReviewsForRun ───────────── reviewsRepository (family: String)
watchReviewsByUser ───────────── reviewsRepository (family: String)
watchUserReviewForClub ───────── reviewsRepository (family: named params)
publicProfile ────────────────── publicProfileRepository (family: String)
blockedUsers ─────────────────── uidProvider + safetyRepository
```

### Layer 3 — Computed Providers & ViewModels
```
runDetailViewModel ───────────── watchRun + userProfileStream + watchReviewsForRun
runClubDetailViewModel ───────── watchRunClub + runsForClub + watchReviewsForClub + userProfileStream + uidProvider
runClubsListViewModel ────────── userProfileStream + filteredRunClubs
filteredRunClubs ─────────────── selectedRunClubCity + runClubSearchQuery + watchRunClubsByLocation
totalUnreadCount ─────────────── matchesForUser
dashboardRecommendedRuns ─────── runRepository
swipeCandidateRepository ─────── runRepository + swipeRepository + publicProfileRepository + safetyRepository
```

### Layer 4 — Controllers & Mutations
```
onboardingController ─────────── authRepository + userProfileStream + userProfileRepository + onboardingDraftRepository + uidProvider
createRunController ──────────── runRepository
runBookingController ─────────── paymentRepository + runRepository
runClubMembershipController ──── runClubsRepository
runClubsListController ───────── runClubsRepository
createRunClubController ──────── imageUploadRepository + runClubsRepository + userProfileStream
writeReviewController ────────── reviewsRepository
swipeQueueNotifier ───────────── userProfileStream + swipeCandidateRepository + authRepository + swipeRepository
photoUploadController ────────── imageUploadRepository + userProfileRepository
```

### Layer 5 — Router
```
goRouter ─── listens: uidProvider + userProfileStream
         ─── reads: appAnalytics
```

### Layer 6 — App Shell
```
app.dart ─── watches: goRouterProvider + forceUpdateRequiredProvider + locationInitializerProvider
appShell ─── watches: uidProvider + totalUnreadCount
```

---

## Repository Layer Analysis

### Pattern Adherence

All 15 repositories follow the same constructor pattern:
```dart
class XxxRepository {
  const XxxRepository(this._db);  // or this._functions, this._storage, etc.
  final FirebaseFirestore _db;     // injected dependency
  static const _collectionPath = 'xxx';  // collection path constant
  // ... methods
}
```

All are wrapped in a `@Riverpod(keepAlive: true)` provider that injects the Firebase dependency. This is **consistent and clean**.

### Method Classification

| Repository | Stream (real-time) | Future (one-shot read) | Write | Cloud Function |
|------------|-------------------|----------------------|-------|----------------|
| AuthRepository | `authStateChanges()` | — | `signIn`, `signOut` | — |
| UserProfileRepository | `watchUserProfile()` | `fetchUserProfile()` | `set`, `update`, `updatePhotoUrls`, `setProfileComplete`, `saveRun`, `unsaveRun` | — |
| RunClubsRepository | `watchRunClub()`, `watchRunClubsByLocation()` × 2 | `fetchRunClub()` | `create`, `update`, `delete`, `joinClub`, `leaveClub` | — |
| RunRepository | `watchRun()`, `watchRunsForClub()`, `watchAttendedRuns()`, `watchSignedUpRuns()` | `fetchRun()`, `fetchUpcomingRunsForClubs()` | `create`, `signUp`, `leaveWaitlist` | `cancelRunSignUp`, `joinRunWaitlist`, `markRunAttendance` |
| SwipeRepository | — | `fetchSwipedUserIds()` | `recordSwipe()` | — |
| SwipeCandidateRepository | — | `fetchCandidates()` | — | — |
| MatchRepository | `watchMatchesForUser()`, `watchMatch()` | — | `resetUnread()` | — |
| ChatRepository | `watchMessages()` | — | `sendMessage()` | — |
| PaymentRepository | — | — | (via Razorpay SDK) | `createRazorpayOrder`, `verifyRazorpayPayment`, `signUpForFreeRun` |
| PaymentHistoryRepository | `watchPaymentsForUser()` | `fetchPaymentsForUser()`, `fetchPaymentForRun()` | — | — |
| ReviewsRepository | `watchReviewsForClub()`, `watchReviewsForRun()`, `watchReviewsByUser()`, `watchUserReviewForClub()` | — | `add`, `update`, `delete` | — |
| OnboardingDraftRepository | — | `fetchDraft()` | `save`, `delete` | — |
| ImageUploadRepository | — | `pickImage()` | `upload`, `uploadUserPhoto`, `uploadRunClubCover` | — |
| PublicProfileRepository | `watchPublicProfile()` | `fetchPublicProfile()`, `fetchPublicProfiles()` (batch) | — | — |
| SafetyRepository | `watchBlockedUsers()` | `fetchBlockedUserIds()` | — | `blockUser`, `unblockUser`, `reportUser`, `requestAccountDeletion` |

### Error Handling Inconsistency

This is the **largest quality gap** in the repository layer:

| Repository | Method | Error Handling |
|------------|--------|----------------|
| RunClubsRepository | `joinClub()` | `withFirestoreErrorContext()` ✅ |
| RunClubsRepository | `leaveClub()` | None ❌ |
| PaymentRepository | All methods | Custom `_normalize*Error()` + typed exceptions ✅ |
| MatchRepository | `resetUnread()` | Catches `not-found` only ✅ |
| RunDraftRepository | `loadDrafts()` | Blank `catch (_) => []` ⚠️ |
| All other repos | All methods | **No error handling** — raw FirebaseException propagates ❌ |

The `withFirestoreErrorContext` utility exists and is well-designed, but it's used in **exactly 1 of ~40 write methods**. The `firestoreErrorMessage` utility is used at the UI layer, but the structured error context (collection + action) is lost for most operations.

---

## Controller & Mutation Pattern Analysis

### Three Distinct Patterns

The codebase uses **three different patterns** for stateful logic:

#### Pattern A: Stateful keepAlive Notifier + freezed state (1 instance)
```
OnboardingController
  - @Riverpod(keepAlive: true) class
  - State: OnboardingData (freezed)
  - Mutations: static final (4)
  - Methods mutate state directly via state = state.copyWith(...)
```

Used for: Multi-step flows where state must survive navigation.

#### Pattern B: Stateless @riverpod controller + static Mutations (6 instances)
```
RunBookingController, CreateRunController, RunClubMembershipController,
RunClubsListController, CreateRunClubController, WriteReviewController
  - @riverpod class (autoDispose)
  - State: void (build() returns nothing)
  - Mutations: static final Mutation<T>
  - Methods delegate to repositories, mutations track lifecycle
```

Used for: Single-shot operations (book, cancel, join, leave, submit, delete).

#### Pattern C: AsyncNotifier with state (3 instances)
```
DeviceLocation, LocationInitializer, SwipeQueueNotifier
  - @Riverpod(keepAlive: true) or @riverpod class
  - State: AsyncValue<T> (managed by Riverpod's AsyncNotifier base)
  - build() returns Future<T>
  - Methods mutate state
```

Used for: Async initialization that runs once, or async state that needs mutation.

#### Pattern D: Pure computed providers (5 instances)
```
runDetailViewModel, runClubDetailViewModel, runClubsListViewModel,
filteredRunClubs, forceUpdateRequired
  - @riverpod function (not a class)
  - Combines multiple providers into a derived value
  - Freezed data class for the result
```

### Pattern Evaluation

**Pattern B (Stateless Controllers + Mutations)** is the most common for user actions. It cleanly separates:
- Data fetching (Layer 2-3 stream/future providers)
- Data mutation (Layer 4 controllers)
- UI state (screens watch both)

However, there's an inconsistency: `OnboardingController` (Pattern A) uses **both** freezed state AND mutations. It mutates `OnboardingData` directly for step tracking while using mutations for OTP/profile operations. This hybrid approach is reasonable for its use case but is unique in the codebase.

**Pattern C** (AsyncNotifier) is appropriate for `DeviceLocation` and `LocationInitializer` (fire-and-cache) and `SwipeQueueNotifier` (async load + sync mutations). The swipe queue's `swipe()` method removes the first profile from the list — this is a synchronous mutation of async-loaded state accessible via `AsyncData(...)`.

### Pattern Decision Guide

When creating new controller/view-model logic, use this decision tree:

```
Does the state need to survive navigation between screens/pages?
  ├─ YES → Pattern A: @Riverpod(keepAlive: true) + freezed state + Mutations
  │         (example: OnboardingController)
  │
  └─ NO → Does the state need async initialization?
            ├─ YES → Does it need mutation after load?
            │         ├─ YES → Pattern C: AsyncNotifier
            │         │         (example: SwipeQueueNotifier)
            │         └─ NO  → Pattern D: @riverpod function returning AsyncValue
            │                  (example: runDetailViewModel)
            │
            └─ NO → Is it a single-shot user action (book, join, submit)?
                      ├─ YES → Pattern B: Stateless @riverpod + static Mutations
                      │         (example: RunBookingController)
                      └─ NO  → Simple @riverpod function or @Riverpod(keepAlive) Notifier
                                (example: selectedRunClubCity, runClubSearchQuery)
```

### Mutation Count & Types

| Controller | Mutations | Types |
|------------|-----------|-------|
| OnboardingController | 4 | `void` × 4 |
| RunBookingController | 5 | `void` × 5 |
| RunClubMembershipController | 2 | `void` × 2 |
| WriteReviewController | 2 | `void` × 2 |
| RunClubsListController | 1 | `void` |
| CreateRunController | 1 | `Run` (carries created run) |
| CreateRunClubController | 1 | `void` |
| **Total** | **16** | |

---

## GoRouter & Auth Flow

### Redirect Decision Tree

```
On every navigation + every uidProvider/userProfileStream emission:

1. Is uidAsync still loading?
   → YES: Go to /loading (preserving ?from= destination)
   → NO: Continue

2. Is uid non-null BUT userProfileAsync still loading?
   → YES: Go to /loading (preserving ?from= destination)
   → NO: Continue

3. Is uid null? (signed out)
   → YES: Go to /onboarding (preserving ?from= destination)
   → Already on /onboarding: stay

4. Is userProfile null OR profileComplete == false?
   → YES: Go to /onboarding (preserving ?from= destination)
   → Already on /onboarding: stay

5. Signed in + profile complete:
   → If on /loading, /auth, or /onboarding: resume to ?from= or /
   → Otherwise: stay (null = allow navigation)
```

### Critical Design Details

1. **`ref.listen` + `ref.read` pattern:** The `goRouterProvider` uses `ref.listen(uidProvider, ...)` and `ref.listen(userProfileStreamProvider, ...)` to trigger a `ChangeNotifier` (GoRouter's `refreshListenable`). The actual redirect function uses `ref.read()` to get snapshots. This avoids the circular dependency that `ref.watch` would create inside a provider that's also watched by the router.

2. **Loading screen is transient:** `/loading` is never the `?from=` destination. When auth resolves, the user is redirected to their intended destination.

3. **Onboarding completion triggers instant redirect:** When `OnboardingController.complete()` writes `profileComplete: true` to Firestore, the `userProfileStreamProvider` emits a new `UserProfile` with `profileComplete == true`. This triggers `goRouter`'s `refreshListenable`, which re-evaluates the redirect, sending the user from `/onboarding` to `/` (or their `?from=` destination).

4. **No race conditions in redirect:** The redirect checks `isLoading` before checking values, so it never makes decisions on stale/partial data.

### Auth State Transitions

```
App Launch
  → uidProvider: AsyncLoading
  → userProfileStream: Stream.empty() (uid not yet known)
  → router: redirects to /loading

Firebase Auth resolves (signed out)
  → uidProvider: AsyncData(null)
  → router: redirects to /onboarding

User completes phone OTP
  → uidProvider: AsyncData("abc123")
  → userProfileStream: AsyncLoading (Firestore doc loading)
  → router: redirects to /loading

UserProfile doc loads
  → userProfileStream: AsyncData(UserProfile(profileComplete: false))
  → router: redirects to /onboarding

Onboarding completes
  → userProfileStream: AsyncData(UserProfile(profileComplete: true))
  → router: redirects to / (or ?from= destination)
```

---

## Caching & KeepAlive Analysis

### What Stays Alive Forever (34 providers)

These providers are **never disposed** during the app lifetime:

**Firebase singletons (5):** All Firebase service providers.

**Auth chain (3):** `authRepositoryProvider`, `authStateChangesProvider`, `uidProvider`.

**User profile (2):** `userProfileRepositoryProvider`, `userProfileStreamProvider`.

**Core infrastructure (7):** `deviceLocationProvider`, `locationInitializerProvider`, `fcmServiceProvider`, `appVersionConfigProvider`, `appPackageInfoProvider`, `forceUpdateRequiredProvider`, `goRouterProvider`.

**All repository providers (15):** Every `*RepositoryProvider` in the app.

**UI state (2):** `selectedRunClubCityProvider`, `runClubSearchQueryProvider`, `onboardingControllerProvider`.

### What Auto-Disposes (36 providers)

All stream providers that watch Firestore collections:
- `watchRunClub`, `watchRunClubsByLocation*`, `watchRun`, `runsForClub`, `attendedRuns`, `signedUpRuns`
- `matchesForUser`, `matchStream`, `chatMessages`
- `watchReviewsForClub`, `watchReviewsForRun`, `watchReviewsByUser`, `watchUserReviewForClub`
- `publicProfile`, `blockedUsers`
- `paymentsForUser`
- All 6 stateless controllers

### Cache Behavior Analysis

**Stream providers (autoDispose):** When the last watcher is removed (screen popped), the Firestore listener is cancelled. When the screen is re-opened, a new listener is established. This means:
- **Re-subscription causes a loading flash** on every screen re-entry
- Firestore's local cache may serve stale data briefly before the server syncs
- The first emission from a re-subscribed stream is typically from the local cache (~0ms), followed by the server snapshot

**Future providers (autoDispose):** When autoDisposed, the future result is discarded. Re-watching re-executes the fetch. For `fetchUpcomingRunsForClubs`, this means a new Firestore query on every dashboard visit.

**keepAlive providers:** Their data is available instantly without any loading delay. `userProfileStream` is the most important — it's always live and always up-to-date.

### Memory Footprint

34 keepAlive providers is **above average** for a Riverpod app of this size. Each repository provider is a thin wrapper holding only a reference to a Firebase singleton (negligible memory), but the stream providers like `userProfileStream` maintain an open Firestore listener for the app's lifetime. This is **one listener per keepAlive stream**, which is correct and minimal.

The primary memory concern is `selectedRunClubCityProvider` and `runClubSearchQueryProvider` being keepAlive — these hold UI-only state (`IndianCity` enum and a `String`) that could be autoDisposed when the clubs tab is not visible. Their keepAlive status is justified by the need to preserve the user's city selection across tab switches.

---

## Firestore Read Analysis

### Active Firestore Listeners (Real-time Streams)

These providers create **persistent Firestore snapshot listeners** while watched:

| Provider | Collection | Query Scope | Listener Count |
|----------|-----------|-------------|----------------|
| `userProfileStreamProvider` | `users/{uid}` | Single doc | 1 (keepAlive — always active) |
| `watchRunClubsByLocationProvider` | `runClubs` | All clubs in a city, ordered by `createdAt` | 1 per city selection |
| `watchRunClubProvider` | `runClubs/{id}` | Single doc | 1 per club detail screen |
| `watchRunProvider` | `runs/{id}` | Single doc | 1 per run detail screen |
| `runsForClubProvider` | `runs` | All runs for a club | 1 per club detail screen |
| `attendedRunsProvider` | `runs` | Runs where `attendedUserIds` contains uid | 1 (dashboard, catches tab) |
| `signedUpRunsProvider` | `runs` | Runs where `signedUpUserIds` contains uid | 1 (dashboard) |
| `matchesForUserProvider` | `matches` | 2 queries (user1 or user2) | 2 per chats tab |
| `chatMessagesProvider` | `chats/{matchId}/messages` | All messages | 1 per chat screen |
| `watchReviewsForClubProvider` | `reviews` | All reviews for a club | 1 per club detail |
| `watchReviewsForRunProvider` | `reviews` | All reviews for a run | 1 per run detail |
| `watchUserReviewForClubProvider` | `reviews` | Single review doc | 1 per write review sheet |
| `publicProfileProvider` | `publicProfiles/{uid}` | Single doc | N (one per profile card in swipe) |
| `paymentsForUserProvider` | `payments` | All payments for user | 1 per payment history |
| `blockedUsersProvider` | `blocks` | Blocks where user is blocker or blocked | 1 (settings screen) |

### One-Time Firestore Reads (Futures)

| Provider | Read Pattern | Triggers |
|----------|-------------|----------|
| `fetchRunClubProvider` | `runClubs/{id}.get()` | Route-level screen load (create run, edit club) |
| `recommendedRunsProvider` | `runs` query (whereIn + limit 10) | Dashboard load |
| `dashboardRecommendedRunsProvider` | `runs` query (whereIn + limit 10) | Dashboard load |
| `clubRunDraftsProvider` | SharedPreferences read | Create run screen |
| `runnerProfilesProvider` | `publicProfiles` batch get (up to 30 per chunk) | Run detail (who's running) |
| `swipeQueueNotifier.build()` | Multi-step fetch (run → swiped ids → blocked ids → profiles) | Swipe screen entry |

### Firestore Read Cost Estimate (per session)

**Always active (1 listener):**
- `userProfileStream`: 1 doc read on startup, then real-time updates (0 additional reads unless the doc changes)

**Per screen visit (transient listeners):**
- Club list: `runClubs` query (all clubs in city) — 1 query read
- Club detail: `runClubs/{id}` + `runs` query + `reviews` query — 3 query reads
- Run detail: `runs/{id}` + `reviews` query — 2 query reads
- Dashboard: `attendedRuns` query + `signedUpRuns` query + `recommendedRuns` fetch — 3 reads
- Swipe: `run.get()` + `swipes` query + `blocks` query + batch `publicProfiles` — ~4 reads
- Chat list: 2 `matches` queries — 2 reads
- Chat: `messages` query — 1 read
- Profile: `publicProfiles/{uid}` — 1 read

**Typical user journey (club browsing + one run booking):** ~20-30 Firestore reads per session, which is **well within reasonable limits** for Firestore's pricing model.

**Optimization opportunity:** The dashboard re-fetches `recommendedRuns` every time it's visited (autoDispose). If the user switches tabs and returns, this triggers another fetch. A keepAlive with a TTL could reduce this.

### No N+1 Query Problems

The codebase generally avoids N+1 patterns:
- `fetchPublicProfiles` batches by 30 (Firestore `whereIn` limit)
- `fetchCandidates` in `SwipeCandidateRepository` does one batch fetch for all candidate profiles
- Run lists are fetched as queries, not individual doc gets

---

## Data Availability Guarantees

### What's Always Available (after auth resolves)

| Data | Provider | Guarantee |
|------|----------|-----------|
| Current user UID | `uidProvider` | Always available (keepAlive, sync from Firebase Auth) |
| Current user profile | `userProfileStreamProvider` | Always available once signed in (keepAlive stream) |
| Auth state | `authStateChangesProvider` | Always available (keepAlive stream) |
| Device location | `deviceLocationProvider` | Cached after first fetch (keepAlive) |
| Selected city | `selectedRunClubCityProvider` | Always available (keepAlive, defaults to Mumbai) |
| Force update status | `forceUpdateRequiredProvider` | Always available (keepAlive) |

**Your assumption is correct:** `userProfileStreamProvider` is initialized at app startup (via `uidProvider` → `userProfileStream` chain) and remains live throughout the session. Any screen can `ref.watch(userProfileStreamProvider)` and will receive the current `UserProfile` immediately (no loading delay) once auth has resolved.

However, there are **nuances**:

1. **During initial auth resolution** (~100-500ms after app launch), `userProfileStream` emits nothing (empty stream). Screens that watch it will show loading during this brief window. The router handles this by showing `/loading`.

2. **On sign-out**, `userProfileStream` emits `null`. Screens must handle this gracefully, but since the router redirects unauthenticated users to `/onboarding`, screens inside the authenticated shell should never see this state in practice.

3. **The profile may be stale** if a Cloud Function modifies the user's document. But since `userProfileStream` is a real-time listener, it will update within ~1-2 seconds of any server-side change.

### What Requires Waiting

| Data | Provider | Wait Time |
|------|----------|-----------|
| Club list for a new city | `watchRunClubsByLocationProvider` | ~200-500ms (first fetch), ~0ms (cached) |
| Club detail | `watchRunClubProvider` + `runsForClubProvider` | ~200-500ms each |
| Run detail | `watchRunProvider` | ~200-500ms |
| Swipe candidates | `swipeQueueNotifier.build()` | ~500-2000ms (multi-step fetch) |
| Recommendations | `recommendedRunsProvider` | ~200-500ms |
| Chat messages | `chatMessagesProvider` | ~200-500ms |

---

## Loading Indicator Map

### Where Users See Loading Spinners

| Screen | Loading Trigger | Mitigation |
|--------|----------------|------------|
| **App launch** | uidProvider resolving | `/loading` route (centered spinner) |
| **Force update check** | `forceUpdateRequiredProvider` loading | Full-screen spinner (blocks app) |
| **Club list** | Re-subscribing to `watchRunClubsByLocation` after autoDispose | Brief flash on tab re-entry |
| **Club detail** | `watchRunClubProvider` + `runsForClubProvider` + `watchReviewsForClubProvider` initial load | Screen shows skeleton/loading via `AsyncValue.when()` |
| **Run detail** | `watchRunProvider` + `watchReviewsForRunProvider` initial load | Screen shows loading via `AsyncValue.when()` |
| **Create run / Edit club** | `fetchRunClubProvider` for route data | `_RouterLoadingScreen` |
| **Dashboard** | `signedUpRunsProvider` + `attendedRunsProvider` + `recommendedRunsProvider` | `DashboardScreen` uses `.when()` |
| **Swipe hub** | `attendedRunsProvider` + `swipeQueueNotifier` | Screen shows loading |
| **Chat list** | `matchesForUserProvider` | Screen shows loading |
| **Chat** | `chatMessagesProvider` + `matchStreamProvider` | Screen shows loading |
| **Payment history** | `paymentsForUserProvider` | Screen shows loading |
| **Public profile** | `publicProfileProvider` | Screen shows loading |

### Loading Indicator Count Estimate

**Cold start (first launch + onboarding):** 1 loading screen (`/loading`), then the onboarding UI (no additional spinners since onboarding manages its own UI state).

**Authenticated home tab switch:** 0 loading indicators on Home (data is streaming/already resolved), potential brief flash on Clubs, Catches, or Chats if the tab's stream was autoDisposed.

**Navigating to a detail screen:** 1 loading indicator per detail screen (club, run, chat, public profile).

**Typical session:** 3-6 loading indicators across a 5-minute browsing session. This is **acceptable but could be improved** by pre-warming frequently accessed streams.

---

## Architecture Consistency Evaluation

### What's Consistent ✅

1. **Feature folder structure:** Every feature follows `domain/` → `data/` → `presentation/`. No exceptions.

2. **Repository wrapping:** Every Firebase interaction goes through a repository. No widgets call Firestore directly.

3. **Provider pattern for repositories:** All 15 repositories use `@Riverpod(keepAlive: true)` and inject their Firebase dependency via `ref.watch`.

4. **Firestore partial updates:** `FieldValue.arrayUnion/arrayRemove` and `.update(fields)` are used for all partial writes. No full-document read-modify-write cycles. This prevents the timestamp precision bug described in PROJECT_CONTEXT.md §18.

5. **Mutation display:** `mutationErrorMessage()` from `lib/core/widgets/mutation_error_util.dart` is the standard way to display mutation errors.

6. **`requireSignedInUid()` utility:** Used by 6 controllers to assert auth state before performing actions.

7. **Freezed for domain models:** All data models in `domain/` are freezed. Consistent use of `@freezed` with `fromJson`/`toJson`.

### What's Inconsistent ❌

1. **Error handling in repositories:**
   - `withFirestoreErrorContext()` now wraps the majority of write methods: UserProfileRepository (6), RunRepository (7), ReviewsRepository (3), RunClubsRepository (2), ChatRepository (1) = ~19 methods. Remaining unwrapped: OnboardingDraftRepository (2), SwipeRepository (1), ImageUploadRepository (3 — Storage, not Firestore), PaymentHistoryRepository (0 — read-only).
   - ~~Some methods catch+specific-handle (`MatchRepository.resetUnread`), others catch+swallow (`RunDraftRepository.loadDrafts`), most have no handling at all~~ **Partially resolved 2026-05-03 — majority of Firestore write methods now wrapped. `run_draft_repository.dart` still swallows silently (uses SharedPreferences, not Firestore).**

2. **Provider declaration style:** ✅ **RESOLVED 2026-05-03** — All 70 providers now use `@riverpod` codegen. The 4 manual providers (`safetyRepositoryProvider`, `blockedUsersProvider`, `matchStreamProvider`, `appAnalyticsProvider`) were converted.

3. **Error banner duplication:** ✅ **RESOLVED 2026-05-03** — `CatchErrorBanner` deleted, merged into `ErrorBanner` with `onRetry` support. Single canonical error banner.

4. **Dead code (`showSnackbarOnError`):** ✅ **RESOLVED 2026-05-03** — File deleted (zero call sites).

5. **Raw `e.toString()` in UI:** ✅ **RESOLVED 2026-05-03** — `run_detail_screen.dart:23` now uses `firestoreErrorMessage(e)`.

6. **`onboardingControllerProvider` never disposed:** ✅ **RESOLVED 2026-05-03** — `ref.invalidateSelf()` called at end of `complete()`.

7. **Controller state patterns:**
   - `OnboardingController`: freezed state + keepAlive + mutations (Pattern A)
   - 6 controllers: stateless + mutations (Pattern B)
   - 3 controllers: AsyncNotifier with async state (Pattern C)
   - **Assessment:** Pattern B is appropriate for single-shot operations. Pattern A is necessary for multi-step flows. Pattern C is correct for async initialization. The mix is justified but should be documented.

4. **ViewModel naming:**
   - Some are called `*ViewModel` (`RunDetailViewModel`)
   - Some are called `*Controller` (`RunBookingController`)
   - Some are called `*Notifier` (`SwipeQueueNotifier`)
   - **Recommendation:** Standardize: `*Controller` for mutation hosts, `*ViewModel` for derived data, `*Notifier` for stateful Riverpod notifiers.

5. **keepAlive on UI state:**
   - `selectedRunClubCityProvider` and `runClubSearchQueryProvider` are keepAlive (survive tab switches)
   - But `swipeQueueNotifierProvider` is autoDispose (loses state on tab switch)
   - **Assessment:** Inconsistent but arguably correct — preserving the swipe queue across tab switches would be stale data.

6. **`onboardingControllerProvider` is keepAlive but never disposed after onboarding completes:**
   - After onboarding, this provider holds `OnboardingData` in memory for the rest of the app session
   - **Impact:** Negligible memory (~200 bytes), but technically a leak
   - **Recommendation:** Add a `dispose()` or reset mechanism after onboarding completion

7. **Manual `ref.read` for `requireSignedInUid`:**
   - Controllers use `ref.read(uidProvider)` inside mutation methods
   - This is safe because mutations are called from UI event handlers (not during build), but it bypasses Riverpod's reactivity
   - **Assessment:** Acceptable pattern for mutations, but could cause issues if the uid changes during a long-running operation

### What's Missing 🚫

1. **No cache invalidation strategy:** There's no systematic way to invalidate provider caches. `ref.invalidate()` is used ad-hoc (e.g., after force update retry), but there's no pattern for "the user's profile changed, invalidate all dependent providers."

2. **No offline/persistence layer documentation:** Firestore's built-in offline persistence is enabled by default, but the app doesn't document which data is expected to be available offline and which requires network.

3. **No provider lifecycle documentation:** The distinction between keepAlive and autoDispose is not documented per-provider. Future developers may change keepAlive status without understanding the implications.

4. **No loading timeout handling:** Stream providers that haven't emitted after N seconds show perpetual loading spinners with no timeout error state.

---

## Recommendations

### Immediate (Low Effort, High Impact)

1. **Standardize error handling in repositories.** ✅ **IN PROGRESS 2026-05-03** — `withFirestoreErrorContext` now wraps ~19 write methods across 5 repositories (UserProfileRepository, RunRepository, ReviewsRepository, RunClubsRepository, ChatRepository). The utility now maps Firebase codes to specific `AppException` subtypes (`PermissionException`, `NetworkException`, `SignInRequiredException`). Remaining: OnboardingDraftRepository, SwipeRepository, ImageUploadRepository.

2. **Convert manual providers to codegen.** ✅ **DONE 2026-05-03** — All 4 manual providers converted to `@riverpod` codegen (`safetyRepositoryProvider`, `blockedUsersProvider`, `matchStreamProvider`, `appAnalyticsProvider`). All 70 providers now use codegen.

3. **Add dispose for `onboardingControllerProvider`.** ✅ **DONE 2026-05-03** — `ref.invalidateSelf()` called at end of `complete()` method. Onboarding state freed after profile completion.

### Short-Term (Medium Effort, Medium Impact)

4. **Document the three controller patterns** in a `CONTROLLERS.md` or at the top of the relevant files. Future contributors should know when to use each.

5. **Pre-warm the clubs list stream** by watching `watchRunClubsByLocationProvider` from the `AppShell` (similar to how `locationInitializerProvider` is triggered). This eliminates the clubs tab loading flash on first visit.

6. **Add loading timeouts** to key stream providers. A 10-second timeout with an error state is better than a perpetual spinner.

### Long-Term (Higher Effort, Architectural)

7. **Implement a structured cache invalidation system.** For example:
   ```dart
   // Invalidate all providers that depend on user profile when it changes
   ref.listen(userProfileStreamProvider, (prev, next) {
     if (prev?.value?.uid != next.value?.uid) {
       ref.invalidate(attendedRunsProvider);
       ref.invalidate(signedUpRunsProvider);
       ref.invalidate(matchesForUserProvider);
       // etc.
     }
   });
   ```

8. **Consider a TTL-based keepAlive** for expensive-but-infrequently-changing data like the clubs list. Riverpod doesn't natively support TTL, but a wrapper `Ref` with a timer-based invalidation could work.

9. **Evaluate whether 15 repository providers all need keepAlive.** Repository providers are thin wrappers around Firebase singletons — they could be autoDispose with negligible reconstruction cost. The only benefit of keepAlive is avoiding the `Provider<XxxRepository>` reconstruction, which is essentially free.

10. **Add Firestore read telemetry** via `AppAnalytics.logFirestoreWriteFailed` equivalent for reads. This would help identify hot paths and optimization opportunities in production.

---

## How to Improve Future Queries

Your query was comprehensive and well-structured. Here's how to make it even better:

1. **Specify output format:** "Create a markdown document at `docs/architecture-audit.md`" rather than "create a readme or some kind of documentation." I defaulted to what you intended, but explicit paths reduce ambiguity.

2. **Ask for specific metrics:** "How many Firestore reads per typical user session?" or "What's the maximum number of concurrent Firestore listeners?" These concrete questions produce more actionable answers than "evaluate the patterns."

3. **Prioritize concerns:** "First analyze caching, then Firestore reads, then pattern consistency." This helps order the exploration so the most important findings come first.

4. **Request a decision framework:** "For each inconsistency found, recommend whether to standardize on the majority pattern or keep the exception." This turns findings into a concrete action plan.

5. **Include the adjacent areas you named:** "Also check Firebase Security Rules alignment with the data access patterns" or "Also verify that Cloud Functions are called with correct auth context" would have added valuable backend context.

6. **Version pin the audit:** "Tag this audit with the current git SHA so future audits can diff against it." This enables tracking architectural drift over time.

---

## Appendix: Quick Reference

### Key Files

| Concern | File |
|---------|------|
| App bootstrap | `lib/main.dart` |
| App widget (force update gate) | `lib/app.dart` |
| Router + redirect logic | `lib/routing/go_router.dart` |
| Firebase service providers | `lib/core/firebase_providers.dart` |
| Auth repository + uid stream | `lib/auth/auth_repository.dart` |
| User profile repository + stream | `lib/user_profile/data/user_profile_repository.dart` |
| Error message translation | `lib/core/firestore_error_message.dart` |
| Error context wrapper | `lib/core/firestore_error_util.dart` |
| Mutation error display | `lib/core/widgets/mutation_error_util.dart` |
| Signed-in guard utility | `lib/auth/require_signed_in_uid.dart` |
| Global error observer | `lib/exceptions/async_error_logger.dart` |
| App shell (tab bar + FCM init) | `lib/core/presentation/app_shell.dart` |
| Onboarding controller | `lib/onboarding/presentation/onboarding_controller.dart` |

### Provider Count by Feature

| Feature | Providers |
|---------|-----------|
| Core / Infrastructure | 17 |
| Auth | 3 |
| User Profile | 2 |
| Run Clubs | 11 |
| Runs | 10 |
| Swipes | 5 |
| Matches / Chats | 6 |
| Reviews | 5 |
| Payments | 3 |
| Safety | 2 |
| Onboarding | 2 |
| Image Uploads | 2 |
| Dashboard | 2 |
| **Total** | **70** |
