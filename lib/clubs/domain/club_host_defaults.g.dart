// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_host_defaults.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClubHostDefaults _$ClubHostDefaultsFromJson(Map<String, dynamic> json) =>
    _ClubHostDefaults(
      eventPolicy: json['eventPolicy'] == null
          ? const EventPolicyDefaults()
          : EventPolicyDefaults.fromJson(
              json['eventPolicy'] as Map<String, dynamic>,
            ),
      eventSuccess: json['eventSuccess'] == null
          ? const EventSuccessDefaults()
          : EventSuccessDefaults.fromJson(
              json['eventSuccess'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ClubHostDefaultsToJson(_ClubHostDefaults instance) =>
    <String, dynamic>{
      'eventPolicy': instance.eventPolicy.toJson(),
      'eventSuccess': instance.eventSuccess.toJson(),
    };
