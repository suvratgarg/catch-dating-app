import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar_colors.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

class CatchActivityInitialsPlaceholder extends StatelessWidget {
  const CatchActivityInitialsPlaceholder({
    super.key,
    required this.colors,
    required this.initials,
    required this.size,
    this.dim = false,
  });

  final CatchAvatarColors colors;
  final String initials;
  final double size;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final initialsSize = size * CatchLayout.activityAvatarInitialsScale;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: const GradientRotation(150 * math.pi / 180),
              colors: [colors.accent, colors.deep],
            ),
            border: Border.all(
              color: CatchTokens.editorialWhite.withValues(
                alpha: CatchOpacity.activityAvatarInnerRule,
              ),
            ),
          ),
        ),
        CustomPaint(painter: _ActivityAvatarTexturePainter()),
        if (initials.isNotEmpty)
          Center(
            child: Text(
              initials,
              style: CatchTextStyles.avatarInitials(
                context,
                size: initialsSize,
                color: CatchTokens.editorialWhite,
              ),
            ),
          ),
        if (dim)
          ColoredBox(
            color: CatchTokens.editorialBlack.withValues(
              alpha: CatchOpacity.activityAvatarDim,
            ),
          ),
      ],
    );
  }
}

class _ActivityAvatarTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CatchTokens.editorialWhite.withValues(
        alpha: CatchOpacity.activityAvatarPrint,
      )
      ..strokeWidth = CatchLayout.activityAvatarTextureStrokeWidth;
    final stride = CatchLayout.activityAvatarTextureStride;
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
  bool shouldRepaint(covariant _ActivityAvatarTexturePainter oldDelegate) =>
      false;
}
