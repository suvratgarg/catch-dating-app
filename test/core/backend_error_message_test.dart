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
