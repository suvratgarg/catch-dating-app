import 'package:flutter/widgets.dart';

/// Internal chrome boundary: generic body controls must not restyle app bars.
class CatchToolbarScope extends InheritedWidget {
  const CatchToolbarScope({super.key, required super.child})
    : selectorReflow = false;

  const CatchToolbarScope.selectorRow({super.key, required super.child})
    : selectorReflow = true;

  final bool selectorReflow;

  static bool selectorReflowOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchToolbarScope>()
          ?.selectorReflow ??
      false;

  static bool contains(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CatchToolbarScope>() != null;

  @override
  bool updateShouldNotify(CatchToolbarScope oldWidget) =>
      oldWidget.selectorReflow != selectorReflow;
}
