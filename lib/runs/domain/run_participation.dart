import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_participation.freezed.dart';
part 'run_participation.g.dart';

enum RunParticipationStatus {
  signedUp,
  waitlisted,
  attended,
  cancelled,
  deleted,
}

@freezed
abstract class RunParticipation with _$RunParticipation {
  const factory RunParticipation({
    @JsonKey(includeToJson: false) required String id,
    required String runId,
    required String runClubId,
    required String uid,
    required RunParticipationStatus status,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @NullableTimestampConverter() DateTime? signedUpAt,
    @NullableTimestampConverter() DateTime? waitlistedAt,
    @NullableTimestampConverter() DateTime? attendedAt,
    @NullableTimestampConverter() DateTime? cancelledAt,
    @NullableTimestampConverter() DateTime? deletedAt,
    @JsonKey(unknownEnumValue: null) Gender? genderAtSignup,
    String? paymentId,
  }) = _RunParticipation;

  factory RunParticipation.fromJson(Map<String, dynamic> json) =>
      _$RunParticipationFromJson(json);
}

String runParticipationId({required String runId, required String uid}) =>
    '${runId}_$uid';
