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
    this.iconWidget,
    this.activeIconWidget,
    this.badgeCount = 0,
    this.onLongPress,
    this.semanticValue,
    this.semanticHint,
  });

  final T id;
  final IconData icon;
  final IconData? activeIcon;
  final Widget? iconWidget;
  final Widget? activeIconWidget;
  final String label;
  final int badgeCount;
  final VoidCallback? onLongPress;
  final String? semanticValue;
  final String? semanticHint;
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
    final disabledAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    final duration = disabledAnimations == true
        ? Duration.zero
        : CatchMotion.standard;
    final activeIndex = items.indexWhere((item) => item.id == active);
    final resolvedActiveIndex = activeIndex < 0 ? 0 : activeIndex;
    final navigation = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isFloating
            ? CatchLayout.tabBarFloatingContentHorizontalPadding
            : CatchLayout.tabBarHorizontalPadding,
      ),
      child: items.isEmpty
          ? const SizedBox.shrink()
          : LayoutBuilder(
              builder: (context, constraints) {
                final selectedExtent = _selectedExtent(
                  context,
                  constraints.maxWidth,
                  items[resolvedActiveIndex].label,
                );
                final compactExtent = items.length == 1
                    ? 0.0
                    : (constraints.maxWidth - selectedExtent) /
                          (items.length - 1);
                var start = 0.0;
                final positions = <({double start, double width})>[];
                for (var index = 0; index < items.length; index++) {
                  final width = index == resolvedActiveIndex
                      ? selectedExtent
                      : compactExtent;
                  positions.add((start: start, width: width));
                  start += width;
                }

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    for (var index = 0; index < items.length; index++)
                      AnimatedPositionedDirectional(
                        key: ValueKey<Object>(
                          'catch_tab_bar.slot.${items[index].id}',
                        ),
                        duration: duration,
                        curve: CatchMotion.standardCurve,
                        start: positions[index].start,
                        top: 0,
                        bottom: 0,
                        width: positions[index].width,
                        child: CatchTabBarButton<T>(
                          item: items[index],
                          selected: index == resolvedActiveIndex,
                          materialInk: !isFloating,
                          onTap: onChanged == null
                              ? null
                              : () => onChanged!(items[index].id),
                        ),
                      ),
                  ],
                );
              },
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
            child: Material(color: Colors.transparent, child: navigation),
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
              child: SizedBox(
                height: CatchLayout.tabBarExtent,
                child: navigation,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _selectedExtent(
    BuildContext context,
    double availableWidth,
    String label,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: CatchTextStyles.buttonSm(context)),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return CatchLayout.tabBarSelectedExtentFor(
      availableWidth: availableWidth,
      itemCount: items.length,
      labelWidth: painter.width,
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
      child: selected
          ? item.activeIconWidget ?? item.iconWidget
          : item.iconWidget,
    );
    final content = TweenAnimationBuilder<double>(
      key: ValueKey<Object>('catch_tab_bar.pill.${item.id}'),
      duration: duration,
      curve: CatchMotion.standardCurve,
      tween: Tween<double>(end: selected ? 1 : 0),
      builder: (context, progress, child) => Container(
        constraints: const BoxConstraints(
          minWidth: CatchLayout.tabBarCompactItemExtent,
          minHeight: CatchLayout.tabBarPillMinHeight,
        ),
        padding: EdgeInsetsDirectional.only(
          start: CatchLayout.tabBarPillLeadingPadding * progress,
          end: CatchLayout.tabBarPillTrailingPadding * progress,
        ),
        decoration: ShapeDecoration(
          color: t.ink.withValues(
            alpha: CatchOpacity.tabBarPillFill * progress,
          ),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            if (progress > 0.001)
              Flexible(
                child: ClipRect(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: progress,
                    child: Opacity(
                      opacity: progress,
                      child: ExcludeSemantics(
                        key: ValueKey('catch_tab_bar.label.${item.label}'),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: CatchLayout.tabBarLabelGap,
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
                      ),
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
      value: item.semanticValue,
      hint: item.semanticHint,
      onLongPress: item.onLongPress,
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
              onLongPress: item.onLongPress,
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
    this.child,
  });

  final IconData icon;
  final Color color;
  final int badgeCount;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final glyph =
        child ?? Icon(icon, size: CatchLayout.tabBarIconSize, color: color);
    return SizedBox(
      width: CatchLayout.tabBarIconBoxExtent,
      height: CatchLayout.tabBarIconBoxExtent,
      child: CatchCountBadge(
        count: badgeCount,
        offset: const Offset(-1, 2),
        child: Align(child: glyph),
      ),
    );
  }
}
