import 'dart:async';

import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_form_keys.dart';
import 'package:catch_dating_app/auth/presentation/auth_input.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_otp_code_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  static const _resendCooldown = Duration(seconds: 60);

  final _otpController = TextEditingController();
  Timer? _resendTimer;
  int _secondsUntilResend = _resendCooldown.inSeconds;

  @override
  void initState() {
    super.initState();
    _resendTimer = _createResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _submit(String code) {
    if (AuthInput.isCompleteOtpCode(code)) {
      if (ref.read(AuthController.verifyOtpMutation).isPending) return;

      unawaited(
        AuthController.verifyOtpMutation
            .run(ref, (tx) async {
              await tx.get(authControllerProvider.notifier).verifyOtp(code);
            })
            .catchError((Object _) {}),
      );
    }
  }

  void _handleCodeChanged(String value) {
    if (!ref.read(AuthController.verifyOtpMutation).isPending) {
      AuthController.verifyOtpMutation.reset(ref);
    }
    setState(() {});
    if (AuthInput.isCompleteOtpCode(value)) _submit(value);
  }

  void _resendOtp() {
    final data = ref.read(authControllerProvider);
    final phoneNumber = data.phoneNumber;
    final countryCode = data.countryCode;
    if (_secondsUntilResend > 0 || phoneNumber.isEmpty) {
      return;
    }

    _otpController.clear();
    AuthController.verifyOtpMutation.reset(ref);
    AuthController.sendOtpMutation.reset(ref);
    _restartResendCooldown();

    AuthController.sendOtpMutation.run(ref, (tx) async {
      await tx
          .get(authControllerProvider.notifier)
          .sendOtp(phoneNumber, countryCode);
    });
  }

  void _restartResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _secondsUntilResend = _resendCooldown.inSeconds);
    _resendTimer = _createResendTimer();
  }

  Timer _createResendTimer() {
    return Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsUntilResend <= 1) {
        timer.cancel();
        setState(() => _secondsUntilResend = 0);
        return;
      }

      setState(() => _secondsUntilResend--);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(authControllerProvider);
    final verifyMutation = ref.watch(AuthController.verifyOtpMutation);
    final sendMutation = ref.watch(AuthController.sendOtpMutation);
    final shouldAutofocus = data.step == AuthStep.otp;
    final displayPhoneNumber = AuthInput.displayPhoneNumber(
      phoneNumber: data.phoneNumber,
      countryCode: data.countryCode,
    );
    final t = CatchTokens.of(context);
    final canResend =
        _secondsUntilResend == 0 &&
        !verifyMutation.isPending &&
        !sendMutation.isPending;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(
            'Enter the code',
            style: CatchTextStyles.titleL(
              context,
            ).copyWith(fontWeight: FontWeight.bold, color: t.ink),
          ),
          const SizedBox(height: 8),
          Text(
            'Sent to $displayPhoneNumber',
            style: CatchTextStyles.bodyM(context, color: t.ink2),
          ),
          const SizedBox(height: 40),
          CatchOtpCodeField(
            inputKey: AuthFormKeys.otpField,
            controller: _otpController,
            length: AuthInput.otpCodeLength,
            autofocus: shouldAutofocus,
            onSubmitted: _submit,
            onChanged: _handleCodeChanged,
          ),
          if (verifyMutation.hasError) ...[
            gapH16,
            ErrorBanner(
              message: appErrorMessage(
                (verifyMutation as MutationError).error,
                context: AppErrorContext.auth,
              ),
            ),
          ],
          if (sendMutation.hasError) ...[
            gapH16,
            ErrorBanner(
              message: appErrorMessage(
                (sendMutation as MutationError).error,
                context: AppErrorContext.auth,
              ),
            ),
          ],
          gapH24,
          if (verifyMutation.isPending) const CatchLoadingIndicator(),
          gapH16,
          Center(
            child: CatchButton(
              key: AuthFormKeys.resendOtp,
              label: _resendButtonLabel(sendMutation.isPending),
              onPressed: canResend ? _resendOtp : null,
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              foregroundColor: t.primary,
            ),
          ),
          gapH8,
          Center(
            child: CatchButton(
              key: AuthFormKeys.changeNumber,
              label: 'Change number',
              onPressed: verifyMutation.isPending || sendMutation.isPending
                  ? null
                  : () => ref
                        .read(authControllerProvider.notifier)
                        .goToStep(AuthStep.phone),
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              foregroundColor: t.ink2,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _resendButtonLabel(bool isSending) {
    if (isSending) {
      return 'Sending OTP...';
    }

    if (_secondsUntilResend > 0) {
      return 'Resend OTP in ${_secondsUntilResend}s';
    }

    return 'Resend OTP';
  }
}
