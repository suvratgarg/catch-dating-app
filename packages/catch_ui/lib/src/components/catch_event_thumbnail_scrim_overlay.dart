import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Presentation-only thumbnail scrim, preserving its event-card member identity.
///
/// The caller chooses the recipe; this renderer does not read event data.
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
