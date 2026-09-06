import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_metric_strip_cell.dart';
import 'package:catch_ui/src/components/catch_metric_strip_divider.dart';
import 'package:catch_ui/src/components/catch_metric_strip_item.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

/// Shared detail-page metric rail used anywhere compact value-over-label stats
/// need to read as one consistent surface.
class CatchMetricStrip extends StatelessWidget {
  const CatchMetricStrip({
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
  });

  final List<CatchMetricStripItem> items;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? dividerColor;
  final Color? valueColor;
  final Color? unitColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
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
                    child: CatchMetricStripCell(
                      item: item,
                      valueColor: valueColor,
                      unitColor: unitColor,
                      labelColor: labelColor,
                    ),
                  ),
                  if (item != items.last)
                    SizedBox(
                      width: double.infinity,
                      height: CatchStroke.hairline,
                      child: ColoredBox(color: dividerColor ?? t.line),
                    ),
                ],
              ],
            )
          : Row(
              children: [
                for (final item in items) ...[
                  CatchMetricStripCell(
                    item: item,
                    valueColor: valueColor,
                    unitColor: unitColor,
                    labelColor: labelColor,
                    expanded: true,
                  ),
                  if (item != items.last)
                    CatchMetricStripDivider(color: dividerColor ?? t.line),
                ],
              ],
            ),
    );
  }
}
