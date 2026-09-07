import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_choice_chip.dart';
import 'package:catch_ui/src/components/catch_field_choice_picked_notification.dart';
import 'package:flutter/material.dart';

/// Exact wrapping chip control used by the field choices facade.
class CatchFieldChoiceControl<T> extends StatelessWidget {
  const CatchFieldChoiceControl({
    super.key,
    required this.values,
    required this.itemLabel,
    required this.selected,
    required this.multi,
    required this.onSelectionChanged,
    this.allowEmptySelection = false,
    this.autoClose = false,
    this.enabled = true,
    this.itemAccent,
  });

  final List<T> values;
  final String Function(T value) itemLabel;
  final Set<T> selected;
  final bool multi;
  final bool allowEmptySelection;
  final bool autoClose;
  final bool enabled;
  final Color? Function(T value)? itemAccent;
  final ValueChanged<Set<T>>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: CatchFieldTokens.chipHorizontalGap,
        runSpacing: CatchFieldTokens.chipRunSpacing,
        children: [
          for (final value in values)
            CatchFieldChoiceChip(
              label: itemLabel(value),
              selected: selected.contains(value),
              multi: multi,
              enabled: enabled && onSelectionChanged != null,
              accent: itemAccent?.call(value),
              onPressed: () {
                final next = Set<T>.from(selected);
                if (multi) {
                  if (next.contains(value)) {
                    if (!allowEmptySelection && next.length == 1) return;
                    next.remove(value);
                  } else {
                    next.add(value);
                  }
                } else {
                  final wasSelected = next.contains(value);
                  next.clear();
                  if (!wasSelected || !allowEmptySelection) {
                    next.add(value);
                  }
                }
                onSelectionChanged?.call(next);
                if (!multi && autoClose && onSelectionChanged != null) {
                  const CatchFieldChoicePickedNotification(
                    autoClose: true,
                  ).dispatch(context);
                }
              },
            ),
        ],
      ),
    );
  }
}
