import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/presentation/app_shell_keys.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_bar.dart';
import 'package:flutter/material.dart';

/// Shared adaptive placement contract for consumer and host tab shells.
///
/// Floating tab chrome overlays the body and publishes its raw physical
/// obstruction to root scroll owners. Anchored chrome is assigned to
/// [Scaffold.bottomNavigationBar], while a transient shell with no bottom
/// chrome leaves device-safe terminal clearance to [AppShellActiveTab].
class CatchAdaptiveTabScaffold extends StatelessWidget {
  const CatchAdaptiveTabScaffold({
    super.key,
    required this.activeIndex,
    required this.body,
    this.navigationBar,
    this.anchoredFallback,
  });

  final int activeIndex;
  final Widget body;
  final Widget? navigationBar;
  final Widget? anchoredFallback;

  @override
  Widget build(BuildContext context) {
    final navigationBar = this.navigationBar;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final candidateTabBarFloats =
        navigationBar != null && CatchTabBar.floatsFor(context);
    final tabBarFloats = candidateTabBarFloats && !keyboardVisible;
    final anchoredBar = keyboardVisible || candidateTabBarFloats
        ? null
        : navigationBar ?? anchoredFallback;
    final placement = tabBarFloats
        ? AppShellBottomBarPlacement.floating
        : anchoredBar != null
        ? AppShellBottomBarPlacement.anchored
        : AppShellBottomBarPlacement.none;
    final bottomOverlayInset = tabBarFloats
        ? CatchTabBar.reservedBottomInset(context)
        : 0.0;
    final scopedBody = AppShellActiveTab(
      index: activeIndex,
      bottomOverlayInset: bottomOverlayInset,
      bottomBarPlacement: placement,
      child: body,
    );

    return Scaffold(
      key: AppShellKeys.scaffold,
      extendBody: tabBarFloats,
      body: candidateTabBarFloats
          ? Stack(
              children: [
                Positioned.fill(child: scopedBody),
                if (tabBarFloats)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: navigationBar,
                  ),
              ],
            )
          : scopedBody,
      bottomNavigationBar: anchoredBar,
    );
  }
}
