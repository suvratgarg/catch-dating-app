// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventDraft _$EventDraftFromJson(Map<String, dynamic> json) => _EventDraft(
  id: json['id'] as String,
  clubId: json['clubId'] as String,
  savedAt: DateTime.parse(json['savedAt'] as String),
  distance: json['distance'] as String?,
  capacity: json['capacity'] as String?,
  price: json['price'] as String?,
  description: json['description'] as String?,
  activityKind: json['activityKind'] as String?,
  customActivityLabel: json['customActivityLabel'] as String?,
  interactionModel: json['interactionModel'] as String?,
  paceName: json['paceName'] as String?,
  meetingPoint: json['meetingPoint'] as String?,
  locationDetails: json['locationDetails'] as String?,
  meetingLocationAddress: json['meetingLocationAddress'] as String?,
  meetingLocationPlaceId: json['meetingLocationPlaceId'] as String?,
  startingPointLat: (json['startingPointLat'] as num?)?.toDouble(),
  startingPointLng: (json['startingPointLng'] as num?)?.toDouble(),
  selectedDateMillis: (json['selectedDateMillis'] as num?)?.toInt(),
  selectedStartHour: (json['selectedStartHour'] as num?)?.toInt(),
  selectedStartMinute: (json['selectedStartMinute'] as num?)?.toInt(),
  durationMinutes:
      (json['durationMinutes'] as num?)?.toInt() ??
      CatchBusinessRules.eventDefaultDurationMinutes,
  minAge: json['minAge'] as String?,
  maxAge: json['maxAge'] as String?,
  maxMen: json['maxMen'] as String?,
  maxWomen: json['maxWomen'] as String?,
  admissionPreset: json['admissionPreset'] as String?,
  inviteCode: json['inviteCode'] as String?,
  dynamicPricingEnabled: json['dynamicPricingEnabled'] as bool? ?? false,
  dynamicPricingStep: json['dynamicPricingStep'] as String?,
  dynamicPricingMax: json['dynamicPricingMax'] as String?,
  cancellationPolicy: json['cancellationPolicy'] as String?,
  eventSuccessDefaults: json['eventSuccessDefaults'] == null
      ? const EventSuccessDefaults()
      : EventSuccessDefaults.fromJson(
          json['eventSuccessDefaults'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$EventDraftToJson(_EventDraft instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clubId': instance.clubId,
      'savedAt': instance.savedAt.toIso8601String(),
      'distance': instance.distance,
      'capacity': instance.capacity,
      'price': instance.price,
      'description': instance.description,
      'activityKind': instance.activityKind,
      'customActivityLabel': instance.customActivityLabel,
      'interactionModel': instance.interactionModel,
      'paceName': instance.paceName,
      'meetingPoint': instance.meetingPoint,
      'locationDetails': instance.locationDetails,
      'meetingLocationAddress': instance.meetingLocationAddress,
      'meetingLocationPlaceId': instance.meetingLocationPlaceId,
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
      'admissionPreset': instance.admissionPreset,
      'inviteCode': instance.inviteCode,
      'dynamicPricingEnabled': instance.dynamicPricingEnabled,
      'dynamicPricingStep': instance.dynamicPricingStep,
      'dynamicPricingMax': instance.dynamicPricingMax,
      'cancellationPolicy': instance.cancellationPolicy,
      'eventSuccessDefaults': instance.eventSuccessDefaults.toJson(),
    };
