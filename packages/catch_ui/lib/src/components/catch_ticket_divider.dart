import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_ticket_perforation_painter.dart';
import 'package:flutter/material.dart';

/// Ticket perforation aligned to the notch geometry of its containing ticket.
///
/// Unlike a continuous section rule, the dashed line stops inside the notches.
class CatchTicketDivider extends StatelessWidget {
  const CatchTicketDivider({
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
