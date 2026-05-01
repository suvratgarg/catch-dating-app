import 'package:flutter/material.dart';

/// Design tokens for Catch, based on the canonical Sunset palette and Sporty
/// type direction from the design-system handoff.
///
/// Access via `CatchTokens.of(context)` inside any widget.
/// [AppTheme] wires `sunsetLight` / `sunsetDark` into [ThemeData.extensions].
@immutable
class CatchTokens extends ThemeExtension<CatchTokens> {
  const CatchTokens({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.overlay,
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
    required this.success,
    required this.warning,
    required this.danger,
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

  /// Modal scrim / overlay.
  final Color overlay;

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

  /// Positive state colour.
  final Color success;

  /// Warning / attention state colour.
  final Color warning;

  /// Error / destructive state colour.
  final Color danger;

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
    bg: Color(0xFFFBF3E9),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFFFF8EE),
    overlay: Color.fromRGBO(26, 20, 16, 0.55),
    ink: Color(0xFF1A1410),
    ink2: Color(0xFF5C4A3A),
    ink3: Color(0xFF9C8775),
    line: Color.fromRGBO(26, 20, 16, 0.08),
    line2: Color.fromRGBO(26, 20, 16, 0.14),
    primary: Color(0xFFFF4E1F),
    primaryInk: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFFFE2D4),
    accent: Color(0xFF0B3B3C),
    accentInk: Color(0xFFFFFFFF),
    success: Color(0xFF2F7D45),
    warning: Color(0xFFC97B0E),
    danger: Color(0xFFC2261A),
    like: Color(0xFFFF4E1F),
    pass: Color(0xFF1A1410),
    gold: Color(0xFFE9A43A),
    heroGrad: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.60, 1.0],
      colors: [Color(0xFFFF4E1F), Color(0xFFFF9A5C), Color(0xFFFFC78A)],
    ),
  );

  // ── Sunset palette — dark ─────────────────────────────────────────────────────

  static const sunsetDark = CatchTokens(
    bg: Color(0xFF120D09),
    surface: Color(0xFF1D1612),
    raised: Color(0xFF2A2018),
    overlay: Color.fromRGBO(0, 0, 0, 0.70),
    ink: Color(0xFFFBF3E9),
    ink2: Color(0xFFC8B8A6),
    ink3: Color(0xFF7C6B5A),
    line: Color.fromRGBO(251, 243, 233, 0.10),
    line2: Color.fromRGBO(251, 243, 233, 0.18),
    primary: Color(0xFFFF6A3F),
    primaryInk: Color(0xFF120D09),
    primarySoft: Color(0xFF3A1E10),
    accent: Color(0xFF45D6B3),
    accentInk: Color(0xFF120D09),
    success: Color(0xFF5BC07C),
    warning: Color(0xFFE5A655),
    danger: Color(0xFFE5564B),
    like: Color(0xFFFF6A3F),
    pass: Color(0xFFFBF3E9),
    gold: Color(0xFFF0B85A),
    heroGrad: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF4E1F), Color(0xFFA03014)],
    ),
  );

  // ── ThemeExtension boilerplate ────────────────────────────────────────────────

  @override
  CatchTokens copyWith({
    Color? bg,
    Color? surface,
    Color? raised,
    Color? overlay,
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
    Color? success,
    Color? warning,
    Color? danger,
    Color? like,
    Color? pass,
    Color? gold,
    Gradient? heroGrad,
  }) => CatchTokens(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    raised: raised ?? this.raised,
    overlay: overlay ?? this.overlay,
    ink: ink ?? this.ink,
    ink2: ink2 ?? this.ink2,
    ink3: ink3 ?? this.ink3,
    line: line ?? this.line,
    line2: line2 ?? this.line2,
    primary: primary ?? this.primary,
    primaryInk: primaryInk ?? this.primaryInk,
    primarySoft: primarySoft ?? this.primarySoft,
    accent: accent ?? this.accent,
    accentInk: accentInk ?? this.accentInk,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    like: like ?? this.like,
    pass: pass ?? this.pass,
    gold: gold ?? this.gold,
    heroGrad: heroGrad ?? this.heroGrad,
  );

  @override
  CatchTokens lerp(CatchTokens? other, double t) {
    if (other is! CatchTokens) return this;
    return CatchTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      line: Color.lerp(line, other.line, t)!,
      line2: Color.lerp(line2, other.line2, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryInk: Color.lerp(primaryInk, other.primaryInk, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      like: Color.lerp(like, other.like, t)!,
      pass: Color.lerp(pass, other.pass, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      heroGrad: Gradient.lerp(heroGrad, other.heroGrad, t)!,
    );
  }
}

// ── Spacing ───────────────────────────────────────────────────────────────────

/// Layout spacing constants from the design-system 4-point scale.
abstract final class CatchSpacing {
  static const double s0 = 0.0;
  static const double s1 = 4.0;
  static const double s2 = 8.0;
  static const double s3 = 12.0;
  static const double s4 = 16.0;
  static const double s5 = 20.0;
  static const double s6 = 24.0;
  static const double s8 = 32.0;
  static const double s10 = 40.0;
  static const double s12 = 48.0;
  static const double s16 = 64.0;
}

// ── Radii ─────────────────────────────────────────────────────────────────────

/// Corner radius constants from the design-system radius scale.
abstract final class CatchRadius {
  static const double none = 0.0;
  static const double sm = 8.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double pill = 999.0;
}

// ── Elevation ────────────────────────────────────────────────────────────────

/// Minimal elevation tokens. Most Catch surfaces should use a hairline border;
/// use shadows only when UI actually floats above content.
abstract final class CatchElevation {
  static const List<BoxShadow> none = <BoxShadow>[];

  /// Bottom sheets, floating action buttons, popovers.
  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.10),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.06),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Toasts, snackbars, dropdown overlays.
  static const List<BoxShadow> overlay = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.18),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.08),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}

// ── Motion ───────────────────────────────────────────────────────────────────

/// Shared motion tokens for hover/tap feedback, standard transitions, and
/// celebratory success moments.
abstract final class CatchMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 420);

  static const Curve standardCurve = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve springCurve = Cubic(0.34, 1.4, 0.64, 1.0);
}

// ── Iconography ──────────────────────────────────────────────────────────────

/// Icon sizing and stroke guidance from the component catalog.
abstract final class CatchIcon {
  static const double sm = 14.0;
  static const double md = 18.0;
  static const double lg = 24.0;

  static const double strokeSm = 1.6;
  static const double strokeMd = 1.6;
  static const double strokeLg = 1.8;
}
