// Corpus annotations name internal owners; all construction uses public APIs.
// catch_row_geometry_is_internal still forbids direct renderer construction.
// ignore_for_file: implementation_imports

import 'package:catch_ui/catch_ui.dart';
// Internal types identify the rendered owner for corpus coverage. Public
// Section and Field APIs construct every specimen below.
import 'package:catch_ui/src/components/catch_content_section.dart';
import 'package:catch_ui/src/components/catch_field_activity_notification.dart';
import 'package:catch_ui/src/components/catch_row_section.dart';
import 'package:catch_ui/src/patterns/catch_row_viewport.dart';
import 'package:catch_ui/src/primitives/catch_row_press_surface.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/contract_preview.dart';

Widget _fieldGroup(BuildContext context) => WidgetbookContractFrame(
  title: 'Section owns the perimeter; Field owns interaction',
  contractId: 'catch.section',
  states: const ['resting', 'hovered', 'disabled', 'contained'],
  children: [
    CatchSection.containedRows(
      title: 'People',
      children: [
        CatchField.navigate(
          content: const CatchPersonLayout(
            name: 'Riya',
            supportingText: '2 events',
          ),
          onActivate: () {},
          states: const {WidgetState.hovered},
        ),
        CatchField.navigate(
          content: const CatchPersonLayout(
            name: 'Manan',
            supportingText: 'New',
          ),
          onActivate: () {},
          states: const {WidgetState.disabled},
        ),
        const CatchField.read(content: CatchPersonLayout(name: 'Suvrat')),
      ],
    ),
  ],
);

@widgetbook.UseCase(
  name: 'Typed row boundaries',
  type: CatchRowSection,
  path: '[Core primitives]/Layout',
)
Widget catchRowSectionContract(BuildContext context) => _fieldGroup(context);

@widgetbook.UseCase(
  name: 'Field active handoff',
  type: CatchFieldActivityNotification,
  path: '[Core primitives]/Inputs',
)
Widget catchFieldActivityContract(BuildContext context) => _fieldGroup(context);

@widgetbook.UseCase(
  name: 'Field-owned press states',
  type: CatchRowPressSurface,
  path: '[Core primitives]/Inputs',
)
Widget catchInternalRowPressContract(BuildContext context) =>
    _fieldGroup(context);

@widgetbook.UseCase(
  name: 'Pane interaction width',
  type: CatchRowViewport,
  path: '[Core primitives]/Layout',
)
Widget catchRowViewportContract(BuildContext context) =>
    CatchSectionList.panes(body: _fieldGroup(context));

@widgetbook.UseCase(
  name: 'Published pane width',
  type: CatchRowViewportScope,
  path: '[Core primitives]/Layout',
)
Widget catchRowViewportScopeContract(BuildContext context) =>
    CatchSectionList.panes(body: _fieldGroup(context));

@widgetbook.UseCase(
  name: 'Content-width rule',
  type: CatchContentSectionHeader,
  path: '[Core primitives]/Layout',
)
Widget catchSectionHeaderContract(BuildContext context) =>
    catchContentSectionContract(context);

@widgetbook.UseCase(
  name: 'Non-row section header',
  type: CatchContentSection,
  path: '[Core primitives]/Layout',
)
Widget catchContentSectionContract(BuildContext context) =>
    WidgetbookContractFrame(
      title: 'Content uses the same header rule',
      contractId: 'catch.section',
      states: const ['titled'],
      children: [
        CatchSection.content(
          title: 'Media',
          child: const Text('Photos and supporting content'),
        ),
      ],
    );
