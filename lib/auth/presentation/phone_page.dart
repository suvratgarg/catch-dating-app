import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_error_message.dart';
import 'package:catch_dating_app/auth/presentation/auth_form_keys.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:country_code_picker/country_code_picker.dart';
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
    _phoneController.text = ref.read(authControllerProvider).phoneNumber;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final countryCode = ref.read(authControllerProvider).countryCode;
      AuthController.sendOtpMutation.run(ref, (tx) async {
        await tx
            .get(authControllerProvider.notifier)
            .sendOtp(_phoneController.text.trim(), countryCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutation = ref.watch(AuthController.sendOtpMutation);
    final shouldAutofocus = ref.watch(
      authControllerProvider.select((data) => data.step == AuthStep.phone),
    );
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      "What's your number?",
                      style: CatchTextStyles.titleL(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold, color: t.ink),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We'll send you a one-time code to verify.",
                      style: CatchTextStyles.bodyM(context, color: t.ink2),
                    ),
                    const SizedBox(height: 40),
                    CatchTextField(
                      key: AuthFormKeys.phoneField,
                      label: 'Mobile number',
                      controller: _phoneController,
                      autofocus: shouldAutofocus,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [
                        AutofillHints.telephoneNumberNational,
                      ],
                      onSubmitted: (_) => _submit(),
                      onChanged: (_) =>
                          AuthController.sendOtpMutation.reset(ref),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      hintText: '98765 43210',
                      prefixIcon: _buildCountryCodePicker(t),
                      validator: (v) {
                        if (v == null || v.trim().length < 7) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    if (mutation.hasError) ...[
                      gapH16,
                      ErrorBanner(
                        message: authErrorMessage(
                          (mutation as MutationError).error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          CatchButton(
            key: AuthFormKeys.sendCode,
            label: 'Send code',
            onPressed: _submit,
            isLoading: mutation.isPending,
            fullWidth: true,
            size: CatchButtonSize.lg,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCountryCodePicker(CatchTokens t) {
    return CountryCodePicker(
      initialSelection: ref.watch(
        authControllerProvider.select((d) => d.countryCode),
      ),
      onChanged: (code) {
        ref
            .read(authControllerProvider.notifier)
            .setCountryCode(code.dialCode!);
        AuthController.sendOtpMutation.reset(ref);
      },
      showCountryOnly: false,
      showOnlyCountryWhenClosed: false,
      alignLeft: false,
      showFlag: true,
      showDropDownButton: true,
      hideMainText: false,
      favorite: const ['IN'],
      textStyle: CatchTextStyles.bodyM(context, color: t.ink),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      flagDecoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
    );
  }
}
