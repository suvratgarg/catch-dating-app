import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Activity-register avatar: initials over the selected activity pigment.
class ActivityAvatar extends StatelessWidget {
  const ActivityAvatar({
    super.key,
    required this.activityKind,
    this.initials,
    this.size = CatchLayout.activityAvatarDefaultSize,
    this.dim = false,
    this.ring = false,
  });

  final ActivityKind activityKind;
  final String? initials;
  final double size;
  final bool dim;
  final bool ring;

  static String initialsOf(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words.first.characters.take(2).toString().toUpperCase();
    }
    return words
        .take(2)
        .map((word) => word.characters.first)
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, activityKind);
    final displayInitials = initials?.trim() ?? '';

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: const GradientRotation(150 * math.pi / 180),
            colors: [activity.accent, activity.deep],
          ),
          border: ring
              ? null
              : Border.all(
                  color: Colors.white.withValues(
                    alpha: CatchOpacity.activityAvatarInnerRule,
                  ),
                ),
          boxShadow: ring
              ? [
                  BoxShadow(
                    color: t.bg,
                    spreadRadius: CatchLayout.activityAvatarRingSpread,
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _ActivityAvatarTexturePainter()),
              if (displayInitials.isNotEmpty)
                Center(
                  child: Text(
                    displayInitials,
                    style: CatchTextStyles.avatarCount(
                      context,
                      size: size * CatchLayout.activityAvatarInitialsScale,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (dim)
                ColoredBox(
                  color: Colors.black.withValues(
                    alpha: CatchOpacity.activityAvatarDim,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityAvatarTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: CatchOpacity.activityAvatarPrint)
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
