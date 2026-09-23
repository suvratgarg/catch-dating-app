import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'preview.dart';

@widgetbook.UseCase(
  name: "EventSuccessHostSection",
  type: EventSuccessHostSection,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Host folded states",
)
Widget eventSuccessStrictEventSuccessHostSection(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.host,
    componentName: "EventSuccessHostSection",
  );
}
