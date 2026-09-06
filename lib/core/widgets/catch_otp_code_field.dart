import 'package:catch_dating_app/core/schema_contracts/catch_contract_field_policy.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart'
    show CatchContractConstraints, CatchContractFieldConstraints;

/// Canonical one-time-code input primitive.
///
/// The visible digit boxes are token-styled, while the real platform text
/// input remains hidden so SMS autofill, paste, keyboard input, and tests keep
/// using one stable field.
class CatchOtpCodeField extends StatelessWidget {
  const CatchOtpCodeField({
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
    this.hasError = false,
    this.height = CatchLayout.otpDigitHeight,
    this.gap = CatchLayout.otpDigitGap,
    this.autofocus = false,
    this.semanticsLabel = 'One-time code',
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
  final bool hasError;
  final double height;
  final double gap;
  final bool autofocus;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final contractLength = contract?.maxLength;
    assert(
      contract == null || contract!.valueTypes?.contains('string') != false,
      'CatchOtpCodeField requires a string contract.',
    );
    assert(
      contract?.minLength == null ||
          contractLength == null ||
          contract!.minLength == contractLength,
      'CatchOtpCodeField requires an exact-length contract.',
    );
    final effectiveLength = contractLength ?? length ?? 6;
    return Semantics(
      label: semanticsLabel,
      textField: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CatchCodeInputRow(
            length: effectiveLength,
            value: controller.text,
            active: active,
            caret: caret,
            hasError: hasError,
            height: height,
            gap: gap,
            cellKeyPrefix:
                context.l10n.coreCatchOtpCodeFieldVisiblecopyOtpDigit,
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
