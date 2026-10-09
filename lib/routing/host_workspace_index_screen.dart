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
      Routes.hostTodayScreen => HostNavigationWorkspace(
        spec: _eventWorkspace(
          context,
          index: HostTodayScreen(
            initialOrganizerId: uri.queryParameters['organizerId'],
          ),
        ),
      ),
      Routes.hostEventsScreen => HostNavigationWorkspace(
        spec: _eventWorkspace(
          context,
          index: HostEventsScreen(
            initialOrganizerId: uri.queryParameters['organizerId'],
            initialProgramId: uri.queryParameters['programId'],
            initialProgramAnchor: initialProgramAnchor,
          ),
        ),
      ),
      Routes.hostAudienceScreen => switch (hostAudienceViewFromName(
        uri.queryParameters['view'],
      )) {
        HostAudienceView.forms ||
        HostAudienceView.responses => HostNavigationWorkspace(
          spec: HostDirectoryWorkspace<String>(
            index: hostAudienceScreenForUri(uri),
            selection: null,
            detailBuilder: (_) => const SizedBox.shrink(),
            unselected: CatchEmptyState(
              icon: CatchIcons.chevronRightRounded,
              title: context.l10n.coreCatchFieldVisiblecopySelect,
            ),
          ),
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
      Routes.hostOrganizerScreen => hostOrganizerScreenForUri(uri),
      _ => throw StateError('Not a Host workspace root: $root'),
    };
  }

  HostDirectoryWorkspace<({String organizerId, String eventId})>
  _eventWorkspace(BuildContext context, {required Widget index}) {
    final organizerId = uri.queryParameters['organizerId'];
    final eventId = uri.queryParameters['eventId'];
    return HostDirectoryWorkspace(
      index: index,
      selection: organizerId == null || eventId == null
          ? null
          : (organizerId: organizerId, eventId: eventId),
      unselected: CatchEmptyState(
        icon: CatchIcons.chevronRightRounded,
        title: context.l10n.coreCatchFieldVisiblecopySelect,
      ),
      onBack: () => context.go(hostWorkspaceIndexUri(uri).toString()),
      recordId: (_) => Routes.hostAppEventManageScreen.name,
      detailBuilder: (selection) => HostWorkspaceRouteContent(
        id: hostWorkspaceContentId(
          Routes.hostAppEventManageScreen.name,
          Routes.hostAppEventManageScreen.path,
          {'clubId': selection.organizerId, 'eventId': selection.eventId},
        ),
        builder: (context) => HostEventManageRouteScreen(
          key: ValueKey('${selection.organizerId}/${selection.eventId}'),
          clubId: selection.organizerId,
          eventId: selection.eventId,
          initialEvent: initialEvent,
          initialSection: switch (uri.queryParameters['section']) {
            'live' => HostEventManageSection.live,
            'report' => HostEventManageSection.report,
            'guests' => HostEventManageSection.guests,
            _ => HostEventManageSection.setup,
          },
        ),
      ),
    );
  }
}
