import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_typography.dart';
import 'package:flutter/material.dart';

/// Reading hierarchy for an activity, distinct from an editable label/value.
/// The parent owns chronology and grouping; this item owns its content lanes.
class HostCustomerHistoryItem extends StatelessWidget {
  const HostCustomerHistoryItem({
    super.key,
    required this.title,
    required this.metadata,
    required this.icon,
    required this.color,
    this.excerpt,
    this.onTap,
  });

  final String title;
  final String metadata;
  final IconData icon;
  final Color color;
  final String? excerpt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => CatchRowPressSurface(
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
              backgroundColor: color.withValues(alpha: CatchOpacity.subtleFill),
              child: Icon(icon, size: CatchIcon.md, color: color),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: HostCustomerTypography.name(context)),
                gapH4,
                Text(metadata, style: HostCustomerTypography.context(context)),
                if (excerpt case final text? when text.isNotEmpty) ...[
                  gapH8,
                  Text(text, style: HostCustomerTypography.body(context)),
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
