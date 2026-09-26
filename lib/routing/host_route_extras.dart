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

/// Compatibility provider for test harnesses that intentionally exercise both
/// role graphs in one Dart process. Installable app roots use one of the two
/// compile-time role providers above.
// keepalive: compatibility tests need one stable role-selected router graph.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  return _buildGoRouter(ref, isHostApp: AppConfig.appRole.isHost);
}

OrganizerMomentScope _eventMomentScope(GoRouterState state) =>
    OrganizerMomentScope.event(state.pathParameters['eventId']!);
