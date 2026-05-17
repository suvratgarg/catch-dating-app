// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_participation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RunParticipation _$RunParticipationFromJson(Map<String, dynamic> json) =>
    _RunParticipation(
      id: json['id'] as String,
      runId: json['runId'] as String,
      runClubId: json['runClubId'] as String,
      uid: json['uid'] as String,
      status: $enumDecode(_$RunParticipationStatusEnumMap, json['status']),
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      updatedAt: const TimestampConverter().fromJson(
        json['updatedAt'] as Timestamp,
      ),
      signedUpAt: const NullableTimestampConverter().fromJson(
        json['signedUpAt'] as Timestamp?,
      ),
      waitlistedAt: const NullableTimestampConverter().fromJson(
        json['waitlistedAt'] as Timestamp?,
      ),
      attendedAt: const NullableTimestampConverter().fromJson(
        json['attendedAt'] as Timestamp?,
      ),
      cancelledAt: const NullableTimestampConverter().fromJson(
        json['cancelledAt'] as Timestamp?,
      ),
      deletedAt: const NullableTimestampConverter().fromJson(
        json['deletedAt'] as Timestamp?,
      ),
      genderAtSignup: $enumDecodeNullable(
        _$GenderEnumMap,
        json['genderAtSignup'],
      ),
      cohortAtSignup: json['cohortAtSignup'] as String?,
      paymentId: json['paymentId'] as String?,
    );

Map<String, dynamic> _$RunParticipationToJson(
  _RunParticipation instance,
) => <String, dynamic>{
  'runId': instance.runId,
  'runClubId': instance.runClubId,
  'uid': instance.uid,
  'status': _$RunParticipationStatusEnumMap[instance.status]!,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'signedUpAt': const NullableTimestampConverter().toJson(instance.signedUpAt),
  'waitlistedAt': const NullableTimestampConverter().toJson(
    instance.waitlistedAt,
  ),
  'attendedAt': const NullableTimestampConverter().toJson(instance.attendedAt),
  'cancelledAt': const NullableTimestampConverter().toJson(
    instance.cancelledAt,
  ),
  'deletedAt': const NullableTimestampConverter().toJson(instance.deletedAt),
  'genderAtSignup': _$GenderEnumMap[instance.genderAtSignup],
  'cohortAtSignup': instance.cohortAtSignup,
  'paymentId': instance.paymentId,
};

const _$RunParticipationStatusEnumMap = {
  RunParticipationStatus.signedUp: 'signedUp',
  RunParticipationStatus.waitlisted: 'waitlisted',
  RunParticipationStatus.attended: 'attended',
  RunParticipationStatus.cancelled: 'cancelled',
  RunParticipationStatus.deleted: 'deleted',
};

const _$GenderEnumMap = {
  Gender.man: 'man',
  Gender.woman: 'woman',
  Gender.nonBinary: 'nonBinary',
  Gender.other: 'other',
};
