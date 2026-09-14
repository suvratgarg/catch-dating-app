import 'dart:math' as math;
import 'dart:ui';

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_navigation_button.dart';
import 'package:catch_ui/src/components/catch_navigation_button_status.dart';
import 'package:catch_ui/src/components/catch_tab_bar_indicator.dart';
import 'package:catch_ui/src/components/catch_tab_bar_item.dart';
import 'package:catch_ui/src/foundations/catch_adaptive_platform.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/foundations/catch_transitions.dart';
import 'package:flutter/material.dart';

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
                          child: CatchTabBarIndicator(
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
                          child: CatchTabBarIndicator(
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
                          child: CatchNavigationButton<T>.sharedIndicator(
                            key: ValueKey<Object>(
                              'catch_tab_bar.destination.${item.id}',
                            ),
                            item: item,
                            status: switch ((
                              index == activeIndex,
                              index == visualIndex,
                            )) {
                              (true, true) =>
                                CatchNavigationButtonStatus.selected,
                              (false, true) =>
                                CatchNavigationButtonStatus.preview,
                              (true, false) =>
                                CatchNavigationButtonStatus.retainedSelection,
                              (false, false) =>
                                CatchNavigationButtonStatus.unselected,
                            },
                            showSelectedLabel:
                                !compactDestinations &&
                                index == activeIndex &&
                                visualIndex == activeIndex,
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
        style: CatchTextStyles.navigationLabel(context),
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
