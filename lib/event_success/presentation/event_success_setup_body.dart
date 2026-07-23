import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_questionnaire_config_editor.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_structure_config_editor.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef EventSuccessHostDraftUpdate =
    EventSuccessHostDraft Function(EventSuccessHostDraft current);

/// Compact Event Success setup shared by create-event defaults and Host Manage.
///
/// Text remains raw while the host edits. Domain normalization happens only at
/// the explicit persistence boundary, so clearing or replacing a value never
/// causes the UI to fight the user's input.
class EventSuccessSetupBody extends StatefulWidget {
  const EventSuccessSetupBody({
    super.key,
    required this.draft,
    required this.eventFormat,
    required this.targetAttendeeCount,
    required this.attendeePrompt,
    required this.onChanged,
    required this.onAttendeePromptChanged,
    this.editable = true,
    this.planLeadingRows = const [],
    this.showResetToRecommended = false,
    this.onResetToRecommended,
  }) : assert(
         !showResetToRecommended || onResetToRecommended != null,
         'onResetToRecommended must be provided when reset is visible',
       );

  final EventSuccessHostDraft draft;
  final EventFormatSnapshot eventFormat;
  final int targetAttendeeCount;
  final String? attendeePrompt;
  final ValueChanged<EventSuccessHostDraftUpdate> onChanged;
  final ValueChanged<String> onAttendeePromptChanged;
  final bool editable;
  final List<Widget> planLeadingRows;
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
  bool _hostGoalOpen = false;
  bool _attendeePromptOpen = false;

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
    final draft = widget.draft;
    final profile = EventSuccessActivityProfile.forFormat(
      widget.eventFormat,
      targetAttendeeCount: widget.targetAttendeeCount,
    );
    final liveTools = profile.recommendations
        .where((recommendation) => recommendation.selectable)
        .where((recommendation) => recommendation.module.hostConfigurable)
        .toList(growable: false);
    final showStructureEditor =
        draft.isModuleSelected(EventSuccessModuleCatalog.microPods.id) ||
        draft.isModuleSelected(EventSuccessModuleCatalog.guidedRotations.id) ||
        draft.isModuleSelected(EventSuccessModuleCatalog.liveReveal.id) ||
        draft.structureConfig.unitKind != EventSuccessUnitKind.wholeGroup;

    return CatchSectionList(
      emptyStateOmitted: true,
      children: [
        CatchSection.fieldRows(
          first: true,
          title: context.l10n.eventSuccessEventSuccessHostSetupTitleYourPlan,
          children: [
            CatchField.read(
              title: profile.formatLabel,
              body: profile.summary,
              valueText: profile.interactionModel.label,
              action:
                  widget.showResetToRecommended &&
                      widget.onResetToRecommended != null
                  ? CatchTextButton(
                      label: context
                          .l10n
                          .eventSuccessEventSuccessSetupBodyLabelReset,
                      onPressed: widget.onResetToRecommended,
                    )
                  : null,
            ),
            ...widget.planLeadingRows,
            CatchField.inputActions(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTitleYourGoalForTheEvent,
              contract:
                  CatchContractConstraints.eventSuccessPlanDocumentHostGoal,
              controller: _hostGoalController,
              open: _hostGoalOpen,
              onOpenChanged: (open) =>
                  setState(() => _hostGoalOpen = open && widget.editable),
              onCancel: _cancelHostGoal,
              onSubmit: _submitHostGoal,
              enabled: widget.editable,
              inputHint: draft.hostGoal,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              error: _hostGoalController.text.trim().isEmpty
                  ? context
                        .l10n
                        .eventSuccessEventSuccessHostSetupTextAddAGoalSoTheLiveGuideKnowsWhatToAimFor
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            CatchField.inputActions(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTitleMessageToAttendees,
              contract: CatchContractConstraints
                  .eventSuccessPlanDocumentAttendeePrompt,
              controller: _attendeePromptController,
              open: _attendeePromptOpen,
              onOpenChanged: (open) =>
                  setState(() => _attendeePromptOpen = open && widget.editable),
              onCancel: _cancelAttendeePrompt,
              onSubmit: _submitAttendeePrompt,
              enabled: widget.editable,
              inputHint: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyPlaceholderSomethingAttendeesSeeBeforeTheEventKicksOff,
              supporting: Text(
                context.l10n
                    .eventSuccessEventSuccessSetupBodyTextAttendeesWillSeeText(
                      text: _attendeePromptPreview(
                        profile,
                        widget.attendeePrompt,
                      ),
                    ),
                style: CatchTextStyles.supporting(context),
              ),
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
        for (final bucket in _EventSuccessStageBucket.values) ...[
          if (_recommendationsForBucket(liveTools, bucket).isNotEmpty)
            CatchSection.fieldRows(
              title: _bucketTitle(context, bucket),
              children: [
                for (final recommendation in _recommendationsForBucket(
                  liveTools,
                  bucket,
                ))
                  EventSuccessModuleRows._(
                    recommendation: recommendation,
                    draft: draft,
                    editable: widget.editable,
                    onModuleChanged: (selected) => _applyImmediateDraftUpdate(
                      (current) => current.withModuleSelection(
                        recommendation.module.id,
                        selected,
                      ),
                    ),
                    onDraftChanged: widget.onChanged,
                    onQuestionnaireModeChanged: (mode) =>
                        _setQuestionnaireMode(mode),
                  ),
              ],
            ),
          if (bucket == _EventSuccessStageBucket.during && showStructureEditor)
            EventSuccessStructureConfigEditor(
              sectionTitle: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTitleHowTheRoomIsGrouped,
              value: draft.structureConfig,
              targetAttendeeCount: widget.targetAttendeeCount,
              enabled: widget.editable,
              onChanged: (value) => widget.onChanged(
                (current) => current.copyWith(structureConfig: value),
              ),
            ),
        ],
      ],
    );
  }

  void _applyImmediateDraftUpdate(EventSuccessHostDraftUpdate update) {
    widget.onChanged(update);
  }

  void _cancelHostGoal() {
    _setText(_hostGoalController, widget.draft.hostGoal);
    setState(() => _hostGoalOpen = false);
  }

  void _submitHostGoal() {
    final value = _hostGoalController.text;
    if (value.trim().isEmpty) {
      setState(() {});
      return;
    }
    widget.onChanged((current) => current.copyWith(hostGoal: value));
    setState(() => _hostGoalOpen = false);
  }

  void _cancelAttendeePrompt() {
    _setText(_attendeePromptController, widget.attendeePrompt ?? '');
    setState(() => _attendeePromptOpen = false);
  }

  void _submitAttendeePrompt() {
    widget.onAttendeePromptChanged(_attendeePromptController.text);
    setState(() => _attendeePromptOpen = false);
  }

  void _setQuestionnaireMode(_QuestionnaireMode mode) {
    final active = mode != _QuestionnaireMode.off;
    widget.onChanged(
      (current) => current
          .withModuleSelection(
            EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
            active,
          )
          .copyWith(
            compatibilityAffectsRanking:
                active && mode == _QuestionnaireMode.cluesAndPairing,
          ),
    );
  }
}

class EventSuccessModuleRows extends StatelessWidget {
  const EventSuccessModuleRows._({
    required this._recommendation,
    required this._draft,
    required this._editable,
    required this._onModuleChanged,
    required this._onDraftChanged,
    required this._onQuestionnaireModeChanged,
  });

  final EventSuccessModuleRecommendation _recommendation;
  final EventSuccessHostDraft _draft;
  final bool _editable;
  final ValueChanged<bool> _onModuleChanged;
  final ValueChanged<EventSuccessHostDraftUpdate> _onDraftChanged;
  final ValueChanged<_QuestionnaireMode> _onQuestionnaireModeChanged;

  @override
  Widget build(BuildContext context) {
    final module = _recommendation.module;
    final questionnaire =
        module.id == EventSuccessModuleCatalog.compatibilityQuestionnaire.id;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (questionnaire)
          CatchField.optionCards<_QuestionnaireMode>(
            key: ValueKey('eventSuccessModule-${module.id}'),
            title: context
                .l10n
                .eventSuccessEventSuccessSetupBodyTextMatchClueQuestions,
            contract: CatchContractConstraints
                .eventSuccessPlanDocumentSelectedModuleIds,
            contractValue: (value) => value.name,
            values: _QuestionnaireMode.values,
            itemTitle: (mode) => switch (mode) {
              _QuestionnaireMode.off =>
                context.l10n.eventSuccessEventSuccessSetupBodyLabelOff,
              _QuestionnaireMode.cluesOnly =>
                context.l10n.eventSuccessEventSuccessSetupBodyLabelCluesOnly,
              _QuestionnaireMode.cluesAndPairing =>
                context
                    .l10n
                    .eventSuccessEventSuccessSetupBodyLabelCluesSoftPairing,
            },
            itemDescription: (mode) => switch (mode) {
              _QuestionnaireMode.off =>
                context
                    .l10n
                    .eventSuccessEventSuccessSetupBodyTextOptionalPromptsAreOff,
              _QuestionnaireMode.cluesOnly =>
                context
                    .l10n
                    .eventSuccessEventSuccessSetupBodyTextAnswersCreateRevealClues,
              _QuestionnaireMode.cluesAndPairing =>
                context
                    .l10n
                    .eventSuccessEventSuccessSetupBodyTextAnswersCreateCluesAndSoftlyGuidePairings,
            },
            selected: _questionnaireMode(_draft),
            enabled: _editable,
            onChanged: _editable ? _onQuestionnaireModeChanged : null,
          )
        else
          CatchField.toggle(
            key: ValueKey('eventSuccessModule-${module.id}'),
            title: module.title,
            contract: CatchContractConstraints
                .eventSuccessPlanDocumentSelectedModuleIds,
            body: _recommendation.reason,
            badgeLabel: _recommendationBadgeLabel(_recommendation),
            bodyMaxLines: 3,
            value: _draft.isModuleSelected(module.id),
            onChanged: _editable ? _onModuleChanged : null,
          ),
        if (questionnaire && _draft.isModuleSelected(module.id))
          KeyedSubtree(
            key: const ValueKey('eventSuccessQuestionnaireConfig'),
            child: EventSuccessQuestionnaireConfigEditor(
              value: _draft.questionnaireConfig,
              enabled: _editable,
              onChanged: (value) => _onDraftChanged(
                (current) => current.copyWith(questionnaireConfig: value),
              ),
            ),
          ),
        if (module.id == EventSuccessModuleCatalog.guidedRotations.id &&
            _draft.isModuleSelected(module.id))
          CatchSection.containedFieldRows(
            key: const ValueKey('eventSuccessRotationConfig'),
            child: CatchField.choices<int?>(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyLabelSwitchPartnersEvery,
              contract: CatchContractConstraints
                  .eventSuccessPlanDocumentStructureConfigRotationIntervalMinutes,
              contractValue: (value) => value?.toString() ?? '',
              values: const <int?>[null, 10, 15, 20, 30],
              itemLabel: (value) => switch (value) {
                null =>
                  context.l10n.eventSuccessEventSuccessSetupBodyLabelNoTimer,
                10 => context.l10n.eventSuccessEventSuccessSetupBodyLabel10Min,
                15 => context.l10n.eventSuccessEventSuccessSetupBodyLabel15Min,
                20 => context.l10n.eventSuccessEventSuccessSetupBodyLabel20Min,
                _ => context.l10n.eventSuccessEventSuccessSetupBodyLabel30Min,
              },
              selected: {_draft.structureConfig.rotationIntervalMinutes},
              enabled: _editable,
              onSelectionChanged: _editable
                  ? (selection) => _onDraftChanged(
                      (current) => current.copyWith(
                        structureConfig: current.structureConfig.copyWith(
                          rotationIntervalMinutes: selection.single,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        if (module.id == EventSuccessModuleCatalog.liveReveal.id &&
            _draft.isModuleSelected(module.id))
          CatchSection.containedFieldRows(
            key: const ValueKey('eventSuccessRevealConfig'),
            child: CatchField.choices<int>(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyLabelRevealCountdown,
              contract: CatchContractConstraints
                  .eventSuccessPlanDocumentStructureConfigRevealCountdownSeconds,
              contractValue: (value) => value.toString(),
              values: const [0, 5, 10, 15],
              itemLabel: (value) => switch (value) {
                0 => context.l10n.eventSuccessEventSuccessSetupBodyLabelOff,
                5 => context.l10n.eventSuccessEventSuccessSetupBodyLabel5s,
                10 => context.l10n.eventSuccessEventSuccessSetupBodyLabel10s,
                _ => context.l10n.eventSuccessEventSuccessSetupBodyLabel15s,
              },
              selected: {_draft.structureConfig.revealCountdownSeconds},
              enabled: _editable,
              onSelectionChanged: _editable
                  ? (selection) => _onDraftChanged(
                      (current) => current.copyWith(
                        structureConfig: current.structureConfig.copyWith(
                          revealCountdownSeconds: selection.single,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

enum _EventSuccessStageBucket { before, arrival, during, after }

List<EventSuccessModuleRecommendation> _recommendationsForBucket(
  List<EventSuccessModuleRecommendation> recommendations,
  _EventSuccessStageBucket bucket,
) => recommendations
    .where(
      (recommendation) => _bucketFor(recommendation.module.stage) == bucket,
    )
    .toList(growable: false);

_EventSuccessStageBucket _bucketFor(EventSuccessStage stage) => switch (stage) {
  EventSuccessStage.before => _EventSuccessStageBucket.before,
  EventSuccessStage.arrival => _EventSuccessStageBucket.arrival,
  EventSuccessStage.opening ||
  EventSuccessStage.activity ||
  EventSuccessStage.mixing ||
  EventSuccessStage.closing => _EventSuccessStageBucket.during,
  EventSuccessStage.after ||
  EventSuccessStage.hostDebrief => _EventSuccessStageBucket.after,
};

String _bucketTitle(BuildContext context, _EventSuccessStageBucket bucket) =>
    switch (bucket) {
      _EventSuccessStageBucket.before =>
        context.l10n.eventSuccessEventSuccessSetupBodyTitleBeforeTheEvent,
      _EventSuccessStageBucket.arrival =>
        context.l10n.eventSuccessEventSuccessSetupBodyTitleWhenPeopleArrive,
      _EventSuccessStageBucket.during =>
        context.l10n.eventSuccessEventSuccessSetupBodyTitleDuringTheEvent,
      _EventSuccessStageBucket.after =>
        context.l10n.eventSuccessEventSuccessSetupBodyTitleAfterTheEvent,
    };

String? _recommendationBadgeLabel(
  EventSuccessModuleRecommendation recommendation,
) {
  final level = recommendation.level;
  return switch (level) {
    EventSuccessRecommendationLevel.recommended ||
    EventSuccessRecommendationLevel.discouraged => level.label,
    _ => null,
  };
}

enum _QuestionnaireMode { off, cluesOnly, cluesAndPairing }

_QuestionnaireMode _questionnaireMode(EventSuccessHostDraft draft) {
  if (!draft.isModuleSelected(
    EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
  )) {
    return _QuestionnaireMode.off;
  }
  return draft.compatibilityAffectsRanking
      ? _QuestionnaireMode.cluesAndPairing
      : _QuestionnaireMode.cluesOnly;
}

String _attendeePromptPreview(
  EventSuccessActivityProfile profile,
  String? typed,
) {
  final configured = typed?.trim();
  return configured == null || configured.isEmpty
      ? profile.defaultAttendeePrompt
      : configured;
}

void _setText(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.value = TextEditingValue(
    text: value,
    selection: TextSelection.collapsed(offset: value.length),
  );
}
