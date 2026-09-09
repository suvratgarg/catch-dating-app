import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_banner_status.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/components/catch_icon_action.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchBannerTone { primary, success, warning, danger, neutral }

enum CatchBannerVariant { message, error, status, statuses }

/// Persistent feedback with one icon, copy and action renderer.
///
/// Message/error recipes remain inline. [CatchBanner.statuses] renders durable
/// header context supplied through CatchBannerStatusScope; canonical screen
/// owners alone place it and consume its publication once.
class CatchBanner extends StatelessWidget {
  const CatchBanner({
    Key? key,
    required String message,
    String? title,
    IconData? icon,
    CatchBannerTone tone = CatchBannerTone.primary,
    List<Widget> actions = const [],
    EdgeInsetsGeometry? padding = CatchInsets.tileContentCompact,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Duration duration = CatchMotion.fast,
  }) : this._(
         key: key,
         message: message,
         title: title,
         icon: icon,
         tone: tone,
         actions: actions,
         padding: padding,
         margin: margin,
         width: width,
         height: height,
         duration: duration,
       );

  const CatchBanner.error({Key? key, required String message})
    : this._(
        key: key,
        message: message,
        variant: CatchBannerVariant.error,
        tone: CatchBannerTone.danger,
        icon: CatchIcons.errorOutlineRounded,
        padding: _errorPadding,
        margin: _errorMargin,
      );

  /// The caller-owned retry label stays required while its callback is absent.
  const CatchBanner.errorWithRetry({
    Key? key,
    required String message,
    required String retryLabel,
    required VoidCallback? onRetry,
  }) : this._(
         key: key,
         message: message,
         retryLabel: retryLabel,
         onRetry: onRetry,
         variant: CatchBannerVariant.error,
         tone: CatchBannerTone.danger,
         icon: CatchIcons.errorOutlineRounded,
         padding: _errorPadding,
         margin: _errorMargin,
       );

  /// Full-width, intrinsically measured bands placed by screen layouts.
  const CatchBanner.statuses({
    Key? key,
    required List<CatchBannerStatus> statuses,
  }) : this._(
         key: key,
         variant: CatchBannerVariant.statuses,
         statuses: statuses,
       );

  const CatchBanner._({
    super.key,
    this.message = '',
    this.title,
    this.icon,
    this.tone = CatchBannerTone.primary,
    this.variant = CatchBannerVariant.message,
    this.actions = const [],
    this.padding = CatchInsets.tileContentCompact,
    this.margin,
    this.width,
    this.height,
    this.duration = CatchMotion.fast,
    this.onRetry,
    this.retryLabel,
    this.statuses = const [],
    this._status,
  });

  static const _errorPadding = EdgeInsets.symmetric(
    horizontal: CatchSpacing.s3,
    vertical: CatchSpacing.micro10,
  );
  static const _errorMargin = EdgeInsets.fromLTRB(
    CatchSpacing.s4,
    CatchSpacing.s2,
    CatchSpacing.s4,
    CatchSpacing.s0,
  );

  final String message;
  final String? title;
  final IconData? icon;
  final CatchBannerTone tone;
  final CatchBannerVariant variant;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Duration duration;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final List<CatchBannerStatus> statuses;
  final CatchBannerStatus? _status;

  @override
  Widget build(BuildContext context) {
    if (variant == CatchBannerVariant.statuses) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final status in statuses)
            CatchBanner._(variant: CatchBannerVariant.status, status: status),
        ],
      );
    }
    final tokens = CatchTokens.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final status = _status;
    final isStatus = status != null;
    final isError = variant == CatchBannerVariant.error;
    final isNeutral = tone == CatchBannerTone.neutral;
    final toneColor = switch (tone) {
      CatchBannerTone.primary => tokens.primary,
      CatchBannerTone.success => tokens.success,
      CatchBannerTone.warning => tokens.warning,
      CatchBannerTone.danger => tokens.danger,
      CatchBannerTone.neutral => tokens.ink2,
    };
    final foreground = isStatus
        ? _readableAccent(tokens, status.color)
        : isError
        ? colorScheme.error
        : null;
    final heading = status?.label.toUpperCase() ?? title;
    final glyph = Icon(
      status?.icon ?? icon ?? CatchIcons.sparkle,
      size: isError ? CatchIcon.xs : CatchIcon.md,
      color: status?.color ?? (isError ? colorScheme.error : toneColor),
    );
    final copy = Column(
      mainAxisSize: isStatus ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isStatus || (heading != null && heading.isNotEmpty)) ...[
          Text(
            heading!,
            style: isStatus
                ? CatchTextStyles.kicker(context, color: foreground)
                : CatchTextStyles.labelL(context),
          ),
          const SizedBox(height: CatchSpacing.s1),
        ],
        Text(
          status?.message ?? message,
          style: CatchTextStyles.supporting(context, color: foreground),
        ),
      ],
    );
    final actionWidgets = <Widget>[
      if (isStatus)
        for (final action in status.actions)
          if (action.icon != null)
            CatchIconAction.icon(
              icon: action.icon!,
              tooltip: action.label,
              onPressed: action.onPressed,
              accent: status.color,
              variant: CatchIconActionVariant.plain,
            )
          else
            CatchButton.text(
              label: action.label,
              onPressed: action.onPressed,
              foregroundColor: foreground,
              minimumSize: const Size.square(CatchLayout.iconButtonSize),
            )
      else ...[
        ...actions,
        if (onRetry != null)
          CatchButton.text(
            label: retryLabel!,
            onPressed: onRetry,
            foregroundColor: colorScheme.error,
            minimumSize: const Size(CatchSpacing.s0, CatchSpacing.s8),
            padding: EdgeInsets.zero,
          ),
      ],
    ];
    final rowChildren = <Widget>[
      if (isStatus)
        glyph
      else
        Padding(
          padding: EdgeInsets.only(
            top: isError ? CatchSpacing.s0 : CatchStroke.hairline,
          ),
          child: glyph,
        ),
      SizedBox(width: isStatus ? CatchSpacing.micro10 : CatchSpacing.s3),
      Expanded(child: copy),
      if (!isStatus)
        for (final action in actionWidgets) ...[
          const SizedBox(width: CatchSpacing.s2),
          action,
        ],
    ];
    if (isStatus) {
      return Semantics(
        key: ValueKey('status_strip.${status.id}'),
        container: true,
        liveRegion: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _background(tokens.bg, status.color),
            border: Border(
              bottom: BorderSide(
                color: status.color.withValues(
                  alpha: CatchOpacity.lightOverlayBorder,
                ),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CatchSpacing.screenPx,
              vertical: CatchSpacing.s2,
            ),
            // Status bands measure their own width. Inline recipes below
            // keep intrinsic sizing without a LayoutBuilder.
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked =
                    MediaQuery.textScalerOf(context).scale(1) >= 1.4 ||
                    constraints.maxWidth <
                        CatchLayout.statusStripInlineMinWidth;
                final statusActions = Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: CatchSpacing.s1,
                  children: actionWidgets,
                );
                final row = Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...rowChildren,
                    if (!stacked && actionWidgets.isNotEmpty) ...[
                      const SizedBox(width: CatchSpacing.s2),
                      statusActions,
                    ],
                  ],
                );
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: CatchSpacing.s12,
                  ),
                  child: stacked
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            row,
                            if (actionWidgets.isNotEmpty) ...[
                              const SizedBox(height: CatchSpacing.s2),
                              statusActions,
                            ],
                          ],
                        )
                      : row,
                );
              },
            ),
          ),
        ),
      );
    }
    final surface = CatchSurface(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      duration: duration,
      radius: CatchRadius.md,
      tone: isNeutral ? CatchSurfaceTone.transparent : CatchSurfaceTone.surface,
      backgroundColor: isError
          ? colorScheme.errorContainer.withValues(
              alpha: CatchOpacity.errorContainerFill,
            )
          : isNeutral
          ? null
          : Color.alphaBlend(
              toneColor.withValues(alpha: CatchOpacity.calloutFill),
              tokens.surface,
            ),
      borderSpec: isError
          ? CatchBorder.resolve(
              tokens,
              CatchBorderRole.boundary,
              color: colorScheme.error.withValues(
                alpha: CatchOpacity.errorContainerBorder,
              ),
            )
          : null,
      borderRole: isNeutral ? CatchBorderRole.boundary : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rowChildren,
      ),
    );
    return isError
        ? ColoredBox(color: colorScheme.surface, child: surface)
        : surface;
  }

  static Color _background(Color background, Color accent) => Color.alphaBlend(
    accent.withValues(alpha: CatchOpacity.tabBarPillFill),
    background,
  );

  // Header copy/actions retain 4.5:1 contrast against their actual tint.
  static Color _readableAccent(CatchTokens tokens, Color accent) {
    final background = _background(tokens.bg, accent);
    final backgroundLuminance = background.computeLuminance() + 0.05;
    for (var step = 0; step <= 10; step++) {
      final candidate = Color.alphaBlend(
        Color.lerp(accent, tokens.ink, step / 10)!,
        background,
      );
      final luminance = candidate.computeLuminance() + 0.05;
      final contrast = luminance > backgroundLuminance
          ? luminance / backgroundLuminance
          : backgroundLuminance / luminance;
      if (contrast >= 4.5) return candidate;
    }
    return tokens.ink;
  }
}
