import 'dart:math' as math;

import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_success_defaults.freezed.dart';
part 'event_success_defaults.g.dart';

@freezed
abstract class EventSuccessDefaults with _$EventSuccessDefaults {
  const EventSuccessDefaults._();

  const factory EventSuccessDefaults({
    @Default(false) bool enabled,
    @Default('socialRun') String playbookId,
    @Default(<String>[]) List<String> selectedModuleIds,
    @Default('Help attendees meet at least two new people.') String hostGoal,
    @Default(true) bool privateCrushEnabled,
    @Default(true) bool contextualOpenersEnabled,
    String? attendeePrompt,
  }) = _EventSuccessDefaults;

  factory EventSuccessDefaults.fromJson(Map<String, dynamic> json) =>
      _$EventSuccessDefaultsFromJson(json);

  factory EventSuccessDefaults.fromDraft(
    EventSuccessHostDraft draft, {
    bool enabled = true,
    String? attendeePrompt,
  }) {
    return EventSuccessDefaults(
      enabled: enabled,
      playbookId: draft.playbook.id,
      selectedModuleIds: draft.selectedModuleIds.toList()..sort(),
      hostGoal: draft.hostGoal,
      privateCrushEnabled: draft.privateCrushEnabled,
      contextualOpenersEnabled: draft.contextualOpenersEnabled,
      attendeePrompt: _trimToNull(attendeePrompt),
    );
  }

  EventSuccessHostDraft toDraft({int? targetAttendeeCount}) {
    final playbook = EventSuccessPlaybookLibrary.byIdOrDefault(playbookId);
    final defaultDraft = EventSuccessHostDraft.fromPlaybook(
      playbook,
      targetAttendeeCount: targetAttendeeCount,
    );
    final selectedIds = selectedModuleIds
        .where(playbook.moduleIds.contains)
        .toSet();
    return defaultDraft.copyWith(
      selectedModuleIds: selectedIds.isEmpty
          ? defaultDraft.selectedModuleIds
          : selectedIds,
      hostGoal: hostGoal.trim().isEmpty ? defaultDraft.hostGoal : hostGoal,
      privateCrushEnabled: privateCrushEnabled,
      contextualOpenersEnabled: contextualOpenersEnabled,
    );
  }

  EventSuccessPlan toPlanForEvent(Event event, {DateTime? now}) {
    final createdAt = now ?? DateTime.now();
    return EventSuccessPlan.fromDraft(
      id: event.id,
      eventId: event.id,
      clubId: event.clubId,
      draft: toDraft(targetAttendeeCount: math.max(1, event.capacityLimit)),
      createdAt: createdAt,
      updatedAt: createdAt,
      attendeePrompt: _trimToNull(attendeePrompt),
    );
  }
}

String? _trimToNull(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
