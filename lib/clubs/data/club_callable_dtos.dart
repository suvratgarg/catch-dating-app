final class CreateClubCallableRequest {
  const CreateClubCallableRequest({
    required this.name,
    required this.description,
    required this.location,
    required this.area,
    this.clubId,
    this.imageUrl,
    this.instagramHandle,
    this.phoneNumber,
    this.email,
  });

  final String? clubId;
  final String name;
  final String description;
  final String location;
  final String area;
  final String? imageUrl;
  final String? instagramHandle;
  final String? phoneNumber;
  final String? email;

  Map<String, Object?> toJson() => {
    if (clubId != null) 'clubId': clubId,
    'name': name,
    'description': description,
    'location': location,
    'area': area,
    'imageUrl': imageUrl,
    'instagramHandle': instagramHandle,
    'phoneNumber': phoneNumber,
    'email': email,
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

final class ClubIdCallableRequest {
  const ClubIdCallableRequest(this.clubId);

  final String clubId;

  Map<String, Object?> toJson() => {'clubId': clubId};
}

final class SetClubNotificationPreferenceCallableRequest {
  const SetClubNotificationPreferenceCallableRequest({
    required this.clubId,
    required this.enabled,
  });

  final String clubId;
  final bool enabled;

  Map<String, Object?> toJson() => {'clubId': clubId, 'enabled': enabled};
}
