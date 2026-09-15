import 'package:catch_dating_app/hosts/data/host_forms_repository.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_definition.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_editor.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_availability_field.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_settings_section_list.dart';
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
    WidgetbookFixtureScope(
      overrides: [
        hostFormsRepositoryProvider.overrideWithValue(_PreviewFormRepository()),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final provider = hostFormEditorControllerProvider('org_1', 'form_1');
          final state = ref.watch(provider).asData?.value;
          return WidgetbookScrollCatalogFrame(
            title: 'HostFormSettingsSectionList',
            catalogId: 'host.form_settings',
            children: [
              if (state != null)
                WidgetbookContentFrame(
                  child: HostFormSettingsSectionList(
                    definition: state.editor.definition,
                    notifier: ref.read(provider.notifier),
                  ),
                ),
            ],
          );
        },
      ),
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

// Keep real controller edits, undo and autosave inside this in-memory fixture.
// Unsupported operations fail here instead of reaching a backend.
class _PreviewFormRepository implements HostFormsRepository {
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
