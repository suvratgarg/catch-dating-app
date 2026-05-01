import 'dart:async';

import 'package:catch_dating_app/auth/presentation/auth_error_message.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (code.length == 6) {
      OnboardingController.verifyOtpMutation.run(ref, (tx) async {
        await tx.get(onboardingControllerProvider.notifier).verifyOtp(code);
      });
    }
  }

  void _handleCodeChanged(String value) {
    OnboardingController.verifyOtpMutation.reset(ref);
    setState(() {});
    if (value.length == 6) _submit(value);
  }

  void _resendOtp() {
    final phoneNumber = ref.read(onboardingControllerProvider).phoneNumber;
    if (_secondsUntilResend > 0 || phoneNumber.isEmpty) {
      return;
    }

    _otpController.clear();
    OnboardingController.verifyOtpMutation.reset(ref);
    OnboardingController.sendOtpMutation.reset(ref);
    _restartResendCooldown();

    OnboardingController.sendOtpMutation.run(ref, (tx) async {
      await tx.get(onboardingControllerProvider.notifier).sendOtp(phoneNumber);
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
    final data = ref.watch(onboardingControllerProvider);
    final verifyMutation = ref.watch(OnboardingController.verifyOtpMutation);
    final sendMutation = ref.watch(OnboardingController.sendOtpMutation);
    final shouldAutofocus = data.step == OnboardingStep.otp;
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
          OnboardingStepHeader(
            title: 'Enter the code',
            subtitle: 'Sent to ${_maskedPhoneNumber(data.phoneNumber)}',
          ),
          const SizedBox(height: 40),
          _OtpDigitField(
            controller: _otpController,
            autofocus: shouldAutofocus,
            onSubmitted: _submit,
            onChanged: _handleCodeChanged,
            tokens: t,
          ),
          if (verifyMutation.hasError) ...[
            gapH16,
            ErrorBanner(
              message: authErrorMessage(
                (verifyMutation as MutationError).error,
              ),
            ),
          ],
          if (sendMutation.hasError) ...[
            gapH16,
            ErrorBanner(
              message: authErrorMessage((sendMutation as MutationError).error),
            ),
          ],
          gapH24,
          if (verifyMutation.isPending)
            const Center(child: CircularProgressIndicator()),
          gapH16,
          TextButton(
            onPressed: canResend ? _resendOtp : null,
            child: Text(_resendButtonLabel(sendMutation.isPending)),
          ),
          gapH8,
          TextButton(
            onPressed: verifyMutation.isPending || sendMutation.isPending
                ? null
                : () => ref
                      .read(onboardingControllerProvider.notifier)
                      .goToStep(OnboardingStep.phone),
            child: Text(
              'Change number',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: t.ink2),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _maskedPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return 'your number';
    }

    if (phoneNumber.length < 5) {
      return '+91 $phoneNumber';
    }

    return '+91 ${phoneNumber.substring(0, 5)} ${phoneNumber.substring(5)}';
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

class _OtpDigitField extends StatelessWidget {
  const _OtpDigitField({
    required this.controller,
    required this.autofocus,
    required this.onChanged,
    required this.onSubmitted,
    required this.tokens,
  });

  final TextEditingController controller;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    final code = controller.text;
    final textStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: tokens.ink,
      fontWeight: FontWeight.w700,
    );

    return Semantics(
      label: 'One-time code',
      textField: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              for (var i = 0; i < 6; i++) ...[
                Expanded(
                  child: _OtpDigitBox(
                    key: ValueKey('otp_digit_$i'),
                    digit: i < code.length ? code[i] : '',
                    isActive: code.length == i,
                    textStyle: textStyle,
                    tokens: tokens,
                  ),
                ),
                if (i < 5) const SizedBox(width: 8),
              ],
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.01,
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(color: Colors.transparent),
                enableInteractiveSelection: false,
                showCursor: false,
                onSubmitted: onSubmitted,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    super.key,
    required this.digit,
    required this.isActive,
    required this.textStyle,
    required this.tokens,
  });

  final String digit;
  final bool isActive;
  final TextStyle? textStyle;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? tokens.primary : tokens.line2,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Text(digit, style: textStyle),
    );
  }
}
