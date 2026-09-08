import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_analytics_metric_tile.dart';
import 'package:catch_ui/src/components/catch_metric_card_data.dart';
import 'package:flutter/material.dart';

/// Two-column layout for caller-formatted metrics with an optional item limit.
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
