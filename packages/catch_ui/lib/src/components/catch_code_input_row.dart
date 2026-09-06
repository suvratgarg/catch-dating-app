import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_code_input_cell.dart';
import 'package:flutter/material.dart';

/// Token-styled row of verification-code cells.
class CatchCodeInputRow extends StatelessWidget {
  const CatchCodeInputRow({
    super.key,
    this.length = 6,
    this.value = '',
    this.active,
    this.caret = true,
    this.hasError = false,
    this.height = CatchLayout.otpDigitHeight,
    this.gap = CatchLayout.otpDigitGap,
    this.cellKeyPrefix = 'code_digit',
  }) : assert(length > 0);

  final int length;
  final String value;
  final int? active;
  final bool caret;
  final bool hasError;
  final double height;
  final double gap;
  final String cellKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    final code = value.length > length ? value.substring(0, length) : value;
    final done = code.length >= length;
    final activeIndex =
        active ?? (code.length < length ? code.length : length - 1);
    final textStyle = CatchTextStyles.otpDigit(context, color: tokens.ink);

    return Row(
      children: [
        for (var i = 0; i < length; i++) ...[
          Expanded(
            child: CatchCodeInputCell(
              key: ValueKey('${cellKeyPrefix}_$i'),
              digit: i < code.length ? code[i] : '',
              isActive: !done && i == activeIndex,
              hasError: hasError,
              showCaret: caret,
              height: height,
              textStyle: textStyle,
            ),
          ),
          if (i < length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}
