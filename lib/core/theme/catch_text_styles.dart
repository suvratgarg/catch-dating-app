import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Catch's typographic scale — one principled hierarchy across three roles:
/// Newsreader for *voice* (display + editorial body), Inter for *function*
/// (UI controls), IBM Plex Mono for *data* (kickers, numerics, labels).
///
/// **Fidelity rules** (the locked specimen, `docs/visual_references/catch_typography.html`):
/// - Display serif is **w600 with negative tracking** — refined, not blunt. Optical
///   sizing is automatic (driven from point size inside [CatchFonts]); large cuts read
///   as display, small cuts as text.
/// - Mono kickers/labels are **tracked uppercase** (0.12–0.18em). Render the text
///   already upper-cased; the style only sets weight/size/tracking.
/// - Body serif (`proseL`/`proseM`) uses generous leading (~1.55).
///
/// **Scale discipline:** dramatic jumps in the display tier (no near-duplicate
/// mid-sizes); fine steps only where function needs them (labels/body).
///
/// Prefer the named styles over ad hoc [TextStyle]; use `copyWith` only for local
/// state (unread/disabled).
abstract final class CatchTextStyles {
  // ===========================================================================
  // VOICE — Newsreader serif (display, titles, editorial body)
  // ===========================================================================

  /// Biggest hero moment — onboarding/celebration impact, live countdowns.
  static TextStyle display(BuildContext context, {Color? color}) => _serif(
    context,
    size: 44,
    weight: FontWeight.w600,
    height: 0.98,
    letterSpacing: -0.7,
    color: color,
  );

  /// Screen titles and section heroes.
  static TextStyle headline(BuildContext context, {Color? color}) => _serif(
    context,
    size: 32,
    weight: FontWeight.w600,
    height: 1.04,
    letterSpacing: -0.35,
    color: color,
  );

  /// Sub-headlines and form questions — a step under [headline].
  static TextStyle headlineS(BuildContext context, {Color? color}) => _serif(
    context,
    size: 26,
    weight: FontWeight.w600,
    height: 1.10,
    letterSpacing: -0.16,
    color: color,
  );

  /// Serif card / section titles (club + event identity, editorial cards).
  static TextStyle titleL(BuildContext context, {Color? color}) => _serif(
    context,
    size: 20,
    weight: FontWeight.w600,
    height: 1.16,
    letterSpacing: -0.1,
    color: color,
  );

  /// Profile prompt answers — editorial serif, a touch tighter leading.
  static TextStyle profileAnswer(BuildContext context, {Color? color}) =>
      _serif(
        context,
        size: 18,
        weight: FontWeight.w600,
        height: 1.28,
        color: color,
      );

  /// Editorial prose — bios, event descriptions, long-form reading text.
  static TextStyle proseL(BuildContext context, {Color? color}) => _serif(
    context,
    size: 16,
    weight: FontWeight.w400,
    height: 1.55,
    color: color,
  );

  /// Editorial prose, smaller cut.
  static TextStyle proseM(BuildContext context, {Color? color}) => _serif(
    context,
    size: 14,
    weight: FontWeight.w400,
    height: 1.55,
    color: color,
  );

  /// Editorial club identity treatment (parametric size) shared by Explore club
  /// cards and the club detail hero/collapsed header. Optical sizing is automatic.
  static TextStyle clubDisplay(
    BuildContext context, {
    required double size,
    double height = 1.0,
    Color? color,
    FontWeight weight = FontWeight.w600,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return CatchFonts.clubDisplay(
      fontSize: size,
      fontWeight: weight,
      fontStyle: fontStyle,
      height: height,
      color: color ?? CatchTokens.of(context).ink,
    );
  }

  /// Ticket/event identity treatment (parametric size) — italic by default
  /// (the ticket-metaphor look). Shared by Explore event cards + detail headers.
  static TextStyle eventDisplay(
    BuildContext context, {
    required double size,
    double height = 1.0,
    Color? color,
    FontWeight weight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.italic,
  }) {
    return CatchFonts.eventDisplay(
      fontSize: size,
      fontWeight: weight,
      fontStyle: fontStyle,
      height: height,
      color: color ?? CatchTokens.of(context).ink,
    );
  }

  // ===========================================================================
  // FUNCTION — Inter sans (UI titles, body, labels, controls)
  // ===========================================================================

  /// Canonical sans section/card title.
  static TextStyle sectionTitle(BuildContext context, {Color? color}) => _sans(
    context,
    size: 16,
    weight: FontWeight.w700,
    height: 1.22,
    color: color,
  );

  /// Small sans title.
  static TextStyle titleS(BuildContext context, {Color? color}) => _sans(
    context,
    size: 14,
    weight: FontWeight.w700,
    height: 1.26,
    color: color,
  );

  /// Lead-in supporting copy (slightly heavier than [supporting]).
  static TextStyle bodyLead(BuildContext context, {Color? color}) => _sans(
    context,
    size: 16,
    weight: FontWeight.w500,
    height: 1.42,
    color: color ?? CatchTokens.of(context).ink2,
  );

  static TextStyle bodyL(BuildContext context, {Color? color}) => _sans(
    context,
    size: 16,
    weight: FontWeight.w400,
    height: 1.50,
    color: color,
  );

  static TextStyle bodyM(BuildContext context, {Color? color}) => _sans(
    context,
    size: 14,
    weight: FontWeight.w400,
    height: 1.50,
    color: color,
  );

  static TextStyle bodyS(BuildContext context, {Color? color}) => _sans(
    context,
    size: 13,
    weight: FontWeight.w400,
    height: 1.45,
    color: color ?? CatchTokens.of(context).ink2,
  );

  /// The workhorse supporting label — dense meta, secondary copy.
  static TextStyle supporting(BuildContext context, {Color? color}) => _sans(
    context,
    size: 13,
    weight: FontWeight.w500,
    height: 1.42,
    color: color ?? CatchTokens.of(context).ink2,
  );

  static TextStyle labelL(BuildContext context, {Color? color}) => _sans(
    context,
    size: 13,
    weight: FontWeight.w700,
    height: 1.24,
    color: color,
  );

  static TextStyle labelM(BuildContext context, {Color? color}) => _sans(
    context,
    size: 11,
    weight: FontWeight.w600,
    height: 1.30,
    color: color ?? CatchTokens.of(context).ink2,
  );

  static TextStyle labelS(BuildContext context, {Color? color}) => _sans(
    context,
    size: 10,
    weight: FontWeight.w700,
    height: 1.20,
    color: color ?? CatchTokens.of(context).ink2,
  );

  /// Tiny all-caps status label (sans).
  static TextStyle statusLabel(BuildContext context, {Color? color}) => _sans(
    context,
    size: 10,
    weight: FontWeight.w800,
    height: 1.10,
    color: color ?? CatchTokens.of(context).ink2,
  );

  static TextStyle buttonSm(BuildContext context, {Color? color}) => _sans(
    context,
    size: 13,
    weight: FontWeight.w600,
    height: 1,
    color: color ?? CatchTokens.of(context).ink,
  );

  static TextStyle buttonMd(BuildContext context, {Color? color}) => _sans(
    context,
    size: 15,
    weight: FontWeight.w600,
    height: 1,
    color: color ?? CatchTokens.of(context).ink,
  );

  static TextStyle buttonLg(BuildContext context, {Color? color}) => _sans(
    context,
    size: 16,
    weight: FontWeight.w600,
    height: 1,
    color: color ?? CatchTokens.of(context).ink,
  );

  /// Count badge on overlapping avatars (parametric size).
  static TextStyle avatarCount(
    BuildContext context, {
    required double size,
    Color? color,
  }) => _sans(
    context,
    size: size,
    weight: FontWeight.w800,
    height: 1,
    color: color ?? CatchTokens.of(context).surface,
  );

  /// OTP digit boxes.
  static TextStyle otpDigit(BuildContext context, {Color? color}) => _sans(
    context,
    size: 24,
    weight: FontWeight.w700,
    height: 1.15,
    color: color,
  );

  /// Chat message body (sans, comfortable leading).
  static TextStyle chatMessage(BuildContext context, {Color? color}) => _sans(
    context,
    size: 15,
    weight: FontWeight.w400,
    height: 1.42,
    color: color,
  );

  /// Compact tabular stat figure (sans).
  static TextStyle statCompact(BuildContext context, {Color? color}) =>
      _tabular(
        _sans(
          context,
          size: 14,
          weight: FontWeight.w700,
          height: 1.15,
          color: color,
        ),
      );

  static TextStyle transparentInput() =>
      const TextStyle(color: Colors.transparent);

  static TextStyle mapPinTime({required double scale, required Color color}) =>
      CatchFonts.sans(
        fontSize: 13 * scale,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color,
      );

  static TextStyle mapPinCluster({
    required double scale,
    required Color color,
  }) => CatchFonts.sans(
    fontSize: 14 * scale,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: color,
  );

  // ===========================================================================
  // DATA — IBM Plex Mono (kickers, numerics, tracked labels)
  // ===========================================================================

  /// Tracked-uppercase kicker — eyebrows, time-line labels (`TONIGHT · 8:50 PM`).
  /// Render text already upper-cased; this sets weight + editorial tracking only.
  static TextStyle kicker(BuildContext context, {Color? color}) => _mono(
    context,
    size: 11,
    weight: FontWeight.w800,
    height: 1.15,
    letterSpacing: 1.6,
    color: color ?? CatchTokens.of(context).ink2,
  );

  /// Larger tracked kicker for editorial sashes (`TONIGHT'S PICK`).
  static TextStyle kickerLg(BuildContext context, {Color? color}) => _mono(
    context,
    size: 12,
    weight: FontWeight.w800,
    height: 1.1,
    letterSpacing: 2.0,
    color: color ?? CatchTokens.of(context).primary,
  );

  /// Tracked mono meta label — ticket meta, hero time chips, status badges.
  static TextStyle monoLabel(BuildContext context, {Color? color}) => _mono(
    context,
    size: 11,
    weight: FontWeight.w600,
    height: 1.15,
    letterSpacing: 1.3,
    color: color ?? CatchTokens.of(context).ink2,
  );

  /// Smallest tracked mono label — date-rail weekday/month, micro meta.
  static TextStyle monoLabelS(BuildContext context, {Color? color}) => _mono(
    context,
    size: 10,
    weight: FontWeight.w700,
    height: 1.15,
    letterSpacing: 1.2,
    color: color ?? CatchTokens.of(context).ink2,
  );

  /// Default mono run — pace, distance, codes, inline data.
  static TextStyle mono(BuildContext context, {Color? color}) =>
      CatchFonts.mono(
        fontSize: 13,
        height: 1.40,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// Tabular numerals for prominent quantities (`6/6`, `2.3 km`).
  static TextStyle numericLarge(BuildContext context, {Color? color}) =>
      CatchFonts.mono(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// Smaller tabular figure for inline meta (`7 km · 4 min walk`).
  static TextStyle numericMeta(BuildContext context, {Color? color}) =>
      CatchFonts.mono(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color ?? CatchTokens.of(context).ink2,
      );

  /// Oversized tabular stat number.
  static TextStyle statDisplay(BuildContext context, {Color? color}) =>
      CatchFonts.mono(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 1,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// Compact numeric seal on club cards.
  static TextStyle clubMemberSeal(BuildContext context, {Color? color}) =>
      labelM(context, color: color).copyWith(height: 1.05);

  static TextStyle debugDetails(BuildContext context, {Color? color}) =>
      CatchFonts.mono(
        fontSize: 12,
        height: 1.35,
        color: color ?? CatchTokens.of(context).ink2,
      );

  // ===========================================================================
  // Private builders — route through CatchFonts (which applies optical sizing).
  // ===========================================================================

  static TextStyle _tabular(TextStyle style) =>
      style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static TextStyle _serif(
    BuildContext context, {
    required double size,
    required FontWeight weight,
    required double height,
    double letterSpacing = 0,
    Color? color,
  }) => CatchFonts.serif(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    color: color ?? CatchTokens.of(context).ink,
  );

  static TextStyle _sans(
    BuildContext context, {
    required double size,
    required FontWeight weight,
    required double height,
    double letterSpacing = 0,
    Color? color,
  }) => CatchFonts.sans(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    color: color ?? CatchTokens.of(context).ink,
  );

  static TextStyle _mono(
    BuildContext context, {
    required double size,
    required FontWeight weight,
    required double height,
    double letterSpacing = 0,
    Color? color,
  }) => CatchFonts.mono(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    color: color ?? CatchTokens.of(context).ink,
  );
}
