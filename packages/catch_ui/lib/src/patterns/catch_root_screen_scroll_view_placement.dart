/// Declares which owner consumes the physical top safe-area inset.
enum CatchRootScreenScrollViewPlacement {
  /// The canonical root scroll owner keeps all content below the safe area.
  safeArea,

  /// An edge-to-edge header paints behind system chrome and applies its own
  /// safe-area padding to interactive content.
  headerOwned,
}
