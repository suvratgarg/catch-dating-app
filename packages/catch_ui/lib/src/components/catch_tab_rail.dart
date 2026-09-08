import 'dart:math' as math;

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_option.dart';
import 'package:catch_ui/src/components/catch_option_group.dart';
import 'package:catch_ui/src/components/catch_option_group_variant.dart';
import 'package:catch_ui/src/components/catch_primary_rail.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';

/// Segmented tab rail for app-bar bottoms: a [CatchOptionGroup] in the
/// standard rail shell.
class CatchTabRail<T> extends StatelessWidget
    implements CatchPrimaryRail, CatchScaledPreferredSize {
  /// The pinned slot and its content use the same scaled line-box geometry.
  /// The unscaled preferredSize remains the canonical minimum contract.
  static double heightFor(
    BuildContext context, {
    CatchOptionGroupVariant variant = CatchOptionGroupVariant.label,
  }) {
    final style = CatchTextStyles.tabLabel(context);
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(style.fontSize!) * style.height!;
    final contentHeight = lineHeight + CatchSpacing.s4 + CatchSpacing.micro2;
    final gridHeight =
        (contentHeight / CatchSpacing.s1).ceil() * CatchSpacing.s1;
    final inset = variant == CatchOptionGroupVariant.operational
        ? CatchSpacing.s2
        : 0.0;
    return math.max(gridHeight, minimumHeight) + inset;
  }

  static double get minimumHeight => math.max(
    CatchLayout.tabRailHeight,
    CatchPlatformTokens.minimumInteractiveExtent,
  );

  static double minimumHeightFor(CatchOptionGroupVariant variant) =>
      minimumHeight +
      (variant == CatchOptionGroupVariant.operational ? CatchSpacing.s2 : 0);

  const CatchTabRail({
    super.key,
    required this.selected,
    required this.options,
    this.onChanged,
    this.groupKey,
    this.selectionPosition,
    this.trailing,
    this.scrollable = false,
    this.variant = CatchOptionGroupVariant.label,
    this.accent,
    this.backgroundColor,
    this.contentPadding = CatchInsets.screenControlRow,
  });

  final T selected;
  final ValueChanged<T>? onChanged;
  final List<CatchOption<T>> options;
  final Key? groupKey;
  final double? selectionPosition;
  final Widget? trailing;
  final bool scrollable;
  final CatchOptionGroupVariant variant;
  final Color? accent;
  final Color? backgroundColor;
  final EdgeInsetsGeometry contentPadding;

  @override
  Size get preferredSize => Size.fromHeight(minimumHeightFor(variant));

  @override
  Size preferredSizeFor(BuildContext context) =>
      Size.fromHeight(CatchTabRail.heightFor(context, variant: variant));

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final operational = variant == CatchOptionGroupVariant.operational;

    return ColoredBox(
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
            child: CatchOptionGroup<T>(
              key: groupKey,
              selected: selected,
              onChanged: onChanged,
              options: options,
              selectionPosition: selectionPosition,
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
    );
  }
}
