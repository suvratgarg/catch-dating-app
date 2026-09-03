import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';

/// Marker contract for the one pinned peer-control rail owned by a root screen.
///
/// Root composition accepts this type instead of any [PreferredSizeWidget], so
/// an arbitrary app bar, wrapper, or hand-rolled tab bar cannot enter the
/// pinned rail slot merely by reporting the expected height.
abstract interface class CatchPrimaryRail implements PreferredSizeWidget {}

/// Segmented tab rail for app-bar bottoms: a [CatchOptionGroup] in the
/// standard rail shell.
class CatchTabRail<T> extends StatelessWidget
    implements CatchPrimaryRail, CatchScaledPreferredSize {
  /// The pinned slot and its content use the same scaled line-box geometry.
  /// The unscaled preferredSize remains the canonical minimum contract.
  static double heightFor(BuildContext context) {
    final style = CatchTextStyles.tabLabel(context);
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(style.fontSize!) * style.height!;
    final contentHeight = lineHeight + CatchSpacing.s4 + CatchSpacing.micro2;
    final gridHeight =
        (contentHeight / CatchSpacing.s1).ceil() * CatchSpacing.s1;
    return gridHeight < CatchLayout.tabRailHeight
        ? CatchLayout.tabRailHeight
        : gridHeight;
  }

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
  Size get preferredSize => const Size.fromHeight(CatchLayout.tabRailHeight);

  @override
  Size preferredSizeFor(BuildContext context) =>
      Size.fromHeight(CatchTabRail.heightFor(context));

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
          height: heightFor(context),
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

/// Binds a route-owned [TabController] to the canonical [CatchTabRail].
///
/// This keeps tap selection, horizontal pager interpolation, and the standard
/// option-group chrome on one shared path for root screens with peer views.
class CatchTabControllerRail<T> extends StatelessWidget
    implements CatchPrimaryRail, CatchScaledPreferredSize {
  const CatchTabControllerRail({
    super.key,
    required this.controller,
    required this.options,
    this.groupKey,
  }) : assert(options.length == controller.length);

  final TabController controller;
  final List<CatchOption<T>> options;
  final Key? groupKey;

  @override
  Size get preferredSize => const Size.fromHeight(CatchLayout.tabRailHeight);

  @override
  Size preferredSizeFor(BuildContext context) =>
      Size.fromHeight(CatchTabRail.heightFor(context));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        return CatchTabRail<T>(
          groupKey: groupKey,
          selected: options[controller.index].value,
          selectionPosition: controller.animation!.value,
          onChanged: (value) {
            final index = options.indexWhere((option) => option.value == value);
            if (index != -1) controller.animateTo(index);
          },
          options: options,
        );
      },
    );
  }
}
