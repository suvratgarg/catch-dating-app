import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_chip.dart';
import 'package:catch_ui/src/components/catch_chip_mode.dart';
import 'package:catch_ui/src/components/catch_choice_tile.dart';
import 'package:catch_ui/src/components/catch_contract_field_constraints.dart';
import 'package:catch_ui/src/components/catch_contract_field_policy.dart';
import 'package:catch_ui/src/components/catch_field_choice_picked_notification.dart';
import 'package:catch_ui/src/components/catch_form_field_label.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

/// Checked choices with caller-owned values and shared selection policy.
///
/// The default recipe wraps compact chips; [CatchChoiceInput.described]
/// stacks full-width choices whose supporting copy belongs in the target.
/// [CatchChoiceInput.form] adds Flutter Form validation and optional label copy
/// around the same input. A null [onChanged] disables every choice.
class CatchChoiceInput<T> extends StatelessWidget {
  const CatchChoiceInput({
    super.key,
    required this.values,
    required this.itemLabelBuilder,
    required this.selected,
    required this.mode,
    required this.onChanged,
    this.allowEmptySelection = false,
    this.autoClose = false,
    this.itemAccentBuilder,
    this.itemKeyBuilder,
  }) : _form = null,
       _itemSubtitleBuilder = null,
       _constraints = null;

  const CatchChoiceInput.described({
    super.key,
    required this.values,
    required this.itemLabelBuilder,
    required String Function(T value) itemSubtitleBuilder,
    required this.selected,
    required this.onChanged,
    this.autoClose = false,
    this.itemKeyBuilder,
    CatchContractFieldConstraints? contract,
    String Function(T value)? contractValueBuilder,
  }) : mode = CatchChipMode.single,
       allowEmptySelection = false,
       itemAccentBuilder = null,
       _form = null,
       _itemSubtitleBuilder = itemSubtitleBuilder,
       _constraints = (contract: contract, valueBuilder: contractValueBuilder);

  const CatchChoiceInput.form({
    super.key,
    required String? label,
    required CatchFormFieldLabelCopy copy,
    required this.values,
    required this.itemLabelBuilder,
    required this.selected,
    required this.mode,
    required this.onChanged,
    this.allowEmptySelection = false,
    bool isOptional = false,
    CatchContractFieldConstraints? contract,
    String Function(T value)? contractValueBuilder,
    FormFieldValidator<Set<T>>? validator,
    this.itemAccentBuilder,
    this.itemKeyBuilder,
  }) : autoClose = false,
       _itemSubtitleBuilder = null,
       _constraints = null,
       _form = (
         label: label,
         copy: copy,
         isOptional: isOptional,
         contract: contract,
         contractValueBuilder: contractValueBuilder,
         validator: validator,
       );

  final String Function(T value)? _itemSubtitleBuilder;
  final ({
    CatchContractFieldConstraints? contract,
    String Function(T value)? valueBuilder,
  })?
  _constraints;

  final List<T> values;
  final String Function(T value) itemLabelBuilder;
  final Set<T> selected;
  final CatchChipMode mode;
  final ValueChanged<Set<T>>? onChanged;
  final bool allowEmptySelection;

  /// Requests the nearest field's existing close protocol after a single
  /// choice callback completes. Multiple selection never requests closure.
  final bool autoClose;
  final Color? Function(T value)? itemAccentBuilder;
  final Key? Function(T value)? itemKeyBuilder;
  final ({
    String? label,
    CatchFormFieldLabelCopy copy,
    bool isOptional,
    CatchContractFieldConstraints? contract,
    String Function(T value)? contractValueBuilder,
    FormFieldValidator<Set<T>>? validator,
  })?
  _form;

  @override
  Widget build(BuildContext context) {
    if (_form case final form?) {
      final supportedValues = CatchContractFieldPolicy.supportedChoiceValues(
        form.contract,
        values,
        form.contractValueBuilder,
        multi: mode == CatchChipMode.multiple,
      );
      final supportedSelection = selected.intersection(supportedValues.toSet());
      assert(
        supportedSelection.length == selected.length,
        'CatchChoiceInput selected values must be allowed by the schema contract.',
      );
      return FormField<Set<T>>(
        initialValue: supportedSelection,
        validator: form.validator,
        builder: (field) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (form.label case final label?) ...[
              CatchFormFieldLabel(
                copy: form.copy,
                label: label,
                isOptional: form.isOptional,
                hasError: field.hasError,
              ),
              gapH8,
            ],
            CatchChoiceInput<T>(
              values: supportedValues,
              itemLabelBuilder: itemLabelBuilder,
              selected: supportedSelection,
              mode: mode,
              allowEmptySelection: allowEmptySelection,
              itemKeyBuilder: itemKeyBuilder,
              itemAccentBuilder: itemAccentBuilder,
              onChanged: onChanged == null
                  ? null
                  : (next) {
                      onChanged!(next);
                      field.didChange(next);
                    },
            ),
            if (field.hasError) ...[
              gapH8,
              Text(
                field.errorText!,
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).danger,
                ),
              ),
            ],
          ],
        ),
      );
    }

    final supportedValues = CatchContractFieldPolicy.supportedChoiceValues(
      _constraints?.contract,
      values,
      _constraints?.valueBuilder,
      multi: mode == CatchChipMode.multiple,
    );
    final supportedSelection = selected.intersection(supportedValues.toSet());
    assert(
      supportedSelection.length == selected.length,
      'CatchChoiceInput selected values must be allowed by the schema contract.',
    );
    assert(
      _itemSubtitleBuilder == null || selected.length <= 1,
      'Described choices accept at most one selected value.',
    );
    final items = <Widget>[];
    for (final value in supportedValues) {
      final label = itemLabelBuilder(value);
      final key =
          itemKeyBuilder?.call(value) ??
          ValueKey(
            _itemSubtitleBuilder == null
                ? 'catch-field-choice-$label'
                : 'catch-field-option-card-$label',
          );
      final VoidCallback? action = onChanged == null
          ? null
          : () {
              final next = Set<T>.from(supportedSelection);
              if (mode == CatchChipMode.multiple) {
                if (next.contains(value)) {
                  if (!allowEmptySelection && next.length == 1) return;
                  next.remove(value);
                } else {
                  next.add(value);
                }
              } else {
                final wasSelected = next.contains(value);
                next.clear();
                if (!wasSelected || !allowEmptySelection) next.add(value);
              }
              onChanged!(next);
              if (mode == CatchChipMode.single && autoClose) {
                const CatchFieldChoicePickedNotification(
                  autoClose: true,
                ).dispatch(context);
              }
            };
      items.add(
        KeyedSubtree(
          key: _CatchChoiceValueKey<T>(value),
          child: _itemSubtitleBuilder == null
              ? CatchChip.choice(
                  key: key,
                  label: label,
                  selected: supportedSelection.contains(value),
                  mode: mode,
                  accent: itemAccentBuilder?.call(value),
                  onPressed: action,
                )
              : CatchChoiceTile(
                  key: key,
                  title: label,
                  subtitle: _itemSubtitleBuilder(value),
                  selected: supportedSelection.contains(value),
                  onTap: action,
                ),
        ),
      );
    }
    if (_itemSubtitleBuilder != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) const SizedBox(height: CatchSpacing.s2),
            items[index],
          ],
        ],
      );
    }
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: CatchFieldTokens.chipHorizontalGap,
        runSpacing: CatchFieldTokens.chipRunSpacing,
        children: items,
      ),
    );
  }
}

// Keep caller-provided chip keys separate from the group's value identity.
class _CatchChoiceValueKey<T> extends ValueKey<T> {
  const _CatchChoiceValueKey(super.value);
}
