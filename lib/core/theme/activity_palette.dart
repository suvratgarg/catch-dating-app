import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:flutter/material.dart';

/// The expressive "activity color" layer — the *only* chroma in Catch's
/// otherwise black-and-white system (see `docs/design_language.md` §3). One
/// confident mid-tone **pigment** per [ActivityKind]; light/dark swatches are
/// derived so the system is dark-aware and editable in exactly one place.
///
/// To re-tune the palette, edit [pigments] only. Everything else (deep shade,
/// soft tint, dark-mode pop) is derived.
@immutable
class ActivitySwatch {
  const ActivitySwatch({
    required this.accent,
    required this.deep,
    required this.soft,
  });

  /// Mid-tone pigment — CTAs, kickers, stamps, gradient start.
  final Color accent;

  /// Darker shade — icons on light surfaces, gradient end.
  final Color deep;

  /// Mode-aware tint — soft fills/backgrounds.
  final Color soft;

  static ActivitySwatch _derive(Color pigment, Brightness brightness) {
    final hsl = HSLColor.fromColor(pigment);
    final deep = hsl
        .withLightness((hsl.lightness - 0.13).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.04).clamp(0.0, 1.0))
        .toColor();
    if (brightness == Brightness.light) {
      final soft = hsl
          .withLightness(0.93)
          .withSaturation((hsl.saturation * 0.55).clamp(0.0, 1.0))
          .toColor();
      return ActivitySwatch(accent: pigment, deep: deep, soft: soft);
    }
    // Dark: lift the accent a touch so it pops; soft becomes a deep muted tint.
    final accent = hsl
        .withLightness((hsl.lightness + 0.07).clamp(0.0, 1.0))
        .toColor();
    final soft = hsl
        .withLightness(0.22)
        .withSaturation((hsl.saturation * 0.5).clamp(0.0, 1.0))
        .toColor();
    return ActivitySwatch(accent: accent, deep: deep, soft: soft);
  }

  static ActivitySwatch lerp(ActivitySwatch a, ActivitySwatch b, double t) =>
      ActivitySwatch(
        accent: Color.lerp(a.accent, b.accent, t)!,
        deep: Color.lerp(a.deep, b.deep, t)!,
        soft: Color.lerp(a.soft, b.soft, t)!,
      );
}

@immutable
class ActivityPalette extends ThemeExtension<ActivityPalette> {
  const ActivityPalette(this.swatches);

  final Map<ActivityKind, ActivitySwatch> swatches;

  /// THE single editable source of activity pigments (design_language §3).
  /// Confident mid-tones — bold, not candy, never beige.
  static const Map<ActivityKind, Color> pigments = <ActivityKind, Color>{
    ActivityKind.socialRun: Color(0xFFD85A3C),
    ActivityKind.running: Color(0xFFC9482E),
    ActivityKind.walking: Color(0xFF6E9A5A),
    ActivityKind.pickleball: Color(0xFF2F9E7A),
    ActivityKind.padel: Color(0xFF2E9AA0),
    ActivityKind.tennis: Color(0xFF4E9A4E),
    ActivityKind.badminton: Color(0xFF4F70C8),
    ActivityKind.cycling: Color(0xFF3A6FD0),
    ActivityKind.spinClass: Color(0xFF3E55C0),
    ActivityKind.yoga: Color(0xFF8A5FB0),
    ActivityKind.strengthTraining: Color(0xFFB0573C),
    ActivityKind.dinner: Color(0xFFC44D6A),
    ActivityKind.pubQuiz: Color(0xFF4356A8),
    ActivityKind.barCrawl: Color(0xFFB14488),
    ActivityKind.singlesMixer: Color(0xFFD85A6E),
    ActivityKind.openActivity: Color(0xFF7A7166),
  };

  factory ActivityPalette.forBrightness(Brightness brightness) =>
      ActivityPalette(<ActivityKind, ActivitySwatch>{
        for (final entry in pigments.entries)
          entry.key: ActivitySwatch._derive(entry.value, brightness),
      });

  static final ActivityPalette light =
      ActivityPalette.forBrightness(Brightness.light);
  static final ActivityPalette dark =
      ActivityPalette.forBrightness(Brightness.dark);

  ActivitySwatch forKind(ActivityKind kind) =>
      swatches[kind] ?? swatches[ActivityKind.openActivity] ?? _fallback;

  static const _fallback = ActivitySwatch(
    accent: Color(0xFF7A7166),
    deep: Color(0xFF5A534B),
    soft: Color(0xFFE9E6E0),
  );

  /// Tolerant of a missing extension (e.g. bare test harnesses) — falls back to
  /// the light palette rather than throwing.
  static ActivityPalette of(BuildContext context) =>
      Theme.of(context).extension<ActivityPalette>() ?? light;

  @override
  ActivityPalette copyWith({Map<ActivityKind, ActivitySwatch>? swatches}) =>
      ActivityPalette(swatches ?? this.swatches);

  @override
  ActivityPalette lerp(ActivityPalette? other, double t) {
    if (other is! ActivityPalette) return this;
    return ActivityPalette(<ActivityKind, ActivitySwatch>{
      for (final kind in swatches.keys)
        kind: ActivitySwatch.lerp(
          swatches[kind]!,
          other.swatches[kind] ?? swatches[kind]!,
          t,
        ),
    });
  }
}
