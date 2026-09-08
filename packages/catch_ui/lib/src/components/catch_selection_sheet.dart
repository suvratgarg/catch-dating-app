import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_bottom_sheet_scaffold.dart';
import 'package:catch_ui/src/components/catch_menu_item.dart';
import 'package:catch_ui/src/components/catch_menu_row.dart';
import 'package:catch_ui/src/components/catch_selection_menu_item.dart';
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
    final maxHeight =
        MediaQuery.sizeOf(context).height * CatchLayout.sheetMaxHeightFraction;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: CatchBottomSheetScaffold(
        title: title,
        subtitle: subtitle,
        child: Flexible(
          child: ListView(
            key: const ValueKey('catch-selection-sheet-list'),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              for (final item in items)
                CatchMenuRow<T>(
                  key: ValueKey<Object?>(item.value),
                  item: CatchMenuItem<T>(
                    value: item.value,
                    label: item.label,
                    sublabel: item.sublabel,
                    icon: item.icon,
                    selected: item.value == value,
                    enabled: item.enabled,
                    role: CatchMenuItemRole.choice,
                  ),
                  onSelected: (selected, _) {
                    if (selected != value) catchSelectionHaptic();
                    Navigator.of(context).pop(selected);
                  },
                ),
            ],
          ),
        ),
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
