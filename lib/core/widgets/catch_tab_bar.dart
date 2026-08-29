import 'dart:math' as math;
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

/// Bottom navigation with one shared selection/contact indicator, drag-to-
/// select behavior, and platform-adaptive chrome.
class CatchTabBar<T> extends StatefulWidget {
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
  State<CatchTabBar<T>> createState() => _CatchTabBarState<T>();
}

class _CatchTabBarState<T> extends State<CatchTabBar<T>> {
  int? _pressedIndex;
  int? _dragIndex;
  int? _hoveredIndex;
  int? _focusedIndex;
  bool _dragging = false;
  bool _dragProducedHaptic = false;

  int get _activeIndex {
    final index = widget.items.indexWhere((item) => item.id == widget.active);
    return index < 0 ? 0 : index;
  }

  bool get _enabled => widget.onChanged != null && widget.items.isNotEmpty;

  @override
  void didUpdateWidget(covariant CatchTabBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.items.length != widget.items.length) {
      _clearTransientState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFloating = CatchTabBar.floatsFor(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // Compact bottom navigation cannot guarantee both 48 px targets and
    // readable labels once the user's text scale reaches the large-text
    // layout. Keep every destination visible and preserve its semantic label;
    // the selected pill becomes icon-only until a side-navigation breakpoint
    // provides enough horizontal room for labels again.
    final compactDestinations = textScale >= 1.6;
    final t = CatchTokens.of(context);
    final disabledAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    final duration = disabledAnimations == true
        ? Duration.zero
        : CatchMotion.standard;
    final activeIndex = _activeIndex;
    final previewIndex = _dragging ? _dragIndex : _pressedIndex;
    final visualIndex = previewIndex ?? activeIndex;
    final navigation = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isFloating
            ? CatchLayout.tabBarContentHorizontalPaddingFor(textScale)
            : CatchLayout.tabBarHorizontalPadding,
      ),
      child: widget.items.isEmpty
          ? const SizedBox.shrink()
          : LayoutBuilder(
              builder: (context, constraints) {
                final geometry = _CatchTabBarGeometry.calculate(
                  context: context,
                  width: constraints.maxWidth,
                  items: widget.items,
                  activeIndex: activeIndex,
                  compact: compactDestinations,
                );
                final primaryRect = geometry.indicatorRectFor(
                  visualIndex,
                  expanded: visualIndex == activeIndex,
                );
                final secondaryIndex = previewIndex == null
                    ? _focusedIndex ?? _hoveredIndex
                    : null;
                final secondaryRect =
                    secondaryIndex == null || secondaryIndex == activeIndex
                    ? null
                    : geometry.indicatorRectFor(
                        secondaryIndex,
                        expanded: false,
                      );
                final primaryFocused = _focusedIndex == activeIndex;
                final primaryInteracted =
                    previewIndex != null || secondaryIndex == activeIndex;
                final primaryOpacity = previewIndex != null
                    ? CatchOpacity.tabBarPressedFill
                    : primaryInteracted
                    ? CatchOpacity.tabBarFocusFill
                    : CatchOpacity.tabBarPillFill;

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: _enabled
                      ? (details) => _handleDragStart(details, geometry)
                      : null,
                  onHorizontalDragUpdate: _enabled
                      ? (details) => _handleDragUpdate(details, geometry)
                      : null,
                  onHorizontalDragEnd: _enabled ? _handleDragEnd : null,
                  onHorizontalDragCancel: _enabled ? _handleDragCancel : null,
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      if (primaryRect != null)
                        AnimatedPositionedDirectional(
                          duration: duration,
                          curve: CatchMotion.standardCurve,
                          start: primaryRect.left,
                          top: primaryRect.top,
                          width: primaryRect.width,
                          height: primaryRect.height,
                          child: _CatchTabBarIndicator(
                            key: const ValueKey('catch_tab_bar.indicator'),
                            color: t.ink.withValues(alpha: primaryOpacity),
                            focused: primaryFocused,
                          ),
                        ),
                      if (secondaryRect != null)
                        AnimatedPositionedDirectional(
                          duration: duration,
                          curve: CatchMotion.standardCurve,
                          start: secondaryRect.left,
                          top: secondaryRect.top,
                          width: secondaryRect.width,
                          height: secondaryRect.height,
                          child: _CatchTabBarIndicator(
                            key: const ValueKey(
                              'catch_tab_bar.interaction_indicator',
                            ),
                            color: t.ink.withValues(
                              alpha: _focusedIndex == secondaryIndex
                                  ? CatchOpacity.tabBarFocusFill
                                  : CatchOpacity.tabBarHoverFill,
                            ),
                            focused: _focusedIndex == secondaryIndex,
                          ),
                        ),
                      for (final (index, item) in widget.items.indexed)
                        AnimatedPositionedDirectional(
                          key: ValueKey<Object>(
                            'catch_tab_bar.slot.${item.id}',
                          ),
                          duration: duration,
                          curve: CatchMotion.standardCurve,
                          start: geometry.itemRects[index].left,
                          top: 0,
                          width: geometry.itemRects[index].width,
                          height: CatchLayout.tabBarExtent,
                          child: CatchTabBarButton<T>(
                            key: ValueKey<Object>(
                              'catch_tab_bar.destination.${item.id}',
                            ),
                            item: item,
                            selected: index == visualIndex,
                            semanticSelected: index == activeIndex,
                            showSelectedLabel:
                                !compactDestinations &&
                                index == activeIndex &&
                                visualIndex == activeIndex,
                            ownsIndicator: false,
                            onTap: !_enabled ? null : () => _handleTap(index),
                            onTapDown: !_enabled
                                ? null
                                : (_) => _handlePressStart(index),
                            onTapCancel: !_enabled
                                ? null
                                : () => _handlePressCancel(index),
                            onHoverChanged: !_enabled
                                ? null
                                : (hovered) => _handleHover(index, hovered),
                            onFocusChanged: !_enabled
                                ? null
                                : (focused) => _handleFocus(index, focused),
                            onLongPress: item.onLongPress == null
                                ? null
                                : () => _handleLongPress(index),
                          ),
                        ),
                    ],
                  ),
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

    final floatingHorizontalInset =
        CatchLayout.tabBarFloatingHorizontalInsetFor(textScale);
    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(
        floatingHorizontalInset,
        0,
        floatingHorizontalInset,
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

  void _handlePressStart(int index) {
    if (!_enabled || _dragging) return;
    setState(() => _pressedIndex = index);
  }

  void _handlePressCancel(int index) {
    if (_dragging || _pressedIndex != index) return;
    setState(() => _pressedIndex = null);
  }

  void _handleTap(int index) {
    if (!_enabled) return;
    catchSelectionHaptic();
    widget.onChanged!(widget.items[index].id);
    if (mounted) setState(() => _pressedIndex = null);
  }

  void _handleLongPress(int index) {
    _clearTransientState(notify: true);
    widget.items[index].onLongPress?.call();
  }

  void _handleHover(int index, bool hovered) {
    if (!_enabled) return;
    if (hovered) {
      if (_hoveredIndex != index) setState(() => _hoveredIndex = index);
    } else if (_hoveredIndex == index) {
      setState(() => _hoveredIndex = null);
    }
  }

  void _handleFocus(int index, bool focused) {
    if (!_enabled) return;
    if (focused) {
      if (_focusedIndex != index) setState(() => _focusedIndex = index);
    } else if (_focusedIndex == index) {
      setState(() => _focusedIndex = null);
    }
  }

  void _handleDragStart(
    DragStartDetails details,
    _CatchTabBarGeometry geometry,
  ) {
    final index = geometry.indexForPosition(
      details.localPosition,
      currentIndex: _pressedIndex,
    );
    setState(() {
      _dragging = true;
      _dragIndex = index;
      _pressedIndex = null;
      _dragProducedHaptic = false;
    });
  }

  void _handleDragUpdate(
    DragUpdateDetails details,
    _CatchTabBarGeometry geometry,
  ) {
    final index = geometry.indexForPosition(
      details.localPosition,
      currentIndex: _dragIndex,
    );
    if (index == _dragIndex) return;
    setState(() => _dragIndex = index);
    if (index != null) {
      _dragProducedHaptic = true;
      catchSelectionHaptic();
    }
  }

  void _handleDragEnd(DragEndDetails _) {
    final index = _dragIndex;
    final needsCommitHaptic = !_dragProducedHaptic;
    setState(() {
      _dragging = false;
      _dragIndex = null;
      _pressedIndex = null;
      _dragProducedHaptic = false;
    });
    if (index == null || !_enabled) return;
    if (needsCommitHaptic) catchSelectionHaptic();
    widget.onChanged!(widget.items[index].id);
  }

  void _handleDragCancel() => _clearTransientState(notify: true);

  void _clearTransientState({bool notify = false}) {
    void clear() {
      _pressedIndex = null;
      _dragIndex = null;
      _dragging = false;
      _dragProducedHaptic = false;
    }

    if (notify && mounted) {
      setState(clear);
    } else {
      clear();
    }
  }
}

class _CatchTabBarIndicator extends StatelessWidget {
  const _CatchTabBarIndicator({
    super.key,
    required this.color,
    required this.focused,
  });

  final Color color;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final disabledAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    return AnimatedContainer(
      duration: disabledAnimations == true
          ? Duration.zero
          : CatchMotion.standard,
      curve: CatchMotion.standardCurve,
      decoration: ShapeDecoration(
        color: color,
        shape: StadiumBorder(
          side: focused
              ? CatchBorder.resolve(
                  CatchTokens.of(context),
                  CatchBorderRole.focus,
                ).side
              : BorderSide.none,
        ),
      ),
    );
  }
}

class _CatchTabBarGeometry {
  const _CatchTabBarGeometry({
    required this.width,
    required this.textDirection,
    required this.itemRects,
    required this.selectedIndicatorWidth,
  });

  final double width;
  final TextDirection textDirection;
  final List<Rect> itemRects;
  final double selectedIndicatorWidth;

  static _CatchTabBarGeometry calculate<T>({
    required BuildContext context,
    required double width,
    required List<CatchTabBarItem<T>> items,
    required int activeIndex,
    bool compact = false,
  }) {
    final textDirection = Directionality.of(context);
    if (items.isEmpty || !width.isFinite || width <= 0) {
      return _CatchTabBarGeometry(
        width: 0,
        textDirection: textDirection,
        itemRects: const <Rect>[],
        selectedIndicatorWidth: 0,
      );
    }

    final count = items.length;
    final minimumExtent = CatchLayout.tabBarMinimumTapExtent;
    if (compact || width < minimumExtent * count) {
      final itemWidth = width / count;
      return _CatchTabBarGeometry(
        width: width,
        textDirection: textDirection,
        itemRects: [
          for (var index = 0; index < count; index++)
            Rect.fromLTWH(
              itemWidth * index,
              0,
              itemWidth,
              CatchLayout.tabBarExtent,
            ),
        ],
        selectedIndicatorWidth: math.min(
          itemWidth,
          CatchLayout.tabBarCompactItemExtent,
        ),
      );
    }

    final resolvedActiveIndex = activeIndex.clamp(0, count - 1);
    final selectedItem = items[resolvedActiveIndex];
    final labelPainter = TextPainter(
      text: TextSpan(
        text: selectedItem.label,
        style: CatchTextStyles.buttonSm(context),
      ),
      maxLines: 1,
      textDirection: textDirection,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final selectedWidth = CatchLayout.tabBarSelectedExtentFor(
      availableWidth: width,
      itemCount: count,
      labelWidth: labelPainter.width,
    );
    final inactiveWidth = count == 1
        ? 0.0
        : (width - selectedWidth) / (count - 1);
    var start = 0.0;
    final rects = <Rect>[];
    for (var index = 0; index < count; index++) {
      final itemWidth = index == resolvedActiveIndex
          ? selectedWidth
          : inactiveWidth;
      rects.add(Rect.fromLTWH(start, 0, itemWidth, CatchLayout.tabBarExtent));
      start += itemWidth;
    }

    return _CatchTabBarGeometry(
      width: width,
      textDirection: textDirection,
      itemRects: rects,
      selectedIndicatorWidth: selectedWidth,
    );
  }

  Rect? indicatorRectFor(int index, {required bool expanded}) {
    if (index < 0 || index >= itemRects.length) return null;
    final itemRect = itemRects[index];
    final indicatorWidth = math.min(
      itemRect.width,
      expanded ? selectedIndicatorWidth : CatchLayout.tabBarCompactItemExtent,
    );
    return Rect.fromCenter(
      center: itemRect.center,
      width: indicatorWidth,
      height: CatchLayout.tabBarIndicatorExtent,
    );
  }

  int? indexForPosition(Offset position, {int? currentIndex}) {
    final logicalX = textDirection == TextDirection.ltr
        ? position.dx
        : width - position.dx;
    if (logicalX < 0 ||
        logicalX > width ||
        position.dy < -CatchLayout.tabBarDragCancelSlop ||
        position.dy > CatchLayout.tabBarDragBottomLimit) {
      return null;
    }
    if (currentIndex != null &&
        currentIndex >= 0 &&
        currentIndex < itemRects.length) {
      final currentRect = itemRects[currentIndex];
      if (logicalX >= currentRect.left - CatchLayout.tabBarDragHysteresis &&
          logicalX <= currentRect.right + CatchLayout.tabBarDragHysteresis) {
        return currentIndex;
      }
    }
    for (final (index, rect) in itemRects.indexed) {
      if (logicalX >= rect.left && logicalX <= rect.right) return index;
    }
    return null;
  }
}

class CatchTabBarButton<T> extends StatefulWidget {
  const CatchTabBarButton({
    super.key,
    required this.item,
    required this.selected,
    this.onTap,
    this.onTapDown,
    this.onTapCancel,
    this.onHoverChanged,
    this.onFocusChanged,
    this.onLongPress,
    this.semanticSelected,
    this.showSelectedLabel,
    this.ownsIndicator = true,
  });

  final CatchTabBarItem<T> item;
  final bool selected;
  final VoidCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final VoidCallback? onTapCancel;
  final ValueChanged<bool>? onHoverChanged;
  final ValueChanged<bool>? onFocusChanged;
  final VoidCallback? onLongPress;
  final bool? semanticSelected;
  final bool? showSelectedLabel;
  final bool ownsIndicator;

  @override
  State<CatchTabBarButton<T>> createState() => _CatchTabBarButtonState<T>();
}

class _CatchTabBarButtonState<T> extends State<CatchTabBarButton<T>> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final disabledAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    final duration = disabledAnimations == true
        ? Duration.zero
        : CatchMotion.standard;
    final t = CatchTokens.of(context);
    final selected = widget.selected;
    final showSelectedLabel = widget.showSelectedLabel ?? selected;
    final color = selected ? t.ink : t.ink3;
    final icon = CatchTabBarIcon(
      icon: selected
          ? widget.item.activeIcon ?? widget.item.icon
          : widget.item.icon,
      color: color,
      badgeCount: widget.item.badgeCount,
      child: selected
          ? widget.item.activeIconWidget ?? widget.item.iconWidget
          : widget.item.iconWidget,
    );
    final indicatorOpacity = _pressed
        ? CatchOpacity.tabBarPressedFill
        : _focused
        ? CatchOpacity.tabBarFocusFill
        : _hovered
        ? CatchOpacity.tabBarHoverFill
        : selected
        ? CatchOpacity.tabBarPillFill
        : CatchOpacity.none;
    final content = TweenAnimationBuilder<double>(
      key: ValueKey<Object>('catch_tab_bar.pill.${widget.item.id}'),
      duration: duration,
      curve: CatchMotion.standardCurve,
      tween: Tween<double>(end: showSelectedLabel ? 1 : 0),
      builder: (context, progress, child) => AnimatedContainer(
        duration: duration,
        curve: CatchMotion.standardCurve,
        constraints: const BoxConstraints(
          minWidth: CatchLayout.tabBarCompactItemExtent,
        ),
        height: CatchLayout.tabBarIndicatorExtent,
        padding: EdgeInsetsDirectional.only(
          start: showSelectedLabel
              ? CatchLayout.tabBarPillLeadingPadding
              : CatchLayout.tabBarCompactItemHorizontalPadding,
          end: showSelectedLabel
              ? CatchLayout.tabBarPillTrailingPadding
              : CatchLayout.tabBarCompactItemHorizontalPadding,
        ),
        decoration: ShapeDecoration(
          color: widget.ownsIndicator
              ? t.ink.withValues(alpha: indicatorOpacity)
              : Colors.transparent,
          shape: StadiumBorder(
            side: widget.ownsIndicator && _focused
                ? CatchBorder.resolve(t, CatchBorderRole.focus).side
                : BorderSide.none,
          ),
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
                        key: ValueKey(
                          'catch_tab_bar.label.${widget.item.label}',
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: CatchLayout.tabBarLabelGap,
                          ),
                          child: Text(
                            widget.item.label,
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
      selected: widget.semanticSelected ?? selected,
      label: widget.item.label,
      value: widget.item.semanticValue,
      hint: widget.item.semanticHint,
      onLongPress: widget.onLongPress ?? widget.item.onLongPress,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap == null
              ? null
              : () {
                  if (widget.ownsIndicator) catchSelectionHaptic();
                  widget.onTap!();
                },
          onTapDown: (details) {
            if (!_pressed) setState(() => _pressed = true);
            widget.onTapDown?.call(details);
          },
          onTapCancel: () {
            if (_pressed) setState(() => _pressed = false);
            widget.onTapCancel?.call();
          },
          onTapUp: (_) {
            if (_pressed) setState(() => _pressed = false);
          },
          onLongPress: widget.onLongPress ?? widget.item.onLongPress,
          onHover: (hovered) {
            if (_hovered != hovered) setState(() => _hovered = hovered);
            widget.onHoverChanged?.call(hovered);
          },
          onFocusChange: (focused) {
            if (_focused != focused) setState(() => _focused = focused);
            widget.onFocusChanged?.call(focused);
          },
          customBorder: const StadiumBorder(),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          child: Center(child: content),
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
