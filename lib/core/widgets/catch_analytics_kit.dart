import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchMetricStatus { ready, partial, missing }

/// Display-ready payload for one analytics metric tile.
class CatchMetricCardData {
  const CatchMetricCardData({
    required this.icon,
    required this.value,
    required this.label,
    this.caption,
    this.status = CatchMetricStatus.ready,
    this.partialBadgeLabel = 'Partial',
    this.missingBadgeLabel = 'Missing',
  });

  final IconData icon;
  final String value;
  final String label;
  final String? caption;
  final CatchMetricStatus status;
  final String partialBadgeLabel;
  final String missingBadgeLabel;
}

/// Display-ready payload for one analytics data-quality row.
class CatchDataQualityRowData {
  const CatchDataQualityRowData({required this.status, required this.detail});

  final CatchMetricStatus status;
  final String detail;
}

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
            backgroundColor: indexedRow.$2.status == CatchMetricStatus.ready
                ? t.surface
                : t.warning.withValues(alpha: CatchOpacity.warningFill),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _dataQualityIcon(indexedRow.$2.status),
                  size: CatchIcon.md,
                  color: indexedRow.$2.status == CatchMetricStatus.ready
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

IconData _dataQualityIcon(CatchMetricStatus status) {
  return switch (status) {
    CatchMetricStatus.ready => CatchIcons.checkCircleOutlineRounded,
    CatchMetricStatus.partial => CatchIcons.warningAmberRounded,
    CatchMetricStatus.missing => CatchIcons.errorOutlineRounded,
  };
}

class CatchAnalyticsMetricTile extends StatelessWidget {
  const CatchAnalyticsMetricTile({super.key, required this.data});

  final CatchMetricCardData data;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final muted = data.status == CatchMetricStatus.missing;
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
              if (data.status != CatchMetricStatus.ready)
                CatchBadge(
                  label: data.status == CatchMetricStatus.partial
                      ? data.partialBadgeLabel
                      : data.missingBadgeLabel,
                  tone: data.status == CatchMetricStatus.partial
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

class CatchAnalyticsMetricGrid extends StatelessWidget {
  const CatchAnalyticsMetricGrid({
    super.key,
    required this.metrics,
    this.maxItems,
  });

  final List<CatchMetricCardData> metrics;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final visibleMetrics = maxItems == null ? metrics : metrics.take(maxItems!);
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - CatchSpacing.s3) / 2;
        return Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s3,
          children: [
            for (final metric in visibleMetrics)
              SizedBox(
                width: itemWidth,
                child: CatchAnalyticsMetricTile(data: metric),
              ),
          ],
        );
      },
    );
  }
}

class CatchAnalyticsSection extends StatelessWidget {
  const CatchAnalyticsSection({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: CatchKicker(label: label, color: t.ink3),
        ),
        gapH8,
        child,
      ],
    );
  }
}
