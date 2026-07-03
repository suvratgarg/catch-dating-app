import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:flutter/material.dart';

/// Segmented tab rail for app-bar bottoms: a [CatchOptionGroup] in the
/// standard rail shell.
class CatchTabRail<T> extends StatelessWidget implements PreferredSizeWidget {
  const CatchTabRail({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.options,
    this.groupKey,
  });

  final T selected;
  final ValueChanged<T> onChanged;
  final List<CatchOption<T>> options;
  final Key? groupKey;

  @override
  Size get preferredSize => const Size.fromHeight(CatchLayout.tabRailHeight);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          0,
          CatchSpacing.s5,
          CatchSpacing.s2,
        ),
        child: CatchOptionGroup<T>(
          key: groupKey,
          selected: selected,
          onChanged: onChanged,
          options: options,
        ),
      ),
    );
  }
}
