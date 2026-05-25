import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens for Catch's canonical type system:
/// Inter for display, text, labels, and numeric treatments.
///
/// These names mirror the design-system catalog. Prefer the named styles over
/// ad hoc `TextStyle` values, and use `copyWith` only for local state changes
/// such as unread or disabled text.
abstract final class CatchTextStyles {
  // -- Editorial roles - expressive text moments -----------------------------

  static TextStyle heroImpact(BuildContext context, {Color? color}) => _display(
    context,
    size: 48,
    weight: FontWeight.w800,
    height: 0.95,
    color: color,
  );

  static TextStyle heroHeadline(BuildContext context, {Color? color}) =>
      _display(
        context,
        size: 34,
        weight: FontWeight.w800,
        height: 1.05,
        color: color,
      );

  static TextStyle screenHeadline(BuildContext context, {Color? color}) =>
      _display(
        context,
        size: 32,
        weight: FontWeight.w800,
        height: 1.05,
        color: color,
      );

  static TextStyle formQuestion(BuildContext context, {Color? color}) =>
      _display(
        context,
        size: 28,
        weight: FontWeight.w800,
        height: 1.10,
        color: color,
      );

  static TextStyle cardTitle(BuildContext context, {Color? color}) => _display(
    context,
    size: 20,
    weight: FontWeight.w700,
    height: 1.18,
    color: color,
  );

  static TextStyle sectionTitle(BuildContext context, {Color? color}) => _text(
    context,
    size: 16,
    weight: FontWeight.w700,
    height: 1.22,
    color: color,
  );

  static TextStyle bodyLead(BuildContext context, {Color? color}) => _text(
    context,
    size: 16,
    weight: FontWeight.w500,
    height: 1.42,
    color: color ?? CatchTokens.of(context).ink2,
  );

  static TextStyle supporting(BuildContext context, {Color? color}) => _text(
    context,
    size: 13,
    weight: FontWeight.w500,
    height: 1.42,
    color: color ?? CatchTokens.of(context).ink2,
  );

  static TextStyle kicker(BuildContext context, {Color? color}) => _text(
    context,
    size: 11,
    weight: FontWeight.w800,
    height: 1.15,
    color: color ?? CatchTokens.of(context).ink2,
  );

  static TextStyle statusLabel(BuildContext context, {Color? color}) => _text(
    context,
    size: 10,
    weight: FontWeight.w800,
    height: 1.10,
    color: color ?? CatchTokens.of(context).ink2,
  );

  static TextStyle chatMessage(BuildContext context, {Color? color}) => _text(
    context,
    size: 15,
    weight: FontWeight.w400,
    height: 1.42,
    color: color,
  );

  static TextStyle profileAnswer(BuildContext context, {Color? color}) => _text(
    context,
    size: 18,
    weight: FontWeight.w700,
    height: 1.28,
    color: color,
  );

  static TextStyle statDisplay(BuildContext context, {Color? color}) =>
      _tabular(
        _display(
          context,
          size: 36,
          weight: FontWeight.w800,
          height: 1,
          color: color,
        ),
      );

  static TextStyle statCompact(BuildContext context, {Color? color}) =>
      _tabular(
        _text(
          context,
          size: 14,
          weight: FontWeight.w700,
          height: 1.15,
          color: color,
        ),
      );

  // ── Display — hero moments, screen titles ─────────────────────────────────

  static TextStyle displayXL(BuildContext context, {Color? color}) => _display(
    context,
    size: 40,
    weight: FontWeight.w800,
    height: 1.02,
    color: color,
  );

  static TextStyle displayL(BuildContext context, {Color? color}) => _display(
    context,
    size: 32,
    weight: FontWeight.w800,
    height: 1.04,
    color: color,
  );

  static TextStyle displayM(BuildContext context, {Color? color}) => _display(
    context,
    size: 26,
    weight: FontWeight.w800,
    height: 1.08,
    color: color,
  );

  static TextStyle displayS(BuildContext context, {Color? color}) => _display(
    context,
    size: 20,
    weight: FontWeight.w800,
    height: 1.14,
    color: color,
  );

  // ── Titles — section headers, card titles ────────────────────────────────

  static TextStyle titleL(BuildContext context, {Color? color}) => _display(
    context,
    size: 19,
    weight: FontWeight.w700,
    height: 1.20,
    color: color,
  );

  static TextStyle titleM(BuildContext context, {Color? color}) => _text(
    context,
    size: 16,
    weight: FontWeight.w700,
    height: 1.24,
    color: color,
  );

  static TextStyle titleS(BuildContext context, {Color? color}) => _text(
    context,
    size: 14,
    weight: FontWeight.w700,
    height: 1.26,
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
    weight: FontWeight.w700,
    height: 1.24,
    color: color,
  );

  static TextStyle labelM(BuildContext context, {Color? color}) => _text(
    context,
    size: 11,
    weight: FontWeight.w600,
    height: 1.30,
    color: color ?? CatchTokens.of(context).ink2,
  );

  static TextStyle labelS(BuildContext context, {Color? color}) => _text(
    context,
    size: 10,
    weight: FontWeight.w700,
    height: 1.20,
    color: color ?? CatchTokens.of(context).ink2,
  );

  // ── Mono — pace, distance, codes, countdowns ─────────────────────────────

  static TextStyle mono(BuildContext context, {Color? color}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.40,
        letterSpacing: 0,
        fontFeatures: const [FontFeature.tabularFigures()],
        decoration: TextDecoration.none,
        color: color ?? CatchTokens.of(context).ink,
      );

  static TextStyle _tabular(TextStyle style) =>
      style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static TextStyle _display(
    BuildContext context, {
    required double size,
    required FontWeight weight,
    required double height,
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: 0,
    decoration: TextDecoration.none,
    color: color ?? CatchTokens.of(context).ink,
  );

  static TextStyle _text(
    BuildContext context, {
    required double size,
    required FontWeight weight,
    required double height,
    Color? color,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: 0,
    decoration: TextDecoration.none,
    color: color ?? CatchTokens.of(context).ink,
  );
}
