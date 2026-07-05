import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Photo scrim gradients for readable text and chrome over media.
///
/// Always pointer-transparent.
class CatchScrim extends StatelessWidget {
  /// Detail-screen hero: editorial dark, heavier at the top.
  const CatchScrim.detailHero({super.key})
    : _stops = const [0.0, 0.45, 1.0],
      base = null,
      _alphas = const [
        CatchOpacity.photoScrimLight,
        CatchOpacity.photoScrimMedium,
        CatchOpacity.onDarkMuted,
      ];

  /// Card photo frame: light top band, clear middle, subtle bottom edge.
  const CatchScrim.photoFrame({super.key})
    : _stops = const [0.0, 0.48, 1.0],
      base = null,
      _alphas = const [
        CatchOpacity.photoScrimLight,
        CatchOpacity.none,
        CatchOpacity.photoFrameEdge,
      ];

  /// Profile hero: caller-tinted, readable top and bottom thirds.
  const CatchScrim.heroTint({super.key, required this.base})
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
    final resolvedBase = base ?? CatchTokens.editorialDark;
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
