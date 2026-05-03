import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class StatColumn extends StatelessWidget {
  const StatColumn({
    super.key,
    this.icon,
    this.value,
    required this.label,
    this.highlight = false,
    this.monoValue = false,
    this.center = false,
  });

  final IconData? icon;
  final String? value;
  final String label;
  final bool highlight;
  final bool monoValue;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final valueColor = highlight ? t.primary : t.ink;
    final labelColor = highlight ? t.primary : t.ink3;
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        if (icon != null) ...[
          Icon(icon, color: t.primary, size: 18),
          const SizedBox(height: 6),
        ],
        if (value != null)
          Text(
            value!,
            style: monoValue
                ? CatchTextStyles.mono(context, color: valueColor)
                : CatchTextStyles.titleM(context, color: valueColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: center ? TextAlign.center : null,
          ),
        const SizedBox(height: 2),
        Text(
          label,
          style: CatchTextStyles.bodyS(context, color: labelColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: center ? TextAlign.center : null,
        ),
      ],
    );
  }
}
