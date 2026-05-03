From: Claude Code <noreply@anthropic.com>
To: suvratgarg@gmail.com
Subject: [Fix 1/6] Replaced raw error.toString() with firestoreErrorMessage() in RunDetailScreen

---

## What I changed

**File:** `lib/runs/presentation/run_detail_screen.dart:23`

**Before:**
```dart
error: (e, _) => Center(child: Text(e.toString())),
```

**After:**
```dart
error: (e, _) => Center(child: Text(firestoreErrorMessage(e))),
```

Also added the import:
```dart
import 'package:catch_dating_app/core/firestore_error_message.dart';
```

## Why this matters

This was the ONLY place in the entire app that displayed a raw `error.toString()` to users. Every other screen that uses the `AsyncValue.when(error: ...)` pattern correctly routes errors through `firestoreErrorMessage()`.

### The problem with `error.toString()`

`e.toString()` on a `FirebaseException` produces something like:
```
FirebaseException ([core/permission-denied] The caller does not have permission...)
```

This is:
- **Ugly** — users see stack-trace-like formatting
- **Leaky** — exposes internal Firebase error codes and server messages
- **Inconsistent** — every other screen shows clean, user-friendly messages

### How `firestoreErrorMessage()` works

It's defined in `lib/core/firestore_error_message.dart` and translates errors to human-readable messages:

| Error type | What user sees |
|---|---|
| `FirebaseException(code: 'permission-denied')` | "You don't have permission to perform this action..." |
| `FirebaseException(code: 'unavailable')` | "We're having trouble connecting..." |
| `AppException` | The exception's `.message` field |
| `StateError` / `ArgumentError` | The clean error message |
| Unknown | Strips "Exception: " prefix, shows clean text |

In debug mode, it also appends `[DEBUG Firestore <code>]` so developers can diagnose issues.

### The architectural principle

Every `AsyncValue.when(error: ...)` in the app should use `firestoreErrorMessage(e)` — never `e.toString()`. This is because:

1. **Repository layer** throws raw `FirebaseException` (the technical error)
2. **UI layer** translates it via `firestoreErrorMessage()` (the human message)
3. **ErrorLogger** (ProviderObserver) catches it for Crashlytics (the diagnostic)

These three concerns — user message, technical detail, and diagnostic — should never be conflated into a single `toString()` call.

## How to verify

Visit any run detail screen, then simulate a Firestore error (e.g., block the Firestore endpoint in dev tools or use the emulator with rules that reject the read). The error text should be clean and user-friendly, not raw exception output.
