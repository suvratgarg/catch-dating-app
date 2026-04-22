import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sporty typography helpers — Space Grotesk (display), Inter (text),
/// JetBrains Mono (timers, distances, paces).
///
/// All methods accept a [BuildContext] so they can read the active
/// [CatchTokens] and apply the correct ink colour automatically.
///
/// Usage:
/// ```dart
/// Text('Catch', style: CatchTextStyles.displayLg(context))
/// ```
///
/// Pass [color] to override the default ink colour.
abstract final class CatchTextStyles {
  // ── Display — Space Grotesk 700, -0.02em tracking ─────────────────────────

  /// 36 px — hero titles, onboarding headlines.
  static TextStyle displayXl(BuildContext context, {Color? color}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 36 * -0.02,
        height: 1.1,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// 28 px — section titles, dashboard hero label.
  static TextStyle displayLg(BuildContext context, {Color? color}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 28 * -0.02,
        height: 1.15,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// 22 px — card titles, modal headers.
  static TextStyle displayMd(BuildContext context, {Color? color}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 22 * -0.02,
        height: 1.2,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// 18 px — sub-section titles.
  static TextStyle displaySm(BuildContext context, {Color? color}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 18 * -0.02,
        height: 1.25,
        color: color ?? CatchTokens.of(context).ink,
      );

  // ── Body — Inter ──────────────────────────────────────────────────────────

  /// 17 px regular — primary body copy.
  static TextStyle bodyLg(
    BuildContext context, {
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: weight,
    height: 1.5,
    color: color ?? CatchTokens.of(context).ink,
  );

  /// 15 px regular — secondary body, card descriptions.
  static TextStyle bodyMd(
    BuildContext context, {
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: weight,
    height: 1.45,
    color: color ?? CatchTokens.of(context).ink,
  );

  /// 13 px regular — captions, meta text.
  static TextStyle bodySm(
    BuildContext context, {
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: weight,
    height: 1.4,
    color: color ?? CatchTokens.of(context).ink2,
  );

  // ── Labels — Inter semibold / bold ────────────────────────────────────────

  /// 15 px semibold — primary button labels, tab labels.
  static TextStyle labelLg(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// 13 px semibold — chip text, row meta labels.
  static TextStyle labelMd(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// 11 px semibold + 0.5 tracking — vibe tags, status chips (uppercase).
  static TextStyle labelSm(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.2,
        color: color ?? CatchTokens.of(context).ink2,
      );

  /// 12 px regular — footer captions, timestamps.
  static TextStyle caption(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: color ?? CatchTokens.of(context).ink3,
      );

  // ── Mono — JetBrains Mono — timers, paces, distances ─────────────────────

  /// 18 px medium mono — prominent stat values (pace, distance).
  static TextStyle monoLg(BuildContext context, {Color? color}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// 14 px medium mono — secondary stat values, countdown timers.
  static TextStyle mono(BuildContext context, {Color? color}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// 12 px regular mono — small inline stats.
  static TextStyle monoSm(BuildContext context, {Color? color}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: color ?? CatchTokens.of(context).ink2,
      );
}
