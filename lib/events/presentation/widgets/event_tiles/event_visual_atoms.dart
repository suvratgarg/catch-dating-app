import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:flutter/material.dart';

class EventActivityStamp extends StatelessWidget {
  const EventActivityStamp({
    super.key,
    required this.visual,
    this.size = 42,
    this.iconSize = 22,
  });

  final EventActivityVisualSpec visual;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: visual.soft.withValues(alpha: 0.72),
        border: Border.all(color: visual.accent.withValues(alpha: 0.54)),
      ),
      alignment: Alignment.center,
      child: Icon(visual.icon, size: iconSize, color: visual.deep),
    );
  }
}

class EventClockMark extends StatelessWidget {
  const EventClockMark({
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
        painter: _EventClockPainter(
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

class EventCapacityProgress extends StatelessWidget {
  const EventCapacityProgress({
    super.key,
    required this.color,
    required this.value,
    this.minHeight = 5,
  });

  final Color color;
  final double value;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      child: LinearProgressIndicator(
        minHeight: minHeight,
        value: value,
        color: color,
        backgroundColor: t.line,
      ),
    );
  }
}

enum EventStatusPillTone { soft, dark }

class EventStatusPill extends StatelessWidget {
  const EventStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.tone = EventStatusPillTone.soft,
  });

  final String label;
  final Color color;
  final EventStatusPillTone tone;

  @override
  Widget build(BuildContext context) {
    final dark = tone == EventStatusPillTone.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark
            ? Colors.black.withValues(alpha: 0.68)
            : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(CatchRadius.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dark ? CatchSpacing.s3 : 8,
          vertical: dark ? CatchSpacing.s1 : 4,
        ),
        child: Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              CatchTextStyles.mono(
                context,
                color: dark ? Colors.white : color,
              ).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
        ),
      ),
    );
  }
}

class _EventClockPainter extends CustomPainter {
  const _EventClockPainter({
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
  bool shouldRepaint(covariant _EventClockPainter oldDelegate) =>
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
