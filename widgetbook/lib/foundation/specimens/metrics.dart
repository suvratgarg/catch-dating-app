import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

import '../../preview_layout_contracts.dart';

class WidgetbookFoundationMetricStack extends StatelessWidget {
  const WidgetbookFoundationMetricStack({
    super.key,
    required this.rows,
    this.maxBarWidth = 240,
  });

  final List<WidgetbookFoundationMetricSpec> rows;
  final double maxBarWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
            child: _MetricRow(row: row, maxBarWidth: maxBarWidth),
          ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.row, required this.maxBarWidth});

  final WidgetbookFoundationMetricSpec row;
  final double maxBarWidth;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final barWidth = row.value.clamp(1, maxBarWidth).toDouble();
    return Row(
      children: [
        SizedBox(
          width: WidgetbookPreviewLayout.foundationMetricLabelWidth,
          child: Text(row.name, style: CatchTextStyles.monoLabel(context)),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: barWidth,
              height: WidgetbookPreviewLayout.foundationMetricBarHeight,
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
            ),
          ),
        ),
        SizedBox(
          width: WidgetbookPreviewLayout.foundationMetricValueWidth,
          child: Text(
            widgetbookFoundationNumber(row.value),
            textAlign: TextAlign.end,
            style: CatchTextStyles.numericMeta(context),
          ),
        ),
      ],
    );
  }
}

class WidgetbookFoundationMetricSpec {
  const WidgetbookFoundationMetricSpec(this.name, this.value);

  final String name;
  final double value;
}

String widgetbookFoundationNumber(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}
