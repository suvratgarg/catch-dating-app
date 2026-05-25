import 'package:catch_dating_app/user_profile/domain/update_user_profile_patch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Wire payload for `updateUserProfile`. Wraps a typed
/// [UpdateUserProfilePatch] so callers cannot pass arbitrary maps. The legacy
/// `Map<String, dynamic>` constructor remains for transitional call sites and
/// applies the same Timestamp/DateTime → millis normalization.
final class UpdateUserProfileCallableRequest {
  const UpdateUserProfileCallableRequest.fromPatch(this._patch)
    : _legacyFields = null;

  const UpdateUserProfileCallableRequest.fromLegacyFields(
    Map<String, dynamic> fields,
  ) : _patch = null,
      _legacyFields = fields;

  final UpdateUserProfilePatch? _patch;
  final Map<String, dynamic>? _legacyFields;

  Map<String, Object?> toJson() => {
    'fields': _patch != null
        ? _patch.toFieldsJson()
        : _callableFields(_legacyFields!),
  };
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
