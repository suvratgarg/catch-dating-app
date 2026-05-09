import 'package:catch_dating_app/runs/presentation/run_booking_error_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';

class TestFirebaseFunctionsException extends FirebaseFunctionsException {
  TestFirebaseFunctionsException({required super.code, required super.message});
}

void main() {
  group('runBookingErrorMessage', () {
    test('prefers callable server messages over generic Firebase text', () {
      final message = runBookingErrorMessage(
        TestFirebaseFunctionsException(
          code: 'failed-precondition',
          message: 'Check-in opens 10 min before the run starts.',
        ),
      );

      expect(message, 'Check-in opens 10 min before the run starts.');
    });

    test('keeps Firestore errors on the Firestore formatter path', () {
      final message = runBookingErrorMessage(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      expect(message, contains('connect'));
    });

    test('surfaces local location permission failures', () {
      final message = runBookingErrorMessage(
        StateError('Allow location access to check in.'),
      );

      expect(message, 'Allow location access to check in.');
    });
  });
}
