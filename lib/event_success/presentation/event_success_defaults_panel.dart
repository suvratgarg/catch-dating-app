import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_questionnaire_config_editor.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_structure_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventSuccessDefaultsPanel extends StatefulWidget {
  const EventSuccessDefaultsPanel({
    super.key,
    required this.defaults,
    required this.activityKind,
    required this.onChanged,
    this.targetAttendeeCount,
    this.title = 'Live event guide',
    this.subtitle = 'Choose whether new events should get a saved live plan.',
  });

  final EventSuccessDefaults defaults;
  final ActivityKind activityKind;
  final ValueChanged<EventSuccessDefaults> onChanged;
  final int? targetAttendeeCount;
  final String title;
  final String subtitle;

  @override
  State<EventSuccessDefaultsPanel> createState() =>
      _EventSuccessDefaultsPanelState();
}

class _EventSuccessDefaultsPanelState extends State<EventSuccessDefaultsPanel> {
  late final TextEditingController _hostGoalController = TextEditingController(
    text: widget.defaults.hostGoal,
  );
  late final TextEditingController _attendeePromptController =
      TextEditingController(text: widget.defaults.attendeePrompt ?? '');

  @override
  void didUpdateWidget(covariant EventSuccessDefaultsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaults.hostGoal != widget.defaults.hostGoal) {
      _setText(_hostGoalController, widget.defaults.hostGoal);
    }
    if (oldWidget.defaults.attendeePrompt != widget.defaults.attendeePrompt) {
      _setText(_attendeePromptController, widget.defaults.attendeePrompt ?? '');
    }
  }

  @override
  void dispose() {
    _hostGoalController.dispose();
    _attendeePromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final targetAttendeeCount = widget.targetAttendeeCount;
    final defaults = widget.defaults.normalizedForActivity(
      widget.activityKind,
      targetAttendeeCount: targetAttendeeCount,
    );
    final draft = _syncModuleBooleans(
      defaults.toDraft(targetAttendeeCount: targetAttendeeCount),
    );
    final profile = EventSuccessActivityProfile.forActivity(
      widget.activityKind,
      targetAttendeeCount: draft.targetAttendeeCount,
    );
    final liveRevealEnabled = draft.isModuleSelected(
      EventSuccessModuleCatalog.liveReveal.id,
    );
    final guidedRotationsEnabled = draft.isModuleSelected(
      EventSuccessModuleCatalog.guidedRotations.id,
    );

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      radius: CatchRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: defaults.enabled,
            onChanged: (value) => _emit(defaults.copyWith(enabled: value)),
            title: Text(widget.title, style: CatchTextStyles.titleM(context)),
            subtitle: Text(
              widget.subtitle,
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ),
          if (defaults.enabled) ...[
            gapH12,
            _PresetReviewCard(
              profile: profile,
              draft: draft,
              showReset: !_matchesRecommendedSetup(
                defaults,
                widget.activityKind,
                targetAttendeeCount,
              ),
              onReset: () => _emit(
                EventSuccessDefaults.recommendedForActivity(
                  widget.activityKind,
                  enabled: defaults.enabled,
                  targetAttendeeCount: targetAttendeeCount,
                  attendeePrompt: _attendeePromptController.text,
                ),
              ),
            ),
            gapH8,
            _SetupDisclosureSection(
              title: 'Guide notes',
              subtitle: _guideNotesSubtitle(draft, defaults.attendeePrompt),
              children: [
                CatchTextField(
                  label: 'Host goal',
                  controller: _hostGoalController,
                  hintText: draft.hostGoal,
                  inputFormatters: [LengthLimitingTextInputFormatter(300)],
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  onChanged: (value) => _emit(
                    defaults.copyWith(
                      hostGoal: _normalizedRequired(
                        value,
                        fallback: draft.hostGoal,
                      ),
                    ),
                  ),
                ),
                gapH12,
                CatchTextField(
                  label: 'Attendee prompt',
                  isOptional: true,
                  controller: _attendeePromptController,
                  hintText: 'Prompt attendees before or after the event.',
                  inputFormatters: [LengthLimitingTextInputFormatter(300)],
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  onChanged: (value) => _emit(
                    defaults.copyWith(attendeePrompt: _trimToNull(value)),
                  ),
                ),
              ],
            ),
            gapH8,
            _QuestionnaireDisclosureSection(
              active: draft.isModuleSelected(
                EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
              ),
              compatibilityAffectsRanking: defaults.compatibilityAffectsRanking,
              questionnaireConfig: defaults.questionnaireConfig,
              onActiveChanged: (active) {
                final nextDraft = _syncModuleBooleans(
                  draft.withModuleSelection(
                    EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
                    active,
                  ),
                );
                _emitDraft(nextDraft, enabled: defaults.enabled);
              },
              onRankingChanged: (value) => _emit(
                defaults
                    .copyWith(compatibilityAffectsRanking: value)
                    .normalizedForActivity(
                      widget.activityKind,
                      targetAttendeeCount: targetAttendeeCount,
                    ),
              ),
              onQuestionnaireChanged: (value) => _emit(
                defaults
                    .copyWith(questionnaireConfig: value)
                    .normalizedForActivity(
                      widget.activityKind,
                      targetAttendeeCount: targetAttendeeCount,
                    ),
              ),
            ),
            gapH8,
            _SetupDisclosureSection(
              title: _structureSectionTitle(draft),
              subtitle: _structureSectionSubtitle(draft),
              children: [
                EventSuccessStructureConfigEditor(
                  value: draft.structureConfig,
                  targetAttendeeCount: draft.targetAttendeeCount,
                  enabled: true,
                  showRotationCadence: guidedRotationsEnabled,
                  showRevealCountdown: liveRevealEnabled,
                  revealCountdownLabel: _revealCountdownLabel(draft),
                  onChanged: (value) {
                    _emitDraft(
                      draft.copyWith(structureConfig: value),
                      enabled: defaults.enabled,
                    );
                  },
                ),
              ],
            ),
            gapH8,
            _SetupDisclosureSection(
              title: 'Tools',
              subtitle:
                  '${draft.selectedModules.length} selected. Each capability appears once.',
              children: [
                for (final level in const [
                  EventSuccessRecommendationLevel.defaultOn,
                  EventSuccessRecommendationLevel.recommended,
                  EventSuccessRecommendationLevel.optional,
                  EventSuccessRecommendationLevel.discouraged,
                ])
                  if (_toolRecommendationsFor(profile, level).isNotEmpty) ...[
                    _RecommendationGroup(
                      title: level.label,
                      recommendations: _toolRecommendationsFor(profile, level),
                      draft: draft,
                      onToggle: (moduleId) {
                        final nextDraft = _syncModuleBooleans(
                          draft
                              .toggleModule(moduleId)
                              .copyWith(
                                hostGoal: _normalizedRequired(
                                  _hostGoalController.text,
                                  fallback: draft.hostGoal,
                                ),
                              ),
                        );
                        _emitDraft(nextDraft, enabled: defaults.enabled);
                      },
                    ),
                    gapH8,
                  ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _emit(EventSuccessDefaults defaults) => widget.onChanged(defaults);

  void _emitDraft(EventSuccessHostDraft draft, {required bool enabled}) {
    _emit(
      EventSuccessDefaults.fromDraft(
        _syncModuleBooleans(draft),
        enabled: enabled,
        attendeePrompt: _attendeePromptController.text,
      ).normalizedForActivity(
        widget.activityKind,
        targetAttendeeCount: widget.targetAttendeeCount,
      ),
    );
  }
}

class _PresetReviewCard extends StatelessWidget {
  const _PresetReviewCard({
    required this.profile,
    required this.draft,
    required this.showReset,
    required this.onReset,
  });

  final EventSuccessActivityProfile profile;
  final EventSuccessHostDraft draft;
  final bool showReset;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      borderColor: Colors.transparent,
      radius: CatchRadius.md,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Recommended preset',
                  style: CatchTextStyles.labelL(context),
                ),
              ),
              if (showReset)
                CatchTextButton(
                  label: 'Reset',
                  onPressed: onReset,
                  minimumSize: const Size(40, 32),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          gapH6,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchBadge(
                label: profile.activityKind.label,
                tone: CatchBadgeTone.brand,
                icon: Icons.auto_awesome_outlined,
              ),
              CatchBadge(
                label: profile.activityKind.defaultInteractionModel.label,
                tone: CatchBadgeTone.neutral,
              ),
              CatchBadge(
                label: _capacitySummary(draft),
                tone: CatchBadgeTone.neutral,
                icon: Icons.groups_2_outlined,
              ),
            ],
          ),
          gapH8,
          Text(
            profile.summary,
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH6,
          Text(
            _structureSectionSubtitle(draft),
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH6,
          Text(
            _structurePreviewText(draft),
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class _QuestionnaireDisclosureSection extends StatelessWidget {
  const _QuestionnaireDisclosureSection({
    required this.active,
    required this.compatibilityAffectsRanking,
    required this.questionnaireConfig,
    required this.onActiveChanged,
    required this.onRankingChanged,
    required this.onQuestionnaireChanged,
  });

  final bool active;
  final bool compatibilityAffectsRanking;
  final EventSuccessQuestionnaireConfig questionnaireConfig;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onRankingChanged;
  final ValueChanged<EventSuccessQuestionnaireConfig> onQuestionnaireChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return _SetupDisclosureSection(
      title: 'Match clue questions',
      subtitle: active
          ? 'Attendees answer event-specific prompts before matching moments.'
          : 'Off. Turn this on only when answers should create reveal clues.',
      children: [
        SwitchListTile.adaptive(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: active,
          onChanged: onActiveChanged,
          title: Text(
            'Ask attendees match clue questions',
            style: CatchTextStyles.labelL(context),
          ),
          subtitle: Text(
            'Answers can create reveal clues. They affect pairing suggestions only if you allow that below.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ),
        if (active) ...[
          gapH8,
          SwitchListTile.adaptive(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: compatibilityAffectsRanking,
            onChanged: onRankingChanged,
            title: Text(
              'Let answers guide pairings',
              style: CatchTextStyles.labelL(context),
            ),
            subtitle: Text(
              'Off keeps answers for reveal clues only. On lets suggested pairings use them as one light input.',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ),
          gapH12,
          EventSuccessQuestionnaireConfigEditor(
            value: questionnaireConfig,
            onChanged: onQuestionnaireChanged,
          ),
        ],
      ],
    );
  }
}

class _SetupDisclosureSection extends StatelessWidget {
  const _SetupDisclosureSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        maintainState: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: CatchSpacing.s2),
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: t.primary,
        collapsedIconColor: t.ink2,
        title: Text(title, style: CatchTextStyles.labelL(context)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.s1),
          child: Text(
            subtitle,
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ],
      ),
    );
  }
}

class _RecommendationGroup extends StatelessWidget {
  const _RecommendationGroup({
    required this.title,
    required this.recommendations,
    required this.draft,
    required this.onToggle,
  });

  final String title;
  final List<EventSuccessModuleRecommendation> recommendations;
  final EventSuccessHostDraft draft;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CatchTextStyles.labelL(context)),
        gapH6,
        for (final recommendation in recommendations)
          _RecommendationSwitch(
            recommendation: recommendation,
            active: draft.isModuleSelected(recommendation.module.id),
            onChanged: recommendation.selectable
                ? (_) => onToggle(recommendation.module.id)
                : null,
          ),
      ],
    );
  }
}

class _RecommendationSwitch extends StatelessWidget {
  const _RecommendationSwitch({
    required this.recommendation,
    required this.active,
    required this.onChanged,
  });

  final EventSuccessModuleRecommendation recommendation;
  final bool active;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SwitchListTile.adaptive(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: active,
      onChanged: onChanged,
      title: Text(
        recommendation.module.title,
        style: CatchTextStyles.labelL(context),
      ),
      subtitle: Text(
        recommendation.reason,
        style: CatchTextStyles.bodyS(context, color: t.ink2),
      ),
    );
  }
}

List<EventSuccessModuleRecommendation> _toolRecommendationsFor(
  EventSuccessActivityProfile profile,
  EventSuccessRecommendationLevel level,
) {
  return profile
      .recommendationsFor(level)
      .where(
        (recommendation) =>
            recommendation.module.id !=
            EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
      )
      .toList(growable: false);
}

bool _matchesRecommendedSetup(
  EventSuccessDefaults defaults,
  ActivityKind activityKind,
  int? targetAttendeeCount,
) {
  final normalized = defaults.normalizedForActivity(
    activityKind,
    targetAttendeeCount: targetAttendeeCount,
  );
  final recommended = EventSuccessDefaults.recommendedForActivity(
    activityKind,
    enabled: defaults.enabled,
    targetAttendeeCount: targetAttendeeCount,
    attendeePrompt: defaults.attendeePrompt,
  );
  final draft = _syncModuleBooleans(
    normalized.toDraft(targetAttendeeCount: targetAttendeeCount),
  );
  final recommendedDraft = _syncModuleBooleans(
    recommended.toDraft(targetAttendeeCount: targetAttendeeCount),
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

EventSuccessHostDraft _syncModuleBooleans(EventSuccessHostDraft draft) {
  return draft.copyWith(
    wingmanRequestsEnabled: draft.isModuleSelected(
      EventSuccessModuleCatalog.wingmanRequests.id,
    ),
    contextualOpenersEnabled: draft.isModuleSelected(
      EventSuccessModuleCatalog.contextualOpeners.id,
    ),
  );
}

String _guideNotesSubtitle(
  EventSuccessHostDraft draft,
  String? attendeePrompt,
) {
  final prompt = attendeePrompt?.trim();
  if (prompt != null && prompt.isNotEmpty) {
    return 'Host goal and attendee prompt are ready.';
  }
  return 'Host goal: ${draft.hostGoal}';
}

String _structureSectionTitle(EventSuccessHostDraft draft) {
  return switch (draft.structureConfig.unitKind) {
    EventSuccessUnitKind.wholeGroup => 'Group flow',
    EventSuccessUnitKind.pods => 'Pod setup',
    EventSuccessUnitKind.pairs => 'Pair setup',
    EventSuccessUnitKind.teams => 'Team setup',
    EventSuccessUnitKind.tables => 'Table setup',
  };
}

String _structureSectionSubtitle(EventSuccessHostDraft draft) {
  final config = draft.structureConfig;
  final estimatedUnitCount = config.estimatedUnitCount(
    draft.targetAttendeeCount,
  );
  if (config.unitKind == EventSuccessUnitKind.wholeGroup) {
    return 'Plan for up to ${draft.targetAttendeeCount} attendees in one shared flow.';
  }
  final countPrefix = config.unitCount == null
      ? 'about $estimatedUnitCount'
      : estimatedUnitCount.toString();
  return 'Plan for up to ${draft.targetAttendeeCount} attendees: $countPrefix ${config.unitKind.label.toLowerCase()}, aiming for ${config.unitSize} people per ${config.unitKind.singularLabel}. Final assignments use actual signups and check-ins.';
}

String _structurePreviewText(EventSuccessHostDraft draft) {
  final config = draft.structureConfig;
  final target = draft.targetAttendeeCount;
  if (config.unitKind == EventSuccessUnitKind.wholeGroup) {
    return 'Preview: If $target attend, Catch keeps everyone in one shared flow. If fewer people check in, Live mode uses the actual roster.';
  }
  final targetEstimate = config.estimateForAttendance(target);
  final sampleAttendance = _sampleAttendanceCount(target);
  final sampleEstimate = config.estimateForAttendance(sampleAttendance);
  return 'Preview: If $target attend, Catch suggests ${_estimatePhrase(config, targetEstimate)}. If $sampleAttendance check in, expect ${_estimatePhrase(config, sampleEstimate)}.';
}

int _sampleAttendanceCount(int targetAttendeeCount) {
  if (targetAttendeeCount <= 1) return 1;
  final drop = math.max(1, (targetAttendeeCount * 0.25).round());
  return math.max(1, targetAttendeeCount - drop);
}

String _estimatePhrase(
  EventSuccessStructureConfig config,
  EventSuccessStructureEstimate estimate,
) {
  final countText = config.unitKind.countText(estimate.unitCount);
  if (estimate.minPeoplePerUnit == 0) {
    return '$countText with up to ${estimate.maxPeoplePerUnit} ${_peopleWord(estimate.maxPeoplePerUnit)} each';
  }
  if (estimate.isEven) {
    return '$countText of ${estimate.minPeoplePerUnit}';
  }
  return '$countText of ${estimate.minPeoplePerUnit}-${estimate.maxPeoplePerUnit}';
}

String _peopleWord(int count) => count == 1 ? 'person' : 'people';

String _capacitySummary(EventSuccessHostDraft draft) {
  final config = draft.structureConfig;
  if (config.unitKind == EventSuccessUnitKind.wholeGroup) {
    return '${draft.targetAttendeeCount} target';
  }
  final estimatedUnitCount = config.estimatedUnitCount(
    draft.targetAttendeeCount,
  );
  return '$estimatedUnitCount ${config.unitKind.label.toLowerCase()}';
}

String _revealCountdownLabel(EventSuccessHostDraft draft) {
  return switch (draft.structureConfig.unitKind) {
    EventSuccessUnitKind.teams => 'Team reveal countdown',
    EventSuccessUnitKind.tables => 'Table reveal countdown',
    EventSuccessUnitKind.pairs => 'Pair reveal countdown',
    EventSuccessUnitKind.pods => 'Pod reveal countdown',
    EventSuccessUnitKind.wholeGroup => 'Reveal countdown',
  };
}

void _setText(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}

String _normalizedRequired(String value, {required String fallback}) {
  final normalized = value.trim();
  return normalized.isEmpty ? fallback : normalized;
}

String? _trimToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
