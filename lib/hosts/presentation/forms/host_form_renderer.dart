import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class HostFormRenderer extends StatefulWidget {
  const HostFormRenderer({
    super.key,
    required this.definition,
    this.preview = true,
    this.onSubmit,
  });

  final HostFormDefinition definition;
  final bool preview;
  final VoidCallback? onSubmit;

  @override
  State<HostFormRenderer> createState() => _HostFormRendererState();
}

class _HostFormRendererState extends State<HostFormRenderer> {
  final Map<String, Object?> _answers = {};

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final sections = widget.definition.reachableSections(_answers);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.definition.title,
          style: CatchTextStyles.headline(context, color: t.ink),
        ),
        if (widget.definition.description case final description?) ...[
          gapH10,
          Text(
            description,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
        if (widget.definition.appearancePreset ==
                HostFormAppearancePreset.activity &&
            widget.definition.activityKind != null) ...[
          gapH12,
          Align(
            alignment: Alignment.centerLeft,
            child: CatchChip.tag(label: widget.definition.activityKind!),
          ),
        ],
        for (final indexedSection in sections.indexed)
          CatchSection.fieldRows(
            key: ValueKey(
              'host-form-renderer-section-${indexedSection.$2.sectionId}',
            ),
            title: indexedSection.$2.title,
            first: indexedSection.$1 == 0,
            footer: indexedSection.$2.description == null
                ? null
                : Text(
                    indexedSection.$2.description!,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
            children: [
              for (final question in indexedSection.$2.questions)
                _HostFormSchemaQuestionField(
                  question: question,
                  answer: _answers[question.questionId],
                  onChanged: (answer) =>
                      setState(() => _answers[question.questionId] = answer),
                ),
            ],
          ),
        gapH24,
        CatchButton(
          label: widget.preview
              ? context.l10n.hostFormPreviewSubmitDisabled
              : context.l10n.hostFormSubmit,
          onPressed: widget.preview ? null : widget.onSubmit,
          fullWidth: true,
          size: CatchButtonSize.lg,
        ),
        gapH12,
        Text(
          widget.preview
              ? context.l10n.hostFormPreviewNoResponses
              : widget.definition.completionTitle,
          textAlign: TextAlign.center,
          style: CatchTextStyles.recordContext(context),
        ),
      ],
    );
  }
}

class _HostFormSchemaQuestionField extends StatelessWidget {
  const _HostFormSchemaQuestionField({
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final HostFormQuestion question;
  final Object? answer;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final optional = !question.required;
    late final Widget field;
    switch (question.kind) {
      case HostFormQuestionKind.shortText:
      case HostFormQuestionKind.longText:
      case HostFormQuestionKind.date:
      case HostFormQuestionKind.phone:
      case HostFormQuestionKind.email:
      case HostFormQuestionKind.url:
      case HostFormQuestionKind.number:
        field = _HostFormSchemaBoundary(
          child: CatchField.input(
            key: ValueKey('host-form-renderer-question-${question.questionId}'),
            title: question.label,
            initialValue: switch (answer) {
              final String value => value,
              _ => null,
            },
            contractExemption:
                'Organizer-authored fields are validated by the versioned form contract.',
            helperText: question.helpText,
            isOptional: optional,
            maxLines: question.kind == HostFormQuestionKind.longText ? 5 : 1,
            keyboardType: _keyboardType(question.kind),
            onChanged: (value) => onChanged(
              question.kind == HostFormQuestionKind.number
                  ? num.tryParse(value)
                  : value,
            ),
          ),
        );
        break;
      case HostFormQuestionKind.singleChoice:
      case HostFormQuestionKind.multiChoice:
        final values = question.options.map((option) => option.value).toList();
        final selected = switch (answer) {
          final Set<String> values => values,
          final List<String> values => values.toSet(),
          final String value => {value},
          _ => <String>{},
        };
        field = _HostFormSchemaBoundary(
          child: CatchField.choices<String>(
            key: ValueKey('host-form-renderer-question-${question.questionId}'),
            title: question.label,
            contract: CatchContractConstraints
                .organizerFormVersionDocumentDefinitionSectionsItemsQuestionsItemsOptions,
            contractValue: (value) => value,
            body: question.helpText,
            values: values,
            itemLabel: (value) => question.options
                .firstWhere((option) => option.value == value)
                .label,
            selected: selected,
            multi: question.kind == HostFormQuestionKind.multiChoice,
            allowEmptySelection: optional,
            isOptional: optional,
            onSelectionChanged: (values) => onChanged(
              question.kind == HostFormQuestionKind.multiChoice
                  ? values.toList(growable: false)
                  : values.firstOrNull,
            ),
          ),
        );
        break;
      case HostFormQuestionKind.boolean:
      case HostFormQuestionKind.acknowledgement:
        field = _HostFormSchemaBoundary(
          child: CatchField.toggle(
            key: ValueKey('host-form-renderer-question-${question.questionId}'),
            title: question.label,
            body: question.helpText,
            contractExemption:
                'Organizer-authored boolean fields are validated by the form contract.',
            value: answer == true,
            onChanged: onChanged,
          ),
        );
        break;
      case HostFormQuestionKind.file:
        field = _HostFormSchemaBoundary(
          child: CatchField.action(
            key: ValueKey('host-form-renderer-question-${question.questionId}'),
            title: question.label,
            body: question.helpText,
            icon: CatchIcons.cloudUploadOutlined,
            placeholder: context.l10n.hostFormPreviewUploadPlaceholder,
            onTap: null,
          ),
        );
        break;
      case HostFormQuestionKind.signature:
        field = _HostFormSchemaBoundary(
          child: CatchField.action(
            key: ValueKey('host-form-renderer-question-${question.questionId}'),
            title: question.label,
            body: question.helpText,
            icon: CatchIcons.editNoteOutlined,
            placeholder: context.l10n.hostFormPreviewSignaturePlaceholder,
            onTap: null,
          ),
        );
        break;
    }
    return field;
  }
}

class _HostFormSchemaBoundary extends StatelessWidget {
  const _HostFormSchemaBoundary({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

TextInputType _keyboardType(HostFormQuestionKind kind) => switch (kind) {
  HostFormQuestionKind.phone => TextInputType.phone,
  HostFormQuestionKind.email => TextInputType.emailAddress,
  HostFormQuestionKind.url => TextInputType.url,
  HostFormQuestionKind.number => const TextInputType.numberWithOptions(
    decimal: true,
    signed: true,
  ),
  HostFormQuestionKind.date => TextInputType.datetime,
  _ => TextInputType.text,
};
