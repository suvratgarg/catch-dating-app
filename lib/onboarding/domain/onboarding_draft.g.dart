// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingDraft _$OnboardingDraftFromJson(Map<String, dynamic> json) =>
    _OnboardingDraft(
      step: (json['step'] as num).toInt(),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: _$JsonConverterFromJson<Timestamp, DateTime>(
        json['dateOfBirth'],
        const TimestampConverter().fromJson,
      ),
      phoneNumber: json['phoneNumber'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '+91',
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      interestedInGenders:
          (json['interestedInGenders'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$GenderEnumMap, e))
              .toList() ??
          const [],
      instagramHandle: json['instagramHandle'] as String?,
    );

Map<String, dynamic> _$OnboardingDraftToJson(_OnboardingDraft instance) =>
    <String, dynamic>{
      'step': instance.step,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.dateOfBirth,
        const TimestampConverter().toJson,
      ),
      'phoneNumber': instance.phoneNumber,
      'countryCode': instance.countryCode,
      'gender': _$GenderEnumMap[instance.gender],
      'interestedInGenders': instance.interestedInGenders
          .map((e) => _$GenderEnumMap[e]!)
          .toList(),
      'instagramHandle': instance.instagramHandle,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$GenderEnumMap = {
  Gender.man: 'man',
  Gender.woman: 'woman',
  Gender.nonBinary: 'nonBinary',
  Gender.other: 'other',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
