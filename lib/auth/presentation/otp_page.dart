import 'dart:async';

import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_form_keys.dart';
import 'package:catch_dating_app/auth/presentation/auth_input.dart';
import 'package:catch_dating_app/auth/presentation/auth_presentation_state.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_otp_code_field.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _otpController = TextEditingController();
  Timer? _resendTimer;
  int _secondsUntilResend = AuthOtpEntryViewState.resendCooldown.inSeconds;

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
    setState(
      () =>
          _secondsUntilResend = AuthOtpEntryViewState.resendCooldown.inSeconds,
    );
    _resendTimer = _createResendTimer();
  }

  Timer _createResendTimer() {
    return Timer.periodic(CatchMotion.authOtpCooldownTick, (timer) {
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
    final viewState = AuthOtpEntryViewState.from(
      data: data,
      otpCode: _otpController.text,
      secondsUntilResend: _secondsUntilResend,
      isVerifyPending: verifyMutation.isPending,
      isSendPending: sendMutation.isPending,
    );
    final t = CatchTokens.of(context);

    return OnboardingStepLayout(
      footer: CatchButton(
        label: 'Verify',
        icon: Icon(CatchIcons.checkRounded),
        onPressed: viewState.canVerify
            ? () => _submit(_otpController.text)
            : null,
        isLoading: viewState.verifyButtonLoading,
        fullWidth: true,
        size: CatchButtonSize.lg,
      ),
      children: [
        CatchStepHeader(
          title: 'Enter the code',
          subtitle: 'Sent to ${viewState.displayPhoneNumber}',
          showBack: false,
          gutter: false,
        ),
        gapH28,
        CatchOtpCodeField(
          inputKey: AuthFormKeys.otpField,
          controller: _otpController,
          autofocus: viewState.shouldAutofocus,
          onSubmitted: _submit,
          onChanged: _handleCodeChanged,
        ),
        if (verifyMutation.hasError) ...[
          gapH16,
          CatchErrorBanner(
            message: appErrorMessage(
              (verifyMutation as MutationError).error,
              context: AppErrorContext.auth,
            ),
          ),
        ],
        if (sendMutation.hasError) ...[
          gapH16,
          CatchErrorBanner(
            message: appErrorMessage(
              (sendMutation as MutationError).error,
              context: AppErrorContext.auth,
            ),
          ),
        ],
        gapH20,
        Text(
          viewState.resendCooldownLabel,
          style: CatchTextStyles.monoLabel(context, color: t.ink3),
        ),
        gapH12,
        Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchButton(
              key: AuthFormKeys.resendOtp,
              label: viewState.resendButtonLabel,
              onPressed: viewState.canResend ? _resendOtp : null,
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              foregroundColor: t.ink,
            ),
            CatchButton(
              key: AuthFormKeys.changeNumber,
              label: 'Change number',
              onPressed: viewState.canChangeNumber
                  ? () => ref
                        .read(authControllerProvider.notifier)
                        .goToStep(AuthStep.phone)
                  : null,
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              foregroundColor: t.ink2,
            ),
          ],
        ),
      ],
    );
  }
}
