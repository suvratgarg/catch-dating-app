/// Component-level layout breakpoints, in logical pixels.
///
/// Compared against the **local** box width from a [LayoutBuilder]
/// (`constraints.maxWidth`) — not the window size — so an individual widget can
/// reflow based on the space it is actually given.
///
/// Deliberately distinct from [ScreenSize] in `breakpoints.dart`, which
/// classifies the whole window into Material 3 size classes (compact / medium /
/// expanded). Use [ScreenSize] for app-shell decisions (bottom bar vs nav
/// rail); use these for in-widget reflow. Migrated verbatim from `CatchLayout`.
abstract final class ComponentBreakpoints {
  /// Catches deck surfaces gain horizontal padding once their column is this wide.
  static const double catchesWidePaddingBreakpoint = 700;

  /// Explore event-type grid switches 1 → 2 columns at this rail width.
  static const double eventTypeGridTwoColumnBreakpoint = 360.0;

  /// Event-success lab promise row goes 1 → 3 columns at this width.
  static const double eventSuccessLabPromiseBreakpoint = 640.0;

  /// Event-success lab module grid expands at this width.
  static const double eventSuccessLabModuleBreakpoint = 720.0;

  /// Event-policy lab metric tiles stack compactly below this width.
  static const double eventPolicyLabMetricsBreakpoint = 560.0;

  /// Live-reveal host countdown uses its compact layout below this width.
  static const double eventSuccessRevealHostCompactBreakpoint = 520.0;

  /// Dashboard quick-actions row fits all tiles in one row above this width.
  static const double quickActionsWideBreakpoint = 320.0;

  /// Structure-config editor goes 1 → 2 columns at this width.
  static const double eventSuccessConfigTwoColumnBreakpoint = 560.0;

  /// Host waitlist movement callout stacks its text and action below this local
  /// width so the action label never crowds the summary.
  static const double hostWaitlistBulkOfferStackBreakpoint = 340.0;
}
