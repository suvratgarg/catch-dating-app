import 'package:catch_ui/src/components/catch_field_label_text.dart';
import 'package:catch_ui/src/components/catch_form_validation_copy.dart';

/// Caller-resolved labels, messages and formatters for every field recipe.
///
/// The caller owns locale-specific grammar and casing. Visible save progress
/// and screen-reader announcements remain separate messages.
class CatchFieldCopy {
  const CatchFieldCopy({
    required this.label,
    required this.validation,
    required this.cancelLabel,
    required this.doneLabel,
    required this.savingLabel,
    required this.savingSemanticLabel,
    required this.savedSemanticLabel,
    required this.emptyValueText,
    required this.selectPlaceholder,
    required this.clearTooltip,
    this.clearLabel,
  });

  /// Override caller-resolved action copy without changing other field grammar.
  CatchFieldCopy copyWith({String? doneLabel}) => CatchFieldCopy(
    label: label,
    validation: validation,
    cancelLabel: cancelLabel,
    doneLabel: doneLabel ?? this.doneLabel,
    savingLabel: savingLabel,
    savingSemanticLabel: savingSemanticLabel,
    savedSemanticLabel: savedSemanticLabel,
    emptyValueText: emptyValueText,
    selectPlaceholder: selectPlaceholder,
    clearTooltip: clearTooltip,
    clearLabel: clearLabel,
  );

  final CatchFieldLabelTextCopy label;
  final CatchFormValidationCopy validation;
  final String cancelLabel;
  final String doneLabel;

  /// Localized explicit commit action for removing an optional value.
  final String? clearLabel;
  final String savingLabel;
  final String savingSemanticLabel;
  final String savedSemanticLabel;
  final String Function(String title) emptyValueText;
  final String Function(String? title) selectPlaceholder;
  final String Function(String? title) clearTooltip;
}
