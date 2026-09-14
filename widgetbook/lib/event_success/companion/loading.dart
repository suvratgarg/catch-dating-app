import 'package:catch_dating_app/event_success/presentation/event_success_companion_screen.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Loading body',
  type: EventSuccessCompanionLoadingBody,
  path: '[P1 product surfaces]/Event Success companion',
)
Widget eventSuccessCompanionLoadingBodyState(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'EventSuccessCompanionLoadingBody',
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
                body: const EventSuccessCompanionLoadingBody(),
              );
            },
          ),
        ),
      ),
    ],
  );
}
