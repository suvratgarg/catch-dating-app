import 'package:flutter/material.dart';

/// Central font registry — the single swap point for the three-role type system.
///
/// Voice (serif):   Newsreader — display titles + long-form body
/// Function (sans): Inter         — buttons, nav, inputs, dense UI
/// Data (mono):     IBM Plex Mono — time, price, counts, kickers, labels
///
/// Fonts are **bundled** (see `pubspec.yaml`) rather than fetched at runtime, so
/// (a) the variable optical-size (`opsz`) axis is drivable — the `google_fonts`
/// runtime can't drive variable axes — and (b) the load-bearing identity fonts
/// ship with the app (offline / release-safe).
///
/// Optical sizing is applied **automatically** from the rendered point size:
/// small text gets the sturdy low-contrast "text" cut, large display gets the
/// fine high-contrast "display" cut. Routing every style through here means that
/// refinement is free and consistent app-wide — the single biggest type lever.
abstract final class CatchFonts {
  // -- Families (tunable — change here to re-skin the entire app) -------------

  static const String serifFamily = 'Newsreader';
  static const String sansFamily = 'Inter';
  static const String monoFamily = 'IBM Plex Mono';

  // -- Variable optical-size axis ranges (per the bundled TTFs) ---------------
  // Newsreader carries a wide opsz axis (the whole point of the choice);
  // out-of-range values are clamped by the font engine regardless.
  static const double _serifOpszMin = 6;
  static const double _serifOpszMax = 72;
  static const double _sansOpszMin = 14;
  static const double _sansOpszMax = 32;

  /// Optical size for a rendered point size, clamped to the serif axis.
  static double _serifOpsz(double fontSize) =>
      fontSize.clamp(_serifOpszMin, _serifOpszMax).toDouble();

  /// Optical size for Inter, clamped to the bundled font's tighter axis.
  static double _sansOpsz(double fontSize) =>
      fontSize.clamp(_sansOpszMin, _sansOpszMax).toDouble();

  // -- General-purpose builders -----------------------------------------------

  /// Newsreader (voice). Weight + optical size are driven via [FontVariation]
  /// against the bundled variable font; [fontWeight] is kept in sync so any
  /// weight-aware layout logic agrees with the rendered axis value.
  static TextStyle serif({
    required double fontSize,
    required double height,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
    FontStyle fontStyle = FontStyle.normal,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: serifFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
      color: color,
      fontVariations: <FontVariation>[
        FontVariation('opsz', _serifOpsz(fontSize)),
        FontVariation('wght', fontWeight.value.toDouble()),
      ],
    );
  }

  /// Inter (function). Weight and optical size are driven through the bundled
  /// variable font axes so small functional labels keep the sturdy text cut
  /// while larger UI titles can use Inter's display cut.
  static TextStyle sans({
    required double fontSize,
    required double height,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.normal,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: sansFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
      color: color,
      fontVariations: <FontVariation>[
        FontVariation('opsz', _sansOpsz(fontSize)),
        FontVariation('wght', fontWeight.value.toDouble()),
      ],
    );
  }

  /// IBM Plex Mono (data). Static family — weight selects among the bundled
  /// instances (400/500/600/700; w800 maps to the heaviest, Bold). Tabular
  /// figures on by default so numerics align in columns.
  static TextStyle mono({
    required double fontSize,
    required double height,
    Color? color,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = 0,
    List<FontFeature> fontFeatures = const [FontFeature.tabularFigures()],
  }) {
    return TextStyle(
      fontFamily: monoFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: fontFeatures,
      decoration: TextDecoration.none,
      color: color,
    );
  }

  // -- Named role builders (backward-compatible with existing call sites) -----
  // These use the serif family under the hood; kept as convenience wrappers
  // for club/event identity treatments.

  static TextStyle clubDisplay({
    required double fontSize,
    required double height,
    required Color color,
    FontWeight fontWeight = FontWeight.w600,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return serif(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      color: color,
    );
  }

  static TextStyle eventDisplay({
    required double fontSize,
    required double height,
    required Color color,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.italic,
  }) {
    return serif(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      color: color,
    );
  }
}
