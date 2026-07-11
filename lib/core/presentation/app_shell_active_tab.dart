import 'dart:math' as math;

import 'package:flutter/material.dart';

const appShellHomeTabIndex = 0;
const appShellClubsTabIndex = 1;
const appShellChatsTabIndex = 2;
const appShellProfileTabIndex = 3;

class AppShellActiveTab extends InheritedWidget {
  const AppShellActiveTab({
    super.key,
    required this.index,
    this.bottomOverlayInset = 0,
    required super.child,
  });

  final int index;
  final double bottomOverlayInset;

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

  @override
  bool updateShouldNotify(AppShellActiveTab oldWidget) =>
      index != oldWidget.index ||
      bottomOverlayInset != oldWidget.bottomOverlayInset;
}

bool isAppShellTabActive(BuildContext context, int index) {
  final activeIndex = AppShellActiveTab.maybeIndexOf(context);
  return activeIndex == null || activeIndex == index;
}
