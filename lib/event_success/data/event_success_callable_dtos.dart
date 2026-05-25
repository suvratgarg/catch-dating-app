import 'package:catch_dating_app/public_profile/domain/public_profile.dart';

// Re-export generated callable request classes for event_success operations.
export 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show
        CompleteEventSuccessFirstHelloMissionCallableRequest,
        OverrideEventSuccessGroupsCallableRequest,
        OverrideEventSuccessRotationsCallableRequest,
        StartEventSuccessFirstHelloMissionCallableRequest,
        SubmitEventSuccessWingmanRequestCallableRequest;

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
              .map(
                (raw) => PublicProfile.fromJson(Map<String, dynamic>.from(raw)),
              )
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
