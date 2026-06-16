import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Handoff `CatchSectionLabel`: an activity-accent eyebrow with an optional leading
/// glyph and mono label.
class CatchSectionLabel extends StatelessWidget {
  const CatchSectionLabel({
    super.key,
    required this.label,
    this.icon,
    this.accentColor,
    this.maxLines = 1,
  });

  final String label;
  final IconData? icon;
  final Color? accentColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? CatchTokens.of(context).primary;
    final text = Text(
      label,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.kicker(context, color: accent),
    );

    return Semantics(
      header: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisSize: constraints.hasBoundedWidth
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: CatchIcon.md, color: accent),
                const SizedBox(width: CatchSpacing.s2),
              ],
              if (constraints.hasBoundedWidth) Flexible(child: text) else text,
            ],
          );
        },
      ),
    );
  }
}
