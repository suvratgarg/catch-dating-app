import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Type-preserving dispatch for the six form row descriptions.
///
/// Callers choose the result type; row descriptions contain no render methods.
typedef CatchFormRowVisitor<P, R> = ({
  R Function(CatchFormReadRow<P> row) read,
  R Function(CatchFormTextRow<P> row) text,
  R Function<T>(CatchFormSingleChoiceRow<P, T> row) singleChoice,
  R Function<T>(CatchFormMultiChoiceRow<P, T> row) multiChoice,
  R Function(CatchFormRangeRow<P> row) range,
  R Function(CatchFormCustomRow<P> row) custom,
});

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

  /// Dispatches without erasing a choice row's item type or producing UI.
  R accept<R>(CatchFormRowVisitor<P, R> visitor);
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
  R accept<R>(CatchFormRowVisitor<P, R> visitor) => visitor.read(this);
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
  R accept<R>(CatchFormRowVisitor<P, R> visitor) => visitor.text(this);
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
  R accept<R>(CatchFormRowVisitor<P, R> visitor) =>
      visitor.singleChoice<T>(this);
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
  R accept<R>(CatchFormRowVisitor<P, R> visitor) =>
      visitor.multiChoice<T>(this);
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
  R accept<R>(CatchFormRowVisitor<P, R> visitor) => visitor.range(this);
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
  R accept<R>(CatchFormRowVisitor<P, R> visitor) => visitor.custom(this);
}
