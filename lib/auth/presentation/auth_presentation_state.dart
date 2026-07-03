import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_input.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';

class AuthPhoneEntryViewState {
  const AuthPhoneEntryViewState({
    required this.countryCode,
    required this.shouldAutofocus,
    required this.sendButtonLoading,
  });

  final String countryCode;
  final bool shouldAutofocus;
  final bool sendButtonLoading;

  factory AuthPhoneEntryViewState.from({
    required AuthScreenState data,
    required bool isSendPending,
  }) {
    return AuthPhoneEntryViewState(
      countryCode: data.countryCode,
      shouldAutofocus: data.step == AuthStep.phone,
      sendButtonLoading: isSendPending,
    );
  }
}

class AuthOtpEntryViewState {
  const AuthOtpEntryViewState({
    required this.displayPhoneNumber,
    required this.shouldAutofocus,
    required this.canVerify,
    required this.verifyButtonLoading,
    required this.canResend,
    required this.resendCooldownLabel,
    required this.resendButtonLabel,
    required this.canChangeNumber,
  });

  static const resendCooldown = CatchMotion.authOtpResendCooldown;

  final String displayPhoneNumber;
  final bool shouldAutofocus;
  final bool canVerify;
  final bool verifyButtonLoading;
  final bool canResend;
  final String resendCooldownLabel;
  final String resendButtonLabel;
  final bool canChangeNumber;

  factory AuthOtpEntryViewState.from({
    required AuthScreenState data,
    required String otpCode,
    required int secondsUntilResend,
    required bool isVerifyPending,
    required bool isSendPending,
  }) {
    return AuthOtpEntryViewState(
      displayPhoneNumber: AuthInput.displayPhoneNumber(
        phoneNumber: data.phoneNumber,
        countryCode: data.countryCode,
      ),
      shouldAutofocus: data.step == AuthStep.otp,
      canVerify:
          AuthInput.isCompleteOtpCode(otpCode) &&
          !isVerifyPending &&
          !isSendPending,
      verifyButtonLoading: isVerifyPending,
      canResend:
          secondsUntilResend <= 0 &&
          data.phoneNumber.isNotEmpty &&
          !isVerifyPending &&
          !isSendPending,
      resendCooldownLabel: resendCooldownLabelFor(secondsUntilResend),
      resendButtonLabel: resendButtonLabelFor(isSendPending),
      canChangeNumber: !isVerifyPending && !isSendPending,
    );
  }

  static String resendCooldownLabelFor(int secondsUntilResend) {
    if (secondsUntilResend <= 0) return 'RESEND NOW';
    final minutes = secondsUntilResend ~/ 60;
    final seconds = (secondsUntilResend % 60).toString().padLeft(2, '0');
    return 'RESEND IN $minutes:$seconds';
  }

  static String resendButtonLabelFor(bool isSending) {
    if (isSending) return 'Sending OTP...';
    return 'Resend OTP';
  }
}
