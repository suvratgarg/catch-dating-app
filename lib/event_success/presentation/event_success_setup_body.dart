import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
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

const EdgeInsets _foundationLineIconInset = EdgeInsets.only(
  top: CatchSpacing.micro2,
);
const EdgeInsets _setupNestedControlPadding = EdgeInsets.only(
  left: CatchSpacing.s4,
  bottom: CatchSpacing.s2,
);
const EdgeInsets _attendeePromptPreviewPadding = EdgeInsets.only(
  top: CatchSpacing.s2,
);
const EdgeInsets _attendeePromptPreviewIconInset = EdgeInsets.only(
  top: CatchSpacing.micro2,
);
const EdgeInsets _disclosureChildrenPadding = EdgeInsets.only(
  top: CatchSpacing.s2,
);
const EdgeInsets _disclosureSubtitlePadding = EdgeInsets.only(
  top: CatchSpacing.s1,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PresetReviewCard(
          profile: profile,
          draft: draft,
          targetAttendeeCount: widget.targetAttendeeCount,
          showReset: widget.showResetToRecommended,
          onReset: widget.onResetToRecommended,
        ),
        gapH8,
        SetupDisclosureSection(
          title: context.l10n.eventSuccessEventSuccessSetupBodyTitleGuideNotes,
          subtitle: _guideNotesSubtitle(draft, widget.attendeePrompt),
          initiallyExpanded: true,
          children: [
            CatchField.input(
              title:
                  context.l10n.eventSuccessEventSuccessSetupBodyTitleHostGoal,
              controller: _hostGoalController,
              enabled: widget.editable,
              placeholder: draft.hostGoal,
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
            gapH12,
            CatchField.input(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTitleAttendeePrompt,
              isOptional: true,
              controller: _attendeePromptController,
              enabled: widget.editable,
              placeholder: context
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
        gapH8,
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
        gapH8,
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
                SetupChoiceChips<int?>(
                  label: context
                      .l10n
                      .eventSuccessEventSuccessSetupBodyLabelRotationCadence,
                  options: [
                    CatchOption<int?>(
                      value: null,
                      label: context
                          .l10n
                          .eventSuccessEventSuccessSetupBodyLabelNoTimedRotation,
                    ),
                    CatchOption(
                      value: 10,
                      label: context
                          .l10n
                          .eventSuccessEventSuccessSetupBodyLabel10Min,
                    ),
                    CatchOption(
                      value: 15,
                      label: context
                          .l10n
                          .eventSuccessEventSuccessSetupBodyLabel15Min,
                    ),
                    CatchOption(
                      value: 20,
                      label: context
                          .l10n
                          .eventSuccessEventSuccessSetupBodyLabel20Min,
                    ),
                    CatchOption(
                      value: 30,
                      label: context
                          .l10n
                          .eventSuccessEventSuccessSetupBodyLabel30Min,
                    ),
                  ],
                  value: draft.structureConfig.rotationIntervalMinutes,
                  enabled: widget.editable,
                  onChanged: (interval) {
                    widget.onDraftChanged(
                      draft.copyWith(
                        structureConfig: draft.structureConfig.copyWith(
                          rotationIntervalMinutes: interval,
                        ),
                      ),
                    );
                  },
                ),
              if (recommendation.module.id ==
                      EventSuccessModuleCatalog.liveReveal.id &&
                  draft.isModuleSelected(
                    EventSuccessModuleCatalog.liveReveal.id,
                  ))
                SetupChoiceChips<int>(
                  label: _revealCountdownLabel(draft),
                  options: [
                    CatchOption(
                      value: 0,
                      label: context
                          .l10n
                          .eventSuccessEventSuccessSetupBodyLabelOff,
                    ),
                    CatchOption(
                      value: 5,
                      label:
                          context.l10n.eventSuccessEventSuccessSetupBodyLabel5s,
                    ),
                    CatchOption(
                      value: 10,
                      label: context
                          .l10n
                          .eventSuccessEventSuccessSetupBodyLabel10s,
                    ),
                    CatchOption(
                      value: 15,
                      label: context
                          .l10n
                          .eventSuccessEventSuccessSetupBodyLabel15s,
                    ),
                  ],
                  value: draft.structureConfig.revealCountdownSeconds,
                  enabled: widget.editable,
                  onChanged: (seconds) {
                    widget.onDraftChanged(
                      draft.copyWith(
                        structureConfig: draft.structureConfig.copyWith(
                          revealCountdownSeconds: seconds,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
        gapH8,
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
        gapH8,
        SetupDisclosureSection(
          title: _structureSectionTitle(draft),
          subtitle: _structureSectionSubtitle(draft),
          children: [
            EventSuccessStructureConfigEditor(
              value: draft.structureConfig,
              targetAttendeeCount: draft.targetAttendeeCount,
              enabled: widget.editable,
              onChanged: (value) {
                widget.onDraftChanged(draft.copyWith(structureConfig: value));
              },
            ),
          ],
        ),
        gapH8,
        SetupDisclosureSection(
          title: context.l10n.eventSuccessEventSuccessSetupBodyTitleAdvanced,
          subtitle: _advancedSubtitle(draft),
          children: [
            QuestionnaireBlock(
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
          ],
        ),
        gapH8,
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
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CatchTextStyles.labelL(context)),
          if (subtitle != null) ...[
            gapH4,
            Text(
              subtitle!,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
          gapH6,
          ...children,
        ],
      ),
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
    return Padding(
      padding: CatchInsets.controlVerticalTight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: _foundationLineIconInset,
            child: Icon(
              CatchIcons.checkRounded,
              size: CatchIcon.md,
              color: t.primary,
            ),
          ),
          gapW8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CatchTextStyles.labelL(context)),
                if (subtitle != null) ...[
                  gapH2,
                  Text(
                    subtitle!,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline setup chips rendered beneath setup toggles in the During stage card.
class SetupChoiceChips<T> extends StatelessWidget {
  const SetupChoiceChips({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final List<CatchOption<T>> options;
  final T value;
  final bool enabled;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _setupNestedControlPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CatchTextStyles.labelM(context)),
          gapH6,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final option in options)
                CatchSelectChip(
                  label: option.label,
                  active: value == option.value,
                  enabled: enabled,
                  onTap: enabled ? () => onChanged(option.value) : null,
                ),
            ],
          ),
        ],
      ),
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
    final t = CatchTokens.of(context);
    final mode = _mode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.eventSuccessEventSuccessSetupBodyTextMatchClueQuestions,
          style: CatchTextStyles.labelL(context),
        ),
        gapH4,
        Text(
          _questionnaireModeSubtitle(mode),
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        gapH8,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            for (final option in _QuestionnaireMode.values)
              CatchSelectChip(
                label: _questionnaireModeLabel(option),
                active: mode == option,
                enabled: editable,
                onTap: editable ? () => onModeChanged(option) : null,
              ),
          ],
        ),
        if (active) ...[
          gapH12,
          EventSuccessQuestionnaireConfigEditor(
            value: questionnaireConfig,
            enabled: editable,
            onChanged: onQuestionnaireChanged,
            useBottomSheetForCustom: true,
          ),
        ],
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

class SetupDisclosureSection extends StatefulWidget {
  const SetupDisclosureSection({
    required this.title,
    required this.subtitle,
    required this.children,
    this.initiallyExpanded = false,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  State<SetupDisclosureSection> createState() => _SetupDisclosureSectionState();
}

class _SetupDisclosureSectionState extends State<SetupDisclosureSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _expanded,
          child: CatchSurface(
            tone: CatchSurfaceTone.transparent,
            radius: 0,
            borderWidth: 0,
            onTap: () => setState(() => _expanded = !_expanded),
            padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: CatchTextStyles.labelL(context),
                      ),
                      Padding(
                        padding: _disclosureSubtitlePadding,
                        child: Text(
                          widget.subtitle,
                          style: CatchTextStyles.supporting(
                            context,
                            color: t.ink2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                gapW12,
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: CatchMotion.fast,
                  curve: CatchMotion.standardCurve,
                  child: Icon(
                    CatchIcons.chevronRightRounded,
                    color: _expanded ? t.primary : t.ink2,
                    size: CatchIcon.sm,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: CatchMotion.fast,
          curve: CatchMotion.standardCurve,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: _disclosureChildrenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.children,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
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
