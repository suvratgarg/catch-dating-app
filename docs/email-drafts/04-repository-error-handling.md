From: Claude Code <noreply@anthropic.com>
To: suvratgarg@gmail.com
Subject: [Fix 6] Standardized repository error handling — 19 methods wrapped + exception hierarchy expanded

---

## What I changed

### 1. Expanded exception hierarchy (`lib/exceptions/app_exception.dart`)

Added new exception classes:
- **`NetworkException`** — for connectivity/timeout/quota errors (code: `connection-failed`, `timeout`, `too-many-requests`)
- **`PermissionException`** — for permission-denied errors

Added `cause` property to `AppException`:
```dart
sealed class AppException implements Exception {
  const AppException(this.code, this.message, {this.cause});
  final Object? cause;  // Original error for debugging, never shown to users
}
```

### 2. Evolved `withFirestoreErrorContext` (`lib/core/firestore_error_util.dart`)

The wrapper now:
- Catches `FirebaseFunctionsException` (Cloud Function errors) before `FirebaseException` (ordering matters — FunctionsException is a subtype)
- Maps specific Firebase error codes to typed exceptions:
  - `permission-denied` → `PermissionException`
  - `unauthenticated` → `SignInRequiredException`
  - `unavailable` → `NetworkException('connection-failed')`
  - `deadline-exceeded` → `NetworkException('timeout')`
  - `resource-exhausted` → `NetworkException('too-many-requests')`
  - `not-found` → `DocumentNotFoundException`
- Re-throws `AppException` as-is (no double-wrapping)
- Catches unexpected errors and wraps them as `FirestoreWriteException(code: 'unexpected')` with the original error as `cause`

### 3. Wrapped 19 write methods across 5 repositories

| Repository | Methods Wrapped |
|------------|----------------|
| `UserProfileRepository` | `setUserProfile`, `updateUserProfile`, `updatePhotoUrls`, `setProfileComplete`, `saveRun`, `unsaveRun` (6) |
| `RunRepository` | `createRun`, `signUpForRun`, `cancelSignUpViaFunction`, `joinWaitlistViaFunction`, `leaveWaitlist`, `markAttendance` (6) |
| `ReviewsRepository` | `addReview`, `updateReview`, `deleteReview` (3) |
| `RunClubsRepository` | `leaveClub` (1 — `joinClub` was already wrapped) |
| `ChatRepository` | `sendMessage` (1 — batch write) |

Combined with the pre-existing `joinClub` wrapper: **~20 of ~40 write methods now have structured error context.**

## Why this matters

### The before situation

Before this fix, if `userProfileRepository.setUserProfile()` threw `FirebaseException(code: 'permission-denied')`:
1. The raw `FirebaseException` propagated all the way to the UI
2. The UI called `firestoreErrorMessage(e)` which returned a generic message
3. There was no collection/action context for debugging
4. No analytics event was fired
5. The error in Crashlytics had no context about what was being attempted

### The after situation

Now when the same error occurs:
1. `withFirestoreErrorContext` catches the `FirebaseException`
2. Maps it to `PermissionException('set profile on users failed: [permission-denied] ...')`
3. The `cause` property preserves the original `FirebaseException` for debugging
4. The UI sees a clean `AppException` with a structured message
5. The `AsyncErrorLogger` ProviderObserver catches it and logs to Crashlytics with the full context

### The code pattern you should use

Every repository write method should follow this pattern:

```dart
Future<void> doSomething({required String uid}) =>
    withFirestoreErrorContext(
      () => _db.collection('items').doc(uid).set(data),
      collection: 'items',
      action: 'create item',
    );
```

The `withFirestoreErrorContext` function handles:
- FirebaseException → typed AppException mapping
- FirebaseFunctionsException (Cloud Functions) → same treatment
- AppException re-thrown as-is (no double-wrapping)
- Unexpected errors wrapped with `cause`

### Remaining unwrapped methods

These are intentionally not wrapped yet:
- `ImageUploadRepository` — uses Firebase Storage (not Firestore), different exception types
- `SwipeRepository.recordSwipe` — writes to subcollection, lower risk
- `OnboardingDraftRepository.saveDraft/deleteDraft` — best-effort, non-critical writes
- `MatchRepository.resetUnread` — already has specific `not-found` handling
