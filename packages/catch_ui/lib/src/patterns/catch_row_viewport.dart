import 'package:flutter/widgets.dart';

/// Internal boundary published only by page and pane owners. A section may
/// inset its content, but cannot quietly shrink the row interaction perimeter.
class CatchRowViewport extends StatelessWidget {
  const CatchRowViewport({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) =>
        CatchRowViewportScope(width: constraints.maxWidth, child: child),
  );

  /// Null means no page/pane owner proved the perimeter. Renderers must use
  /// rounded containment in that case; absence cannot authorize square paint.
  static bool? matches(BuildContext context, double width) {
    final viewport = context
        .dependOnInheritedWidgetOfExactType<CatchRowViewportScope>();
    return viewport == null ? null : (viewport.width - width).abs() < 0.5;
  }
}

class CatchRowViewportScope extends InheritedWidget {
  const CatchRowViewportScope({
    super.key,
    required this.width,
    required super.child,
  });
  final double width;
  @override
  bool updateShouldNotify(CatchRowViewportScope oldWidget) =>
      width != oldWidget.width;
}
