import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchRevealViewportVariant { content, stationaryMedia, flight }

/// Presents content from an external transition clock with owned curve lifetime.
///
/// Stationary media reveals through a paper veil so native views are never
/// transformed. Flight content uses the shared spring without an opacity fade.
class CatchRevealViewport extends StatefulWidget {
  const CatchRevealViewport({
    super.key,
    required this.animation,
    required this.child,
    this.variant = CatchRevealViewportVariant.content,
  });

  const CatchRevealViewport.stationary({
    super.key,
    required this.animation,
    required this.child,
  }) : variant = CatchRevealViewportVariant.stationaryMedia;

  const CatchRevealViewport.flight({
    super.key,
    required this.animation,
    required this.child,
  }) : variant = CatchRevealViewportVariant.flight;

  final Animation<double> animation;
  final Widget child;
  final CatchRevealViewportVariant variant;

  @override
  State<CatchRevealViewport> createState() => _CatchRevealViewportState();
}

class _CatchRevealViewportState extends State<CatchRevealViewport> {
  late CurvedAnimation _curved;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _configureAnimation();
  }

  @override
  void didUpdateWidget(CatchRevealViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.animation, widget.animation) ||
        oldWidget.variant != widget.variant) {
      _curved.dispose();
      _configureAnimation();
    }
  }

  void _configureAnimation() {
    final flight = widget.variant == CatchRevealViewportVariant.flight;
    _curved = CurvedAnimation(
      parent: widget.animation,
      curve: flight ? CatchMotion.springCurve : CatchMotion.standardCurve,
      reverseCurve: flight
          ? CatchMotion.standardCurve
          : CatchMotion.easeInCubicCurve,
    );
    _scale = Tween<double>(
      begin: flight ? 0.98 : 0.985,
      end: 1,
    ).animate(_curved);
  }

  @override
  void dispose() {
    _curved.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations == true) {
      return KeyedSubtree(
        key: ValueKey(
          widget.variant == CatchRevealViewportVariant.stationaryMedia
              ? 'catch_map_reveal.reduced'
              : 'catch_reveal.reduced',
        ),
        child: widget.child,
      );
    }
    if (widget.variant == CatchRevealViewportVariant.flight) {
      return ScaleTransition(scale: _scale, child: widget.child);
    }
    if (widget.variant == CatchRevealViewportVariant.content) {
      return FadeTransition(
        opacity: _curved,
        child: ScaleTransition(scale: _scale, child: widget.child),
      );
    }
    final veilColor = CatchTokens.of(context).bg;
    return AnimatedBuilder(
      animation: _curved,
      child: widget.child,
      builder: (context, mediaChild) {
        return Stack(
          fit: StackFit.expand,
          children: [
            mediaChild!,
            if (_curved.value < 1)
              IgnorePointer(
                child: CustomPaint(
                  key: const ValueKey('catch_map_reveal.veil'),
                  painter: _CatchRevealVeilPainter(
                    color: veilColor,
                    revealProgress: _curved.value,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CatchRevealVeilPainter extends CustomPainter {
  const _CatchRevealVeilPainter({
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
  bool shouldRepaint(covariant _CatchRevealVeilPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.revealProgress != revealProgress;
  }
}
