/// Base class for all app-level exceptions that can be shown to the user.
///
/// Subclasses carry a human-readable [message] and a machine-readable [code].
/// Override [toString] returns [message] so exceptions display cleanly in
/// error widgets without extra formatting.
sealed class AppException implements Exception {
  const AppException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

// ── Auth/session ─────────────────────────────────────────────────────────────

class SignInRequiredException extends AppException {
  const SignInRequiredException(String action)
    : super('sign-in-required', 'You need to be signed in to $action.');
}

// ── Payments ──────────────────────────────────────────────────────────────────

class PaymentCancelledException extends AppException {
  const PaymentCancelledException()
    : super('payment-cancelled', 'Payment was cancelled.');
}

class PaymentFailedException extends AppException {
  const PaymentFailedException(String detail)
    : super('payment-failed', 'Payment failed: $detail');
}

class PaymentVerificationFailedException extends AppException {
  const PaymentVerificationFailedException()
    : super(
        'payment-verification-failed',
        'Payment could not be verified. Please contact support.',
      );
}

// ── Run booking ───────────────────────────────────────────────────────────────

class PaidBookingUnsupportedException extends AppException {
  const PaidBookingUnsupportedException()
    : super(
        'paid-booking-unsupported',
        'Paid bookings are only available on Android and iOS.',
      );
}

class RunBookingFailedException extends AppException {
  const RunBookingFailedException(String message)
    : super('run-booking-failed', message);
}
