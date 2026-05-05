import 'package:catch_dating_app/auth/presentation/auth_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthInput', () {
    test('normalizes national phone numbers', () {
      expect(AuthInput.normalizePhoneInput('98765 43210'), '9876543210');
    });

    test('normalizes international phone numbers', () {
      expect(AuthInput.normalizePhoneInput('+91 98765 43210'), '+919876543210');
    });

    test('rejects invalid phone numbers with shared UI message', () {
      expect(
        AuthInput.phoneNumberError('123'),
        AuthInput.invalidPhoneNumberMessage,
      );
    });

    test('normalizes a six digit OTP code', () {
      expect(AuthInput.normalizeOtpCode(' 123456 '), '123456');
    });

    test('rejects malformed OTP codes', () {
      expect(
        () => AuthInput.normalizeOtpCode('12345a'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            AuthInput.invalidOtpCodeMessage,
          ),
        ),
      );
    });

    test('formats and masks phone numbers for UI/logging', () {
      expect(
        AuthInput.formatPhoneNumber(
          phoneNumber: '9876543210',
          countryCode: '+91',
        ),
        '+919876543210',
      );
      expect(
        AuthInput.displayPhoneNumber(
          phoneNumber: '9876543210',
          countryCode: '+91',
        ),
        '+91 98765 43210',
      );
      expect(AuthInput.maskedPhoneNumber('+919876543210'), '****3210');
    });
  });
}
