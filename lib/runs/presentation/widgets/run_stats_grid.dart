import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';

class RunStatsGrid extends StatelessWidget {
  const RunStatsGrid({super.key, required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: t.raised,
        borderRadius: BorderRadius.circular(CatchRadius.card),
        border: Border.all(color: t.line),
      ),
      child: Row(
        children: [
          RunStatCell(
            value: run.distanceValueLabel,
            unit: 'km',
            label: 'Distance',
          ),
          const RunStatDivider(),
          RunStatCell(value: run.pace.label, unit: '', label: 'Pace level'),
          const RunStatDivider(),
          RunStatCell(value: run.spotsLabel, unit: '', label: 'Spots taken'),
        ],
      ),
    );
  }
}

class RunStatCell extends StatelessWidget {
  const RunStatCell({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
  });

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: CatchTextStyles.monoLg(context)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: CatchTextStyles.monoSm(context, color: t.ink2),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: CatchTextStyles.caption(context, color: t.ink3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class RunStatDivider extends StatelessWidget {
  const RunStatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(width: 1, height: 36, color: t.line);
  }
}
