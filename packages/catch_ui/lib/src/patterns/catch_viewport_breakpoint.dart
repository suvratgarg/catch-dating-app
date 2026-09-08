import 'package:catch_ui/src/patterns/catch_viewport.dart';
import 'package:flutter/material.dart';

/// Switches a component between two named layouts at a local-width boundary.
///
/// Unlike [CatchViewport], this contract is for a component whose own
/// composition changes at a domain-specific breakpoint. Keeping the local
/// measurement here gives feature widgets a declarative compact/expanded API
/// and one consistent boundary rule.
class CatchViewportBreakpoint extends StatelessWidget {
  const CatchViewportBreakpoint({
    super.key,
    required this.breakpoint,
    required this.compactBuilder,
    required this.expandedBuilder,
  });

  final double breakpoint;
  final WidgetBuilder compactBuilder;
  final WidgetBuilder expandedBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < breakpoint
          ? compactBuilder(context)
          : expandedBuilder(context),
    );
  }
}
