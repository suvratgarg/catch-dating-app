import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Header content',
  type: CatchScreenHeader,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardHeaderContentReview(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'CatchScreenHeader',
    contractId: 'dashboard.home.header_content',
    children: [
      WidgetbookPageStateCard(
        label: 'copy only',
        child: const WidgetbookDashboardPrimitiveFrame(
          child: CatchScreenHeader.block(
            title: 'Good evening, Subrath',
            actions: [],
            padding: CatchInsets.screenTitleBlockCompact,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'notification action',
        child: WidgetbookDashboardPrimitiveFrame(
          child: CatchScreenHeader.block(
            title: 'Three plans ready',
            padding: CatchInsets.screenTitleBlockCompact,
            actions: [
              CatchIconAction.counted(
                icon: CatchIcons.notificationsRounded,
                count: 3,
                size: CatchIconAction.navSize,
                tooltip: 'Notifications',
                onPressed: widgetbookNoop,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Counted notification action',
  type: CatchIconAction,
  path: '[P1 product surfaces]/Dashboard primitives',
)
Widget dashboardCountedNotificationActionReviewStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'CatchIconAction.counted',
    contractId: 'catch.icon_button',
    children: [
      WidgetbookPageStateCard(
        label: 'no unread',
        child: WidgetbookDashboardPrimitiveFrame(
          child: CatchIconAction.counted(
            icon: CatchIcons.notificationsNoneRounded,
            count: 0,
            size: CatchIconAction.navSize,
            tooltip: 'Notifications',
            onPressed: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'unread count',
        child: WidgetbookDashboardPrimitiveFrame(
          child: CatchIconAction.counted(
            icon: CatchIcons.notificationsRounded,
            count: 3,
            size: CatchIconAction.navSize,
            tooltip: 'Notifications',
            onPressed: widgetbookNoop,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'overflow badge',
        child: WidgetbookDashboardPrimitiveFrame(
          child: CatchIconAction.counted(
            icon: CatchIcons.notificationsRounded,
            count: 124,
            size: CatchIconAction.navSize,
            tooltip: 'Notifications',
            onPressed: widgetbookNoop,
          ),
        ),
      ),
    ],
  );
}
