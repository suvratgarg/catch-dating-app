import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_ticket_perforation_painter.dart';
import 'package:flutter/material.dart';

class CatchTicketPerforatedDivider extends StatelessWidget {
  const CatchTicketPerforatedDivider({
    super.key,
    this.height = CatchLayout.eventTicketDividerHeight,
    this.lineColor,
    this.notchRadius = CatchLayout.eventTicketNotchRadius,
  });

  final double height;
  final Color? lineColor;
  final double notchRadius;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: CatchTicketPerforationPainter(
          lineColor: lineColor ?? t.line2,
          notchRadius: notchRadius,
        ),
      ),
    );
  }
}
