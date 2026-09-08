import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_adaptive_selection_menu.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/components/catch_selection_menu_item.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:flutter/material.dart';

/// A standard visible selection control that uses a sheet on phones and an
/// anchored picker on wider Host layouts. Prefer this over an inline option
/// group when mutually-exclusive choices are numerous, long, or dynamic.
class CatchAdaptiveSelectionControl<T> extends StatelessWidget {
  const CatchAdaptiveSelectionControl({
    super.key,
    required this.title,
    required this.tooltip,
    required this.items,
    required this.value,
    required this.triggerLabel,
    required this.onSelected,
    this.subtitle,
    this.icon,
    this.buttonKey,
  });

  final String title;
  final String? subtitle;
  final String tooltip;
  final List<CatchSelectionMenuItem<T>> items;
  final T value;
  final String Function(CatchSelectionMenuItem<T> selectedItem) triggerLabel;
  final ValueChanged<T> onSelected;
  final IconData? icon;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return CatchAdaptiveSelectionMenu<T>(
      title: title,
      subtitle: subtitle,
      items: items,
      value: value,
      onSelected: onSelected,
      builder: (context, selectedItem, open, toggle) => CatchButton(
        key: buttonKey,
        label: triggerLabel(selectedItem),
        semanticsLabel: tooltip,
        leading: Icon(icon ?? CatchIcons.sort, size: CatchIcon.sm),
        variant: CatchButtonVariant.secondary,
        size: CatchButtonSize.sm,
        onPressed: toggle,
      ),
    );
  }
}
