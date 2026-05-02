import 'package:catch_dating_app/auth/presentation/auth_error_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authErrorMessage', () {
    test('maps phone auth failures to user-facing messages', () {
      expect(
        authErrorMessage(FirebaseAuthException(code: 'invalid-phone-number')),
        'Please enter a valid phone number.',
      );
      expect(
        authErrorMessage(
          FirebaseAuthException(code: 'invalid-verification-code'),
        ),
        'That code is invalid. Please try again.',
      );
      expect(
        authErrorMessage(FirebaseAuthException(code: 'session-expired')),
        'That code expired. Please request a new one.',
      );
      expect(
        authErrorMessage(FirebaseAuthException(code: 'code-expired')),
        'That code expired. Please request a new one.',
      );
    });

    test('maps shared Firebase auth failures', () {
      expect(
        authErrorMessage(FirebaseAuthException(code: 'network-request-failed')),
        'Check your internet connection and try again.',
      );
      expect(
        authErrorMessage(FirebaseAuthException(code: 'operation-not-allowed')),
        'This sign-in method is not enabled.',
      );
      expect(
        authErrorMessage(FirebaseAuthException(code: 'too-many-requests')),
        'Too many attempts. Please wait a bit and try again.',
      );
      expect(
        authErrorMessage(FirebaseAuthException(code: 'user-disabled')),
        'This account has been disabled.',
      );
    });

    test('uses backend messages and strips common exception prefixes', () {
      expect(
        authErrorMessage(
          FirebaseAuthException(code: 'unexpected', message: 'Backend said no'),
        ),
        'Backend said no',
      );
      expect(
        authErrorMessage(Exception('Readable message')),
        'Readable message',
      );
      expect(authErrorMessage(StateError('Unexpected')), 'Unexpected');
    });
  });

  group('generalErrorMessage', () {
    test('returns StateError messages directly', () {
      expect(
        generalErrorMessage(StateError('Please sign in again.')),
        'Please sign in again.',
      );
    });

    test('returns ArgumentError messages directly', () {
      expect(
        generalErrorMessage(ArgumentError('You must be at least 18.')),
        'You must be at least 18.',
      );
    });

    test('strips common prefixes from other exception types', () {
      expect(
        generalErrorMessage(Exception('Something broke')),
        'Something broke',
      );
      expect(
        generalErrorMessage('Bad state: Invalid data'),
        'Invalid data',
      );
    });
  });
}
