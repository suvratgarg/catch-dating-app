/// Material 3 window size class breakpoints, in logical pixels.
///
/// These match the Material Design 3 [Window size classes]
/// (https://m3.material.io/foundations/layout/applying-layout/window-size-classes)
/// convention:
///
/// - **Compact** (< 600 dp): phone portrait, small phone landscape
/// - **Medium** (600–839 dp): tablet portrait, large phone landscape, foldable
/// - **Expanded** (≥ 840 dp): tablet landscape, desktop, large foldable
///
/// Usage:
/// ```dart
/// final screenSize = ScreenSize.fromWidth(
///   MediaQuery.of(context).size.width,
/// );
/// ```
enum ScreenSize {
  compact,
  medium,
  expanded;

  /// Returns the [ScreenSize] for [width] in logical pixels.
  static ScreenSize fromWidth(double width) {
    if (width < _compactMax) return compact;
    if (width < _mediumMax) return medium;
    return expanded;
  }

  // ── Thresholds ──────────────────────────────────────────────────────────

  static const _compactMax = 600;
  static const _mediumMax = 840;

  // ── Convenience ─────────────────────────────────────────────────────────

  bool get isCompact => this == compact;
  bool get isMedium => this == medium;
  bool get isExpanded => this == expanded;
  bool get isMediumOrExpanded => this != compact;
}

/// Maximum logical-pixel width for a phone-portrait layout.
const kPhoneMaxWidth = 600;

/// Maximum logical-pixel width for a tablet layout.
const kTabletMaxWidth = 840;
