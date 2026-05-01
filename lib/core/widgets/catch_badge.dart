import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchBadgeTone { neutral, brand, success, warning, danger, solid, live }

enum CatchBadgeSize { sm, md }

/// Canonical small status badge primitive.
class CatchBadge extends StatelessWidget {
  const CatchBadge({
    super.key,
    required this.label,
    this.tone = CatchBadgeTone.neutral,
    this.size = CatchBadgeSize.sm,
    this.icon,
    this.uppercase = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final CatchBadgeTone tone;
  final CatchBadgeSize size;
  final IconData? icon;
  final bool uppercase;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = _BadgePalette.from(tone, CatchTokens.of(context));
    final metrics = _BadgeMetrics.from(size);
    final displayLabel = uppercase ? label.toUpperCase() : label;
    final foreground = foregroundColor ?? palette.foreground;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.background,
        borderRadius: BorderRadius.circular(CatchRadius.pill),
        border: Border.all(color: borderColor ?? palette.border),
      ),
      child: Padding(
        padding: metrics.padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tone == CatchBadgeTone.live) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: foreground,
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                ),
                child: SizedBox.square(dimension: metrics.dotSize),
              ),
              SizedBox(width: metrics.gap),
            ],
            if (icon != null) ...[
              Icon(icon, size: metrics.iconSize, color: foreground),
              SizedBox(width: metrics.gap),
            ],
            Text(
              displayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: metrics.textStyle(context, foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeMetrics {
  const _BadgeMetrics({
    required this.padding,
    required this.gap,
    required this.iconSize,
    required this.dotSize,
    required this.textStyle,
  });

  final EdgeInsetsGeometry padding;
  final double gap;
  final double iconSize;
  final double dotSize;
  final TextStyle Function(BuildContext context, Color color) textStyle;

  static _BadgeMetrics from(CatchBadgeSize size) {
    return switch (size) {
      CatchBadgeSize.sm => _BadgeMetrics(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        gap: CatchSpacing.s1,
        iconSize: 12,
        dotSize: 6,
        textStyle: (context, color) =>
            CatchTextStyles.labelS(context, color: color),
      ),
      CatchBadgeSize.md => _BadgeMetrics(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        gap: CatchSpacing.s1,
        iconSize: 14,
        dotSize: 7,
        textStyle: (context, color) =>
            CatchTextStyles.labelL(context, color: color),
      ),
    };
  }
}

class _BadgePalette {
  const _BadgePalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;

  static _BadgePalette from(CatchBadgeTone tone, CatchTokens t) {
    return switch (tone) {
      CatchBadgeTone.neutral => _BadgePalette(
        background: t.raised,
        foreground: t.ink2,
        border: t.line2,
      ),
      CatchBadgeTone.brand => _BadgePalette(
        background: t.primarySoft,
        foreground: t.primary,
        border: Colors.transparent,
      ),
      CatchBadgeTone.success => _BadgePalette(
        background: t.success.withValues(alpha: 0.12),
        foreground: t.success,
        border: Colors.transparent,
      ),
      CatchBadgeTone.warning => _BadgePalette(
        background: t.warning.withValues(alpha: 0.14),
        foreground: t.warning,
        border: Colors.transparent,
      ),
      CatchBadgeTone.danger => _BadgePalette(
        background: t.danger.withValues(alpha: 0.10),
        foreground: t.danger,
        border: Colors.transparent,
      ),
      CatchBadgeTone.solid => _BadgePalette(
        background: t.ink,
        foreground: t.surface,
        border: Colors.transparent,
      ),
      CatchBadgeTone.live => _BadgePalette(
        background: t.primary,
        foreground: t.primaryInk,
        border: Colors.transparent,
      ),
    };
  }
}
