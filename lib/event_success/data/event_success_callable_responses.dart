import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Typed response for the `fetchEventSuccessWingmanCandidates` callable.
///
/// Validated by `test/core/callable_dto_contracts_test.dart` against
/// `contracts/callable_responses/fetch_event_success_wingman_candidates_response.schema.json`.
final class FetchEventSuccessWingmanCandidatesCallableResponse {
  const FetchEventSuccessWingmanCandidatesCallableResponse({
    required this.profiles,
  });

  factory FetchEventSuccessWingmanCandidatesCallableResponse.fromCallableData(
    Object? data,
  ) {
    if (data case final Map<Object?, Object?> map) {
      final profiles = map['profiles'];
      if (profiles is List<Object?>) {
        return FetchEventSuccessWingmanCandidatesCallableResponse(
          profiles: profiles
              .whereType<Map<Object?, Object?>>()
              .map((raw) => PublicProfile.fromJson(_publicProfileJson(raw)))
              .toList(growable: false),
        );
      }
    }

    throw StateError(
      'fetchEventSuccessWingmanCandidates response was malformed.',
    );
  }

  final List<PublicProfile> profiles;
}

Map<String, dynamic> _publicProfileJson(Map<Object?, Object?> raw) {
  final profile = Map<String, dynamic>.from(raw);
  final photos = profile['profilePhotos'];
  if (photos is List<Object?>) {
    profile['profilePhotos'] = photos
        .map((photo) {
          if (photo is! Map<Object?, Object?>) return photo;
          final normalized = Map<String, dynamic>.from(photo);
          normalized['createdAt'] = _timestampFromCallableJson(
            normalized['createdAt'],
          );
          normalized['updatedAt'] = _timestampFromCallableJson(
            normalized['updatedAt'],
          );

          final moderation = normalized['moderation'];
          if (moderation is Map<Object?, Object?>) {
            final normalizedModeration = Map<String, dynamic>.from(moderation);
            normalizedModeration['reviewedAt'] = _timestampFromCallableJson(
              normalizedModeration['reviewedAt'],
            );
            normalized['moderation'] = normalizedModeration;
          }

          return normalized;
        })
        .toList(growable: false);
  }
  return profile;
}

Object? _timestampFromCallableJson(Object? value) {
  if (value == null || value is Timestamp) return value;
  if (value case final Map<Object?, Object?> map) {
    final seconds = map['_seconds'] ?? map['seconds'];
    final nanoseconds = map['_nanoseconds'] ?? map['nanoseconds'];
    if (seconds is num && nanoseconds is num) {
      return Timestamp(seconds.toInt(), nanoseconds.toInt());
    }
  }
  return value;
}
