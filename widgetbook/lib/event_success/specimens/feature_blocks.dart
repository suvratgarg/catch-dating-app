import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'preview.dart';

@widgetbook.UseCase(
  name: "ConversationCueRow",
  type: ConversationCueRow,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Feature block folded states",
)
Widget eventSuccessStrictConversationCueRow(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.featureBlocks,
    componentName: "ConversationCueRow",
  );
}

@widgetbook.UseCase(
  name: "EventSuccessConversationCueCard",
  type: EventSuccessConversationCueCard,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Feature block folded states",
)
Widget eventSuccessStrictEventSuccessConversationCueCard(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.featureBlocks,
    componentName: "EventSuccessConversationCueCard",
  );
}

@widgetbook.UseCase(
  name: "EventSuccessPostEventReport",
  type: EventSuccessPostEventReport,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Feature block folded states",
)
Widget eventSuccessStrictEventSuccessPostEventReport(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.featureBlocks,
    componentName: "EventSuccessPostEventReport",
  );
}

@widgetbook.UseCase(
  name: "EventSuccessRecommendationTile",
  type: EventSuccessRecommendationTile,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Feature block folded states",
)
Widget eventSuccessStrictEventSuccessRecommendationTile(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.featureBlocks,
    componentName: "EventSuccessRecommendationTile",
  );
}
