import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_code_input_row.dart';
import 'package:catch_ui/src/components/catch_contract_field_constraints.dart';
import 'package:catch_ui/src/components/catch_contract_field_policy.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_code_input_status.dart';
import 'package:catch_ui/src/primitives/catch_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Canonical editable one-time-code input with synchronized visual digits.
///
/// The visible digit boxes are token-styled, while the real platform text
/// input remains hidden so SMS autofill, paste, keyboard input, and tests keep
/// using one stable field.
class CatchCodeInput extends StatelessWidget {
  const CatchCodeInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    this.contract,
    this.contractExemption,
    this.inputKey,
    this.length,
    this.active,
    this.caret = true,
    this.status = CatchCodeInputStatus.ready,
    this.height = CatchLayout.otpDigitHeight,
    this.gap = CatchLayout.otpDigitGap,
    this.autofocus = false,
    required this.semanticsLabel,
  }) : assert(length == null || length > 0);

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final CatchContractFieldConstraints? contract;
  final String? contractExemption;
  final Key? inputKey;
  final int? length;
  final int? active;
  final bool caret;
  final CatchCodeInputStatus status;
  final double height;
  final double gap;
  final bool autofocus;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final contractLength = contract?.maxLength;
    assert(
      contract == null || contract!.valueTypes?.contains('string') != false,
      'CatchCodeInput requires a string contract.',
    );
    assert(
      contract?.minLength == null ||
          contractLength == null ||
          contract!.minLength == contractLength,
      'CatchCodeInput requires an exact-length contract.',
    );
    final effectiveLength = contractLength ?? length ?? 6;
    return Semantics(
      label: semanticsLabel,
      textField: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) => CatchCodeInputRow(
              length: effectiveLength,
              value: value.text,
              active: active,
              caret: caret,
              status: status,
              height: height,
              gap: gap,
              cellKeyPrefix: 'otp_digit',
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: CatchOpacity.hiddenInput,
              child: CatchTextInput(
                key: inputKey,
                controller: controller,
                autofocus: autofocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters:
                    CatchContractFieldPolicy.effectiveInputFormatters(
                      contract,
                      [FilteringTextInputFormatter.digitsOnly],
                      explicitMaxLength: effectiveLength,
                    ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: CatchTextStyles.transparentInput(),
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
