import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchBannerTone { primary, success, warning, danger, neutral }

enum CatchBannerVariant { message, error }

/// Persistent inline feedback with one icon, text, and action layout.
///
/// Semantic messages use [tone]; [CatchBanner.error] and
/// [CatchBanner.errorWithRetry] preserve the compact failure recipe. Callers
/// resolve all copy and retry eligibility; this component owns no error mapping.
class CatchBanner extends StatelessWidget {
  const CatchBanner({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.tone = CatchBannerTone.primary,
    this.actions = const [],
    this.padding = CatchInsets.tileContentCompact,
    this.margin,
    this.width,
    this.height,
    this.duration = CatchMotion.fast,
  }) : variant = CatchBannerVariant.message,
       onRetry = null,
       retryLabel = null;

  const CatchBanner.error({super.key, required this.message})
    : variant = CatchBannerVariant.error,
      tone = CatchBannerTone.danger,
      title = null,
      icon = CatchIcons.errorOutlineRounded,
      actions = const [],
      onRetry = null,
      retryLabel = null,
      padding = _errorPadding,
      margin = _errorMargin,
      width = null,
      height = null,
      duration = CatchMotion.fast;

  /// The caller-owned retry label remains required while the callback is absent.
  const CatchBanner.errorWithRetry({
    super.key,
    required this.message,
    required String this.retryLabel,
    required this.onRetry,
  }) : variant = CatchBannerVariant.error,
       tone = CatchBannerTone.danger,
       title = null,
       icon = CatchIcons.errorOutlineRounded,
       actions = const [],
       padding = _errorPadding,
       margin = _errorMargin,
       width = null,
       height = null,
       duration = CatchMotion.fast;

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

  @override
  Widget build(BuildContext context) {
    final tokens = CatchTokens.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isError = variant == CatchBannerVariant.error;
    final isNeutral = tone == CatchBannerTone.neutral;
    final toneColor = switch (tone) {
      CatchBannerTone.primary => tokens.primary,
      CatchBannerTone.success => tokens.success,
      CatchBannerTone.warning => tokens.warning,
      CatchBannerTone.danger => tokens.danger,
      CatchBannerTone.neutral => tokens.ink2,
    };
    final content = CatchSurface(
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
      // This is a containment line; preserve its hairline width while applying
      // the existing error pigment. The danger role has a different geometry.
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
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: isError ? CatchSpacing.s0 : CatchStroke.hairline,
            ),
            child: Icon(
              icon ?? CatchIcons.sparkle,
              size: isError ? CatchIcon.xs : CatchIcon.md,
              color: isError ? colorScheme.error : toneColor,
            ),
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(title!, style: CatchTextStyles.labelL(context)),
                  const SizedBox(height: CatchSpacing.s1),
                ],
                Text(
                  message,
                  style: CatchTextStyles.supporting(
                    context,
                    color: isError ? colorScheme.error : null,
                  ),
                ),
              ],
            ),
          ),
          for (final action in actions) ...[gapW8, action],
          if (onRetry != null) ...[
            gapW8,
            CatchButton.text(
              label: retryLabel!,
              onPressed: onRetry,
              foregroundColor: colorScheme.error,
              minimumSize: const Size(CatchSpacing.s0, CatchSpacing.s8),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
    return isError
        ? ColoredBox(color: colorScheme.surface, child: content)
        : content;
  }
}
