# Email Draft: Preserving stack traces in catch blocks

## Why

Five catch blocks across the codebase used `catch (e)` or `catch (error)`
without capturing the stack trace. When these errors were logged or reported
to Crashlytics, the stack trace was lost — making it impossible to trace
the error back to its origin in production debugging.

## What changed

### 1. Added `stackTrace` to AppException base class

```dart
sealed class AppException implements Exception {
  const AppException(this.code, this.message, {
    this.cause,
    this.stackTrace,  // NEW
  });

  final StackTrace? stackTrace;  // NEW
}
```

### 2. Updated 5 catch blocks

| File | Before | After |
|---|---|---|
| `photo_upload_controller.dart:45` | `catch (e)` | `catch (e, st)` |
| `photo_upload_controller.dart:72` | `catch (e)` | `catch (e, st)` |
| `payment_repository.dart:120` | `catch (error)` | `catch (error, st)` |
| `payment_repository.dart:175` | `catch (e)` | `catch (e, st)` |
| `firestore_error_util.dart:39` | `catch (e)` | `catch (e, st)` |

### 3. Updated signatures to pass stack traces through

```dart
// _failUploading now accepts optional stack trace
void _failUploading(int index, Object error, [StackTrace? st]) {
  debugPrint('[ERROR] PhotoUploadController._failUploading($index): $error\n$st');
}

// _normalizePaymentError now accepts optional stackTrace
AppException _normalizePaymentError(Object error, {
  required String fallbackMessage,
  StackTrace? stackTrace,
}) { ... }

// FirestoreWriteException now accepts stackTrace
const FirestoreWriteException({
  ...,
  StackTrace? stackTrace,  // NEW
}) : super(..., stackTrace: stackTrace);
```

## Why this matters for Crashlytics

Before: Crashlytics would report "PaymentFailedException: Unable to launch
the payment checkout" with no call stack. You couldn't tell which code path
triggered it.

After: The full Dart stack trace is attached, showing exactly which line in
which file threw the original error.
