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

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// keepalive: GoRouter is the app-wide navigation graph and owns route refresh
// listeners for auth/update state.
@Riverpod(keepAlive: true)
GoRouter consumerGoRouter(Ref ref) => _buildGoRouter(ref, isHostApp: false);

// keepalive: Host navigation is the app-wide route graph for the Host root.
@Riverpod(keepAlive: true)
GoRouter hostGoRouter(Ref ref) => _buildGoRouter(ref, isHostApp: true);

const _fromQueryParam = 'from';
const _onboardingIntentQueryParam = 'intent';
const _completeProfileIntent = 'complete-profile';
const _completeRunPreferencesIntent = 'complete-run-preferences';
const _initialRouteOverride = String.fromEnvironment('CATCH_INITIAL_ROUTE');
