// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_success_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventSuccessPlan _$EventSuccessPlanFromJson(
  Map<String, dynamic> json,
) => _EventSuccessPlan(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  clubId: json['clubId'] as String,
  playbookId: json['playbookId'] as String,
  selectedModuleIds: (json['selectedModuleIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  targetAttendeeCount: (json['targetAttendeeCount'] as num).toInt(),
  hostGoal: json['hostGoal'] as String,
  privateCrushEnabled: json['privateCrushEnabled'] as bool? ?? true,
  contextualOpenersEnabled: json['contextualOpenersEnabled'] as bool? ?? true,
  activeStepIndex: (json['activeStepIndex'] as num?)?.toInt() ?? 0,
  status:
      $enumDecodeNullable(_$EventSuccessPlanStatusEnumMap, json['status']) ??
      EventSuccessPlanStatus.setup,
  attendeePrompt: json['attendeePrompt'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
  frozenAt: const NullableTimestampConverter().fromJson(
    json['frozenAt'] as Timestamp?,
  ),
  completedAt: const NullableTimestampConverter().fromJson(
    json['completedAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$EventSuccessPlanToJson(_EventSuccessPlan instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'clubId': instance.clubId,
      'playbookId': instance.playbookId,
      'selectedModuleIds': instance.selectedModuleIds,
      'targetAttendeeCount': instance.targetAttendeeCount,
      'hostGoal': instance.hostGoal,
      'privateCrushEnabled': instance.privateCrushEnabled,
      'contextualOpenersEnabled': instance.contextualOpenersEnabled,
      'activeStepIndex': instance.activeStepIndex,
      'status': _$EventSuccessPlanStatusEnumMap[instance.status]!,
      'attendeePrompt': instance.attendeePrompt,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'frozenAt': const NullableTimestampConverter().toJson(instance.frozenAt),
      'completedAt': const NullableTimestampConverter().toJson(
        instance.completedAt,
      ),
    };

const _$EventSuccessPlanStatusEnumMap = {
  EventSuccessPlanStatus.setup: 'setup',
  EventSuccessPlanStatus.live: 'live',
  EventSuccessPlanStatus.complete: 'complete',
};

_EventSuccessFeedback _$EventSuccessFeedbackFromJson(
  Map<String, dynamic> json,
) => _EventSuccessFeedback(
  id: json['id'] as String,
  eventId: json['eventId'] as String,
  clubId: json['clubId'] as String,
  uid: json['uid'] as String,
  welcomeRating: (json['welcomeRating'] as num).toInt(),
  structureRating: (json['structureRating'] as num).toInt(),
  metNewPeopleCount: (json['metNewPeopleCount'] as num).toInt(),
  markedPrivateCrush: json['markedPrivateCrush'] as bool? ?? false,
  safetyConcern: json['safetyConcern'] as bool? ?? false,
  privateNote: json['privateNote'] as String?,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$EventSuccessFeedbackToJson(
  _EventSuccessFeedback instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'clubId': instance.clubId,
  'uid': instance.uid,
  'welcomeRating': instance.welcomeRating,
  'structureRating': instance.structureRating,
  'metNewPeopleCount': instance.metNewPeopleCount,
  'markedPrivateCrush': instance.markedPrivateCrush,
  'safetyConcern': instance.safetyConcern,
  'privateNote': instance.privateNote,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
