import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central font treatments that are intentionally more specific than the
/// Inter-based app text scale.
abstract final class CatchFonts {
  static const String clubDisplayFamily = 'Instrument Serif';
  static const String eventDisplayFamily = 'Instrument Serif';

  static TextStyle clubDisplay({
    required double fontSize,
    required double height,
    required Color color,
    FontWeight fontWeight = FontWeight.w600,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return GoogleFonts.getFont(
      clubDisplayFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: 0,
      decoration: TextDecoration.none,
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
    return GoogleFonts.getFont(
      eventDisplayFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: 0,
      decoration: TextDecoration.none,
      color: color,
    );
  }
}
