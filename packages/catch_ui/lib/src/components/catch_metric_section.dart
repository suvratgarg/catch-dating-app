import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_data_quality_metric_tile.dart';
import 'package:catch_ui/src/components/catch_metric_data.dart';
import 'package:catch_ui/src/components/catch_metric_tile.dart';
import 'package:catch_ui/src/components/catch_metric_value.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchMetricSectionVariant { rail, dataQuality }

/// Local arrangement of metric values or data-quality-aware metric tiles.
///
/// The rail shares one surface and reflows into a vertical stack at large text.
/// The data-quality recipe arranges independently surfaced tiles in two columns.
/// It receives formatted data; fetching, aggregation and status evaluation stay
/// with the caller. Generic titled content and field groups use CatchSection.
class CatchMetricSection extends StatelessWidget {
  const CatchMetricSection({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(
      vertical: CatchSpacing.s4,
      horizontal: CatchSpacing.s3,
    ),
    this.backgroundColor,
    this.borderColor,
    this.dividerColor,
    this.valueColor,
    this.unitColor,
    this.labelColor,
  }) : variant = CatchMetricSectionVariant.rail,
       metrics = const [],
       maxItems = null;

  const CatchMetricSection.dataQuality({
    super.key,
    required this.metrics,
    this.maxItems,
  }) : variant = CatchMetricSectionVariant.dataQuality,
       items = const [],
       padding = EdgeInsets.zero,
       backgroundColor = null,
       borderColor = null,
       dividerColor = null,
       valueColor = null,
       unitColor = null,
       labelColor = null;

  final CatchMetricSectionVariant variant;
  final List<CatchMetricValue> items;
  final List<CatchMetricData> metrics;
  final int? maxItems;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? dividerColor;
  final Color? valueColor;
  final Color? unitColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    if (variant == CatchMetricSectionVariant.dataQuality) {
      final visibleMetrics = maxItems == null
          ? metrics
          : metrics.take(maxItems!);
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
                  child: CatchDataQualityMetricTile(data: metric),
                ),
            ],
          );
        },
      );
    }
    assert(items.isNotEmpty);
    final t = CatchTokens.of(context);
    final reflow = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    return CatchSurface(
      padding: padding,
      radius: CatchRadius.md,
      backgroundColor: backgroundColor,
      borderColor: borderColor ?? t.line,
      child: reflow
          ? Column(
              key: const ValueKey('catch_metric_strip.reflow'),
              children: [
                for (final item in items) ...[
                  Padding(
                    padding: CatchInsets.contentVerticalCompact,
                    child: CatchMetricTile.compact(
                      item: item,
                      valueColor: valueColor,
                      unitColor: unitColor,
                      labelColor: labelColor,
                    ),
                  ),
                  if (item != items.last)
                    CatchDivider.section(color: dividerColor ?? t.line),
                ],
              ],
            )
          : Row(
              children: [
                for (final item in items) ...[
                  CatchMetricTile.compact(
                    item: item,
                    valueColor: valueColor,
                    unitColor: unitColor,
                    labelColor: labelColor,
                    expanded: true,
                  ),
                  if (item != items.last)
                    CatchDivider.vertical(color: dividerColor ?? t.line),
                ],
              ],
            ),
    );
  }
}
