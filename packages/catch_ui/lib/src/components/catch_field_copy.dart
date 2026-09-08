import 'package:catch_ui/src/components/catch_form_field_label.dart';
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
  });

  final CatchFormFieldLabelCopy label;
  final CatchFormValidationCopy validation;
  final String cancelLabel;
  final String doneLabel;
  final String savingLabel;
  final String savingSemanticLabel;
  final String savedSemanticLabel;
  final String Function(String title) emptyValueText;
  final String Function(String? title) selectPlaceholder;
  final String Function(String? title) clearTooltip;
}
