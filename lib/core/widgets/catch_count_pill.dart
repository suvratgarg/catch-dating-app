import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_count_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Labelled floating action from the handoff's compact-control family.
///
/// The required label and callback keep this distinct from icon-only
/// [CatchIconButton] actions and prevent an action-looking passive surface.
/// Counts stay typed and render through [CatchCountBadge].
class CatchCountPill extends StatelessWidget {
  CatchCountPill.label({
    super.key,
    this.icon,
    required this.label,
    this.value,
    this.count = 0,
    required this.onPressed,
    this.semanticLabel,
  }) : assert(label.trim().isNotEmpty, 'label must not be empty'),
       assert(count >= 0, 'count must not be negative'),
       assert(
         semanticLabel == null || semanticLabel.trim().isNotEmpty,
         'semanticLabel must not be empty when provided',
       );

  final IconData? icon;
  final String label;
  final String? value;
  final int count;
  final VoidCallback onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final labelText = Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.monoLabel(context, color: t.ink),
        );
        final valueText = value == null || value!.isEmpty
            ? null
            : Text(
                value!.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.monoCapsLabel(context, color: t.ink),
              );
        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: CatchIconButton.defaultSize,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, size: CatchLayout.countPillIconSize, color: t.ink),
              if (icon != null) gapW8,
              if (constraints.hasBoundedWidth)
                Flexible(child: labelText)
              else
                labelText,
              if (valueText != null) ...[
                gapW6,
                Text(
                  '·',
                  style: CatchTextStyles.buttonSm(context, color: t.ink3),
                ),
                gapW6,
                if (constraints.hasBoundedWidth)
                  Flexible(child: valueText)
                else
                  valueText,
              ],
            ],
          ),
        );
      },
    );

    final pill = CatchSurface(
      radius: CatchRadius.pill,
      elevation: CatchSurfaceElevation.raised,
      backgroundColor: t.surface.withValues(alpha: 0.94),
      borderColor: t.line2,
      padding: EdgeInsets.only(
        left: CatchSpacing.s4,
        right: count > 0 ? CatchSpacing.s5 : CatchSpacing.s4,
      ),
      onTap: onPressed,
      child: content,
    );

    final countedPill = CatchCountBadge(
      count: count,
      offset: const Offset(CatchSpacing.s1, -CatchSpacing.s1),
      child: pill,
    );

    if (semanticLabel == null) return countedPill;
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: countedPill,
    );
  }
}
