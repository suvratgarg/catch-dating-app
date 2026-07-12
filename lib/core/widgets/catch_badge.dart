import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchBadgeTone {
  neutral,
  brand,
  success,
  warning,
  danger,
  gold,
  solid,
  live,
}

enum CatchBadgeSize { sm, md, action }

/// Canonical small status badge primitive.
class CatchBadge extends StatelessWidget {
  const CatchBadge({
    super.key,
    required this.label,
    this.tone = CatchBadgeTone.neutral,
    this.size = CatchBadgeSize.sm,
    this.icon,
    this.uppercase = false,
    this.accentColor,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final CatchBadgeTone tone;
  final CatchBadgeSize size;
  final IconData? icon;
  final bool uppercase;
  final Color? accentColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = _BadgePalette.from(
      tone,
      CatchTokens.of(context),
      accentColor: accentColor,
    );
    final metrics = _BadgeMetrics.from(size, uppercase: uppercase);
    final displayLabel = uppercase ? label.toUpperCase() : label;
    final foreground = foregroundColor ?? palette.foreground;

    return LayoutBuilder(
      builder: (context, constraints) {
        final label = Text(
          displayLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: metrics.textStyle(context, foreground),
        );
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: metrics.minHeight),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor ?? palette.background,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
              border: Border.all(color: borderColor ?? palette.border),
            ),
            child: Padding(
              padding: metrics.padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: metrics.centerContent
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (tone == CatchBadgeTone.live && accentColor == null) ...[
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
                  if (constraints.hasBoundedWidth)
                    Flexible(child: label)
                  else
                    label,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Overlay badge for icon actions that need an unread/count marker.
class CatchIconBadge extends StatelessWidget {
  const CatchIconBadge({
    super.key,
    required this.label,
    required this.child,
    this.isLabelVisible = true,
    this.alignment = Alignment.topRight,
    this.offset = const Offset(-2, 2),
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final Widget child;
  final bool isLabelVisible;
  final AlignmentGeometry alignment;
  final Offset offset;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final effectiveForeground = foregroundColor ?? t.primaryInk;

    return Badge(
      isLabelVisible: isLabelVisible,
      label: Text(
        label,
        style: CatchTextStyles.statusLabel(context, color: effectiveForeground),
      ),
      backgroundColor: backgroundColor ?? t.primary,
      alignment: alignment,
      offset: offset,
      child: child,
    );
  }
}

class _BadgeMetrics {
  const _BadgeMetrics({
    required this.padding,
    required this.minHeight,
    required this.gap,
    required this.iconSize,
    required this.dotSize,
    required this.centerContent,
    required this.textStyle,
  });

  final EdgeInsetsGeometry padding;
  final double minHeight;
  final double gap;
  final double iconSize;
  final double dotSize;
  final bool centerContent;
  final TextStyle Function(BuildContext context, Color color) textStyle;

  static _BadgeMetrics from(CatchBadgeSize size, {required bool uppercase}) {
    return switch (size) {
      CatchBadgeSize.sm => _BadgeMetrics(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.micro10,
          vertical: CatchSpacing.s1,
        ),
        minHeight: 0,
        gap: CatchSpacing.s1,
        iconSize: CatchIcon.badge,
        dotSize: CatchSpacing.micro6,
        centerContent: false,
        textStyle: uppercase
            ? (context, color) =>
                  CatchTextStyles.badgeCaps(context, color: color)
            : (context, color) => CatchTextStyles.badge(context, color: color),
      ),
      CatchBadgeSize.md => _BadgeMetrics(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchLayout.badgeMdVerticalPadding,
        ),
        minHeight: 0,
        gap: CatchSpacing.s1,
        iconSize: CatchIcon.sm,
        dotSize: CatchLayout.badgeMdDotExtent,
        centerContent: false,
        textStyle: (context, color) =>
            CatchTextStyles.labelL(context, color: color),
      ),
      CatchBadgeSize.action => _BadgeMetrics(
        padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.micro14),
        minHeight: CatchLayout.badgeActionHeight,
        gap: CatchSpacing.s1,
        iconSize: CatchLayout.badgeActionIconSize,
        dotSize: CatchSpacing.micro6,
        centerContent: true,
        textStyle: (context, color) =>
            CatchTextStyles.buttonSm(context, color: color),
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

  static _BadgePalette from(
    CatchBadgeTone tone,
    CatchTokens t, {
    Color? accentColor,
  }) {
    if (accentColor != null) {
      return _BadgePalette(
        background: accentColor.withValues(alpha: CatchOpacity.subtleFill),
        foreground: accentColor,
        border: accentColor.withValues(alpha: CatchOpacity.subtleBorder),
      );
    }
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
        background: t.success.withValues(alpha: CatchOpacity.subtleFill),
        foreground: t.success,
        border: Colors.transparent,
      ),
      CatchBadgeTone.warning => _BadgePalette(
        background: t.warning.withValues(alpha: CatchOpacity.warningFill),
        foreground: t.warning,
        border: Colors.transparent,
      ),
      CatchBadgeTone.danger => _BadgePalette(
        background: t.danger.withValues(alpha: CatchOpacity.dangerFill),
        foreground: t.danger,
        border: Colors.transparent,
      ),
      CatchBadgeTone.gold => _BadgePalette(
        background: t.gold.withValues(alpha: CatchOpacity.subtleFill),
        foreground: t.gold,
        border: t.gold.withValues(alpha: CatchOpacity.subtleBorder),
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
