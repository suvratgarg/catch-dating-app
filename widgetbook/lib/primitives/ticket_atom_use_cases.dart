import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Visual atom clock',
  type: CatchTicketClock,
  path: '[Events]/Tiles',
)
Widget eventClockMarkState(BuildContext context) {
  return CatchTicketClock(
    accent: CatchTokens.of(context).primary,
    time: const TimeOfDay(hour: 6, minute: 30),
    size: 42,
    centerDotRadius: 2,
  );
}

@widgetbook.UseCase(
  name: 'Visual atom status',
  type: CatchBadge,
  path: '[Events]/Tiles',
)
Widget eventStatusPillState(BuildContext context) {
  final t = CatchTokens.of(context);
  return Wrap(
    spacing: CatchSpacing.s2,
    children: [
      CatchBadge.ticketStatus(label: 'Open', color: t.primary),
      CatchBadge.ticketStatus(
        label: 'Booked',
        color: t.success,
        emphasis: CatchBadgeEmphasis.strong,
      ),
    ],
  );
}
