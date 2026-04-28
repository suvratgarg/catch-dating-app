// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Match _$MatchFromJson(Map<String, dynamic> json) => _Match(
  id: json['id'] as String,
  user1Id: json['user1Id'] as String,
  user2Id: json['user2Id'] as String,
  runId: json['runId'] as String,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  lastMessageAt: const NullableTimestampConverter().fromJson(
    json['lastMessageAt'] as Timestamp?,
  ),
  lastMessagePreview: json['lastMessagePreview'] as String?,
  lastMessageSenderId: json['lastMessageSenderId'] as String?,
  unreadCounts:
      (json['unreadCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  status: json['status'] as String? ?? 'active',
  blockedBy: json['blockedBy'] as String?,
  blockedAt: const NullableTimestampConverter().fromJson(
    json['blockedAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$MatchToJson(_Match instance) => <String, dynamic>{
  'user1Id': instance.user1Id,
  'user2Id': instance.user2Id,
  'runId': instance.runId,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'lastMessageAt': const NullableTimestampConverter().toJson(
    instance.lastMessageAt,
  ),
  'lastMessagePreview': instance.lastMessagePreview,
  'lastMessageSenderId': instance.lastMessageSenderId,
  'unreadCounts': instance.unreadCounts,
  'status': instance.status,
  'blockedBy': instance.blockedBy,
  'blockedAt': const NullableTimestampConverter().toJson(instance.blockedAt),
};
