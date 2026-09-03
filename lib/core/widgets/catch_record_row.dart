import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// A readable record: heading, optional evidence/context, and optional prose.
///
/// Unlike a field, none of these slots represents an editable value. A parent
/// section owns grouping and dividers. Only records with a destination receive
/// press semantics and a disclosure indicator. All text has natural height.
class CatchRecordRow extends StatelessWidget {
  const CatchRecordRow({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    this.metadata,
    this.description,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Color? color;
  final String? metadata;
  final String? description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? CatchTokens.of(context).ink2;
    return CatchRowPressSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: CatchSurface(
                width: CatchSpacing.s10,
                height: CatchSpacing.s10,
                radius: CatchRadius.pill,
                backgroundColor: tone.withValues(
                  alpha: CatchOpacity.subtleFill,
                ),
                child: Icon(icon, size: CatchIcon.md, color: tone),
              ),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: CatchTextStyles.recordTitle(context)),
                  if (metadata case final text? when text.isNotEmpty) ...[
                    gapH4,
                    Text(text, style: CatchTextStyles.recordContext(context)),
                  ],
                  if (description case final text? when text.isNotEmpty) ...[
                    gapH8,
                    Text(text, style: CatchTextStyles.recordBody(context)),
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              gapW8,
              ExcludeSemantics(
                child: Icon(
                  CatchIcons.chevronRightRounded,
                  size: CatchIcon.sm,
                  color: CatchTokens.of(context).ink3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
