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

final class CreateOrganizerCallableResponse {
  const CreateOrganizerCallableResponse({required this.organizerId});

  factory CreateOrganizerCallableResponse.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final organizerId = map['organizerId'] as String?;
      if (organizerId != null && organizerId.isNotEmpty) {
        return CreateOrganizerCallableResponse(organizerId: organizerId);
      }
    }
    throw StateError('createOrganizer response was missing organizerId.');
  }

  final String organizerId;
}

final class CreateClubPostCallableResponse {
  const CreateClubPostCallableResponse({
    required this.postId,
    required this.remainingWeeklyQuota,
  });

  factory CreateClubPostCallableResponse.fromCallableData(Object? data) {
    if (data case final Map<Object?, Object?> map) {
      final postId = map['postId'] as String?;
      final remainingWeeklyQuota = map['remainingWeeklyQuota'] as int?;
      if (postId != null && postId.isNotEmpty && remainingWeeklyQuota != null) {
        return CreateClubPostCallableResponse(
          postId: postId,
          remainingWeeklyQuota: remainingWeeklyQuota,
        );
      }
    }

    throw StateError(
      'createClubPost response was missing postId or remainingWeeklyQuota.',
    );
  }

  final String postId;
  final int remainingWeeklyQuota;
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
