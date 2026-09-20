part of 'go_router.dart';

Event? _eventDetailInitialEvent(GoRouterState state) {
  return switch (state.extra) {
    EventDetailRouteExtra(:final initialEvent) => initialEvent,
    final Event event => event,
    _ => null,
  };
}

EventDetailRouteTransition _eventDetailTransition(GoRouterState state) {
  return switch (state.extra) {
    EventDetailRouteExtra(:final transition) => transition,
    _ => EventDetailRouteTransition.platform,
  };
}

EventDetailPresentationMode _eventDetailPresentationMode(GoRouterState state) {
  return switch (state.extra) {
    EventDetailRouteExtra(:final presentationMode) => presentationMode,
    _ => EventDetailPresentationMode.standard,
  };
}

Object? _eventDetailHeroTag(GoRouterState state) {
  return switch (state.extra) {
    EventDetailRouteExtra(:final heroTag) => heroTag,
    _ => null,
  };
}

EventDetailAttribution? _eventDetailAttribution(GoRouterState state) {
  return switch (state.extra) {
    EventDetailRouteExtra(:final attribution) => attribution,
    _ => null,
  };
}

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

Club? _clubDetailInitialClub(GoRouterState state) {
  return switch (state.extra) {
    final Club club => club,
    _ => null,
  };
}

ClubDetailScreen _clubDetailScreen(GoRouterState state) {
  return ClubDetailScreen(
    clubId: state.pathParameters['clubId']!,
    initialClub: _clubDetailInitialClub(state),
  );
}

Page<void> _clubDetailPage(BuildContext _, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: _clubDetailScreen(state),
    transitionDuration: CatchMotion.calendarScroll,
    reverseTransitionDuration: CatchMotion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        CatchRevealViewport(animation: animation, child: child),
  );
}

Page<void> _exploreMapPage(BuildContext _, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: const ExploreMapScreen(),
    transitionDuration: CatchMotion.slow,
    reverseTransitionDuration: CatchMotion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return CatchRevealViewport.stationary(animation: animation, child: child);
    },
  );
}

Page<void> _eventDetailPage(BuildContext _, GoRouterState state) {
  final child = _eventDetailScreen(state);
  if (_eventDetailTransition(state) == EventDetailRouteTransition.platform) {
    return MaterialPage<void>(
      key: state.pageKey,
      name: state.name,
      child: child,
    );
  }

  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration: CatchMotion.slow,
    reverseTransitionDuration: CatchMotion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        CatchRevealViewport(animation: animation, child: child),
  );
}
