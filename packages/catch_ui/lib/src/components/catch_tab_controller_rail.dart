import 'package:catch_ui/src/components/catch_option.dart';
import 'package:catch_ui/src/components/catch_primary_rail.dart';
import 'package:catch_ui/src/components/catch_tab_rail.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';

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
  Size get preferredSize => Size.fromHeight(CatchTabRail.minimumHeight);

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
