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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    if (uidAsync.isLoading) {
      return HostLoadingScreen(
        title: context.l10n.hostsHostClubsScreenTitleClubs,
        showTabRail: true,
      );
    }
    if (uidAsync.hasError) {
      return CatchErrorScaffold.fromError(
        uidAsync.error!,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      );
    }

    final uid = uidAsync.asData?.value;
    if (uid == null) return const HostAuthRequiredScreen();

    final clubsAsync = ref.watch(_hostClubsForUserProvider(uid));
    return CatchAsyncValueView<List<Club>>(
      value: clubsAsync,
      loadingBuilder: (_) => HostLoadingScreen(
        title: context.l10n.hostsHostClubsScreenTitleClubs,
        showTabRail: true,
      ),
      errorBuilder: (_, error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(_hostClubsForUserProvider(uid)),
      ),
      builder: (context, clubs) => HostClubsScaffold(
        clubs: clubs,
        currentUid: uid,
        initialClubId: initialClubId,
        initialTab: initialTab,
        initialExpandedEditField: initialExpandedEditField,
      ),
    );
  }
}
