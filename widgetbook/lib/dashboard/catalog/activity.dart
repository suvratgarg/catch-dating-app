import 'package:catch_dating_app/dashboard/presentation/notifications_list_state.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/design_fixtures/dashboard_surface_fixtures.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Signed-out state',
  type: ActivitySignedOutState,
  path: '[P1 product surfaces]/Dashboard activity',
)
Widget dashboardActivitySignedOutStateReview(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'ActivitySignedOutState',
    contractId: 'dashboard.activity.signed_out',
    children: [
      WidgetbookPageStateCard(
        label: 'signed out',
        child: WidgetbookDashboardPrimitiveFrame(
          child: ActivitySignedOutState(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Grouped rows',
  type: NotificationDayGroups,
  path: '[P1 product surfaces]/Dashboard activity',
)
Widget dashboardNotificationDayGroupsReview(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'NotificationDayGroups',
    contractId: 'dashboard.activity.day_groups',
    children: [
      WidgetbookPageStateCard(
        label: 'today and earlier',
        child: WidgetbookDashboardPrimitiveFrame(
          child: NotificationDayGroups(groups: _notificationDayGroups()),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Row states',
  type: NotificationRow,
  path: '[P1 product surfaces]/Dashboard activity',
)
Widget dashboardNotificationRowReviewStates(BuildContext context) {
  final rows = _notificationDayGroups().first.rows;
  return WidgetbookPageCatalogFrame(
    title: 'NotificationRow',
    contractId: 'dashboard.activity.notification_row',
    children: [
      WidgetbookPageStateCard(
        label: 'mixed read state',
        child: WidgetbookDashboardPrimitiveFrame(
          child: Column(
            children: [
              for (final row in rows)
                NotificationRow(
                  type: row.type,
                  title: row.title,
                  time: row.timeLabel,
                  body: row.subtitle,
                  unread: row.isUnread,
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Skeleton states',
  type: ActivitySectionSkeleton,
  path: '[P1 product surfaces]/Dashboard activity',
)
Widget dashboardActivitySectionSkeletonReview(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'ActivitySectionSkeleton',
    contractId: 'dashboard.activity.skeleton',
    children: [
      WidgetbookPageStateCard(
        label: 'compact loading',
        child: WidgetbookDashboardPrimitiveFrame(
          child: ActivitySectionSkeleton(count: 2),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'full loading',
        child: WidgetbookDashboardPrimitiveFrame(
          child: ActivitySectionSkeleton(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Row skeleton states',
  type: NotificationRowSkeleton,
  path: '[P1 product surfaces]/Dashboard activity',
)
Widget dashboardNotificationRowSkeletonReview(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'NotificationRowSkeleton',
    contractId: 'dashboard.activity.notification_row_skeleton',
    children: [
      WidgetbookPageStateCard(
        label: 'first row',
        child: WidgetbookDashboardPrimitiveFrame(
          child: NotificationRowSkeleton(divider: false),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'divided row',
        child: WidgetbookDashboardPrimitiveFrame(
          child: NotificationRowSkeleton(divider: true),
        ),
      ),
    ],
  );
}

List<NotificationDayGroup> _notificationDayGroups() {
  return [
    NotificationDayGroup(
      label: 'Today',
      rows: [
        NotificationRowDisplay(
          type: ActivityNotificationType.eventReminder,
          title: 'Event starts tomorrow',
          subtitle: 'Sea Face Social meets at Carter Road Jetty.',
          createdAt: DashboardSurfaceFixtures.now,
          timeLabel: '2h',
          isUnread: true,
        ),
        NotificationRowDisplay(
          type: ActivityNotificationType.match,
          title: "It's a catch",
          subtitle: 'You and Riya matched after Sunday socials.',
          createdAt: DashboardSurfaceFixtures.now.subtract(
            const Duration(hours: 6),
          ),
          timeLabel: '6h',
          isUnread: false,
        ),
      ],
    ),
    NotificationDayGroup(
      label: 'Earlier',
      rows: [
        NotificationRowDisplay(
          type: ActivityNotificationType.clubUpdate,
          title: 'New club update',
          subtitle: 'Sea Face Social added a monsoon breakfast run.',
          createdAt: DashboardSurfaceFixtures.now.subtract(
            const Duration(days: 1),
          ),
          timeLabel: '1d',
          isUnread: false,
        ),
      ],
    ),
  ];
}
