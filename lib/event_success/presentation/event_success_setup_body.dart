import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_questionnaire_config_editor.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_structure_config_editor.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const EdgeInsets _attendeePromptPreviewPadding = EdgeInsets.only(
  top: CatchSpacing.s2,
);
const EdgeInsets _attendeePromptPreviewIconInset = EdgeInsets.only(
  top: CatchSpacing.micro2,
);

/// Shared event-success setup body used by both the create-event last step
/// (`EventSuccessDefaultsPanel`) and the Host Manage Setup tab (`SetupTab`).
///
/// Owns the visual layout of the configuration UI — preset preview, guide
/// notes, match clue questions, structure, and tools — and emits changes back
/// to the host via [onDraftChanged] and [onAttendeePromptChanged]. The parent
/// widget is responsible for persistence, freeze/notice banners, and any
/// surrounding chrome.
class EventSuccessSetupBody extends StatefulWidget {
  const EventSuccessSetupBody({
    super.key,
    required this.draft,
    required this.eventFormat,
    required this.targetAttendeeCount,
    required this.attendeePrompt,
    required this.onDraftChanged,
    required this.onAttendeePromptChanged,
    this.editable = true,
    this.showResetToRecommended = false,
    this.onResetToRecommended,
  }) : assert(
         !showResetToRecommended || onResetToRecommended != null,
         'onResetToRecommended must be provided when showResetToRecommended is true',
       );

  final EventSuccessHostDraft draft;
  final EventFormatSnapshot eventFormat;
  final int targetAttendeeCount;
  final String? attendeePrompt;
  final ValueChanged<EventSuccessHostDraft> onDraftChanged;
  final ValueChanged<String> onAttendeePromptChanged;
  final bool editable;
  final bool showResetToRecommended;
  final VoidCallback? onResetToRecommended;

  @override
  State<EventSuccessSetupBody> createState() => _EventSuccessSetupBodyState();
}

class _EventSuccessSetupBodyState extends State<EventSuccessSetupBody> {
  late final TextEditingController _hostGoalController = TextEditingController(
    text: widget.draft.hostGoal,
  );
  late final TextEditingController _attendeePromptController =
      TextEditingController(text: widget.attendeePrompt ?? '');

  @override
  void didUpdateWidget(covariant EventSuccessSetupBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.hostGoal != widget.draft.hostGoal) {
      _setText(_hostGoalController, widget.draft.hostGoal);
    }
    if (oldWidget.attendeePrompt != widget.attendeePrompt) {
      _setText(_attendeePromptController, widget.attendeePrompt ?? '');
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
    final draft = _syncModuleBooleans(widget.draft);
    final profile = EventSuccessActivityProfile.forFormat(
      widget.eventFormat,
      targetAttendeeCount: draft.targetAttendeeCount,
    );

    return CatchSectionList(
      children: [
        PresetReviewCard(
          profile: profile,
          draft: draft,
          targetAttendeeCount: widget.targetAttendeeCount,
          showReset: widget.showResetToRecommended,
          onReset: widget.onResetToRecommended,
        ),
        CatchField.control(
          title: context.l10n.eventSuccessEventSuccessSetupBodyTitleGuideNotes,
          body: _guideNotesSubtitle(draft, widget.attendeePrompt),
          initiallyOpen: true,
          control: CatchSection.containedFieldRows(
            children: [
              CatchField.input(
                title:
                    context.l10n.eventSuccessEventSuccessSetupBodyTitleHostGoal,
                controller: _hostGoalController,
                enabled: widget.editable,
                inputHint: draft.hostGoal,
                inputFormatters: [LengthLimitingTextInputFormatter(300)],
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                onChanged: (value) {
                  widget.onDraftChanged(
                    draft.copyWith(
                      hostGoal: _normalizedRequired(
                        value,
                        fallback: draft.hostGoal,
                      ),
                    ),
                  );
                },
              ),
              CatchField.input(
                title: context
                    .l10n
                    .eventSuccessEventSuccessSetupBodyTitleAttendeePrompt,
                isOptional: true,
                controller: _attendeePromptController,
                enabled: widget.editable,
                inputHint: context
                    .l10n
                    .eventSuccessEventSuccessSetupBodyPlaceholderPromptAttendeesBeforeOr,
                inputFormatters: [LengthLimitingTextInputFormatter(300)],
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                onChanged: widget.onAttendeePromptChanged,
              ),
              AttendeePromptPreview(
                text: _attendeePromptPreview(profile, widget.attendeePrompt),
              ),
            ],
          ),
        ),
        StageCard(
          title: context
              .l10n
              .eventSuccessEventSuccessSetupBodyTitleWhenPeopleArrive,
          subtitle: context
              .l10n
              .eventSuccessEventSuccessSetupBodySubtitleCheckInStaysReliable,
          children: [
            FoundationLine(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTitleCheckAttendeesInAnd,
              subtitle: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodySubtitleArrivalIsTheSource,
            ),
            FoundationLine(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTitleReadABriefWelcome,
              subtitle: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodySubtitleAShortHostOpener,
            ),
            for (final recommendation in _stageRecommendations(
              profile,
              _SetupLifecycleStage.arrival,
            ))
              RecommendationSwitch(
                recommendation: recommendation,
                active: draft.isModuleSelected(recommendation.module.id),
                onChanged: widget.editable && recommendation.selectable
                    ? (_) => _emitModuleToggle(draft, recommendation.module.id)
                    : null,
              ),
          ],
        ),
        StageCard(
          title:
              context.l10n.eventSuccessEventSuccessSetupBodyTitleDuringTheEvent,
          subtitle: context
              .l10n
              .eventSuccessEventSuccessSetupBodySubtitleToolsTheHostRuns,
          children: [
            for (final recommendation in _stageRecommendations(
              profile,
              _SetupLifecycleStage.during,
            )) ...[
              RecommendationSwitch(
                recommendation: recommendation,
                active: draft.isModuleSelected(recommendation.module.id),
                onChanged: widget.editable && recommendation.selectable
                    ? (_) => _emitModuleToggle(draft, recommendation.module.id)
                    : null,
              ),
              if (recommendation.module.id ==
                      EventSuccessModuleCatalog.guidedRotations.id &&
                  draft.isModuleSelected(
                    EventSuccessModuleCatalog.guidedRotations.id,
                  ))
                CatchField.choices<int?>(
                  title: context
                      .l10n
                      .eventSuccessEventSuccessSetupBodyLabelRotationCadence,
                  values: const <int?>[null, 10, 15, 20, 30],
                  itemLabel: (value) => switch (value) {
                    null =>
                      context
                          .l10n
                          .eventSuccessEventSuccessSetupBodyLabelNoTimedRotation,
                    10 =>
                      context.l10n.eventSuccessEventSuccessSetupBodyLabel10Min,
                    15 =>
                      context.l10n.eventSuccessEventSuccessSetupBodyLabel15Min,
                    20 =>
                      context.l10n.eventSuccessEventSuccessSetupBodyLabel20Min,
                    _ =>
                      context.l10n.eventSuccessEventSuccessSetupBodyLabel30Min,
                  },
                  selected: <int?>{
                    draft.structureConfig.rotationIntervalMinutes,
                  },
                  enabled: widget.editable,
                  initiallyOpen: true,
                  onSelectionChanged: widget.editable
                      ? (selection) {
                          final interval = selection.single;
                          widget.onDraftChanged(
                            draft.copyWith(
                              structureConfig: draft.structureConfig.copyWith(
                                rotationIntervalMinutes: interval,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              if (recommendation.module.id ==
                      EventSuccessModuleCatalog.liveReveal.id &&
                  draft.isModuleSelected(
                    EventSuccessModuleCatalog.liveReveal.id,
                  ))
                CatchField.choices<int>(
                  title: _revealCountdownLabel(draft),
                  values: const [0, 5, 10, 15],
                  itemLabel: (value) => switch (value) {
                    0 => context.l10n.eventSuccessEventSuccessSetupBodyLabelOff,
                    5 => context.l10n.eventSuccessEventSuccessSetupBodyLabel5s,
                    10 =>
                      context.l10n.eventSuccessEventSuccessSetupBodyLabel10s,
                    _ => context.l10n.eventSuccessEventSuccessSetupBodyLabel15s,
                  },
                  selected: {draft.structureConfig.revealCountdownSeconds},
                  enabled: widget.editable,
                  initiallyOpen: true,
                  onSelectionChanged: widget.editable
                      ? (selection) {
                          final seconds = selection.single;
                          widget.onDraftChanged(
                            draft.copyWith(
                              structureConfig: draft.structureConfig.copyWith(
                                revealCountdownSeconds: seconds,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
            ],
          ],
        ),
        StageCard(
          title:
              context.l10n.eventSuccessEventSuccessSetupBodyTitleAfterTheEvent,
          subtitle: context
              .l10n
              .eventSuccessEventSuccessSetupBodySubtitleWrapUpToolsFor,
          children: [
            for (final recommendation in _stageRecommendations(
              profile,
              _SetupLifecycleStage.after,
            ))
              RecommendationSwitch(
                recommendation: recommendation,
                active: draft.isModuleSelected(recommendation.module.id),
                onChanged: widget.editable && recommendation.selectable
                    ? (_) => _emitModuleToggle(draft, recommendation.module.id)
                    : null,
              ),
            FoundationLine(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTitleCollectQuickAttendeeFeedback,
              subtitle: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodySubtitleShortRatingsTellYou,
            ),
            FoundationLine(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTitleHostCoachingSummary,
              subtitle: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodySubtitleAShortPostEvent,
            ),
          ],
        ),
        CatchField.control(
          title: _structureSectionTitle(draft),
          body: _structureSectionSubtitle(draft),
          control: CatchSection.containedFieldRows(
            child: EventSuccessStructureConfigEditor(
              value: draft.structureConfig,
              targetAttendeeCount: draft.targetAttendeeCount,
              enabled: widget.editable,
              onChanged: (value) {
                widget.onDraftChanged(draft.copyWith(structureConfig: value));
              },
            ),
          ),
        ),
        CatchField.control(
          title: context.l10n.eventSuccessEventSuccessSetupBodyTitleAdvanced,
          body: _advancedSubtitle(draft),
          control: CatchSection.containedFieldRows(
            child: QuestionnaireBlock(
              active: draft.isModuleSelected(
                EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
              ),
              editable: widget.editable,
              compatibilityAffectsRanking: draft.compatibilityAffectsRanking,
              questionnaireConfig: draft.questionnaireConfig,
              onModeChanged: (mode) {
                final newActive = mode != _QuestionnaireMode.off;
                final newRanking = mode == _QuestionnaireMode.cluesAndPairing;
                final next =
                    _syncModuleBooleans(
                      draft.withModuleSelection(
                        EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
                        newActive,
                      ),
                    ).copyWith(
                      compatibilityAffectsRanking: newActive && newRanking,
                    );
                widget.onDraftChanged(next);
              },
              onQuestionnaireChanged: (value) {
                widget.onDraftChanged(
                  draft.copyWith(questionnaireConfig: value),
                );
              },
            ),
          ),
        ),
        const SafetyFooter(),
      ],
    );
  }

  void _emitModuleToggle(EventSuccessHostDraft draft, String moduleId) {
    widget.onDraftChanged(
      _syncModuleBooleans(
        draft
            .toggleModule(moduleId)
            .copyWith(
              hostGoal: _normalizedRequired(
                _hostGoalController.text,
                fallback: draft.hostGoal,
              ),
            ),
      ),
    );
  }
}

/// Lifecycle stage a module belongs to in the host-facing setup view.
enum _SetupLifecycleStage { arrival, during, after }

/// Modules that are "always-on event basics" for the host — surfaced as ✓ lines
/// in the lifecycle stage cards instead of toggles.
const Set<String> _foundationModuleIds = {
  'safety_controls',
  'qr_check_in',
  'host_script',
  'decomposed_feedback',
  'host_analytics',
  'crowd_balance',
};

/// Maps host-toggleable modules to the lifecycle stage card they appear under.
/// Modules absent from this map (and not in [_foundationModuleIds]) fall into
/// the Advanced drawer.
const Map<String, _SetupLifecycleStage> _lifecycleStageForModule = {
  'first_hello_check_in': _SetupLifecycleStage.arrival,
  'micro_pods': _SetupLifecycleStage.during,
  'guided_rotations': _SetupLifecycleStage.during,
  'live_reveal': _SetupLifecycleStage.during,
  'social_missions': _SetupLifecycleStage.during,
  'wingman_requests': _SetupLifecycleStage.during,
  'contextual_openers': _SetupLifecycleStage.after,
};

bool _isFoundationModule(String moduleId) =>
    _foundationModuleIds.contains(moduleId);

bool _isStageVisible(EventSuccessModuleRecommendation recommendation) =>
    recommendation.level == EventSuccessRecommendationLevel.defaultOn ||
    recommendation.level == EventSuccessRecommendationLevel.recommended;

List<EventSuccessModuleRecommendation> _stageRecommendations(
  EventSuccessActivityProfile profile,
  _SetupLifecycleStage stage,
) {
  return profile.recommendations
      .where(
        (recommendation) =>
            !_isFoundationModule(recommendation.module.id) &&
            recommendation.module.id !=
                EventSuccessModuleCatalog.compatibilityQuestionnaire.id &&
            _lifecycleStageForModule[recommendation.module.id] == stage &&
            _isStageVisible(recommendation),
      )
      .toList(growable: false);
}

/// Force foundation modules selected on every draft update so the host's saved
/// plan stays consistent with the "always on" lines shown in the stage cards.
EventSuccessHostDraft _enforceFoundationSelections(
  EventSuccessHostDraft draft,
) {
  var next = draft;
  for (final id in _foundationModuleIds) {
    if (!next.playbook.moduleIds.contains(id)) continue;
    if (!next.isModuleSelected(id)) {
      next = next.withModuleSelection(id, true);
    }
  }
  return next;
}

class StageCard extends StatelessWidget {
  const StageCard({required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSection.fieldRows(
      title: title,
      first: true,
      footer: subtitle == null
          ? null
          : Padding(
              padding: CatchInsets.inlineHorizontal,
              child: Text(
                subtitle!,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ),
      children: children,
    );
  }
}

class FoundationLine extends StatelessWidget {
  const FoundationLine({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchField.read(
      title: title,
      body: subtitle,
      icon: CatchIcons.checkRounded,
      iconColor: t.primary,
    );
  }
}

/// Live preview rendered beneath the attendee-prompt field showing exactly
/// what attendees will see — the host's typed prompt, or the playbook default
/// when the field is empty.
class AttendeePromptPreview extends StatelessWidget {
  const AttendeePromptPreview({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: _attendeePromptPreviewPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: _attendeePromptPreviewIconInset,
            child: Icon(
              CatchIcons.visibilityOutlined,
              size: CatchIcon.sm,
              color: t.ink2,
            ),
          ),
          gapW6,
          Expanded(
            child: Text(
              context.l10n
                  .eventSuccessEventSuccessSetupBodyTextAttendeesWillSeeText(
                    text: text,
                  ),
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

class SafetyFooter extends StatelessWidget {
  const SafetyFooter();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: CatchInsets.inlineHorizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CatchIcons.shieldOutlined, size: CatchIcon.md, color: t.ink2),
          gapW8,
          Expanded(
            child: Text(
              context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTextSafetyBlockingAndReport,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

class PresetReviewCard extends StatelessWidget {
  const PresetReviewCard({
    required this.profile,
    required this.draft,
    required this.targetAttendeeCount,
    required this.showReset,
    required this.onReset,
  });

  final EventSuccessActivityProfile profile;
  final EventSuccessHostDraft draft;
  final int targetAttendeeCount;
  final bool showReset;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      borderColor: t.surface.withValues(alpha: CatchOpacity.none),
      radius: CatchRadius.md,
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  context
                      .l10n
                      .eventSuccessEventSuccessSetupBodyTextRecommendedPreset,
                  style: CatchTextStyles.labelL(context),
                ),
              ),
              if (showReset && onReset != null)
                CatchTextButton(
                  label:
                      context.l10n.eventSuccessEventSuccessSetupBodyLabelReset,
                  onPressed: onReset,
                  minimumSize: const Size(
                    CatchLayout.eventSuccessResetButtonMinWidth,
                    CatchLayout.eventSuccessResetButtonMinHeight,
                  ),
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
                label: profile.formatLabel,
                tone: CatchBadgeTone.brand,
                icon: CatchIcons.autoAwesomeOutlined,
              ),
              CatchBadge(label: profile.interactionModel.label),
              CatchBadge(
                label: _capacitySummary(draft),
                icon: CatchIcons.groups2Outlined,
              ),
            ],
          ),
          gapH8,
          Text(
            profile.summary,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH6,
          Text(
            _structureSectionSubtitle(draft),
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH6,
          Text(
            _structurePreviewText(draft),
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

/// Compatibility-questionnaire setting mode. Collapses the old two-switch
/// arrangement (module toggle + "guide pairings") into a single host choice.
enum _QuestionnaireMode { off, cluesOnly, cluesAndPairing }

/// Inner content of the Match clue questions feature. Rendered inside the
/// Advanced disclosure (no disclosure shell of its own). Exposes a single
/// 3-state chooser so the host doesn't have to reason about a separate
/// "ask questions" and "guide pairings" switch pair.
class QuestionnaireBlock extends StatelessWidget {
  const QuestionnaireBlock({
    required this.active,
    required this.editable,
    required this.compatibilityAffectsRanking,
    required this.questionnaireConfig,
    required this.onModeChanged,
    required this.onQuestionnaireChanged,
  });

  final bool active;
  final bool editable;
  final bool compatibilityAffectsRanking;
  final EventSuccessQuestionnaireConfig questionnaireConfig;
  final ValueChanged<_QuestionnaireMode> onModeChanged;
  final ValueChanged<EventSuccessQuestionnaireConfig> onQuestionnaireChanged;

  _QuestionnaireMode get _mode {
    if (!active) return _QuestionnaireMode.off;
    return compatibilityAffectsRanking
        ? _QuestionnaireMode.cluesAndPairing
        : _QuestionnaireMode.cluesOnly;
  }

  @override
  Widget build(BuildContext context) {
    final mode = _mode;
    return CatchSectionList(
      gap: CatchGaps.formField,
      children: [
        CatchField.choices<_QuestionnaireMode>(
          title: context
              .l10n
              .eventSuccessEventSuccessSetupBodyTextMatchClueQuestions,
          body: _questionnaireModeSubtitle(mode),
          values: _QuestionnaireMode.values,
          itemLabel: _questionnaireModeLabel,
          selected: {mode},
          enabled: editable,
          initiallyOpen: true,
          onSelectionChanged: editable
              ? (selection) => onModeChanged(selection.single)
              : null,
        ),
        if (active)
          EventSuccessQuestionnaireConfigEditor(
            value: questionnaireConfig,
            enabled: editable,
            onChanged: onQuestionnaireChanged,
            useBottomSheetForCustom: true,
          ),
      ],
    );
  }
}

String _questionnaireModeLabel(_QuestionnaireMode mode) {
  switch (mode) {
    case _QuestionnaireMode.off:
      return 'Off';
    case _QuestionnaireMode.cluesOnly:
      return 'Clues only';
    case _QuestionnaireMode.cluesAndPairing:
      return 'Clues + soft pairing';
  }
}

String _questionnaireModeSubtitle(_QuestionnaireMode mode) {
  switch (mode) {
    case _QuestionnaireMode.off:
      return 'Attendees skip the prompts.';
    case _QuestionnaireMode.cluesOnly:
      return 'Answers create reveal clues. Pairing suggestions ignore them.';
    case _QuestionnaireMode.cluesAndPairing:
      return 'Answers create reveal clues and softly inform pairing suggestions.';
  }
}

class RecommendationSwitch extends StatelessWidget {
  const RecommendationSwitch({
    super.key,
    required this.recommendation,
    required this.active,
    required this.onChanged,
  });

  final EventSuccessModuleRecommendation recommendation;
  final bool active;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CatchField.toggle(
      title: recommendation.module.title,
      body: recommendation.reason,
      value: active,
      onChanged: onChanged,
    );
  }
}

/// Enforces foundation module selections (so the ✓ lines in the stage cards
/// reflect the saved state) and keeps the `wingmanRequestsEnabled` /
/// `contextualOpenersEnabled` boolean flags on the draft in sync with the
/// underlying module selections.
EventSuccessHostDraft _syncModuleBooleans(EventSuccessHostDraft draft) {
  final enforced = _enforceFoundationSelections(draft);
  return enforced.copyWith(
    wingmanRequestsEnabled: enforced.isModuleSelected(
      EventSuccessModuleCatalog.wingmanRequests.id,
    ),
    contextualOpenersEnabled: enforced.isModuleSelected(
      EventSuccessModuleCatalog.contextualOpeners.id,
    ),
  );
}

String _advancedSubtitle(EventSuccessHostDraft draft) {
  final questionnaireActive = draft.isModuleSelected(
    EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
  );
  if (questionnaireActive) {
    return 'Match clue questions are on.';
  }
  return 'Optional extras you opt into intentionally.';
}

String _attendeePromptPreview(
  EventSuccessActivityProfile profile,
  String? typed,
) {
  final configured = typed?.trim();
  if (configured != null && configured.isNotEmpty) return configured;
  return profile.defaultAttendeePrompt;
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
