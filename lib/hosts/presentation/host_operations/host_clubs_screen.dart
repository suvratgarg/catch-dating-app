part of '../host_operations_screen.dart';

class HostClubsScreen extends ConsumerWidget {
  const HostClubsScreen({
    super.key,
    this.initialClubId,
    this.initialTab = HostClubTab.edit,
    this.initialExpandedEditField,
  });

  final String? initialClubId;
  final HostClubTab initialTab;
  final String? initialExpandedEditField;

  HostClubTab get effectiveInitialTab =>
      initialExpandedEditField == null ? initialTab : HostClubTab.edit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final selectedTab = effectiveInitialTab;
    return CatchAsyncValueView<String?>(
      value: uidAsync,
      onRetry: () => ref.invalidate(uidProvider),
      loadingBuilder: (_) => HostOrganizerStateScaffold(
        selectedTab: selectedTab,
        scrollKey: const PageStorageKey<String>(
          'host-organizer-auth-route-state',
        ),
        slivers: const [
          CatchSliverStateViewport(
            child: HostRouteLoadingBody(padding: EdgeInsets.zero),
          ),
        ],
      ),
      errorBuilderWithRetry: (_, error, _, onRetry) =>
          HostOrganizerStateScaffold(
            selectedTab: selectedTab,
            scrollKey: const PageStorageKey<String>(
              'host-organizer-auth-route-state',
            ),
            slivers: [
              CatchSliverErrorState.fromError(
                error,
                context: AppErrorContext.auth,
                onRetry: onRetry,
              ),
            ],
          ),
      builder: (context, uid) {
        if (uid == null) {
          return HostOrganizerStateScaffold(
            selectedTab: selectedTab,
            scrollKey: const PageStorageKey<String>(
              'host-organizer-auth-route-state',
            ),
            slivers: [
              CatchSliverErrorState(
                title:
                    context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
                message: context
                    .l10n
                    .hostsHostAuthRequiredScreenMessageSignInToManage,
                retryLabel:
                    context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
                onRetry: () => context.go(Routes.authScreen.path),
              ),
            ],
          );
        }

        final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
        return CatchAsyncValueView<List<Club>>(
          value: clubsAsync,
          onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
          loadingBuilder: (_) => HostOrganizerStateScaffold(
            selectedTab: selectedTab,
            scrollKey: const PageStorageKey<String>(
              'host-organizer-data-route-state',
            ),
            slivers: const [
              CatchSliverStateViewport(
                child: HostRouteLoadingBody(padding: EdgeInsets.zero),
              ),
            ],
          ),
          errorBuilderWithRetry: (_, error, _, onRetry) =>
              HostOrganizerStateScaffold(
                selectedTab: selectedTab,
                scrollKey: const PageStorageKey<String>(
                  'host-organizer-data-route-state',
                ),
                slivers: [
                  CatchSliverErrorState.fromError(
                    error,
                    context: AppErrorContext.club,
                    onRetry: onRetry,
                  ),
                ],
              ),
          builder: (context, clubs) => HostClubsScaffold(
            clubs: clubs,
            currentUid: uid,
            initialClubId: initialClubId,
            initialTab: selectedTab,
            initialExpandedEditField: initialExpandedEditField,
          ),
        );
      },
    );
  }
}
