import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_success_defaults.freezed.dart';
part 'event_success_defaults.g.dart';

@freezed
abstract class EventSuccessDefaults with _$EventSuccessDefaults {
  const EventSuccessDefaults._();

  const factory EventSuccessDefaults({
    @Default(false) bool enabled,
    @Default('social_run_light') String playbookId,
    @Default(<String>[]) List<String> selectedModuleIds,
    @Default(EventSuccessStructureConfig.legacyDefault())
    EventSuccessStructureConfig structureConfig,
    @Default('Help attendees meet at least two new people.') String hostGoal,
    @Default(true) bool wingmanRequestsEnabled,
    @Default(true) bool contextualOpenersEnabled,
    @Default(false) bool compatibilityAffectsRanking,
    @Default(EventSuccessQuestionnaireConfig.defaultTemplate())
    EventSuccessQuestionnaireConfig questionnaireConfig,
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
      structureConfig: draft.structureConfig,
      hostGoal: draft.hostGoal,
      wingmanRequestsEnabled: draft.isModuleSelected(
        EventSuccessModuleCatalog.wingmanRequests.id,
      ),
      contextualOpenersEnabled: draft.isModuleSelected(
        EventSuccessModuleCatalog.contextualOpeners.id,
      ),
      compatibilityAffectsRanking: draft.compatibilityAffectsRanking,
      questionnaireConfig: draft.questionnaireConfig,
      attendeePrompt: _trimToNull(attendeePrompt),
    );
  }

  factory EventSuccessDefaults.recommendedForActivity(
    ActivityKind activityKind, {
    bool enabled = false,
    int? targetAttendeeCount,
    String? attendeePrompt,
  }) {
    return EventSuccessDefaults.fromDraft(
      EventSuccessHostDraft.fromActivity(
        activityKind,
        targetAttendeeCount: targetAttendeeCount,
      ),
      enabled: enabled,
      attendeePrompt: attendeePrompt,
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
    final resolvedSelectedIds = selectedIds.isEmpty
        ? defaultDraft.selectedModuleIds
        : selectedIds;
    return defaultDraft.copyWith(
      selectedModuleIds: resolvedSelectedIds,
      structureConfig: structureConfig.isLegacyDefault
          ? defaultDraft.structureConfig
          : structureConfig,
      hostGoal: hostGoal.trim().isEmpty ? defaultDraft.hostGoal : hostGoal,
      wingmanRequestsEnabled: resolvedSelectedIds.contains(
        EventSuccessModuleCatalog.wingmanRequests.id,
      ),
      contextualOpenersEnabled: resolvedSelectedIds.contains(
        EventSuccessModuleCatalog.contextualOpeners.id,
      ),
      compatibilityAffectsRanking: compatibilityAffectsRanking,
      questionnaireConfig: questionnaireConfig,
    );
  }

  EventSuccessDefaults normalizedForActivity(
    ActivityKind activityKind, {
    int? targetAttendeeCount,
  }) {
    final recommended = EventSuccessDefaults.recommendedForActivity(
      activityKind,
      enabled: enabled,
      targetAttendeeCount: targetAttendeeCount,
      attendeePrompt: attendeePrompt,
    );
    final recommendedDraft = recommended.toDraft(
      targetAttendeeCount: targetAttendeeCount,
    );
    final profile = EventSuccessActivityProfile.forActivity(
      activityKind,
      targetAttendeeCount: targetAttendeeCount,
    );
    final currentPlaybook = EventSuccessPlaybookLibrary.byIdOrDefault(
      playbookId,
    );
    final currentSelectedIds = selectedModuleIds
        .where(recommendedDraft.playbook.moduleIds.contains)
        .where(profile.isSelectable)
        .toSet();
    final useCurrentSelectedIds =
        currentSelectedIds.isNotEmpty &&
        _playbookMatchesActivity(currentPlaybook, activityKind);
    final selectedIds = useCurrentSelectedIds
        ? currentSelectedIds
        : recommendedDraft.selectedModuleIds;
    final compatibilitySelected = selectedIds.contains(
      EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
    );

    return EventSuccessDefaults.fromDraft(
      recommendedDraft.copyWith(
        selectedModuleIds: selectedIds,
        structureConfig:
            _shouldUseRecommendedStructure(
              activityKind,
              structureConfig,
              targetAttendeeCount,
            )
            ? recommendedDraft.structureConfig
            : structureConfig,
        hostGoal: hostGoal.trim().isEmpty
            ? recommendedDraft.hostGoal
            : hostGoal,
        wingmanRequestsEnabled: selectedIds.contains(
          EventSuccessModuleCatalog.wingmanRequests.id,
        ),
        contextualOpenersEnabled: selectedIds.contains(
          EventSuccessModuleCatalog.contextualOpeners.id,
        ),
        compatibilityAffectsRanking:
            compatibilitySelected &&
            (useCurrentSelectedIds
                ? compatibilityAffectsRanking
                : recommendedDraft.compatibilityAffectsRanking),
        questionnaireConfig: questionnaireConfig,
      ),
      enabled: enabled,
      attendeePrompt: attendeePrompt,
    );
  }

  EventSuccessPlan toPlanForEvent(Event event, {DateTime? now}) {
    final createdAt = now ?? DateTime.now();
    final normalized = normalizedForActivity(
      event.activityKind,
      targetAttendeeCount: math.max(1, event.capacityLimit),
    );
    return EventSuccessPlan.fromDraft(
      id: event.id,
      eventId: event.id,
      clubId: event.clubId,
      draft: normalized.toDraft(
        targetAttendeeCount: math.max(1, event.capacityLimit),
      ),
      createdAt: createdAt,
      updatedAt: createdAt,
      attendeePrompt: _trimToNull(normalized.attendeePrompt),
    );
  }
}

String? _trimToNull(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

bool _playbookMatchesActivity(
  EventSuccessPlaybook playbook,
  ActivityKind activityKind,
) {
  if (playbook.activityType == activityKind) return true;
  return activityKind.defaultPlaybookId == playbook.id;
}

bool _shouldUseRecommendedStructure(
  ActivityKind activityKind,
  EventSuccessStructureConfig structureConfig,
  int? targetAttendeeCount,
) {
  if (structureConfig.isLegacyDefault) return true;
  return targetAttendeeCount != null &&
      activityKind.defaultInteractionModel ==
          EventInteractionModel.teamRotations &&
      structureConfig.isDeprecatedTeamRotationDefault;
}
