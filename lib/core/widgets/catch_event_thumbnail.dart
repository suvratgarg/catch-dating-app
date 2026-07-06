import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/widgets/event_activity_visuals.dart'
    show activityKindGlyph;

/// Shared image/fallback primitive for any event-card surface.
///
/// Renders [photoUrl] when present, otherwise the shared activity visual
/// backdrop for [activityKind] so no-photo states match Explore cards and the
/// event detail header.
class CatchEventThumbnail extends StatelessWidget {
  const CatchEventThumbnail({
    super.key,
    required this.photoUrl,
    required this.pace,
    required this.activityKind,
    this.scrim = CatchEventThumbnailScrim.bottom,
    this.fit = BoxFit.cover,
    this.iconAlignment = Alignment.bottomRight,
    this.preferActivityArtwork = false,
    this.fallbackIconSize,
    this.fallbackIconOpacity = CatchOpacity.fallbackArtworkIcon,
    this.fallbackPatternOpacity = CatchOpacity.ticketPerforationLine,
  });

  final String? photoUrl;
  final PaceLevel pace;
  final ActivityKind activityKind;
  final CatchEventThumbnailScrim scrim;
  final BoxFit fit;
  final Alignment iconAlignment;
  final bool preferActivityArtwork;
  final double? fallbackIconSize;
  final double fallbackIconOpacity;
  final double fallbackPatternOpacity;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    final hasPhoto = !preferActivityArtwork && url != null && url.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasPhoto)
          CatchGradedImage(
            child: CatchNetworkImage(
              url,
              fit: fit,
              errorBuilder: (context, _, _) =>
                  CatchEventThumbnailActivityFallback(
                    activityKind: activityKind,
                    iconAlignment: iconAlignment,
                    iconSize: fallbackIconSize,
                    iconOpacity: fallbackIconOpacity,
                    patternOpacity: fallbackPatternOpacity,
                  ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return CatchEventThumbnailActivityFallback(
                  activityKind: activityKind,
                  iconAlignment: iconAlignment,
                  iconSize: fallbackIconSize,
                  iconOpacity: fallbackIconOpacity,
                  patternOpacity: fallbackPatternOpacity,
                );
              },
            ),
          )
        else
          CatchEventThumbnailActivityFallback(
            activityKind: activityKind,
            iconAlignment: iconAlignment,
            iconSize: fallbackIconSize,
            iconOpacity: fallbackIconOpacity,
            patternOpacity: fallbackPatternOpacity,
          ),
        if (scrim != CatchEventThumbnailScrim.none)
          CatchEventThumbnailScrimOverlay(style: scrim),
      ],
    );
  }
}

class CatchEventThumbnailActivityFallback extends StatelessWidget {
  const CatchEventThumbnailActivityFallback({
    super.key,
    required this.activityKind,
    this.iconAlignment = Alignment.bottomRight,
    this.iconSize,
    this.iconOpacity = CatchOpacity.fallbackArtworkIcon,
    this.patternOpacity = CatchOpacity.ticketPerforationLine,
  });

  final ActivityKind activityKind;
  final Alignment iconAlignment;
  final double? iconSize;
  final double iconOpacity;
  final double patternOpacity;

  @override
  Widget build(BuildContext context) {
    return EventActivityBackdrop(
      visual: eventActivityVisual(activityKind, context: context),
      dense: true,
      iconAlignment: iconAlignment,
      iconSize: iconSize ?? CatchLayout.eventThumbnailBackdropIconSize,
      iconOpacity: iconOpacity,
      patternOpacity: patternOpacity,
    );
  }
}

class CatchEventThumbnailScrimOverlay extends StatelessWidget {
  const CatchEventThumbnailScrimOverlay({super.key, required this.style});

  final CatchEventThumbnailScrim style;

  @override
  Widget build(BuildContext context) {
    final colors = switch (style) {
      CatchEventThumbnailScrim.none => const [Colors.transparent],
      CatchEventThumbnailScrim.bottom => [
        Colors.transparent,
        Colors.transparent,
        CatchTokens.editorialBlack.withValues(alpha: CatchOpacity.mutedContent),
        CatchTokens.editorialBlack.withValues(alpha: CatchOpacity.gradientBand),
      ],
      CatchEventThumbnailScrim.full => [
        CatchTokens.editorialBlack.withValues(
          alpha: CatchOpacity.photoScrimBarelyVisible,
        ),
        CatchTokens.editorialBlack.withValues(alpha: CatchOpacity.mutedContent),
        CatchTokens.editorialBlack.withValues(alpha: CatchOpacity.gradientBand),
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
