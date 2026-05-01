import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens for Catch's canonical Sporty type system:
/// Space Grotesk for display, Inter for text, and JetBrains Mono for numerics.
///
/// These names mirror the design-system catalog. Prefer the named styles over
/// ad hoc `TextStyle` values, and use `copyWith` only for local state changes
/// such as unread or disabled text.
abstract final class CatchTextStyles {
  // ── Display — hero moments, screen titles ─────────────────────────────────

  static TextStyle displayXL(BuildContext context, {Color? color}) => _display(
    context,
    size: 40,
    weight: FontWeight.w700,
    height: 1.05,
    trackingEm: -0.025,
    color: color,
  );

  static TextStyle displayL(BuildContext context, {Color? color}) => _display(
    context,
    size: 32,
    weight: FontWeight.w700,
    height: 1.08,
    trackingEm: -0.022,
    color: color,
  );

  static TextStyle displayM(BuildContext context, {Color? color}) => _display(
    context,
    size: 26,
    weight: FontWeight.w700,
    height: 1.12,
    trackingEm: -0.020,
    color: color,
  );

  static TextStyle displayS(BuildContext context, {Color? color}) => _display(
    context,
    size: 20,
    weight: FontWeight.w700,
    height: 1.20,
    trackingEm: -0.015,
    color: color,
  );

  // ── Titles — section headers, card titles ────────────────────────────────

  static TextStyle titleL(BuildContext context, {Color? color}) => _display(
    context,
    size: 18,
    weight: FontWeight.w600,
    height: 1.25,
    trackingEm: -0.010,
    color: color,
  );

  static TextStyle titleM(BuildContext context, {Color? color}) => _text(
    context,
    size: 16,
    weight: FontWeight.w600,
    height: 1.30,
    trackingEm: -0.005,
    color: color,
  );

  static TextStyle titleS(BuildContext context, {Color? color}) => _text(
    context,
    size: 14,
    weight: FontWeight.w600,
    height: 1.35,
    color: color,
  );

  // ── Body — readable prose and supporting copy ────────────────────────────

  static TextStyle bodyL(BuildContext context, {Color? color}) => _text(
    context,
    size: 16,
    weight: FontWeight.w400,
    height: 1.50,
    color: color,
  );

  static TextStyle bodyM(BuildContext context, {Color? color}) => _text(
    context,
    size: 14,
    weight: FontWeight.w400,
    height: 1.50,
    color: color,
  );

  static TextStyle bodyS(BuildContext context, {Color? color}) => _text(
    context,
    size: 13,
    weight: FontWeight.w400,
    height: 1.45,
    color: color ?? CatchTokens.of(context).ink2,
  );

  // ── Labels — controls, metadata, small uppercase chips ───────────────────

  static TextStyle labelL(BuildContext context, {Color? color}) => _text(
    context,
    size: 13,
    weight: FontWeight.w600,
    height: 1.30,
    color: color,
  );

  static TextStyle labelM(BuildContext context, {Color? color}) => _text(
    context,
    size: 11,
    weight: FontWeight.w600,
    height: 1.30,
    trackingEm: 0.040,
    color: color ?? CatchTokens.of(context).ink2,
  );

  static TextStyle labelS(BuildContext context, {Color? color}) => _text(
    context,
    size: 10,
    weight: FontWeight.w700,
    height: 1.20,
    trackingEm: 0.060,
    color: color ?? CatchTokens.of(context).ink2,
  );

  // ── Mono — pace, distance, codes, countdowns ─────────────────────────────

  static TextStyle mono(BuildContext context, {Color? color}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.40,
        letterSpacing: 0,
        color: color ?? CatchTokens.of(context).ink,
      );

  static TextStyle _display(
    BuildContext context, {
    required double size,
    required FontWeight weight,
    required double height,
    double trackingEm = 0,
    Color? color,
  }) => GoogleFonts.spaceGrotesk(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: size * trackingEm,
    color: color ?? CatchTokens.of(context).ink,
  );

  static TextStyle _text(
    BuildContext context, {
    required double size,
    required FontWeight weight,
    required double height,
    double trackingEm = 0,
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: size * trackingEm,
    color: color ?? CatchTokens.of(context).ink,
  );
}
