import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Floating CountPill from the handoff.
///
/// Used for Explore map/list toggles and filter affordances: raised surface,
/// hairline border, optional icon, optional mono label, and optional corner
/// badge for active counts.
class CatchCountPill extends StatelessWidget {
  const CatchCountPill({
    super.key,
    this.icon,
    this.label,
    this.badge,
    this.onPressed,
    this.semanticLabel,
  });

  final IconData? icon;
  final String? label;
  final String? badge;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasLabel = label != null && label!.isNotEmpty;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(icon, size: CatchLayout.countPillIconSize, color: t.ink),
        if (icon != null && hasLabel) gapW8,
        if (hasLabel)
          Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.monoLabel(context, color: t.ink),
          ),
      ],
    );

    final pill = CatchSurface(
      radius: CatchRadius.pill,
      elevation: CatchSurfaceElevation.raised,
      backgroundColor: t.surface.withValues(alpha: 0.94),
      borderColor: t.line2,
      padding: hasLabel
          ? const EdgeInsets.symmetric(
              horizontal: CatchSpacing.s4,
              vertical: CatchLayout.countPillLabelVerticalPadding,
            )
          : EdgeInsets.zero,
      width: hasLabel ? null : 38,
      height: hasLabel ? null : 38,
      onTap: onPressed,
      child: content,
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
    return Semantics(label: semanticLabel, child: wrapped);
  }
}
