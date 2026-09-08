import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_choice_picked_notification.dart';
import 'package:catch_ui/src/components/catch_option_card.dart';
import 'package:flutter/material.dart';

/// Field-owned vertical single-select control for explanatory choices.
///
/// Each option remains one complete clickable [CatchOptionCard]; the field
/// owns disclosure, collapsed summary, and auto-close behavior.
class CatchFieldOptionCardControl<T> extends StatelessWidget {
  const CatchFieldOptionCardControl({
    super.key,
    required this.values,
    required this.itemTitle,
    required this.itemDescription,
    required this.selected,
    required this.onChanged,
    this.autoClose = false,
    this.enabled = true,
  });

  final List<T> values;
  final String Function(T value) itemTitle;
  final String Function(T value) itemDescription;
  final T selected;
  final ValueChanged<T>? onChanged;
  final bool autoClose;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < values.length; index++) ...[
          if (index > 0) const SizedBox(height: CatchSpacing.s2),
          Builder(
            builder: (context) {
              final value = values[index];
              final title = itemTitle(value);
              final isSelected = value == selected;
              return Semantics(
                selected: isSelected,
                inMutuallyExclusiveGroup: true,
                child: CatchOptionCard(
                  key: ValueKey('catch-field-option-card-$title'),
                  title: title,
                  description: itemDescription(value),
                  selected: isSelected,
                  onTap: enabled && onChanged != null
                      ? () {
                          onChanged?.call(value);
                          if (autoClose) {
                            const CatchFieldChoicePickedNotification(
                              autoClose: true,
                            ).dispatch(context);
                          }
                        }
                      : null,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
