import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
  return ActivityPalette.glyphs[activityKind] ??
      ActivityPalette.glyphs[ActivityKind.openActivity]!;
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

/// Resolves the presentation spec for [kind]. Colors come from the centralized,
/// dark-aware [ActivityPalette] (design_language §3); label + pattern are
/// mode-independent metadata. Pass [context] for the correct light/dark swatch;
/// without it (const/preview/sandbox call sites) the light palette is used.
EventActivityVisualSpec eventActivityVisual(
  ActivityKind kind, {
  BuildContext? context,
}) {
  final swatch = context != null
      ? ActivityPalette.of(context).forKind(kind)
      : ActivityPalette.light.forKind(kind);
  final meta = _activityMeta(kind);
  return EventActivityVisualSpec(
    activityKind: kind,
    label: meta.label,
    colors: <Color>[swatch.accent, swatch.deep, swatch.soft],
    pattern: meta.pattern,
  );
}

typedef _ActivityMeta = ({String label, EventActivityPattern pattern});

_ActivityMeta _activityMeta(ActivityKind kind) => switch (kind) {
  ActivityKind.socialRun => (
    label: 'Social run',
    pattern: EventActivityPattern.routeDots,
  ),
  ActivityKind.running => (
    label: 'Running',
    pattern: EventActivityPattern.routeDashes,
  ),
  ActivityKind.walking => (
    label: 'Walking',
    pattern: EventActivityPattern.stepDots,
  ),
  ActivityKind.pickleball => (
    label: 'Pickleball',
    pattern: EventActivityPattern.courtLines,
  ),
  ActivityKind.padel => (
    label: 'Padel',
    pattern: EventActivityPattern.glassGrid,
  ),
  ActivityKind.tennis => (
    label: 'Tennis',
    pattern: EventActivityPattern.courtArcs,
  ),
  ActivityKind.badminton => (
    label: 'Badminton',
    pattern: EventActivityPattern.shuttleStrokes,
  ),
  ActivityKind.cycling => (
    label: 'Cycling',
    pattern: EventActivityPattern.wheelArcs,
  ),
  ActivityKind.spinClass => (
    label: 'Spin class',
    pattern: EventActivityPattern.rhythmRings,
  ),
  ActivityKind.yoga => (
    label: 'Yoga',
    pattern: EventActivityPattern.mandalaArcs,
  ),
  ActivityKind.strengthTraining => (
    label: 'Strength',
    pattern: EventActivityPattern.barMarks,
  ),
  ActivityKind.dinner => (
    label: 'Dinner',
    pattern: EventActivityPattern.plateCircles,
  ),
  ActivityKind.pubQuiz => (
    label: 'Pub quiz',
    pattern: EventActivityPattern.quizCards,
  ),
  ActivityKind.barCrawl => (
    label: 'Bar crawl',
    pattern: EventActivityPattern.neonDots,
  ),
  ActivityKind.singlesMixer => (
    label: 'Singles mixer',
    pattern: EventActivityPattern.overlapCircles,
  ),
  ActivityKind.openActivity => (
    label: 'Open format',
    pattern: EventActivityPattern.stampGrid,
  ),
};

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
              // Confident mid-tone duotone (pigment → deep), not a pastel sweep.
              colors: dense
                  ? [visual.accent, visual.deep, visual.accent]
                  : [visual.accent, visual.deep],
              stops: dense ? const [0, 0.6, 1] : null,
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
            padding: CatchInsets.tileContent,
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
              const Radius.circular(CatchSpacing.micro3),
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
              Rect.fromCenter(
                center: Offset(x, y),
                width: CatchSpacing.micro3,
                height: CatchSpacing.micro3,
              ),
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
