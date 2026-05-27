import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class ExploreConceptMapPreview extends StatelessWidget {
  const ExploreConceptMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return AspectRatio(
      aspectRatio: 1.55,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(color: t.raised),
          child: CustomPaint(
            painter: _MapPaperPainter(
              line: t.ink.withValues(alpha: 0.14),
              dotted: t.line2,
              park: t.accent.withValues(alpha: 0.13),
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: 130,
                  top: 110,
                  child: ExploreConceptUserPin(),
                ),
                const Positioned(
                  right: 88,
                  top: 56,
                  child: ExploreConceptMapPin(label: '4'),
                ),
                const Positioned(
                  right: 128,
                  top: 124,
                  child: ExploreConceptMapPin(label: '2'),
                ),
                const Positioned(
                  right: 172,
                  bottom: 58,
                  child: ExploreConceptMapPin(label: '3'),
                ),
                Positioned(
                  left: 28,
                  bottom: 72,
                  child: _SelectedPinCallout(color: t.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExploreConceptMapPin extends StatelessWidget {
  const ExploreConceptMapPin({
    super.key,
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final fill = selected ? t.ink : t.primary;
    return SizedBox(
      width: 58,
      height: 68,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 46,
            child: Transform.rotate(
              angle: 0.78,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: CatchElevation.card,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: CatchTextStyles.displayS(
                context,
                color: Colors.white,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreConceptUserPin extends StatelessWidget {
  const ExploreConceptUserPin({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: t.primary.withValues(alpha: 0.14),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.primary,
              border: Border.all(color: Colors.white, width: 4),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(CatchRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CatchSpacing.s2,
                vertical: CatchSpacing.micro3,
              ),
              child: Text(
                'you',
                style: CatchTextStyles.supporting(context, color: t.ink),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedPinCallout extends StatelessWidget {
  const _SelectedPinCallout({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(CatchRadius.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s3,
              CatchSpacing.s2,
              CatchSpacing.s4,
              CatchSpacing.s2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CatchIcons.dinner, color: t.primaryInk, size: 18),
                gapW8,
                Text(
                  'Slow Tables',
                  style: CatchTextStyles.titleS(context, color: t.primaryInk),
                ),
                gapW8,
                Text('9M', style: CatchTextStyles.mono(context, color: t.gold)),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-10, 30),
          child: const ExploreConceptMapPin(label: '5', selected: true),
        ),
      ],
    );
  }
}

class _MapPaperPainter extends CustomPainter {
  const _MapPaperPainter({
    required this.line,
    required this.dotted,
    required this.park,
  });

  final Color line;
  final Color dotted;
  final Color park;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = dotted.withValues(alpha: 0.42);
    for (var x = 12.0; x < size.width; x += 26) {
      for (var y = 12.0; y < size.height; y += 26) {
        canvas.drawCircle(Offset(x, y), 1.4, dotPaint);
      }
    }

    final road = Paint()
      ..color = line
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final major = Paint()
      ..color = line.withValues(alpha: 0.75)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas
      ..drawLine(
        Offset(0, size.height * 0.28),
        Offset(size.width, size.height * 0.12),
        road,
      )
      ..drawLine(
        Offset(0, size.height * 0.58),
        Offset(size.width, size.height * 0.66),
        major,
      )
      ..drawLine(
        Offset(size.width * 0.48, 0),
        Offset(size.width * 0.52, size.height),
        major,
      )
      ..drawLine(
        Offset(size.width * 0.82, 0),
        Offset(size.width * 0.55, size.height),
        road,
      );

    final ringPaint = Paint()
      ..color = line.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width * 0.5, size.height * 0.52);
    for (final radius in [90.0, 150.0, 220.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * 2.2, height: radius),
        ringPaint,
      );
    }

    final parkPaint = Paint()
      ..color = park
      ..style = PaintingStyle.fill;
    final parkPath = Path()
      ..moveTo(size.width * 0.74, size.height * 0.18)
      ..cubicTo(
        size.width * 0.92,
        size.height * 0.1,
        size.width * 1.04,
        size.height * 0.18,
        size.width * 1.02,
        size.height * 0.54,
      )
      ..lineTo(size.width * 0.78, size.height * 0.52)
      ..cubicTo(
        size.width * 0.7,
        size.height * 0.4,
        size.width * 0.72,
        size.height * 0.26,
        size.width * 0.74,
        size.height * 0.18,
      );
    canvas.drawPath(parkPath, parkPaint);
  }

  @override
  bool shouldRepaint(covariant _MapPaperPainter oldDelegate) =>
      oldDelegate.line != line ||
      oldDelegate.dotted != dotted ||
      oldDelegate.park != park;
}
