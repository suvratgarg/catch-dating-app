// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_participation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventParticipation _$EventParticipationFromJson(Map<String, dynamic> json) =>
    _EventParticipation(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      clubId: json['clubId'] as String,
      uid: json['uid'] as String,
      status: $enumDecode(_$EventParticipationStatusEnumMap, json['status']),
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

Map<String, dynamic> _$EventParticipationToJson(
  _EventParticipation instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'clubId': instance.clubId,
  'uid': instance.uid,
  'status': _$EventParticipationStatusEnumMap[instance.status]!,
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

const _$EventParticipationStatusEnumMap = {
  EventParticipationStatus.signedUp: 'signedUp',
  EventParticipationStatus.waitlisted: 'waitlisted',
  EventParticipationStatus.attended: 'attended',
  EventParticipationStatus.cancelled: 'cancelled',
  EventParticipationStatus.deleted: 'deleted',
};

const _$GenderEnumMap = {
  Gender.man: 'man',
  Gender.woman: 'woman',
  Gender.nonBinary: 'nonBinary',
  Gender.other: 'other',
};
