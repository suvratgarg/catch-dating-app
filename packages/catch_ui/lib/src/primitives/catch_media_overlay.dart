import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchMediaOverlayVariant { none, bottom, full }

/// Photo scrim gradients for readable text and chrome over media.
///
/// Always pointer-transparent.
class CatchMediaOverlay extends StatelessWidget {
  /// Readability over a thumbnail; media selection stays with the caller.
  const CatchMediaOverlay.thumbnail({
    super.key,
    required CatchMediaOverlayVariant variant,
  }) : base = null,
       _stops = variant == CatchMediaOverlayVariant.none
           ? const [0.0, 1.0]
           : variant == CatchMediaOverlayVariant.bottom
           ? const [0.0, 0.45, 0.78, 1.0]
           : const [0.0, 0.55, 1.0],
       _alphas = variant == CatchMediaOverlayVariant.none
           ? const [0.0, 0.0]
           : variant == CatchMediaOverlayVariant.bottom
           ? const [
               0.0,
               0.0,
               CatchOpacity.mutedContent,
               CatchOpacity.gradientBand,
             ]
           : const [
               CatchOpacity.photoScrimBarelyVisible,
               CatchOpacity.mutedContent,
               CatchOpacity.gradientBand,
             ];

  /// Detail-screen hero: editorial dark, heavier at the top.
  const CatchMediaOverlay.detailHero({super.key})
    : _stops = const [0.0, 0.45, 1.0],
      base = null,
      _alphas = const [
        CatchOpacity.photoScrimLight,
        CatchOpacity.photoScrimMedium,
        CatchOpacity.onDarkMuted,
      ];

  /// Card photo frame: light top band, clear middle, subtle bottom edge.
  const CatchMediaOverlay.photoFrame({super.key})
    : _stops = const [0.0, 0.48, 1.0],
      base = null,
      _alphas = const [
        CatchOpacity.photoScrimLight,
        CatchOpacity.none,
        CatchOpacity.photoFrameEdge,
      ];

  /// Profile hero: caller-tinted, readable top and bottom thirds.
  const CatchMediaOverlay.heroTint({super.key, required this.base})
    : _stops = const [0.0, 0.45, 0.78, 1.0],
      _alphas = const [
        CatchOpacity.profileHeroScrimTop,
        CatchOpacity.none,
        CatchOpacity.profileHeroScrimMid,
        CatchOpacity.profileHeroScrimBottom,
      ];

  final List<double> _stops;
  final List<double> _alphas;
  final Color? base;

  @override
  Widget build(BuildContext context) {
    final resolvedBase = base ?? CatchTokens.editorialBlack;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: _stops,
            colors: [
              for (final alpha in _alphas)
                resolvedBase.withValues(alpha: alpha),
            ],
          ),
        ),
      ),
    );
  }
}
