import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _customQuestionSetId = '__custom__';

class EventSuccessQuestionnaireConfigEditor extends StatelessWidget {
  const EventSuccessQuestionnaireConfigEditor({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final EventSuccessQuestionnaireConfig value;
  final ValueChanged<EventSuccessQuestionnaireConfig> onChanged;
  final bool enabled;

  /// When true, the custom-question builder opens in a modal bottom sheet
  /// instead of rendering inline. Keeps the host setup screen short while the
  /// host edits long custom question sets.

  @override
  Widget build(BuildContext context) {
    final pack = value.pack;
    final templates = EventSuccessQuestionnairePackLibrary.allTemplates;
    final questionSetIds = [
      ...templates.map((template) => template.id),
      _customQuestionSetId,
    ];
    final selectedQuestionSetId = value.usesCustom
        ? _customQuestionSetId
        : value.templateId;

    return CatchSectionList(
      gap: CatchGaps.formField,
      children: [
        CatchField.optionCards<String>(
          title: context
              .l10n
              .eventSuccessEventSuccessQuestionnaireConfigEditorTextQuestionSet,
          helperText: context.l10n
              .eventSuccessEventSuccessQuestionnaireConfigEditorLabelLengthQuestions(
                length: pack.questions.length,
              ),
          values: questionSetIds,
          itemTitle: (id) => id == _customQuestionSetId
              ? context
                    .l10n
                    .eventSuccessEventSuccessQuestionnaireConfigEditorLabelCustom
              : templates.firstWhere((template) => template.id == id).title,
          itemDescription: (id) => id == _customQuestionSetId
              ? EventSuccessQuestionnairePackLibrary.resolve(
                  const EventSuccessQuestionnaireConfig.customTemplate(),
                ).subtitle
              : templates.firstWhere((template) => template.id == id).subtitle,
          selected: selectedQuestionSetId,
          enabled: enabled,
          onChanged: enabled
              ? (id) {
                  onChanged(
                    id == _customQuestionSetId
                        ? (value.usesCustom
                              ? value
                              : const EventSuccessQuestionnaireConfig.customTemplate())
                        : EventSuccessQuestionnaireConfig(templateId: id),
                  );
                }
              : null,
        ),
        if (value.usesCustom)
          CustomQuestionnaireFields(
            value: value,
            enabled: enabled,
            onChanged: onChanged,
          ),
      ],
    );
  }
}

class CustomQuestionnaireFields extends StatelessWidget {
  const CustomQuestionnaireFields({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final EventSuccessQuestionnaireConfig value;
  final bool enabled;
  final ValueChanged<EventSuccessQuestionnaireConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final questions = value.customQuestions;
    return CatchSectionList(
      children: [
        CatchSection.fieldRows(
          first: true,
          child: CatchField.input(
            key: const ValueKey('customQuestionnaireTitle'),
            title: context
                .l10n
                .eventSuccessEventSuccessQuestionnaireConfigEditorTitleCustomQuestionSetName,
            initialValue:
                value.customTitle ??
                context
                    .l10n
                    .eventSuccessEventSuccessQuestionnaireConfigEditorVisiblecopyCustomQuestionSet,
            enabled: enabled,
            inputFormatters: [LengthLimitingTextInputFormatter(80)],
            textInputAction: TextInputAction.next,
            onChanged: (title) => onChanged(value.copyWith(customTitle: title)),
          ),
        ),
        for (
          var questionIndex = 0;
          questionIndex < questions.length;
          questionIndex++
        )
          CustomQuestionFields(
            question: questions[questionIndex],
            index: questionIndex,
            enabled: enabled,
            onChanged: (question) {
              final nextQuestions = [...questions];
              nextQuestions[questionIndex] = question;
              onChanged(value.copyWith(customQuestions: nextQuestions));
            },
            onRemove: questions.length <= 1
                ? null
                : () {
                    final nextQuestions = [...questions]
                      ..removeAt(questionIndex);
                    onChanged(value.copyWith(customQuestions: nextQuestions));
                  },
          ),
        CatchSection.plain(
          child: Row(
            children: [
              Expanded(
                child: CatchButton(
                  label: context
                      .l10n
                      .eventSuccessEventSuccessQuestionnaireConfigEditorLabelAddQuestion,
                  icon: Icon(CatchIcons.addRounded),
                  variant: CatchButtonVariant.secondary,
                  onPressed: enabled && questions.length < 8
                      ? () => onChanged(
                          value.copyWith(
                            customQuestions: [
                              ...questions,
                              _blankQuestion(questions, context.l10n),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              gapW10,
              Expanded(
                child: CatchButton(
                  label: context
                      .l10n
                      .eventSuccessEventSuccessQuestionnaireConfigEditorLabelReset,
                  icon: Icon(CatchIcons.refreshRounded),
                  variant: CatchButtonVariant.ghost,
                  onPressed: enabled
                      ? () => onChanged(
                          const EventSuccessQuestionnaireConfig.customTemplate(),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomQuestionFields extends StatelessWidget {
  const CustomQuestionFields({
    super.key,
    required this.question,
    required this.index,
    required this.enabled,
    required this.onChanged,
    required this.onRemove,
  });

  final EventSuccessCompatibilityQuestion question;
  final int index;
  final bool enabled;
  final ValueChanged<EventSuccessCompatibilityQuestion> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSection.containedFieldRows(
      title: context.l10n
          .eventSuccessEventSuccessQuestionnaireConfigEditorTextQuestionValue1(
            value1: index + 1,
          ),
      trailing: onRemove == null
          ? null
          : Tooltip(
              message: context
                  .l10n
                  .eventSuccessEventSuccessQuestionnaireConfigEditorMessageRemoveQuestion,
              child: CatchIconButton(
                onTap: enabled ? onRemove : null,
                child: Icon(
                  CatchIcons.deleteOutlineRounded,
                  size: CatchIcon.md,
                  color: enabled ? t.danger : t.ink3,
                ),
              ),
            ),
      children: [
        CatchField.input(
          key: ValueKey('customQuestionPrompt-$index'),
          title: context
              .l10n
              .eventSuccessEventSuccessQuestionnaireConfigEditorTitlePrompt,
          initialValue: question.prompt,
          enabled: enabled,
          inputFormatters: [LengthLimitingTextInputFormatter(140)],
          textInputAction: TextInputAction.next,
          onChanged: (prompt) => onChanged(question.copyWith(prompt: prompt)),
        ),
        for (
          var optionIndex = 0;
          optionIndex < question.options.length;
          optionIndex++
        )
          CatchField.input(
            key: ValueKey('customQuestionOption-$index-$optionIndex'),
            title: context.l10n
                .eventSuccessEventSuccessQuestionnaireConfigEditorTitleOptionValue1(
                  value1: optionIndex + 1,
                ),
            initialValue: question.options[optionIndex].label,
            enabled: enabled,
            inputFormatters: [LengthLimitingTextInputFormatter(60)],
            textInputAction: optionIndex == question.options.length - 1
                ? TextInputAction.done
                : TextInputAction.next,
            onChanged: (label) {
              final nextOptions = [...question.options];
              nextOptions[optionIndex] = nextOptions[optionIndex].copyWith(
                label: label,
              );
              onChanged(question.copyWith(options: nextOptions));
            },
          ),
      ],
    );
  }
}

EventSuccessCompatibilityQuestion _blankQuestion(
  List<EventSuccessCompatibilityQuestion> questions,
  AppLocalizations l10n,
) {
  final usedIds = questions.map((question) => question.id).toSet();
  var questionNumber = 1;
  while (usedIds.contains('custom_question_$questionNumber')) {
    questionNumber++;
  }
  return EventSuccessCompatibilityQuestion(
    id: 'custom_question_$questionNumber',
    prompt: l10n
        .eventSuccessEventSuccessQuestionnaireConfigEditorPromptCustomQuestionQuestionnumber(
          questionNumber: questionNumber,
        ),
    options: [
      EventSuccessCompatibilityOption(
        id: 'custom_question_${questionNumber}_option_1',
        label:
            l10n.eventSuccessEventSuccessQuestionnaireConfigEditorLabelOption1,
      ),
      EventSuccessCompatibilityOption(
        id: 'custom_question_${questionNumber}_option_2',
        label:
            l10n.eventSuccessEventSuccessQuestionnaireConfigEditorLabelOption2,
      ),
      EventSuccessCompatibilityOption(
        id: 'custom_question_${questionNumber}_option_3',
        label:
            l10n.eventSuccessEventSuccessQuestionnaireConfigEditorLabelOption3,
      ),
    ],
  );
}
