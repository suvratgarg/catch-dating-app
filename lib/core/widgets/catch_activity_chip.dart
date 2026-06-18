import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Handoff CatchActivityChip: registry-backed activity glyph, label, and pigment.
class CatchActivityChip extends StatelessWidget {
  const CatchActivityChip({
    super.key,
    required this.activityKind,
    this.primary = false,
    this.label,
    this.onTap,
  });

  final ActivityKind activityKind;
  final bool primary;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, activityKind);
    final foreground = primary ? t.onFill(activity.accent) : activity.deep;

    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: primary ? activity.accent : activity.soft,
      borderWidth: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s4,
        vertical: CatchSpacing.micro10,
      ),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activity.glyph,
            size: CatchLayout.activityChipIconSize,
            color: foreground,
          ),
          const SizedBox(width: CatchLayout.activityChipIconGap),
          Flexible(
            child: Text(
              label ?? activity.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.infoRowTitle(
                context,
                color: foreground,
              ).copyWith(height: 1),
            ),
          ),
        ],
      ),
    );
  }
}
