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
    this.minimumSize = const Size(40, 40),
    this.padding = const EdgeInsets.symmetric(horizontal: CatchSpacing.s2),
  });

  final String label;
  final VoidCallback? onPressed;
  final CatchTextButtonTone tone;
  final Color? foregroundColor;
  final Size minimumSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = foregroundColor ?? _toneColor(t);
    final effectiveColor = onPressed == null ? t.ink3 : color;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: t.ink3,
        minimumSize: minimumSize,
        padding: padding,
        textStyle: CatchTextStyles.labelL(context),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: CatchTextStyles.labelL(context, color: effectiveColor),
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
