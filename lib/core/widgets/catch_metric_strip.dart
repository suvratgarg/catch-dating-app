import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class CatchMetricStripItem {
  const CatchMetricStripItem({
    required this.value,
    required this.label,
    this.unit = '',
  });

  final String value;
  final String unit;
  final String label;
}

/// Shared detail-page metric rail used anywhere compact value-over-label stats
/// need to read as one consistent surface.
class CatchMetricStrip extends StatelessWidget {
  CatchMetricStrip({
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
  }) : assert(items.isNotEmpty);

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
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: padding,
      radius: CatchRadius.md,
      backgroundColor: backgroundColor,
      borderColor: borderColor ?? t.line,
      child: Row(
        children: [
          for (final item in items) ...[
            _CatchMetricCell(
              item: item,
              valueColor: valueColor,
              unitColor: unitColor,
              labelColor: labelColor,
            ),
            if (item != items.last)
              _CatchMetricDivider(color: dividerColor ?? t.line),
          ],
        ],
      ),
    );
  }
}

class _CatchMetricCell extends StatelessWidget {
  const _CatchMetricCell({
    required this.item,
    this.valueColor,
    this.unitColor,
    this.labelColor,
  });

  final CatchMetricStripItem item;
  final Color? valueColor;
  final Color? unitColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  item.value,
                  style: CatchTextStyles.mono(context, color: valueColor),
                ),
                if (item.unit.isNotEmpty) ...[
                  gapW2,
                  Text(
                    item.unit,
                    style: CatchTextStyles.mono(
                      context,
                      color: unitColor ?? t.ink2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          gapH2,
          Text(
            item.label,
            style: CatchTextStyles.supporting(
              context,
              color: labelColor ?? t.ink3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CatchMetricDivider extends StatelessWidget {
  const _CatchMetricDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: color);
  }
}
