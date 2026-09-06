/// Stroke widths that are part of reusable component geometry.
abstract final class CatchStroke {
  static const double hairline = 1.0;
  static const double emphasis = 1.5;
  static const double progressIndicator = 2.0;
  static const double avatarRing = 2.0;

  /// Typographic underline compatibility alias. Border emphasis should use
  /// `CatchBorderRole.selected`, `CatchBorderRole.danger`, or
  /// `CatchBorderRole.warning` instead of selecting this width directly.
  static const double underline = 1.5;
  static const double focusRing = 2.0;
  static const double selection = 3.0;
  static const double passProgress = 2.6;
}
