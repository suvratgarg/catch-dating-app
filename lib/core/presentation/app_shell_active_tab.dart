import 'dart:math' as math;

import 'package:flutter/material.dart';

const appShellHomeTabIndex = 0;
const appShellClubsTabIndex = 1;
const appShellChatsTabIndex = 2;
const appShellProfileTabIndex = 3;

enum AppShellBottomBarPlacement { none, anchored, floating }

class AppShellActiveTab extends InheritedWidget {
  const AppShellActiveTab({
    super.key,
    required this.index,
    this.bottomOverlayInset = 0,
    this.bottomBarPlacement = AppShellBottomBarPlacement.none,
    required super.child,
  });

  final int index;
  final double bottomOverlayInset;
  final AppShellBottomBarPlacement bottomBarPlacement;

  static int? maybeIndexOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppShellActiveTab>()
        ?.index;
  }

  static double bottomOverlayInsetOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppShellActiveTab>()
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
        .dependOnInheritedWidgetOfExactType<AppShellActiveTab>();
    if (activeTab != null) {
      switch (activeTab.bottomBarPlacement) {
        case AppShellBottomBarPlacement.floating:
          return activeTab.bottomOverlayInset + extra;
        case AppShellBottomBarPlacement.anchored:
          return extra;
        case AppShellBottomBarPlacement.none:
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
  bool updateShouldNotify(AppShellActiveTab oldWidget) =>
      index != oldWidget.index ||
      bottomOverlayInset != oldWidget.bottomOverlayInset ||
      bottomBarPlacement != oldWidget.bottomBarPlacement;
}

bool isAppShellTabActive(BuildContext context, int index) {
  final activeIndex = AppShellActiveTab.maybeIndexOf(context);
  return activeIndex == null || activeIndex == index;
}
