import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_setup_body.dart';
import 'package:flutter/material.dart';

typedef EventSuccessDefaultsUpdate =
    EventSuccessDefaults Function(EventSuccessDefaults current);

/// Create-event panel that lets the host enable the live event guide and tune
/// the saved defaults inline. The configuration UI is shared with the Host
/// Manage Setup tab via [EventSuccessSetupBody].
class EventSuccessDefaultsPanel extends StatelessWidget {
  const EventSuccessDefaultsPanel({
    super.key,
    required this.defaults,
    required this.activityKind,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    this.eventFormat,
    this.targetAttendeeCount,
  });

  final EventSuccessDefaults defaults;
  final ActivityKind activityKind;
  final ValueChanged<EventSuccessDefaultsUpdate> onChanged;
  final EventFormatSnapshot? eventFormat;
  final int? targetAttendeeCount;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final format =
        eventFormat ?? EventFormatSnapshot.fromActivityKind(activityKind);
    final normalized = defaults.normalizedForFormat(
      format,
      targetAttendeeCount: targetAttendeeCount,
    );
    final draft = normalized.toDraft(targetAttendeeCount: targetAttendeeCount);

    void updateDraft(EventSuccessHostDraftUpdate update) {
      onChanged((current) {
        final currentNormalized = current.normalizedForFormat(
          format,
          targetAttendeeCount: targetAttendeeCount,
        );
        final currentDraft = currentNormalized.toDraft(
          targetAttendeeCount: targetAttendeeCount,
        );
        return EventSuccessDefaults.fromDraft(
          update(currentDraft),
          enabled: currentNormalized.enabled,
          attendeePrompt: currentNormalized.attendeePrompt,
        ).normalizedForFormat(format, targetAttendeeCount: targetAttendeeCount);
      });
    }

    return CatchSectionList(
      children: [
        CatchFieldInsetScope(
          flush: true,
          child: CatchField.toggle(
            title: title,
            body: subtitle,
            bodyMaxLines: 5,
            value: normalized.enabled,
            onChanged: (value) =>
                onChanged((current) => current.copyWith(enabled: value)),
          ),
        ),
        if (normalized.enabled)
          EventSuccessSetupBody(
            draft: draft,
            eventFormat: format,
            targetAttendeeCount: draft.targetAttendeeCount,
            attendeePrompt: normalized.attendeePrompt,
            showResetToRecommended: !_matchesRecommendedSetup(
              normalized,
              format,
              targetAttendeeCount,
            ),
            onResetToRecommended: () => onChanged(
              (current) => EventSuccessDefaults.recommendedForFormat(
                format,
                enabled: current.enabled,
                targetAttendeeCount: targetAttendeeCount,
                attendeePrompt: current.attendeePrompt,
              ),
            ),
            onChanged: updateDraft,
            onAttendeePromptChanged: (value) {
              final trimmed = value.trim();
              onChanged(
                (current) => current.copyWith(
                  attendeePrompt: trimmed.isEmpty ? null : trimmed,
                ),
              );
            },
          ),
      ],
    );
  }
}

bool _matchesRecommendedSetup(
  EventSuccessDefaults defaults,
  EventFormatSnapshot format,
  int? targetAttendeeCount,
) {
  final recommended = EventSuccessDefaults.recommendedForFormat(
    format,
    enabled: defaults.enabled,
    targetAttendeeCount: targetAttendeeCount,
    attendeePrompt: defaults.attendeePrompt,
  );
  final draft = defaults.toDraft(targetAttendeeCount: targetAttendeeCount);
  final recommendedDraft = recommended.toDraft(
    targetAttendeeCount: targetAttendeeCount,
  );
  return draft.playbook.id == recommendedDraft.playbook.id &&
      _sameStringSet(
        draft.selectedModuleIds,
        recommendedDraft.selectedModuleIds,
      ) &&
      draft.structureConfig == recommendedDraft.structureConfig &&
      draft.hostGoal == recommendedDraft.hostGoal &&
      draft.compatibilityAffectsRanking ==
          recommendedDraft.compatibilityAffectsRanking &&
      draft.questionnaireConfig == recommendedDraft.questionnaireConfig;
}

bool _sameStringSet(Set<String> a, Set<String> b) {
  return a.length == b.length && a.containsAll(b);
}
