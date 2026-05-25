// Re-export generated callable request classes for clubs. Generated from
// contracts/callables/ by tool/contracts/generate_schema_contracts.mjs.
export 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show
        AddClubHostCallableRequest,
        ArchiveClubCallableRequest,
        ClubMembershipCallableRequest,
        CreateClubCallableRequest,
        DeleteClubCallableRequest,
        RemoveClubHostCallableRequest,
        SetClubNotificationPreferenceCallableRequest,
        StartClubHostConversationCallableRequest,
        TransferClubOwnershipCallableRequest,
        UpdateClubCallableRequest;

final class CreateClubCallableResponse {
  const CreateClubCallableResponse({required this.clubId});

  factory CreateClubCallableResponse.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final clubId = map['clubId'] as String?;
      if (clubId != null && clubId.isNotEmpty) {
        return CreateClubCallableResponse(clubId: clubId);
      }
    }

    throw StateError('createClub response was missing clubId.');
  }

  final String clubId;
}

final class StartClubHostConversationCallableResponse {
  const StartClubHostConversationCallableResponse({required this.matchId});

  factory StartClubHostConversationCallableResponse.fromCallableData(
    Object? data,
  ) {
    if (data case final Map<Object?, Object?> map) {
      final matchId = map['matchId'] as String?;
      if (matchId != null && matchId.isNotEmpty) {
        return StartClubHostConversationCallableResponse(matchId: matchId);
      }
    }

    throw StateError('startClubHostConversation response was missing matchId.');
  }

  final String matchId;
}
