import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:flutter/material.dart';

class DashedAvatar extends StatelessWidget {
  const DashedAvatar({
    super.key,
    required this.size,
    required this.imageUrl,
    required this.name,
    required this.tokens,
  });

  final double size;
  final String? imageUrl;
  final String name;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return PersonAvatar(size: size, name: name, imageUrl: imageUrl);
    }
    return CustomPaint(
      size: Size.square(size),
      painter: _DashedCirclePainter(color: tokens.line2),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final r = size.width / 2 - 1;
    final cx = size.width / 2;
    final cy = size.height / 2;

    const dashLen = 4.0;
    const gapLen = 4.0;
    const total = dashLen + gapLen;
    final circumference = 2 * math.pi * r;
    final dashCount = (circumference / total).floor();
    for (var i = 0; i < dashCount; i++) {
      final start = i * total / circumference * 2 * math.pi;
      final end = start + dashLen / circumference * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start - math.pi / 2,
        end - start,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
