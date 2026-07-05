import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:flutter/material.dart';

/// Segmented tab rail for app-bar bottoms: a [CatchOptionGroup] in the
/// standard rail shell.
class CatchTabRail<T> extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: backgroundColor ?? t.bg,
      child: SizedBox(
        height: preferredSize.height,
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
          contentPadding: contentPadding,
        ),
      ),
    );
  }
}
