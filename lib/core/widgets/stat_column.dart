import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Vertical stat display with optional icon, value, and label — used in
/// calendar headers, host manage panels, recap screens, and swipe hubs.
///
/// Usage:
/// ```dart
/// StatColumn(icon: Icons.check_circle_outline, value: '12/20', label: 'BOOKED')
/// StatColumn(value: '42 km', label: 'DISTANCE')
/// ```
class StatColumn extends StatelessWidget {
  const StatColumn({
    super.key,
    this.icon,
    this.value,
    required this.label,
    this.highlight = false,
  });

  final IconData? icon;
  final String? value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final valueColor = highlight ? t.primary : t.ink;
    final labelColor = highlight ? t.primary : t.ink3;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: t.primary, size: 18),
          const SizedBox(height: 6),
        ],
        if (value != null)
          Text(
            value!,
            style: CatchTextStyles.titleM(context, color: valueColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 2),
        Text(
          label,
          style: CatchTextStyles.bodyS(context, color: labelColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
