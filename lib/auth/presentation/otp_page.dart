import 'dart:async';

import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_form_keys.dart';
import 'package:catch_dating_app/auth/presentation/auth_input.dart';
import 'package:catch_dating_app/auth/presentation/auth_page_presentation.dart';
import 'package:catch_dating_app/auth/presentation/auth_presentation_state.dart';
import 'package:catch_dating_app/auth/presentation/host_auth_widgets.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_otp_code_field.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({
    super.key,
    this.presentation = AuthPagePresentation.standalone,
    this.initialCode = '',
    this.initialSecondsUntilResend,
  });

  final AuthPagePresentation presentation;
  final String initialCode;
  final int? initialSecondsUntilResend;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  late final TextEditingController _otpController;
  Timer? _resendTimer;
  late int _secondsUntilResend;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController(text: widget.initialCode);
    _secondsUntilResend =
        widget.initialSecondsUntilResend ??
        AuthOtpEntryViewState.resendCooldown.inSeconds;
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
    final l10n = context.l10n;
    final resendStatus = viewState.secondsUntilResend <= 0
        ? l10n.authResendNowStatus
        : l10n.authResendCountdownStatus(
            minutes: viewState.secondsUntilResend ~/ 60,
            seconds: (viewState.secondsUntilResend % 60).toString().padLeft(
              2,
              '0',
            ),
          );

    if (widget.presentation == AuthPagePresentation.hostInline) {
      final verifyError = verifyMutation.hasError
          ? appErrorMessage(
              (verifyMutation as MutationError).error,
              l10n: l10n,
              context: AppErrorContext.auth,
            )
          : null;
      final resendLabel = viewState.isSendPending
          ? l10n.authHostSendingCodeAction
          : viewState.secondsUntilResend > 0
          ? l10n.authHostResendCountdownAction(
              minutes: viewState.secondsUntilResend ~/ 60,
              seconds: (viewState.secondsUntilResend % 60).toString().padLeft(
                2,
                '0',
              ),
            )
          : l10n.authHostResendCodeAction;

      final countryIso = countryIsoForDialCode(data.countryCode);
      final reflowPhoneSummary =
          MediaQuery.textScalerOf(context).scale(1) >= 1.6;
      final phoneIdentity = _HostPhoneIdentity(
        countryIso: countryIso,
        countryCode: data.countryCode,
        nationalPhoneNumber: viewState.maskedNationalPhoneNumber.isEmpty
            ? l10n.authYourNumber
            : viewState.maskedNationalPhoneNumber,
      );
      CatchButton editNumberButton({bool fullWidth = false}) => CatchButton(
        key: AuthFormKeys.changeNumber,
        label: l10n.authHostEditNumberAction,
        semanticsLabel: l10n.authChangeNumberAction,
        onPressed: viewState.canChangeNumber
            ? () => ref
                  .read(authControllerProvider.notifier)
                  .goToStep(AuthStep.phone)
            : null,
        variant: CatchButtonVariant.secondary,
        size: CatchButtonSize.sm,
        shape: CatchButtonShape.rounded,
        fullWidth: fullWidth,
      );

      return HostAuthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            HostAuthHeader(
              title: l10n.authHostPhoneTitle,
              subtitle: l10n.authHostPhoneSubtitle,
            ),
            gapH16,
            if (reflowPhoneSummary) ...[
              phoneIdentity,
              gapH12,
              editNumberButton(fullWidth: true),
            ] else
              Row(
                children: [
                  Expanded(child: phoneIdentity),
                  gapW8,
                  editNumberButton(),
                ],
              ),
            gapH16,
            const CatchDivider.section(),
            gapH12,
            Text(
              l10n.authOtpTitle,
              style: CatchTextStyles.fieldLabel(context, color: t.ink),
            ),
            gapH8,
            CatchOtpCodeField(
              inputKey: AuthFormKeys.otpField,
              contract: CatchContractConstraints.mobileFormStateAuthOtpCode,
              controller: _otpController,
              autofocus: viewState.shouldAutofocus,
              hasError: verifyError != null,
              height: CatchLayout.authOtpDigitHeight,
              gap: CatchLayout.authOtpDigitGap,
              onSubmitted: _submit,
              onChanged: _handleCodeChanged,
            ),
            if (verifyError != null) ...[
              gapH8,
              Text(
                verifyError,
                style: CatchTextStyles.supporting(context, color: t.danger),
              ),
            ],
            if (sendMutation.hasError) ...[
              gapH12,
              CatchErrorBanner(
                message: appErrorMessage(
                  (sendMutation as MutationError).error,
                  l10n: l10n,
                  context: AppErrorContext.auth,
                ),
              ),
            ],
            gapH12,
            if (viewState.verifyButtonLoading) ...[
              HostAuthProgressButton(label: l10n.authHostVerifyingStatus),
              gapH8,
              Text(
                l10n.authHostVerificationPendingHint,
                textAlign: TextAlign.center,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ] else if (viewState.isSendPending)
              HostAuthProgressButton(
                key: AuthFormKeys.resendOtp,
                label: resendLabel,
                variant: CatchButtonVariant.secondary,
              )
            else
              CatchButton(
                key: AuthFormKeys.resendOtp,
                label: resendLabel,
                onPressed: viewState.canResend ? _resendOtp : null,
                variant: CatchButtonVariant.secondary,
                size: CatchButtonSize.lg,
                shape: CatchButtonShape.rounded,
                fullWidth: true,
              ),
          ],
        ),
      );
    }

    return OnboardingStepLayout(
      footer: CatchButton(
        label: l10n.authVerifyAction,
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
          title: l10n.authOtpTitle,
          subtitle: l10n.authOtpSentTo(
            phoneNumber: viewState.displayPhoneNumber.isEmpty
                ? l10n.authYourNumber
                : viewState.displayPhoneNumber,
          ),
          showBack: false,
          gutter: false,
        ),
        gapH28,
        CatchOtpCodeField(
          inputKey: AuthFormKeys.otpField,
          contract: CatchContractConstraints.mobileFormStateAuthOtpCode,
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
              l10n: context.l10n,
              context: AppErrorContext.auth,
            ),
          ),
        ],
        if (sendMutation.hasError) ...[
          gapH16,
          CatchErrorBanner(
            message: appErrorMessage(
              (sendMutation as MutationError).error,
              l10n: context.l10n,
              context: AppErrorContext.auth,
            ),
          ),
        ],
        gapH20,
        Text(
          resendStatus,
          style: CatchTextStyles.monoLabel(context, color: t.ink3),
        ),
        gapH12,
        Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchButton(
              key: AuthFormKeys.resendOtp,
              label: viewState.isSendPending
                  ? l10n.authSendingCodeAction
                  : l10n.authResendCodeAction,
              onPressed: viewState.canResend ? _resendOtp : null,
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              foregroundColor: t.ink,
            ),
            CatchButton(
              key: AuthFormKeys.changeNumber,
              label: l10n.authChangeNumberAction,
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

class _HostPhoneIdentity extends StatelessWidget {
  const _HostPhoneIdentity({
    required this.countryIso,
    required this.countryCode,
    required this.nationalPhoneNumber,
  });

  final String countryIso;
  final String countryCode;
  final String nationalPhoneNumber;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Image.asset(
          'flags/${countryIso.toLowerCase()}.png',
          package: 'country_code_picker',
          width: CatchSpacing.s6,
        ),
        gapW8,
        Text(
          countryCode,
          style: CatchTextStyles.fieldRowTitle(context, color: t.ink),
        ),
        gapW8,
        SizedBox(
          height: CatchSpacing.s6,
          child: VerticalDivider(
            width: CatchStroke.emphasis,
            thickness: CatchStroke.hairline,
            color: t.line2,
          ),
        ),
        gapW8,
        Expanded(
          child: Text(
            nationalPhoneNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.fieldRowTitle(context, color: t.ink),
          ),
        ),
      ],
    );
  }
}
