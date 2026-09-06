import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

const appShellHomeTabIndex = 0;
const appShellClubsTabIndex = 1;
const appShellChatsTabIndex = 2;
const appShellProfileTabIndex = 3;

bool isAppShellTabActive(BuildContext context, int index) {
  final activeIndex = CatchTabViewportScope.maybeIndexOf(context);
  return activeIndex == null || activeIndex == index;
}
