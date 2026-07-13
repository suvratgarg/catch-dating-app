import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:flutter/material.dart';

enum CatchInlineStatusTone { neutral, success, warning, danger, live }

/// Quiet, unboxed status made from a semantic dot and supporting copy.
class CatchInlineStatus extends StatelessWidget {
  const CatchInlineStatus({
    super.key,
    required this.label,
    this.tone = CatchInlineStatusTone.neutral,
  });

  final String label;
  final CatchInlineStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = switch (tone) {
      CatchInlineStatusTone.neutral => t.ink3,
      CatchInlineStatusTone.success => t.success,
      CatchInlineStatusTone.warning => t.warning,
      CatchInlineStatusTone.danger => t.danger,
      CatchInlineStatusTone.live => t.primary,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final copy = Text(
          label,
          style: CatchTextStyles.supporting(context, color: color),
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchStatusDot(color: color, size: CatchIcon.unsavedDot),
            gapW6,
            if (constraints.hasBoundedWidth) Flexible(child: copy) else copy,
          ],
        );
      },
    );
  }
}
