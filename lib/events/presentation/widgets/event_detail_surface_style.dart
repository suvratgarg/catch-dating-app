import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class EventDetailSurfaceStyle {
  const EventDetailSurfaceStyle({
    required this.isDark,
    required this.pageBackground,
    required this.surfaceBackground,
    required this.raisedBackground,
    required this.borderColor,
    required this.dividerColor,
    required this.headingColor,
    required this.bodyColor,
    required this.mutedColor,
    required this.primaryColor,
    required this.primarySoftColor,
  });

  final bool isDark;
  final Color pageBackground;
  final Color surfaceBackground;
  final Color raisedBackground;
  final Color borderColor;
  final Color dividerColor;
  final Color headingColor;
  final Color bodyColor;
  final Color mutedColor;
  final Color primaryColor;
  final Color primarySoftColor;

  factory EventDetailSurfaceStyle.light(
    CatchTokens t, {
    bool useWhite = false,
  }) {
    return EventDetailSurfaceStyle(
      isDark: false,
      pageBackground: useWhite ? t.surface : t.bg,
      surfaceBackground: t.surface,
      raisedBackground: t.raised,
      borderColor: t.line,
      dividerColor: t.line,
      headingColor: t.ink,
      bodyColor: t.ink2,
      mutedColor: t.ink3,
      primaryColor: t.primary,
      primarySoftColor: t.primarySoft,
    );
  }

  factory EventDetailSurfaceStyle.dark(CatchTokens t) {
    return EventDetailSurfaceStyle(
      isDark: true,
      pageBackground: t.ink,
      surfaceBackground: const Color(0xFF1D1814),
      raisedBackground: Colors.white.withValues(alpha: 0.07),
      borderColor: Colors.white.withValues(alpha: 0.12),
      dividerColor: Colors.white.withValues(alpha: 0.12),
      headingColor: t.primaryInk,
      bodyColor: t.primaryInk.withValues(alpha: 0.78),
      mutedColor: t.primaryInk.withValues(alpha: 0.58),
      primaryColor: t.primary,
      primarySoftColor: t.primary.withValues(alpha: 0.18),
    );
  }
}
