import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_selection_menu.dart';
import 'package:catch_ui/src/components/catch_selection_menu_item.dart';
import 'package:catch_ui/src/components/catch_selection_sheet.dart';
import 'package:flutter/material.dart';

/// Adapts a caller-supplied selection trigger to a bottom sheet on compact
/// layouts and an anchored picker on wider layouts.
class CatchAdaptiveSelectionMenu<T> extends StatelessWidget {
  const CatchAdaptiveSelectionMenu({
    super.key,
    required this.title,
    required this.items,
    required this.value,
    required this.onSelected,
    required this.builder,
    this.subtitle,
    this.width = CatchLayout.selectionMenuWidth,
  });

  final String title;
  final String? subtitle;
  final List<CatchSelectionMenuItem<T>> items;
  final T value;
  final ValueChanged<T> onSelected;
  final CatchSelectionMenuTriggerBuilder<T> builder;
  final double width;

  CatchSelectionMenuItem<T> get _selectedItem =>
      items.firstWhere((item) => item.value == value);

  @override
  Widget build(BuildContext context) {
    final compact = CatchWindowSize.fromWidth(
      MediaQuery.sizeOf(context).width,
    ).isCompact;
    if (!compact) {
      return CatchSelectionMenu<T>(
        items: items,
        value: value,
        onSelected: onSelected,
        width: width,
        builder: builder,
      );
    }

    return builder(context, _selectedItem, false, () async {
      final selected = await showCatchSelectionSheet<T>(
        context: context,
        title: title,
        subtitle: subtitle,
        items: items,
        value: value,
      );
      if (selected != null && context.mounted) onSelected(selected);
    });
  }
}
