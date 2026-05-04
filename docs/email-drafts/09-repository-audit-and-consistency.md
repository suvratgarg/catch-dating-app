From: Claude Code <noreply@anthropic.com>
To: suvratgarg@gmail.com
Subject: [Audit] Repository audit — 7 write paths wrapped, 9 providers renamed, BlockedUser extracted, 3 style fixes

---

## Summary

Audited all 16 repositories across 12 features for structure, naming, error handling, and best-practice adherence. Fixed 6 of the 8 findings (2 were re-evaluated as correct-as-is).

## What I changed

### 1. Wrapped 7 unprotected write paths with `withFirestoreErrorContext`

**`RunClubsRepository`** (`lib/run_clubs/data/run_clubs_repository.dart`):

Three write methods had no error wrapping (while `joinClub` and `leaveClub` already did):

```dart
// Before
Future<String> createRunClub({...}) async { ... }
Future<void> updateRunClub({...}) => _runClubRef(clubId).update(fields);
Future<void> deleteRunClub(String id) => _runClubRef(id).delete();

// After
Future<String> createRunClub({...}) => withFirestoreErrorContext(
  () async { ... },
  collection: _collectionPath,
  action: 'create club',
);
Future<void> updateRunClub({...}) => withFirestoreErrorContext(
  () => _runClubRef(clubId).update(fields),
  collection: _collectionPath,
  action: 'update club',
);
Future<void> deleteRunClub(String id) => withFirestoreErrorContext(
  () => _runClubRef(id).delete(),
  collection: _collectionPath,
  action: 'delete club',
);
```

**`SafetyRepository`** (`lib/safety/data/safety_repository.dart`):

All four Cloud Function calls were unprotected:

```dart
// blockUser, unblockUser, reportUser, requestAccountDeletion
// now all wrapped with collection/action context:
Future<void> blockUser({...}) => withFirestoreErrorContext(
  () => _functions.httpsCallable('blockUser').call({...}),
  collection: 'blocks',
  action: 'block user',
);
```

`withFirestoreErrorContext` already handles `FirebaseFunctionsException` (it's caught before `FirebaseException` since it's a subtype), so Cloud Function calls get the same structured error mapping.

### 2. Extracted `BlockedUser` to its proper domain directory

**New file:** `lib/safety/domain/blocked_user.dart`

The `BlockedUser` class was defined inline in `safety_repository.dart` — the only repository to embed a domain class. Extracted it with a proper `fromFirestore` factory and re-exported from the repository so existing imports continue to work:

```dart
// lib/safety/domain/blocked_user.dart
class BlockedUser {
  const BlockedUser({required this.uid, required this.createdAt, required this.source});
  final String uid;
  final DateTime? createdAt;
  final String source;

  factory BlockedUser.fromFirestore(Map<String, dynamic> data) { ... }
}
```

The repository now imports and re-exports:
```dart
import 'package:catch_dating_app/safety/domain/blocked_user.dart';
export 'package:catch_dating_app/safety/domain/blocked_user.dart';
```

### 3. Standardized stream provider naming to `watch` prefix

9 stream providers were renamed for consistent house style. The `watch` prefix was already the dominant convention (used by RunClubs, Runs, Reviews, Chats, Matches repos):

| Before | After | Repository file |
|--------|-------|----------------|
| `chatMessages` | `watchChatMessages` | `chat_repository.dart` |
| `matchesForUser` | `watchMatchesForUser` | `match_repository.dart` |
| `runsForClub` | `watchRunsForClub` | `run_repository.dart` |
| `attendedRuns` | `watchAttendedRuns` | `run_repository.dart` |
| `signedUpRuns` | `watchSignedUpRuns` | `run_repository.dart` |
| `paymentsForUser` | `watchPaymentsForUser` | `payment_history_repository.dart` |
| `publicProfile` | `watchPublicProfile` | `public_profile_repository.dart` |
| `blockedUsers` | `watchBlockedUsers` | `safety_repository.dart` |
| `userProfileStream` | `watchUserProfile` | `user_profile_repository.dart` |

All 40+ reference sites (in `lib/`, `test/`, and `tool/`) were updated. Generated `.g.dart` files were regenerated via `dart run build_runner build --delete-conflicting-outputs`.

### 4. Fixed `RunDraftRepository` SharedPreferences pattern

**File:** `lib/runs/data/run_draft_repository.dart`

```dart
// Before: new async call on every method invocation
Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

// After: cached after first retrieval
SharedPreferences? _prefsInstance;
Future<SharedPreferences> get _prefs async {
  _prefsInstance ??= await SharedPreferences.getInstance();
  return _prefsInstance!;
}
```

`SharedPreferences.getInstance()` is internally cached so this was harmless in practice, but the lazy `??=` pattern is the standard idiom and signals intent more clearly.

### 5. Fixed riverpod_lint `KeepAliveLink` warning

**File:** `lib/user_profile/data/user_profile_repository.dart`

```dart
// Before
@riverpod
UserProfileRepository userProfileRepository(Ref ref) => ...;

// After
@Riverpod(keepAlive: true)
UserProfileRepository userProfileRepository(Ref ref) => ...;
```

`userProfileStreamProvider` is `keepAlive: true` and internally watches `userProfileRepositoryProvider`. When a keepAlive provider watches a non-keepAlive provider, riverpod_lint warns about the implicit KeepAliveLink. Since `userProfileRepositoryProvider` only wraps `firebaseFirestoreProvider` (already keepAlive), adding `keepAlive: true` is safe and resolves the warning.

## What I did NOT change (and why)

### `RunClubsRepository.createRunClub` — `DateTime.now()` for `createdAt`

This is a **create** operation, not an update. The `PROJECT_CONTEXT.md` convention about avoiding `Timestamp → DateTime → Timestamp` round-trips applies only to read-modify-write cycles on existing documents. For initial document creation, `DateTime.now()` goes through the typed converter (`@TimestampConverter()`) and produces a valid server-storable `Timestamp`. Switching to `FieldValue.serverTimestamp()` would require dropping the typed model in favor of a raw map — trading type safety for a negligible clock-skew improvement.

### `MatchRepository.resetUnread` — raw `catchError`

This method intentionally swallows only `not-found` errors (match docs may not exist yet when a chat is opened). The `test` parameter correctly filters to only `FirebaseException` with code `not-found`. Wrapping with `withFirestoreErrorContext` would **re-throw** that error — exactly the wrong behavior. The current pattern is correct and well-documented.

## Remaining inconsistencies (not fixed in this pass)

These are lower-priority style items that don't affect correctness:

- **Section headers**: 8 of 16 repos use `── Read ──` / `── Write ──` separators; 8 don't. This is purely cosmetic.
- **`auth` and `image_uploads` lack `domain/` directories**: Neither feature has domain models today, so this is only relevant if they grow models later.
- **4 pre-existing `KeepAliveLink` warnings** remain in `onboarding_controller.dart` and `go_router.dart` — these are in presentation/controller layer, not repositories.

## Verification

- `flutter analyze`: 0 errors (same 111 pre-existing info/warnings)
- `build_runner`: regenerated 64 outputs cleanly
- `flutter test --concurrency=1`: 354 pass (13 pre-existing failures from `Tableview` isolation + `_RunConstraints` model issue, both unrelated)
