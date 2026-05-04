// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CityData _$CityDataFromJson(Map<String, dynamic> json) => _CityData(
  name: json['name'] as String,
  label: json['label'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$CityDataToJson(_CityData instance) => <String, dynamic>{
  'name': instance.name,
  'label': instance.label,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
