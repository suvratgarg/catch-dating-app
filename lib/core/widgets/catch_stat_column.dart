import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class CatchStatColumn extends StatelessWidget {
  const CatchStatColumn({
    super.key,
    this.icon,
    this.value,
    required this.label,
    this.highlight = false,
    this.monoValue = false,
    this.center = false,
    this.surface = false,
    this.padding,
    this.borderColor,
  });

  final IconData? icon;
  final String? value;
  final String label;
  final bool highlight;
  final bool monoValue;
  final bool center;
  final bool surface;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final valueColor = highlight ? t.primary : t.ink;
    final labelColor = highlight ? t.primary : t.ink2;
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        if (icon != null) ...[
          Icon(icon, color: t.primary, size: CatchIcon.md),
          gapH6,
        ],
        if (value != null)
          Text(
            value!,
            style: monoValue
                ? CatchTextStyles.mono(context, color: valueColor)
                : CatchTextStyles.metric(context, color: valueColor),
            textAlign: center ? TextAlign.center : null,
          ),
        gapH4,
        Text(
          label,
          style: CatchTextStyles.supporting(context, color: labelColor),
          textAlign: center ? TextAlign.center : null,
        ),
      ],
    );

    if (!surface) {
      return content;
    }

    return CatchSurface(
      padding: padding ?? CatchInsets.contentDense,
      borderColor: borderColor ?? t.line,
      child: content,
    );
  }
}
