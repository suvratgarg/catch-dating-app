// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClubDraft _$ClubDraftFromJson(Map<String, dynamic> json) => _ClubDraft(
  savedAt: DateTime.parse(json['savedAt'] as String),
  name: json['name'] as String?,
  area: json['area'] as String?,
  description: json['description'] as String?,
  location: json['location'] as String?,
  instagramHandle: json['instagramHandle'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$ClubDraftToJson(_ClubDraft instance) =>
    <String, dynamic>{
      'savedAt': instance.savedAt.toIso8601String(),
      'name': instance.name,
      'area': instance.area,
      'description': instance.description,
      'location': instance.location,
      'instagramHandle': instance.instagramHandle,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
    };
