// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_success_defaults.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventSuccessDefaults _$EventSuccessDefaultsFromJson(
  Map<String, dynamic> json,
) => _EventSuccessDefaults(
  enabled: json['enabled'] as bool? ?? false,
  playbookId: json['playbookId'] as String? ?? 'socialRun',
  selectedModuleIds:
      (json['selectedModuleIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  hostGoal:
      json['hostGoal'] as String? ??
      'Help attendees meet at least two new people.',
  privateCrushEnabled: json['privateCrushEnabled'] as bool? ?? true,
  contextualOpenersEnabled: json['contextualOpenersEnabled'] as bool? ?? true,
  attendeePrompt: json['attendeePrompt'] as String?,
);

Map<String, dynamic> _$EventSuccessDefaultsToJson(
  _EventSuccessDefaults instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'playbookId': instance.playbookId,
  'selectedModuleIds': instance.selectedModuleIds,
  'hostGoal': instance.hostGoal,
  'privateCrushEnabled': instance.privateCrushEnabled,
  'contextualOpenersEnabled': instance.contextualOpenersEnabled,
  'attendeePrompt': instance.attendeePrompt,
};
