import 'package:catch_dating_app/common_widgets/error_banner.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
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
        await tx
            .get(onboardingControllerProvider.notifier)
            .verifyOtp(code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingControllerProvider);
    final mutation = ref.watch(OnboardingController.verifyOtpMutation);
    final t = CatchTokens.of(context);

    final maskedPhone = data.phoneNumber.length >= 5
        ? '+91 ${data.phoneNumber.substring(0, 5)} ${data.phoneNumber.substring(5)}'
        : '+91 ${data.phoneNumber}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(
            'Enter the code',
            style: CatchTextStyles.displaySm(context).copyWith(
              fontWeight: FontWeight.bold,
              color: t.ink,
            ),
          ),
          gapH8,
          Text(
            'Sent to $maskedPhone',
            style: CatchTextStyles.bodyMd(context, color: t.ink2),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _otpController,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: CatchTextStyles.displaySm(context).copyWith(
              letterSpacing: 12,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '• • • • • •',
              hintStyle: CatchTextStyles.displaySm(context).copyWith(
                letterSpacing: 12,
                color: t.line,
              ),
            ),
            onChanged: (v) {
              if (v.length == 6) _submit(v);
            },
          ),
          if (mutation.hasError) ...[
            gapH16,
            ErrorBanner(
              message: (mutation as MutationError).error.toString(),
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
                    .goToStep(1),
            child: Text(
              'Resend code',
              style: CatchTextStyles.bodyMd(context, color: t.ink2),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
