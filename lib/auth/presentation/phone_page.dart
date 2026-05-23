import 'dart:async';

import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_form_keys.dart';
import 'package:catch_dating_app/auth/presentation/auth_input.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
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
      if (ref.read(AuthController.sendOtpMutation).isPending) return;

      final countryCode = ref.read(authControllerProvider).countryCode;
      unawaited(
        AuthController.sendOtpMutation
            .run(ref, (tx) async {
              await tx
                  .get(authControllerProvider.notifier)
                  .sendOtp(_phoneController.text.trim(), countryCode);
            })
            .catchError((Object _) {}),
      );
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
                    const CatchFormFieldLabel(label: 'Mobile number'),
                    const SizedBox(height: CatchSpacing.s2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CountryCodeSelector(
                          countryCode: ref.watch(
                            authControllerProvider.select((d) => d.countryCode),
                          ),
                          onChanged: (code) {
                            ref
                                .read(authControllerProvider.notifier)
                                .setCountryCode(code);
                            AuthController.sendOtpMutation.reset(ref);
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CatchTextField(
                            key: AuthFormKeys.phoneField,
                            label: 'Mobile number',
                            showLabel: false,
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
                              LengthLimitingTextInputFormatter(
                                AuthInput.maxPhoneDigits,
                              ),
                            ],
                            hintText: '98765 43210',
                            validator: AuthInput.phoneNumberError,
                          ),
                        ),
                      ],
                    ),
                    if (mutation.hasError) ...[
                      gapH16,
                      ErrorBanner(
                        message: appErrorMessage(
                          (mutation as MutationError).error,
                          context: AppErrorContext.auth,
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
}

class _CountryCodeSelector extends StatelessWidget {
  const _CountryCodeSelector({
    required this.countryCode,
    required this.onChanged,
  });

  final String countryCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SizedBox(
      width: 120,
      height: CatchTextField.mdControlHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(CatchRadius.sm),
          border: Border.all(color: t.line2, width: 1.5),
        ),
        child: CountryCodePicker(
          initialSelection: countryIsoForDialCode(countryCode),
          onChanged: (code) {
            final dialCode = code.dialCode;
            if (dialCode == null || dialCode.isEmpty) return;
            onChanged(dialCode);
          },
          showCountryOnly: false,
          showOnlyCountryWhenClosed: false,
          alignLeft: false,
          showFlag: true,
          showFlagMain: true,
          showFlagDialog: true,
          showDropDownButton: true,
          hideMainText: false,
          favorite: supportedCountryPickerFavorites,
          textStyle: CatchTextStyles.bodyM(context, color: t.ink),
          dialogTextStyle: CatchTextStyles.bodyM(context, color: t.ink),
          searchStyle: CatchTextStyles.bodyM(context, color: t.ink),
          headerTextStyle: CatchTextStyles.titleM(context, color: t.ink),
          dialogBackgroundColor: t.surface,
          backgroundColor: t.surface,
          barrierColor: Colors.black.withValues(alpha: 0.54),
          boxDecoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(CatchRadius.md),
            border: Border.all(color: t.line),
          ),
          searchDecoration: InputDecoration(
            hintText: 'Search country',
            hintStyle: CatchTextStyles.bodyM(context, color: t.ink3),
            filled: true,
            fillColor: t.raised,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CatchRadius.sm),
              borderSide: BorderSide(color: t.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CatchRadius.sm),
              borderSide: BorderSide(color: t.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CatchRadius.sm),
              borderSide: BorderSide(color: t.primary),
            ),
          ),
          closeIcon: Icon(Icons.close_rounded, color: t.ink2),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          margin: const EdgeInsets.only(right: 6),
          flagWidth: 24,
          flagDecoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
