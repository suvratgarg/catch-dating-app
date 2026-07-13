import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
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

/// Typography intent for compact, non-interactive badge content.
///
/// Metadata keeps authored sentence case. Functional status is normalized to
/// tracked uppercase mono so status language does not drift by feature.
enum CatchBadgeTypography { metadata, functional }

enum _CatchBadgeRecipe { standard, onDark, privacy }

/// Canonical small status badge primitive.
class CatchBadge extends StatelessWidget {
  const CatchBadge({
    super.key,
    required this.label,
    this.tone = CatchBadgeTone.neutral,
    this.size = CatchBadgeSize.sm,
    this.icon,
    this.typography = CatchBadgeTypography.metadata,
    this.accentColor,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  }) : _recipe = _CatchBadgeRecipe.standard;

  const CatchBadge.metadata({
    super.key,
    required this.label,
    this.tone = CatchBadgeTone.neutral,
    this.size = CatchBadgeSize.sm,
    this.icon,
    this.accentColor,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  }) : typography = CatchBadgeTypography.metadata,
       _recipe = _CatchBadgeRecipe.standard;

  const CatchBadge.functional({
    super.key,
    required this.label,
    this.tone = CatchBadgeTone.neutral,
    this.size = CatchBadgeSize.sm,
    this.icon,
    this.accentColor,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  }) : typography = CatchBadgeTypography.functional,
       _recipe = _CatchBadgeRecipe.standard;

  /// Fixed editorial solid treatment for badges on light surfaces.
  const CatchBadge.solid({
    super.key,
    required this.label,
    this.size = CatchBadgeSize.md,
    this.icon,
  }) : tone = CatchBadgeTone.solid,
       typography = CatchBadgeTypography.metadata,
       accentColor = null,
       backgroundColor = null,
       foregroundColor = null,
       borderColor = null,
       _recipe = _CatchBadgeRecipe.standard;

  /// Canonical live-status treatment: live fill, status dot, functional copy.
  const CatchBadge.live({
    super.key,
    required this.label,
    this.size = CatchBadgeSize.sm,
  }) : tone = CatchBadgeTone.live,
       icon = null,
       typography = CatchBadgeTypography.functional,
       accentColor = null,
       backgroundColor = null,
       foregroundColor = null,
       borderColor = null,
       _recipe = _CatchBadgeRecipe.standard;

  /// Fixed treatment for compact metadata over dark, media, or art surfaces.
  const CatchBadge.onDark({super.key, required this.label})
    : tone = CatchBadgeTone.neutral,
      size = CatchBadgeSize.md,
      icon = null,
      typography = CatchBadgeTypography.metadata,
      accentColor = null,
      backgroundColor = null,
      foregroundColor = null,
      borderColor = null,
      _recipe = _CatchBadgeRecipe.onDark;

  /// Canonical trust/privacy chrome. Domain adapters still own localized copy.
  const CatchBadge.privacy({super.key, required this.label, required this.icon})
    : tone = CatchBadgeTone.neutral,
      size = CatchBadgeSize.sm,
      typography = CatchBadgeTypography.functional,
      accentColor = null,
      backgroundColor = null,
      foregroundColor = null,
      borderColor = null,
      _recipe = _CatchBadgeRecipe.privacy;

  final String label;
  final CatchBadgeTone tone;
  final CatchBadgeSize size;
  final IconData? icon;
  final CatchBadgeTypography typography;
  final Color? accentColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final _CatchBadgeRecipe _recipe;

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    final palette = _BadgePalette.from(
      tone,
      tokens,
      recipe: _recipe,
      accentColor: accentColor,
    );
    final metrics = _BadgeMetrics.from(
      size,
      typography: typography,
      recipe: _recipe,
    );
    final displayLabel = typography == CatchBadgeTypography.functional
        ? label.toUpperCase()
        : label;
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
                    CatchStatusDot(color: foreground, size: metrics.dotSize),
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

  static _BadgeMetrics from(
    CatchBadgeSize size, {
    required CatchBadgeTypography typography,
    required _CatchBadgeRecipe recipe,
  }) {
    if (recipe == _CatchBadgeRecipe.onDark) {
      return _BadgeMetrics(
        padding: CatchInsets.compactControlContent,
        minHeight: 0,
        gap: CatchSpacing.s1,
        iconSize: CatchIcon.sm,
        dotSize: CatchSpacing.micro6,
        centerContent: false,
        textStyle: (context, color) =>
            CatchTextStyles.labelL(context, color: color),
      );
    }
    if (recipe == _CatchBadgeRecipe.privacy) {
      return _BadgeMetrics(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.micro10,
          vertical: CatchSpacing.s1,
        ),
        minHeight: 0,
        gap: CatchSpacing.s1,
        iconSize: CatchIcon.micro,
        dotSize: CatchSpacing.micro6,
        centerContent: false,
        textStyle: (context, color) =>
            CatchTextStyles.badgeCaps(context, color: color),
      );
    }
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
        textStyle: typography == CatchBadgeTypography.functional
            ? (context, color) =>
                  CatchTextStyles.badgeCaps(context, color: color)
            : (context, color) => CatchTextStyles.labelS(context, color: color),
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
        textStyle: typography == CatchBadgeTypography.functional
            ? (context, color) => CatchTextStyles.kicker(context, color: color)
            : (context, color) => CatchTextStyles.labelL(context, color: color),
      ),
      CatchBadgeSize.action => _BadgeMetrics(
        padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.micro14),
        minHeight: CatchLayout.badgeActionHeight,
        gap: CatchSpacing.s1,
        iconSize: CatchLayout.badgeActionIconSize,
        dotSize: CatchSpacing.micro6,
        centerContent: true,
        textStyle: typography == CatchBadgeTypography.functional
            ? (context, color) => CatchTextStyles.kicker(context, color: color)
            : (context, color) =>
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
    required _CatchBadgeRecipe recipe,
    Color? accentColor,
  }) {
    if (recipe == _CatchBadgeRecipe.onDark) {
      return _BadgePalette(
        background: CatchTokens.editorialWhite.withValues(
          alpha: CatchOpacity.revealSurfaceFill,
        ),
        foreground: CatchTokens.editorialWhite,
        border: CatchTokens.editorialWhite.withValues(
          alpha: CatchOpacity.eventSuccessSubtleBorder,
        ),
      );
    }
    if (recipe == _CatchBadgeRecipe.privacy) {
      return _BadgePalette(
        background: Colors.transparent,
        foreground: t.ink3,
        border: t.line2,
      );
    }
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
