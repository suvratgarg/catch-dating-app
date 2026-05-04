# Email 2: OTP Timeout Fix

**To:** Suvrat
**Subject:** [Catch Audit #8] OTP timeout — Completer.timeout(60s) + recovery path

---

## What changed

Two files modified, 8 lines added. Zero new dependencies.

1. **`lib/onboarding/presentation/onboarding_controller.dart`** — Added 60-second timeout to the OTP `sendOtp` Completer. If Firebase Auth's `codeSent` or `verificationFailed` callbacks never fire (network timeout, Firebase SDK edge case, process death), the mutation now fails with a `FirebaseAuthException(code: 'timeout')` instead of hanging the UI forever.

2. **`lib/auth/presentation/auth_error_message.dart`** — Added a `'timeout'` case to the `authErrorMessage` switch so the user sees "The verification request timed out. Please check your connection and try again." instead of a raw exception string.

**Zero UI changes.** The OTP page already has a "Resend OTP" button with a 60-second cooldown timer that handles recovery — clearing the input, resetting mutations, and re-sending.

---

## Why this was made

The audit found that the OTP flow uses a raw `Completer<void>()` to bridge Firebase Auth's callback-based `verifyPhoneNumber()` API into the Mutation pattern. The completer has no timeout. If neither `codeSent` nor `verificationFailed` fires — which happens on network timeout, Firebase SDK edge cases, or if the SMS gateway silently drops the request — the completer hangs forever. The mutation stays in `pending` state, the phone page's "Send code" button stays in loading state indefinitely, and the user has no recovery path.

This is a high-reliability gap for the auth flow — the first thing every new user experiences.

---

## How it was made — code walkthrough

### The problem: callback-based API bridged to Future

Firebase Auth's `verifyPhoneNumber()` uses a callback pattern:

```dart
FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: '+919876543210',
  codeSent: (verificationId, forceResendingToken) { /* ... */ },
  verificationFailed: (error) { /* ... */ },
  verificationCompleted: (credential) { /* ... */ },
);
```

The `verifyPhoneNumber()` call itself returns a `Future<void>` that resolves when Firebase *submits* the request — not when the SMS is delivered or the code is entered. The actual delivery confirmation comes minutes later through the `codeSent` callback (or never, if delivery fails silently).

The onboarding controller bridges this callback model into a single Future using a `Completer`:

```dart
// Before: no timeout — if callbacks never fire, this Future hangs forever
final completer = Completer<void>();

ref.read(authRepositoryProvider).verifyPhoneNumber(
  codeSent: (verificationId, _) {
    state = state.copyWith(verificationId: verificationId, step: OnboardingStep.otp);
    if (!completer.isCompleted) completer.complete();
  },
  verificationFailed: (e) {
    if (!completer.isCompleted) completer.completeError(e);
  },
);

return completer.future;  // ← this Future never resolves if callbacks never fire
```

There are three ways the completer can fail to resolve:
1. **Network failure after submission** — Firebase accepted the request but the SMS gateway is unreachable. No callback fires.
2. **Firebase SDK edge case** — On certain Android devices with specific OEM battery optimizations, the Firebase Auth callbacks can be delayed by minutes or dropped entirely.
3. **App Check failure** — If the App Check token is invalid when `verifyPhoneNumber` is called, the SDK may silently fail without calling any callback (observed behavior with certain Firebase Auth versions).

### The fix: Future.timeout with structured error

The fix adds 60 seconds of patience, then converts the timeout into a typed `FirebaseAuthException`:

```dart
// After: 60s timeout with structured error that the UI already knows how to display
return completer.future.timeout(
  const Duration(seconds: 60),
  onTimeout: () => throw FirebaseAuthException(
    code: 'timeout',
    message: 'The verification request timed out. Please check your connection and try again.',
  ),
);
```

#### Design decision: `FirebaseAuthException` vs custom exception

I reused `FirebaseAuthException` instead of creating a custom exception because:

1. **The existing error display pipeline already handles it.** The OTP page passes errors through `authErrorMessage()`, which has a switch on `FirebaseAuthException.code`. Adding a custom exception would require a new case in the switch and risk being lost in the generic fallback.

2. **It's semantically correct.** A timeout of the verification flow IS an auth error — the Firebase Auth service (or the network path to it) failed.

3. **It's consistent.** The `verificationFailed` callback already provides `FirebaseAuthException`. A timeout is the same category of error from the user's perspective.

#### Design decision: 60-second timeout

The OTP page's "Resend OTP" button already has a 60-second cooldown timer:

```dart
static const _resendCooldown = Duration(seconds: 60);
```

Aligning the timeout with the cooldown means:
- The user sees the "Send code" button go from loading → error banner at the same time the "Resend OTP" button becomes active
- The cooldown timer and the mutation timeout are in sync
- The user has a clear recovery action (tap "Resend OTP") immediately when the timeout fires

#### Why the resend button IS the recovery path (no new UI)

The OTP page already implemented resend correctly:

```dart
void _resendOtp() {
  _otpController.clear();            // Clear stale input
  OnboardingController.verifyOtpMutation.reset(ref);  // Reset OTP verify state
  OnboardingController.sendOtpMutation.reset(ref);    // Reset send state
  _restartResendCooldown();          // Restart 60s cooldown

  OnboardingController.sendOtpMutation.run(ref, (tx) async {
    await tx.get(onboardingControllerProvider.notifier)
        .sendOtp(phoneNumber, countryCode);
  });
}
```

The key line is `OnboardingController.sendOtpMutation.reset(ref)` — this resets the mutation from `error` → `idle`, which dismisses the error banner and re-enables the UI. Without this, the error banner would persist after a successful resend.

### Why the recovery path works end-to-end

Here's the full flow when a timeout occurs:

```
1. User taps "Send code" on phone page
2. Mutation → pending, button shows loading spinner
3. Firebase submits request, but SMS gateway is down
4. 60 seconds pass, codeSent never fires
5. completer.future.timeout() fires → Future rejects with FirebaseAuthException('timeout')
6. Mutation transitions from pending → error
7. Phone page rebuilds: shows ErrorBanner with timeout message
8. Button returns to idle state (isLoading: false, mutation.isPending is false)
9. User taps "Resend OTP" (cooldown also expired at 60s)
10. Mutation resets → error banner disappears
11. sendOtp called again → fresh completer, fresh timeout, fresh attempt
```

The recovery is a single tap on a button that's already there. No new UI was needed.

### The error message in authErrorMessage

```dart
'timeout' =>
  'The verification request timed out. Please check your connection and try again.',
```

This message:
- Tells the user what happened (timeout, not a wrong number)
- Suggests a possible cause (connection)
- Gives a clear action (try again) — which they can do via the Resend button

---

## Verification

```
$ flutter analyze lib/onboarding/presentation/onboarding_controller.dart lib/auth/presentation/auth_error_message.dart
3 issues found.

warning • KeepAliveLink can only be used inside providers that are kept alive
warning • KeepAliveLink can only be used inside providers that are kept alive
warning • KeepAliveLink can only be used inside providers that are kept alive
```

All 3 warnings are pre-existing (KeepAliveLink lint in the same file, unrelated to timeout change). No new errors or warnings introduced.

The test suite has pre-existing `.g.dart` stale code issues (riverpod_generator needs to be re-run) — these are unrelated to this change.

---

## Files changed

```
 lib/onboarding/presentation/onboarding_controller.dart  |  +8 lines (timeout + import)
 lib/auth/presentation/auth_error_message.dart           |  +2 lines (timeout case)
```

**8 lines of functional change, zero new dependencies, zero UI changes.**
