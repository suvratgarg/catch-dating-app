import 'package:flutter/widgets.dart';

abstract final class AuthFormKeys {
  static const countryCode = ValueKey('auth-country-code');
  static const phoneField = ValueKey('auth-phone-field');
  static const sendCode = ValueKey('auth-send-code');
  static const otpField = ValueKey('auth-otp-field');
  static const resendOtp = ValueKey('auth-resend-otp');
  static const changeNumber = ValueKey('auth-change-number');
}
