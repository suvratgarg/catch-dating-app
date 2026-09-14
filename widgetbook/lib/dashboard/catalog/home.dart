import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_screen.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_empty.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_full.dart';
import 'package:catch_dating_app/design_fixtures/dashboard_surface_fixtures.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';
import 'scope.dart';

@widgetbook.UseCase(
  name: 'Empty home sliver',
  type: DashboardEmptySliverBody,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEmptySliverBodyReview(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'DashboardEmptySliverBody',
    contractId: 'dashboard.home.empty_sliver',
    children: [
      WidgetbookPageStateCard(
        label: 'first event education',
        child: WidgetbookDashboardDeviceFrame(
          child: CustomScrollView(slivers: [DashboardEmptySliverBody()]),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Full home',
  type: DashboardHomeScreen,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardFullReview(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'DashboardHomeScreen',
    contractId: 'dashboard.home.full',
    children: [
      WidgetbookPageStateCard(
        label: 'booked event with recommendations',
        child: WidgetbookDashboardDeviceFrame(
          child: WidgetbookDashboardScope(
            child: DashboardHomeScreen(
              header: DashboardHomeHeaderModel.full(
                user: widgetbookDashboardViewer,
                now: DashboardSurfaceFixtures.now,
              ),
              dashboardSliver: DashboardFullSliverBody(
                viewModel: _dashboardFullViewModel(),
                user: widgetbookDashboardViewer,
              ),
              actions: [
                CatchIconAction.counted(
                  icon: CatchIcons.notificationsRounded,
                  count: widgetbookDashboardNotifications
                      .where((notification) => notification.isUnread)
                      .length,
                  size: CatchIconAction.navSize,
                  tooltip: 'Notifications',
                  onPressed: widgetbookNoop,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Full sliver body',
  type: DashboardFullSliverBody,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardFullSliverBodyReview(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'DashboardFullSliverBody',
    contractId: 'dashboard.home.full_sliver_body',
    children: [
      WidgetbookPageStateCard(
        label: 'body content',
        child: WidgetbookDashboardDeviceFrame(
          child: WidgetbookDashboardScope(
            child: CustomScrollView(
              slivers: [
                CatchPageBody.slivers(
                  mode: CatchPageBodyMode.standard,
                  children: [
                    DashboardFullSliverBody(
                      viewModel: _dashboardFullViewModel(),
                      user: widgetbookDashboardViewer,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

DashboardFullViewModel _dashboardFullViewModel() {
  return DashboardFullViewModel(
    upcomingEvents: [widgetbookDashboardNextEvent],
    nextEvent: widgetbookDashboardNextEvent,
    arrivalAction: null,
    activeSwipeEvent: null,
    pendingReviewEvent: null,
    attendedEventsSection: DashboardSectionModel.data([
      DashboardSurfaceFixtures.attendedEvent,
    ]),
  );
}
