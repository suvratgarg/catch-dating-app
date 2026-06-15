import 'package:catch_dating_app/core/theme/generated/catch_design_tokens.g.dart';
import 'package:flutter/material.dart';

/// Central font registry — the single swap point for the three-role type system.
///
/// Voice/head: Archivo — titles, names, heroes, event/club poster moments, and
/// editorial reading text. Function/body: the platform system font. Data: IBM
/// Plex Mono for kickers, labels, time, price, counts, and codes.
///
/// The old serif/custom-sans direction is intentionally retired. Keep
/// production text styles routed through this file so screens inherit the
/// current design language without restating family names.
abstract final class CatchFonts {
  // -- Families (tunable — change here to re-skin the entire app) -------------

  static const String voiceFamily = GeneratedCatchFontFamilyTokens.voice;
  static const String headFamily = GeneratedCatchFontFamilyTokens.head;
  static const String functionFamily = GeneratedCatchFontFamilyTokens.function;
  static const String dataFamily = GeneratedCatchFontFamilyTokens.data;
  static const String monoFamily = GeneratedCatchFontFamilyTokens.mono;

  /// Backward-compatible names while feature code moves from serif/sans
  /// language to voice/function/data language.
  static const String serifFamily = voiceFamily;
  static const String sansFamily = functionFamily;

  static const double _archivoWidthMin = 62;
  static const double _archivoWidthMax = 125;

  static double _archivoWidth(double width) =>
      width.clamp(_archivoWidthMin, _archivoWidthMax).toDouble();

  // -- General-purpose builders -----------------------------------------------

  /// Archivo (voice). Weight and width are driven via [FontVariation] against
  /// the bundled variable font. Archivo ships as roman in this pack, so italic
  /// requests are intentionally ignored to keep the app on the locked spec.
  static TextStyle voice({
    required double fontSize,
    required double height,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
    double width = 100,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: voiceFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: FontStyle.normal,
      height: height,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
      color: color,
      fontVariations: <FontVariation>[
        FontVariation('wght', fontWeight.value.toDouble()),
        FontVariation('wdth', _archivoWidth(width)),
      ],
    );
  }

  /// Archivo condensed head treatment for event titles, console titles, hints,
  /// and person/host names.
  static TextStyle head({
    required double fontSize,
    required double height,
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
    double width = 92,
    double letterSpacing = 0,
  }) => voice(
    fontSize: fontSize,
    height: height,
    color: color,
    fontWeight: fontWeight,
    width: width,
    letterSpacing: letterSpacing,
  );

  /// Compatibility alias for older call sites.
  static TextStyle serif({
    required double fontSize,
    required double height,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
    FontStyle fontStyle = FontStyle.normal,
    double letterSpacing = 0,
  }) => voice(
    fontSize: fontSize,
    height: height,
    color: color,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
  );

  /// Platform system font (function). No [fontFamily] is set on purpose: this
  /// lets iOS render SF and Android render Roboto with native Dynamic Type.
  static TextStyle sans({
    required double fontSize,
    required double height,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.normal,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
      color: color,
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
  // These use the voice family under the hood; kept as convenience wrappers
  // for club/event identity treatments.

  static TextStyle clubDisplay({
    required double fontSize,
    required double height,
    required Color color,
    FontWeight fontWeight = FontWeight.w600,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return voice(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    );
  }

  static TextStyle eventDisplay({
    required double fontSize,
    required double height,
    required Color color,
    FontWeight fontWeight = FontWeight.w600,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return voice(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      width: 92,
    );
  }
}
