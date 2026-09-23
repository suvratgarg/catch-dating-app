import 'package:catch_ui/src/components/catch_menu_item.dart';
import 'package:catch_ui/src/components/catch_menu_row.dart';
import 'package:catch_ui/src/components/catch_selection_menu_item.dart';
import 'package:catch_ui/src/components/catch_sheet.dart';
import 'package:catch_ui/src/foundations/catch_transitions.dart';
import 'package:flutter/material.dart';

/// Phone-friendly selection surface with mutually-exclusive row semantics.
class CatchSelectionSheet<T> extends StatelessWidget {
  const CatchSelectionSheet({
    super.key,
    required this.title,
    required this.items,
    required this.value,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<CatchSelectionMenuItem<T>> items;
  final T value;

  @override
  Widget build(BuildContext context) {
    return CatchSheet.standard(
      title: title,
      subtitle: subtitle,
      child: Column(
        key: const ValueKey('catch-selection-sheet-list'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items)
            CatchMenuRow<T>.sheet(
              key: ValueKey<Object?>(item.value),
              item: CatchMenuItem<T>(
                value: item.value,
                label: item.label,
                sublabel: item.sublabel,
                icon: item.icon,
                selected: item.value == value,
                enabled: item.enabled,
                variant: CatchMenuItemVariant.choice,
              ),
              onSelected: (selected, _) {
                if (selected != value) catchSelectionHaptic();
                Navigator.of(context).pop(selected);
              },
            ),
        ],
      ),
    );
  }
}

Future<T?> showCatchSelectionSheet<T>({
  required BuildContext context,
  required String title,
  required List<CatchSelectionMenuItem<T>> items,
  required T value,
  String? subtitle,
}) => showCatchBottomSheet<T>(
  context: context,
  builder: (_) => CatchSelectionSheet<T>(
    title: title,
    subtitle: subtitle,
    items: items,
    value: value,
  ),
);
