import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
            style: CatchTextStyles.bodyM(context, color: t.ink2),
          ),
        ],
        for (final indexedSection in widget.definition.sections.indexed)
          CatchSection.fieldRows(
            key: ValueKey(
              'host-form-renderer-section-${indexedSection.$2.sectionId}',
            ),
            title: indexedSection.$2.title,
            first: indexedSection.$1 == 0,
            footer: indexedSection.$2.description == null
                ? null
                : Text(indexedSection.$2.description!),
            children: [
              for (final question in indexedSection.$2.questions)
                _questionField(context, question),
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
          style: CatchTextStyles.monoLabel(context, color: t.ink3),
        ),
      ],
    );
  }

  Widget _questionField(BuildContext context, HostFormQuestion question) {
    final optional = !question.required;
    switch (question.kind) {
      case HostFormQuestionKind.shortText:
      case HostFormQuestionKind.longText:
      case HostFormQuestionKind.date:
      case HostFormQuestionKind.phone:
      case HostFormQuestionKind.email:
      case HostFormQuestionKind.url:
      case HostFormQuestionKind.number:
        return CatchField.input(
          key: ValueKey('host-form-renderer-question-${question.questionId}'),
          title: question.label,
          initialValue: switch (_answers[question.questionId]) {
            final String value => value,
            _ => null,
          },
          contractExemption:
              'Organizer-authored fields are validated by the versioned form contract.',
          helperText: question.helpText,
          isOptional: optional,
          maxLines: question.kind == HostFormQuestionKind.longText ? 5 : 1,
          keyboardType: _keyboardType(question.kind),
          onChanged: (value) => _answers[question.questionId] = value,
        );
      case HostFormQuestionKind.singleChoice:
      case HostFormQuestionKind.multiChoice:
        final values = question.options.map((option) => option.value).toList();
        final selected = switch (_answers[question.questionId]) {
          final Set<String> values => values,
          _ => <String>{},
        };
        return CatchField.choices<String>(
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
          onSelectionChanged: (values) => setState(
            () => _answers[question.questionId] = Set<String>.from(values),
          ),
        );
      case HostFormQuestionKind.boolean:
      case HostFormQuestionKind.acknowledgement:
        return CatchField.toggle(
          key: ValueKey('host-form-renderer-question-${question.questionId}'),
          title: question.label,
          body: question.helpText,
          contractExemption:
              'Organizer-authored boolean fields are validated by the form contract.',
          value: _answers[question.questionId] == true,
          onChanged: (value) =>
              setState(() => _answers[question.questionId] = value),
        );
      case HostFormQuestionKind.file:
        return CatchField.action(
          key: ValueKey('host-form-renderer-question-${question.questionId}'),
          title: question.label,
          body: question.helpText,
          icon: CatchIcons.cloudUploadOutlined,
          placeholder: context.l10n.hostFormPreviewUploadPlaceholder,
          onTap: null,
        );
      case HostFormQuestionKind.signature:
        return CatchField.action(
          key: ValueKey('host-form-renderer-question-${question.questionId}'),
          title: question.label,
          body: question.helpText,
          icon: CatchIcons.editNoteOutlined,
          placeholder: context.l10n.hostFormPreviewSignaturePlaceholder,
          onTap: null,
        );
    }
  }
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
