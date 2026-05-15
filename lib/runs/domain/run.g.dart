// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Run _$RunFromJson(Map<String, dynamic> json) => _Run(
  id: json['id'] as String,
  runClubId: json['runClubId'] as String,
  startTime: const TimestampConverter().fromJson(
    json['startTime'] as Timestamp,
  ),
  endTime: const TimestampConverter().fromJson(json['endTime'] as Timestamp),
  meetingPoint: json['meetingPoint'] as String,
  startingPointLat: (json['startingPointLat'] as num?)?.toDouble(),
  startingPointLng: (json['startingPointLng'] as num?)?.toDouble(),
  locationDetails: json['locationDetails'] as String?,
  photoUrl: json['photoUrl'] as String?,
  distanceKm: (json['distanceKm'] as num).toDouble(),
  pace: $enumDecode(_$PaceLevelEnumMap, json['pace']),
  capacityLimit: (json['capacityLimit'] as num).toInt(),
  description: json['description'] as String,
  priceInPaise: (json['priceInPaise'] as num).toInt(),
  bookedCount: (json['bookedCount'] as num?)?.toInt(),
  checkedInCount: (json['checkedInCount'] as num?)?.toInt(),
  waitlistedCount: (json['waitlistedCount'] as num?)?.toInt(),
  status:
      $enumDecodeNullable(_$RunLifecycleStatusEnumMap, json['status']) ??
      RunLifecycleStatus.active,
  cancelledAt: const NullableTimestampConverter().fromJson(
    json['cancelledAt'] as Timestamp?,
  ),
  cancellationReason: json['cancellationReason'] as String?,
  constraints: json['constraints'] == null
      ? const RunConstraints()
      : RunConstraints.fromJson(json['constraints'] as Map<String, dynamic>),
  genderCounts:
      (json['genderCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$RunToJson(_Run instance) => <String, dynamic>{
  'runClubId': instance.runClubId,
  'startTime': const TimestampConverter().toJson(instance.startTime),
  'endTime': const TimestampConverter().toJson(instance.endTime),
  'meetingPoint': instance.meetingPoint,
  'startingPointLat': instance.startingPointLat,
  'startingPointLng': instance.startingPointLng,
  'locationDetails': instance.locationDetails,
  'photoUrl': ?instance.photoUrl,
  'distanceKm': instance.distanceKm,
  'pace': _$PaceLevelEnumMap[instance.pace]!,
  'capacityLimit': instance.capacityLimit,
  'description': instance.description,
  'priceInPaise': instance.priceInPaise,
  'bookedCount': ?instance.bookedCount,
  'checkedInCount': ?instance.checkedInCount,
  'waitlistedCount': ?instance.waitlistedCount,
  'status': _$RunLifecycleStatusEnumMap[instance.status]!,
  'cancelledAt': const NullableTimestampConverter().toJson(
    instance.cancelledAt,
  ),
  'cancellationReason': instance.cancellationReason,
  'constraints': instance.constraints.toJson(),
  'genderCounts': instance.genderCounts,
};

const _$PaceLevelEnumMap = {
  PaceLevel.easy: 'easy',
  PaceLevel.moderate: 'moderate',
  PaceLevel.fast: 'fast',
  PaceLevel.competitive: 'competitive',
};

const _$RunLifecycleStatusEnumMap = {
  RunLifecycleStatus.active: 'active',
  RunLifecycleStatus.cancelled: 'cancelled',
};
