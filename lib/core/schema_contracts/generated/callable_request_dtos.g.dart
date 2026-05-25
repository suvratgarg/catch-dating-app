// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names

// Typed callable request DTOs emitted from contracts/callables/ and
// contracts/patches/. The toJson() output of each class is validated against
// the corresponding JSON Schema by test/core/callable_dto_contracts_test.dart.
//
// Hand-written DTOs in lib/**/data/*_callable_dtos.dart may still exist for
// schemas that this generator cannot yet emit (nested objects, anyOf with
// multiple non-null branches, Timestamp serialization quirks); see backlog
// item CONTRACT-DART-GEN-001.

/// Callable payload accepted by createClub.
final class CreateClubCallableRequest {
  const CreateClubCallableRequest({
    this.clubId,
    required this.name,
    required this.description,
    required this.location,
    required this.area,
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
  final String? location;
  final String area;
  final String? imageUrl;
  final String? profileImageUrl;
  final String? instagramHandle;
  final String? phoneNumber;
  final String? email;
  final Map<String, Object?>? hostDefaults;

  Map<String, Object?> toJson() => {
    'clubId': ?clubId,
    'name': name,
    'description': description,
    'location': location,
    'area': area,
    'imageUrl': ?imageUrl,
    'profileImageUrl': ?profileImageUrl,
    'instagramHandle': ?instagramHandle,
    'phoneNumber': ?phoneNumber,
    'email': ?email,
    'hostDefaults': ?hostDefaults,
  };
}

/// Callable payload accepted by updateClub.
final class UpdateClubCallableRequest {
  const UpdateClubCallableRequest({
    required this.clubId,
    required this.fields,
  });

  final String clubId;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
    'fields': fields,
  };
}

/// Callable payload accepted by addClubHost.
final class AddClubHostCallableRequest {
  const AddClubHostCallableRequest({
    required this.clubId,
    this.uid,
    this.phoneNumber,
  });

  final String clubId;
  final String? uid;
  final String? phoneNumber;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
    'uid': ?uid,
    'phoneNumber': ?phoneNumber,
  };
}

/// Callable payload accepted by removeClubHost.
final class RemoveClubHostCallableRequest {
  const RemoveClubHostCallableRequest({
    required this.clubId,
    required this.uid,
  });

  final String clubId;
  final String uid;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
    'uid': uid,
  };
}

/// Callable payload accepted by transferClubOwnership.
final class TransferClubOwnershipCallableRequest {
  const TransferClubOwnershipCallableRequest({
    required this.clubId,
    required this.uid,
  });

  final String clubId;
  final String uid;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
    'uid': uid,
  };
}

/// Callable payload accepted by startClubHostConversation.
final class StartClubHostConversationCallableRequest {
  const StartClubHostConversationCallableRequest({
    required this.clubId,
    required this.hostUid,
  });

  final String clubId;
  final String hostUid;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
    'hostUid': hostUid,
  };
}

/// Callable payload accepted by archiveClub.
final class ArchiveClubCallableRequest {
  const ArchiveClubCallableRequest({
    required this.clubId,
    this.reason,
  });

  final String clubId;
  final String? reason;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
    'reason': ?reason,
  };
}

/// Callable payload accepted by deleteClub.
final class DeleteClubCallableRequest {
  const DeleteClubCallableRequest({
    required this.clubId,
  });

  final String clubId;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
  };
}

/// Callable payload accepted by joinClub and leaveClub.
final class ClubMembershipCallableRequest {
  const ClubMembershipCallableRequest({
    required this.clubId,
  });

  final String clubId;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
  };
}

/// Callable payload accepted by setClubNotificationPreference.
final class SetClubNotificationPreferenceCallableRequest {
  const SetClubNotificationPreferenceCallableRequest({
    required this.clubId,
    required this.enabled,
  });

  final String clubId;
  final bool enabled;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
    'enabled': enabled,
  };
}

/// Callable payload accepted by createEvent.
final class CreateEventCallableRequest {
  const CreateEventCallableRequest({
    this.eventId,
    required this.clubId,
    required this.startTimeMillis,
    required this.endTimeMillis,
    required this.meetingPoint,
    this.meetingLocation,
    required this.startingPointLat,
    required this.startingPointLng,
    this.locationDetails,
    this.photoUrl,
    required this.distanceKm,
    required this.pace,
    required this.capacityLimit,
    required this.description,
    required this.priceInPaise,
    this.currency,
    this.eventPolicy,
    this.privateAccess,
    this.eventFormat,
    this.eventSuccessDefaults,
    this.constraints,
  });

  final String? eventId;
  final String clubId;
  final int startTimeMillis;
  final int endTimeMillis;
  final String meetingPoint;
  final Map<String, Object?>? meetingLocation;
  final double startingPointLat;
  final double startingPointLng;
  final String? locationDetails;
  final String? photoUrl;
  final double distanceKm;
  final String pace;
  final int capacityLimit;
  final String description;
  final int priceInPaise;
  final String? currency;
  final Map<String, Object?>? eventPolicy;
  final Map<String, Object?>? privateAccess;
  final Map<String, Object?>? eventFormat;
  final Map<String, Object?>? eventSuccessDefaults;
  final Map<String, Object?>? constraints;

  Map<String, Object?> toJson() => {
    'eventId': ?eventId,
    'clubId': clubId,
    'startTimeMillis': startTimeMillis,
    'endTimeMillis': endTimeMillis,
    'meetingPoint': meetingPoint,
    'meetingLocation': ?meetingLocation,
    'startingPointLat': startingPointLat,
    'startingPointLng': startingPointLng,
    'locationDetails': ?locationDetails,
    'photoUrl': ?photoUrl,
    'distanceKm': distanceKm,
    'pace': pace,
    'capacityLimit': capacityLimit,
    'description': description,
    'priceInPaise': priceInPaise,
    'currency': ?currency,
    'eventPolicy': ?eventPolicy,
    'privateAccess': ?privateAccess,
    'eventFormat': ?eventFormat,
    'eventSuccessDefaults': ?eventSuccessDefaults,
    'constraints': ?constraints,
  };
}

/// Callable payload accepted by updateEvent.
final class UpdateEventCallableRequest {
  const UpdateEventCallableRequest({
    required this.eventId,
    required this.fields,
  });

  final String eventId;
  final Map<String, Object?> fields;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'fields': fields,
  };
}

/// Callable payload accepted by cancelEvent.
final class CancelEventCallableRequest {
  const CancelEventCallableRequest({
    required this.eventId,
    this.reason,
  });

  final String eventId;
  final String? reason;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'reason': ?reason,
  };
}

/// Callable payload accepted by deleteEvent.
final class DeleteEventCallableRequest {
  const DeleteEventCallableRequest({
    required this.eventId,
  });

  final String eventId;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
  };
}

/// Callable payload accepted by simple event actions that need only an eventId (plus optional inviteCode for invite-gated events).
final class EventIdCallableRequest {
  const EventIdCallableRequest({
    required this.eventId,
    this.inviteCode,
  });

  final String eventId;
  final String? inviteCode;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'inviteCode': ?inviteCode,
  };
}

/// Callable payload accepted by markEventAttendance.
final class MarkEventAttendanceCallableRequest {
  const MarkEventAttendanceCallableRequest({
    required this.eventId,
    required this.userId,
  });

  final String eventId;
  final String userId;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'userId': userId,
  };
}

/// Callable payload accepted by decideEventJoinRequest.
final class EventJoinRequestDecisionCallableRequest {
  const EventJoinRequestDecisionCallableRequest({
    required this.eventId,
    required this.userId,
    required this.decision,
  });

  final String eventId;
  final String userId;
  final String decision;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'userId': userId,
    'decision': decision,
  };
}

/// Callable payload accepted by overrideEventSuccessRotations.
final class OverrideEventSuccessRotationsCallableRequest {
  const OverrideEventSuccessRotationsCallableRequest({
    required this.eventId,
    required this.rounds,
  });

  final String eventId;
  final List<Map<String, Object?>> rounds;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'rounds': rounds,
  };
}

/// Callable payload accepted by submitEventSuccessWingmanRequest.
final class SubmitEventSuccessWingmanRequestCallableRequest {
  const SubmitEventSuccessWingmanRequestCallableRequest({
    required this.eventId,
    required this.targetUid,
    this.note,
  });

  final String eventId;
  final String targetUid;
  final String? note;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'targetUid': targetUid,
    'note': ?note,
  };
}

/// Callable payload accepted by startEventSuccessFirstHelloMission.
final class StartEventSuccessFirstHelloMissionCallableRequest {
  const StartEventSuccessFirstHelloMissionCallableRequest({
    required this.eventId,
    this.latitude,
    this.longitude,
  });

  final String eventId;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'latitude': ?latitude,
    'longitude': ?longitude,
  };
}

/// Callable payload accepted by completeEventSuccessFirstHelloMission.
final class CompleteEventSuccessFirstHelloMissionCallableRequest {
  const CompleteEventSuccessFirstHelloMissionCallableRequest({
    required this.eventId,
    required this.answerId,
    this.latitude,
    this.longitude,
  });

  final String eventId;
  final String answerId;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'answerId': answerId,
    'latitude': ?latitude,
    'longitude': ?longitude,
  };
}

/// Callable payload accepted by selfCheckInAttendance.
final class SelfCheckInAttendanceCallableRequest {
  const SelfCheckInAttendanceCallableRequest({
    required this.eventId,
    this.latitude,
    this.longitude,
  });

  final String eventId;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'latitude': ?latitude,
    'longitude': ?longitude,
  };
}

/// Callable payload accepted by createEventReview.
final class CreateEventReviewCallableRequest {
  const CreateEventReviewCallableRequest({
    required this.clubId,
    required this.eventId,
    required this.rating,
    required this.comment,
  });

  final String clubId;
  final String eventId;
  final int rating;
  final String comment;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
    'eventId': eventId,
    'rating': rating,
    'comment': comment,
  };
}

/// Callable payload accepted by updateEventReview.
final class UpdateEventReviewCallableRequest {
  const UpdateEventReviewCallableRequest({
    required this.reviewId,
    required this.rating,
    required this.comment,
  });

  final String reviewId;
  final int rating;
  final String comment;

  Map<String, Object?> toJson() => {
    'reviewId': reviewId,
    'rating': rating,
    'comment': comment,
  };
}

/// Callable payload accepted by deleteEventReview.
final class DeleteEventReviewCallableRequest {
  const DeleteEventReviewCallableRequest({
    required this.reviewId,
  });

  final String reviewId;

  Map<String, Object?> toJson() => {
    'reviewId': reviewId,
  };
}

/// Callable payload accepted by blockUser.
final class BlockUserCallableRequest {
  const BlockUserCallableRequest({
    required this.targetUserId,
    this.source,
    this.reasonCode,
  });

  final String targetUserId;
  final String? source;
  final String? reasonCode;

  Map<String, Object?> toJson() => {
    'targetUserId': targetUserId,
    'source': ?source,
    'reasonCode': ?reasonCode,
  };
}

/// Callable payload accepted by unblockUser.
final class UnblockUserCallableRequest {
  const UnblockUserCallableRequest({
    required this.targetUserId,
  });

  final String targetUserId;

  Map<String, Object?> toJson() => {
    'targetUserId': targetUserId,
  };
}

/// Callable payload accepted by reportUser.
final class ReportUserCallableRequest {
  const ReportUserCallableRequest({
    required this.targetUserId,
    this.source,
    this.reasonCode,
    this.contextId,
    this.notes,
  });

  final String targetUserId;
  final String? source;
  final String? reasonCode;
  final String? contextId;
  final String? notes;

  Map<String, Object?> toJson() => {
    'targetUserId': targetUserId,
    'source': ?source,
    'reasonCode': ?reasonCode,
    'contextId': ?contextId,
    'notes': ?notes,
  };
}

/// Callable payload accepted by requestSuvbotDemoOperation. Demo-only operations triggered from the Suvbot conversation surface.
final class RequestSuvbotDemoOperationCallableRequest {
  const RequestSuvbotDemoOperationCallableRequest({
    required this.action,
    this.text,
  });

  final String action;
  final String? text;

  Map<String, Object?> toJson() => {
    'action': action,
    'text': ?text,
  };
}

/// Callable payload accepted by verifyRazorpayPayment.
final class VerifyRazorpayPaymentCallableRequest {
  const VerifyRazorpayPaymentCallableRequest({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  final String paymentId;
  final String orderId;
  final String signature;

  Map<String, Object?> toJson() => {
    'paymentId': paymentId,
    'orderId': orderId,
    'signature': signature,
  };
}

/// Callable payload accepted by placesAutocomplete.
final class PlacesAutocompleteCallableRequest {
  const PlacesAutocompleteCallableRequest({
    required this.input,
    this.sessionToken,
    this.countryIsoCode,
    this.latitude,
    this.longitude,
  });

  final String input;
  final String? sessionToken;
  final String? countryIsoCode;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toJson() => {
    'input': input,
    'sessionToken': ?sessionToken,
    'countryIsoCode': ?countryIsoCode,
    'latitude': ?latitude,
    'longitude': ?longitude,
  };
}

/// Callable payload accepted by placeDetails.
final class PlaceDetailsCallableRequest {
  const PlaceDetailsCallableRequest({
    required this.placeId,
    this.sessionToken,
  });

  final String placeId;
  final String? sessionToken;

  Map<String, Object?> toJson() => {
    'placeId': placeId,
    'sessionToken': ?sessionToken,
  };
}
