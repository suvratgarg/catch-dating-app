import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:flutter/material.dart';

/// Presentation-only visual taxonomy for event activity surfaces.
///
/// This is intentionally separate from the persisted event schema. Production
/// events stay keyed by [ActivityKind], while the colors, patterns, labels, and
/// glyph choices here can evolve as the Explore direction matures.
enum EventActivityPattern {
  routeDots,
  routeDashes,
  stepDots,
  courtLines,
  glassGrid,
  courtArcs,
  shuttleStrokes,
  wheelArcs,
  rhythmRings,
  mandalaArcs,
  barMarks,
  plateCircles,
  quizCards,
  neonDots,
  overlapCircles,
  stampGrid,
}

class EventActivityVisualSpec {
  const EventActivityVisualSpec({
    required this.activityKind,
    required this.label,
    required this.colors,
    required this.pattern,
  });

  final ActivityKind activityKind;
  final String label;
  final List<Color> colors;
  final EventActivityPattern pattern;

  Color get accent => colors.first;
  Color get deep => colors.length > 1 ? colors[1] : colors.first;
  Color get soft => colors.last;
  IconData get icon => activityKindGlyph(activityKind);
}

IconData activityKindGlyph(ActivityKind activityKind) {
  return switch (activityKind) {
    ActivityKind.socialRun || ActivityKind.running => CatchIcons.running,
    ActivityKind.walking => CatchIcons.walking,
    ActivityKind.cycling || ActivityKind.spinClass => CatchIcons.cycling,
    ActivityKind.pickleball ||
    ActivityKind.padel ||
    ActivityKind.tennis ||
    ActivityKind.badminton => CatchIcons.racquet,
    ActivityKind.yoga => CatchIcons.yoga,
    ActivityKind.strengthTraining => CatchIcons.strength,
    ActivityKind.pubQuiz => CatchIcons.pubQuiz,
    ActivityKind.barCrawl => CatchIcons.barCrawl,
    ActivityKind.dinner => CatchIcons.dinner,
    ActivityKind.singlesMixer => CatchIcons.singlesMixer,
    ActivityKind.openActivity => CatchIcons.openActivity,
  };
}

const primaryBrowseActivityKinds = <ActivityKind>[
  ActivityKind.socialRun,
  ActivityKind.walking,
  ActivityKind.pickleball,
  ActivityKind.padel,
  ActivityKind.tennis,
  ActivityKind.badminton,
  ActivityKind.cycling,
  ActivityKind.spinClass,
  ActivityKind.yoga,
  ActivityKind.dinner,
  ActivityKind.pubQuiz,
  ActivityKind.barCrawl,
  ActivityKind.singlesMixer,
  ActivityKind.openActivity,
];

const allActivityKindsForVisuals = <ActivityKind>[
  ActivityKind.socialRun,
  ActivityKind.running,
  ActivityKind.walking,
  ActivityKind.pickleball,
  ActivityKind.padel,
  ActivityKind.tennis,
  ActivityKind.badminton,
  ActivityKind.cycling,
  ActivityKind.spinClass,
  ActivityKind.yoga,
  ActivityKind.strengthTraining,
  ActivityKind.dinner,
  ActivityKind.pubQuiz,
  ActivityKind.barCrawl,
  ActivityKind.singlesMixer,
  ActivityKind.openActivity,
];

EventActivityVisualSpec eventActivityVisual(ActivityKind kind) {
  return switch (kind) {
    ActivityKind.socialRun => const EventActivityVisualSpec(
      activityKind: ActivityKind.socialRun,
      label: 'Social run',
      colors: [Color(0xFFFF5B2E), Color(0xFFFF9A58), Color(0xFFFFE0B8)],
      pattern: EventActivityPattern.routeDots,
    ),
    ActivityKind.running => const EventActivityVisualSpec(
      activityKind: ActivityKind.running,
      label: 'Running',
      colors: [Color(0xFFE9472E), Color(0xFFFF7448), Color(0xFFFFC7A6)],
      pattern: EventActivityPattern.routeDashes,
    ),
    ActivityKind.walking => const EventActivityVisualSpec(
      activityKind: ActivityKind.walking,
      label: 'Walking',
      colors: [Color(0xFF4F8A5B), Color(0xFFA8C96F), Color(0xFFECF2C2)],
      pattern: EventActivityPattern.stepDots,
    ),
    ActivityKind.pickleball => const EventActivityVisualSpec(
      activityKind: ActivityKind.pickleball,
      label: 'Pickleball',
      colors: [Color(0xFF9BCB3D), Color(0xFF36C6A6), Color(0xFFE8F8B5)],
      pattern: EventActivityPattern.courtLines,
    ),
    ActivityKind.padel => const EventActivityVisualSpec(
      activityKind: ActivityKind.padel,
      label: 'Padel',
      colors: [Color(0xFF00A7A7), Color(0xFF55D6B7), Color(0xFFD9FFF3)],
      pattern: EventActivityPattern.glassGrid,
    ),
    ActivityKind.tennis => const EventActivityVisualSpec(
      activityKind: ActivityKind.tennis,
      label: 'Tennis',
      colors: [Color(0xFF2E9E44), Color(0xFFD6DA45), Color(0xFFF7F0A8)],
      pattern: EventActivityPattern.courtArcs,
    ),
    ActivityKind.badminton => const EventActivityVisualSpec(
      activityKind: ActivityKind.badminton,
      label: 'Badminton',
      colors: [Color(0xFF4F70C8), Color(0xFF8FC7FF), Color(0xFFF0F7FF)],
      pattern: EventActivityPattern.shuttleStrokes,
    ),
    ActivityKind.cycling => const EventActivityVisualSpec(
      activityKind: ActivityKind.cycling,
      label: 'Cycling',
      colors: [Color(0xFF2563EB), Color(0xFF36BDF8), Color(0xFFCCF2FF)],
      pattern: EventActivityPattern.wheelArcs,
    ),
    ActivityKind.spinClass => const EventActivityVisualSpec(
      activityKind: ActivityKind.spinClass,
      label: 'Spin class',
      colors: [Color(0xFF304ED8), Color(0xFF21C7D9), Color(0xFFD6F8FA)],
      pattern: EventActivityPattern.rhythmRings,
    ),
    ActivityKind.yoga => const EventActivityVisualSpec(
      activityKind: ActivityKind.yoga,
      label: 'Yoga',
      colors: [Color(0xFF8E75C9), Color(0xFFF0A6CA), Color(0xFFF9E8F1)],
      pattern: EventActivityPattern.mandalaArcs,
    ),
    ActivityKind.strengthTraining => const EventActivityVisualSpec(
      activityKind: ActivityKind.strengthTraining,
      label: 'Strength',
      colors: [Color(0xFF31373A), Color(0xFFB84A3A), Color(0xFFF2C98D)],
      pattern: EventActivityPattern.barMarks,
    ),
    ActivityKind.dinner => const EventActivityVisualSpec(
      activityKind: ActivityKind.dinner,
      label: 'Dinner',
      colors: [Color(0xFFD98A24), Color(0xFFE85D75), Color(0xFFFFE0B8)],
      pattern: EventActivityPattern.plateCircles,
    ),
    ActivityKind.pubQuiz => const EventActivityVisualSpec(
      activityKind: ActivityKind.pubQuiz,
      label: 'Pub quiz',
      colors: [Color(0xFF25316D), Color(0xFF4E5FC8), Color(0xFFFFC857)],
      pattern: EventActivityPattern.quizCards,
    ),
    ActivityKind.barCrawl => const EventActivityVisualSpec(
      activityKind: ActivityKind.barCrawl,
      label: 'Bar crawl',
      colors: [Color(0xFFC02672), Color(0xFF6D3FC8), Color(0xFFF7A8C8)],
      pattern: EventActivityPattern.neonDots,
    ),
    ActivityKind.singlesMixer => const EventActivityVisualSpec(
      activityKind: ActivityKind.singlesMixer,
      label: 'Singles mixer',
      colors: [Color(0xFFFF5F6D), Color(0xFF35C2B6), Color(0xFFFFE7A3)],
      pattern: EventActivityPattern.overlapCircles,
    ),
    ActivityKind.openActivity => const EventActivityVisualSpec(
      activityKind: ActivityKind.openActivity,
      label: 'Open format',
      colors: [Color(0xFF56616B), Color(0xFFB8A06A), Color(0xFFF3EFE5)],
      pattern: EventActivityPattern.stampGrid,
    ),
  };
}

class EventActivityBackdrop extends StatelessWidget {
  const EventActivityBackdrop({
    super.key,
    required this.visual,
    this.dense = false,
    this.iconAlignment = Alignment.bottomRight,
    this.iconSize = 132,
    this.iconOpacity = 0.2,
    this.patternOpacity = 0.22,
  });

  final EventActivityVisualSpec visual;
  final bool dense;
  final Alignment iconAlignment;
  final double iconSize;
  final double iconOpacity;
  final double patternOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dense
                  ? [visual.accent, visual.deep, visual.soft, visual.accent]
                  : visual.colors,
              stops: dense ? const [0, 0.42, 0.74, 1] : null,
            ),
          ),
        ),
        CustomPaint(
          painter: _ActivityPatternPainter(
            pattern: visual.pattern,
            color: Colors.white.withValues(alpha: patternOpacity),
          ),
        ),
        Align(
          alignment: iconAlignment,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Icon(
              visual.icon,
              size: iconSize,
              color: Colors.white.withValues(alpha: iconOpacity),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityPatternPainter extends CustomPainter {
  const _ActivityPatternPainter({required this.pattern, required this.color});

  final EventActivityPattern pattern;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (pattern) {
      case EventActivityPattern.routeDots:
        for (var x = 16.0; x < size.width; x += 28) {
          final y = size.height * 0.52 + math.sin(x / 26) * 16;
          canvas.drawCircle(Offset(x, y), 1.8, fill);
        }
      case EventActivityPattern.routeDashes:
        for (var x = 8.0; x < size.width; x += 28) {
          final y = size.height * 0.5 + math.sin(x / 30) * 18;
          canvas.drawLine(Offset(x, y), Offset(x + 12, y + 4), paint);
        }
      case EventActivityPattern.stepDots:
        for (var x = 18.0; x < size.width; x += 32) {
          canvas
            ..drawCircle(Offset(x, size.height * 0.42), 2, fill)
            ..drawCircle(Offset(x + 12, size.height * 0.58), 2, fill);
        }
      case EventActivityPattern.courtLines:
        canvas
          ..drawRect(
            Rect.fromLTWH(18, 18, size.width - 36, size.height - 36),
            paint,
          )
          ..drawLine(
            Offset(size.width / 2, 18),
            Offset(size.width / 2, size.height - 18),
            paint,
          )
          ..drawLine(
            Offset(18, size.height / 2),
            Offset(size.width - 18, size.height / 2),
            paint,
          );
      case EventActivityPattern.glassGrid:
        for (var x = 18.0; x < size.width; x += 34) {
          canvas.drawLine(
            Offset(x, 10),
            Offset(x - 22, size.height - 10),
            paint,
          );
        }
        for (var y = 18.0; y < size.height; y += 28) {
          canvas.drawLine(
            Offset(10, y),
            Offset(size.width - 10, y + 10),
            paint,
          );
        }
      case EventActivityPattern.courtArcs:
        for (var radius = 36.0; radius < size.width; radius += 42) {
          canvas.drawArc(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height),
              radius: radius,
            ),
            math.pi,
            math.pi,
            false,
            paint,
          );
        }
      case EventActivityPattern.shuttleStrokes:
        for (var x = 22.0; x < size.width; x += 42) {
          canvas
            ..drawLine(Offset(x, 20), Offset(x + 18, size.height - 20), paint)
            ..drawLine(
              Offset(x + 10, 26),
              Offset(x + 26, size.height - 26),
              paint,
            );
        }
      case EventActivityPattern.wheelArcs:
        for (var x = 24.0; x < size.width; x += 66) {
          canvas.drawCircle(Offset(x, size.height * 0.68), 22, paint);
        }
      case EventActivityPattern.rhythmRings:
        for (var radius = 16.0; radius < size.shortestSide; radius += 22) {
          canvas.drawCircle(
            Offset(size.width * 0.22, size.height * 0.42),
            radius,
            paint,
          );
        }
      case EventActivityPattern.mandalaArcs:
        for (var i = 0; i < 5; i += 1) {
          canvas.drawArc(
            Rect.fromCircle(
              center: Offset(size.width * 0.28, size.height * 0.5),
              radius: 22.0 + i * 16,
            ),
            -math.pi / 3,
            math.pi * 1.3,
            false,
            paint,
          );
        }
      case EventActivityPattern.barMarks:
        for (var x = 20.0; x < size.width; x += 34) {
          canvas.drawLine(
            Offset(x, size.height * 0.35),
            Offset(x, size.height * 0.68),
            paint,
          );
          canvas.drawLine(
            Offset(x - 8, size.height * 0.5),
            Offset(x + 8, size.height * 0.5),
            paint,
          );
        }
      case EventActivityPattern.plateCircles:
        for (var x = 28.0; x < size.width; x += 64) {
          canvas
            ..drawCircle(Offset(x, size.height * 0.48), 18, paint)
            ..drawCircle(Offset(x, size.height * 0.48), 7, paint);
        }
      case EventActivityPattern.quizCards:
        for (var x = 16.0; x < size.width; x += 44) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, size.height * 0.34, 24, 18),
              const Radius.circular(3),
            ),
            paint,
          );
        }
      case EventActivityPattern.neonDots:
        for (var x = 16.0; x < size.width; x += 26) {
          for (var y = 18.0; y < size.height; y += 28) {
            if ((x + y).round().isEven) {
              canvas.drawCircle(Offset(x, y), 2, fill);
            }
          }
        }
      case EventActivityPattern.overlapCircles:
        for (var x = 28.0; x < size.width; x += 46) {
          canvas
            ..drawCircle(Offset(x, size.height * 0.46), 18, paint)
            ..drawCircle(Offset(x + 16, size.height * 0.46), 18, paint);
        }
      case EventActivityPattern.stampGrid:
        for (var x = 16.0; x < size.width; x += 28) {
          for (var y = 16.0; y < size.height; y += 28) {
            canvas.drawRect(
              Rect.fromCenter(center: Offset(x, y), width: 3, height: 3),
              fill,
            );
          }
        }
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityPatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern || oldDelegate.color != color;
  }
}
