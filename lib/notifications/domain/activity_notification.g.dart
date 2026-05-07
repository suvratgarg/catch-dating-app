// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityNotification _$ActivityNotificationFromJson(
  Map<String, dynamic> json,
) => _ActivityNotification(
  id: json['id'] as String,
  uid: json['uid'] as String,
  type: $enumDecode(_$ActivityNotificationTypeEnumMap, json['type']),
  title: json['title'] as String,
  body: json['body'] as String,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  readAt: const NullableTimestampConverter().fromJson(
    json['readAt'] as Timestamp?,
  ),
  matchId: json['matchId'] as String?,
  runId: json['runId'] as String?,
  runClubId: json['runClubId'] as String?,
  actorUid: json['actorUid'] as String?,
  actorName: json['actorName'] as String?,
);

Map<String, dynamic> _$ActivityNotificationToJson(
  _ActivityNotification instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'type': _$ActivityNotificationTypeEnumMap[instance.type]!,
  'title': instance.title,
  'body': instance.body,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'readAt': const NullableTimestampConverter().toJson(instance.readAt),
  'matchId': instance.matchId,
  'runId': instance.runId,
  'runClubId': instance.runClubId,
  'actorUid': instance.actorUid,
  'actorName': instance.actorName,
};

const _$ActivityNotificationTypeEnumMap = {
  ActivityNotificationType.message: 'message',
  ActivityNotificationType.match: 'match',
  ActivityNotificationType.runReminder: 'runReminder',
  ActivityNotificationType.runSignup: 'runSignup',
  ActivityNotificationType.waitlistPromotion: 'waitlistPromotion',
  ActivityNotificationType.runCancelled: 'runCancelled',
  ActivityNotificationType.runUpdated: 'runUpdated',
  ActivityNotificationType.clubUpdate: 'clubUpdate',
};
