import 'package:flutter/material.dart';

class StaticMapDark extends StatelessWidget {
  const StaticMapDark({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DarkMapPainter());
  }
}

class _DarkMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint();

    p.color = const Color(0xFF1A2E2A);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), p);

    p.color = const Color(0xFF0F1E2B);
    final waterPath = Path()
      ..moveTo(0, h * 0.69)
      ..cubicTo(w * 0.2, h * 0.63, w * 0.4, h * 0.81, w * 0.67, h * 0.75)
      ..lineTo(w, h * 0.81)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(waterPath, p);

    p
      ..color = const Color(0xFF2F2A24)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-10, h * 0.25), Offset(w + 10, h * 0.375), p);

    p
      ..color = const Color(0xFFFF6A3F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final route = Path()
      ..moveTo(w * 0.13, h * 0.81)
      ..quadraticBezierTo(w * 0.47, h * 0.50, w * 0.83, h * 0.31);
    canvas.drawPath(route, p);
  }

  @override
  bool shouldRepaint(_) => false;
}
