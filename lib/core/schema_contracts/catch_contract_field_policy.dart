import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Runtime policy derived from one generated JSON Schema field contract.
///
/// Product surfaces still own labels, layout, and save orchestration. This
/// policy owns reusable validation and input bounds so a UI cannot silently
/// accept values that the authoritative schema rejects.
abstract final class CatchContractFieldPolicy {
  static int? effectiveMaxLength(
    CatchContractFieldConstraints? contract,
    int? explicitMaxLength,
  ) {
    final contractMax = contract?.maxLength;
    assert(
      explicitMaxLength == null ||
          contractMax == null ||
          explicitMaxLength <= contractMax,
      'An explicit maxLength cannot exceed the schema contract.',
    );
    if (explicitMaxLength == null) return contractMax;
    if (contractMax == null) return explicitMaxLength;
    return explicitMaxLength < contractMax ? explicitMaxLength : contractMax;
  }

  static List<TextInputFormatter>? effectiveInputFormatters(
    CatchContractFieldConstraints? contract,
    List<TextInputFormatter>? explicitFormatters, {
    int? explicitMaxLength,
  }) {
    final maxLength = effectiveMaxLength(contract, explicitMaxLength);
    if (maxLength == null) return explicitFormatters;
    return <TextInputFormatter>[
      ...?explicitFormatters,
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static String? validateText(
    BuildContext context, {
    required String label,
    required String value,
    CatchContractFieldConstraints? contract,
    FormFieldValidator<String>? explicitValidator,
  }) {
    final explicitError = explicitValidator?.call(value);
    if (explicitError != null) return explicitError;
    if (contract == null) return null;

    if (contract.required && value.trim().isEmpty) {
      return context.l10n.coreCatchFormValidationRequired(field: label);
    }
    final minLength = contract.minLength;
    if (value.isNotEmpty && minLength != null && value.length < minLength) {
      return context.l10n.coreCatchFormValidationMinLength(
        field: label,
        minLength: minLength,
      );
    }
    final maxLength = contract.maxLength;
    if (maxLength != null && value.length > maxLength) {
      return context.l10n.coreCatchFormValidationMaxLength(
        field: label,
        maxLength: maxLength,
      );
    }
    final pattern = contract.pattern;
    if (value.isNotEmpty &&
        pattern != null &&
        !RegExp(pattern).hasMatch(value)) {
      return context.l10n.coreCatchFormValidationPattern(field: label);
    }
    return null;
  }

  static num? effectiveMinimum(
    CatchContractFieldConstraints? contract,
    num? explicitMinimum,
  ) {
    final contractMinimum = contract?.minimum;
    assert(
      explicitMinimum == null ||
          contractMinimum == null ||
          explicitMinimum >= contractMinimum,
      'An explicit minimum cannot undercut the schema contract.',
    );
    if (explicitMinimum == null) return contractMinimum;
    if (contractMinimum == null) return explicitMinimum;
    return explicitMinimum > contractMinimum
        ? explicitMinimum
        : contractMinimum;
  }

  static num? effectiveMaximum(
    CatchContractFieldConstraints? contract,
    num? explicitMaximum,
  ) {
    final contractMaximum = contract?.maximum;
    assert(
      explicitMaximum == null ||
          contractMaximum == null ||
          explicitMaximum <= contractMaximum,
      'An explicit maximum cannot exceed the schema contract.',
    );
    if (explicitMaximum == null) return contractMaximum;
    if (contractMaximum == null) return explicitMaximum;
    return explicitMaximum < contractMaximum
        ? explicitMaximum
        : contractMaximum;
  }

  static num effectiveStep(
    CatchContractFieldConstraints? contract,
    num? explicitStep,
  ) {
    final contractStep = contract?.multipleOf;
    assert(
      explicitStep == null ||
          contractStep == null ||
          _isMultiple(explicitStep, contractStep),
      'An explicit step must be a multiple of the schema contract.',
    );
    if (explicitStep == null) return contractStep ?? 1;
    return contractStep == null || explicitStep > contractStep
        ? explicitStep
        : contractStep;
  }

  static List<T> supportedChoiceValues<T>(
    CatchContractFieldConstraints? contract,
    List<T> values,
    String Function(T value)? contractValue, {
    required bool multi,
  }) {
    final allowed = multi ? contract?.itemEnumValues : contract?.enumValues;
    if (allowed == null || contractValue == null) return values;
    final allowedSet = allowed.toSet();
    return values
        .where((value) => allowedSet.contains(contractValue(value)))
        .toList(growable: false);
  }

  static bool _isMultiple(num value, num divisor) {
    if (divisor == 0) return false;
    final quotient = value / divisor;
    return (quotient - quotient.round()).abs() < 0.0000001;
  }
}
