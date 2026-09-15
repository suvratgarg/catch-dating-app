import 'package:catch_dating_app/event_success/presentation/companion/event_success_companion_loading_page_body.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Loading body',
  type: EventSuccessCompanionLoadingPageBody,
  path: '[P1 product surfaces]/Event Success companion',
)
Widget eventSuccessCompanionLoadingBodyState(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'EventSuccessCompanionLoadingPageBody',
    contractId: 'state.event_success.companion.loading',
    children: [
      WidgetbookPageStateCard(
        label: 'route skeleton',
        child: WidgetbookCompanionDeviceFrame(
          child: Builder(
            builder: (context) {
              final t = CatchTokens.of(context);
              return Scaffold(
                backgroundColor: t.bg,
                body: const EventSuccessCompanionLoadingPageBody(),
              );
            },
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Stage loading',
  type: EventSuccessCompanionStageSkeleton,
  path: '[P1 product surfaces]/Event Success companion',
)
Widget eventSuccessCompanionStageSkeletonState(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'EventSuccessCompanionStageSkeleton',
    contractId: 'state.event_success.companion.loading',
    children: [
      WidgetbookPageStateCard(
        label: 'moment stage',
        child: EventSuccessCompanionStageSkeleton(),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Primary action loading',
  type: EventSuccessCompanionPrimaryActionSkeleton,
  path: '[P1 product surfaces]/Event Success companion',
)
Widget eventSuccessCompanionPrimaryActionSkeletonState(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'EventSuccessCompanionPrimaryActionSkeleton',
    contractId: 'state.event_success.companion.loading',
    children: [
      WidgetbookPageStateCard(
        label: 'primary action',
        child: EventSuccessCompanionPrimaryActionSkeleton(),
      ),
    ],
  );
}
