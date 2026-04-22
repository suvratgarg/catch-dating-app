// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RunClub _$RunClubFromJson(Map<String, dynamic> json) => _RunClub(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  location: $enumDecode(_$IndianCityEnumMap, json['location']),
  area: json['area'] as String,
  hostUserId: json['hostUserId'] as String,
  hostName: json['hostName'] as String,
  hostAvatarUrl: json['hostAvatarUrl'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  imageUrl: json['imageUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  memberUserIds:
      (json['memberUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  nextRunAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['nextRunAt'],
    const TimestampConverter().fromJson,
  ),
  nextRunLabel: json['nextRunLabel'] as String?,
);

Map<String, dynamic> _$RunClubToJson(_RunClub instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'location': _$IndianCityEnumMap[instance.location]!,
  'area': instance.area,
  'hostUserId': instance.hostUserId,
  'hostName': instance.hostName,
  'hostAvatarUrl': instance.hostAvatarUrl,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'imageUrl': instance.imageUrl,
  'tags': instance.tags,
  'memberUserIds': instance.memberUserIds,
  'memberCount': instance.memberCount,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'nextRunAt': _$JsonConverterToJson<Timestamp, DateTime>(
    instance.nextRunAt,
    const TimestampConverter().toJson,
  ),
  'nextRunLabel': instance.nextRunLabel,
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

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
