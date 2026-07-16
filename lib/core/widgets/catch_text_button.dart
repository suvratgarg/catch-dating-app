import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchTextButtonTone { primary, neutral, danger }

/// Canonical text-only action primitive.
///
/// Use this for inline actions, dialog actions, top-bar text actions, and
/// compact retry links. Use [CatchButton] for pill CTAs.
class CatchTextButton extends StatelessWidget {
  const CatchTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = CatchTextButtonTone.primary,
    this.foregroundColor,
    this.backgroundColor,
    this.disabledForegroundColor,
    this.disabledBackgroundColor,
    this.side,
    this.shape,
    this.textStyle,
    this.leading,
    this.leadingGap = CatchSpacing.micro6,
    this.tapTargetSize,
    this.minimumSize = const Size.square(CatchSpacing.s10),
    this.padding = const EdgeInsets.symmetric(horizontal: CatchSpacing.s2),
  });

  final String label;
  final VoidCallback? onPressed;
  final CatchTextButtonTone tone;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disabledForegroundColor;
  final Color? disabledBackgroundColor;
  final BorderSide? side;
  final OutlinedBorder? shape;
  final TextStyle? textStyle;
  final Widget? leading;
  final double leadingGap;
  final MaterialTapTargetSize? tapTargetSize;
  final Size minimumSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = foregroundColor ?? _toneColor(t);
    final effectiveDisabledColor = disabledForegroundColor ?? t.ink3;
    final effectiveColor = onPressed == null ? effectiveDisabledColor : color;
    final effectiveTextStyle = textStyle ?? CatchTextStyles.labelL(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        backgroundColor: backgroundColor,
        disabledForegroundColor: effectiveDisabledColor,
        disabledBackgroundColor: disabledBackgroundColor,
        minimumSize: minimumSize,
        padding: padding,
        tapTargetSize: tapTargetSize,
        side: side,
        shape: shape,
        textStyle: effectiveTextStyle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, SizedBox(width: leadingGap)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: effectiveTextStyle.copyWith(color: effectiveColor),
            ),
          ),
        ],
      ),
    );
  }

  Color _toneColor(CatchTokens t) {
    return switch (tone) {
      CatchTextButtonTone.primary => t.primary,
      CatchTextButtonTone.neutral => t.ink2,
      CatchTextButtonTone.danger => t.danger,
    };
  }
}
