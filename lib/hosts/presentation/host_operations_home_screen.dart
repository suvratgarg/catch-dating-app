part of 'host_operations_screen.dart';

class HostOperationsHomeScreen extends ConsumerWidget {
  const HostOperationsHomeScreen({
    super.key,
    this.initialClubId,
    this.initialTab = HostHomeTab.today,
  });

  final String? initialClubId;
  final HostHomeTab initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final uid = uidAsync.asData?.value;
    final clubsAsync = uid == null
        ? null
        : ref.watch(_hostClubsForUserProvider(uid));
    final routeState = buildHostHomeRouteState(
      uid: uidAsync,
      clubs: clubsAsync,
    );

    return switch (routeState.status) {
      HostHomeRouteStatus.authRequired => const HostAuthRequiredScreen(),
      HostHomeRouteStatus.loading => const HostLoadingScreen(
        title: 'Host events',
      ),
      HostHomeRouteStatus.error => CatchErrorScaffold.fromError(
        routeState.error!,
        context: routeState.errorContext,
        onRetry: () {
          final uid = routeState.uid;
          if (routeState.errorContext == AppErrorContext.auth || uid == null) {
            ref.invalidate(uidProvider);
            return;
          }
          ref.invalidate(_hostClubsForUserProvider(uid));
        },
      ),
      HostHomeRouteStatus.empty => HostEventsScaffold(
        clubs: routeState.clubs,
        currentUid: routeState.uid!,
        initialClubId: initialClubId,
        initialTab: initialTab,
      ),
      HostHomeRouteStatus.loaded => HostEventsScaffold(
        clubs: routeState.clubs,
        currentUid: routeState.uid!,
        initialClubId: initialClubId,
        initialTab: initialTab,
      ),
    };
  }
}
