import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:catch_dating_app/design_fixtures/dashboard_surface_fixtures.dart';
import 'package:catch_dating_app/events/domain/event_arrival_action.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';

final _eventFocusActions = EventFocusActions(
  onViewEvent: (_) => widgetbookNoop(),
  onCheckIn: (_) => widgetbookNoop(),
  onOpenSwipe: (_) => widgetbookNoop(),
  onWriteReview: (_) => widgetbookNoop(),
  onOpenDirections: (_) => widgetbookNoop(),
  onAddToCalendar: (_) => widgetbookNoop(),
  onResetCheckInError: widgetbookNoop,
);

@widgetbook.UseCase(
  name: 'Rail states',
  type: EventFocusRail,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEventFocusRailReviewStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'EventFocusRail',
    contractId: 'dashboard.home.event_focus_rail',
    children: [
      WidgetbookPageStateCard(
        label: 'upcoming event',
        child: WidgetbookDashboardPrimitiveFrame(
          child: EventFocusRail(
            upcomingEvents: [widgetbookDashboardNextEvent],
            actions: _eventFocusActions,
            clubNameBuilder: (_) => widgetbookDashboardClub.name,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'check-in pending',
        child: WidgetbookDashboardPrimitiveFrame(
          child: EventFocusRail(
            upcomingEvents: [widgetbookDashboardNextEvent],
            arrivalAction: EventArrivalAction(
              kind: EventArrivalActionKind.selfCheckIn,
              event: widgetbookDashboardNextEvent,
            ),
            checkInState: const EventFocusCheckInState(isPending: true),
            actions: _eventFocusActions,
            clubNameBuilder: (_) => widgetbookDashboardClub.name,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Card states',
  type: EventFocusCard,
  path: '[P1 product surfaces]/Dashboard home',
)
Widget dashboardEventFocusCardReviewStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'EventFocusCard',
    contractId: 'dashboard.home.event_focus_card',
    children: [
      WidgetbookPageStateCard(
        label: 'upcoming',
        child: WidgetbookDashboardPrimitiveFrame(
          child: EventFocusCard(
            item: EventFocusItem(
              event: widgetbookDashboardNextEvent,
              kind: EventFocusKind.upcoming,
              clubName: widgetbookDashboardClub.name,
            ),
            cardIndex: 0,
            cardCount: 3,
            checkInState: EventFocusCheckInState.idle,
            onActionPressed: (_) {},
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'check-in pending',
        child: WidgetbookDashboardPrimitiveFrame(
          child: EventFocusCard(
            item: EventFocusItem(
              event: widgetbookDashboardNextEvent,
              kind: EventFocusKind.checkIn,
              clubName: widgetbookDashboardClub.name,
            ),
            cardIndex: 1,
            cardCount: 3,
            checkInState: const EventFocusCheckInState(isPending: true),
            onActionPressed: (_) {},
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'after event actions',
        child: WidgetbookDashboardPrimitiveFrame(
          child: EventFocusCard(
            item: EventFocusItem(
              event: DashboardSurfaceFixtures.attendedEvent,
              kind: EventFocusKind.afterEvent,
              clubName: widgetbookDashboardClub.name,
              canSwipe: true,
              needsReview: true,
            ),
            cardIndex: 2,
            cardCount: 3,
            checkInState: EventFocusCheckInState.idle,
            onActionPressed: (_) {},
          ),
        ),
      ),
    ],
  );
}
