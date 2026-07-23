import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/schema_contracts/catch_contract_field_policy.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart'
    show CatchContractConstraints, CatchContractFieldConstraints;

/// A chip selector that works for both single-select and multi-select use cases.
///
/// Wraps [FormField] so it participates in [Form] validation.
/// The [selected] set is driven by the parent — update it via [onChanged] and
/// call [setState] to reflect changes.
class CatchChipField<T extends Labelled> extends StatelessWidget {
  const CatchChipField({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.multiSelect,
    required this.onChanged,
    this.contract,
    this.contractValue,
    this.enabled = true,
    this.isOptional = false,
    this.showLabel = true,
    this.allowEmptySingleSelection = false,
    this.validator,
    this.chipKeyBuilder,
  });

  final String label;
  final List<T> values;
  final CatchContractFieldConstraints? contract;
  final String Function(T value)? contractValue;

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
    final supportedValues = CatchContractFieldPolicy.supportedChoiceValues(
      contract,
      values,
      contractValue,
      multi: multiSelect,
    );
    final supportedSelection = selected.intersection(supportedValues.toSet());
    assert(
      supportedSelection.length == selected.length,
      'CatchChipField selected values must be allowed by the schema contract.',
    );

    return FormField<Set<T>>(
      initialValue: supportedSelection,
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
            children: supportedValues.map((v) {
              final isSelected = supportedSelection.contains(v);
              return CatchChip.selectable(
                key: chipKeyBuilder?.call(v),
                label: v.label,
                selected: isSelected,
                leading: multiSelect && isSelected
                    ? Icon(CatchIcons.checkRounded)
                    : null,
                enabled: enabled,
                onChanged: (_) {
                  final next = Set<T>.from(supportedSelection);
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
              style: CatchTextStyles.supporting(context, color: t.danger),
            ),
          ],
        ],
      ),
    );
  }
}
