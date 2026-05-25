import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';

/// Typed patch payload for `updateClub`. Replaces the prior
/// `Map<String, dynamic> fields` API with named, type-checked optional fields.
///
/// Mirrors the `fields` shape inside
/// `contracts/callables/update_club_payload.schema.json`. Parity is asserted by
/// `test/core/update_club_patch_test.dart`.
final class UpdateClubPatch {
  UpdateClubPatch({
    String? name,
    String? description,
    String? location,
    String? area,
    String? hostName,
    Object? hostAvatarUrl = _unset,
    Object? imageUrl = _unset,
    Object? profileImageUrl = _unset,
    List<String>? tags,
    Object? instagramHandle = _unset,
    Object? phoneNumber = _unset,
    Object? email = _unset,
    ClubHostDefaults? hostDefaults,
  }) : _fields = {
         if (name != null) 'name': name,
         if (description != null) 'description': description,
         if (location != null) 'location': location,
         if (area != null) 'area': area,
         if (hostName != null) 'hostName': hostName,
         if (!identical(hostAvatarUrl, _unset)) 'hostAvatarUrl': hostAvatarUrl,
         if (!identical(imageUrl, _unset)) 'imageUrl': imageUrl,
         if (!identical(profileImageUrl, _unset))
           'profileImageUrl': profileImageUrl,
         if (tags != null) 'tags': tags,
         if (!identical(instagramHandle, _unset))
           'instagramHandle': instagramHandle,
         if (!identical(phoneNumber, _unset)) 'phoneNumber': phoneNumber,
         if (!identical(email, _unset)) 'email': email,
         if (hostDefaults != null) 'hostDefaults': hostDefaults.toJson(),
       };

  /// Escape hatch for dynamic callers; field names still pass through the
  /// Functions Ajv validator at the server boundary and the schema-parity
  /// test catches typos.
  UpdateClubPatch.raw(Map<String, Object?> fields)
    : _fields = Map<String, Object?>.from(fields);

  final Map<String, Object?> _fields;

  Iterable<String> get keys => _fields.keys;
  bool get isEmpty => _fields.isEmpty;
  bool get isNotEmpty => _fields.isNotEmpty;

  Map<String, Object?> toFieldsJson() =>
      Map<String, Object?>.unmodifiable(_fields);
}

const Object _unset = Object();
