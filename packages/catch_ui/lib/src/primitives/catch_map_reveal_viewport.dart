import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Focused map reveal that opens from the centered Explore map launcher.
///
/// The native map stays stationary. A Flutter paper veil opens above it, so we
/// get a spatial transition without clipping or transforming the platform view.
class CatchMapRevealViewport extends StatelessWidget {
  const CatchMapRevealViewport({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations == true;
    final curved = CurvedAnimation(
      parent: animation,
      curve: CatchMotion.standardCurve,
      reverseCurve: CatchMotion.easeInCubicCurve,
    );
    if (reduceMotion) {
      return KeyedSubtree(
        key: const ValueKey('catch_map_reveal.reduced'),
        child: child,
      );
    }
    final veilColor = CatchTokens.of(context).bg;
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, mapChild) {
        return Stack(
          fit: StackFit.expand,
          children: [
            mapChild!,
            if (curved.value < 1)
              IgnorePointer(
                child: CustomPaint(
                  key: const ValueKey('catch_map_reveal.veil'),
                  painter: _CatchMapRevealVeilPainter(
                    color: veilColor,
                    revealProgress: curved.value,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CatchMapRevealVeilPainter extends CustomPainter {
  const _CatchMapRevealVeilPainter({
    required this.color,
    required this.revealProgress,
  });

  final Color color;
  final double revealProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || revealProgress >= 1) return;
    final origin = Offset(size.width / 2, size.height * 0.88);
    final farthestCornerDistance =
        <Offset>[
              Offset.zero,
              Offset(size.width, 0),
              Offset(0, size.height),
              Offset(size.width, size.height),
            ]
            .map((corner) => (corner - origin).distance)
            .reduce((left, right) => left > right ? left : right);
    final revealRadius = farthestCornerDistance * revealProgress * 1.04;
    final veilPath = Path()..addRect(Offset.zero & size);
    final openingPath = Path()
      ..addOval(Rect.fromCircle(center: origin, radius: revealRadius));
    canvas.drawPath(
      Path.combine(PathOperation.difference, veilPath, openingPath),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _CatchMapRevealVeilPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.revealProgress != revealProgress;
  }
}
