import 'dart:ui' show ImageFilter;

import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Floating CountPill from the handoff.
///
/// Used for Explore map/list toggles and filter affordances: raised surface,
/// hairline border, optional icon, optional function label, optional mono data
/// value, and optional corner badge for active counts.
class CatchCountPill extends StatelessWidget {
  const CatchCountPill({
    super.key,
    this.icon,
    this.label,
    this.value,
    this.badge,
    this.onPressed,
    this.semanticLabel,
  });

  final IconData? icon;
  final String? label;
  final String? value;
  final String? badge;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasLabel = label != null && label!.isNotEmpty;
    final hasValue = value != null && value!.isNotEmpty;
    final hasText = hasLabel || hasValue;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(icon, size: CatchLayout.countPillIconSize, color: t.ink),
        if (icon != null && hasText) gapW8,
        if (hasLabel)
          Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.buttonSm(context, color: t.ink),
          ),
        if (hasLabel && hasValue) ...[
          gapW6,
          Text('·', style: CatchTextStyles.buttonSm(context, color: t.ink3)),
          gapW6,
        ],
        if (hasValue)
          Text(
            value!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.monoCapsLabel(context, color: t.ink),
          ),
      ],
    );

    final pill = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: hasText ? 0 : CatchLayout.countPillMinExtent,
        minHeight: CatchLayout.countPillMinExtent,
      ),
      child: CatchSurface(
        radius: CatchRadius.pill,
        elevation: CatchSurfaceElevation.raised,
        backgroundColor: t.surface.withValues(
          alpha: CatchOpacity.overlayPillFill,
        ),
        borderColor: t.line2,
        clipBehavior: Clip.antiAlias,
        padding: hasText
            ? const EdgeInsets.symmetric(
                horizontal: CatchSpacing.s4,
                vertical: CatchLayout.countPillLabelVerticalPadding,
              )
            : EdgeInsets.zero,
        width: hasText ? null : CatchLayout.countPillMinExtent,
        height: hasText ? null : CatchLayout.countPillMinExtent,
        onTap: onPressed,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: CatchLayout.tabBarBlurSigma,
                  sigmaY: CatchLayout.tabBarBlurSigma,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            content,
          ],
        ),
      ),
    );

    final badgeLabel = badge;
    final wrapped = badgeLabel == null || badgeLabel.isEmpty
        ? pill
        : Stack(
            clipBehavior: Clip.none,
            children: [
              pill,
              Positioned(
                top: -CatchSpacing.s1,
                right: -CatchSpacing.s1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.ink,
                    borderRadius: BorderRadius.circular(CatchRadius.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CatchSpacing.micro3,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: CatchSpacing.micro14,
                        minHeight: CatchSpacing.micro14,
                      ),
                      child: Center(
                        child: Text(
                          badgeLabel,
                          style: CatchTextStyles.statusLabel(
                            context,
                            color: t.primaryInk,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

    if (semanticLabel == null) return wrapped;
    return Semantics(
      container: true,
      button: onPressed != null,
      label: semanticLabel,
      onTap: onPressed,
      child: ExcludeSemantics(child: wrapped),
    );
  }
}
