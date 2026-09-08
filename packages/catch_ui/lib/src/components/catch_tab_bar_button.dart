import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_tab_bar_icon.dart';
import 'package:catch_ui/src/components/catch_tab_bar_item.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/foundations/catch_transitions.dart';
import 'package:flutter/material.dart';

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
                            style: CatchTextStyles.navigationLabel(
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
