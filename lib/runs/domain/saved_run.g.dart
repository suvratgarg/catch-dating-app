// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedRun _$SavedRunFromJson(Map<String, dynamic> json) => _SavedRun(
  id: json['id'] as String,
  uid: json['uid'] as String,
  runId: json['runId'] as String,
  savedAt: const TimestampConverter().fromJson(json['savedAt'] as Timestamp),
);

Map<String, dynamic> _$SavedRunToJson(_SavedRun instance) => <String, dynamic>{
  'uid': instance.uid,
  'runId': instance.runId,
  'savedAt': const TimestampConverter().toJson(instance.savedAt),
};
