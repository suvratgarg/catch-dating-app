---
doc_id: error_handling_audit
version: 2.3.1
updated: 2026-05-06
owner: recursive_audit_loop
status: snapshot
---

# Catch Dating App — Error Handling Architecture Audit

> Audit snapshot. Re-verify counts and remediation status before treating this
> file as current. Use `docs/README.md` for the docs ownership map and keep new
> durable error-handling decisions in this document rather than creating parallel
> trackers.

## Read Policy

Use this as an error-handling snapshot and remediation map. Re-run focused
searches/tests before treating counts as current. Stamp files reviewed against
this doc in the audit registry rather than copying findings into new trackers.

## Current State of Truth

### 2026-05-06: Error Catalogue Decision

Yes, the app should invest in a curated sealed error catalogue, but not in a
new sealed class for every possible vendor code, screen copy variant, or
one-off edge case.

The app already has a sealed `AppException` root in
`lib/exceptions/app_exception.dart`. That is the correct foundation. Going
forward, add a new `AppException` subclass only when the error is a stable
product/domain concept that code, analytics, tests, or retry behavior need to
distinguish. Do not add subclasses merely to change copy on one screen; that
belongs in `appErrorTitle`, `appErrorMessage`, feature-specific message
mappers, or UI context.

Use this rule:

- **Typed exception:** the app needs branching, analytics, retry rules,
  auditing, or tests around the error.
- **Mapped message/code:** the app only needs better user-facing copy for an
  existing error family.
- **Logged unexpected error:** the error is a bug or unknown failure path and
  should not become a product contract until it repeats or requires UX.

The error catalogue lives in this document. Any pass that adds, renames, or
removes an `AppException`, error code, error mapper, app error context, or
error primitive must update this document and stamp `ERROR-CATALOG-001`.

### 2026-05-06: Branded Error Surface Foundation

The first `ERROR-UI-QUEUE` implementation pass created the canonical app-facing
error primitives:

- `CatchErrorState` for branded error content.
- `CatchErrorScaffold` for root-tab/full-screen load failures.
- `CatchSliverErrorState` for sliver-native load failures.
- `CatchInlineErrorState` for compact section-level failures.
- `showCatchErrorSnackBar` for transient action failures.
- `appErrorMessage` / `appErrorTitle` as UI-facing message/title facades over
  existing Firestore and auth mappers.

`CatchFrameworkErrorView` remains separate for Flutter framework/build errors
because `ErrorWidget.builder` runs while the widget tree may already be
unstable. `ErrorBanner` remains the inline mutation/form error primitive.
`CatchErrorText` was removed after the hard migration; do not reintroduce
compatibility wrappers for app-facing load failures unless there is a specific
measured need.

Migrated in the first branded batch: Dashboard root errors, Profile root
errors, Run Clubs list/detail errors, Chats list/thread errors, Catches hub
errors, and the swipe queue error branch. The scanner reports the remaining raw
error-surface candidates so later passes can migrate payments, routing
wrappers, run detail, run map, attendance, filters, and recap screens.

### Error 101 for Catch

In Dart, exceptions are unchecked: methods do not declare what they throw, and
any non-null object can technically be thrown. Production code should throw
typed `Exception`/`Error` objects rather than strings or ad hoc objects. For
this app, that means repositories and controllers should throw typed
`AppException`s for expected product failures and let truly unexpected bugs flow
to `ErrorLogger`.

Separate these concerns:

- **Origin:** Firebase, platform plugins, validation code, repositories,
  controllers, widgets, or Flutter itself.
- **Classification:** expected product failure, network/offline condition,
  permission/auth problem, missing data, validation failure, user-cancelled
  action, or unexpected bug.
- **Transport:** `Future`, Firestore `Stream`, Riverpod `AsyncValue`, Riverpod
  `Mutation`, Flutter framework callback, or platform-dispatcher callback.
- **Presentation:** full-screen, sliver, inline section, form/banner, snackbar,
  or framework-crash fallback.
- **Telemetry:** `AsyncErrorLogger`, `ErrorLogger`, Crashlytics, analytics, and
  local debug logs.

The core habit is: classify low-level errors once near the boundary, propagate
typed errors through providers/controllers, render them with a branded surface,
and log unexpected failures without leaking stack traces or vendor messages to
normal users.

**Date:** 2026-05-06
**Scope:** Current error catalogue, propagation rules, UI primitives, naming
conventions, and progressive remediation plan.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [The Error Pipeline](#the-error-pipeline)
3. [Exception Hierarchy](#exception-hierarchy)
4. [Error Catalogue](#error-catalogue)
5. [Naming Conventions](#naming-conventions)
6. [Repository Layer Error Handling](#repository-layer-error-handling)
7. [Controller Layer Error Handling](#controller-layer-error-handling)
8. [UI Layer Error Rendering](#ui-layer-error-rendering)
9. [Logging & Telemetry](#logging--telemetry)
10. [Silent Error Swallowing](#silent-error-swallowing)
11. [Gap Analysis](#gap-analysis)
12. [Remediation Progress](#remediation-progress)
13. [References](#references)

---

## Executive Summary

The app's error handling grew organically without a deliberate strategy. Original
findings from the first audit were:

- **11 of 16 repositories** originally had zero error handling — raw `FirebaseException` propagated unchecked to the UI. Now down to ~3 after the 2026-05-03 remediation pass.
- **`AppException` subclasses were invisible in production** — `logAppException` only called `debugPrint` (no-op in release). No Crashlytics or Analytics events for business-impacting errors like payment failures.
- **`logFirestoreWriteFailed` analytics event** was defined but had zero call sites — Firestore write failures were invisible in dashboards.
- **6+ distinct UI error display patterns** existed across the app — `ErrorBanner`, `CatchErrorBanner`, direct `SnackBar` with hardcoded strings, raw `e.toString()`, `listenForMutationErrorSnackbar`, `AsyncValueWidget`.
- **5+ locations silently swallowed errors** without logging — `DeviceLocation`, `RunDraftRepository`, `OnboardingController`, `PhotoUploadController`, `ProfileEditSheet`.
- **Web platform had zero error reporting** — `Crashlytics` returned `null` on web with no fallback.
- **No structured logging** — no timestamps, log levels, or contextual metadata across any error path.

The 2026-05-03 remediation pass addressed the highest-impact gaps: exception
hierarchy expansion, repository write wrapping, UI consolidation, dead code
removal, and provider codegen consistency. The 2026-05-06 pass added the
branded app-facing error primitives and formalized this catalogue.

---

## The Error Pipeline

The error lifecycle across layers:

```
Layer 1: Origin
  Repository throws FirebaseException / FirebaseFunctionsException
  Platform plugins throw plugin exceptions
  Domain validation currently throws ArgumentError / StateError
  Framework build/layout failures throw through FlutterError

Layer 2: Capture (Repository)
  withFirestoreErrorContext catches FirebaseException
  Maps to typed AppException (PermissionException, NetworkException, etc.)
  Re-throws as AppException
  Feature repositories may normalize non-Firestore failures, e.g. payments

Layer 3: Propagation (Controller / Provider)
  AppException propagates through Riverpod AsyncValue or Mutation state
  Unexpected exceptions propagate to AsyncErrorLogger / global handlers

Layer 4: Display (UI)
  AsyncValueWidget / AsyncValueSliverWidget → CatchErrorState family
  Mutation.hasError → ErrorBanner for inline/form failures
  Transient actions → showCatchErrorSnackBar
  Framework crash → CatchFrameworkErrorView

Layer 5: Telemetry
  AsyncErrorLogger (ProviderObserver) → ErrorLogger
  AppException → warning log; FirestoreWriteException may fire analytics
  Unexpected errors → ErrorLogger error/fatal path and Crashlytics when enabled
```

---

## Exception Hierarchy

### Current state (after 2026-05-06 remediation)

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

**File:** `lib/exceptions/app_exception.dart`

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

- No `ValidationException` for reusable domain/product validation errors.
  Local `ArgumentError` / `StateError` is still acceptable for developer
  misuse, constructor invariants, and private helper preconditions.
- No `StorageException` / `ImageUploadException` for Firebase Storage upload
  failures. This is a good candidate because image upload failures are
  user-facing and need consistent retry/copy.
- No `ExternalActionException` for URL launches, share sheets, store launches,
  and other plugin side effects. Add this only when a touched flow needs
  user-facing retry/analytics beyond a simple snackbar.
- No dedicated `TimeoutException` subclass. Current policy is to keep timeout
  under `NetworkException('timeout')` unless a timeout has product behavior
  that differs from other connectivity failures.

---

## Error Catalogue

This catalogue is the durable source of truth for expected app-level failures.
When adding a row, update the subclass, mapper, UI copy, and tests in the same
pass.

| Exception | Code | Meaning | Origin | User Surface |
|-----------|------|---------|--------|--------------|
| `SignInRequiredException` | `sign-in-required` | User must be signed in before an action can proceed. | Auth/session guard, Firebase unauthenticated codes | Inline banner, snackbar, or auth context title |
| `NetworkException` | `connection-failed`, `timeout`, `too-many-requests` | Connectivity, deadline, or rate-limit failure. | Firestore / Functions mapping | Branded retry surface, stale/offline banner when cached data exists |
| `PermissionException` | `permission-denied` | User is not allowed to perform the action. | Firestore / Functions security failure | Branded error surface or inline mutation error |
| `PaymentCancelledException` | `payment-cancelled` | User cancelled checkout. | Razorpay callback | Usually non-fatal snackbar or inline payment state |
| `PaymentFailedException` | `payment-failed` | Razorpay returned a failed payment. | Razorpay callback | Payment screen inline error / snackbar |
| `PaymentVerificationFailedException` | `payment-verification-failed` | Backend could not verify payment signature/status. | Payment verification function | Payment screen error with support-oriented copy |
| `PaidBookingUnsupportedException` | `paid-booking-unsupported` | Paid bookings are unavailable on this platform. | Payment repository platform guard | Payment or booking action error |
| `RunBookingFailedException` | `run-booking-failed` | Booking Cloud Function rejected or failed the run signup. | Run booking/payment flow | Run detail/dashboard action error |
| `FirestoreWriteException` | Firebase code or `unexpected` | Generic data write failure after context wrapping. | `withFirestoreErrorContext` | Error mapper plus analytics/logging |
| `DocumentNotFoundException` | `not-found` | Expected document no longer exists. | Firestore not-found mapping or missing document guard | Not-found state, not a generic crash |

### Candidate Catalogue Additions

| Candidate | Add When | Avoid When |
|-----------|----------|------------|
| `ValidationException` | The same user-correctable validation failure crosses controller/repository/widget boundaries or needs shared copy/tests. | The error is a private precondition or developer misuse; keep `ArgumentError` / `StateError`. |
| `ImageUploadException` or `StorageException` | Upload failures need retry, analytics, or consistent profile/run-club copy. | A local picker cancellation or non-persistent image choice can be handled as a simple no-op. |
| `ExternalActionException` | URL/share/store/plugin side effects need consistent error UI and test seams. | The action has no retry path and a simple `showCatchErrorSnackBar` is enough. |
| `LocationException` | Location failures become user-facing and require explicit retry/permission copy. | Location is optional and failure should silently fall back to manual city selection after logging. |

---

## Naming Conventions

- Exception class names end in `Exception`, not `Error` or `Failure`.
- Use the product/domain noun first: `RunBookingFailedException`,
  `PaymentVerificationFailedException`, `DocumentNotFoundException`.
- Stable machine codes are lowercase kebab-case: `run-booking-failed`,
  `payment-verification-failed`, `connection-failed`.
- The exception `message` should be useful but should not be the only source of
  screen-specific copy. UI-facing titles and context-aware phrasing belong in
  `appErrorTitle` / `appErrorMessage` or feature message mappers.
- Do not expose stack traces, raw Firebase server messages, or plugin object
  dumps in normal app UI. Debug details can appear in debug-mode logs or
  developer-only appended diagnostics.
- Use `AppErrorContext` names that match user-facing feature domains:
  `dashboard`, `profile`, `run`, `club`, `chat`, `payments`, `auth`, or
  `generic`. Add contexts only when title/copy materially improves.
- If a subclass is added, add at least one mapper/rendering test that proves the
  user-facing copy and title remain stable.

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

**Pattern 2: Controllers use auth/session guards that throw `AppException`**

`requireSignedInUid` now throws `SignInRequiredException` directly, so feature
controllers do not need to catch a raw `StateError` just to normalize auth
failures:

```dart
final uid = requireSignedInUid(ref, action: 'join a run');
```

This is the preferred pattern for expected auth failures: throw a typed app
exception at the guard boundary and let Riverpod/mutation UI handle display.

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

- **Controller context in logs is still thin**: unexpected mutation errors are
  visible through provider/global logging, but feature/method context is not
  always explicit. Add context when a touched controller has ambiguous failures.
- **Validation errors are not yet catalogued**: repeated user-correctable
  validation failures still use `ArgumentError` / `StateError`. Promote only
  repeated product validation errors to `ValidationException`.

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

### Current state (2026-05-06)

| Pattern | Count | Status |
|---------|-------|--------|
| `CatchErrorState` family | New canonical path | Full-screen, sliver, and inline app-facing load failures |
| `AsyncValueWidget` / `AsyncValueSliverWidget` | Migrated default | Branded errors by default through `appErrorTitle` / `appErrorMessage` |
| `ErrorBanner` | Canonical mutation/form inline path | Save-before-pop forms, sheets, and persistent page actions |
| `showCatchErrorSnackBar` | Canonical transient action path | Snackbars map through `appErrorMessage` |
| `CatchFrameworkErrorView` | Framework crash fallback | Keep separate and minimal for `ErrorWidget.builder` |
| `CatchErrorText` | Removed | Do not reintroduce as a compatibility layer |
| Raw `Center(Text(...))` error branches | Scanner-tracked candidates | Migrate in `ERROR-UI-QUEUE` batches |

### Decision tree for error display

| Context | Method | Widget |
|---------|--------|--------|
| Full-screen/root-tab data load | `AsyncValue` error or route guard failure | `CatchErrorScaffold` |
| Sliver-native screen load | `AsyncValue` error inside `CustomScrollView` | `CatchSliverErrorState` |
| Section/card failure | Section-level provider or stale refresh failure | `CatchInlineErrorState` |
| Inline mutation/form failure | Mutation state check | `ErrorBanner` |
| Transient action failure | Mutation listener or caught action error | `showCatchErrorSnackBar` |
| Form field validation | FormField validator | Inline `errorText` |
| Framework/build/layout crash | `ErrorWidget.builder` | `CatchFrameworkErrorView` |
| True empty state | successful data load with no items | `CatchEmptyState` |

### Error message translation pipeline

```
Raw error (any type)
  → appErrorTitle(error, context: ...)
  → appErrorMessage(error, context: ...)
    → CatchErrorState / ErrorBanner / showCatchErrorSnackBar

Auth-specific:
  → authErrorMessage(error)            // Maps FirebaseAuthException codes → String
  → appErrorMessage(..., context: auth)

Firestore/data-specific:
  → firestoreErrorMessage(error)       // Maps FirebaseException/AppException/StateError → String
```

`lib/core/app_error_message.dart` is the UI facade. It delegates to
`firestoreErrorMessage` and `authErrorMessage`, while adding context-specific
titles. In debug mode, `firestoreErrorMessage` can append Firestore diagnostic
details for developer diagnosis.

---

## Logging & Telemetry

### Current pipeline

```
Error thrown
  │
  ├─→ AsyncErrorLogger (ProviderObserver, watches ALL Riverpod providers)
  │     ├─ AppException? → ErrorLogger.logAppException(level: warn)
  │     ├─ FirestoreWriteException? → optional firestore_write_failed analytics
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
| **Analytics** | `firestore_write_failed` event | Via `AsyncErrorLogger` when a `FirestoreWriteException` includes collection/action context |
| **Console (debugPrint)** | Structured local logs, AppExceptions, unexpected errors | Debug/local visibility path |
| **Web** | Console fallback | `ConsoleCrashReporter` fallback when Crashlytics is unavailable |

### Key gaps

1. **Controller/mutation context is uneven**: provider-level logging sees the
   error, but not every controller failure includes feature/action metadata.

2. **Expected AppExceptions are warning-level by default**: this is intentional
   to avoid polluting crash dashboards with user-correctable states, but
   product-significant expected failures should still emit analytics where
   useful.

3. **Error catalogue coverage is incomplete**: image uploads, reusable
   validation failures, external action failures, and optional location failures
   are still handled by local logic rather than typed app-level exceptions.

4. **Some raw UI branches remain**: scanner candidates remain in payments,
   routing wrappers, run detail, run map, attendance, filters, and run recap.

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
| UI-facing title/message facade | `lib/core/app_error_message.dart` |
| Auth error messages | `lib/auth/presentation/auth_error_message.dart` |
| Central error logger | `lib/exceptions/error_logger.dart` |
| Provider error observer | `lib/exceptions/error_logger.dart:150` (AsyncErrorLogger) |
| Analytics error events | `lib/analytics/app_analytics.dart:112` (logFirestoreWriteFailed) |
| Branded error surfaces | `lib/core/widgets/catch_error_state.dart` |
| Branded error snackbar | `lib/core/widgets/catch_error_snackbar.dart` |
| Error banner widget | `lib/core/widgets/error_banner.dart` |
| Mutation error display | `lib/core/widgets/mutation_error_util.dart` |
| Mutation snackbar listener | `lib/core/widgets/mutation_error_snackbar_listener.dart` |
| Global error handlers | `lib/main.dart:142-168` |

### Error handling decision flowchart

```
Throwing an error:
  In shared product failure → throw an AppException subclass
  In private validation/preconditions → throw ArgumentError/StateError
  In repository → throw through withFirestoreErrorContext (auto-maps to AppException)
  In controller → throw AppException or let repository errors propagate through Mutation/AsyncValue
  In widget → never throw; show error state

Catching an error:
  In repository → use withFirestoreErrorContext (automatic)
  In controller → catch only when adding domain context; otherwise let AppException pass
  In UI → AsyncValueWidget/AsyncValueSliverWidget or Mutation.hasError check
  Globally → AsyncErrorLogger (ProviderObserver) catches everything
```

### Progressive implementation plan

| Phase | Work | Proof |
|-------|------|-------|
| 1 | Keep migrating `ERROR-UI-QUEUE` raw candidates to `CatchErrorState` family. | Scanner raw error candidate count decreases or each retained candidate is justified. |
| 2 | Add typed catalogue entries only for repeated stable product failures: likely image upload/storage, reusable validation, external action, and location. | New subclass, mapper copy, tests, and catalogue row in this doc. |
| 3 | Add scanner coverage for direct raw app-facing error branches and direct string snackbars in presentation code. | `tool/widget_cleanup_scan.sh` catches new violations. |
| 4 | Add feature-level analytics for expected but product-significant failures. | ErrorLogger/analytics tests prove events fire without treating expected errors as crashes. |
| 5 | Consider generated error catalogue checks if manual drift becomes expensive. | CI or registry validates subclass/code/doc catalogue parity. |

---

## References

- Dart language error handling:
  https://dart.dev/language/error-handling
- Flutter app error handling:
  https://docs.flutter.dev/testing/errors
- Flutter `ErrorWidget.builder` contract:
  https://api.flutter.dev/flutter/widgets/ErrorWidget/builder.html
- Riverpod `AsyncValue`:
  https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html
- Riverpod mutations:
  https://riverpod.dev/docs/concepts2/mutations
- Firestore offline persistence:
  https://firebase.google.com/docs/firestore/manage-data/enable-offline
