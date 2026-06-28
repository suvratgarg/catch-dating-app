---
doc_id: error_handling_audit
version: 2.7.2
updated: 2026-06-20
owner: recursive_audit_loop
status: active
---

# Catch Dating App — Error Handling Architecture Audit

> Active source of truth. Use `docs/README.md` for the docs ownership map and
> keep new durable error-handling decisions in this document rather than
> creating parallel trackers.

## Read Policy

Use this as the app-wide error-management source of truth, migration checklist,
error catalogue, and remediation map. Re-run
`dart tool/audit/backend_error_candidates.dart` before backend error work and
`dart tool/audit/frontend_error_candidates.dart` before frontend/local/plugin
error work. Both must stay at `mustMigrate=0` and `review=0`. Keep their to-do
lists in the audit registry rather than copying findings into new trackers.
Stamp files reviewed against this doc in the audit registry.

## Current State of Truth

### 2026-06-20: Error Surface Consolidation

The error primitive family now separates visual content, placement adapters, and
delivery channels more explicitly:

- `CatchErrorState` owns the app-facing branded error content through one
  internal resolved spec and one shared body renderer.
- `CatchErrorScaffold`, `CatchSliverErrorState`, and `CatchInlineErrorState`
  remain code-level placement adapters, but no longer duplicate descriptor or
  body resolution. Widgetbook reviews them together under one Error surfaces
  entry.
- `CatchErrorBanner` remains the persistent inline mutation/form error channel
  and shares the internal inline-message shell with `CatchSurface.message`.
- `CatchMutationErrorBanner` is the new persistent Riverpod mutation adapter.
- `CatchMutationErrorListener` and `CatchMutationErrorListeners` are the
  transient snackbar boundaries for one or many mutations.
- `CatchFrameworkErrorView` remains separate for `ErrorWidget.builder`.

### 2026-06-16: Frontend / Local Error-Management Layer (APP-ERROR-INFRA-001)

The non-backend half of the error system is now in place. The backend layer
(`withBackendErrorContext` / `withBackendErrorStream`) remains the seam for
Firebase service calls; the new frontend layer is the seam for everything the
app does *locally or through a platform plugin*.

#### App operation-context API

**File:** `lib/core/app_error_context.dart`

This is the non-backend parallel to `BackendErrorContext` /
`withBackendErrorContext`. It deliberately reuses `BackendService` and
`BackendErrorContext` under the hood (via `toBackendContext()`) so the whole app
keeps ONE log/analytics context shape and ONE normalizer
(`normalizeBackendError`) — it does not duplicate the backend layer.

| Symbol | Shape | Use for |
|---|---|---|
| `AppOperation` | enum: `validation`, `localPersistence`, `navigation`, `plugin`, `ui`, `runtime` | Tags the failure category. `plugin` logs under `BackendService.external`; the rest under `BackendService.local`. The category is written to the `operation` log key. |
| `AppErrorContext` | `{operation, action, resource?, metadata}` → `toBackendContext()` | Non-PII frontend operation context. `resource`/`action` stay low-cardinality (e.g. `image_picker`, `pick a photo`). |
| `normalizeAppError(error, context, mapper?)` | `AppException` | Normalizes any local/plugin error to a typed exception, reusing the backend normalizer. Pass a `mapper` (or throw an `AppException`) to promote user-correctable input into `ValidationException`. |
| `withAppErrorContext(op, context, mapper?)` | `Future<T>` | Wrap plugin/local async work so thrown errors become typed app exceptions. Mirrors `withBackendErrorContext`. |
| `runLoggingAppErrors(op, context, logError, mapper?)` | `Future<bool>` | Best-effort fire-and-forget local work: runs `op`, on failure normalizes + logs via `ErrorLogger` and returns `false` instead of rethrowing. The explicit, observable replacement for bare `catch (_) {}` / `.catchError((_) {})`. |
| `logAppError(error, context, logError, mapper?)` | `void` | In a `catch` where the op legitimately continues (cleanup / UI fallback): normalize + record without rethrowing. |

Privacy rules are identical to the backend context: never put user IDs, phone
numbers, file names, message text, bios, photo URLs, exact coordinates, or
payment ids into `action`/`resource`/`metadata`.

#### Frontend candidate scanner

**File:** `tool/audit/frontend_error_candidates.dart` (run with `--json` /
`--markdown`). Modeled on the backend scanner with the same buckets. It scans
`lib` + `test` for: bare `catch (_)` / `catch (e)` swallows, `.catchError`
callbacks, raw `print`/`debugPrint` of errors, raw `throw '...'` /
`Exception` / `StateError` / `ArgumentError` (validation vs. programmer guard),
plugin side effects (picker / `launchUrl` / share / geolocation / permissions /
`SharedPreferences`), the global framework handlers
(`FlutterError.onError` / `PlatformDispatcher.onError` / `ErrorWidget.builder`),
and usage of the new op-context API.

Disposition rules (conservatism is intentional — the goal is real coverage, not
churn):

- **verified** — a caught error is normalized/logged, rethrown (or rethrown as a
  typed exception), forwarded to a completer / `FlutterError.reportError`,
  surfaced to the user (snackbar / banner / error UI state), owned by a
  Riverpod mutation's error state, scoped by `.catchError(test:)`, or a plugin
  call sits inside an op-context wrapper / a file that routes its failures
  through the logger + normalizer.
- **intentional** — bootstrap-owned global handlers and pre-logger diagnostics,
  core error-infra files, sealed/exhaustiveness `StateError` guards,
  `ArgumentError` programmer-guard preconditions, internal-invariant
  `StateError`s, user-facing `StateError`s caught locally for inline
  field-error control flow, and documented best-effort swallows / defensive
  fallbacks.
- **fixture** — test/fake/mock code.
- **migrated** — call sites already using the op-context API.
- **mustMigrate / review** — must stay at 0.

Latest result: `mustMigrate=0`, `review=0`, `verified=71`, `intentional=90`,
`fixture=29`, `migrated=28`.

#### Migrated in this pass

| Area | File | Change |
|---|---|---|
| Image picker seam | `lib/image_uploads/data/image_upload_repository.dart` | `pickImage` / `pickImages` now run inside `withAppErrorContext` (plugin), so every picker call site (chat, photo upload, create-event, create-club) inherits a normalizing seam. |
| Event check-in location | `lib/events/presentation/event_check_in_location_service.dart` | Geolocator calls wrapped in `withAppErrorContext` (plugin); the user-facing service/permission guidance now throws `PermissionException` (kept user copy, reported as warnings, not crashes). |
| Onboarding validation | `lib/onboarding/presentation/onboarding_controller.dart` | Five user-correctable submit guards converted from `StateError` to `ValidationException` so they stop polluting Crashlytics as unexpected errors while keeping their copy in the gender-interest banner. |
| Launch-access validation | `lib/launch_access/data/launch_access_repository.dart` | Two user-facing `StateError`s converted to `ValidationException`; previously the surrounding `withBackendErrorContext` rewrote them to generic "unable to…" copy, so the helpful message was being lost. |
| Force-update refresh | `lib/app.dart` | Best-effort Remote Config refresh now `logAppError`s (normalized + recorded) instead of `debugPrint`-and-swallow. |
| Health activity | `lib/health_activity/data/health_activity_repository.dart` | The weekly-activity fetch fallback now `logAppError`s the swallowed plugin failure before returning the connect-CTA snapshot. |

`StateError`s that are caught locally for inline field validation (e.g.
`lib/auth/presentation/auth_input.dart`) were intentionally left as-is: they
never reach crash reporting, so converting them would be churn.

## Current State of Truth

### 2026-05-12: App-Wide Error Management Playbook

The backend hard migration fixed the most obvious weak point, but a first-class
error system is broader than Firebase service wrapping. It needs one app-level
contract for all failures that a user, developer, tester, or release dashboard
needs to understand.

Research anchors used for this playbook:

- Flutter's error handling guide separates Flutter framework callback/build
  errors from asynchronous errors that Flutter does not catch automatically:
  https://docs.flutter.dev/testing/errors
- Firebase Crashlytics for Flutter recommends wiring both
  `FlutterError.onError` and `PlatformDispatcher.instance.onError`, then using
  caught/non-fatal reporting plus custom keys/logs/user identifiers for context:
  https://firebase.google.com/docs/crashlytics/flutter/get-started and
  https://firebase.google.com/docs/crashlytics/flutter/customize-crash-reports
- Dart exceptions are unchecked, and `Error` represents programmer failures
  that callers should not normally be expected to handle:
  https://dart.dev/language/error-handling and
  https://api.dart.dev/dart-core/Error-class.html
- Riverpod exposes `AsyncValue` for data/loading/error states and
  `ProviderObserver` for lifecycle logging/analytics/debugging:
  https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html
  and https://riverpod.dev/docs/concepts2/observers
- Firebase Auth and Storage expose structured exception codes/messages, and
  Storage documents user-cancelled, permission, retry, missing-object, quota,
  and invalid-argument failures separately:
  https://firebase.google.com/docs/auth/flutter/errors and
  https://firebase.google.com/docs/storage/flutter/handle-errors

#### What "first-class" means for Catch

A finished Catch error-management system should cover these channels:

| Channel | Examples | Required handling |
|---|---|---|
| Firebase backend services | Firestore, Auth, Functions, Storage, Messaging, Remote Config, App Check | Normalize vendor exceptions once at the boundary, preserve non-PII operation context, map to `AppException`, log/report with stable codes. |
| Platform/plugin side effects | Share sheet, URL launcher, image picker, location, device permissions, app-store launches | Put behind provider/service seams, normalize expected plugin failures, treat user cancellation as low severity, log unexpected plugin bugs. |
| Frontend validation and parsing | Form input, local draft JSON, route/deep-link params, profile/run fields, date/number parsing | Convert user-correctable failures into `ValidationException` or typed local exceptions before they reach raw UI. |
| Domain/business rejections | Sign-in required, permission denied, already joined, not eligible, payment cancelled/failed, run booking rejected | Use typed `AppException` subclasses only when code, retry policy, analytics, or tests need stable branching. |
| Controller/mutation failures | Riverpod mutations, multi-step flow mutations, callback-completer APIs | Let typed errors propagate to mutation state; add action context where the repository boundary cannot explain the failure. |
| Provider/load failures | `FutureProvider`, `StreamProvider`, cached/stale refresh, empty vs error states | Render through the `CatchErrorState` family, preserve retry actions, and log provider errors centrally. |
| Flutter framework failures | Build/layout/render exceptions, `ErrorWidget.builder` fallback | Keep a minimal `CatchFrameworkErrorView`; report through Flutter's global hooks; do not try to run normal app UI during an unstable build tree. |
| Uncaught asynchronous failures | Timers, plugin callbacks, unawaited futures, platform dispatcher errors | Wire `PlatformDispatcher.instance.onError`, pass to `ErrorLogger`, report fatal/nonfatal according to severity. |
| Unexpected programmer bugs | Bad state, invalid arguments, invariant violations, null/schema mismatch | Do not show raw details to users. Log/report with stack trace, show generic app copy, and turn recurring user-correctable instances into typed exceptions. |
| Operational/release signals | Crashlytics, Analytics, console fallback, emulator tests, dashboards, alerts | Attach custom keys/logs that help triage without PII; smoke-test reporting in release-like builds. |

The goal is not "catch everything everywhere." The goal is:

1. Expected failures are typed, user-safe, retry-aware, and testable.
2. Unexpected failures retain stack traces and enough context to diagnose.
3. Every app-facing surface gets a branded error primitive instead of raw
   `toString()` or vendor messages.
4. Every caught error is either displayed, rethrown as a typed app error,
   reported/logged, or intentionally documented as silent/noisy.
5. Product-significant expected failures appear in analytics without polluting
   Crashlytics as crashes.

#### Boundary classification rules

Classify low-level errors at the closest stable boundary:

| Boundary | Preferred API | Notes |
|---|---|---|
| Firebase/backend repository call | `withBackendErrorContext` / `withBackendErrorStream` | Keep as-is for backend calls; it is the correct transport wrapper. |
| Non-backend app operation | Future `withAppErrorContext` / `normalizeAppError` | Proposed next layer for local, platform, validation, parsing, and controller-owned failures. |
| Form field validation | `FormField` validators plus reusable domain validators | Use inline field errors for simple per-field validation; throw only when async flow or shared business logic needs an exception. |
| Domain guard | `requireSignedInUid`, eligibility guards, action cardinality checks | Throw typed `AppException` when the UI can recover or message the user. |
| Provider/load state | Riverpod `AsyncValue` | Preserve `error` and `stackTrace`; render with descriptor primitives. |
| Framework/global runtime | `FlutterError.onError`, `ErrorWidget.builder`, `PlatformDispatcher.instance.onError` | Report globally; avoid feature-level copy because the app tree may be compromised. |

`BackendErrorContext` should not remain the only context concept forever. It is
correct for Firebase/service calls, but the app also needs a more general
operation context for frontend/local failures. The next design should either:

- introduce `AppOperationContext` / `OperationErrorContext`, then let
  `BackendErrorContext` be a backend-specialized adapter; or
- rename the current backend context only if the migration can be done in one
  pass without making service-specific metadata ambiguous.

Do not reuse presentation `AppErrorContext` for operation logging. Presentation
context answers "where are we showing this?" Operation context answers "what was
the app trying to do?" They are related but not the same API.

#### Exception taxonomy target

Current `AppException` coverage is strongest for backend and payment flows. The
target catalogue for an app-wide system should distinguish:

| Family | Examples | Existing / target |
|---|---|---|
| Auth/session | signed out, expired credential, auth provider disabled, throttled OTP | Existing via `SignInRequiredException`, Auth mapper, `ValidationException`, `NetworkException`. |
| Network/backend | offline, timeout, rate limit, permission denied, not found, backend unknown | Existing via `NetworkException`, `PermissionException`, `DocumentNotFoundException`, `BackendOperationException`. |
| Storage/media | upload cancelled, file missing, unauthorized, retry limit, invalid file | Existing via `StorageException`; should confirm all photo/cover/image-picker failures use the same path. |
| Payments/booking | checkout cancelled, payment failed, verification failed, booking rejected | Existing via payment/run-booking exceptions; should confirm support-oriented reporting and nonfatal severity. |
| Validation/forms | invalid name, date, phone, age, height, route params, local payload | Partially existing through validators and `ValidationException`; needs a catalogue pass for repeated user-correctable failures. |
| Local persistence/cache | corrupt draft, unsupported schema, local write/read failure | Target addition: local data exception family or normalized `ValidationException`/`BackendOperationException` equivalent with local service context. |
| Navigation/deep links | malformed link, missing route id, inaccessible target, stale invite | Target addition if these become user-facing flows rather than generic not-found screens. |
| Location/permissions | permission denied, permission permanently denied, service disabled, unavailable | Target addition when map/check-in/location failures become product-significant. |
| External actions | share failed, URL launch failed, store link failed, picker failure | Existing `ExternalActionException`; needs candidate scan for every platform side effect. |
| Programmer bugs | `StateError`, `ArgumentError`, assertion, schema invariant | Should remain bugs unless the user can correct the condition. Never show raw details. |
| User cancellation | picker cancelled, upload cancelled, payment cancelled | Usually info/warning severity, often no full error surface. Must be explicit so cancellation does not look like a crash. |

The rule for sealed classes remains unchanged: add a subclass only when it is a
stable product/domain concept with branching, analytics, retry policy, audit
value, or tests. Use mapped copy for one-off message wording.

#### Descriptor and UI contract

Every app-facing error should end in one descriptor contract:

```
Object error + presentation AppErrorContext
  -> appErrorDescriptor
     -> title
     -> message
     -> severity
     -> retryable
     -> retryLabel
     -> icon
     -> support/report affordance when needed
```

Surface rules:

| Surface | Use when | Required behavior |
|---|---|---|
| `CatchErrorScaffold` | Root screen/tab cannot load | Title/message/retry from descriptor; never raw exception text. |
| `CatchSliverErrorState` | Sliver-native load failure | Same descriptor, sliver-compatible layout. |
| `CatchInlineErrorState` | Section/card-level failure | Compact descriptor copy and retry when retryable. |
| `CatchErrorBanner.fromError` / `CatchMutationErrorBanner` | Persistent form/mutation failure | No retry unless action exists; avoid duplicating field-level validation. |
| `showCatchErrorSnackBar` | Transient action failure | Descriptor message and retry action if the failed action can safely rerun. |
| Field validation error | Per-field invalid input | Specific field copy, not a snackbar or generic exception. |
| `CatchFrameworkErrorView` | Flutter build/render failure | Minimal fallback; diagnostic details only in debug/reporting. |
| Empty state | Successful load with zero items | Never use an error primitive for empty data. |

The next pass must check that every current and future `AsyncValue` error branch,
mutation error branch, caught snackbar, route guard, sheet/dialog failure, and
framework fallback flows through this contract or has a documented exception.

#### Reporting and observability contract

Crash/reporting should be useful, not noisy:

| Event type | User display | Crashlytics | Analytics | Notes |
|---|---|---|---|---|
| Expected validation/auth/permission | User-safe copy | Usually no crash issue; optional nonfatal only if high impact | Yes when product-significant | Avoid alert fatigue. |
| Expected retryable backend/network | Retry copy | Nonfatal only if repeated/high impact | Yes with service/action/code/retryable | Prefer aggregated analytics for frequency. |
| User cancellation | Usually no error or low-key copy | No | Usually no, unless funnel analysis needs it | Cancellation is not failure unless product says so. |
| Payment/booking verification failure | Support-oriented copy | Nonfatal with context | Yes | High business impact but not necessarily crash. |
| Unexpected exception/bug | Generic user copy | Yes with stack trace | Optional | Must retain stack and operation context. |
| Framework/global uncaught fatal | Fallback or app crash | Fatal | Optional | Covered by FlutterError/PlatformDispatcher. |

Recommended custom keys/logs for reportability:

- `app_env`, `app_version`, build mode, platform, and Firebase project alias.
- `error_family`, stable `code`, `severity`, `retryable`, and whether it was
  expected.
- Operation `service`, `feature`, `action`, and `resource` without document ids,
  phone numbers, names, chat text, profile bio, exact coordinates, or payment
  secrets.
- Presentation context (`dashboard`, `explore`, `profile`, `run`, `club`,
  `chat`, `payments`, `auth`, `generic`) when available.
- Hashed/opaque user identifier only if product/privacy policy accepts it.

Crashlytics custom keys are limited, so do not set one key for every dynamic
detail. Prefer a small stable set and put short breadcrumbs/log messages around
important transitions.

#### Privacy and safety rules

- Never show raw `FirebaseException.message`, stack traces, callable details, or
  plugin object dumps to normal users.
- `appErrorMessage`, `backendErrorMessage`, mutation banners, snackbars, and
  error-state widgets must not append debug diagnostics to user-facing copy,
  even in debug builds. Developer details belong in `ErrorLogger`,
  Crashlytics, analytics metadata, backend logs, and the Flutter console.
- Never log PII in error metadata: names, phone numbers, exact birth dates,
  chat/message text, profile bio, photo URLs, precise locations, payment ids or
  signatures, and document ids unless they are already non-sensitive public ids.
- Separate debug-only diagnostics from release UI copy.
- Preserve the original `cause` and `stackTrace` for developer diagnosis, but
  do not make them part of user-facing copy.
- Treat security-rule denials as product/security signals, not generic "try
  again" failures unless retry can actually succeed after a user action.

#### App-wide scanner requirements

Before candidate migration, add a scanner that surfaces every possible local
and frontend error-management candidate. It should produce stable buckets like
the backend scanner: `mustMigrate`, `review`, `verified`, `intentional`,
`fixture`, and `migrated`.

Candidate rules to scan:

| Pattern | Why it matters |
|---|---|
| `catch (_)`, empty `catch`, `.catchError` without logging/rethrow | Silent failures. |
| `catch (e)` followed by `debugPrint`, raw `SnackBar`, or `Text(e.toString())` | Invisible in release or unsafe user copy. |
| `throw StateError`, `throw ArgumentError`, `throw Exception`, thrown strings | Possible user-correctable errors bypassing `AppException`. |
| `AsyncValue(error:)` branches not using descriptor primitives | Raw provider errors in UI. |
| `requireValue` in widgets/providers without explicit reason | Loading/error states can become runtime exceptions. |
| `Timer`, subscription, stream, listener, callback, `unawaited`, plugin futures | Async errors may bypass normal try/catch. |
| `jsonDecode`, model parsing, local storage reads, route/deep-link parsing | Local/schema failures need typed context. |
| `url_launcher`, share, image picker, geolocator, permission handlers | Platform failures need consistent external-action handling. |
| `FirebaseException.message`, `FirebaseAuthException.message`, `FirebaseFunctionsException.message` in UI | Raw vendor copy leaks implementation detail and may be unstable. |
| `FlutterError.presentError`, `ErrorWidget.builder`, global handlers | Confirm framework/global reporting remains wired. |
| Test fakes and fixtures | Must be classified so the scanner is actionable. |

The scanner is not proof by itself. Its value is a single source of truth for
what still needs migration and what was intentionally retained.

#### Comprehensive pre-migration checklist

Use this checklist before editing candidates:

| Check | Done bar |
|---|---|
| Taxonomy | Every stable failure family has an `AppException` decision: existing subclass, new subclass, mapped copy, or logged unexpected bug. |
| Context | There is one operation-context API for backend and non-backend actions, with explicit non-PII rules. |
| Normalization | Backend, plugin, validation, local parsing, route/deep-link, and domain guard failures normalize through one `normalizeAppError` path or documented specialized mappers. |
| Presentation | Every full-screen, sliver, inline, banner, snackbar, field, and framework fallback uses the correct primitive. |
| Riverpod | Provider/mutation errors preserve stack traces and are observed/logged centrally; UI does not call `requireValue` casually. |
| Global handlers | `FlutterError.onError`, `PlatformDispatcher.instance.onError`, and `ErrorWidget.builder` remain installed and tested. |
| Reporting | Crashlytics/Analytics get stable codes and low-cardinality context; expected errors do not pollute crash dashboards. |
| Privacy | Error logs and descriptors avoid PII and sensitive document/payment/location details. |
| Tests | Mappers, descriptors, widgets, provider observers, global handlers, and scanner buckets have focused tests. |
| Release proof | Production-like build has Crashlytics/Analytics smoke evidence and dashboard/alert review. |

#### General to-do list

Persistent implementation work should be tracked by `APP-ERROR-INFRA-001` in
`docs/audit_registry/backlog.json`. The intended order is:

1. Design the app-wide context API and normalizer.
2. Add the app-wide error-candidate scanner with stable buckets and tests.
3. Run the scanner and create the migration source of truth from its output.
4. Migrate frontend/local candidates by family: validation, local persistence,
   route/deep-link parsing, plugin/external actions, provider/mutation UI,
   uncaught async/listeners, and framework/global hooks.
5. Expand `AppException` only where the taxonomy rule justifies it.
6. Connect every app-facing failure to `appErrorDescriptor` and branded
   primitives.
7. Add non-PII Crashlytics custom keys/logs and Analytics events for
   product-significant expected failures.
8. Add tests for every mapper family and every surface primitive.
9. Run release-like reporting QA: forced test exception, forced nonfatal,
   expected validation failure, expected backend failure, plugin failure, and
   framework error fallback.
10. Keep scanner `mustMigrate=0` and `review=0` as the finished state, with
    intentional exceptions documented here and in the registry.

#### Definition of done for "finished"

Error management is not finished until all of these are true:

- Backend scanner stays at `mustMigrate=0` and `review=0`.
- App-wide frontend/local scanner exists and stays at `mustMigrate=0` and
  `review=0`.
- No user-facing screen renders raw `error.toString()`, raw Firebase messages,
  or generic Dart exception text.
- Expected user-correctable failures are typed or mapped, retry-aware, and
  covered by tests.
- Unexpected failures preserve stack traces and operation context through
  `ErrorLogger`/Crashlytics.
- Provider, mutation, stream, callback, timer, plugin, and global framework
  errors have a documented capture path.
- Every branded error primitive consumes the descriptor contract.
- Crashlytics/Analytics reporting is smoke-tested in a release-like build and
  dashboard alert thresholds are reviewed.
- The catalogue, scanner output, backlog item, and audit registry stamp agree.

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
- `tool/audit/backend_error_candidates.dart` is the scanner for future migration
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
dart tool/audit/backend_error_candidates.dart --json
```

Latest result: `mustMigrate=0`, `review=0`, `verified=80`,
`intentional=29`, `fixture=56`, `migrated=148`.

The scanner intentionally still looks for direct `.httpsCallable`,
`.snapshots`, `.get`, `.set`, `.update`, `.delete`, and raw Firebase exception
references. It now classifies them as `verified`, `intentional`, `fixture`, or
`review` so future work can tell the difference between a real migration risk
and an inspected backend boundary. The key invariants are that `mustMigrate` and
`review` remain zero.

#### Backend Error Migration Checklist

Single source of truth for this hard migration:

| Area | Locations | Status |
|---|---|---|
| Core catalogue | `lib/exceptions/app_exception.dart` | Migrated: backend context, severity, retry policy, `ValidationException`, `BackendOperationException`, storage/external metadata |
| Core wrappers | `lib/core/backend_error_util.dart`, `lib/core/backend_error_message.dart` | Migrated: futures, streams, Auth, Firestore, Functions, Storage, Remote Config, App Check, Messaging, timeout, and unexpected mappings |
| UI facade | `lib/core/app_error_message.dart`, `lib/core/widgets/mutation_error_util.dart` | Migrated: screens and mutation banners route through `appErrorMessage` / `backendErrorMessage` |
| Logging/reporting | `lib/exceptions/error_logger.dart`, `lib/analytics/app_analytics.dart`, `lib/main.dart` | Migrated: backend failures carry context into logs and analytics |
| Candidate scanner | `tool/audit/backend_error_candidates.dart` | Added: repeatable candidate scan with `mustMigrate`, `review`, and `migrated` buckets |
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

### 2026-05-12: Error Feature Completion Pass

The backend error feature now has a single presentation descriptor:

- `appErrorDescriptor(error, context: ...)` returns title, message, icon,
  retry label, retryability, and severity.
- `appErrorTitle` and `appErrorMessage` are compatibility helpers over the
  descriptor.
- `CatchErrorState`, `CatchErrorScaffold`, `CatchSliverErrorState`,
  `CatchInlineErrorState`, `showCatchErrorSnackBar`, and
  `CatchErrorBanner.fromError`
  all consume the same descriptor contract.
- Non-retryable typed failures such as validation and permission errors no
  longer show retry actions merely because a caller passed an `onRetry`.
- Retryable failures expose descriptor-owned retry labels such as
  `Reload messages`, `Reload profile`, `Try upload again`, or
  `Try payment again`.

Mapper coverage is now explicit in tests:

- Firestore permission, network, missing document, and unexpected failures.
- Callable Functions auth failures and feature-specific mapper overrides.
- Firebase Auth validation, session, network, and throttling failures.
- Firebase Storage permission, missing object, cancelled, retry, and unknown
  upload failures.
- Remote Config, App Check, Messaging, timeout, and unexpected failures.
- Descriptor behavior for network, validation, storage, external action,
  payment, and run-booking failures.
- Branded primitives hide retry for non-retryable errors and expose snackbar
  retry actions for retryable errors.

The old flat scanner result `review=153` has been reviewed and classified by
`tool/audit/backend_error_candidates.dart`:

| Status | Count | Meaning |
|---|---:|---|
| `mustMigrate` | 0 | No legacy Firestore/Auth/run-booking error APIs remain in `lib` or `test`. |
| `review` | 0 | No direct backend/error candidate is currently unclassified. |
| `verified` | 80 | Direct Firebase calls are inside `withBackendErrorContext`, `withBackendErrorStream`, feature mappers, or normalized best-effort catches. |
| `intentional` | 29 | Raw error checks are in mapper/message/logger/bootstrap/diagnostic/not-found-swallow seams. |
| `fixture` | 56 | Direct Firebase calls or raw Firebase exceptions are test setup/assertion code. |
| `migrated` | 148 | Unified backend error API call sites. |

This is the current done bar for code-level backend error management. Remaining
release-quality work is operational rather than structural: production
Crashlytics/Analytics dashboard review, alert thresholds, and device/UI QA for
the most important failure states.

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
unstable. `CatchErrorBanner` remains the inline mutation/form error primitive.
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
  Mutation.hasError → CatchErrorBanner / CatchMutationErrorBanner for inline/form failures
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
├── NetworkException                  // offline / connection-failed / timeout / too-many-requests
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
Client-side obvious-offline checks may create `NetworkException('offline')`
before waiting for a backend timeout when no current/cached data is available.

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
| `NetworkException` | `offline`, `connection-failed`, `timeout`, `too-many-requests` | Connectivity, deadline, or rate-limit failure. | Connectivity preflight, Firestore / Functions mapping | Immediate offline state when no cached data exists; branded retry surface or stale/offline banner when cached data exists |
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
  `dashboard`, `explore`, `profile`, `run`, `club`, `chat`, `swipes`,
  `payments`, `auth`, or `generic`. Add contexts only when title/copy
  materially improves.
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

`tool/audit/backend_error_candidates.dart` intentionally reports direct Firebase
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
  CatchErrorBanner(message: mutationErrorMessage(joinMutation)),
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
| `CatchErrorBanner` / `CatchMutationErrorBanner` | Canonical mutation/form inline path | Save-before-pop forms, sheets, and persistent page actions |
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
| Inline mutation/form failure | Mutation state check | `CatchErrorBanner` / `CatchMutationErrorBanner` |
| Transient action failure | Mutation listener or caught action error | `showCatchErrorSnackBar` |
| Form field validation | FormField validator | Inline `errorText` |
| Framework/build/layout crash | `ErrorWidget.builder` | `CatchFrameworkErrorView` |
| True empty state | successful data load with no items | `CatchEmptyState` |

### Error message translation pipeline

```
Raw error (any type)
  → appErrorTitle(error, context: ...)
  → appErrorMessage(error, context: ...)
    → CatchErrorState / CatchErrorBanner / showCatchErrorSnackBar

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

1. **App-wide operation context is missing**: backend calls carry
   `BackendErrorContext`, but local validation, parsing, navigation, platform,
   and controller-owned failures do not yet have one shared context API.

2. **Frontend/local scanner is missing**: backend drift is now measurable, but
   the app still needs a repeatable scanner for raw UI errors, `StateError` /
   `ArgumentError` candidates, silent catches, plugin failures, local parsing,
   callbacks, and provider error branches.

3. **Controller/mutation context is uneven**: provider-level logging sees the
   error, but not every controller failure includes feature/action metadata.

4. **Expected AppExceptions are warning-level by default**: this is intentional
   to avoid polluting crash dashboards with user-correctable states, but
   product-significant expected failures should still emit analytics where
   useful.

5. **Error catalogue coverage is incomplete outside backend/payment flows**:
   reusable validation failures, local persistence/schema failures,
   route/deep-link failures, external action failures, and optional location
   failures need an app-wide catalogue pass.

6. **Operational reporting still needs release-like proof**: Crashlytics,
   Analytics, custom keys, nonfatal reporting, and alert thresholds should be
   smoke-tested after the app-wide system is in place.

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
| Backend error wrapping utility | `lib/core/backend_error_util.dart` |
| Frontend/local op-context API | `lib/core/app_error_context.dart` |
| User-facing backend messages | `lib/core/backend_error_message.dart` |
| UI-facing title/message facade | `lib/core/app_error_message.dart` |
| Central error logger | `lib/exceptions/error_logger.dart` |
| Provider error observer | `lib/exceptions/error_logger.dart:150` (AsyncErrorLogger) |
| Analytics error events | `lib/analytics/app_analytics.dart` (`logBackendOperationFailed`) |
| Backend migration scanner | `tool/audit/backend_error_candidates.dart` |
| Frontend migration scanner | `tool/audit/frontend_error_candidates.dart` |
| Branded error surfaces | `lib/core/widgets/catch_error_state.dart` |
| Branded error snackbar | `lib/core/widgets/catch_error_snackbar.dart` |
| Error banner widget | `lib/core/widgets/catch_error_banner.dart` |
| Mutation error display | `lib/core/widgets/mutation_error_util.dart` |
| Mutation snackbar listener | `lib/core/widgets/catch_mutation_error_listener.dart` |
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
| 1 | Create the app-wide operation context and normalizer described in `APP-ERROR-INFRA-001`. | Unit tests prove backend, validation, local, plugin, and unexpected failures normalize consistently. |
| 2 | Add the app-wide candidate scanner for frontend/local/provider/plugin/global error surfaces. | Scanner emits `mustMigrate`, `review`, `verified`, `intentional`, `fixture`, and `migrated` buckets. |
| 3 | Run the scanner and migrate all `mustMigrate` / `review` items by failure family. | Scanner reaches `mustMigrate=0` and `review=0`; retained exceptions are documented. |
| 4 | Add typed catalogue entries only for repeated stable product failures: likely reusable validation, local persistence, route/deep-link, external action, and location. | New subclass or mapper decision, descriptor copy, tests, and catalogue row in this doc. |
| 5 | Add feature-level analytics for expected but product-significant failures. | ErrorLogger/analytics tests prove events fire without treating expected errors as crashes. |
| 6 | Prove release-like reporting. | Forced fatal, forced nonfatal, expected backend failure, expected frontend validation failure, and plugin/platform failure appear with useful non-PII context. |
| 7 | Consider generated error catalogue checks if manual drift becomes expensive. | CI or registry validates subclass/code/doc catalogue parity. |

---

## References

- Dart language error handling:
  https://dart.dev/language/error-handling
- Dart `Error` class semantics:
  https://api.dart.dev/dart-core/Error-class.html
- Flutter app error handling:
  https://docs.flutter.dev/testing/errors
- Flutter `ErrorWidget.builder` contract:
  https://api.flutter.dev/flutter/widgets/ErrorWidget/builder.html
- Firebase Crashlytics setup for Flutter:
  https://firebase.google.com/docs/crashlytics/flutter/get-started
- Firebase Crashlytics custom reports for Flutter:
  https://firebase.google.com/docs/crashlytics/flutter/customize-crash-reports
- Firebase Auth Flutter error handling:
  https://firebase.google.com/docs/auth/flutter/errors
- Firebase Storage Flutter error handling:
  https://firebase.google.com/docs/storage/flutter/handle-errors
- Firestore error code reference:
  https://firebase.google.com/docs/reference/js/v8/firebase.firestore#firestoreerrorcode
- Riverpod `AsyncValue`:
  https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html
- Riverpod `ProviderObserver`:
  https://riverpod.dev/docs/concepts2/observers
- Riverpod mutations:
  https://riverpod.dev/docs/concepts2/mutations
- Firestore offline persistence:
  https://firebase.google.com/docs/firestore/manage-data/enable-offline
