import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/event_success/domain/event_success_compatibility_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventSuccessQuestionnaireConfigEditor extends StatelessWidget {
  const EventSuccessQuestionnaireConfigEditor({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.useBottomSheetForCustom = false,
  });

  final EventSuccessQuestionnaireConfig value;
  final ValueChanged<EventSuccessQuestionnaireConfig> onChanged;
  final bool enabled;

  /// When true, the custom-question builder opens in a modal bottom sheet
  /// instead of rendering inline. Keeps the host setup screen short while the
  /// host edits long custom question sets.
  final bool useBottomSheetForCustom;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final normalized = value.normalized();
    final pack = normalized.pack;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question set', style: CatchTextStyles.labelL(context)),
        gapH6,
        Text(
          'Choose a reusable template or write custom questions for this event.',
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        gapH10,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            for (final template
                in EventSuccessQuestionnairePackLibrary.allTemplates)
              CatchChip(
                label: template.title,
                active:
                    !normalized.usesCustom &&
                    normalized.templateId == template.id,
                icon: const Icon(Icons.style_outlined),
                enabled: enabled,
                onTap: () => onChanged(
                  EventSuccessQuestionnaireConfig(templateId: template.id),
                ),
              ),
            CatchChip(
              label: 'Custom',
              active: normalized.usesCustom,
              icon: const Icon(Icons.edit_note_rounded),
              enabled: enabled,
              onTap: () => onChanged(
                normalized.usesCustom
                    ? normalized
                    : const EventSuccessQuestionnaireConfig.customTemplate(),
              ),
            ),
          ],
        ),
        gapH12,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CatchBadge(
              label: pack.title,
              tone: CatchBadgeTone.neutral,
              icon: pack.custom
                  ? Icons.edit_note_rounded
                  : Icons.style_outlined,
            ),
            CatchBadge(
              label: '${pack.questions.length} questions',
              tone: CatchBadgeTone.neutral,
              icon: Icons.quiz_outlined,
            ),
          ],
        ),
        gapH6,
        Text(
          pack.subtitle,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        if (normalized.usesCustom) ...[
          gapH14,
          if (useBottomSheetForCustom)
            CatchButton(
              label: 'Edit custom questions',
              icon: const Icon(Icons.edit_note_rounded),
              variant: CatchButtonVariant.secondary,
              onPressed: enabled
                  ? () => _openCustomQuestionnaireSheet(
                      context,
                      initial: normalized,
                      onChanged: onChanged,
                    )
                  : null,
              fullWidth: true,
            )
          else
            _CustomQuestionnaireFields(
              value: normalized,
              enabled: enabled,
              onChanged: onChanged,
            ),
        ] else ...[
          gapH12,
          _QuestionnairePreview(questions: pack.questions),
        ],
      ],
    );
  }
}

Future<void> _openCustomQuestionnaireSheet(
  BuildContext context, {
  required EventSuccessQuestionnaireConfig initial,
  required ValueChanged<EventSuccessQuestionnaireConfig> onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) =>
        _CustomQuestionnaireSheet(initialValue: initial, onChanged: onChanged),
  );
}

class _CustomQuestionnaireSheet extends StatefulWidget {
  const _CustomQuestionnaireSheet({
    required this.initialValue,
    required this.onChanged,
  });

  final EventSuccessQuestionnaireConfig initialValue;
  final ValueChanged<EventSuccessQuestionnaireConfig> onChanged;

  @override
  State<_CustomQuestionnaireSheet> createState() =>
      _CustomQuestionnaireSheetState();
}

class _CustomQuestionnaireSheetState extends State<_CustomQuestionnaireSheet> {
  late EventSuccessQuestionnaireConfig _value = widget.initialValue;

  void _emit(EventSuccessQuestionnaireConfig next) {
    setState(() => _value = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;
    return CatchBottomSheetScaffold(
      title: 'Custom questions',
      subtitle: 'Edit your event\'s match clue questions.',
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
          child: _CustomQuestionnaireFields(
            value: _value,
            enabled: true,
            onChanged: _emit,
          ),
        ),
      ),
    );
  }
}

class _QuestionnairePreview extends StatelessWidget {
  const _QuestionnairePreview({required this.questions});

  final List<EventSuccessCompatibilityQuestion> questions;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final question in questions.take(3)) ...[
          Text(question.prompt, style: CatchTextStyles.labelL(context)),
          gapH6,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final option in question.options)
                CatchBadge(label: option.label, tone: CatchBadgeTone.neutral),
            ],
          ),
          if (question != questions.take(3).last) gapH12,
        ],
        if (questions.length > 3) ...[
          gapH8,
          Text(
            '+ ${questions.length - 3} more',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ],
    );
  }
}

class _CustomQuestionnaireFields extends StatelessWidget {
  const _CustomQuestionnaireFields({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchTextField(
          key: const ValueKey('customQuestionnaireTitle'),
          label: 'Custom question set name',
          initialValue: value.customTitle ?? 'Custom question set',
          enabled: enabled,
          inputFormatters: [LengthLimitingTextInputFormatter(80)],
          textInputAction: TextInputAction.next,
          onChanged: (title) => onChanged(value.copyWith(customTitle: title)),
        ),
        gapH12,
        for (
          var questionIndex = 0;
          questionIndex < questions.length;
          questionIndex++
        ) ...[
          _CustomQuestionFields(
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
          gapH14,
        ],
        Row(
          children: [
            Expanded(
              child: CatchButton(
                label: 'Add question',
                icon: const Icon(Icons.add_rounded),
                variant: CatchButtonVariant.secondary,
                onPressed: enabled && questions.length < 8
                    ? () => onChanged(
                        value.copyWith(
                          customQuestions: [
                            ...questions,
                            _blankQuestion(questions.length),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            gapW10,
            Expanded(
              child: CatchButton(
                label: 'Reset',
                icon: const Icon(Icons.refresh_rounded),
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
      ],
    );
  }
}

class _CustomQuestionFields extends StatelessWidget {
  const _CustomQuestionFields({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Question ${index + 1}',
                style: CatchTextStyles.labelL(context),
              ),
            ),
            if (onRemove != null)
              IconButton(
                tooltip: 'Remove question',
                icon: const Icon(Icons.delete_outline_rounded),
                color: t.danger,
                onPressed: enabled ? onRemove : null,
              ),
          ],
        ),
        gapH6,
        CatchTextField(
          key: ValueKey('customQuestionPrompt-$index'),
          label: 'Prompt',
          initialValue: question.prompt,
          enabled: enabled,
          inputFormatters: [LengthLimitingTextInputFormatter(140)],
          textInputAction: TextInputAction.next,
          onChanged: (prompt) => onChanged(question.copyWith(prompt: prompt)),
        ),
        gapH8,
        for (
          var optionIndex = 0;
          optionIndex < question.options.length;
          optionIndex++
        ) ...[
          CatchTextField(
            key: ValueKey('customQuestionOption-$index-$optionIndex'),
            label: 'Option ${optionIndex + 1}',
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
          if (optionIndex != question.options.length - 1) gapH8,
        ],
      ],
    );
  }
}

EventSuccessCompatibilityQuestion _blankQuestion(int index) {
  final questionNumber = index + 1;
  return EventSuccessCompatibilityQuestion(
    id: 'custom_question_$questionNumber',
    prompt: 'Custom question $questionNumber',
    options: [
      EventSuccessCompatibilityOption(
        id: 'custom_question_${questionNumber}_option_1',
        label: 'Option 1',
      ),
      EventSuccessCompatibilityOption(
        id: 'custom_question_${questionNumber}_option_2',
        label: 'Option 2',
      ),
      EventSuccessCompatibilityOption(
        id: 'custom_question_${questionNumber}_option_3',
        label: 'Option 3',
      ),
    ],
  );
}
