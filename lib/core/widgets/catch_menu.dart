import 'dart:math' as math;

import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchMenuItemRole { action, choice }

typedef CatchMenuAnchorBuilder =
    Widget Function(
      BuildContext context,
      MenuController controller,
      Widget? child,
    );

class CatchMenuItem<T> {
  const CatchMenuItem({
    required this.value,
    required this.label,
    this.sublabel,
    this.icon,
    this.selected = false,
    this.danger = false,
    this.enabled = true,
    this.role = CatchMenuItemRole.action,
    this.startsSection = false,
    this.onSelected,
  }) : assert(
         !selected || role == CatchMenuItemRole.choice,
         'Only choice rows can be selected.',
       );

  final T value;
  final String label;
  final String? sublabel;
  final IconData? icon;
  final bool selected;
  final bool danger;
  final bool enabled;
  final CatchMenuItemRole role;
  final bool startsSection;
  final ValueChanged<T>? onSelected;
}

/// Anchors a Catch menu and matches its panel to the local trigger lane.
class CatchMenuAnchor<T> extends StatefulWidget {
  const CatchMenuAnchor({
    super.key,
    required this.items,
    required this.builder,
    this.controller,
    this.onSelected,
    this.width,
    this.alignmentOffset = Offset.zero,
  });

  final List<CatchMenuItem<T>> items;
  final CatchMenuAnchorBuilder builder;
  final MenuController? controller;
  final void Function(T value, CatchMenuItem<T> item)? onSelected;
  final double? width;
  final Offset alignmentOffset;

  @override
  State<CatchMenuAnchor<T>> createState() => _CatchMenuAnchorState<T>();
}

class _CatchMenuAnchorState<T> extends State<CatchMenuAnchor<T>> {
  final _anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final viewport = CatchMenuViewport.from(context);
    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        controller: widget.controller,
        alignmentOffset: widget.alignmentOffset,
        style: _catchMenuAnchorStyle,
        menuChildren: [
          Builder(
            builder: (context) {
              final boundary = viewport.boundaryFor(_anchorKey);
              return Padding(
                // The shell clearance is deliberately placed on the side
                // away from the actual menu. It participates in Material's
                // flip calculation while the visible menu stays flush with
                // its trigger on the chosen side.
                padding: boundary.padding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: boundary.maxHeight > 0
                        ? boundary.maxHeight
                        : double.infinity,
                  ),
                  child: CatchMenu<T>(
                    width:
                        widget.width ??
                        (constraints.hasBoundedWidth
                            ? constraints.maxWidth
                            : null),
                    items: widget.items,
                    onSelected: widget.onSelected,
                  ),
                ),
              );
            },
          ),
        ],
        builder: (context, controller, child) => KeyedSubtree(
          key: _anchorKey,
          child: widget.builder(context, controller, child),
        ),
      ),
    );
  }
}

/// The physical viewport available to an anchored Catch menu.
@immutable
class CatchMenuViewport {
  const CatchMenuViewport({
    required this.usableRect,
    required this.overlayBottomClearance,
  });

  factory CatchMenuViewport.from(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shellBottom = AppShellActiveTab.bottomOverlayInsetOf(context);
    final physicalBottom = math.max(mediaQuery.padding.bottom, shellBottom);
    final inset = CatchLayout.menuViewportInset;
    final left = mediaQuery.padding.left + inset;
    final top = mediaQuery.padding.top + inset;
    final right = math.max(
      left,
      mediaQuery.size.width - mediaQuery.padding.right - inset,
    );
    final bottom = math.max(
      top,
      mediaQuery.size.height - physicalBottom - inset,
    );
    return CatchMenuViewport(
      usableRect: Rect.fromLTRB(left, top, right, bottom),
      // Flutter's overlay already understands the platform safe area. Add
      // only the remaining shell obstruction plus Catch's viewport inset.
      overlayBottomClearance:
          math.max(0, physicalBottom - mediaQuery.padding.bottom) + inset,
    );
  }

  final Rect usableRect;
  final double overlayBottomClearance;

  /// Resolves the physical boundary for a menu anchored in an overlay.
  ///
  /// Material's menu overlay is owned by the navigator and therefore cannot
  /// see shell-local inherited padding. This measures the anchor against the
  /// shell-aware usable rectangle and caps the menu to the larger of the spaces
  /// above and below it. Material can then place the menu on the viable side,
  /// while the menu's own scroll view handles overflow without entering the
  /// floating navigation region.
  ({EdgeInsets padding, double maxHeight}) boundaryFor(GlobalKey anchorKey) {
    final anchorBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final anchorRect = anchorBox == null || !anchorBox.hasSize
        ? null
        : anchorBox.localToGlobal(Offset.zero) & anchorBox.size;
    final spaceAbove = anchorRect == null
        ? usableRect.height
        : math.max(0.0, anchorRect.top - usableRect.top);
    final spaceBelow = anchorRect == null
        ? usableRect.height
        : math.max(0.0, usableRect.bottom - anchorRect.bottom);
    final placeAbove = spaceAbove > spaceBelow;
    final maxHeight = placeAbove
        ? math.max(0.0, spaceAbove - overlayBottomClearance)
        : spaceBelow;
    return (
      padding: EdgeInsets.only(
        top: placeAbove ? overlayBottomClearance : 0,
        bottom: placeAbove ? 0 : overlayBottomClearance,
      ),
      maxHeight: maxHeight,
    );
  }
}

const _catchMenuAnchorStyle = MenuStyle(
  backgroundColor: WidgetStatePropertyAll(Colors.transparent),
  elevation: WidgetStatePropertyAll(0),
  shadowColor: WidgetStatePropertyAll(Colors.transparent),
  surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
  padding: WidgetStatePropertyAll(EdgeInsets.zero),
);

/// Handoff `Menu`: anchored surface panel of selectable rows.
class CatchMenu<T> extends StatelessWidget {
  const CatchMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.width,
  });

  final List<CatchMenuItem<T>> items;
  final void Function(T value, CatchMenuItem<T> item)? onSelected;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewportHeight = math.max(
      0.0,
      mediaQuery.size.height - mediaQuery.padding.vertical,
    );
    final maxHeight = CatchLayout.menuMaxHeightFor(viewportHeight);

    return CatchSurface(
      elevation: CatchSurfaceElevation.overlay,
      radius: CatchRadius.md,
      borderRole: CatchBorderRole.boundary,
      padding: EdgeInsets.zero,
      width: width,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final indexed in items.indexed) ...[
                if (indexed.$1 > 0 && indexed.$2.startsSection)
                  const CatchDivider.fieldRow(indent: 0),
                CatchMenuRow<T>(item: indexed.$2, onSelected: onSelected),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CatchMenuRow<T> extends StatelessWidget {
  const CatchMenuRow({super.key, required this.item, required this.onSelected});

  final CatchMenuItem<T> item;
  final void Function(T value, CatchMenuItem<T> item)? onSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = _menuItemColor(t, item);
    final onTap = item.enabled
        ? () {
            item.onSelected?.call(item.value);
            onSelected?.call(item.value, item);
          }
        : null;

    return Semantics(
      button: item.role == CatchMenuItemRole.action,
      enabled: item.enabled,
      selected: item.selected,
      inMutuallyExclusiveGroup: item.role == CatchMenuItemRole.choice,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: CatchLayout.menuRowMinHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CatchSpacing.micro14,
                vertical: CatchLayout.menuRowVerticalPadding,
              ),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: CatchLayout.menuRowIconSize,
                      color: item.danger ? t.danger : t.ink2,
                    ),
                    const SizedBox(width: CatchLayout.menuRowGap),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.labelL(context, color: color),
                        ),
                        if (item.sublabel != null &&
                            item.sublabel!.trim().isNotEmpty) ...[
                          const SizedBox(height: CatchSpacing.micro2),
                          Text(
                            item.sublabel!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.menuSupporting(
                              context,
                              color: t.ink3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (item.selected) ...[
                    const SizedBox(width: CatchLayout.menuRowGap),
                    Icon(
                      CatchIcons.check,
                      size: CatchLayout.menuRowCheckSize,
                      color: t.ink,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _menuItemColor<T>(CatchTokens t, CatchMenuItem<T> item) {
  if (!item.enabled) return t.ink3;
  if (item.danger) return t.danger;
  return t.ink;
}
