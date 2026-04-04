// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Swipe _$SwipeFromJson(Map<String, dynamic> json) => _Swipe(
  swiperId: json['swiperId'] as String,
  targetId: json['targetId'] as String,
  runId: json['runId'] as String,
  direction: $enumDecode(_$SwipeDirectionEnumMap, json['direction']),
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$SwipeToJson(_Swipe instance) => <String, dynamic>{
  'swiperId': instance.swiperId,
  'targetId': instance.targetId,
  'runId': instance.runId,
  'direction': _$SwipeDirectionEnumMap[instance.direction]!,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};

const _$SwipeDirectionEnumMap = {
  SwipeDirection.like: 'like',
  SwipeDirection.pass: 'pass',
};
