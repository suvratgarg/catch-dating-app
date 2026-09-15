import 'package:catch_dating_app/hosts/data/host_forms_repository.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_definition.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_editor.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_question.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_availability_field.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_number_field.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_question_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_settings_section_list.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_validation_field_lanes.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_validation_text_field.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/hosts/host_form_workspace_use_cases.dart';
import 'package:widgetbook_workspace/support/page_preview.dart';
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Autosaved form settings',
  type: HostFormSettingsSectionList,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormSettingsSectionListPreview(BuildContext context) =>
    _editorPreview(
      title: 'HostFormSettingsSectionList',
      catalogId: 'host.form_settings',
      children: (state, notifier) => [
        WidgetbookContentFrame(
          child: HostFormSettingsSectionList(
            definition: state.editor.definition,
            notifier: notifier,
          ),
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Opening and closing dates',
  type: HostFormAvailabilityField,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormAvailabilityFieldPreview(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'HostFormAvailabilityField',
      catalogId: 'host.form_availability',
      children: [
        for (final endOfDay in [false, true])
          WidgetbookPageStateCard(
            label: endOfDay ? 'Closing date' : 'Opening date',
            child: WidgetbookContentFrame(
              child: HostFormAvailabilityField(
                title: endOfDay ? 'Closes at' : 'Opens at',
                value: endOfDay ? DateTime.utc(2026, 10, 1) : null,
                endOfDay: endOfDay,
                onChanged: (_) {},
              ),
            ),
          ),
      ],
    );

@widgetbook.UseCase(
  name: 'Inline and inspector question editing',
  type: HostFormQuestionSection,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormQuestionSectionPreview(BuildContext context) => _editorPreview(
  title: 'HostFormQuestionSection',
  catalogId: 'host.form_question',
  children: (state, notifier) => [
    for (final compact in [true, false])
      WidgetbookPageStateCard(
        label: compact ? 'Inline editor' : 'Inspector',
        child: WidgetbookContentFrame(
          child: HostFormQuestionSection(
            sectionIndex: 0,
            questionIndex: 0,
            question: state.editor.definition.sections.first.questions.first,
            questionCount:
                state.editor.definition.sections.first.questions.length,
            sections: state.editor.definition.sections,
            notifier: notifier,
            compact: compact,
          ),
        ),
      ),
  ],
);

@widgetbook.UseCase(
  name: 'Text answer validation',
  type: HostFormValidationFieldLanes,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormTextValidationPreview(BuildContext context) => _editorPreview(
  title: 'HostFormValidationFieldLanes',
  catalogId: 'host.form_validation.shortText',
  firstQuestionKind: HostFormQuestionKind.shortText,
  children: (state, notifier) => [
    WidgetbookContentFrame(
      child: HostFormValidationFieldLanes(
        sectionIndex: 0,
        questionIndex: 0,
        question: state.editor.definition.sections.first.questions.first,
        notifier: notifier,
      ),
    ),
  ],
);

@widgetbook.UseCase(
  name: 'Number answer validation',
  type: HostFormValidationFieldLanes,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormNumberValidationPreview(BuildContext context) => _editorPreview(
  title: 'HostFormValidationFieldLanes',
  catalogId: 'host.form_validation.number',
  firstQuestionKind: HostFormQuestionKind.number,
  children: (state, notifier) => [
    WidgetbookContentFrame(
      child: HostFormValidationFieldLanes(
        sectionIndex: 0,
        questionIndex: 0,
        question: state.editor.definition.sections.first.questions.first,
        notifier: notifier,
      ),
    ),
  ],
);

@widgetbook.UseCase(
  name: 'Date answer validation',
  type: HostFormValidationFieldLanes,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormDateValidationPreview(BuildContext context) => _editorPreview(
  title: 'HostFormValidationFieldLanes',
  catalogId: 'host.form_validation.date',
  firstQuestionKind: HostFormQuestionKind.date,
  children: (state, notifier) => [
    WidgetbookContentFrame(
      child: HostFormValidationFieldLanes(
        sectionIndex: 0,
        questionIndex: 0,
        question: state.editor.definition.sections.first.questions.first,
        notifier: notifier,
      ),
    ),
  ],
);

@widgetbook.UseCase(
  name: 'Choices answer validation',
  type: HostFormValidationFieldLanes,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormChoicesValidationPreview(BuildContext context) => _editorPreview(
  title: 'HostFormValidationFieldLanes',
  catalogId: 'host.form_validation.multiChoice',
  firstQuestionKind: HostFormQuestionKind.multiChoice,
  children: (state, notifier) => [
    WidgetbookContentFrame(
      child: HostFormValidationFieldLanes(
        sectionIndex: 0,
        questionIndex: 0,
        question: state.editor.definition.sections.first.questions.first,
        notifier: notifier,
      ),
    ),
  ],
);

@widgetbook.UseCase(
  name: 'File answer validation',
  type: HostFormValidationFieldLanes,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormFileValidationPreview(BuildContext context) => _editorPreview(
  title: 'HostFormValidationFieldLanes',
  catalogId: 'host.form_validation.file',
  firstQuestionKind: HostFormQuestionKind.file,
  children: (state, notifier) => [
    WidgetbookContentFrame(
      child: HostFormValidationFieldLanes(
        sectionIndex: 0,
        questionIndex: 0,
        question: state.editor.definition.sections.first.questions.first,
        notifier: notifier,
      ),
    ),
  ],
);

@widgetbook.UseCase(
  name: 'Integer and decimal limits',
  type: HostFormNumberField,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormNumberFieldPreview(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'HostFormNumberField',
      catalogId: 'host.form_number',
      children: [
        for (final decimal in [false, true])
          WidgetbookContentFrame(
            child: HostFormNumberField(
              fieldKey: decimal ? 'min-number' : 'min-length',
              questionId: 'preview',
              title: decimal ? 'Minimum number' : 'Minimum length',
              value: decimal ? 1.5 : 10,
              decimal: decimal,
              onChanged: (_) {},
            ),
          ),
      ],
    );

@widgetbook.UseCase(
  name: 'Date rule and optional error copy',
  type: HostFormValidationTextField,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormValidationTextFieldPreview(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'HostFormValidationTextField',
      catalogId: 'host.form_validation_text',
      children: [
        for (final value in ['2026-10-01', null])
          WidgetbookContentFrame(
            child: HostFormValidationTextField(
              fieldKey: value == null ? 'custom-error' : 'earliest-date',
              questionId: 'preview',
              title: value == null ? 'Custom error' : 'Earliest date',
              value: value,
              onChanged: (_) {},
            ),
          ),
      ],
    );

Widget _editorPreview({
  required String title,
  required String catalogId,
  required List<Widget> Function(HostFormEditorState, HostFormEditorController)
  children,
  HostFormQuestionKind? firstQuestionKind,
}) => WidgetbookFixtureScope(
  overrides: [
    hostFormsRepositoryProvider.overrideWithValue(
      _PreviewFormRepository(firstQuestionKind: firstQuestionKind),
    ),
  ],
  child: Consumer(
    builder: (context, ref, _) {
      final provider = hostFormEditorControllerProvider('org_1', 'form_1');
      final state = ref.watch(provider).asData?.value;
      return WidgetbookScrollCatalogFrame(
        title: title,
        catalogId: catalogId,
        children: state == null
            ? []
            : children(state, ref.read(provider.notifier)),
      );
    },
  ),
);

// Keep real controller edits, undo and autosave inside this in-memory fixture.
// Unsupported operations fail here instead of reaching a backend.
class _PreviewFormRepository implements HostFormsRepository {
  _PreviewFormRepository({HostFormQuestionKind? firstQuestionKind}) {
    if (firstQuestionKind != null) {
      final definition = _editor.definition;
      final section = definition.sections.first;
      _editor = _editor.copyWith(
        definition: definition.replaceSection(
          0,
          section.replaceQuestion(
            0,
            section.questions.first.copyWith(kind: firstQuestionKind),
          ),
        ),
      );
    }
  }

  HostFormEditor _editor = hostFormPreviewState.editor;

  @override
  Future<HostFormEditor> getEditor({
    required String organizerId,
    required String formId,
  }) async => _editor;

  @override
  Future<HostFormEditor> updateDraft({
    required String organizerId,
    required String formId,
    required int expectedRevision,
    required HostFormDefinition definition,
  }) async {
    _editor = _editor.copyWith(definition: definition);
    return _editor;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw StateError(
    'Unsupported form preview operation: ${invocation.memberName}',
  );
}
