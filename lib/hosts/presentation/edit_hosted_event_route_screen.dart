part of 'edit_hosted_event_screen.dart';

class EditHostedEventRouteScreen extends ConsumerWidget {
  const EditHostedEventRouteScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final clubAsync = ref.watch(fetchClubProvider(clubId));
    final eventAsync = ref.watch(watchEventProvider(eventId));

    final state = HostEventEditState.resolve(
      uid: _catchAsyncState(uidAsync),
      club: _catchAsyncState(clubAsync),
      event: _catchAsyncState(eventAsync),
      initialEvent: initialEvent,
    );

    return switch (state.status) {
      HostEventEditRouteStatus.loading => Scaffold(
        backgroundColor: CatchTokens.of(context).bg,
        appBar: CatchTopBar(
          title: context.l10n.hostsEditHostedEventRouteScreenTitleEditEvent,
          border: true,
        ),
        body: const SafeArea(child: HostRouteLoadingBody(showTabRail: true)),
      ),
      HostEventEditRouteStatus.error => CatchErrorScaffold.fromError(
        state.error!,
        context: AppErrorContext.event,
        onRetry: () {
          ref.invalidate(fetchClubProvider(clubId));
          ref.invalidate(watchEventProvider(eventId));
        },
      ),
      HostEventEditRouteStatus.notFound => CatchErrorScaffold(
        title: context.l10n.hostsEditHostedEventRouteScreenTitleEventNotFound,
        message: context
            .l10n
            .hostsEditHostedEventRouteScreenMessageThisHostedEventIs,
      ),
      HostEventEditRouteStatus.unauthorized => CatchErrorScaffold(
        title:
            context.l10n.hostsEditHostedEventRouteScreenTitleActionUnavailable,
        message:
            context.l10n.hostsEditHostedEventRouteScreenMessageYouCanEditOnly,
        icon: CatchIcons.blockRounded,
      ),
      HostEventEditRouteStatus.ready => EditHostedEventScreen(
        club: state.club!,
        event: state.event!,
      ),
    };
  }
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return value.when(
    data: CatchAsyncState<T>.data,
    loading: () => const CatchAsyncState.loading(),
    error: (error, stackTrace) => CatchAsyncState<T>.error(error),
  );
}
