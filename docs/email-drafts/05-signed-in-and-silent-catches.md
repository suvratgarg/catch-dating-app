From: Claude Code <noreply@anthropic.com>
To: suvratgarg@gmail.com
Subject: [Fixes] requireSignedInUid now throws typed exception + 6 silent catch sites fixed

---

## Fix: `requireSignedInUid` now throws `SignInRequiredException` directly

### What changed

**File:** `lib/auth/require_signed_in_uid.dart`

Before:
```dart
throw StateError('You need to be signed in to $action.');
```

After:
```dart
throw SignInRequiredException(action);
```

**File:** `lib/runs/presentation/run_booking_controller.dart`

The `_requireSignedIn` method was catching `StateError` and converting it to `SignInRequiredException`. This conversion is no longer needed:

Before:
```dart
String _requireSignedIn({required String action}) {
  try {
    return requireSignedInUid(ref, action: action);
  } on StateError {
    throw SignInRequiredException(action);
  }
}
```

After:
```dart
String _requireSignedIn({required String action}) {
  return requireSignedInUid(ref, action: action);
}
```

The `import 'package:catch_dating_app/exceptions/app_exception.dart';` import was also removed since it's no longer used in this file.

### Why this matters

This is about making errors carry their meaning through the type system, not just through their message string.

**Before:** `requireSignedInUid` threw a generic `StateError`. Controllers that called it had to know (through convention/documentation) that this specific `StateError` meant "user not signed in" and should be converted to `SignInRequiredException` for the UI. If a developer forgot to wrap it, the user would see "Bad state: You need to be signed in to..." instead of a clean error.

**After:** `requireSignedInUid` throws `SignInRequiredException` directly, which is an `AppException`. The error display pipeline (`firestoreErrorMessage`, `mutationErrorMessage`, `ErrorBanner`) already knows how to handle `AppException`. No conversion needed.

### The principle: typed exceptions for domain errors

A `StateError` means "the program is in an invalid state" — it's a programmer error. A `SignInRequiredException` means "the user needs to sign in" — it's an expected domain condition. These are different categories:

| Category | Type | Examples | User sees |
|----------|------|----------|-----------|
| Domain condition | `AppException` | `SignInRequiredException`, `PaymentFailedException` | Clean message |
| Programmer error | `StateError`, `ArgumentError` | Null where value expected | Generic message (debug: full details) |
| External failure | Mapped to `AppException` | `FirebaseException` → `NetworkException` | Contextual message |

Throwing the right type at the source means every downstream consumer automatically handles it correctly.

---

## Fix: 6 silent catch sites now log errors

### What changed

Six locations that previously swallowed errors silently now log them:

| # | File | Method | Before | After |
|---|------|--------|--------|-------|
| 1 | `device_location.dart:31` | `build()` | `catch (_) { return null; }` | `catch (error, stack)` → `debugPrint` → `return null` |
| 2 | `run_draft_repository.dart:42` | `loadDrafts()` | `catch (_) { return []; }` | `catch (error, stack)` → `debugPrint` → `return []` |
| 3 | `onboarding_controller.dart:418` | `_saveDraft()` | `.catchError((_, _2) {})` | `.catchError((error, stack)` → `debugPrint` |
| 4 | `onboarding_controller.dart:431` | `_deleteDraft()` | `.catchError((_, _2) {})` | `.catchError((error, stack)` → `debugPrint` |
| 5 | `photo_upload_controller.dart:87` | `_failUploading()` | State update only | `debugPrint` + state update |
| 6 | `photo_upload_controller.dart:118` | `_serializePhotoWrite()` | `onError: (_, _) {}` | `onError: (error, stack)` → `debugPrint` |
| 7 | `profile_edit_sheet.dart:35` | `_saveField()` | `debugPrint` (no prefix) | `debugPrint('[ERROR] ...')` (consistent format) |

All use the format: `debugPrint('[ERROR] ClassName.method: $error\n$stack')`

### Why this matters

Silent error swallowing is one of the hardest bugs to diagnose. When an error is caught and discarded:

1. **The user** sees normal behavior but the operation silently failed (draft not saved, location not captured, etc.)
2. **The developer** has no indication anything went wrong — no crash report, no log, no analytics
3. **Debugging** requires reproducing the exact conditions that trigger the error

The `[ERROR]` prefix makes these grep-able. A future upgrade to a structured `ErrorLogger` can search for `[ERROR]` patterns and route them to Crashlytics.

### The right way to handle expected failures

These catch sites are all for **expected** failure modes (GPS unavailable, corrupted SharedPreferences, draft save failed). The correct pattern is:

1. **Catch the error** (these are non-critical operations)
2. **Log it** (so you know it happened)
3. **Return a safe default** (null, empty list, reset state)

The key addition is step 2 — logging. Before, these failures were invisible. Now they're visible in debug mode, and the format is ready for a future Crashlytics upgrade.

### Future upgrade path

When a structured `ErrorLogger` with a Riverpod provider is available, these will be upgraded to:

```dart
ref.read(errorLoggerProvider).log(
  level: LogLevel.warn,
  message: 'DeviceLocation.build failed',
  error: error,
  stackTrace: stack,
);
```
