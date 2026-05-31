import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class StaticMapDark extends StatelessWidget {
  const StaticMapDark({super.key});

  @override
  Widget build(BuildContext context) {
    final swatch = ActivityPalette.of(
      context,
    ).forKind(ActivityKind.openActivity);
    return CustomPaint(painter: _DarkMapPainter(routeColor: swatch.accent));
  }
}

class _DarkMapPainter extends CustomPainter {
  const _DarkMapPainter({required this.routeColor});

  final Color routeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint();

    p.color = CatchStaticMapColors.land;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), p);

    p.color = CatchStaticMapColors.water;
    final waterPath = Path()
      ..moveTo(0, h * 0.69)
      ..cubicTo(w * 0.2, h * 0.63, w * 0.4, h * 0.81, w * 0.67, h * 0.75)
      ..lineTo(w, h * 0.81)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(waterPath, p);

    p
      ..color = CatchStaticMapColors.arterial
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-10, h * 0.25), Offset(w + 10, h * 0.375), p);

    p
      ..color = routeColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final route = Path()
      ..moveTo(w * 0.13, h * 0.81)
      ..quadraticBezierTo(w * 0.47, h * 0.50, w * 0.83, h * 0.31);
    canvas.drawPath(route, p);
  }

  @override
  bool shouldRepaint(_DarkMapPainter old) => old.routeColor != routeColor;
}
