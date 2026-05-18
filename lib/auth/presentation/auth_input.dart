class AuthInput {
  const AuthInput._();

  static const minPhoneDigits = 7;
  static const maxPhoneDigits = 15;
  static const otpCodeLength = 6;

  static const invalidCountryCodeMessage =
      'Please select a valid country code.';
  static const invalidPhoneNumberMessage = 'Please enter a valid phone number.';
  static const invalidOtpCodeMessage =
      'Please enter the 6-digit code we sent you.';

  static String normalizeCountryCode(String countryCode) {
    final normalized = countryCode.trim();
    if (!RegExp(r'^\+\d{1,4}$').hasMatch(normalized)) {
      throw StateError(invalidCountryCodeMessage);
    }
    return normalized;
  }

  static String normalizePhoneInput(String phoneNumber) {
    final trimmed = phoneNumber.trim();
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length < minPhoneDigits || digits.length > maxPhoneDigits) {
      throw StateError(invalidPhoneNumberMessage);
    }
    return trimmed.startsWith('+') ? '+$digits' : digits;
  }

  static String normalizeOtpCode(String code) {
    final normalized = code.trim();
    if (!RegExp('^\\d{$otpCodeLength}\$').hasMatch(normalized)) {
      throw StateError(invalidOtpCodeMessage);
    }
    return normalized;
  }

  static String formatPhoneNumber({
    required String phoneNumber,
    required String countryCode,
  }) {
    if (phoneNumber.startsWith('+')) {
      return phoneNumber;
    }
    return '$countryCode$phoneNumber';
  }

  static String phoneNumberForState({
    required String phoneNumber,
    required String countryCode,
  }) {
    if (!phoneNumber.startsWith('+')) {
      return phoneNumber;
    }
    if (phoneNumber.startsWith(countryCode)) {
      return phoneNumber.substring(countryCode.length);
    }
    return phoneNumber;
  }

  static String displayPhoneNumber({
    required String phoneNumber,
    required String countryCode,
  }) {
    if (phoneNumber.isEmpty) {
      return 'your number';
    }
    if (phoneNumber.length < 5) {
      return '$countryCode $phoneNumber';
    }
    return '$countryCode $phoneNumber';
  }

  static String maskedPhoneNumber(String phoneNumber) {
    if (phoneNumber.length <= 4) {
      return '****';
    }
    return '****${phoneNumber.substring(phoneNumber.length - 4)}';
  }

  static bool isCompleteOtpCode(String code) => code.length == otpCodeLength;

  static String? phoneNumberError(String? phoneNumber) {
    try {
      normalizePhoneInput(phoneNumber ?? '');
      return null;
    } on StateError catch (error) {
      return error.message;
    }
  }
}
