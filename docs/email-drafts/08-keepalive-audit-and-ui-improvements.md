From: Claude Code <noreply@anthropic.com>
To: suvratgarg@gmail.com
Subject: [Fixes] Repo keepAlive audit + pre-warm + cache invalidation + mutation widget + controller docs

---

## Item 9: Repo keepAlive audit — 14 providers demoted to autoDispose

**What:** Changed `@Riverpod(keepAlive: true)` to `@riverpod` on 14 repository providers. Down from 34 → 20 keepAlive providers.

**Files:** 14 repository files in `lib/*/data/`

**Why a repository doesn't need keepAlive:** Repository classes are stateless thin wrappers around Firebase singletons. Their constructor does nothing but store a reference:
```dart
RunRepository(FirebaseFirestore.instance, FirebaseFunctions.instanceFor(...))
```
Reconstructing one costs essentially zero. The Firebase singletons they wrap are never disposed. The only repo that must stay keepAlive is `PaymentRepository` — it has `ref.onDispose(repo.dispose)` to clean up Razorpay listeners.

**The 20 that remain keepAlive each have specific justification:**
- 5 Firebase singletons (must stay alive)
- 3 auth providers (app lifetime)
- 1 userProfileStream (app lifetime stream)
- 1 paymentRepository (dispose logic)
- 2 core infra (deviceLocation, locationInitializer — fire-and-cache)
- 1 fcmService (initialized once)
- 3 force-update (block app startup)
- 2 run clubs UI state (survive tab switches)
- 1 goRouter (app lifetime)
- 1 onboardingController (multi-step flow, self-disposes)

## Pre-warm clubs list stream

**What:** `AppShell` now watches `watchRunClubsByLocationProvider(selectedCity)`, keeping the Firestore listener alive for the app lifetime. Switching to the Clubs tab shows data immediately instead of flashing a loading spinner.

**File:** `lib/core/presentation/app_shell.dart`

## Cache invalidation on sign-out

**What:** `AppShell` listens to `uidProvider` and invalidates `userProfileStreamProvider` when the user signs out. Ensures clean state on next sign-in.

**File:** `lib/core/presentation/app_shell.dart`

## Standardized mutation error display

**What:** Replaced the loose `listenForMutationErrorSnackbar()` function with a reusable `MutationErrorSnackbarListener` ConsumerWidget. The widget wraps its child and automatically listens to the mutation, showing a SnackBar on error.

```dart
MutationErrorSnackbarListener(
  mutation: RunClubMembershipController.joinMutation,
  child: Scaffold(body: ...),
),
```

**Files:** `run_clubs_mutation_feedback.dart` (rewrite), `run_club_detail_screen.dart`, `run_clubs_list_screen.dart`

## Documented controller patterns

**What:** Added doc comments to the four representative controllers explaining which pattern they use and when to use it. Added a decision guide to `architecture-audit.md`.

**Files:** `onboarding_controller.dart`, `run_booking_controller.dart`, `swipe_queue_notifier.dart`, `run_detail_view_model.dart`, `architecture-audit.md`
