import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

/// Pace-level background and foreground colors.
///
/// Brightness-aware: muted, dark-safe tones keyed to [CatchTokens] semantics.
@immutable
class PaceLevelColors {
  const PaceLevelColors({required this.bg, required this.fg});
  final Color bg;
  final Color fg;
}

/// Returns brightness-aware pace-level colors derived from [CatchTokens].
PaceLevelColors paceLevelColors(BuildContext context, PaceLevel pace) {
  final t = CatchTokens.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgAlpha = isDark ? 0.22 : 0.12;

  Color toneFor(PaceLevel p) => switch (p) {
    PaceLevel.easy => t.success,
    PaceLevel.moderate => isDark
        ? CatchPaceColors.moderateDark
        : CatchPaceColors.moderateLight,
    PaceLevel.fast => t.warning,
    PaceLevel.competitive => t.danger,
  };

  final fg = toneFor(pace);
  return PaceLevelColors(
    bg: Color.alphaBlend(fg.withValues(alpha: bgAlpha), t.surface),
    fg: fg,
  );
}
