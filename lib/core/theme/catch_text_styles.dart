import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Catch's typographic scale — one principled hierarchy across three roles:
/// Archivo for *voice/head* (brand display, heroes, deliberate poster moments),
/// the platform system font for *function* (body, controls, names, dense UI),
/// and IBM Plex Mono for *data* (kickers, numerics, labels).
///
/// **Fidelity rules** (the locked specimen, `docs/visual_references/catch_typography.html`):
/// - Display voice is **Archivo w600 with zero tracking** — bold but still
///   restrained.
/// - Mono kickers/labels are uppercase with zero tracking. Render the text
///   already upper-cased; the style keeps letter spacing at the Flutter default.
/// - Body/prose roles use the platform system font with generous leading.
///
/// **Scale discipline:** dramatic jumps in the display tier (no near-duplicate
/// mid-sizes); fine steps only where function needs them (labels/body).
///
/// Prefer the named styles over ad hoc [TextStyle]; use `copyWith` only for local
/// state (unread/disabled).
abstract final class CatchTextStyles {
  // ===========================================================================
  // VOICE — Archivo (brand display and deliberate poster moments)
  // ===========================================================================

  /// Biggest brand moment — onboarding/celebration impact, live countdowns.
  static TextStyle display(BuildContext context, {Color? color}) => _voice(
    context,
    size: 44,
    weight: FontWeight.w600,
    height: 0.98,
    color: color,
  );

  /// Brand headline / section hero.
  static TextStyle headline(BuildContext context, {Color? color}) => _voice(
    context,
    size: 32,
    weight: FontWeight.w600,
    height: 1.04,
    color: color,
  );

  /// Smaller brand headline — a step under [headline].
  static TextStyle headlineS(BuildContext context, {Color? color}) => _voice(
    context,
    size: 26,
    weight: FontWeight.w600,
    height: 1.10,
    color: color,
  );

  /// Editorial club identity treatment (parametric size) shared by Explore club
  /// cards and the club detail hero/collapsed header.
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

  /// Ticket/event identity treatment (parametric size) shared by Explore event
  /// cards and detail headers.
  static TextStyle eventDisplay(
    BuildContext context, {
    required double size,
    double height = 1.0,
    Color? color,
    FontWeight weight = FontWeight.w600,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return CatchFonts.eventDisplay(
      fontSize: size,
      fontWeight: weight,
      fontStyle: fontStyle,
      height: height,
      color: color ?? CatchTokens.of(context).ink,
    );
  }

  /// Condensed poster title (`.t-event-title`).
  static TextStyle eventTitle(BuildContext context, {Color? color}) =>
      CatchFonts.head(
        fontSize: 36,
        width: 90,
        height: 1,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// Host live-console title (`.t-console-title`).
  static TextStyle consoleTitle(BuildContext context, {Color? color}) =>
      CatchFonts.head(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        width: 90,
        height: 1.15,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// Condensed hint/list copy (`.t-hint`).
  static TextStyle hint(BuildContext context, {Color? color}) =>
      CatchFonts.head(
        fontSize: 16.5,
        fontWeight: FontWeight.w600,
        width: 94,
        height: 1.25,
        color: color ?? CatchTokens.of(context).ink,
      );

  // ===========================================================================
  // FUNCTION — platform system font (UI titles, body, labels, controls)
  // ===========================================================================

  /// Large UI title for sections, cards, and sheet headings.
  static TextStyle titleL(BuildContext context, {Color? color}) => _sans(
    context,
    size: 20,
    weight: FontWeight.w700,
    height: 1.16,
    color: color,
  );

  /// Profile prompt answers — user-authored content, not brand voice.
  static TextStyle profileAnswer(BuildContext context, {Color? color}) => _sans(
    context,
    size: 18,
    weight: FontWeight.w600,
    height: 1.28,
    color: color,
  );

  /// Long-form app/user copy — bios, event descriptions, readable details.
  static TextStyle proseL(BuildContext context, {Color? color}) => _sans(
    context,
    size: 16,
    weight: FontWeight.w400,
    height: 1.55,
    color: color,
  );

  /// Long-form app/user copy, smaller cut.
  static TextStyle proseM(BuildContext context, {Color? color}) => _sans(
    context,
    size: 14,
    weight: FontWeight.w400,
    height: 1.55,
    color: color,
  );

  /// Host/person row name treatment (`.t-name`).
  static TextStyle name(BuildContext context, {Color? color}) => _sans(
    context,
    size: 15,
    weight: FontWeight.w700,
    height: 1.2,
    color: color,
  );

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
    height: 1.24,
    color: color,
  );

  /// CatchField primary text (`.t-title-s` in the design handoff).
  static TextStyle fieldRowTitle(BuildContext context, {Color? color}) => _sans(
    context,
    size: 14,
    weight: FontWeight.w700,
    height: 1.24,
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

  /// AppBar subtitle (`.t-body-s`) under compact and large screen titles.
  static TextStyle appBarSubtitle(BuildContext context, {Color? color}) =>
      bodyS(context, color: color);

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
    size: 14,
    weight: FontWeight.w700,
    height: 1.24,
    color: color,
  );

  static TextStyle fieldLabel(BuildContext context, {Color? color}) => _sans(
    context,
    size: 11.5,
    weight: FontWeight.w500,
    height: 1.2,
    color: color ?? CatchTokens.of(context).ink3,
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

  static TextStyle button(BuildContext context, {Color? color}) =>
      buttonMd(context, color: color);

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

  /// OTP digit boxes (`.t-code`).
  static TextStyle otpDigit(BuildContext context, {Color? color}) =>
      code(context, color: color);

  /// Chat message body (sans, comfortable leading).
  static TextStyle chatMessage(BuildContext context, {Color? color}) => _sans(
    context,
    size: 15,
    weight: FontWeight.w400,
    height: 1.40,
    color: color,
  );

  static TextStyle chat(BuildContext context, {Color? color}) =>
      chatMessage(context, color: color);

  /// Chat inbox preview copy (`CatchPersonRow` chat-preview secondary line).
  static TextStyle chatPreview(BuildContext context, {Color? color}) => _sans(
    context,
    size: 13,
    weight: FontWeight.w400,
    height: 1.45,
    color: color ?? CatchTokens.of(context).ink2,
  );

  /// Chat thread event-context title (`ChatThreadHeader` secondary line).
  static TextStyle chatThreadContext(BuildContext context, {Color? color}) =>
      _sans(
        context,
        size: 14,
        weight: FontWeight.w600,
        height: 1.35,
        color: color ?? CatchTokens.of(context).ink,
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
  // DATA — IBM Plex Mono (kickers, numerics, labels)
  // ===========================================================================

  /// Uppercase kicker — eyebrows, time-line labels (`TONIGHT · 8:50 PM`).
  /// Render text already upper-cased; this sets weight, size, and leading.
  static TextStyle kicker(BuildContext context, {Color? color}) => _mono(
    context,
    size: 11,
    weight: FontWeight.w700,
    height: 1.15,
    color: color ?? CatchTokens.of(context).ink2,
  );

  /// Larger uppercase kicker for editorial sashes (`TONIGHT'S PICK`).
  static TextStyle kickerLg(BuildContext context, {Color? color}) => _mono(
    context,
    size: 12,
    weight: FontWeight.w700,
    height: 1.1,
    color: color ?? CatchTokens.of(context).ink,
  );

  /// Mono meta label — ticket meta, hero time chips, status badges.
  static TextStyle monoLabel(BuildContext context, {Color? color}) => _mono(
    context,
    size: 11,
    weight: FontWeight.w600,
    height: 1.15,
    color: color ?? CatchTokens.of(context).ink2,
  );

  /// Smallest mono label — date-rail weekday/month, micro meta.
  static TextStyle monoLabelS(BuildContext context, {Color? color}) => _mono(
    context,
    size: 10,
    weight: FontWeight.w700,
    height: 1.15,
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

  /// Compact mono meta (`.t-meta`).
  static TextStyle meta(BuildContext context, {Color? color}) =>
      CatchFonts.mono(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: color ?? CatchTokens.of(context).ink2,
      );

  /// Tiny status badge label (`.t-badge`).
  static TextStyle badge(BuildContext context, {Color? color}) =>
      CatchFonts.mono(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// OTP/code digit (`.t-code`).
  static TextStyle code(BuildContext context, {Color? color}) =>
      CatchFonts.mono(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1,
        color: color ?? CatchTokens.of(context).ink,
      );

  /// Oversized tabular stat number.
  static TextStyle statDisplay(BuildContext context, {Color? color}) =>
      CatchFonts.mono(
        fontSize: 36,
        fontWeight: FontWeight.w700,
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

  static TextStyle _voice(
    BuildContext context, {
    required double size,
    required FontWeight weight,
    required double height,
    double letterSpacing = 0,
    Color? color,
  }) => CatchFonts.voice(
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
