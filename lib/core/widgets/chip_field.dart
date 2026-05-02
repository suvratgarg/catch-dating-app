import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/labelled.dart';
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
    this.isOptional = false,
    this.validator,
  });

  final String label;
  final List<T> values;

  /// The currently selected items — parent-owned, passed down each build.
  final Set<T> selected;

  final bool multiSelect;
  final void Function(Set<T> next) onChanged;
  final bool isOptional;
  final FormFieldValidator<Set<T>>? validator;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return FormField<Set<T>>(
      initialValue: selected,
      validator: validator,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchFormFieldLabel(
            label: label,
            isOptional: isOptional,
            hasError: field.hasError,
          ),
          gapH8,
          Wrap(
            spacing: Sizes.p8,
            runSpacing: Sizes.p8,
            children: values.map((v) {
              final isSelected = selected.contains(v);
              return CatchChip(
                label: v.label,
                active: isSelected,
                onTap: () {
                  final next = Set<T>.from(selected);
                  if (!multiSelect) next.clear();
                  isSelected ? next.remove(v) : next.add(v);
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
