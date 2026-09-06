import 'dart:math' as math;

import 'package:flutter/material.dart';

enum CatchTabViewportScopePlacement { none, anchored, floating }

/// Route-neutral active-page and bottom-obstruction metrics for shared layouts.
class CatchTabViewportScope extends InheritedWidget {
  const CatchTabViewportScope({
    super.key,
    required this.index,
    this.bottomOverlayInset = 0,
    this.bottomBarPlacement = CatchTabViewportScopePlacement.none,
    required super.child,
  });

  final int index;
  final double bottomOverlayInset;
  final CatchTabViewportScopePlacement bottomBarPlacement;

  static int? maybeIndexOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CatchTabViewportScope>()
        ?.index;
  }

  static double bottomOverlayInsetOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<CatchTabViewportScope>()
            ?.bottomOverlayInset ??
        0;
  }

  static double bottomOverlayClearanceOf(
    BuildContext context, {
    double minimum = 0,
  }) {
    final overlayInset = bottomOverlayInsetOf(context);
    final safeBottomInset = MediaQuery.paddingOf(context).bottom;
    return minimum + math.max(0, overlayInset - safeBottomInset);
  }

  /// Bottom clearance for content that terminates inside a root scroll view.
  ///
  /// A floating shell publishes its complete physical obstruction, including
  /// the device safe area, through [bottomOverlayInset]. Anchored shell chrome
  /// already reduces the body viewport and therefore publishes zero. Outside a
  /// shell, or while a shell has no bottom chrome, the scroll owner must
  /// preserve the device safe area itself.
  static double scrollTerminalClearanceOf(
    BuildContext context, {
    double extra = 0,
  }) {
    final activeTab = context
        .dependOnInheritedWidgetOfExactType<CatchTabViewportScope>();
    if (activeTab != null) {
      switch (activeTab.bottomBarPlacement) {
        case CatchTabViewportScopePlacement.floating:
          return activeTab.bottomOverlayInset + extra;
        case CatchTabViewportScopePlacement.anchored:
          return extra;
        case CatchTabViewportScopePlacement.none:
          break;
      }
    }

    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return extra;

    final safeBottomInset = math.max(
      mediaQuery.padding.bottom,
      mediaQuery.viewPadding.bottom,
    );
    return safeBottomInset + extra;
  }

  @override
  bool updateShouldNotify(CatchTabViewportScope oldWidget) =>
      index != oldWidget.index ||
      bottomOverlayInset != oldWidget.bottomOverlayInset ||
      bottomBarPlacement != oldWidget.bottomBarPlacement;
}
