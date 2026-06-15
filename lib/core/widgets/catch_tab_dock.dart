import 'dart:ui';

import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class CatchTabDockItem<T> {
  const CatchTabDockItem({
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

/// Handoff `TabDock`: bottom navigation dock with blur surface, hairline top
/// rule, filled active glyph, and uppercase mono labels.
class CatchTabDock<T> extends StatelessWidget {
  const CatchTabDock({
    super.key,
    required this.items,
    required this.active,
    this.onChanged,
    this.radius = BorderRadius.zero,
  });

  final List<CatchTabDockItem<T>> items;
  final T active;
  final ValueChanged<T>? onChanged;
  final BorderRadiusGeometry radius;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: CatchLayout.tabDockBlurSigma,
          sigmaY: CatchLayout.tabDockBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface.withValues(alpha: CatchOpacity.tabDockFill),
            border: Border(top: BorderSide(color: t.line)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchLayout.tabDockHorizontalPadding,
                CatchLayout.tabDockTopPadding,
                CatchLayout.tabDockHorizontalPadding,
                CatchLayout.tabDockBottomPadding,
              ),
              child: Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: _CatchTabDockItem(
                        item: item,
                        selected: item.id == active,
                        onTap: onChanged == null
                            ? null
                            : () => onChanged!(item.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CatchTabDockItem<T> extends StatelessWidget {
  const _CatchTabDockItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final CatchTabDockItem<T> item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = selected ? t.ink : t.ink3;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CatchRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TabDockIcon(
                  icon: selected ? item.activeIcon ?? item.icon : item.icon,
                  color: color,
                  badgeCount: item.badgeCount,
                ),
                const SizedBox(height: CatchLayout.tabDockItemGap),
                Text(
                  item.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.monoLabel(
                    context,
                    color: color,
                  ).copyWith(fontSize: CatchLayout.tabDockLabelFontSize),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabDockIcon extends StatelessWidget {
  const _TabDockIcon({
    required this.icon,
    required this.color,
    required this.badgeCount,
  });

  final IconData icon;
  final Color color;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(icon, size: CatchLayout.tabDockIconSize, color: color);
    if (badgeCount <= 0) return glyph;

    final t = CatchTokens.of(context);
    final label = badgeCount > 99 ? '99+' : '$badgeCount';

    return SizedBox(
      width: CatchLayout.appShellNavigationBadgeWidth,
      height: CatchLayout.appShellNavigationBadgeHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(alignment: Alignment.bottomCenter, child: glyph),
          Positioned(
            top: 0,
            right: 1,
            child: CatchSurface(
              radius: CatchRadius.pill,
              backgroundColor: t.primary,
              borderColor: t.surface,
              borderWidth: 1.5,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CatchSpacing.s1,
                    vertical: CatchStroke.hairline,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: CatchTextStyles.statusLabel(
                        context,
                        color: t.primaryInk,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
