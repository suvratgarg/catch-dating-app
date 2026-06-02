import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Display-time, non-destructive photo grade (design_language §4).
///
/// User photos are inconsistent; we never edit them on upload. Instead every
/// displayed photo passes through one shared **warm matte-duotone** grade so a
/// mixed feed of UGC and generated activity art reads as a single editorial
/// family. The grade is fully tunable here — dial the whole app in one place.
///
/// The look has three composable parts:
/// 1. **Desaturate + matte tone curve** — pull saturation down, lower contrast,
///    and lift the black point so shadows are never pure black (faded-film matte).
///    All linear, so it folds into a single [ColorFilter.matrix].
/// 2. **Warm split-tone** — a warm *multiply* (lands in the shadows) plus a warm
///    *screen* (lands in the highlights); together a cohesive warm wash that
///    matches the activity pigments.
/// 3. **Optional fine grain** — off by default ([grainOpacity] `0`) until
///    perf-checked; deterministic so goldens stay stable.
@immutable
class CatchGrade {
  const CatchGrade({
    required this.saturation,
    required this.contrast,
    required this.blackLift,
    required this.warmShadow,
    required this.warmHighlight,
    this.grainOpacity = 0,
  });

  /// <1 desaturates. The "warm-desaturate" of the reference grade.
  final double saturation;

  /// <1 rolls off contrast for the matte look.
  final double contrast;

  /// 0..1 normalized floor lift — how far shadows are raised off pure black.
  /// Keep `contrast + blackLift <= 1` so highlights don't clip.
  final double blackLift;

  /// Low-alpha warm tint multiplied in — warms (and deepens) the shadows.
  final Color warmShadow;

  /// Low-alpha warm tint screened in — warms (and lifts) the highlights.
  final Color warmHighlight;

  /// 0 = no grain. Small values (~0.04) add filmic texture.
  final double grainOpacity;

  /// Light register — browse/forms photography.
  static const CatchGrade light = CatchGrade(
    saturation: 0.84,
    contrast: 0.94,
    blackLift: 0.03,
    // token:allow: fixed photo-grade warm shadow tint (theme-independent art)
    warmShadow: Color(0x14C9542F),
    // token:allow: fixed photo-grade warm highlight tint (theme-independent art)
    warmHighlight: Color(0x0FF3C778),
  );

  /// Dark "wow" surfaces (event spotlight, profile hero) — deeper, moodier.
  static const CatchGrade dark = CatchGrade(
    saturation: 0.80,
    contrast: 0.90,
    blackLift: 0.05,
    // token:allow: fixed photo-grade dark warm shadow tint (theme-independent art)
    warmShadow: Color(0x1FC9542F),
    // token:allow: fixed photo-grade dark warm highlight tint (theme-independent art)
    warmHighlight: Color(0x14F3C778),
  );

  /// The grade for the current brightness. Dark surfaces run [dark].
  static CatchGrade of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// 4x5 color matrix: saturation, then a contrast/black-lift tone curve.
  /// (Luma weights 0.2126/0.7152/0.0722; offset column is on the 0–255 scale.)
  List<double> toMatrix() {
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    final s = saturation, c = contrast;
    final o = blackLift * 255.0;
    // saturation row entry, then scaled by contrast.
    double e(double luma, {required bool onDiagonal}) =>
        (onDiagonal ? luma * (1 - s) + s : luma * (1 - s)) * c;
    return <double>[
      e(lr, onDiagonal: true),
      e(lg, onDiagonal: false),
      e(lb, onDiagonal: false),
      0,
      o,
      e(lr, onDiagonal: false),
      e(lg, onDiagonal: true),
      e(lb, onDiagonal: false),
      0,
      o,
      e(lr, onDiagonal: false),
      e(lg, onDiagonal: false),
      e(lb, onDiagonal: true),
      0,
      o,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}

/// Wraps a photo [child] in the shared [CatchGrade] for the current brightness.
/// Non-destructive: the source image is untouched. Set [enabled] `false` to
/// show the raw photo (e.g. the user viewing their own upload).
class GradedImage extends StatelessWidget {
  const GradedImage({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final grade = CatchGrade.of(context);

    // Desaturate + matte, then warm the shadows (multiply) and highlights
    // (screen). ColorFilter.mode is luminance-agnostic, but multiply lands in
    // the darks and screen in the lights — a reliable pseudo split-tone with no
    // backdrop-blend pitfalls.
    Widget graded = ColorFiltered(
      colorFilter: ColorFilter.mode(grade.warmHighlight, BlendMode.screen),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(grade.warmShadow, BlendMode.multiply),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(grade.toMatrix()),
          child: child,
        ),
      ),
    );

    if (grade.grainOpacity > 0) {
      graded = Stack(
        children: <Widget>[
          graded,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _GrainPainter(grade.grainOpacity)),
            ),
          ),
        ],
      );
    }
    return graded;
  }
}

/// Deterministic fine grain (fixed seed → stable goldens). Sparse light/dark
/// specks at low alpha read as film texture without a bundled noise asset.
class _GrainPainter extends CustomPainter {
  const _GrainPainter(this.opacity);

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rng = math.Random(0x6A7C); // fixed seed — deterministic
    final count = (size.width * size.height / 26).clamp(0, 12000).toInt();
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final light = rng.nextBool();
      // token:allow: deterministic film-grain speck color (theme-independent art)
      paint.color = (light ? Colors.white : Colors.black).withValues(
        alpha: opacity * (0.35 + rng.nextDouble() * 0.65),
      );
      canvas.drawRect(Rect.fromLTWH(dx, dy, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
