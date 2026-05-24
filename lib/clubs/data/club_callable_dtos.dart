// Re-export generated callable request classes for clubs. Generated from
// contracts/callables/ by tool/contracts/generate_schema_contracts.mjs.
export 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show
        AddClubHostCallableRequest,
        ArchiveClubCallableRequest,
        ClubMembershipCallableRequest,
        DeleteClubCallableRequest,
        RemoveClubHostCallableRequest,
        SetClubNotificationPreferenceCallableRequest,
        StartClubHostConversationCallableRequest,
        TransferClubOwnershipCallableRequest;

final class CreateClubCallableRequest {
  const CreateClubCallableRequest({
    required this.name,
    required this.description,
    required this.location,
    required this.area,
    this.clubId,
    this.imageUrl,
    this.profileImageUrl,
    this.instagramHandle,
    this.phoneNumber,
    this.email,
    this.hostDefaults,
  });

  final String? clubId;
  final String name;
  final String description;
  final String location;
  final String area;
  final String? imageUrl;
  final String? profileImageUrl;
  final String? instagramHandle;
  final String? phoneNumber;
  final String? email;
  final Map<String, Object?>? hostDefaults;

  Map<String, Object?> toJson() => {
    if (clubId != null) 'clubId': clubId,
    'name': name,
    'description': description,
    'location': location,
    'area': area,
    'imageUrl': imageUrl,
    'profileImageUrl': profileImageUrl,
    'instagramHandle': instagramHandle,
    'phoneNumber': phoneNumber,
    'email': email,
    'hostDefaults': ?hostDefaults,
  };
}

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

final class UpdateClubCallableRequest {
  const UpdateClubCallableRequest({required this.clubId, required this.fields});

  final String clubId;
  final Map<String, dynamic> fields;

  Map<String, Object?> toJson() => {'clubId': clubId, 'fields': fields};
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
