import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:flutter/material.dart';

/// Form-workspace statistics composed from the canonical unboxed stat primitive.
class HostFormMetrics extends StatelessWidget {
  const HostFormMetrics({super.key, required this.items});

  final List<({String value, String label})> items;

  @override
  Widget build(BuildContext context) {
    final stacked = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final cells = [
      for (final item in items)
        CatchStatColumn(value: item.value, label: item.label),
    ];
    return stacked
        ? Column(
            key: const ValueKey('host_form_metrics.reflow'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in cells.indexed) ...[
                if (entry.$1 > 0) gapH16,
                entry.$2,
              ],
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry in cells.indexed) ...[
                if (entry.$1 > 0) gapW16,
                Expanded(child: entry.$2),
              ],
            ],
          );
  }
}
