---
doc_id: error_handling_audit
version: 2.4.0
updated: 2026-05-12
owner: recursive_audit_loop
status: active
---

# Catch Dating App — Error Handling Architecture Audit

> Active source of truth. Use `docs/README.md` for the docs ownership map and
> keep new durable error-handling decisions in this document rather than
> creating parallel trackers.

## Read Policy

Use this as the backend error-management source of truth, migration checklist,
error catalogue, and remediation map. Re-run
`dart tool/backend_error_candidates.dart` before backend error work. Stamp files
reviewed against this doc in the audit registry rather than copying findings
into new trackers.

## Current State of Truth

### 2026-05-12: Backend Error Management Hard Migration

Catch now has one backend error API for expected app-facing failures:

- `BackendErrorContext` records non-PII service/action/resource metadata.
- `withBackendErrorContext` wraps async operations.
- `withBackendErrorStream` wraps realtime/listener streams.
- `normalizeBackendError` maps raw Firebase, plugin, timeout, and unexpected
  failures into `AppException`.
- `backendErrorMessage` and `appErrorMessage` are the UI-facing message
  facades.
- `AsyncErrorLogger` emits generic backend-operation telemetry through
  `AppAnalytics.logBackendOperationFailed`.
- `tool/backend_error_candidates.dart` is the scanner for future migration
  drift.

The old Firestore-specific API was removed from production code:

- `lib/core/firestore_error_util.dart` deleted.
- `lib/core/firestore_error_message.dart` deleted.
- `lib/auth/presentation/auth_error_message.dart` deleted.
- `lib/runs/presentation/run_booking_error_message.dart` deleted.
- `FirestoreWriteException` replaced by `BackendOperationException`.
- `firestore_write_failed` analytics replaced by `backend_operation_failed`.

Current scanner proof:

```sh
dart tool/backend_error_candidates.dart --json
```

Latest result: `mustMigrate=0`, `review=153`, `migrated=136`.

`review` candidates are intentionally broad. They include direct
`.httpsCallable`, `.snapshots`, `.get`, `.set`, `.update`, `.delete`, and raw
Firebase exception references so future work can verify each backend boundary is
still wrapped. The key invariant is that `mustMigrate` remains zero.

#### Backend Error Migration Checklist

Single source of truth for this hard migration:

| Area | Locations | Status |
|---|---|---|
| Core catalogue | `lib/exceptions/app_exception.dart` | Migrated: backend context, severity, retry policy, `ValidationException`, `BackendOperationException`, storage/external metadata |
| Core wrappers | `lib/core/backend_error_util.dart`, `lib/core/backend_error_message.dart` | Migrated: futures, streams, Auth, Firestore, Functions, Storage, Remote Config, App Check, Messaging, timeout, and unexpected mappings |
| UI facade | `lib/core/app_error_message.dart`, `lib/core/widgets/mutation_error_util.dart` | Migrated: screens and mutation banners route through `appErrorMessage` / `backendErrorMessage` |
| Logging/reporting | `lib/exceptions/error_logger.dart`, `lib/analytics/app_analytics.dart`, `lib/main.dart` | Migrated: backend failures carry context into logs and analytics |
| Candidate scanner | `tool/backend_error_candidates.dart` | Added: repeatable candidate scan with `mustMigrate`, `review`, and `migrated` buckets |
| Auth | `lib/auth/data/auth_repository.dart`, `lib/auth/presentation/auth_controller.dart`, `lib/auth/presentation/phone_page.dart`, `lib/auth/presentation/otp_page.dart` | Migrated |
| Firestore reads/streams/writes | `user_profile`, `public_profile`, `runs`, `run_participation`, `saved_run`, `run_clubs`, `run_club_membership`, `reviews`, `matches`, `chats`, `swipes`, `safety`, `payments`, `notifications`, `onboarding` repositories | Migrated |
| Callable Functions | Profile edits, run/run-club/review/safety/payment/places callables | Migrated with `BackendService.functions`; payments and run booking retain domain-specific mappers |
| Firebase Storage | `lib/image_uploads/data/image_upload_repository.dart` | Migrated |
| FCM / local fallback | `lib/core/fcm_service.dart`, `lib/core/data/city_repository.dart` | Migrated/logged with backend context |
| Local/plugin side effects | Draft repositories, device location, external links/share, profile/photo controllers, share action call sites | Migrated/logged with backend context |
| Intentional review-only raw Firebase checks | `lib/core/backend_error_util.dart`, `lib/core/backend_error_message.dart`, `lib/core/app_error_message.dart`, `lib/force_update/presentation/force_update_diagnostics.dart`, `lib/matches/data/match_repository.dart`, `lib/main.dart` bootstrap handlers, test fakes | Allowed: mapper/title/dev-diagnostic/bootstrap/not-found-swallow/test seams |

Future error-management work should update this checklist instead of creating a
parallel tracker. If the scanner reports a new `mustMigrate` item, fix it in
the same pass unless it is explicitly documented here as an intentional
exception.

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
- **Firestore-only analytics** had zero effective coverage — backend failures
  outside Firestore were invisible in dashboards before the generic
  `backend_operation_failed` event.
- **6+ distinct UI error display patterns** existed across the app — `ErrorBanner`, `CatchErrorBanner`, direct `SnackBar` with hardcoded strings, raw `e.toString()`, `listenForMutationErrorSnackbar`, `AsyncValueWidget`.
- **5+ locations silently swallowed errors** without logging — `DeviceLocation`, `RunDraftRepository`, `OnboardingController`, `PhotoUploadController`, `ProfileEditSheet`.
- **Web platform had zero error reporting** — `Crashlytics` returned `null` on web with no fallback.
- **No structured logging** — no timestamps, log levels, or contextual metadata across any error path.

The 2026-05-03 remediation pass addressed the highest-impact gaps: exception
hierarchy expansion, repository write wrapping, UI consolidation, dead code
removal, and provider codegen consistency. The 2026-05-06 pass added the
branded app-facing error primitives and formalized this catalogue. The
2026-05-12 hard migration replaced the Firestore-only wrapper with a backend
operation API that covers Auth, Firestore, Functions, Storage, Messaging, Remote
Config, App Check, local cache, and external plugin actions.

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
  withBackendErrorContext / withBackendErrorStream catch backend failures
  normalizeBackendError maps raw Firebase/plugin errors to AppException
  Re-throws as AppException
  Feature repositories can add domain-specific mappers, e.g. payments/booking

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
  AppException → structured log with optional backend_operation_failed analytics
  Unexpected errors → ErrorLogger error/fatal path and Crashlytics when enabled
```

---

## Exception Hierarchy

### Current state (after 2026-05-12 migration)

```
AppException (sealed)
├── SignInRequiredException          // Auth required for action
├── NetworkException                  // connection-failed / timeout / too-many-requests
├── PermissionException               // permission-denied
├── ValidationException               // user-correctable input/backend validation
├── PaymentCancelledException         // User cancelled Razorpay
├── PaymentFailedException            // Razorpay payment failed
├── PaymentVerificationFailedException // Signature verification failed
├── PaidBookingUnsupportedException   // Platform doesn't support paid bookings
├── RunBookingFailedException         // Cloud Function booking failed
├── BackendOperationException         // Generic normalized backend failure
├── DocumentNotFoundException         // Resource doesn't exist
├── StorageException                  // Firebase Storage upload/download failure
└── ExternalActionException           // Share, URL launcher, plugin side effect
```

**File:** `lib/exceptions/app_exception.dart`

### What each exception carries

| Property | Purpose | Example |
|----------|---------|---------|
| `code` | Machine-readable identifier | `'permission-denied'`, `'timeout'` |
| `message` | User-facing description | `'The request timed out. Please try again.'` |
| `debugMessage` | Developer diagnostic, hidden from normal release UI | `'cloud_firestore/permission-denied: rules denied write'` |
| `cause` | Original error for debugging | The original `FirebaseException` |
| `context` | Non-PII backend operation metadata | `service=functions`, `action=create run`, `resource=runs` |
| `severity` | Reporting severity | `info`, `warning`, `error`, `fatal` |
| `retryable` | Whether retry UI/telemetry should treat it as retryable | `true` for network/timeouts |

`toString()` returns `message` so exceptions display cleanly without the "Exception:" prefix.

### How Firebase exceptions map to domain exceptions

This mapping happens in `lib/core/backend_error_util.dart`.

| FirebaseException.code | AppException |
|------------------------|--------------|
| `permission-denied` | `PermissionException` |
| `unauthenticated` | `SignInRequiredException` |
| `unavailable` | `NetworkException('connection-failed')` |
| `deadline-exceeded` | `NetworkException('timeout')` |
| `resource-exhausted` | `NetworkException('too-many-requests')` |
| `not-found` | `DocumentNotFoundException` |
| Any other code | `BackendOperationException` (preserves original code) |

The same common mapping is used across Firestore and Functions. Auth, Storage,
Remote Config, App Check, Messaging, payment, and run-booking paths add
service-specific copy and domain mappers where needed.

### What's missing from the hierarchy

- No dedicated `TimeoutException` subclass. Current policy is to keep timeout
  under `NetworkException('timeout')` unless a timeout has product behavior
  that differs from other connectivity failures.
- No dedicated `LocationException`. Location remains optional and is currently
  normalized/logged under `BackendService.external`.

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
| `ValidationException` | Firebase/Auth validation code or `validation-failed` | User-correctable invalid input. | Auth mapper or reusable validation boundary | Inline form/banner copy |
| `PaymentCancelledException` | `payment-cancelled` | User cancelled checkout. | Razorpay callback | Usually non-fatal snackbar or inline payment state |
| `PaymentFailedException` | `payment-failed` | Razorpay returned a failed payment. | Razorpay callback | Payment screen inline error / snackbar |
| `PaymentVerificationFailedException` | `payment-verification-failed` | Backend could not verify payment signature/status. | Payment verification function | Payment screen error with support-oriented copy |
| `PaidBookingUnsupportedException` | `paid-booking-unsupported` | Paid bookings are unavailable on this platform. | Payment repository platform guard | Payment or booking action error |
| `RunBookingFailedException` | `run-booking-failed` | Booking Cloud Function rejected or failed the run signup. | Run booking/payment flow | Run detail/dashboard action error |
| `BackendOperationException` | Firebase code or `unexpected` | Generic normalized backend failure after context wrapping. | `withBackendErrorContext`, `withBackendErrorStream`, `normalizeBackendError` | Error mapper plus analytics/logging |
| `DocumentNotFoundException` | `not-found` | Expected document no longer exists. | Firestore not-found mapping or missing document guard | Not-found state, not a generic crash |
| `StorageException` | Firebase Storage code or `storage-error` | Upload/download failed. | Firebase Storage mapper | Inline upload/profile/run-club error |
| `ExternalActionException` | `external-action-error` | URL/share/plugin action failed. | External action seams | Snackbar or inline action failure |

### Candidate Catalogue Additions

| Candidate | Add When | Avoid When |
|-----------|----------|------------|
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

### After hard migration (2026-05-12)

| Boundary | Coverage |
|------------|----------|
| Auth | Auth streams, phone verification, OTP credential sign-in, credential sign-in, and sign-out are wrapped with `BackendService.auth`. |
| Firestore repositories | Reads, streams, writes, edge-doc mutations, and query helpers across user profile, public profile, runs, run participation, saved runs, run clubs, run club membership, reviews, matches, chats, swipes, safety, payments, notifications, and onboarding drafts are wrapped. |
| Callable Functions | Profile update, run/run-club/review/safety/payment/places callables are wrapped with `BackendService.functions`; payments and run booking keep domain-specific mappers. |
| Firebase Storage | Profile photo and run-club cover uploads are wrapped with `BackendService.storage`. |
| Messaging/config/local side effects | FCM token persistence, city config fallback, local draft parsing, location, links, share, and controller-owned side effects normalize/log errors with `BackendErrorContext`. |

### Remaining review-only candidates

`tool/backend_error_candidates.dart` intentionally reports direct Firebase
calls even when they are already inside `withBackendErrorContext` or
`withBackendErrorStream`. The invariant is `mustMigrate=0`; `review` entries
must be inspected when touched and should stay documented here when they are
intentional.

### The `withBackendErrorContext` pattern

Every backend operation should follow one of these patterns:

```dart
Future<void> doSomething({required String uid}) =>
    withBackendErrorContext(
      () => _db.collection('items').doc(uid).set(data),
      context: const BackendErrorContext(
        service: BackendService.firestore,
        action: 'create item',
        resource: 'items',
      ),
    );
```

```dart
Stream<Item?> watchItem(String id) => withBackendErrorStream(
  () => _items.doc(id).snapshots().map((doc) => doc.data()),
  context: const BackendErrorContext(
    service: BackendService.firestore,
    action: 'watch item',
    resource: 'items',
  ),
);
```

What it handles automatically:
1. `FirebaseException` → typed `AppException` mapping
2. `FirebaseFunctionsException` and `FirebaseAuthException` → service-aware
   backend mapping
3. `AppException` → re-thrown as-is (no double-wrapping)
4. Timeout and plugin-side failures → retry-aware app exceptions
5. Unexpected errors → `BackendOperationException(code: 'unexpected')` with
   context and cause

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

Backend-specific:
  → backendErrorMessage(error)         // Normalizes Firebase/Auth/Storage/Functions/etc.
  → appErrorMessage(..., context: ...)
```

`lib/core/app_error_message.dart` is the UI facade. It delegates to
`backendErrorMessage` while adding context-specific titles. In debug mode,
`backendErrorMessage` can append non-PII diagnostics for developer diagnosis.

---

## Logging & Telemetry

### Current pipeline

```
Error thrown
  │
  ├─→ AsyncErrorLogger (ProviderObserver, watches ALL Riverpod providers)
  │     ├─ AppException? → ErrorLogger.logAppException(level: warn)
  │     ├─ BackendOperationException? → optional backend_operation_failed analytics
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
| **Analytics** | `backend_operation_failed` event | Via `AsyncErrorLogger` when an `AppException` includes backend context |
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
| G7 | Firestore-only backend telemetry | Non-Firestore backend failures were not consistently measurable | ✅ Fixed (`AsyncErrorLogger` fires `backend_operation_failed` for contextual backend exceptions) |
| G8 | Web has no error reporting | Web users' errors completely invisible | ✅ Fixed (ConsoleCrashReporter fallback) |
| G9 | No structured logging | Can't filter/search logs, can't measure error frequency | ✅ Fixed (LogLevel enum + structured log() method) |

### Architecture

| # | Gap | Impact | Status |
|---|-----|--------|--------|
| G10 | 4 manual providers vs 66 codegen | Inconsistent override APIs, missing generated helpers | ✅ Fixed |
| G11 | Firestore-only wrapper coverage | Auth, Storage, Functions, Messaging, and local/plugin side effects had inconsistent mapping | ✅ Fixed (`withBackendErrorContext`, `withBackendErrorStream`, and `normalizeBackendError` are the single backend API) |
| G12 | `onboardingControllerProvider` never disposed | PII (phone, name, DOB) held in memory for app lifetime | ✅ Fixed |

---

## Remediation Progress

### Completed (2026-05-03)

| Fix | Files | Tests |
|-----|-------|-------|
| Raw `e.toString()` → app error messages | `run_detail_screen.dart`, test updated | 450 pass |
| Merge `ErrorBanner` + `CatchErrorBanner` | `error_banner.dart` rewritten, 3 call sites, `catch_error_banner.dart` deleted | 450 pass |
| Delete `showSnackbarOnError` dead code | `async_error_logger.dart` deleted | 450 pass |
| Convert 4 manual providers to codegen | `match_repository.dart`, `safety_repository.dart`, `app_analytics.dart` + 3 `.g.dart` | 450 pass |
| Dispose `onboardingControllerProvider` after completion | `onboarding_controller.dart` | 450 pass |
| Expand exception hierarchy | `app_exception.dart` — added `NetworkException`, `PermissionException`, `cause` property | 450 pass |
| Wrap repository write methods | 5 repos, ~18 methods wrapped with the original Firestore helper | 450 pass |
| Backend error hard migration | All Firebase backend services and plugin/local side-effect boundaries use the unified backend error API | 101 focused tests pass |

### All items completed (2026-05-03)

| Priority | Fix | Status |
|----------|-----|--------|
| 🔴 High | `requireSignedInUid` → throw `SignInRequiredException` | ✅ Done |
| 🔴 High | Fix silent error swallowing (6 locations) | ✅ Done |
| 🟡 Medium | Wire backend failure analytics | ✅ Done |
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
| Error wrapping utility | `lib/core/backend_error_util.dart` |
| User-facing backend messages | `lib/core/backend_error_message.dart` |
| UI-facing title/message facade | `lib/core/app_error_message.dart` |
| Central error logger | `lib/exceptions/error_logger.dart` |
| Provider error observer | `lib/exceptions/error_logger.dart:150` (AsyncErrorLogger) |
| Analytics error events | `lib/analytics/app_analytics.dart` (`logBackendOperationFailed`) |
| Migration scanner | `tool/backend_error_candidates.dart` |
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
  In repository → throw through withBackendErrorContext / withBackendErrorStream
  In controller → throw AppException or let repository errors propagate through Mutation/AsyncValue
  In widget → never throw; show error state

Catching an error:
  In repository → use withBackendErrorContext / withBackendErrorStream (automatic)
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
