import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/events/presentation/event_activity_visuals.dart'
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
  });

  final String? photoUrl;
  final PaceLevel pace;
  final ActivityKind activityKind;
  final CatchEventThumbnailScrim scrim;
  final BoxFit fit;
  final Alignment iconAlignment;
  final bool preferActivityArtwork;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    final hasPhoto = !preferActivityArtwork && url != null && url.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasPhoto)
          Image.network(
            url,
            fit: fit,
            errorBuilder: (_, _, _) => _ActivityFallback(
              activityKind: activityKind,
              iconAlignment: iconAlignment,
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _ActivityFallback(
                activityKind: activityKind,
                iconAlignment: iconAlignment,
              );
            },
          )
        else
          _ActivityFallback(
            activityKind: activityKind,
            iconAlignment: iconAlignment,
          ),
        if (scrim != CatchEventThumbnailScrim.none) _Scrim(style: scrim),
      ],
    );
  }
}

class _ActivityFallback extends StatelessWidget {
  const _ActivityFallback({
    required this.activityKind,
    required this.iconAlignment,
  });

  final ActivityKind activityKind;
  final Alignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    return EventActivityBackdrop(
      visual: eventActivityVisual(activityKind),
      dense: true,
      iconAlignment: iconAlignment,
      iconSize: 144,
      iconOpacity: 0.24,
      patternOpacity: 0.22,
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
