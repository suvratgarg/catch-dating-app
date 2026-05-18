// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: json['id'] as String,
  clubId: json['clubId'] as String,
  startTime: const TimestampConverter().fromJson(
    json['startTime'] as Timestamp,
  ),
  endTime: const TimestampConverter().fromJson(json['endTime'] as Timestamp),
  meetingPoint: json['meetingPoint'] as String,
  startingPointLat: (json['startingPointLat'] as num?)?.toDouble(),
  startingPointLng: (json['startingPointLng'] as num?)?.toDouble(),
  locationDetails: json['locationDetails'] as String?,
  photoUrl: json['photoUrl'] as String?,
  eventFormat: json['eventFormat'] == null
      ? const EventFormatSnapshot.socialRun()
      : EventFormatSnapshot.fromJson(
          json['eventFormat'] as Map<String, dynamic>?,
        ),
  distanceKm: (json['distanceKm'] as num).toDouble(),
  pace: $enumDecode(_$PaceLevelEnumMap, json['pace']),
  capacityLimit: (json['capacityLimit'] as num).toInt(),
  description: json['description'] as String,
  priceInPaise: (json['priceInPaise'] as num).toInt(),
  bookedCount: (json['bookedCount'] as num?)?.toInt(),
  checkedInCount: (json['checkedInCount'] as num?)?.toInt(),
  waitlistedCount: (json['waitlistedCount'] as num?)?.toInt(),
  status:
      $enumDecodeNullable(_$EventLifecycleStatusEnumMap, json['status']) ??
      EventLifecycleStatus.active,
  cancelledAt: const NullableTimestampConverter().fromJson(
    json['cancelledAt'] as Timestamp?,
  ),
  cancellationReason: json['cancellationReason'] as String?,
  constraints: json['constraints'] == null
      ? const EventConstraints()
      : EventConstraints.fromJson(json['constraints'] as Map<String, dynamic>),
  eventPolicy: json['eventPolicy'] == null
      ? null
      : EventPolicyBundle.fromJson(json['eventPolicy'] as Map<String, dynamic>),
  genderCounts:
      (json['genderCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  cohortCounts:
      (json['cohortCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  waitlistedCohortCounts:
      (json['waitlistedCohortCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'clubId': instance.clubId,
  'startTime': const TimestampConverter().toJson(instance.startTime),
  'endTime': const TimestampConverter().toJson(instance.endTime),
  'meetingPoint': instance.meetingPoint,
  'startingPointLat': instance.startingPointLat,
  'startingPointLng': instance.startingPointLng,
  'locationDetails': instance.locationDetails,
  'photoUrl': ?instance.photoUrl,
  'eventFormat': instance.eventFormat.toJson(),
  'distanceKm': instance.distanceKm,
  'pace': _$PaceLevelEnumMap[instance.pace]!,
  'capacityLimit': instance.capacityLimit,
  'description': instance.description,
  'priceInPaise': instance.priceInPaise,
  'bookedCount': ?instance.bookedCount,
  'checkedInCount': ?instance.checkedInCount,
  'waitlistedCount': ?instance.waitlistedCount,
  'status': _$EventLifecycleStatusEnumMap[instance.status]!,
  'cancelledAt': const NullableTimestampConverter().toJson(
    instance.cancelledAt,
  ),
  'cancellationReason': instance.cancellationReason,
  'constraints': instance.constraints.toJson(),
  'eventPolicy': ?instance.eventPolicy?.toJson(),
  'genderCounts': instance.genderCounts,
  'cohortCounts': instance.cohortCounts,
  'waitlistedCohortCounts': instance.waitlistedCohortCounts,
};

const _$PaceLevelEnumMap = {
  PaceLevel.easy: 'easy',
  PaceLevel.moderate: 'moderate',
  PaceLevel.fast: 'fast',
  PaceLevel.competitive: 'competitive',
};

const _$EventLifecycleStatusEnumMap = {
  EventLifecycleStatus.active: 'active',
  EventLifecycleStatus.cancelled: 'cancelled',
};
