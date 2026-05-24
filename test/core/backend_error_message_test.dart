import 'package:catch_dating_app/core/backend_error_message.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('backendErrorMessage', () {
    test('maps auth validation errors', () {
      expect(
        backendErrorMessage(
          FirebaseAuthException(code: 'invalid-phone-number'),
        ),
        startsWith('Please enter a valid phone number.'),
      );
      expect(
        backendErrorMessage(
          FirebaseAuthException(code: 'invalid-verification-code'),
        ),
        startsWith('That code is invalid. Please try again.'),
      );
    });

    test('maps auth retry and session errors', () {
      expect(
        backendErrorMessage(FirebaseAuthException(code: 'session-expired')),
        startsWith('That code expired. Please request a new one.'),
      );
      expect(
        backendErrorMessage(
          FirebaseAuthException(code: 'network-request-failed'),
        ),
        startsWith('Check your internet connection and try again.'),
      );
      expect(
        backendErrorMessage(FirebaseAuthException(code: 'too-many-requests')),
        startsWith('Too many attempts. Please wait a bit and try again.'),
      );
    });

    test('maps auth keychain errors to safe user copy', () {
      const rawKeychainMessage =
          'An error occurred when accessing the keychain. The '
          'NSLocalizedFailureReasonErrorKey field in the NSError.userInfo '
          'dictionary will contain more information about the error encountered';

      final message = backendErrorMessage(
        FirebaseAuthException(code: 'unknown', message: rawKeychainMessage),
      );

      expect(
        message,
        'Unable to finish sign-in on this device. Please restart the app and request a new code.',
      );
      expect(message, isNot(contains('keychain')));
      expect(message, isNot(contains('NSLocalizedFailureReasonErrorKey')));
    });

    test('maps auth captcha errors to safe user copy', () {
      const rawCaptchaMessage =
          'Cannot contact reCAPTCHA. Check your connection and try again.';

      final message = backendErrorMessage(
        FirebaseAuthException(
          code: 'captcha-check-failed',
          message: rawCaptchaMessage,
        ),
      );

      expect(
        message,
        'Unable to complete the verification check. Please close the verification window and try again.',
      );
      expect(message, isNot(contains('reCAPTCHA')));
    });

    test('maps auth web verification cancellation to safe user copy', () {
      const rawCancelMessage = 'The interaction was cancelled by the user.';

      final message = backendErrorMessage(
        FirebaseAuthException(
          code: 'web-context-cancelled',
          message: rawCancelMessage,
        ),
      );

      expect(
        message,
        'Verification was cancelled. Please try again when ready.',
      );
      expect(message, isNot(contains('interaction')));
    });

    test('returns app exception user copy without debug metadata', () {
      const error = NetworkException(
        'timeout',
        'The request timed out. Please try again.',
        debugMessage: 'cloud_firestore/deadline-exceeded',
      );

      expect(
        backendErrorMessage(error),
        contains('The request timed out. Please try again.'),
      );
      expect(backendErrorMessage(error), isNot(contains('[DEBUG]')));
      expect(
        backendErrorMessage(error),
        isNot(contains('cloud_firestore/deadline-exceeded')),
      );
    });

    test('strips common Dart error prefixes', () {
      expect(
        backendErrorMessage(StateError('Please sign in again.')),
        'Please sign in again.',
      );
      expect(
        backendErrorMessage(ArgumentError('You must be at least 18.')),
        'You must be at least 18.',
      );
      expect(
        backendErrorMessage(Exception('Something broke')),
        'Something broke',
      );
      expect(backendErrorMessage('Bad state: Invalid data'), 'Invalid data');
    });
  });
}
