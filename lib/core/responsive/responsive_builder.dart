import 'package:flutter/material.dart';

import 'breakpoints.dart';

/// Builds different layouts based on the current screen size.
///
/// Thin wrapper around [LayoutBuilder] that maps the available width to a
/// [ScreenSize] and calls the appropriate builder. Uses a default builder
/// for compact screens and optional overrides for medium/expanded.
///
/// Example:
/// ```dart
/// ResponsiveBuilder(
///   compact: (context) => _PhoneLayout(),
///   medium: (context) => _TabletLayout(),
///   expanded: (context) => _DesktopLayout(),
/// )
/// ```
///
/// If only [compact] is provided, all screen sizes use it (graceful
/// degradation — no tablet-specific layout is required).
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  /// Builder for compact screens (< 600 dp wide — phones).
  final WidgetBuilder compact;

  /// Optional builder for medium screens (600–839 dp — tablets / foldables).
  /// Falls back to [compact] when null.
  final WidgetBuilder? medium;

  /// Optional builder for expanded screens (≥ 840 dp — large tablets /
  /// desktop). Falls back to [medium] then [compact] when null.
  final WidgetBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = ScreenSize.fromWidth(constraints.maxWidth);
        return switch (size) {
          ScreenSize.compact => compact(context),
          ScreenSize.medium => (medium ?? compact)(context),
          ScreenSize.expanded => (expanded ?? medium ?? compact)(context),
        };
      },
    );
  }
}

/// Returns the appropriate grid column count for [width].
///
/// Defaults: 2 for compact, 3 for medium, 4 for expanded.
int responsiveGridCount(double width) {
  return switch (ScreenSize.fromWidth(width)) {
    ScreenSize.compact => 2,
    ScreenSize.medium => 3,
    ScreenSize.expanded => 4,
  };
}
