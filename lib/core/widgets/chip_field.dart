import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:flutter/material.dart';

/// A chip selector that works for both single-select and multi-select use cases.
///
/// Wraps [FormField] so it participates in [Form] validation.
/// The [selected] set is driven by the parent — update it via [onChanged] and
/// call [setState] to reflect changes.
class ChipField<T extends Labelled> extends StatelessWidget {
  const ChipField({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.multiSelect,
    required this.onChanged,
    this.enabled = true,
    this.isOptional = false,
    this.showLabel = true,
    this.allowEmptySingleSelection = false,
    this.validator,
    this.chipKeyBuilder,
  });

  final String label;
  final List<T> values;

  /// The currently selected items — parent-owned, passed down each build.
  final Set<T> selected;

  final bool multiSelect;
  final void Function(Set<T> next) onChanged;
  final bool enabled;
  final bool isOptional;
  final bool showLabel;

  /// Allows a selected single-choice chip to be tapped again to clear the
  /// selection. This only takes effect when [isOptional] is true.
  final bool allowEmptySingleSelection;
  final FormFieldValidator<Set<T>>? validator;
  final Key? Function(T value)? chipKeyBuilder;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return FormField<Set<T>>(
      initialValue: selected,
      validator: validator,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel) ...[
            CatchFormFieldLabel(
              label: label,
              isOptional: isOptional,
              hasError: field.hasError,
            ),
            gapH8,
          ],
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: values.map((v) {
              final isSelected = selected.contains(v);
              return CatchChip(
                key: chipKeyBuilder?.call(v),
                label: v.label,
                active: isSelected,
                icon: multiSelect && isSelected
                    ? const Icon(Icons.check_rounded)
                    : null,
                enabled: enabled,
                onTap: () {
                  final next = Set<T>.from(selected);
                  if (!multiSelect) {
                    next.clear();
                    final canClear = isOptional && allowEmptySingleSelection;
                    if (!canClear || !isSelected) {
                      next.add(v);
                    }
                  } else {
                    if (isSelected) {
                      if (isOptional || next.length > 1) {
                        next.remove(v);
                      }
                    } else {
                      next.add(v);
                    }
                  }
                  onChanged(next);
                  field.didChange(next);
                },
              );
            }).toList(),
          ),
          if (field.hasError) ...[
            gapH8,
            Text(
              field.errorText!,
              style: CatchTextStyles.bodyS(context, color: t.danger),
            ),
          ],
        ],
      ),
    );
  }
}
