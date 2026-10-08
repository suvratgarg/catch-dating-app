import 'package:flutter/widgets.dart';

/// The route owns Back; pane chrome consumes it without a second Navigator.
class CatchWorkspaceBackScope extends InheritedWidget {
  const CatchWorkspaceBackScope({
    super.key,
    required this.onBack,
    required super.child,
  });
  final VoidCallback onBack;
  static VoidCallback? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CatchWorkspaceBackScope>()
      ?.onBack;
  @override
  bool updateShouldNotify(CatchWorkspaceBackScope oldWidget) =>
      onBack != oldWidget.onBack;
}
