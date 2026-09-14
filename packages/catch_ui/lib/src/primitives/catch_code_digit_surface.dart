import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_code_caret_indicator.dart';
import 'package:catch_ui/src/primitives/catch_code_input_status.dart';
import 'package:flutter/material.dart';

/// Token-styled verification-code cell.
class CatchCodeDigitSurface extends StatelessWidget {
  const CatchCodeDigitSurface({
    super.key,
    required this.digit,
    required this.isActive,
    this.status = CatchCodeInputStatus.ready,
    this.showCaret = true,
    this.height = CatchLayout.otpDigitHeight,
    this.textStyle,
  });

  final String digit;
  final bool isActive;
  final CatchCodeInputStatus status;
  final bool showCaret;
  final double height;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    final digitStyle =
        textStyle ?? CatchTextStyles.otpDigit(context, color: tokens.ink);

    return AnimatedContainer(
      duration: CatchMotion.fast,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(CatchRadius.interactiveTile),
        border:
            (status == CatchCodeInputStatus.error
                    ? CatchBorder.resolve(tokens, CatchBorderRole.danger)
                    : isActive
                    ? CatchBorder.resolve(
                        tokens,
                        CatchBorderRole.selected,
                        color: tokens.ink,
                      )
                    : CatchBorder.resolve(tokens, CatchBorderRole.boundary))
                .all,
      ),
      child: digit.isNotEmpty
          ? Text(digit, style: digitStyle)
          : isActive && showCaret
          ? CatchCodeCaretIndicator(color: tokens.ink)
          : null,
    );
  }
}
