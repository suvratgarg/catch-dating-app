import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchTicketPerforationPainter extends CustomPainter {
  const CatchTicketPerforationPainter({
    required this.lineColor,
    this.notchRadius = CatchLayout.eventTicketNotchRadius,
  });

  final Color lineColor;
  final double notchRadius;

  static const _dashWidth = 5.0;
  static const _dashGap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    var x = notchRadius + CatchSpacing.s2;
    final lineEnd = size.width - notchRadius - CatchSpacing.s2;
    while (x < lineEnd) {
      canvas.drawLine(Offset(x, y), Offset(x + _dashWidth, y), linePaint);
      x += _dashWidth + _dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CatchTicketPerforationPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.notchRadius != notchRadius;
  }
}
