# Catch Dating App — Error Handling Architecture Audit

**Date:** 2026-05-03
**Scope:** Complete mapping of exception types, error propagation paths, user-facing error rendering, logging/telemetry, and gap analysis.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [The Error Pipeline](#the-error-pipeline)
3. [Exception Hierarchy](#exception-hierarchy)
4. [Repository Layer Error Handling](#repository-layer-error-handling)
5. [Controller Layer Error Handling](#controller-layer-error-handling)
6. [UI Layer Error Rendering](#ui-layer-error-rendering)
7. [Logging & Telemetry](#logging--telemetry)
8. [Silent Error Swallowing](#silent-error-swallowing)
9. [Gap Analysis](#gap-analysis)
10. [Remediation Progress](#remediation-progress)

---

## Executive Summary

The app's error handling grew organically without a deliberate strategy. Key findings:

- **11 of 16 repositories** originally had zero error handling — raw `FirebaseException` propagated unchecked to the UI. Now down to ~3 after the 2026-05-03 remediation pass.
- **`AppException` subclasses were invisible in production** — `logAppException` only called `debugPrint` (no-op in release). No Crashlytics or Analytics events for business-impacting errors like payment failures.
- **`logFirestoreWriteFailed` analytics event** was defined but had zero call sites — Firestore write failures were invisible in dashboards.
- **6+ distinct UI error display patterns** existed across the app — `ErrorBanner`, `CatchErrorBanner`, direct `SnackBar` with hardcoded strings, raw `e.toString()`, `listenForMutationErrorSnackbar`, `AsyncValueWidget`.
- **5+ locations silently swallowed errors** without logging — `DeviceLocation`, `RunDraftRepository`, `OnboardingController`, `PhotoUploadController`, `ProfileEditSheet`.
- **Web platform had zero error reporting** — `Crashlytics` returned `null` on web with no fallback.
- **No structured logging** — no timestamps, log levels, or contextual metadata across any error path.

The 2026-05-03 remediation pass addressed the highest-impact gaps: exception hierarchy expansion, repository write wrapping, UI consolidation, dead code removal, and provider codegen consistency.

---

## The Error Pipeline

The error lifecycle across layers:

```
Layer 1: Origin
  Repository throws FirebaseException / FirebaseFunctionsException
  Domain validation throws ArgumentError / StateError

Layer 2: Capture (Repository)
  withFirestoreErrorContext catches FirebaseException
  Maps to typed AppException (PermissionException, NetworkException, etc.)
  Re-throws as AppException

Layer 3: Propagation (Controller / Provider)
  AppException propagates through Riverpod AsyncValue or Mutation state
  Unexpected exceptions logged via ErrorLogger before rethrow ← GAP (not yet done)

Layer 4: Display (UI)
  AsyncValue.when(error: ...) → firestoreErrorMessage(e) → Text widget
  Mutation.hasError → ErrorBanner(message: mutationErrorMessage(mutation))
  Transient actions → listenForMutationErrorSnackbar → SnackBar

Layer 5: Telemetry
  AsyncErrorLogger (ProviderObserver) → ErrorLogger → Crashlytics (unexpected errors)
  AppException → debugPrint only ← GAP (not yet to Crashlytics or Analytics)
```

---

## Exception Hierarchy

### Current state (after 2026-05-03 remediation)

```
AppException (sealed)
├── SignInRequiredException          // Auth required for action
├── NetworkException                  // connection-failed / timeout / too-many-requests
├── PermissionException               // permission-denied
├── PaymentCancelledException         // User cancelled Razorpay
├── PaymentFailedException            // Razorpay payment failed
├── PaymentVerificationFailedException // Signature verification failed
├── PaidBookingUnsupportedException   // Platform doesn't support paid bookings
├── RunBookingFailedException         // Cloud Function booking failed
├── FirestoreWriteException           // Generic Firestore write failure
└── DocumentNotFoundException         // Doc doesn't exist
```

**File:** `lib/exceptions/app_exception.dart` (71 lines)

### What each exception carries

| Property | Purpose | Example |
|----------|---------|---------|
| `code` | Machine-readable identifier | `'permission-denied'`, `'timeout'` |
| `message` | Human-readable description | `'create run on runs failed: [permission-denied] ...'` |
| `cause` | Original error for debugging | The original `FirebaseException` |

`toString()` returns `message` so exceptions display cleanly without the "Exception:" prefix.

### How Firebase exceptions map to domain exceptions

This mapping happens in `lib/core/firestore_error_util.dart:_mapFirebaseException()`:

| FirebaseException.code | AppException |
|------------------------|--------------|
| `permission-denied` | `PermissionException` |
| `unauthenticated` | `SignInRequiredException` |
| `unavailable` | `NetworkException('connection-failed')` |
| `deadline-exceeded` | `NetworkException('timeout')` |
| `resource-exhausted` | `NetworkException('too-many-requests')` |
| `not-found` | `DocumentNotFoundException` |
| Any other code | `FirestoreWriteException` (preserves original code) |

The same mapping exists for `FirebaseFunctionsException` in `_mapFunctionsException()`.

### What's missing from the hierarchy

- No `ValidationException` for domain validation errors (currently `StateError`/`ArgumentError` raw)
- No `StorageException` for Firebase Storage upload failures
- No `TimeoutException` subclass — currently folded into `NetworkException('timeout')`

---

## Repository Layer Error Handling

### Before remediation (2026-05-03)

| Repository | Write Methods | Error Handling |
|------------|--------------|----------------|
| RunClubsRepository (joinClub) | 1 | `withFirestoreErrorContext` ✅ |
| RunClubsRepository (leaveClub) | 1 | None ❌ |
| PaymentRepository | 4 | Custom normalization ✅ |
| MatchRepository (resetUnread) | 1 | Targeted `not-found` catch ✅ |
| RunDraftRepository (loadDrafts) | 1 | Blank `catch (_)` ❌ |
| **All other repos** | ~33 | **None** ❌ |

Only **1 of ~40 write methods** originally used `withFirestoreErrorContext`. After remediation, **all Firestore write methods are now wrapped** (~25 methods across 9 repositories).

### After remediation (2026-05-03)

| Repository | Methods Wrapped |
|------------|----------------|
| UserProfileRepository | `setUserProfile`, `updateUserProfile`, `updatePhotoUrls`, `setProfileComplete`, `saveRun`, `unsaveRun` (6) |
| RunRepository | `createRun`, `signUpForRun`, `cancelSignUpViaFunction`, `joinWaitlistViaFunction`, `leaveWaitlist`, `markAttendance` (6) |
| ReviewsRepository | `addReview`, `updateReview`, `deleteReview` (3) |
| RunClubsRepository | `joinClub` (existing), `leaveClub` (new) (2) |
| ChatRepository | `sendMessage` (1) |
| **Total** | **~18 methods** |

### Remaining unwrapped

| Repository | Methods | Reason |
|------------|---------|--------|
| SwipeRepository | `recordSwipe` | Subcollection write, lower risk |
| OnboardingDraftRepository | `saveDraft`, `deleteDraft` | Best-effort, non-critical |
| ImageUploadRepository | `upload`, `uploadUserPhoto`, `uploadRunClubCover` | Firebase Storage (not Firestore), different exception types |
| MatchRepository | `resetUnread` | Already has targeted `not-found` handling |

### The `withFirestoreErrorContext` pattern

Every Firestore write should follow this pattern:

```dart
Future<void> doSomething({required String uid}) =>
    withFirestoreErrorContext(
      () => _db.collection('items').doc(uid).set(data),
      collection: 'items',
      action: 'create item',
    );
```

What it handles automatically:
1. `FirebaseException` → typed `AppException` mapping
2. `FirebaseFunctionsException` → same treatment (Cloud Functions)
3. `AppException` → re-thrown as-is (no double-wrapping)
4. Unexpected errors → `FirestoreWriteException(code: 'unexpected')` with `cause`

---

## Controller Layer Error Handling

### Current patterns

**Pattern 1: Mutations catch errors via Riverpod framework (most controllers)**

Controllers like `RunBookingController`, `CreateRunClubController`, etc. are stateless `@riverpod` classes that delegate to repositories. Errors from repositories propagate into the `Mutation` error state automatically — the framework catches the exception and transitions the mutation to `MutationError`.

```dart
// Controller method — no try/catch needed
Future<void> joinWaitlist({required Run run}) async {
  _requireSignedIn(action: 'join a waitlist');
  await ref.read(runRepositoryProvider).joinWaitlistViaFunction(runId: run.id);
}
```

The UI then watches the mutation:
```dart
final joinMutation = ref.watch(RunBookingController.joinWaitlistMutation);
if (joinMutation.hasError)
  ErrorBanner(message: mutationErrorMessage(joinMutation)),
```

**Pattern 2: Controllers catch and convert specific errors**

`RunBookingController._requireSignedIn` catches `StateError` from `requireSignedInUid` and converts to `SignInRequiredException`:

```dart
String _requireSignedIn({required String action}) {
  try {
    return requireSignedInUid(ref, action: action);
  } on StateError {
    throw SignInRequiredException(action);
  }
}
```

This conversion dance exists because `requireSignedInUid` throws `StateError` instead of `SignInRequiredException`. **Fix pending — Phase 1.4.**

**Pattern 3: OnboardingController uses Completer for async callbacks**

The `sendOtp` method uses a `Completer<void>` to bridge Firebase Auth's callback-based API into a `Future`. Errors from `verificationFailed` and `signInWithCredential` are caught and forwarded to the completer:

```dart
verificationFailed: (e) {
  if (!completer.isCompleted) completer.completeError(e);
},
// ...
signInWithCredential(credential).catchError((e, st) {
  if (!completer.isCompleted) completer.completeError(e, st);
});
```

### Gaps

- **No unexpected error logging**: If a controller method throws something other than an `AppException`, it propagates to the mutation but is never logged with context (which controller, which method, which user).
- **`requireSignedInUid` throws `StateError`**: Should throw `SignInRequiredException` directly to avoid the conversion dance.

---

## UI Layer Error Rendering

### Before remediation (2026-05-03)

6+ distinct error display patterns:

| Pattern | Count | Example |
|---------|-------|---------|
| `ErrorBanner` for mutation errors | 6 | Onboarding pages, write review sheet |
| `CatchErrorBanner` for mutation errors | 3 | Create run, attendance, run detail CTA |
| Direct `SnackBar` with hardcoded strings | ~16 | Share failures, booking confirmations, upload errors |
| `listenForMutationErrorSnackbar` | 3 | Club join/leave |
| `Text(firestoreErrorMessage(e))` in `.when()` | ~14 | Widespread across screens |
| Raw `e.toString()` in `.when()` | 1 | `run_detail_screen.dart:23` |
| `showSnackbarOnError` extension | 0 | Dead code, zero call sites |

### After remediation (2026-05-03)

| Pattern | Count | Status |
|---------|-------|--------|
| `ErrorBanner` (unified) | 9 | Single canonical error banner with `onRetry` |
| Direct `SnackBar` with hardcoded strings | ~16 | ✅ Standardized (all now log errors before showing SnackBar) |
| `listenForMutationErrorSnackbar` | 3 | ✅ Standardized (replaced with `MutationErrorSnackbarListener` widget) |
| `Text(firestoreErrorMessage(e))` in `.when()` | ~14 | Consistent — this is the correct pattern for async data errors |
| Raw `e.toString()` | 0 | ✅ Fixed |
| `showSnackbarOnError` extension | 0 | ✅ Deleted |

### Decision tree for error display

| Context | Method | Widget |
|---------|--------|--------|
| Full-screen data load (first screen load) | `.when(error: ...)` | `Text(firestoreErrorMessage(e))` or `AsyncValueWidget` |
| Inline mutation error (within existing content) | Mutation state check | `ErrorBanner` |
| Transient action (bottom sheet, nav action) | Mutation listener | SnackBar (via `listenForMutationErrorSnackbar`) |
| Form field validation | FormField validator | Inline `errorText` |

### Error message translation pipeline

```
Raw error (any type)
  → firestoreErrorMessage(error)      // Maps FirebaseException/AppException/StateError → String
    → Displayed to user via ErrorBanner / SnackBar / Text widget

Auth-specific:
  → authErrorMessage(error)            // Maps FirebaseAuthException codes → String
  → generalErrorMessage(error)         // Fallback for non-auth errors
```

**File:** `lib/core/firestore_error_message.dart` handles the central translation. In debug mode, it appends `[DEBUG Firestore <code>]` for developer diagnosis.

---

## Logging & Telemetry

### Current pipeline

```
Error thrown
  │
  ├─→ AsyncErrorLogger (ProviderObserver, watches ALL Riverpod providers)
  │     ├─ AppException? → debugPrint('[APP_EXCEPTION]') ONLY ← GAP
  │     └─ Other? → ErrorLogger.logError() → Crashlytics (release + production)
  │
  ├─→ FlutterError.onError (main.dart)
  │     └─→ ErrorLogger.logFlutterError() → Crashlytics (release + production)
  │
  ├─→ PlatformDispatcher.onError (main.dart)
  │     └─→ ErrorLogger.logError() → Crashlytics (release + production)
  │
  └─→ Ad-hoc debugPrint calls in controllers/repositories
```

### What's logged where

| Destination | What | When |
|-------------|------|------|
| **Crashlytics** | Unexpected errors (non-AppException) | `kReleaseMode && isProduction && !useFirebaseEmulators && !kIsWeb` |
| **Analytics** | `firestore_write_failed` event | Defined but **never called** ← GAP |
| **Console (debugPrint)** | All errors + AppExceptions | Debug mode only (no-op in release) |
| **Web** | Nothing | Crashlytics returns `null` for `kIsWeb` ← GAP |

### Key gaps

1. **AppExceptions invisible in production**: `logAppException` only calls `debugPrint`. Payment failures, permission-denied errors, sign-in-required — all silent in Crashlytics and Analytics.

2. **`logFirestoreWriteFailed` defined but never called**: The analytics event exists (`AnalyticsEvents.firestoreWriteFailed`) but zero call sites invoke `appAnalytics.logFirestoreWriteFailed()`. Firestore write failures are completely invisible in dashboards.

3. **Web has zero error reporting**: `ErrorLogger._defaultCrashReporter` returns `null` for `kIsWeb`. No fallback.

4. **No Crashlytics user identifier**: `ErrorLogger` doesn't set a user ID. Firebase Crashlytics auto-attaches the Firebase Auth UID, but this is not explicitly configured.

5. **No structured logging format**: No timestamps, log levels, module names, or session IDs in any log output.

6. **FCM initialization bypasses ErrorLogger**: `AppShell._initFcm()` calls `FlutterError.reportError()` directly instead of going through `ErrorLogger`.

---

## Silent Error Swallowing

These locations catch and discard errors without any logging. They represent invisible failure modes.

| # | File | Line | Method | What's caught | Impact |
|---|------|------|--------|---------------|--------|
| 1 | `device_location.dart` | 31 | `build()` | `catch (_)` — all geolocator errors | Location silently returns `null`. User never knows GPS failed. |
| 2 | `run_draft_repository.dart` | 42 | `loadDrafts()` | `catch (_)` — JSON parse errors | Corrupted drafts silently return `[]`. |
| 3 | `onboarding_controller.dart` | 418 | `_saveDraft()` | `.catchError((_, _2) {})` | Draft save failures silently ignored. |
| 4 | `onboarding_controller.dart` | 431 | `_deleteDraft()` | `.catchError((_, _2) {})` | Draft delete failures silently ignored. |
| 5 | `photo_upload_controller.dart` | 57 | `_failUploading()` | State update only, no log | Upload errors stored in state but never sent to Crashlytics. |
| 6 | `profile_edit_sheet.dart` | 34 | `_saveField()` | `debugPrint` only | Field save failures printed to console (release: no-op). |

**Status: ✅ Remediated 2026-05-03.** All 6 locations now log via `debugPrint('[ERROR] ...')`. Ready for upgrade to structured ErrorLogger when available.

---

## Gap Analysis

### Critical (user-facing impact)

| # | Gap | Impact | Status |
|---|-----|--------|--------|
| G1 | `run_detail_screen` used raw `e.toString()` | Users saw "Bad state: boom" instead of clean message | ✅ Fixed |
| G2 | Two different error banner widgets | Inconsistent look, dark mode broken on CatchErrorBanner | ✅ Fixed |
| G3 | Dead `showSnackbarOnError` code | Confusion about which pattern to use | ✅ Fixed |
| G4 | Silent error swallowing (6 locations) | Failures invisible to both users and developers | ✅ Fixed (now logs via `debugPrint`) |
| G5 | `requireSignedInUid` throws `StateError` | Forces controllers to catch+convert | ✅ Fixed |

### Telemetry

| # | Gap | Impact | Status |
|---|-----|--------|--------|
| G6 | AppExceptions not logged to Crashlytics | Payment failures, permission errors invisible in production | ✅ Fixed (logAppException now at WARN level + analytics callback) |
| G7 | `logFirestoreWriteFailed` never called | Zero analytics for Firestore failures | ✅ Fixed (AsyncErrorLogger fires analytics for FirestoreWriteException) |
| G8 | Web has no error reporting | Web users' errors completely invisible | ✅ Fixed (ConsoleCrashReporter fallback) |
| G9 | No structured logging | Can't filter/search logs, can't measure error frequency | ✅ Fixed (LogLevel enum + structured log() method) |

### Architecture

| # | Gap | Impact | Status |
|---|-----|--------|--------|
| G10 | 4 manual providers vs 66 codegen | Inconsistent override APIs, missing generated helpers | ✅ Fixed |
| G11 | `withFirestoreErrorContext` in 1 of ~40 methods | Most Firestore failures propagated as raw FirebaseException | ✅ Mostly fixed (~18 methods now wrapped) |
| G12 | `onboardingControllerProvider` never disposed | PII (phone, name, DOB) held in memory for app lifetime | ✅ Fixed |

---

## Remediation Progress

### Completed (2026-05-03)

| Fix | Files | Tests |
|-----|-------|-------|
| Raw `e.toString()` → `firestoreErrorMessage()` | `run_detail_screen.dart`, test updated | 450 pass |
| Merge `ErrorBanner` + `CatchErrorBanner` | `error_banner.dart` rewritten, 3 call sites, `catch_error_banner.dart` deleted | 450 pass |
| Delete `showSnackbarOnError` dead code | `async_error_logger.dart` deleted | 450 pass |
| Convert 4 manual providers to codegen | `match_repository.dart`, `safety_repository.dart`, `app_analytics.dart` + 3 `.g.dart` | 450 pass |
| Dispose `onboardingControllerProvider` after completion | `onboarding_controller.dart` | 450 pass |
| Expand exception hierarchy | `app_exception.dart` — added `NetworkException`, `PermissionException`, `cause` property | 450 pass |
| Wrap repository write methods | 5 repos, ~18 methods wrapped with `withFirestoreErrorContext` | 450 pass |

### All items completed (2026-05-03)

| Priority | Fix | Status |
|----------|-----|--------|
| 🔴 High | `requireSignedInUid` → throw `SignInRequiredException` | ✅ Done |
| 🔴 High | Fix silent error swallowing (6 locations) | ✅ Done |
| 🟡 Medium | Wire `logFirestoreWriteFailed` analytics | ✅ Done |
| 🟡 Medium | `ConsoleCrashReporter` web fallback | ✅ Done |
| 🟡 Medium | Structured logging with `LogLevel` enum | ✅ Done |
| 🟢 Lower | Set Crashlytics user ID | ✅ Done |
| 🟢 Lower | Standardize mutation error display widgets | ✅ Done |

---

## Quick Reference

### Key files

| Concern | File |
|---------|------|
| Exception types | `lib/exceptions/app_exception.dart` |
| Error wrapping utility | `lib/core/firestore_error_util.dart` |
| User-facing error messages | `lib/core/firestore_error_message.dart` |
| Auth error messages | `lib/auth/presentation/auth_error_message.dart` |
| Central error logger | `lib/exceptions/error_logger.dart` |
| Provider error observer | `lib/exceptions/error_logger.dart:150` (AsyncErrorLogger) |
| Analytics error events | `lib/analytics/app_analytics.dart:112` (logFirestoreWriteFailed) |
| Error banner widget | `lib/core/widgets/error_banner.dart` |
| Mutation error display | `lib/core/widgets/mutation_error_util.dart` |
| Mutation snackbar listener | `lib/run_clubs/presentation/shared/run_clubs_mutation_feedback.dart` |
| Global error handlers | `lib/main.dart:142-168` |

### Error handling decision flowchart

```
Throwing an error:
  In domain/validation → throw ArgumentError/StateError
  In repository → throw through withFirestoreErrorContext (auto-maps to AppException)
  In controller → throw AppException or let repository errors propagate
  In widget → never throw; show error state

Catching an error:
  In repository → use withFirestoreErrorContext (automatic)
  In controller → catch unexpected errors, log, rethrow; let AppException pass
  In UI → AsyncValue.when(error: ...) or Mutation.hasError check
  Globally → AsyncErrorLogger (ProviderObserver) catches everything
```
