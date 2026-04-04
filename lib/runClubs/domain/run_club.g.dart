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
  hostUserId: json['hostUserId'] as String,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  imageUrl: json['imageUrl'] as String?,
  memberUserIds:
      (json['memberUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RunClubToJson(_RunClub instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'location': _$IndianCityEnumMap[instance.location]!,
  'hostUserId': instance.hostUserId,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'imageUrl': instance.imageUrl,
  'memberUserIds': instance.memberUserIds,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
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
