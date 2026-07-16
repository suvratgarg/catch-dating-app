import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
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
    required this.onDraftChanged,
    required this.onAttendeePromptChanged,
    this.onImmediateDraftChanged,
    this.editable = true,
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
  final ValueChanged<EventSuccessHostDraft> onDraftChanged;
  final ValueChanged<EventSuccessHostDraftUpdate>? onImmediateDraftChanged;
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
    final draft = widget.draft;
    final profile = EventSuccessActivityProfile.forFormat(
      widget.eventFormat,
      targetAttendeeCount: widget.targetAttendeeCount,
    );
    final liveTools = profile.recommendations
        .where((recommendation) => recommendation.selectable)
        .where(
          (recommendation) =>
              !_platformModuleIds.contains(recommendation.module.id) &&
              recommendation.module.id !=
                  EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
        )
        .toList(growable: false);

    return CatchSectionList(
      children: [
        CatchSection.fieldRows(
          first: true,
          title: context.l10n.eventSuccessEventSuccessHostSetupTitleYourPlan,
          children: [
            CatchField.read(
              title: profile.formatLabel,
              body: profile.summary,
              valueText: context.l10n
                  .eventSuccessEventSuccessSetupBodyVisiblecopyMinimumcapacityMaximumcapacityGuests(
                    minimumCapacity: draft.playbook.capacity.min,
                    maximumCapacity: draft.playbook.capacity.max,
                  ),
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
            CatchField.input(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTitleYourGoalForTheEvent,
              controller: _hostGoalController,
              enabled: widget.editable,
              inputHint: draft.hostGoal,
              inputFormatters: [LengthLimitingTextInputFormatter(300)],
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              errorText: _hostGoalController.text.trim().isEmpty
                  ? context
                        .l10n
                        .eventSuccessEventSuccessHostSetupTextAddAGoalSoTheLiveGuideKnowsWhatToAimFor
                  : null,
              onChanged: (value) {
                widget.onDraftChanged(draft.copyWith(hostGoal: value));
                setState(() {});
              },
            ),
            CatchField.input(
              title: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyTitleMessageToAttendees,
              isOptional: true,
              controller: _attendeePromptController,
              enabled: widget.editable,
              inputHint: context
                  .l10n
                  .eventSuccessEventSuccessSetupBodyPlaceholderSomethingAttendeesSeeBeforeTheEventKicksOff,
              helperText: context.l10n
                  .eventSuccessEventSuccessSetupBodyTextAttendeesWillSeeText(
                    text: _attendeePromptPreview(
                      profile,
                      widget.attendeePrompt,
                    ),
                  ),
              inputFormatters: [LengthLimitingTextInputFormatter(300)],
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              onChanged: widget.onAttendeePromptChanged,
            ),
          ],
        ),
        CatchSection.fieldRows(
          title: context.l10n.eventSuccessEventSuccessSetupBodyTitleLiveTools,
          children: [
            for (final recommendation in liveTools)
              CatchField.toggle(
                title: recommendation.module.title,
                body: recommendation.reason,
                value: draft.isModuleSelected(recommendation.module.id),
                onChanged: widget.editable
                    ? (selected) => _applyImmediateDraftUpdate(
                        (current) => current.withModuleSelection(
                          recommendation.module.id,
                          selected,
                        ),
                      )
                    : null,
              ),
            if (draft.isModuleSelected(
              EventSuccessModuleCatalog.guidedRotations.id,
            ))
              CatchField.choices<int?>(
                title: context
                    .l10n
                    .eventSuccessEventSuccessSetupBodyLabelSwitchPartnersEvery,
                values: const <int?>[null, 10, 15, 20, 30],
                itemLabel: (value) => switch (value) {
                  null =>
                    context.l10n.eventSuccessEventSuccessSetupBodyLabelNoTimer,
                  10 =>
                    context.l10n.eventSuccessEventSuccessSetupBodyLabel10Min,
                  15 =>
                    context.l10n.eventSuccessEventSuccessSetupBodyLabel15Min,
                  20 =>
                    context.l10n.eventSuccessEventSuccessSetupBodyLabel20Min,
                  _ => context.l10n.eventSuccessEventSuccessSetupBodyLabel30Min,
                },
                selected: {draft.structureConfig.rotationIntervalMinutes},
                enabled: widget.editable,
                onSelectionChanged: widget.editable
                    ? (selection) => widget.onDraftChanged(
                        draft.copyWith(
                          structureConfig: draft.structureConfig.copyWith(
                            rotationIntervalMinutes: selection.single,
                          ),
                        ),
                      )
                    : null,
              ),
            if (draft.isModuleSelected(EventSuccessModuleCatalog.liveReveal.id))
              CatchField.choices<int>(
                title: context
                    .l10n
                    .eventSuccessEventSuccessSetupBodyLabelRevealCountdown,
                values: const [0, 5, 10, 15],
                itemLabel: (value) => switch (value) {
                  0 => context.l10n.eventSuccessEventSuccessSetupBodyLabelOff,
                  5 => context.l10n.eventSuccessEventSuccessSetupBodyLabel5s,
                  10 => context.l10n.eventSuccessEventSuccessSetupBodyLabel10s,
                  _ => context.l10n.eventSuccessEventSuccessSetupBodyLabel15s,
                },
                selected: {draft.structureConfig.revealCountdownSeconds},
                enabled: widget.editable,
                onSelectionChanged: widget.editable
                    ? (selection) => widget.onDraftChanged(
                        draft.copyWith(
                          structureConfig: draft.structureConfig.copyWith(
                            revealCountdownSeconds: selection.single,
                          ),
                        ),
                      )
                    : null,
              ),
          ],
        ),
        EventSuccessStructureConfigEditor(
          sectionTitle: context
              .l10n
              .eventSuccessEventSuccessSetupBodyTitleHowTheRoomIsGrouped,
          value: draft.structureConfig,
          targetAttendeeCount: widget.targetAttendeeCount,
          enabled: widget.editable,
          onChanged: (value) =>
              widget.onDraftChanged(draft.copyWith(structureConfig: value)),
        ),
        CatchSection.fieldRows(
          child: CatchField.choices<_QuestionnaireMode>(
            title: context
                .l10n
                .eventSuccessEventSuccessSetupBodyTextMatchClueQuestions,
            body: switch (_questionnaireMode(draft)) {
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
            values: _QuestionnaireMode.values,
            itemLabel: (mode) => switch (mode) {
              _QuestionnaireMode.off =>
                context.l10n.eventSuccessEventSuccessSetupBodyLabelOff,
              _QuestionnaireMode.cluesOnly =>
                context.l10n.eventSuccessEventSuccessSetupBodyLabelCluesOnly,
              _QuestionnaireMode.cluesAndPairing =>
                context
                    .l10n
                    .eventSuccessEventSuccessSetupBodyLabelCluesSoftPairing,
            },
            selected: {_questionnaireMode(draft)},
            enabled: widget.editable,
            onSelectionChanged: widget.editable
                ? (selection) => _setQuestionnaireMode(draft, selection.single)
                : null,
          ),
        ),
        if (draft.isModuleSelected(
          EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
        ))
          EventSuccessQuestionnaireConfigEditor(
            value: draft.questionnaireConfig,
            enabled: widget.editable,
            onChanged: (value) => widget.onDraftChanged(
              draft.copyWith(questionnaireConfig: value),
            ),
          ),
      ],
    );
  }

  void _applyImmediateDraftUpdate(EventSuccessHostDraftUpdate update) {
    final immediate = widget.onImmediateDraftChanged;
    if (immediate != null) {
      immediate(update);
      return;
    }
    widget.onDraftChanged(update(widget.draft));
  }

  void _setQuestionnaireMode(
    EventSuccessHostDraft draft,
    _QuestionnaireMode mode,
  ) {
    final active = mode != _QuestionnaireMode.off;
    widget.onDraftChanged(
      draft
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

enum _QuestionnaireMode { off, cluesOnly, cluesAndPairing }

const _platformModuleIds = <String>{
  'safety_controls',
  'qr_check_in',
  'crowd_balance',
};

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
