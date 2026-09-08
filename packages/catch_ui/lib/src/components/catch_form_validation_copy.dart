/// Caller-resolved messages for reusable form validation.
///
/// Formatters retain locale-specific field placement and numeric grammar while
/// the validation policy owns the order in which constraints are checked.
class CatchFormValidationCopy {
  const CatchFormValidationCopy({
    required this.requiredMessage,
    required this.minLengthMessage,
    required this.maxLengthMessage,
    required this.patternMessage,
  });

  final String Function(String label) requiredMessage;
  final String Function(String label, int minLength) minLengthMessage;
  final String Function(String label, int maxLength) maxLengthMessage;
  final String Function(String label) patternMessage;
}
