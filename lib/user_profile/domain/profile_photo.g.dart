// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfilePhoto _$ProfilePhotoFromJson(Map<String, dynamic> json) =>
    _ProfilePhoto(
      id: json['id'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      storagePath: json['storagePath'] as String,
      thumbnailStoragePath: json['thumbnailStoragePath'] as String,
      position: (json['position'] as num).toInt(),
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      updatedAt: const TimestampConverter().fromJson(
        json['updatedAt'] as Timestamp,
      ),
      prompt: json['prompt'] == null
          ? null
          : PhotoPromptAnswer.fromJson(json['prompt'] as Map<String, dynamic>),
      moderation: json['moderation'] == null
          ? null
          : ProfilePhotoModeration.fromJson(
              json['moderation'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ProfilePhotoToJson(_ProfilePhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
      'storagePath': instance.storagePath,
      'thumbnailStoragePath': instance.thumbnailStoragePath,
      'position': instance.position,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'prompt': instance.prompt?.toJson(),
      'moderation': instance.moderation?.toJson(),
    };

_ProfilePhotoModeration _$ProfilePhotoModerationFromJson(
  Map<String, dynamic> json,
) => _ProfilePhotoModeration(
  status: json['status'] as String,
  reason: json['reason'] as String?,
  reviewedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['reviewedAt'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$ProfilePhotoModerationToJson(
  _ProfilePhotoModeration instance,
) => <String, dynamic>{
  'status': instance.status,
  'reason': instance.reason,
  'reviewedAt': _$JsonConverterToJson<Timestamp, DateTime>(
    instance.reviewedAt,
    const TimestampConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
