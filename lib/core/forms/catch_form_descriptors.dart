import 'package:catch_dating_app/core/forms/catch_form_multi_choice_row_editor.dart';
import 'package:catch_dating_app/core/forms/catch_form_range_row_editor.dart';
import 'package:catch_dating_app/core/forms/catch_form_single_choice_row_editor.dart';
import 'package:catch_dating_app/core/forms/catch_form_text_row_editor.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// P is the patch type committed by the owning surface.
sealed class CatchFormRowDescriptor<P> {
  const CatchFormRowDescriptor({
    required this.id,
    required this.icon,
    required this.label,
  });

  final String id;
  final IconData icon;
  final String label;

  String get accordionKey => id;

  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  );
}

final class CatchFormReadRow<P> extends CatchFormRowDescriptor<P> {
  const CatchFormReadRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.body,
    this.bodyMaxLines = 4,
  });

  final String body;
  final int bodyMaxLines;

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    return CatchField.read(
      copy: scope.fieldCopy,
      icon: icon,
      title: label,
      body: body,
      bodyMaxLines: bodyMaxLines,
    );
  }
}

final class CatchFormTextRow<P> extends CatchFormRowDescriptor<P> {
  const CatchFormTextRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.currentValue,
    required this.validationCopy,
    required this.patchForValue,
    this.fieldName,
    this.currentFieldValue,
    this.emptyValueText,
    this.placeholder,
    this.inputHint,
    this.leadingUnit,
    this.showClearButton = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
    this.contract,
    this.maxLength,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.normalizeInput,
  });

  final String currentValue;
  final CatchFormValidationCopy validationCopy;
  final Object? currentFieldValue;
  final String? fieldName;
  final String? emptyValueText;
  final String? placeholder;
  final String? inputHint;
  final String? leadingUnit;
  final bool showClearButton;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;
  final CatchContractFieldConstraints? contract;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final String Function(String value)? normalizeInput;
  final P Function(Object? value) patchForValue;

  int? get effectiveMaxLength =>
      CatchContractFieldPolicy.effectiveMaxLength(contract, maxLength);

  List<TextInputFormatter>? get effectiveInputFormatters =>
      CatchContractFieldPolicy.effectiveInputFormatters(
        contract,
        inputFormatters,
        explicitMaxLength: maxLength,
      );

  String? validate(String value) => CatchContractFieldPolicy.validateText(
    copy: validationCopy,
    label: label,
    value: value,
    contract: contract,
    explicitValidator: validator,
  );

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    assert(
      maxLength == null ||
          contract?.maxLength == null ||
          maxLength! <= contract!.maxLength!,
      'An explicit maxLength cannot exceed the schema contract.',
    );
    return CatchFormTextRowEditor<P>(
      key: ValueKey('catch-form-text-$id'),
      descriptor: this,
      scope: scope,
      errorText: errorText,
    );
  }
}

final class CatchFormSingleChoiceRow<P, T> extends CatchFormRowDescriptor<P> {
  const CatchFormSingleChoiceRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.values,
    required this.itemLabel,
    required this.value,
    required this.patchForValue,
    this.fieldName,
    this.emptyValueText,
    this.helperText,
    this.itemAccent,
    this.contractValue,
    this.allowEmptySelection = true,
    this.showOptionalLabel = false,
    this.contract,
  });

  final List<T> values;
  final String Function(T value) itemLabel;
  final T? value;
  final String? fieldName;
  final String? emptyValueText;
  final String? helperText;
  final Color? Function(T item)? itemAccent;
  final String Function(T value)? contractValue;
  final bool allowEmptySelection;
  final bool showOptionalLabel;
  final CatchContractFieldConstraints? contract;
  final P Function(T? value) patchForValue;

  @override
  String get accordionKey => fieldName ?? id;

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    assert(
      contract?.enumValues == null || contractValue != null,
      'Schema-enumerated single-choice rows require contractValue.',
    );
    return CatchFormSingleChoiceRowEditor<P, T>(
      key: ValueKey('catch-form-single-choice-$id'),
      descriptor: this,
      scope: scope,
      errorText: errorText,
    );
  }
}

final class CatchFormMultiChoiceRow<P, T> extends CatchFormRowDescriptor<P> {
  const CatchFormMultiChoiceRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.values,
    required this.itemLabel,
    required this.selected,
    required this.patchForValues,
    this.fieldName,
    this.emptyValueText,
    this.helperText,
    this.itemAccent,
    this.contractValue,
    this.isAddAffordanceWhenEmpty = true,
    this.allowEmptySelection = true,
    this.showOptionalLabel = false,
    this.contract,
  });

  final List<T> values;
  final String Function(T value) itemLabel;
  final List<T> selected;
  final String? fieldName;
  final String? emptyValueText;
  final String? helperText;
  final Color? Function(T item)? itemAccent;
  final String Function(T value)? contractValue;
  final bool isAddAffordanceWhenEmpty;
  final bool allowEmptySelection;
  final bool showOptionalLabel;
  final CatchContractFieldConstraints? contract;
  final P Function(List<T> values) patchForValues;

  @override
  String get accordionKey => fieldName ?? id;

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    assert(
      contract?.itemEnumValues == null || contractValue != null,
      'Schema-enumerated multi-choice rows require contractValue.',
    );
    return CatchFormMultiChoiceRowEditor<P, T>(
      key: ValueKey('catch-form-multi-choice-$id'),
      descriptor: this,
      scope: scope,
      errorText: errorText,
    );
  }
}

final class CatchFormRangeRow<P> extends CatchFormRowDescriptor<P> {
  const CatchFormRangeRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.value,
    required this.currentMin,
    required this.currentMax,
    required this.sliderMin,
    required this.sliderMax,
    required this.divisions,
    required this.labelText,
    required this.patchForRange,
    this.contract,
  });

  final String value;
  final int currentMin;
  final int currentMax;
  final double sliderMin;
  final double sliderMax;
  final int divisions;
  final String Function(double value) labelText;
  final CatchContractFieldConstraints? contract;
  final P Function(int min, int max) patchForRange;

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    assert(
      contract?.minimum == null || sliderMin >= contract!.minimum!,
      'The slider minimum cannot undercut the schema contract.',
    );
    assert(
      contract?.maximum == null || sliderMax <= contract!.maximum!,
      'The slider maximum cannot exceed the schema contract.',
    );
    return CatchFormRangeRowEditor<P>(
      key: ValueKey('catch-form-range-$id'),
      descriptor: this,
      scope: scope,
      errorText: errorText,
    );
  }
}

final class CatchFormCustomRow<P> extends CatchFormRowDescriptor<P> {
  const CatchFormCustomRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.build,
    this.fieldName,
    this.contract,
  });

  final String? fieldName;
  final CatchContractFieldConstraints? contract;
  final Widget Function(BuildContext context, CatchFormRowScope<P> scope) build;

  @override
  String get accordionKey => fieldName ?? id;

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    return build(context, scope);
  }
}
