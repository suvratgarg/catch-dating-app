import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';

/// Pace-level background and foreground colors.
///
/// These are traffic-light semantic colors that don't vary by brand palette —
/// green = easy, blue = moderate, orange = fast, red = competitive.
@immutable
class PaceLevelColors {
  const PaceLevelColors({required this.bg, required this.fg});
  final Color bg;
  final Color fg;
}

extension PaceLevelTheme on PaceLevel {
  PaceLevelColors get colors => switch (this) {
    PaceLevel.easy => const PaceLevelColors(
      bg: Color(0xFFDCFCE7),
      fg: Color(0xFF166534),
    ),
    PaceLevel.moderate => const PaceLevelColors(
      bg: Color(0xFFDBEAFE),
      fg: Color(0xFF1E40AF),
    ),
    PaceLevel.fast => const PaceLevelColors(
      bg: Color(0xFFFEF3C7),
      fg: Color(0xFF92400E),
    ),
    PaceLevel.competitive => const PaceLevelColors(
      bg: Color(0xFFFFE4E6),
      fg: Color(0xFF9F1239),
    ),
  };
}
