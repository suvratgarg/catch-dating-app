// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/sentinels.dart';


// Typed callable request DTO emitted from callables/update_club_payload.schema.json.
// Re-exported by lib/core/schema_contracts/generated/callable_request_dtos.g.dart.

/// Typed patch helper generated from Callable payload accepted by updateClub.
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
    List<String>? tags,
    Object? instagramHandle = unsetSentinel,
    Object? phoneNumber = unsetSentinel,
    Object? email = unsetSentinel,
    ClubHostDefaults? hostDefaults,
  }) : _fields = {
         if (name != null)
           'name': name,
         if (description != null)
           'description': description,
         if (!identical(location, unsetSentinel))
           'location': location,
         if (area != null)
           'area': area,
         if (hostName != null)
           'hostName': hostName,
         if (!identical(hostAvatarUrl, unsetSentinel))
           'hostAvatarUrl': hostAvatarUrl,
         if (!identical(imageUrl, unsetSentinel))
           'imageUrl': imageUrl,
         if (!identical(profileImageUrl, unsetSentinel))
           'profileImageUrl': profileImageUrl,
         if (tags != null)
           'tags': tags.map((e) => e).toList(),
         if (!identical(instagramHandle, unsetSentinel))
           'instagramHandle': instagramHandle,
         if (!identical(phoneNumber, unsetSentinel))
           'phoneNumber': phoneNumber,
         if (!identical(email, unsetSentinel))
           'email': email,
         if (hostDefaults != null)
           'hostDefaults': hostDefaults.toJson(),
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

  Map<String, Object?> toCallableJson({
    required String clubId,
  }) => {
    'clubId': clubId,
    'fields': toFieldsJson(),
  };
}
