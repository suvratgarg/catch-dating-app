import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/widgets.dart';

/// One geometry contract for navigation, selectors and collapsed search.
abstract final class CatchToolbarMetrics {
  static const double visualExtent = CatchLayout.iconButtonNavSize;
  static const double gap = CatchSpacing.s2;
  static double get targetExtent =>
      math.max(visualExtent, CatchPlatformTokens.minimumInteractiveExtent);
}

/// Selectors publish their real size so app-bar title measurement matches paint.
abstract interface class CatchToolbarLeading {
  Size toolbarSizeFor(BuildContext context);
}

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
