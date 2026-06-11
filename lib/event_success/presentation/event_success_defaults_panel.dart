import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/list_tile_material.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_setup_body.dart';
import 'package:flutter/material.dart';

/// Create-event panel that lets the host enable the live event guide and tune
/// the saved defaults inline. The configuration UI is shared with the Host
/// Manage Setup tab via [EventSuccessSetupBody].
class EventSuccessDefaultsPanel extends StatelessWidget {
  const EventSuccessDefaultsPanel({
    super.key,
    required this.defaults,
    required this.activityKind,
    required this.onChanged,
    this.eventFormat,
    this.targetAttendeeCount,
    this.title = 'Live event guide',
    this.subtitle = 'Choose whether new events should get a saved live plan.',
  });

  final EventSuccessDefaults defaults;
  final ActivityKind activityKind;
  final ValueChanged<EventSuccessDefaults> onChanged;
  final EventFormatSnapshot? eventFormat;
  final int? targetAttendeeCount;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final format =
        eventFormat ?? EventFormatSnapshot.fromActivityKind(activityKind);
    final normalized = defaults.normalizedForFormat(
      format,
      targetAttendeeCount: targetAttendeeCount,
    );
    final draft = normalized.toDraft(targetAttendeeCount: targetAttendeeCount);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTileMaterial(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: normalized.enabled,
              onChanged: (value) =>
                  onChanged(normalized.copyWith(enabled: value)),
              title: Text(title, style: CatchTextStyles.sectionTitle(context)),
              subtitle: Text(
                subtitle,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ),
          ),
          if (normalized.enabled) ...[
            gapH12,
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
                EventSuccessDefaults.recommendedForFormat(
                  format,
                  enabled: normalized.enabled,
                  targetAttendeeCount: targetAttendeeCount,
                  attendeePrompt: normalized.attendeePrompt,
                ),
              ),
              onDraftChanged: (nextDraft) {
                onChanged(
                  EventSuccessDefaults.fromDraft(
                    nextDraft,
                    enabled: normalized.enabled,
                    attendeePrompt: normalized.attendeePrompt,
                  ).normalizedForFormat(
                    format,
                    targetAttendeeCount: targetAttendeeCount,
                  ),
                );
              },
              onAttendeePromptChanged: (value) {
                final trimmed = value.trim();
                onChanged(
                  normalized.copyWith(
                    attendeePrompt: trimmed.isEmpty ? null : trimmed,
                  ),
                );
              },
            ),
          ],
        ],
      ),
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
