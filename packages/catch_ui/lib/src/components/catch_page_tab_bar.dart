import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_choice_input.dart';
import 'package:catch_ui/src/components/catch_choice_input_variant.dart';
import 'package:catch_ui/src/components/catch_option.dart';
import 'package:catch_ui/src/components/catch_primary_rail.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';

/// Page-level peer navigation in the canonical scaled app-bar shell.
///
/// [controlled] binds a caller-owned pager to the same option renderer.
/// Product-level bottom navigation remains the responsibility of CatchTabBar.
class CatchPageTabBar<T> extends StatelessWidget
    implements CatchPrimaryRail, CatchScaledPreferredSize {
  /// The pinned slot and its content use the same scaled line-box geometry.
  /// The unscaled preferredSize remains the canonical minimum contract.
  static double heightFor(
    BuildContext context, {
    CatchChoiceInputVariant variant = CatchChoiceInputVariant.label,
  }) {
    final style = CatchTextStyles.tabLabel(context);
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(style.fontSize!) * style.height!;
    final contentHeight = lineHeight + CatchSpacing.s4 + CatchSpacing.micro2;
    final gridHeight =
        (contentHeight / CatchSpacing.s1).ceil() * CatchSpacing.s1;
    final inset = variant == CatchChoiceInputVariant.operational
        ? CatchSpacing.s2
        : 0.0;
    return math.max(gridHeight, minimumHeight) + inset;
  }

  static double get minimumHeight => math.max(
    CatchLayout.tabRailHeight,
    CatchPlatformTokens.minimumInteractiveExtent,
  );

  static double minimumHeightFor(CatchChoiceInputVariant variant) =>
      minimumHeight +
      (variant == CatchChoiceInputVariant.operational ? CatchSpacing.s2 : 0);

  const CatchPageTabBar({
    super.key,
    required T this._selected,
    required this.options,
    this.onChanged,
    this.groupKey,
    this.selectionPosition,
    this.trailing,
    this.scrollable = false,
    this.variant = CatchChoiceInputVariant.label,
    this.accent,
    this.backgroundColor,
    this.contentPadding = CatchInsets.screenControlRow,
  }) : controller = null;

  /// Shares selection, drag interpolation and geometry with the value recipe.
  /// The caller owns and disposes [controller].
  const CatchPageTabBar.controlled({
    super.key,
    required TabController this.controller,
    required this.options,
    this.groupKey,
    this.trailing,
    this.scrollable = false,
    this.variant = CatchChoiceInputVariant.label,
    this.accent,
    this.backgroundColor,
    this.contentPadding = CatchInsets.screenControlRow,
  }) : assert(options.length > 0),
       assert(options.length == controller.length),
       _selected = null,
       onChanged = null,
       selectionPosition = null;

  final T? _selected;
  final TabController? controller;

  /// The committed value; drag progress does not change the selected semantics.
  T get selected =>
      controller == null ? _selected as T : options[controller!.index].value;
  final ValueChanged<T>? onChanged;
  final List<CatchOption<T>> options;
  final Key? groupKey;
  final double? selectionPosition;
  final Widget? trailing;
  final bool scrollable;
  final CatchChoiceInputVariant variant;
  final Color? accent;
  final Color? backgroundColor;
  final EdgeInsetsGeometry contentPadding;

  @override
  Size get preferredSize => Size.fromHeight(minimumHeightFor(variant));

  @override
  Size preferredSizeFor(BuildContext context) =>
      Size.fromHeight(CatchPageTabBar.heightFor(context, variant: variant));

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final operational = variant == CatchChoiceInputVariant.operational;

    return AnimatedBuilder(
      animation: controller?.animation ?? kAlwaysDismissedAnimation,
      builder: (context, _) => ColoredBox(
        color: backgroundColor ?? t.bg,
        child: Padding(
          padding: operational
              ? const EdgeInsets.symmetric(horizontal: CatchSpacing.s4)
              : EdgeInsets.zero,
          child: SizedBox(
            height: heightFor(context, variant: variant),
            child: DecoratedBox(
              decoration: operational
                  ? BoxDecoration(
                      color: t.raised,
                      borderRadius: BorderRadius.circular(CatchRadius.pill),
                      border: CatchBorder.resolve(
                        t,
                        CatchBorderRole.boundary,
                      ).all,
                    )
                  : const BoxDecoration(),
              child: CatchChoiceInput<T>.segmented(
                key: groupKey,
                selected: selected,
                onChanged: controller == null
                    ? onChanged
                    : (value) {
                        final index = options.indexWhere(
                          (option) => option.value == value,
                        );
                        if (index != -1) controller!.animateTo(index);
                      },
                options: options,
                selectionPosition:
                    controller?.animation?.value ?? selectionPosition,
                trailing: trailing,
                scrollable: scrollable,
                variant: variant,
                accent: accent,
                contentPadding: operational
                    ? const EdgeInsets.all(CatchSpacing.s1)
                    : contentPadding,
                showDivider: !operational,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
