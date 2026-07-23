import 'dart:async';

import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_form_keys.dart';
import 'package:catch_dating_app/auth/presentation/auth_input.dart';
import 'package:catch_dating_app/auth/presentation/auth_presentation_state.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/onboarding/shared/onboarding_step_layout.dart';
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
    if (ref.read(AuthController.sendOtpMutation).isPending) return;
    if (_formKey.currentState!.validate()) {
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
    final data = ref.watch(authControllerProvider);
    final mutation = ref.watch(AuthController.sendOtpMutation);
    final viewState = AuthPhoneEntryViewState.from(
      data: data,
      isSendPending: mutation.isPending,
    );
    final l10n = context.l10n;

    return Form(
      key: _formKey,
      child: OnboardingStepLayout(
        footer: CatchButton(
          key: AuthFormKeys.sendCode,
          label: l10n.authSendCodeAction,
          icon: Icon(CatchIcons.arrowForwardRounded),
          onPressed: _submit,
          isLoading: viewState.sendButtonLoading,
          fullWidth: true,
          size: CatchButtonSize.lg,
        ),
        children: [
          CatchStepHeader(
            title: l10n.authPhoneTitle,
            subtitle: l10n.authPhoneSubtitle,
            showBack: false,
            gutter: false,
          ),
          gapH28,
          CatchFormFieldLabel(label: l10n.authPhoneFieldLabel),
          const SizedBox(height: CatchSpacing.s2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CountryCodeSelector(
                countryCode: viewState.countryCode,
                enabled: viewState.requestControlsEnabled,
                onChanged: (code) {
                  ref
                      .read(authControllerProvider.notifier)
                      .setCountryCode(code);
                },
              ),
              gapW8,
              Expanded(
                child: CatchField.input(
                  key: AuthFormKeys.phoneField,
                  title: l10n.authPhoneFieldLabel,
                  showLabel: false,
                  controller: _phoneController,
                  autofocus: viewState.shouldAutofocus,
                  enabled: viewState.requestControlsEnabled,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  onSubmitted: (_) => _submit(),
                  onChanged: (_) => ref
                      .read(authControllerProvider.notifier)
                      .clearSendOtpErrorIfIdle(),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(AuthInput.maxPhoneDigits),
                  ],
                  placeholder: '98765 43210',
                  validator: (value) =>
                      AuthInput.phoneNumberIssue(value) == null
                      ? null
                      : l10n.authInvalidPhoneNumber,
                ),
              ),
            ],
          ),
          if (mutation.hasError) ...[
            gapH16,
            CatchErrorBanner(
              message: appErrorMessage(
                (mutation as MutationError).error,
                l10n: context.l10n,
                context: AppErrorContext.auth,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CountryCodeSelector extends StatelessWidget {
  const CountryCodeSelector({
    super.key,
    required this.countryCode,
    required this.onChanged,
    this.enabled = true,
  });

  final String countryCode;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SizedBox(
      key: AuthFormKeys.countryCode,
      width: CatchLayout.countryCodeSelectorWidth,
      height: CatchField.mdControlHeight,
      child: CatchControlShell(
        enabled: enabled,
        padding: EdgeInsets.zero,
        child: CountryCodePicker(
          enabled: enabled,
          initialSelection: countryIsoForDialCode(countryCode),
          onChanged: (code) {
            final dialCode = code.dialCode;
            if (dialCode == null || dialCode.isEmpty) return;
            onChanged(dialCode);
          },
          showFlagMain: true,
          showFlagDialog: true,
          showDropDownButton: true,
          favorite: supportedCountryPickerFavorites,
          textStyle: CatchTextStyles.bodyLead(context, color: t.ink),
          dialogTextStyle: CatchTextStyles.bodyLead(context, color: t.ink),
          searchStyle: CatchTextStyles.bodyLead(context, color: t.ink),
          headerTextStyle: CatchTextStyles.sectionTitle(context, color: t.ink),
          dialogBackgroundColor: t.surface,
          backgroundColor: t.surface,
          barrierColor: CatchTokens.editorialBlack.withValues(
            alpha: CatchOpacity.mutedBorder,
          ),
          boxDecoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(CatchRadius.md),
            border: Border.all(color: t.line),
          ),
          searchDecoration: InputDecoration(
            hintText: context.l10n.authSearchCountryHint,
            hintStyle: CatchTextStyles.bodyLead(context, color: t.ink3),
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
          closeIcon: Icon(CatchIcons.closeRounded, color: t.ink2),
          padding: CatchInsets.inlineHorizontal,
          margin: CatchInsets.countryCodeFlagMargin,
          flagWidth: CatchSpacing.s6,
          flagDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CatchRadius.xs),
          ),
        ),
      ),
    );
  }
}
