From: Claude Code <noreply@anthropic.com>
To: suvratgarg@gmail.com
Subject: [Fixes 4 & 5] Unified error banners + removed dead code

---

## Fix 4: Unified ErrorBanner and CatchErrorBanner

### What I changed

Merged two separate error banner widgets into a single canonical `ErrorBanner`.

**Deleted:** `lib/core/widgets/catch_error_banner.dart`

**Rewrote:** `lib/core/widgets/error_banner.dart`

**Updated imports** in 3 files that used `CatchErrorBanner`:
- `lib/runs/presentation/attendance_sheet_screen.dart`
- `lib/runs/presentation/create_run_screen.dart`
- `lib/runs/presentation/widgets/run_detail_cta.dart`

### Why this matters

The app had TWO different error banner widgets serving the same purpose:

1. **`ErrorBanner`** (old) — Used theme colors via `colorScheme.errorContainer`, basic layout, no retry button. Used in onboarding pages, write review sheet, create run club screen.

2. **`CatchErrorBanner`** (old) — Used hardcoded red colors (`Color(0xFFCC3333)`), more structured layout with outer surface wrapper, no retry button. Used in attendance sheet, create run screen, run detail CTA.

**The problem with hardcoded colors:** `CatchErrorBanner` used `Color(0xFFFFEEEE)` for background and `Color(0xFFCC3333)` for text. These look fine in light mode but are invisible or jarring in dark mode. Theme-aware colors adapt automatically.

**The merged `ErrorBanner` takes the best of both:**

| Feature | Source |
|---------|--------|
| Structured layout (outer wrapper + inner banner with border) | From `CatchErrorBanner` |
| Theme-aware colors (`colorScheme.error`, `colorScheme.errorContainer`) | From old `ErrorBanner` |
| Optional "Try again" button (`onRetry` callback) | New |

The new API:
```dart
ErrorBanner({required String message, VoidCallback? onRetry})
```

### Design decision: when to use ErrorBanner vs SnackBar

This is an important architectural distinction:

- **`ErrorBanner`** — For errors that are persistent and contextual. The user needs to see the error while they take corrective action. Examples: form validation failure from server, mutation error above a submit button.
- **`SnackBar`** (via `listenForMutationErrorSnackbar`) — For transient errors where the action is already complete. Examples: join/leave club failure, booking cancellation failure. The user already made their intent clear; they just need to know it failed.

A good rule of thumb: If there's something the user can DO about the error (retry, fix input), use `ErrorBanner`. If it's purely informational ("that didn't work"), use a SnackBar.

---

## Fix 5: Removed dead `showSnackbarOnError` code

### What I deleted

**File:** `lib/exceptions/async_error_logger.dart` (entire file)

This contained an extension method `AsyncValueUI` with a `showSnackbarOnError` method. Despite having documentation and a usage example, it had **zero call sites** anywhere in the app (lib/ or test/). No file even imported it.

### Why this matters

Dead code is worse than no code. It:
1. Confuses developers — "Should I use this? Is this the recommended pattern?"
2. Adds maintenance burden — if the API changes, dead code still needs to compile
3. Creates false confidence — "We have error display handled" when in reality nobody uses it

The extension was well-intentioned — automatically show a SnackBar when an `AsyncValue<void>` errors. But it was never adopted because most screens use `AsyncValue.when(error: ...)` directly, and mutations use `listenForMutationErrorSnackbar` or `ErrorBanner`.

### If you want this pattern back later

The extension pattern was actually a good idea for `ref.listen` callbacks. If you want to revive it:

```dart
// In a new file like lib/core/widgets/async_error_snackbar.dart
extension AsyncErrorSnackbar on AsyncValue<void> {
  void showSnackbarOnError(BuildContext context) {
    if (!isLoading && hasError) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(firestoreErrorMessage(error!)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
    }
  }
}
```

Then use it in `ref.listen`:
```dart
ref.listen(someMutation, (_, state) {
  state.showSnackbarOnError(context);
});
```
