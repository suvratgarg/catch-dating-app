import 'package:catch_dating_app/event_success/presentation/event_success_structure_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'preview.dart';

@widgetbook.UseCase(
  name: "EventSuccessStructureConfigEditor",
  type: EventSuccessStructureConfigEditor,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Structure editor folded states",
)
Widget eventSuccessStrictEventSuccessStructureConfigEditor(
  BuildContext context,
) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.structure,
    componentName: "EventSuccessStructureConfigEditor",
  );
}
