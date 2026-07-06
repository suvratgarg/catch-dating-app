import 'package:flutter/material.dart';

const appShellHomeTabIndex = 0;
const appShellClubsTabIndex = 1;
const appShellChatsTabIndex = 2;
const appShellProfileTabIndex = 3;

class AppShellActiveTab extends InheritedWidget {
  const AppShellActiveTab({
    super.key,
    required this.index,
    required super.child,
  });

  final int index;

  static int? maybeIndexOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppShellActiveTab>()
        ?.index;
  }

  @override
  bool updateShouldNotify(AppShellActiveTab oldWidget) =>
      index != oldWidget.index;
}

bool isAppShellTabActive(BuildContext context, int index) {
  final activeIndex = AppShellActiveTab.maybeIndexOf(context);
  return activeIndex == null || activeIndex == index;
}
