// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppVersionConfig _$AppVersionConfigFromJson(Map<String, dynamic> json) =>
    _AppVersionConfig(
      minVersion: json['minVersion'] as String? ?? '0.0.0',
      storeUrlAndroid: json['storeUrlAndroid'] as String? ?? '',
      storeUrlIos: json['storeUrlIos'] as String? ?? '',
    );

Map<String, dynamic> _$AppVersionConfigToJson(_AppVersionConfig instance) =>
    <String, dynamic>{
      'minVersion': instance.minVersion,
      'storeUrlAndroid': instance.storeUrlAndroid,
      'storeUrlIos': instance.storeUrlIos,
    };
