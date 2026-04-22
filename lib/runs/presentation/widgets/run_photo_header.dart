import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';

class RunPhotoHeader extends StatelessWidget {
  const RunPhotoHeader({super.key, required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _RunMapPainter(primary: t.primary)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 52,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: t.primary,
              borderRadius: BorderRadius.circular(CatchRadius.button),
            ),
            child: Text(
              '${run.signedUpCount}/${run.capacityLimit} spots',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: t.primaryInk,
              ),
            ),
          ),
        ),
        Positioned(
          left: CatchSpacing.screenH,
          right: CatchSpacing.screenH,
          bottom: 16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      run.meetingPoint,
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      run.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(CatchRadius.button),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  run.distanceKm == run.distanceKm.roundToDouble()
                      ? '${run.distanceKm.round()}km'
                      : '${run.distanceKm.toStringAsFixed(1)}km',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RunMapPainter extends CustomPainter {
  const _RunMapPainter({required this.primary});
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    paint.color = const Color(0xFF1A2E2A);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    paint.color = const Color(0xFF0F1E2B);
    final waterPath = Path()
      ..moveTo(0, h * 0.72)
      ..cubicTo(w * 0.25, h * 0.65, w * 0.45, h * 0.82, w * 0.7, h * 0.76)
      ..lineTo(w, h * 0.82)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(waterPath, paint);

    paint
      ..color = const Color(0xFF2A423D)
      ..style = PaintingStyle.fill;
    for (final r in [
      Rect.fromLTWH(w * 0.05, h * 0.1, w * 0.18, h * 0.12),
      Rect.fromLTWH(w * 0.28, h * 0.08, w * 0.22, h * 0.1),
      Rect.fromLTWH(w * 0.6, h * 0.15, w * 0.15, h * 0.14),
      Rect.fromLTWH(w * 0.1, h * 0.35, w * 0.14, h * 0.1),
      Rect.fromLTWH(w * 0.38, h * 0.32, w * 0.19, h * 0.12),
      Rect.fromLTWH(w * 0.65, h * 0.38, w * 0.16, h * 0.09),
      Rect.fromLTWH(w * 0.05, h * 0.52, w * 0.12, h * 0.12),
      Rect.fromLTWH(w * 0.42, h * 0.52, w * 0.2, h * 0.1),
    ]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(r, const Radius.circular(2)), paint);
    }

    paint
      ..color = const Color(0xFF2F2A24)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-10, h * 0.25), Offset(w + 10, h * 0.38), paint);
    canvas.drawLine(Offset(w * 0.38, 0), Offset(w * 0.45, h + 10), paint);
    paint.strokeWidth = 3;
    canvas.drawLine(Offset(-10, h * 0.47), Offset(w + 10, h * 0.52), paint);

    paint
      ..color = primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final route = Path()
      ..moveTo(w * 0.08, h * 0.6)
      ..cubicTo(w * 0.15, h * 0.32, w * 0.32, h * 0.22, w * 0.5, h * 0.28)
      ..cubicTo(w * 0.66, h * 0.34, w * 0.78, h * 0.42, w * 0.82, h * 0.55)
      ..cubicTo(w * 0.78, h * 0.63, w * 0.55, h * 0.66, w * 0.35, h * 0.62)
      ..cubicTo(w * 0.22, h * 0.59, w * 0.12, h * 0.65, w * 0.08, h * 0.6);
    canvas.drawPath(route, paint);

    paint
      ..color = primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.08, h * 0.6), 6, paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(w * 0.08, h * 0.6), 3, paint);
  }

  @override
  bool shouldRepaint(covariant _RunMapPainter old) => old.primary != primary;
}
