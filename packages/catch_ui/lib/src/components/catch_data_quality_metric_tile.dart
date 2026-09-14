import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_badge.dart';
import 'package:catch_ui/src/components/catch_metric_data.dart';
import 'package:catch_ui/src/components/catch_metric_data_status.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

/// Summary surface for a caller-formatted metric and its data-quality status.
class CatchDataQualityMetricTile extends StatelessWidget {
  const CatchDataQualityMetricTile({super.key, required this.data});

  final CatchMetricData data;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final muted = data.status == CatchMetricDataStatus.missing;
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: muted
          ? t.warning.withValues(alpha: CatchOpacity.mutedBorderUrgent)
          : t.line,
      backgroundColor: muted
          ? t.warning.withValues(alpha: CatchOpacity.warningFill)
          : t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, size: CatchIcon.sm, color: t.ink2),
              const Spacer(),
              if (data.status != CatchMetricDataStatus.ready)
                CatchBadge(
                  label: data.status == CatchMetricDataStatus.partial
                      ? data.partialBadgeLabel
                      : data.missingBadgeLabel,
                  tone: data.status == CatchMetricDataStatus.partial
                      ? CatchBadgeTone.warning
                      : CatchBadgeTone.neutral,
                ),
            ],
          ),
          gapH12,
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.numericLarge(
              context,
              color: muted ? t.ink3 : t.ink,
            ),
          ),
          gapH4,
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.labelM(context, color: t.ink2),
          ),
          if (data.caption case final caption?
              when caption.trim().isNotEmpty) ...[
            gapH8,
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context, color: t.ink3),
            ),
          ],
        ],
      ),
    );
  }
}
