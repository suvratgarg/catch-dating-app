import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_participation.freezed.dart';
part 'event_participation.g.dart';

enum EventParticipationStatus {
  signedUp,
  waitlisted,
  attended,
  cancelled,
  deleted,
}

enum EventJoinRequestStatus { pending, approved, declined }

@freezed
abstract class EventParticipation with _$EventParticipation {
  const EventParticipation._();

  const factory EventParticipation({
    @JsonKey(includeToJson: false) required String id,
    required String eventId,
    required String clubId,
    required String uid,
    required EventParticipationStatus status,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @NullableTimestampConverter() DateTime? signedUpAt,
    @NullableTimestampConverter() DateTime? waitlistedAt,
    @NullableTimestampConverter() DateTime? attendedAt,
    @NullableTimestampConverter() DateTime? cancelledAt,
    @NullableTimestampConverter() DateTime? deletedAt,
    @JsonKey() Gender? genderAtSignup,
    String? cohortAtSignup,
    String? paymentId,
    @JsonKey() EventJoinRequestStatus? hostApprovalStatus,
    @NullableTimestampConverter() DateTime? hostApprovalDecidedAt,
    String? hostApprovalDecidedBy,
  }) = _EventParticipation;

  factory EventParticipation.fromJson(Map<String, dynamic> json) =>
      _$EventParticipationFromJson(json);

  bool get hasHostApproval =>
      hostApprovalStatus == EventJoinRequestStatus.approved;
}

String eventParticipationId({required String eventId, required String uid}) =>
    '${eventId}_$uid';
