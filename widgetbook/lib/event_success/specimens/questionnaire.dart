import 'package:catch_dating_app/event_success/presentation/event_success_questionnaire_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'preview.dart';

@widgetbook.UseCase(
  name: "CustomQuestionnaireFields",
  type: CustomQuestionnaireFields,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Questionnaire editor folded states",
)
Widget eventSuccessStrictCustomQuestionnaireFields(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.questionnaire,
    componentName: "CustomQuestionnaireFields",
  );
}

@widgetbook.UseCase(
  name: "EventSuccessQuestionnaireConfigEditor",
  type: EventSuccessQuestionnaireConfigEditor,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Questionnaire editor folded states",
)
Widget eventSuccessStrictEventSuccessQuestionnaireConfigEditor(
  BuildContext context,
) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.questionnaire,
    componentName: "EventSuccessQuestionnaireConfigEditor",
  );
}
