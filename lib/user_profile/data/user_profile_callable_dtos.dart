import 'package:cloud_firestore/cloud_firestore.dart';

final class UpdateUserProfileCallableRequest {
  const UpdateUserProfileCallableRequest({required this.fields});

  final Map<String, dynamic> fields;

  Map<String, Object?> toJson() => {'fields': _callableFields(fields)};
}

Map<String, Object?> _callableFields(Map<String, dynamic> fields) =>
    fields.map((key, value) => MapEntry(key, _callableValue(value)));

Object? _callableValue(Object? value) {
  if (value is Timestamp) {
    return value.millisecondsSinceEpoch;
  }
  if (value is DateTime) {
    return value.millisecondsSinceEpoch;
  }
  if (value is Iterable) {
    return value.map(_callableValue).toList();
  }
  if (value is Map) {
    return value.map((key, child) => MapEntry(key, _callableValue(child)));
  }
  return value;
}
