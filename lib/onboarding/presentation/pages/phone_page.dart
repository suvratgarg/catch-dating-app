import 'package:catch_dating_app/auth/presentation/auth_error_message.dart';
import 'package:catch_dating_app/common_widgets/error_banner.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_step.dart';
import 'package:catch_dating_app/onboarding/presentation/widgets/onboarding_step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhonePage extends ConsumerStatefulWidget {
  const PhonePage({super.key});

  @override
  ConsumerState<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends ConsumerState<PhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = ref.read(onboardingControllerProvider).phoneNumber;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      OnboardingController.sendOtpMutation.run(ref, (tx) async {
        await tx
            .get(onboardingControllerProvider.notifier)
            .sendOtp(_phoneController.text.trim());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(OnboardingController.sendOtpMutation);
    final shouldAutofocus = ref.watch(
      onboardingControllerProvider.select(
        (data) => data.step == OnboardingStep.phone,
      ),
    );
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const OnboardingStepHeader(
              title: "What's your number?",
              subtitle: "We'll send you a one-time code to verify.",
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _phoneController,
              autofocus: shouldAutofocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              onFieldSubmitted: (_) => _submit(),
              onChanged: (_) => OnboardingController.sendOtpMutation.reset(ref),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                prefixIcon: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+91',
                    style: CatchTextStyles.bodyMd(context, color: t.ink),
                  ),
                ),
                hintText: '98765 43210',
                labelText: 'Mobile number',
              ),
              validator: (v) {
                if (v == null || v.trim().length != 10) {
                  return 'Please enter a valid 10-digit number';
                }
                return null;
              },
            ),
            if (mutation.hasError) ...[
              gapH16,
              ErrorBanner(
                message: authErrorMessage((mutation as MutationError).error),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: mutation.isPending ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: mutation.isPending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send code'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
