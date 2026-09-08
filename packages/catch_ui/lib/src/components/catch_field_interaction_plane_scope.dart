import 'package:flutter/widgets.dart';

/// Internal page/lane paint extent published by semantic body primitives.
///
/// The resolved values are the horizontal distance from padded content to the
/// interaction plane. Nested page-body primitives accumulate their insets, so
/// a field never reads viewport size or subtracts `screenPx` itself.
class CatchFieldInteractionPlaneScope extends InheritedWidget {
  const CatchFieldInteractionPlaneScope({
    super.key,
    required this.outsets,
    required super.child,
  });

  final EdgeInsets outsets;

  static EdgeInsets outsetsOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchFieldInteractionPlaneScope>()
          ?.outsets ??
      EdgeInsets.zero;

  @override
  bool updateShouldNotify(CatchFieldInteractionPlaneScope oldWidget) =>
      outsets != oldWidget.outsets;
}
