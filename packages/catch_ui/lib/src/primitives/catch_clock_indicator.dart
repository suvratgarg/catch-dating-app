import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchClockIndicator extends StatelessWidget {
  const CatchClockIndicator({
    super.key,
    required this.accent,
    required this.time,
    this.size = 18,
    this.ringColor,
    this.ringStrokeWidth = 1.4,
    this.hourStrokeWidth = 2.0,
    this.minuteStrokeWidth = 1.5,
    this.hourLengthFactor = 0.44,
    this.minuteLengthFactor = 0.62,
    this.centerDotRadius = 0,
  });

  final Color accent;
  final TimeOfDay time;
  final double size;
  final Color? ringColor;
  final double ringStrokeWidth;
  final double hourStrokeWidth;
  final double minuteStrokeWidth;
  final double hourLengthFactor;
  final double minuteLengthFactor;
  final double centerDotRadius;

  @override
  Widget build(BuildContext context) {
    final minuteTurns = time.minute / 60;
    final hourTurns = ((time.hour % 12) + minuteTurns) / 12;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _CatchClockIndicatorPainter(
          ring: ringColor ?? CatchTokens.of(context).line2,
          hand: accent,
          hourTurns: hourTurns,
          minuteTurns: minuteTurns,
          ringStrokeWidth: ringStrokeWidth,
          hourStrokeWidth: hourStrokeWidth,
          minuteStrokeWidth: minuteStrokeWidth,
          hourLengthFactor: hourLengthFactor,
          minuteLengthFactor: minuteLengthFactor,
          centerDotRadius: centerDotRadius,
        ),
      ),
    );
  }
}

class _CatchClockIndicatorPainter extends CustomPainter {
  const _CatchClockIndicatorPainter({
    required this.ring,
    required this.hand,
    required this.hourTurns,
    required this.minuteTurns,
    required this.ringStrokeWidth,
    required this.hourStrokeWidth,
    required this.minuteStrokeWidth,
    required this.hourLengthFactor,
    required this.minuteLengthFactor,
    required this.centerDotRadius,
  });

  final Color ring;
  final Color hand;
  final double hourTurns;
  final double minuteTurns;
  final double ringStrokeWidth;
  final double hourStrokeWidth;
  final double minuteStrokeWidth;
  final double hourLengthFactor;
  final double minuteLengthFactor;
  final double centerDotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStrokeWidth
      ..color = ring;
    canvas.drawCircle(center, radius - ringStrokeWidth, ringPaint);
    _drawHand(
      canvas,
      center,
      radius * hourLengthFactor,
      hourTurns,
      hourStrokeWidth,
    );
    _drawHand(
      canvas,
      center,
      radius * minuteLengthFactor,
      minuteTurns,
      minuteStrokeWidth,
    );
    if (centerDotRadius > 0) {
      canvas.drawCircle(center, centerDotRadius, Paint()..color = hand);
    }
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double length,
    double turns,
    double strokeWidth,
  ) {
    final angle = turns * math.pi * 2 - math.pi / 2;
    final end =
        center + Offset(length * math.cos(angle), length * math.sin(angle));
    final paint = Paint()
      ..color = hand
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant _CatchClockIndicatorPainter oldDelegate) =>
      oldDelegate.ring != ring ||
      oldDelegate.hand != hand ||
      oldDelegate.hourTurns != hourTurns ||
      oldDelegate.minuteTurns != minuteTurns ||
      oldDelegate.ringStrokeWidth != ringStrokeWidth ||
      oldDelegate.hourStrokeWidth != hourStrokeWidth ||
      oldDelegate.minuteStrokeWidth != minuteStrokeWidth ||
      oldDelegate.hourLengthFactor != hourLengthFactor ||
      oldDelegate.minuteLengthFactor != minuteLengthFactor ||
      oldDelegate.centerDotRadius != centerDotRadius;
}
