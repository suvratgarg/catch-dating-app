import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_code_input_row.dart';
import 'package:flutter/material.dart';

/// Static handoff `CodeInput` primitive.
///
/// Use this for mock-friendly or externally managed OTP/code rows. For real
/// platform text entry, use `CatchOtpCodeField`, which composes this visual
/// primitive over one hidden `CatchTextInput`.
class CatchCodeInput extends StatelessWidget {
  const CatchCodeInput({
    super.key,
    this.length = 6,
    this.value = '',
    this.active,
    this.caret = true,
    this.hasError = false,
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
  final bool hasError;

  /// Cell height.
  final double height;

  /// Gap between cells.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return CatchCodeInputRow(
      length: length,
      value: value,
      active: active,
      caret: caret,
      hasError: hasError,
      height: height,
      gap: gap,
    );
  }
}
