import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:flutter/material.dart';

class EventStatsGrid extends StatelessWidget {
  const EventStatsGrid({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.md,
      borderColor: t.line,
      child: Row(
        children: [
          EventStatCell(
            value: event.distanceValueLabel,
            unit: 'km',
            label: 'Distance',
          ),
          const EventStatDivider(),
          EventStatCell(value: event.pace.label, unit: '', label: 'Pace level'),
          const EventStatDivider(),
          EventStatCell(
            value: event.spotsLabel,
            unit: '',
            label: 'Spots taken',
          ),
        ],
      ),
    );
  }
}

class EventStatCell extends StatelessWidget {
  const EventStatCell({
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: CatchTextStyles.mono(context)),
                if (unit.isNotEmpty) ...[
                  gapW2,
                  Text(
                    unit,
                    style: CatchTextStyles.mono(context, color: t.ink2),
                  ),
                ],
              ],
            ),
          ),
          gapH2,
          Text(
            label,
            style: CatchTextStyles.bodyS(context, color: t.ink3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class EventStatDivider extends StatelessWidget {
  const EventStatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(width: 1, height: 36, color: t.line);
  }
}
