part of 'go_router.dart';

/// One route index recipe shared by the visible workspace and its navigator.
/// The navigator anchor retains routing state without mounting a second index.
class HostWorkspaceIndexScreen extends StatelessWidget {
  const HostWorkspaceIndexScreen({
    super.key,
    required this.root,
    required this.uri,
    this.initialEvent,
    this.initialProgramAnchor,
    this.initialContactDisplayName,
    this.initialOrganizerId,
  });
  final Routes root;
  factory HostWorkspaceIndexScreen.route({
    Key? key,
    required Routes root,
    required GoRouterState state,
  }) => HostWorkspaceIndexScreen(
    key: key,
    root: root,
    uri: _hostWorkspaceUri(root, state),
    initialEvent: _routeEventExtra(state),
    initialProgramAnchor: state.extra is OrganizerProgramListAnchor
        ? state.extra as OrganizerProgramListAnchor
        : null,
    initialContactDisplayName: _routeContactNameExtra(state),
    initialOrganizerId: _routeClubIdExtra(state),
  );

  final Uri uri;
  final Event? initialEvent;
  final OrganizerProgramListAnchor? initialProgramAnchor;
  final String? initialContactDisplayName;
  final String? initialOrganizerId;

  @override
  Widget build(BuildContext context) {
    if (HostWorkspaceRouteScope.isNavigatorRoot(context)) {
      return const SizedBox.shrink();
    }
    return switch (root) {
      Routes.hostTodayScreen => HostNavigationWorkspace.event(
        uri: uri,
        initialEvent: initialEvent,
        index: HostTodayScreen(
          initialOrganizerId: uri.queryParameters['organizerId'],
        ),
      ),
      Routes.hostEventsScreen => HostNavigationWorkspace.event(
        uri: uri,
        initialEvent: initialEvent,
        index: HostEventsScreen(
          initialOrganizerId: uri.queryParameters['organizerId'],
          initialProgramId: uri.queryParameters['programId'],
          initialProgramAnchor: initialProgramAnchor,
        ),
      ),
      Routes.hostAudienceScreen => switch (hostAudienceViewFromName(
        uri.queryParameters['view'],
      )) {
        HostAudienceView.forms ||
        HostAudienceView.responses => HostNavigationWorkspace(
          uri: uri,
          index: hostAudienceScreenForUri(uri),
        ),
        _ => hostAudienceScreenForUri(
          uri,
          initialContactDisplayName: initialContactDisplayName,
        ),
      },
      Routes.hostInboxScreen => hostInboxScreenForUri(
        uri,
        initialOrganizerId: initialOrganizerId,
      ),
      _ => hostOrganizerScreenForUri(uri),
    };
  }
}
