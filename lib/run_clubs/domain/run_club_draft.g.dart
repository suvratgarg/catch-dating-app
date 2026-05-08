// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_club_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RunClubDraft _$RunClubDraftFromJson(Map<String, dynamic> json) =>
    _RunClubDraft(
      savedAt: DateTime.parse(json['savedAt'] as String),
      name: json['name'] as String?,
      area: json['area'] as String?,
      description: json['description'] as String?,
      location: $enumDecodeNullable(_$IndianCityEnumMap, json['location']),
      instagramHandle: json['instagramHandle'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$RunClubDraftToJson(_RunClubDraft instance) =>
    <String, dynamic>{
      'savedAt': instance.savedAt.toIso8601String(),
      'name': instance.name,
      'area': instance.area,
      'description': instance.description,
      'location': _$IndianCityEnumMap[instance.location],
      'instagramHandle': instance.instagramHandle,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
    };

const _$IndianCityEnumMap = {
  IndianCity.mumbai: 'mumbai',
  IndianCity.delhi: 'delhi',
  IndianCity.bangalore: 'bangalore',
  IndianCity.hyderabad: 'hyderabad',
  IndianCity.chennai: 'chennai',
  IndianCity.kolkata: 'kolkata',
  IndianCity.pune: 'pune',
  IndianCity.ahmedabad: 'ahmedabad',
  IndianCity.indore: 'indore',
};
