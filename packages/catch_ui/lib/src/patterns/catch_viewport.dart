import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Builds different layouts based on the current screen size.
///
/// Thin wrapper around [LayoutBuilder] that maps the available width to a
/// [CatchWindowSize] and calls the appropriate builder. Uses a default builder
/// for compact screens and optional overrides for medium/expanded.
///
/// Example:
/// ```dart
/// CatchViewport(
///   compactBuilder: (context) => _PhoneLayout(),
///   mediumBuilder: (context) => _TabletLayout(),
///   expandedBuilder: (context) => _DesktopLayout(),
/// )
/// ```
///
/// If only [compactBuilder] is provided, all screen sizes use it (graceful
/// degradation — no tablet-specific layout is required).
class CatchViewport extends StatelessWidget {
  const CatchViewport({
    super.key,
    required this.compactBuilder,
    this.mediumBuilder,
    this.expandedBuilder,
  });

  /// Builder for compact screens (< 600 dp wide — phones).
  final WidgetBuilder compactBuilder;

  /// Optional builder for medium screens (600–839 dp — tablets / foldables).
  /// Falls back to [compactBuilder] when null.
  final WidgetBuilder? mediumBuilder;

  /// Optional builder for expanded screens (≥ 840 dp — large tablets /
  /// desktop). Falls back to [mediumBuilder] then [compactBuilder] when null.
  final WidgetBuilder? expandedBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = CatchWindowSize.fromWidth(constraints.maxWidth);
        return switch (size) {
          CatchWindowSize.compact => compactBuilder(context),
          CatchWindowSize.medium => (mediumBuilder ?? compactBuilder)(context),
          CatchWindowSize.expanded =>
            (expandedBuilder ?? mediumBuilder ?? compactBuilder)(context),
        };
      },
    );
  }
}
