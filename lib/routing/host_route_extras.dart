part of 'go_router.dart';

/// Shared `state.extra` casts for routes that accept typed payloads for
/// initial screen state.
Event? _routeEventExtra(GoRouterState state) => switch (state.extra) {
  final Event event => event,
  _ => null,
};

String? _routeClubIdExtra(GoRouterState state) => switch (state.extra) {
  final Club club => club.id,
  _ => null,
};

HostSavedAudience? _routeAudienceExtra(GoRouterState state) =>
    switch (state.extra) {
      final HostSavedAudience audience => audience,
      _ => null,
    };

OrganizerMomentScope _eventMomentScope(GoRouterState state) =>
    OrganizerMomentScope.event(state.pathParameters['eventId']!);
