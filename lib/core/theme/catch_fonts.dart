import 'package:catch_dating_app/core/theme/generated/catch_design_tokens.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Central font registry — the single swap point for the three-role type system.
///
/// Voice/head: Archivo — brand voice, heroes, and deliberate event/club poster
/// moments. Function/body: the platform system font. Data: IBM Plex Mono for
/// kickers, labels, time, price, counts, and codes.
///
/// The old serif/custom-sans direction is intentionally retired. Keep
/// production text styles routed through this file so screens inherit the
/// current design language without restating family names.
abstract final class CatchFonts {
  // -- Families (tunable — change here to re-skin the entire app) -------------

  static const String voiceFamily = GeneratedCatchFontFamilyTokens.voice;
  static const String headFamily = GeneratedCatchFontFamilyTokens.head;
  static const String functionDesignTokenFamily =
      GeneratedCatchFontFamilyTokens.function;
  static const String dataFamily = GeneratedCatchFontFamilyTokens.data;
  static const String monoFamily = GeneratedCatchFontFamilyTokens.mono;

  /// Flutter's concrete platform font families for the function/body role.
  ///
  /// The DTCG token remains `system-ui` because it is platform-neutral design
  /// language. Runtime Flutter styles need concrete family names so native
  /// builds, Widgetbook, lints, and the design context pack are auditable.
  static const Set<String> platformFunctionFamilies = <String>{
    'Roboto',
    'CupertinoSystemText',
    'CupertinoSystemDisplay',
    '.AppleSystemUIFont',
    'Segoe UI',
  };

  static String get functionFamily =>
      functionFamilyForPlatform(defaultTargetPlatform);

  /// Backward-compatible names while feature code moves from serif/sans
  /// language to voice/function/data language.
  static const String serifFamily = voiceFamily;
  static String get sansFamily => functionFamily;

  @visibleForTesting
  static String functionFamilyForPlatform(
    TargetPlatform platform, {
    double? fontSize,
  }) {
    return switch (platform) {
      TargetPlatform.iOS =>
        (fontSize != null && fontSize >= 20)
            ? 'CupertinoSystemDisplay'
            : 'CupertinoSystemText',
      TargetPlatform.macOS => '.AppleSystemUIFont',
      TargetPlatform.windows => 'Segoe UI',
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.linux => 'Roboto',
    };
  }

  /// The single ratified Archivo width. The bundled variable font exposes a
  /// `wdth` axis of 62–125, but the Catch type system renders Archivo at
  /// exactly ONE width — the DS "78% system" (`colors_and_type.css`, every
  /// voice/headline/prose style at `font-stretch: 78%`). There is deliberately
  /// no per-style width knob: one width is what keeps the poster voice from
  /// drifting back to the old mixed 90–100% state. Re-skin here, never at a
  /// call site.
  static const double archivoWidth = 78;

  // -- General-purpose builders -----------------------------------------------

  /// Archivo (voice). Weight is driven via [FontVariation]; width is locked to
  /// [archivoWidth]. Archivo ships as roman in this pack, so italic requests
  /// are intentionally ignored to keep the app on the locked spec.
  static TextStyle voice({
    required double fontSize,
    required double height,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
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
        const FontVariation('wdth', archivoWidth),
      ],
    );
  }

  /// Archivo head treatment for event titles, console titles, hints, and
  /// person/host names. Same single [archivoWidth] as [voice]; the head role
  /// differs only in default weight.
  static TextStyle head({
    required double fontSize,
    required double height,
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 0,
  }) => voice(
    fontSize: fontSize,
    height: height,
    color: color,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
  );

  /// Deprecated compatibility alias for older call sites. New typography roles
  /// should call [voice] or [head] when they genuinely need Archivo.
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

  /// Platform system font (function). Resolves to Flutter's concrete platform
  /// family names: SF via CupertinoSystem* on iOS, Roboto on Android/Fuchsia/
  /// Linux, .AppleSystemUIFont on macOS, and Segoe UI on Windows.
  static TextStyle sans({
    required double fontSize,
    required double height,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.normal,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: functionFamilyForPlatform(
        defaultTargetPlatform,
        fontSize: fontSize,
      ),
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
    );
  }
}
