import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/pace_level_theme.dart';
import 'package:flutter/material.dart';

/// Shared image/fallback primitive for any event-card surface.
///
/// Renders [photoUrl] when present, otherwise a committed-looking gradient
/// derived from the event's pace-level palette ([PaceLevelTheme]) with a
/// large, low-contrast activity glyph anchored to one corner so the surface
/// reads as intentional design — not a "broken image" placeholder.
class CatchEventThumbnail extends StatelessWidget {
  const CatchEventThumbnail({
    super.key,
    required this.photoUrl,
    required this.pace,
    required this.activityKind,
    this.scrim = CatchEventThumbnailScrim.bottom,
    this.fit = BoxFit.cover,
    this.iconAlignment = Alignment.bottomRight,
  });

  final String? photoUrl;
  final PaceLevel pace;
  final ActivityKind activityKind;
  final CatchEventThumbnailScrim scrim;
  final BoxFit fit;
  final Alignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    final hasPhoto = url != null && url.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasPhoto)
          Image.network(
            url,
            fit: fit,
            errorBuilder: (_, _, _) => _PaceFallback(
              pace: pace,
              activityKind: activityKind,
              iconAlignment: iconAlignment,
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _PaceFallback(
                pace: pace,
                activityKind: activityKind,
                iconAlignment: iconAlignment,
              );
            },
          )
        else
          _PaceFallback(
            pace: pace,
            activityKind: activityKind,
            iconAlignment: iconAlignment,
          ),
        if (scrim != CatchEventThumbnailScrim.none) _Scrim(style: scrim),
      ],
    );
  }
}

class _PaceFallback extends StatelessWidget {
  const _PaceFallback({
    required this.pace,
    required this.activityKind,
    required this.iconAlignment,
  });

  final PaceLevel pace;
  final ActivityKind activityKind;
  final Alignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final paceColors = pace.colors;
    // Build a committed-looking gradient that reads as design, not a
    // half-loaded image. Stronger lerp toward the pace foreground colour,
    // and a soft radial overlay anchored opposite to the activity glyph
    // so the surface feels lit rather than flat.
    final base = paceColors.bg;
    final accent = Color.lerp(paceColors.bg, paceColors.fg, 0.45)!;
    final deep = Color.lerp(paceColors.bg, paceColors.fg, 0.72)!;
    final radialOrigin = iconAlignment == Alignment.bottomRight
        ? Alignment.topLeft
        : Alignment.topRight;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base, accent, deep],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: radialOrigin,
              radius: 1.2,
              colors: [
                Colors.white.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        Align(
          alignment: iconAlignment,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Icon(
              activityKindGlyph(activityKind),
              size: 144,
              color: paceColors.fg.withValues(alpha: 0.36),
            ),
          ),
        ),
      ],
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim({required this.style});

  final CatchEventThumbnailScrim style;

  @override
  Widget build(BuildContext context) {
    final colors = switch (style) {
      CatchEventThumbnailScrim.none => const [Colors.transparent],
      CatchEventThumbnailScrim.bottom => [
        Colors.transparent,
        Colors.transparent,
        Colors.black.withValues(alpha: 0.36),
        Colors.black.withValues(alpha: 0.62),
      ],
      CatchEventThumbnailScrim.full => [
        Colors.black.withValues(alpha: 0.05),
        Colors.black.withValues(alpha: 0.36),
        Colors.black.withValues(alpha: 0.62),
      ],
    };
    final stops = switch (style) {
      CatchEventThumbnailScrim.none => null,
      CatchEventThumbnailScrim.bottom => const [0.0, 0.45, 0.78, 1.0],
      CatchEventThumbnailScrim.full => const [0.0, 0.55, 1.0],
    };
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
            stops: stops,
          ),
        ),
      ),
    );
  }
}

enum CatchEventThumbnailScrim { none, bottom, full }

/// Glyph picker shared by the thumbnail fallback and the activity-icon
/// surfaces (small chips, meta rows). Pulled out so any new card surface
/// uses the same icon as the fallback for visual consistency.
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
