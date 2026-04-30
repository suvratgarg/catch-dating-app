// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppVersionConfig _$AppVersionConfigFromJson(Map<String, dynamic> json) =>
    _AppVersionConfig(
      minVersion: json['minVersion'] as String? ?? '0.0.0',
      minBuildAndroid: (json['minBuildAndroid'] as num?)?.toInt() ?? 0,
      minBuildIos: (json['minBuildIos'] as num?)?.toInt() ?? 0,
      minBuildWeb: (json['minBuildWeb'] as num?)?.toInt() ?? 0,
      minBuildMacos: (json['minBuildMacos'] as num?)?.toInt() ?? 0,
      storeUrlAndroid: json['storeUrlAndroid'] as String? ?? '',
      storeUrlIos: json['storeUrlIos'] as String? ?? '',
    );

Map<String, dynamic> _$AppVersionConfigToJson(_AppVersionConfig instance) =>
    <String, dynamic>{
      'minVersion': instance.minVersion,
      'minBuildAndroid': instance.minBuildAndroid,
      'minBuildIos': instance.minBuildIos,
      'minBuildWeb': instance.minBuildWeb,
      'minBuildMacos': instance.minBuildMacos,
      'storeUrlAndroid': instance.storeUrlAndroid,
      'storeUrlIos': instance.storeUrlIos,
    };
