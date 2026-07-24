import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Display-time, non-destructive photo grade (design_language §4).
///
/// User photos are inconsistent; we never edit them on upload. Instead every
/// displayed photo passes through one shared **warm matte-duotone** grade so a
/// mixed feed of UGC and generated activity art reads as a single editorial
/// family. The grade is fully tunable here — dial the whole app in one place.
///
/// The look has three composable parts:
/// 1. **Desaturate + tone curve** — pull saturation down, then a mid-gray
///    contrast pivot and a global brightness multiply. Matches the design
///    system `.catch-grade` (`saturate(.78) contrast(1.04) brightness(.97)`):
///    contrast is added (>1), not rolled off. All linear, so it folds into a
///    single [ColorFilter.matrix].
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
    required this.brightness,
    required this.warmShadow,
    required this.warmHighlight,
    this.grainOpacity = 0,
  });

  /// <1 desaturates. The "warm-desaturate" of the reference grade.
  final double saturation;

  /// Mid-gray contrast pivot. >1 adds contrast — the DS `.catch-grade` uses
  /// 1.04 (a gentle contrast lift, not a roll-off).
  final double contrast;

  /// Global brightness multiply applied after contrast. <1 gently darkens —
  /// the DS `.catch-grade` uses 0.97.
  final double brightness;

  /// Low-alpha warm tint multiplied in — warms (and deepens) the shadows.
  final Color warmShadow;

  /// Low-alpha warm tint screened in — warms (and lifts) the highlights.
  final Color warmHighlight;

  /// 0 = no grain. Small values (~0.04) add filmic texture.
  final double grainOpacity;

  /// Light register — browse/forms photography.
  static const CatchGrade light = CatchGrade(
    saturation: 0.78,
    contrast: 1.04,
    brightness: 0.97,
    warmShadow: CatchPhotoGradeColors.lightWarmShadow,
    warmHighlight: CatchPhotoGradeColors.lightWarmHighlight,
  );

  /// Dark "wow" surfaces (event spotlight, profile hero) — deeper, moodier.
  /// Same DS tone model as [light], pushed slightly: a touch less saturation,
  /// a hair more contrast, and a deeper brightness multiply.
  static const CatchGrade dark = CatchGrade(
    saturation: 0.76,
    contrast: 1.05,
    brightness: 0.94,
    warmShadow: CatchPhotoGradeColors.darkWarmShadow,
    warmHighlight: CatchPhotoGradeColors.darkWarmHighlight,
  );

  /// The grade for the current brightness. Dark surfaces run [dark].
  static CatchGrade of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// 4x5 color matrix: saturation, then a mid-gray contrast pivot, then a
  /// global brightness multiply — composed in CSS `.catch-grade` order
  /// (`saturate → contrast → brightness`). Luma weights 0.2126/0.7152/0.0722;
  /// the offset column is on the 0–255 scale.
  List<double> toMatrix() {
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    final s = saturation, c = contrast, b = brightness;
    // contrast pivots around mid-gray (127.5); brightness scales the result.
    final scale = b * c;
    final o = b * 127.5 * (1 - c);
    double e(double luma, {required bool onDiagonal}) =>
        (onDiagonal ? luma * (1 - s) + s : luma * (1 - s)) * scale;
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
class CatchGradedImage extends StatelessWidget {
  const CatchGradedImage({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final grade = CatchGrade.of(context);
    final warmShadow = _multiplyTintColor(grade.warmShadow);
    final warmHighlight = _screenTintColor(grade.warmHighlight);

    // Desaturate + matte, then warm the shadows (multiply) and highlights
    // (screen). ColorFilter.mode does not behave like a low-alpha CSS overlay,
    // so tint strength is baked into the blend color by lerping from each
    // blend mode's no-op color.
    Widget graded = ColorFiltered(
      colorFilter: ColorFilter.mode(warmHighlight, BlendMode.screen),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(warmShadow, BlendMode.multiply),
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

  static Color _multiplyTintColor(Color color) {
    final strength = color.a.clamp(0.0, 1.0).toDouble();
    // color-sweep:allow: theme-independent art blend endpoint is absolute white.
    return Color.lerp(Colors.white, color.withValues(alpha: 1), strength)!;
  }

  static Color _screenTintColor(Color color) {
    final strength = color.a.clamp(0.0, 1.0).toDouble();
    // color-sweep:allow: theme-independent art blend endpoint is absolute black.
    return Color.lerp(Colors.black, color.withValues(alpha: 1), strength)!;
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
      // Fixed editorial grain tones keep generated texture theme-independent.
      final tone = light
          ? CatchTokens.editorialWhite
          : CatchTokens.editorialBlack;
      paint.color = tone.withValues(
        alpha: opacity * (0.35 + rng.nextDouble() * 0.65),
      );
      canvas.drawRect(Rect.fromLTWH(dx, dy, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
