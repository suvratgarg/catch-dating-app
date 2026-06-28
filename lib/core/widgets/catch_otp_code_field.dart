import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Static handoff `CodeInput` primitive.
///
/// Use this for mock-friendly or externally managed OTP/code rows. For real
/// platform text entry, use [CatchOtpCodeField], which composes this visual
/// primitive over one hidden [TextField].
class CatchCodeInput extends StatelessWidget {
  const CatchCodeInput({
    super.key,
    this.length = 6,
    this.value = '',
    this.active,
    this.caret = true,
    this.height = CatchLayout.otpDigitHeight,
    this.gap = CatchLayout.otpDigitGap,
  }) : assert(length > 0);

  /// Number of cells.
  final int length;

  /// Typed-so-far digits as a string, e.g. "482".
  final String value;

  /// Active cell index. Defaults to the first empty cell.
  final int? active;

  /// Whether an insertion caret appears in the active empty cell.
  final bool caret;

  /// Cell height.
  final double height;

  /// Gap between cells.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return _buildCodeInputRow(
      context,
      length: length,
      value: value,
      active: active,
      caret: caret,
      height: height,
      gap: gap,
      cellKeyPrefix: 'code_digit',
    );
  }
}

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
    this.active,
    this.caret = true,
    this.height = CatchLayout.otpDigitHeight,
    this.gap = CatchLayout.otpDigitGap,
    this.autofocus = false,
    this.semanticsLabel = 'One-time code',
  }) : assert(length > 0);

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final Key? inputKey;
  final int length;
  final int? active;
  final bool caret;
  final double height;
  final double gap;
  final bool autofocus;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      textField: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCodeInputRow(
            context,
            length: length,
            value: controller.text,
            active: active,
            caret: caret,
            height: height,
            gap: gap,
            cellKeyPrefix: 'otp_digit',
          ),
          Positioned.fill(
            child: Opacity(
              opacity: CatchOpacity.hiddenInput,
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

Widget _buildCodeInputRow(
  BuildContext context, {
  required int length,
  required String value,
  required int? active,
  required bool caret,
  required double height,
  required double gap,
  required String cellKeyPrefix,
}) {
  final tokens = CatchTokens.of(context);
  final code = value.length > length ? value.substring(0, length) : value;
  final done = code.length >= length;
  final activeIndex =
      active ?? (code.length < length ? code.length : length - 1);
  final textStyle = CatchTextStyles.code(context, color: tokens.ink);

  return Row(
    children: [
      for (var i = 0; i < length; i++) ...[
        Expanded(
          child: _buildCodeInputCell(
            digit: i < code.length ? code[i] : '',
            isActive: !done && i == activeIndex,
            showCaret: caret,
            height: height,
            textStyle: textStyle,
            key: ValueKey('${cellKeyPrefix}_$i'),
            tokens: tokens,
          ),
        ),
        if (i < length - 1) SizedBox(width: gap),
      ],
    ],
  );
}

Widget _buildCodeInputCell({
  required Key key,
  required String digit,
  required bool isActive,
  required bool showCaret,
  required double height,
  required TextStyle? textStyle,
  required CatchTokens tokens,
}) {
  return AnimatedContainer(
    key: key,
    duration: CatchMotion.fast,
    height: height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(CatchRadius.interactiveTile),
      border: Border.all(
        color: isActive ? tokens.ink : tokens.line2,
        width: isActive ? 1.5 : 1,
      ),
    ),
    child: digit.isNotEmpty
        ? Text(digit, style: textStyle)
        : isActive && showCaret
        ? _buildCodeInputCaret(tokens)
        : null,
  );
}

Widget _buildCodeInputCaret(CatchTokens tokens) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: tokens.ink,
      borderRadius: BorderRadius.circular(CatchRadius.pill),
    ),
    child: const SizedBox(
      width: CatchLayout.otpCaretWidth,
      height: CatchLayout.otpCaretHeight,
    ),
  );
}
