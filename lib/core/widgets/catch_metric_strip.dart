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
  }) : assert(items.isNotEmpty);

  final List<CatchMetricStripItem> items;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: padding,
      radius: CatchRadius.md,
      borderColor: t.line,
      child: Row(
        children: [
          for (final item in items) ...[
            _CatchMetricCell(item: item),
            if (item != items.last) _CatchMetricDivider(color: t.line),
          ],
        ],
      ),
    );
  }
}

class _CatchMetricCell extends StatelessWidget {
  const _CatchMetricCell({required this.item});

  final CatchMetricStripItem item;

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
                Text(item.value, style: CatchTextStyles.mono(context)),
                if (item.unit.isNotEmpty) ...[
                  gapW2,
                  Text(
                    item.unit,
                    style: CatchTextStyles.mono(context, color: t.ink2),
                  ),
                ],
              ],
            ),
          ),
          gapH2,
          Text(
            item.label,
            style: CatchTextStyles.supporting(context, color: t.ink3),
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
