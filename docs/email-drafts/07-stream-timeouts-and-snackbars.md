From: Claude Code <noreply@anthropic.com>
To: suvratgarg@gmail.com
Subject: [Fixes] Loading timeouts + SnackBar standardization + remaining repos + analytics fields

---

## Items 1-4: The final practical improvements

### Item 1: Loading timeouts on 8 key stream providers

**What:** Added `.timeout(const Duration(seconds: 10))` to every critical stream provider.

**Files:** `run_clubs_repository.dart`, `run_repository.dart`, `match_repository.dart`

Stream providers changed: `watchRunClubsByLocation` × 2, `watchRunClub`, `watchRun`, `runsForClub`, `attendedRuns`, `signedUpRuns`, `matchesForUser`

**Why:** Without a timeout, if a Firestore stream never emits (network down, permission issue, Firestore outage), the user sees a perpetual `CircularProgressIndicator` with no feedback. The `Stream.timeout()` method in Dart throws a `TimeoutException` after the specified duration if no event has been emitted — and crucially, if the first event arrives within the timeout, the timer is cancelled. Firestore typically emits from local cache immediately (~0ms), so users almost never see the timeout in practice.

### Item 2: Standardized error SnackBars

**What:** 4 catch blocks in share/store/save actions now log the actual error (`debugPrint('[ERROR] ...')`) before showing the user-friendly SnackBar. Previously they silently swallowed the error and only showed a generic message.

**Files:** `club_hero_app_bar.dart`, `run_detail_body.dart` (×2), `activity_section.dart`

### Item 3: Wrapped remaining 3 repos

**What:** `SwipeRepository.recordSwipe`, `OnboardingDraftRepository.saveDraft`/`deleteDraft`, and `ImageUploadRepository.upload` now all use `withFirestoreErrorContext`. Every Firestore write in the app is now wrapped.

### Item 4: Fixed analytics collection/action fields

**What:** `FirestoreWriteException` now has `collection` and `action` fields. `AsyncErrorLogger` passes them to `analytics.logFirestoreWriteFailed()`. Analytics events now carry the full context (e.g., `collection: 'runs'`, `action: 'create run'`, `errorCode: 'permission-denied'`).

**Files:** `app_exception.dart`, `firestore_error_util.dart`, `error_logger.dart`
