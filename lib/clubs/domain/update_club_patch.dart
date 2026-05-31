// ignore_for_file: use_null_aware_elements

import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/sentinels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Typed patch helper for the `updateClub` callable.
///
/// This remains handwritten because the schema generator cannot currently emit
/// patch helpers for array fields that contain embedded objects.
final class UpdateClubPatch {
  UpdateClubPatch({
    String? name,
    String? description,
    Object? location = unsetSentinel,
    String? area,
    String? hostName,
    Object? hostAvatarUrl = unsetSentinel,
    Object? imageUrl = unsetSentinel,
    Object? profileImageUrl = unsetSentinel,
    List<UploadedPhoto>? clubPhotos,
    Object? logoPhoto = unsetSentinel,
    List<String>? tags,
    Object? instagramHandle = unsetSentinel,
    Object? phoneNumber = unsetSentinel,
    Object? email = unsetSentinel,
    ClubHostDefaults? hostDefaults,
  }) : _fields = {
         if (name != null) 'name': name,
         if (description != null) 'description': description,
         if (!identical(location, unsetSentinel)) 'location': location,
         if (area != null) 'area': area,
         if (hostName != null) 'hostName': hostName,
         if (!identical(hostAvatarUrl, unsetSentinel))
           'hostAvatarUrl': hostAvatarUrl,
         if (!identical(imageUrl, unsetSentinel)) 'imageUrl': imageUrl,
         if (!identical(profileImageUrl, unsetSentinel))
           'profileImageUrl': profileImageUrl,
         if (clubPhotos != null)
           'clubPhotos': clubPhotos
               .map((photo) => _updateClubPatchJsonValue(photo.toJson()))
               .toList(),
         if (!identical(logoPhoto, unsetSentinel))
           'logoPhoto': _updateClubPatchJsonValue(
             (logoPhoto as UploadedPhoto?)?.toJson(),
           ),
         if (tags != null) 'tags': tags,
         if (!identical(instagramHandle, unsetSentinel))
           'instagramHandle': instagramHandle,
         if (!identical(phoneNumber, unsetSentinel)) 'phoneNumber': phoneNumber,
         if (!identical(email, unsetSentinel)) 'email': email,
         if (hostDefaults != null) 'hostDefaults': hostDefaults.toJson(),
       };

  /// Escape hatch for callers that compute the field key dynamically.
  /// Prefer the typed constructor for app presentation and repository code.
  UpdateClubPatch.raw(Map<String, Object?> fields)
    : _fields = Map<String, Object?>.from(fields);

  final Map<String, Object?> _fields;

  Iterable<String> get keys => _fields.keys;

  bool get isEmpty => _fields.isEmpty;
  bool get isNotEmpty => _fields.isNotEmpty;

  Map<String, Object?> toFieldsJson() =>
      Map<String, Object?>.unmodifiable(_fields);

  Map<String, Object?> toCallableJson({required String clubId}) => {
    'clubId': clubId,
    'fields': toFieldsJson(),
  };
}

Object? _updateClubPatchJsonValue(Object? value) {
  if (value is Timestamp) {
    return {'_seconds': value.seconds, '_nanoseconds': value.nanoseconds};
  }
  if (value is DateTime) {
    return _updateClubPatchJsonValue(Timestamp.fromDate(value));
  }
  if (value is Iterable) {
    return value.map(_updateClubPatchJsonValue).toList();
  }
  if (value is Map) {
    return value.map(
      (key, child) => MapEntry(key, _updateClubPatchJsonValue(child)),
    );
  }
  return value;
}
