// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Review _$ReviewFromJson(Map<String, dynamic> json) => _Review(
  id: json['id'] as String,
  runClubId: json['runClubId'] as String,
  runId: json['runId'] as String?,
  reviewerUserId: json['reviewerUserId'] as String,
  reviewerName: json['reviewerName'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const NullableTimestampConverter().fromJson(
    json['updatedAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  'runClubId': instance.runClubId,
  'runId': instance.runId,
  'reviewerUserId': instance.reviewerUserId,
  'reviewerName': instance.reviewerName,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const NullableTimestampConverter().toJson(instance.updatedAt),
};
