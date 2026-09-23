part of 'go_router.dart';

HostResponseReviewQueue? _responseReviewQueue(Object? extra) =>
    extra is HostResponseReviewQueue ? extra : null;

EventDetailScreen _eventDetailScreen(GoRouterState state) {
  return EventDetailScreen(
    clubId: state.pathParameters['clubId']!,
    eventId: state.pathParameters['eventId']!,
    inviteCode: state.uri.queryParameters['invite'],
    inviteLinkId:
        state.uri.queryParameters['il'] ??
        state.uri.queryParameters['inviteLinkId'],
    initialEvent: _eventDetailInitialEvent(state),
    presentationMode: _eventDetailPresentationMode(state),
    heroTag: _eventDetailHeroTag(state),
    attribution: _eventDetailAttribution(state),
  );
}

ClubDetailScreen _clubDetailScreen(GoRouterState state) {
  return ClubDetailScreen(
    clubId: state.pathParameters['clubId']!,
    initialClub: _clubDetailInitialClub(state),
  );
}
