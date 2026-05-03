/// Base class for all app-level exceptions that can be shown to the user.
///
/// Subclasses carry a human-readable [message] and a machine-readable [code].
/// The optional [cause] holds the original error for debugging — it is never
/// shown to users.
///
/// Override [toString] returns [message] so exceptions display cleanly in
/// error widgets without extra formatting.
sealed class AppException implements Exception {
  const AppException(this.code, this.message, {this.cause});

  final String code;
  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

// ── Auth/session ─────────────────────────────────────────────────────────────

class SignInRequiredException extends AppException {
  const SignInRequiredException(String action)
    : super('sign-in-required', 'You need to be signed in to $action.');
}

// ── Network ───────────────────────────────────────────────────────────────────

class NetworkException extends AppException {
  const NetworkException(super.code, super.message, {super.cause});
}

// ── Permissions ───────────────────────────────────────────────────────────────

class PermissionException extends AppException {
  const PermissionException(String message, {Object? cause})
    : super('permission-denied', message, cause: cause);
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

// ── Firestore / data layer ────────────────────────────────────────────────────

class FirestoreWriteException extends AppException {
  const FirestoreWriteException({
    required String code,
    required String message,
    Object? cause,
    this.collection,
    this.action,
  }) : super(code, message, cause: cause);

  final String? collection;
  final String? action;
}

class DocumentNotFoundException extends AppException {
  const DocumentNotFoundException(String path)
    : super('not-found', 'Document not found: $path');
}
