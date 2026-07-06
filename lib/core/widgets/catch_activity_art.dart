import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Generated activity art: pigment gradient, motif glyph, and print texture.
class CatchActivityArt extends StatelessWidget {
  const CatchActivityArt({
    super.key,
    required this.activityKind,
    this.height = CatchLayout.activityArtDefaultHeight,
    this.radius = CatchLayout.activityArtDefaultRadius,
    this.dim = false,
    this.child,
  });

  final ActivityKind activityKind;
  final double height;
  final double radius;
  final bool dim;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, activityKind);

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: const GradientRotation(150 * math.pi / 180),
              colors: [activity.accent, activity.deep],
            ),
            border: Border.all(
              color: CatchTokens.editorialWhite.withValues(
                alpha: CatchOpacity.activityArtInnerRule,
              ),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _ActivityArtTexturePainter()),
              Positioned(
                right: CatchLayout.activityArtGlyphRight,
                bottom: CatchLayout.activityArtGlyphBottom,
                child: Icon(
                  activity.glyph,
                  size: height * CatchLayout.activityArtGlyphScale,
                  color: CatchTokens.editorialWhite.withValues(
                    alpha: CatchOpacity.activityArtGlyph,
                  ),
                ),
              ),
              if (dim)
                ColoredBox(
                  color: CatchTokens.editorialBlack.withValues(
                    alpha: CatchOpacity.activityArtDim,
                  ),
                ),
              Positioned.fill(child: child ?? const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityArtTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CatchTokens.editorialWhite.withValues(
        alpha: CatchOpacity.activityArtPrint,
      )
      ..strokeWidth = CatchLayout.activityArtTextureStrokeWidth;
    final stride = CatchLayout.activityArtTextureStride;
    for (
      double offset = -size.height;
      offset < size.width + size.height;
      offset += stride
    ) {
      canvas.drawLine(
        Offset(offset, size.height),
        Offset(offset + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityArtTexturePainter oldDelegate) => false;
}
