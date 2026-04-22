import 'package:flutter/material.dart';

/// Design tokens for Catch — ported from tokens.jsx (Sunset palette).
///
/// Access via `CatchTokens.of(context)` inside any widget.
/// All three palettes are available as static constants; the
/// [AppTheme] wires `sunsetLight` / `sunsetDark` into [ThemeData.extensions].
@immutable
class CatchTokens extends ThemeExtension<CatchTokens> {
  const CatchTokens({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.line2,
    required this.primary,
    required this.primaryInk,
    required this.primarySoft,
    required this.accent,
    required this.accentInk,
    required this.like,
    required this.pass,
    required this.gold,
    required this.heroGrad,
  });

  // ── Semantic colour roles ─────────────────────────────────────────────────────

  /// App background (warm cream in Sunset).
  final Color bg;

  /// Card / modal surface.
  final Color surface;

  /// Slightly raised surface (e.g. input backgrounds).
  final Color raised;

  /// Primary text colour.
  final Color ink;

  /// Secondary text colour.
  final Color ink2;

  /// Tertiary / placeholder text colour.
  final Color ink3;

  /// Hairline divider.
  final Color line;

  /// Slightly heavier divider.
  final Color line2;

  /// Brand orange (#FF4E1F in Sunset light).
  final Color primary;

  /// Text/icon colour on top of [primary] fills.
  final Color primaryInk;

  /// Tinted background for soft primary containers (chips, badges).
  final Color primarySoft;

  /// Deep teal accent.
  final Color accent;

  /// Text/icon colour on top of [accent] fills.
  final Color accentInk;

  /// Swipe-like affordance colour.
  final Color like;

  /// Swipe-pass affordance colour.
  final Color pass;

  /// Gold / highlight colour (streak, achievement).
  final Color gold;

  /// Hero gradient used on onboarding, dashboard hero, match modal.
  final Gradient heroGrad;

  // ── Convenience accessor ──────────────────────────────────────────────────────

  static CatchTokens of(BuildContext context) =>
      Theme.of(context).extension<CatchTokens>()!;

  // ── Sunset palette — light (launch default) ───────────────────────────────────

  static const sunsetLight = CatchTokens(
    bg:          Color(0xFFFBF3E9),
    surface:     Color(0xFFFFFFFF),
    raised:      Color(0xFFFFF8EE),
    ink:         Color(0xFF1A1410),
    ink2:        Color(0xFF5C4A3A),
    ink3:        Color(0xFF9C8775),
    line:        Color.fromRGBO(26, 20, 16, 0.08),
    line2:       Color.fromRGBO(26, 20, 16, 0.14),
    primary:     Color(0xFFFF4E1F),
    primaryInk:  Color(0xFFFFFFFF),
    primarySoft: Color(0xFFFFE2D4),
    accent:      Color(0xFF0B3B3C),
    accentInk:   Color(0xFFFFFFFF),
    like:        Color(0xFFFF4E1F),
    pass:        Color(0xFF1A1410),
    gold:        Color(0xFFE9A43A),
    heroGrad:    LinearGradient(
      begin:  Alignment.topLeft,
      end:    Alignment.bottomRight,
      stops:  [0.0, 0.60, 1.0],
      colors: [Color(0xFFFF4E1F), Color(0xFFFF9A5C), Color(0xFFFFC78A)],
    ),
  );

  // ── Sunset palette — dark ─────────────────────────────────────────────────────

  static const sunsetDark = CatchTokens(
    bg:          Color(0xFF120D09),
    surface:     Color(0xFF1D1612),
    raised:      Color(0xFF2A2018),
    ink:         Color(0xFFFBF3E9),
    ink2:        Color(0xFFC8B8A6),
    ink3:        Color(0xFF7C6B5A),
    line:        Color.fromRGBO(251, 243, 233, 0.10),
    line2:       Color.fromRGBO(251, 243, 233, 0.18),
    primary:     Color(0xFFFF6A3F),
    primaryInk:  Color(0xFF120D09),
    primarySoft: Color(0xFF3A1E10),
    accent:      Color(0xFF45D6B3),
    accentInk:   Color(0xFFFFFFFF),
    like:        Color(0xFFFF6A3F),
    pass:        Color(0xFFFBF3E9),
    gold:        Color(0xFFE9A43A),
    heroGrad:    LinearGradient(
      begin:  Alignment.topLeft,
      end:    Alignment.bottomRight,
      stops:  [0.0, 0.60, 1.0],
      colors: [Color(0xFFFF4E1F), Color(0xFFFF9A5C), Color(0xFFFFC78A)],
    ),
  );

  // ── Street palette — light ────────────────────────────────────────────────────

  static const streetLight = CatchTokens(
    bg:          Color(0xFFF1F1EC),
    surface:     Color(0xFFFFFFFF),
    raised:      Color(0xFFF7F7F2),
    ink:         Color(0xFF0B0B0A),
    ink2:        Color(0xFF3F3F3B),
    ink3:        Color(0xFF8A8A84),
    line:        Color.fromRGBO(11, 11, 10, 0.08),
    line2:       Color.fromRGBO(11, 11, 10, 0.15),
    primary:     Color(0xFF0B0B0A),
    primaryInk:  Color(0xFFD6FF3B),
    primarySoft: Color(0xFFE9E9E4),
    accent:      Color(0xFFD6FF3B),
    accentInk:   Color(0xFF0B0B0A),
    like:        Color(0xFFD6FF3B),
    pass:        Color(0xFF0B0B0A),
    gold:        Color(0xFFFF7A00),
    heroGrad:    LinearGradient(
      begin:  Alignment.topCenter,
      end:    Alignment.bottomCenter,
      colors: [Color(0xFF0B0B0A), Color(0xFF1C1C1A)],
    ),
  );

  // ── Editorial palette — light ─────────────────────────────────────────────────

  static const editorialLight = CatchTokens(
    bg:          Color(0xFFF2EDE3),
    surface:     Color(0xFFFFFDF8),
    raised:      Color(0xFFEFE8DA),
    ink:         Color(0xFF1C1A14),
    ink2:        Color(0xFF5A5042),
    ink3:        Color(0xFF9A8F7C),
    line:        Color.fromRGBO(28, 26, 20, 0.10),
    line2:       Color.fromRGBO(28, 26, 20, 0.18),
    primary:     Color(0xFFC7502C),
    primaryInk:  Color(0xFFFFFDF8),
    primarySoft: Color(0xFFF4DDD1),
    accent:      Color(0xFF3C4A22),
    accentInk:   Color(0xFFFFFDF8),
    like:        Color(0xFFC7502C),
    pass:        Color(0xFF1C1A14),
    gold:        Color(0xFFB58A3E),
    heroGrad:    LinearGradient(
      begin:  Alignment.topLeft,
      end:    Alignment.bottomRight,
      colors: [Color(0xFFC7502C), Color(0xFFE9A86C)],
    ),
  );

  // ── ThemeExtension boilerplate ────────────────────────────────────────────────

  @override
  CatchTokens copyWith({
    Color? bg,
    Color? surface,
    Color? raised,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? line,
    Color? line2,
    Color? primary,
    Color? primaryInk,
    Color? primarySoft,
    Color? accent,
    Color? accentInk,
    Color? like,
    Color? pass,
    Color? gold,
    Gradient? heroGrad,
  }) =>
      CatchTokens(
        bg:          bg          ?? this.bg,
        surface:     surface     ?? this.surface,
        raised:      raised      ?? this.raised,
        ink:         ink         ?? this.ink,
        ink2:        ink2        ?? this.ink2,
        ink3:        ink3        ?? this.ink3,
        line:        line        ?? this.line,
        line2:       line2       ?? this.line2,
        primary:     primary     ?? this.primary,
        primaryInk:  primaryInk  ?? this.primaryInk,
        primarySoft: primarySoft ?? this.primarySoft,
        accent:      accent      ?? this.accent,
        accentInk:   accentInk   ?? this.accentInk,
        like:        like        ?? this.like,
        pass:        pass        ?? this.pass,
        gold:        gold        ?? this.gold,
        heroGrad:    heroGrad    ?? this.heroGrad,
      );

  @override
  CatchTokens lerp(CatchTokens? other, double t) {
    if (other is! CatchTokens) return this;
    return CatchTokens(
      bg:          Color.lerp(bg,          other.bg,          t)!,
      surface:     Color.lerp(surface,     other.surface,     t)!,
      raised:      Color.lerp(raised,      other.raised,      t)!,
      ink:         Color.lerp(ink,         other.ink,         t)!,
      ink2:        Color.lerp(ink2,        other.ink2,        t)!,
      ink3:        Color.lerp(ink3,        other.ink3,        t)!,
      line:        Color.lerp(line,        other.line,        t)!,
      line2:       Color.lerp(line2,       other.line2,       t)!,
      primary:     Color.lerp(primary,     other.primary,     t)!,
      primaryInk:  Color.lerp(primaryInk,  other.primaryInk,  t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accent:      Color.lerp(accent,      other.accent,      t)!,
      accentInk:   Color.lerp(accentInk,   other.accentInk,   t)!,
      like:        Color.lerp(like,        other.like,        t)!,
      pass:        Color.lerp(pass,        other.pass,        t)!,
      gold:        Color.lerp(gold,        other.gold,        t)!,
      heroGrad:    Gradient.lerp(heroGrad, other.heroGrad,    t)!,
    );
  }
}

// ── Spacing ───────────────────────────────────────────────────────────────────

/// Layout spacing constants from tokens.jsx.
abstract final class CatchSpacing {
  /// Horizontal padding applied to full-width screens.
  static const double screenH = 20.0;

  /// Horizontal padding inside cards.
  static const double cardH = 16.0;

  /// Assumed iOS status bar height (design canvas value).
  static const double statusBarHeight = 47.0;

  /// Bottom tab bar height.
  static const double tabBarHeight = 84.0;
}

// ── Radii ─────────────────────────────────────────────────────────────────────

/// Corner radius constants from tokens.jsx.
abstract final class CatchRadius {
  /// Standard card.
  static const double card = 14.0;

  /// Prominent / hero card.
  static const double cardLg = 18.0;

  /// Pill — buttons, chips, status badges.
  static const double button = 999.0;
}
