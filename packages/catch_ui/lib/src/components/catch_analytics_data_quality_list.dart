import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_data_quality_row_data.dart';
import 'package:catch_ui/src/components/catch_metric_data_status.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

/// Stacked per-row status surfaces for analytics data-quality rows.
class CatchAnalyticsDataQualityList extends StatelessWidget {
  const CatchAnalyticsDataQualityList({super.key, required this.rows});

  final List<CatchDataQualityRowData> rows;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      children: [
        for (final indexedRow in rows.indexed) ...[
          if (indexedRow.$1 > 0) gapH8,
          CatchSurface(
            padding: CatchInsets.contentDense,
            borderColor: t.line,
            backgroundColor: indexedRow.$2.status == CatchMetricDataStatus.ready
                ? t.surface
                : t.warning.withValues(alpha: CatchOpacity.warningFill),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _dataQualityIcon(indexedRow.$2.status),
                  size: CatchIcon.md,
                  color: indexedRow.$2.status == CatchMetricDataStatus.ready
                      ? t.success
                      : t.warning,
                ),
                const SizedBox(width: CatchSpacing.s3),
                Expanded(
                  child: Text(
                    indexedRow.$2.detail,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

IconData _dataQualityIcon(CatchMetricDataStatus status) {
  return switch (status) {
    CatchMetricDataStatus.ready => CatchIcons.checkCircleOutlineRounded,
    CatchMetricDataStatus.partial => CatchIcons.warningAmberRounded,
    CatchMetricDataStatus.missing => CatchIcons.errorOutlineRounded,
  };
}
