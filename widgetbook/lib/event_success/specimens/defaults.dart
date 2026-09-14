import 'package:catch_dating_app/event_success/presentation/event_success_defaults_panel.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'preview.dart';

@widgetbook.UseCase(
  name: "EventSuccessDefaultsPanel",
  type: EventSuccessDefaultsPanel,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Defaults panel folded states",
)
Widget eventSuccessStrictEventSuccessDefaultsPanel(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.defaults,
    componentName: "EventSuccessDefaultsPanel",
  );
}
