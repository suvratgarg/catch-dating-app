import 'package:catch_dating_app/public_profile/data/public_profile_callable_response.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';

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
  ) => FetchEventSuccessWingmanCandidatesCallableResponse(
    profiles: publicProfilesFromCallableResponse(
      data,
      callableName: 'fetchEventSuccessWingmanCandidates',
    ),
  );

  final List<PublicProfile> profiles;
}
