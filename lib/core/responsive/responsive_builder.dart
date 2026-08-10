import 'package:catch_dating_app/core/responsive/breakpoints.dart';
import 'package:flutter/material.dart';

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

/// Switches a component between two named layouts at a local-width boundary.
///
/// Unlike [ResponsiveBuilder], this contract is for a component whose own
/// composition changes at a domain-specific breakpoint. Keeping the local
/// measurement here gives feature widgets a declarative compact/expanded API
/// and one consistent boundary rule.
class ComponentResponsiveBuilder extends StatelessWidget {
  const ComponentResponsiveBuilder({
    super.key,
    required this.breakpoint,
    required this.compact,
    required this.expanded,
  });

  final double breakpoint;
  final WidgetBuilder compact;
  final WidgetBuilder expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < breakpoint
          ? compact(context)
          : expanded(context),
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

/// Immutable shell geometry supplied to sliver features.
class SliverViewportLayout {
  const SliverViewportLayout({required this.width, required this.screenSize});

  final double width;
  final ScreenSize screenSize;
}

typedef SliverViewportWidgetBuilder =
    Widget Function(BuildContext context, SliverViewportLayout viewport);

/// Supplies cross-axis viewport geometry to a sliver without features reading
/// global window metrics.
class ResponsiveSliverBuilder extends StatelessWidget {
  const ResponsiveSliverBuilder({super.key, required this.builder});

  final SliverViewportWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        return builder(
          context,
          SliverViewportLayout(
            width: width,
            screenSize: ScreenSize.fromWidth(width),
          ),
        );
      },
    );
  }
}
