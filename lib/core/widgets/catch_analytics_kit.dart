import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
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
        Text(label, style: CatchTextStyles.kicker(context, color: t.ink3)),
        gapH8,
        child,
      ],
    );
  }
}
