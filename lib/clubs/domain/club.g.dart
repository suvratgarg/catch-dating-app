// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Club _$ClubFromJson(Map<String, dynamic> json) => _Club(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  location: json['location'] as String,
  area: json['area'] as String,
  hostUserId: json['hostUserId'] as String,
  hostName: json['hostName'] as String,
  hostAvatarUrl: json['hostAvatarUrl'] as String?,
  ownerUserId: json['ownerUserId'] as String?,
  hostUserIds:
      (json['hostUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  hostProfiles:
      (json['hostProfiles'] as List<dynamic>?)
          ?.map((e) => ClubHostProfile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  imageUrl: json['imageUrl'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  nextEventAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['nextEventAt'],
    const TimestampConverter().fromJson,
  ),
  nextEventLabel: json['nextEventLabel'] as String?,
  instagramHandle: json['instagramHandle'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  email: json['email'] as String?,
  status:
      $enumDecodeNullable(_$ClubLifecycleStatusEnumMap, json['status']) ??
      ClubLifecycleStatus.active,
  archived: json['archived'] as bool? ?? false,
  archivedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['archivedAt'],
    const TimestampConverter().fromJson,
  ),
  archiveReason: json['archiveReason'] as String?,
  hostDefaults: json['hostDefaults'] == null
      ? const ClubHostDefaults()
      : ClubHostDefaults.fromJson(json['hostDefaults'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ClubToJson(_Club instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'location': instance.location,
  'area': instance.area,
  'hostUserId': instance.hostUserId,
  'hostName': instance.hostName,
  'hostAvatarUrl': instance.hostAvatarUrl,
  'ownerUserId': instance.ownerUserId,
  'hostUserIds': instance.hostUserIds,
  'hostProfiles': instance.hostProfiles.map((e) => e.toJson()).toList(),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'imageUrl': instance.imageUrl,
  'profileImageUrl': instance.profileImageUrl,
  'tags': instance.tags,
  'memberCount': instance.memberCount,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'nextEventAt': _$JsonConverterToJson<Timestamp, DateTime>(
    instance.nextEventAt,
    const TimestampConverter().toJson,
  ),
  'nextEventLabel': instance.nextEventLabel,
  'instagramHandle': instance.instagramHandle,
  'phoneNumber': instance.phoneNumber,
  'email': instance.email,
  'status': _$ClubLifecycleStatusEnumMap[instance.status]!,
  'archived': instance.archived,
  'archivedAt': _$JsonConverterToJson<Timestamp, DateTime>(
    instance.archivedAt,
    const TimestampConverter().toJson,
  ),
  'archiveReason': instance.archiveReason,
  'hostDefaults': instance.hostDefaults.toJson(),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$ClubLifecycleStatusEnumMap = {
  ClubLifecycleStatus.active: 'active',
  ClubLifecycleStatus.archived: 'archived',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_ClubHostProfile _$ClubHostProfileFromJson(Map<String, dynamic> json) =>
    _ClubHostProfile(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role:
          $enumDecodeNullable(_$ClubHostRoleEnumMap, json['role']) ??
          ClubHostRole.host,
    );

Map<String, dynamic> _$ClubHostProfileToJson(_ClubHostProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'role': _$ClubHostRoleEnumMap[instance.role]!,
    };

const _$ClubHostRoleEnumMap = {
  ClubHostRole.owner: 'owner',
  ClubHostRole.host: 'host',
};
