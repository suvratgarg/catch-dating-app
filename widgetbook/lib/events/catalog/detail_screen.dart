import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_hype_avatar_stack.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import '../../support/widgetbook_harness.dart';
import 'event_scope.dart';
import 'fixtures.dart';
import 'preview.dart';

final _hostViewer = widgetbookEventsViewer.copyWith(
  uid: 'host-mira',
  name: 'Mira Shah',
  displayName: 'Mira Shah',
  firstName: 'Mira',
  lastName: 'Shah',
);

@widgetbook.UseCase(
  name: 'Screen states',
  type: EventDetailScreen,
  path: '[Event Detail]/Screen states',
)
Widget eventDetailScreenStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'EventDetailScreen',
    catalogId: 'screen.event.detail',
    children: [
      WidgetbookPageStateCard(
        label: 'loading',
        child: _RouteFrame(
          value: const AsyncLoading<EventDetailViewModel?>(),
          child: EventDetailScreen(
            clubId: widgetbookEventsClubId,
            eventId: widgetbookEvent.id,
            enableMapNetworkTiles: false,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'not found',
        child: _RouteFrame(
          value: const AsyncData<EventDetailViewModel?>(null),
          child: EventDetailScreen(
            clubId: widgetbookEventsClubId,
            eventId: widgetbookEvent.id,
            enableMapNetworkTiles: false,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'fatal error',
        child: _RouteFrame(
          value: AsyncError<EventDetailViewModel?>(
            StateError('Widgetbook event detail load failed'),
            StackTrace.empty,
          ),
          child: EventDetailScreen(
            clubId: widgetbookEventsClubId,
            eventId: widgetbookEvent.id,
            enableMapNetworkTiles: false,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'member default',
        child: _RouteFrame(
          value: AsyncData(
            _eventVm(widgetbookEvent, participation: widgetbookEventsSignedUp),
          ),
          child: EventDetailScreen(
            clubId: widgetbookEventsClubId,
            eventId: widgetbookEvent.id,
            enableMapNetworkTiles: false,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'guest',
        child: _RouteFrame(
          value: AsyncData(
            _eventVm(widgetbookEvent, isAuthenticated: false, isSaved: false),
          ),
          child: EventDetailScreen(
            clubId: widgetbookEventsClubId,
            eventId: widgetbookEvent.id,
            enableMapNetworkTiles: false,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'host app',
        child: _RouteFrame(
          value: AsyncData(
            _eventVm(widgetbookEvent, userProfile: _hostViewer, isHost: true),
          ),
          child: EventDetailScreen(
            clubId: widgetbookEventsClubId,
            eventId: widgetbookEvent.id,
            enableMapNetworkTiles: false,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'offline error',
        child: _RouteFrame(
          value: AsyncError<EventDetailViewModel?>(
            StateError('No network connection for Event Detail'),
            StackTrace.empty,
          ),
          child: EventDetailScreen(
            clubId: widgetbookEventsClubId,
            eventId: widgetbookEvent.id,
            enableMapNetworkTiles: false,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'ticket presentation',
        child: _RouteFrame(
          value: AsyncData(
            _eventVm(widgetbookEvent, participation: widgetbookEventsSignedUp),
          ),
          child: EventDetailScreen(
            clubId: widgetbookEventsClubId,
            eventId: widgetbookEvent.id,
            enableMapNetworkTiles: false,
            presentationMode: EventDetailPresentationMode.ticket,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'spotlight dark presentation',
        child: _RouteFrame(
          value: AsyncData(
            _eventVm(widgetbookEvent, participation: widgetbookEventsSignedUp),
          ),
          child: EventDetailScreen(
            clubId: widgetbookEventsClubId,
            eventId: widgetbookEvent.id,
            enableMapNetworkTiles: false,
            presentationMode: EventDetailPresentationMode.spotlightDark,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'text scale 2',
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: _RouteFrame(
            value: AsyncData(
              _eventVm(
                widgetbookEvent,
                participation: widgetbookEventsSignedUp,
              ),
            ),
            child: EventDetailScreen(
              clubId: widgetbookEventsClubId,
              eventId: widgetbookEvent.id,
              enableMapNetworkTiles: false,
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'reduced motion',
        child: TickerMode(
          enabled: false,
          child: _RouteFrame(
            value: AsyncData(
              _eventVm(
                widgetbookEvent,
                participation: widgetbookEventsSignedUp,
              ),
            ),
            child: EventDetailScreen(
              clubId: widgetbookEventsClubId,
              eventId: widgetbookEvent.id,
              enableMapNetworkTiles: false,
            ),
          ),
        ),
      ),
    ],
  );
}

class _RouteFrame extends StatelessWidget {
  const _RouteFrame({required this.value, required this.child});

  final AsyncValue<EventDetailViewModel?> value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final avatarQuery = EventHypeAvatarQuery(
      eventId: widgetbookEvent.id,
      limit: 7,
    );

    return WidgetbookEventDeviceFrame(
      child: WidgetbookFixtureScope(
        overrides: [
          eventDetailViewModelProvider(
            widgetbookEvent.id,
          ).overrideWithValue(value),
          fetchClubProvider(
            widgetbookEventsClubId,
          ).overrideWith((ref) => widgetbookEventsClub),
          watchEventParticipationRosterProvider(
            widgetbookEvent.id,
          ).overrideWith((ref) => Stream.value(widgetbookEventsRoster())),
          eventHypeAvatarsProvider(
            avatarQuery,
          ).overrideWith((ref) async => widgetbookEventsAvatarItems),
          watchEventSuccessPlanProvider(
            widgetbookEvent.id,
          ).overrideWith((ref) => Stream.value(null)),
          paymentRepositoryProvider.overrideWithValue(
            const WidgetbookEventFakePaymentRepository(),
          ),
        ],
        child: child,
      ),
    );
  }
}

EventDetailViewModel _eventVm(
  Event event, {
  UserProfile? userProfile,
  bool isAuthenticated = true,
  bool isHost = false,
  bool isSaved = true,
  EventParticipation? participation,
}) {
  return EventDetailViewModel(
    event: event,
    userProfile:
        userProfile ?? (isAuthenticated ? widgetbookEventsViewer : null),
    reviews: widgetbookEventsReviews,
    isAuthenticated: isAuthenticated,
    isHost: isHost,
    isSaved: isSaved,
    participation: participation,
  );
}
