import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.inputKey,
    this.length = 6,
    this.autofocus = false,
    this.semanticsLabel = 'One-time code',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final Key? inputKey;
  final int length;
  final bool autofocus;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    final code = controller.text;
    final textStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: tokens.ink,
      fontWeight: FontWeight.w700,
    );

    return Semantics(
      label: semanticsLabel,
      textField: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              for (var i = 0; i < length; i++) ...[
                Expanded(
                  child: _OtpDigitBox(
                    key: ValueKey('otp_digit_$i'),
                    digit: i < code.length ? code[i] : '',
                    isActive: code.length == i,
                    textStyle: textStyle,
                  ),
                ),
                if (i < length - 1) gapW8,
              ],
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.01,
              child: TextField(
                key: inputKey,
                controller: controller,
                autofocus: autofocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(length),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(color: Colors.transparent),
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

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    super.key,
    required this.digit,
    required this.isActive,
    required this.textStyle,
  });

  final String digit;
  final bool isActive;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    return AnimatedContainer(
      duration: CatchMotion.fast,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        border: Border.all(
          color: isActive ? tokens.primary : tokens.line2,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Text(digit, style: textStyle),
    );
  }
}
