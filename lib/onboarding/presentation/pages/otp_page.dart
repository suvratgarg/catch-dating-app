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
  final _otpController = TextEditingController();

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingControllerProvider);
    final mutation = ref.watch(OnboardingController.verifyOtpMutation);
    final shouldAutofocus = data.step == OnboardingStep.otp;
    final t = CatchTokens.of(context);

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
          TextField(
            controller: _otpController,
            autofocus: shouldAutofocus,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.center,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              letterSpacing: 12,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '• • • • • •',
              hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                letterSpacing: 12,
                color: t.line,
              ),
            ),
            onSubmitted: _submit,
            onChanged: (v) {
              OnboardingController.verifyOtpMutation.reset(ref);
              if (v.length == 6) _submit(v);
            },
          ),
          if (mutation.hasError) ...[
            gapH16,
            ErrorBanner(
              message: authErrorMessage((mutation as MutationError).error),
            ),
          ],
          gapH24,
          if (mutation.isPending)
            const Center(child: CircularProgressIndicator()),
          gapH16,
          TextButton(
            onPressed: mutation.isPending
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
}
