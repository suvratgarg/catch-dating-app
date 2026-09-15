import 'package:flutter/widgets.dart';

/// Internal boundary published only by page and pane owners. A section may
/// inset its content, but cannot quietly shrink the row interaction perimeter.
class CatchRowViewport extends StatelessWidget {
  const CatchRowViewport({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) =>
        _RowViewportExtent(width: constraints.maxWidth, child: child),
  );

  static bool matches(BuildContext context, double width) {
    final viewport = context
        .dependOnInheritedWidgetOfExactType<_RowViewportExtent>();
    return viewport == null || (viewport.width - width).abs() < 0.5;
  }
}

class _RowViewportExtent extends InheritedWidget {
  const _RowViewportExtent({required this.width, required super.child});
  final double width;
  @override
  bool updateShouldNotify(_RowViewportExtent oldWidget) =>
      width != oldWidget.width;
}
