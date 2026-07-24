import 'dart:ui';

import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_count_badge.dart';
import 'package:flutter/material.dart';

class CatchTabBarItem<T> {
  const CatchTabBarItem({
    required this.id,
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badgeCount = 0,
  });

  final T id;
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int badgeCount;
}

/// Bottom navigation with shared Catch selection behavior and platform-adaptive
/// chrome.
class CatchTabBar<T> extends StatelessWidget {
  const CatchTabBar({
    super.key,
    required this.items,
    required this.active,
    this.onChanged,
  });

  final List<CatchTabBarItem<T>> items;
  final T active;
  final ValueChanged<T>? onChanged;

  static bool floatsFor(BuildContext context) =>
      prefersCupertinoControls(platform: Theme.of(context).platform);

  static double reservedBottomInset(BuildContext context) {
    if (!floatsFor(context)) return 0;
    final bottom = MediaQuery.maybeOf(context)?.padding.bottom ?? 0;
    return CatchLayout.tabBarReservedBottomInset(bottom);
  }

  @override
  Widget build(BuildContext context) {
    final isFloating = floatsFor(context);
    final t = CatchTokens.of(context);
    final row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isFloating
            ? CatchLayout.tabBarFloatingContentHorizontalPadding
            : CatchLayout.tabBarHorizontalPadding,
      ),
      child: Row(
        mainAxisAlignment: isFloating
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.spaceAround,
        children: [
          for (final item in items)
            Expanded(
              flex: item.id == active ? 2 : 1,
              child: CatchTabBarButton<T>(
                item: item,
                selected: item.id == active,
                materialInk: !isFloating,
                onTap: onChanged == null ? null : () => onChanged!(item.id),
              ),
            ),
        ],
      ),
    );

    if (!isFloating) {
      return DecoratedBox(
        key: const ValueKey('catch_tab_bar.anchored_chrome'),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border(top: BorderSide(color: t.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: CatchLayout.tabBarExtent,
            child: Material(color: Colors.transparent, child: row),
          ),
        ),
      );
    }

    final floatingChromeRadius = BorderRadius.circular(CatchRadius.pill);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        CatchLayout.tabBarFloatingHorizontalInset,
        0,
        CatchLayout.tabBarFloatingHorizontalInset,
        CatchLayout.tabBarFloatingBottomInset,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          key: const ValueKey('catch_tab_bar.floating_chrome'),
          borderRadius: floatingChromeRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: CatchLayout.tabBarBlurSigma,
              sigmaY: CatchLayout.tabBarBlurSigma,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.surface.withValues(
                  alpha: CatchOpacity.tabBarGlassFill,
                ),
                border: Border.all(color: t.line),
                borderRadius: floatingChromeRadius,
              ),
              child: SizedBox(height: CatchLayout.tabBarExtent, child: row),
            ),
          ),
        ),
      ),
    );
  }
}

class CatchTabBarButton<T> extends StatelessWidget {
  const CatchTabBarButton({
    super.key,
    required this.item,
    required this.selected,
    this.materialInk = true,
    this.onTap,
  });

  final CatchTabBarItem<T> item;
  final bool selected;
  final bool materialInk;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabledAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    final duration = disabledAnimations == true
        ? Duration.zero
        : CatchMotion.standard;
    final t = CatchTokens.of(context);
    final color = selected ? t.ink : t.ink3;
    final icon = CatchTabBarIcon(
      icon: selected ? item.activeIcon ?? item.icon : item.icon,
      color: color,
      badgeCount: item.badgeCount,
    );
    final content = AnimatedSize(
      duration: duration,
      curve: CatchMotion.standardCurve,
      alignment: Alignment.centerLeft,
      child: AnimatedContainer(
        duration: duration,
        curve: CatchMotion.standardCurve,
        constraints: const BoxConstraints(
          minWidth: CatchLayout.tabBarCompactItemExtent,
          minHeight: CatchLayout.tabBarPillMinHeight,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: selected
              ? CatchLayout.tabBarPillHorizontalPadding
              : CatchSpacing.s2,
        ),
        decoration: ShapeDecoration(
          color: selected
              ? t.ink.withValues(alpha: CatchOpacity.tabBarPillFill)
              : Colors.transparent,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            Flexible(
              child: ClipRect(
                child: AnimatedSwitcher(
                  duration: duration,
                  switchInCurve: CatchMotion.standardCurve,
                  switchOutCurve: CatchMotion.easeInCubicCurve,
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(-0.08, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: selected
                      ? ExcludeSemantics(
                          key: ValueKey('catch_tab_bar.label.${item.label}'),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: CatchLayout.tabBarLabelGap,
                            ),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: CatchTextStyles.buttonSm(
                                context,
                                color: t.ink,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('catch_tab_bar.label.hidden'),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: SizedBox(
        height: CatchLayout.tabBarExtent,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap == null
                  ? null
                  : () {
                      catchSelectionHaptic();
                      onTap!();
                    },
              customBorder: const StadiumBorder(),
              splashFactory: materialInk
                  ? InkRipple.splashFactory
                  : NoSplash.splashFactory,
              highlightColor: materialInk
                  ? null
                  : t.ink.withValues(alpha: CatchOpacity.none),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class CatchTabBarIcon extends StatelessWidget {
  const CatchTabBarIcon({
    super.key,
    required this.icon,
    required this.color,
    this.badgeCount = 0,
  });

  final IconData icon;
  final Color color;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(icon, size: CatchLayout.tabBarIconSize, color: color);
    return SizedBox(
      width: CatchLayout.appShellNavigationBadgeWidth,
      height: CatchLayout.appShellNavigationBadgeHeight,
      child: CatchCountBadge(
        count: badgeCount,
        offset: const Offset(-1, 2),
        child: Align(alignment: Alignment.bottomCenter, child: glyph),
      ),
    );
  }
}
