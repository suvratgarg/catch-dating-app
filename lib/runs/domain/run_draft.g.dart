// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RunDraft _$RunDraftFromJson(Map<String, dynamic> json) => _RunDraft(
  id: json['id'] as String,
  runClubId: json['runClubId'] as String,
  savedAt: DateTime.parse(json['savedAt'] as String),
  distance: json['distance'] as String?,
  capacity: json['capacity'] as String?,
  price: json['price'] as String?,
  description: json['description'] as String?,
  paceName: json['paceName'] as String?,
  meetingPoint: json['meetingPoint'] as String?,
  locationDetails: json['locationDetails'] as String?,
  startingPointLat: (json['startingPointLat'] as num?)?.toDouble(),
  startingPointLng: (json['startingPointLng'] as num?)?.toDouble(),
  selectedDateMillis: (json['selectedDateMillis'] as num?)?.toInt(),
  selectedStartHour: (json['selectedStartHour'] as num?)?.toInt(),
  selectedStartMinute: (json['selectedStartMinute'] as num?)?.toInt(),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 60,
  minAge: json['minAge'] as String?,
  maxAge: json['maxAge'] as String?,
  maxMen: json['maxMen'] as String?,
  maxWomen: json['maxWomen'] as String?,
);

Map<String, dynamic> _$RunDraftToJson(_RunDraft instance) => <String, dynamic>{
  'id': instance.id,
  'runClubId': instance.runClubId,
  'savedAt': instance.savedAt.toIso8601String(),
  'distance': instance.distance,
  'capacity': instance.capacity,
  'price': instance.price,
  'description': instance.description,
  'paceName': instance.paceName,
  'meetingPoint': instance.meetingPoint,
  'locationDetails': instance.locationDetails,
  'startingPointLat': instance.startingPointLat,
  'startingPointLng': instance.startingPointLng,
  'selectedDateMillis': instance.selectedDateMillis,
  'selectedStartHour': instance.selectedStartHour,
  'selectedStartMinute': instance.selectedStartMinute,
  'durationMinutes': instance.durationMinutes,
  'minAge': instance.minAge,
  'maxAge': instance.maxAge,
  'maxMen': instance.maxMen,
  'maxWomen': instance.maxWomen,
};
