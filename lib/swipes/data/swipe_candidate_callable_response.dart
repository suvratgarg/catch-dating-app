import 'package:catch_dating_app/public_profile/data/public_profile_callable_response.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';

/// Typed response for the server-owned `fetchSwipeCandidates` callable.
final class FetchSwipeCandidatesCallableResponse {
  const FetchSwipeCandidatesCallableResponse({required this.profiles});

  factory FetchSwipeCandidatesCallableResponse.fromCallableData(Object? data) {
    return FetchSwipeCandidatesCallableResponse(
      profiles: publicProfilesFromCallableResponse(
        data,
        callableName: 'fetchSwipeCandidates',
      ),
    );
  }

  final List<PublicProfile> profiles;
}
