import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_menu.dart';
import 'package:catch_ui/src/components/catch_menu_item.dart';
import 'package:catch_ui/src/components/catch_selection_menu_item.dart';
import 'package:catch_ui/src/foundations/catch_transitions.dart';
import 'package:flutter/material.dart';

/// Anchored, mutually-exclusive selection for medium and expanded layouts.
///
/// Compact layouts should use `CatchSelectionSheet` or
/// `CatchAdaptiveSelectionControl` so labels and touch targets remain legible.
class CatchSelectionMenu<T> extends StatefulWidget {
  CatchSelectionMenu({
    super.key,
    required this.items,
    required this.value,
    required this.onSelected,
    required this.builder,
    this.width = CatchLayout.selectionMenuWidth,
  }) : assert(items.isNotEmpty, 'CatchSelectionMenu needs at least one item.'),
       assert(
         items.any((item) => item.value == value),
         'CatchSelectionMenu value must match an item.',
       );

  final List<CatchSelectionMenuItem<T>> items;
  final T value;
  final ValueChanged<T> onSelected;
  final CatchSelectionMenuTriggerBuilder<T> builder;
  final double width;

  @override
  State<CatchSelectionMenu<T>> createState() => _CatchSelectionMenuState<T>();
}

class _CatchSelectionMenuState<T> extends State<CatchSelectionMenu<T>> {
  final _controller = MenuController();

  CatchSelectionMenuItem<T> get _selectedItem =>
      widget.items.firstWhere((item) => item.value == widget.value);

  @override
  Widget build(BuildContext context) {
    final menuWidth = CatchLayout.menuWidthFor(
      preferredWidth: widget.width,
      viewportWidth: MediaQuery.sizeOf(context).width,
    );
    return CatchMenu<T>.anchored(
      controller: _controller,
      width: menuWidth,
      alignmentOffset: const Offset(0, CatchSpacing.s1),
      items: [
        for (final item in widget.items)
          CatchMenuItem<T>(
            value: item.value,
            label: item.label,
            sublabel: item.sublabel,
            icon: item.icon,
            selected: item.value == widget.value,
            enabled: item.enabled,
            role: CatchMenuItemRole.choice,
          ),
      ],
      onSelected: (value, _) {
        if (value != widget.value) catchSelectionHaptic();
        widget.onSelected(value);
        _controller.close();
      },
      builder: (context, controller, child) => widget.builder(
        context,
        _selectedItem,
        controller.isOpen,
        () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
