/// Presentation-neutral field constraints supplied by an app.
///
/// The app owns schema projection and the concrete field paths and values.
class CatchContractFieldConstraints {
  const CatchContractFieldConstraints({
    required this.path,
    this.maxLength,
    this.minLength,
    this.required = false,
    this.valueTypes,
    this.format,
    this.pattern,
    this.enumValues,
    this.itemValueTypes,
    this.itemEnumValues,
    this.minItems,
    this.maxItems,
    this.uniqueItems = false,
    this.minimum,
    this.maximum,
    this.multipleOf,
  });

  final String path;
  final int? maxLength;
  final int? minLength;
  final bool required;
  final List<String>? valueTypes;
  final String? format;
  final String? pattern;
  final List<String>? enumValues;
  final List<String>? itemValueTypes;
  final List<String>? itemEnumValues;
  final int? minItems;
  final int? maxItems;
  final bool uniqueItems;
  final num? minimum;
  final num? maximum;
  final num? multipleOf;
}
