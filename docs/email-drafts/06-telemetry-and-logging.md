From: Claude Code <noreply@anthropic.com>
To: suvratgarg@gmail.com
Subject: [Fixes] Structured logging + web fallback + Crashlytics user ID + analytics wiring

---

## What changed

### 1. Structured logging with LogLevel (`lib/exceptions/error_logger.dart`)

Added `LogLevel` enum and a central `log()` method:

```dart
enum LogLevel { fatal, error, warn, info, debug }

void log({
  required LogLevel level,
  required String message,
  Object? error,
  StackTrace? stackTrace,
  Map<String, String>? context,
});
```

Output format: `[LEVEL][timestamp] key=value... message`

Example output:
```
[ERROR][2026-05-03T14:22:01.123] Flutter error: Bad state: boom
  error=Bad state: boom
  #0 ...
```

The old convenience methods (`logFlutterError`, `logError`, `logAppException`) delegate to `log()` internally, so existing call sites continue to work.

### 2. Web crash reporting fallback (`lib/exceptions/console_crash_reporter.dart`)

Before: `ErrorLogger._defaultCrashReporter` returned `null` for `kIsWeb`. Web errors were completely invisible.

After: Returns `ConsoleCrashReporter()` — prints structured output via `debugPrint` with `[WEB_CRASH]` prefix. This can be upgraded later to send to a custom endpoint (Sentry, Cloud Logging).

### 3. `errorLoggerProvider` — Riverpod access to ErrorLogger

```dart
@riverpod
ErrorLogger errorLogger(Ref ref) => ErrorLogger();
```

Overridden in `main.dart` with the real instance:
```dart
ProviderScope(
  overrides: [
    appAnalyticsProvider.overrideWithValue(analytics),
    errorLoggerProvider.overrideWithValue(errorLogger),  // NEW
  ],
```

This allows any controller or widget to access the ErrorLogger via `ref.read(errorLoggerProvider).log(...)`.

### 4. `AsyncErrorLogger` now fires analytics for Firestore write failures

The `AsyncErrorLogger` ProviderObserver now accepts an optional `onFirestoreWriteFailed` callback. When it catches a `FirestoreWriteException`, it fires this callback, which is wired in `main.dart` to call `analytics.logFirestoreWriteFailed()`.

This means **every Firestore write failure** (now wrapped with `withFirestoreErrorContext`) automatically generates an analytics event with the error code. No developer action needed.

### 5. Crashlytics user ID kept in sync

`AppShell` now watches `uidProvider` and calls `errorLogger.setUserId(uid)` on every auth state change:

```dart
ref.listen(uidProvider, (_, next) {
  ref.read(errorLoggerProvider).setUserId(next.asData?.value);
});
```

This means every Crashlytics report will be attributable to a specific user. When a crash report comes in, you can see exactly which user experienced it.

### 6. `logAppException` now logs at WARN level (not just debugPrint)

Before: `logAppException` only called `debugPrint` (no-op in release).

After: `logAppException` calls `log(level: LogLevel.warn, ...)`. In debug mode, this prints to console. The WARN level doesn't go to Crashlytics (only ERROR and FATAL do), but it does print with a consistent format. The analytics callback on `AsyncErrorLogger` covers business-impacting exceptions.

## Why this matters

### The before situation

Imagine a user's payment fails in production:
1. `PaymentRepository` throws `PaymentFailedException`
2. `RunBookingController.bookMutation` catches it, transitions to `MutationError`
3. The UI shows an `ErrorBanner`
4. `AsyncErrorLogger` catches the `AppException` → calls `logAppException` → `debugPrint` → **silent in release** ❌
5. No Crashlytics report. No analytics event. No user ID.
6. You have no idea this happened unless the user reports it.

### The after situation

Now when the same failure occurs:
1-3: Same path (user still sees the ErrorBanner)
4. `AsyncErrorLogger` catches the `AppException` → calls `logAppException` → `log(level: warn)` → console output
5. If it's a `FirestoreWriteException`, the `onFirestoreWriteFailed` callback fires → `analytics.logFirestoreWriteFailed(...)` → appears in Firebase Analytics dashboard
6. The `errorLoggerProvider` is available for any code to call `ref.read(errorLoggerProvider).log(...)`
7. Crashlytics reports carry the user ID for attribution

### The architectural principle: automatic telemetry

The key insight is that telemetry should be automatic — developers shouldn't need to remember to call `analytics.logFirestoreWriteFailed()` after every Firestore write. By hooking into the `AsyncErrorLogger` ProviderObserver (which already watches every provider), the telemetry is a side-effect of the existing error propagation path.

This is the "opt-out, not opt-in" principle applied to telemetry.

## Files changed

| File | Change |
|------|--------|
| `lib/exceptions/error_logger.dart` | `LogLevel` enum, structured `log()`, `setUserId()`, `errorLoggerProvider`, updated `AsyncErrorLogger` |
| `lib/exceptions/console_crash_reporter.dart` | **NEW** — Web crash reporting fallback |
| `lib/main.dart` | Override `errorLoggerProvider`, pass analytics callback to `AsyncErrorLogger` |
| `lib/core/presentation/app_shell.dart` | Watch `uidProvider` and sync Crashlytics user ID |
