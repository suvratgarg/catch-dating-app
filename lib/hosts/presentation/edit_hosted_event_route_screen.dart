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
      HostEventEditRouteStatus.loading => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostsEditHostedEventRouteScreenTitleEditEvent,
          divider: scrolledUnder,
        ),
        body: const CatchRouteBody.standard(
          scrollable: false,
          child: HostRouteLoadingBody(
            showTabRail: true,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      HostEventEditRouteStatus.error => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostsEditHostedEventRouteScreenTitleEditEvent,
          leadingType: CatchTopBarLeading.back,
          divider: scrolledUnder,
        ),
        body: CatchRouteBody.standard(
          scrollable: false,
          child: CatchErrorState.fromError(
            state.error!,
            context: AppErrorContext.event,
            onRetry: () {
              ref.invalidate(fetchClubProvider(clubId));
              ref.invalidate(watchEventProvider(eventId));
            },
          ),
        ),
      ),
      HostEventEditRouteStatus.notFound => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostsEditHostedEventRouteScreenTitleEditEvent,
          leadingType: CatchTopBarLeading.back,
          divider: scrolledUnder,
        ),
        body: CatchRouteBody.standard(
          scrollable: false,
          child: CatchErrorBody(
            title:
                context.l10n.hostsEditHostedEventRouteScreenTitleEventNotFound,
            message: context
                .l10n
                .hostsEditHostedEventRouteScreenMessageThisHostedEventIs,
            secondaryAction: const CatchErrorBackAction(),
          ),
        ),
      ),
      HostEventEditRouteStatus.unauthorized => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostsEditHostedEventRouteScreenTitleEditEvent,
          leadingType: CatchTopBarLeading.back,
          divider: scrolledUnder,
        ),
        body: CatchRouteBody.standard(
          scrollable: false,
          child: CatchErrorBody(
            title: context
                .l10n
                .hostsEditHostedEventRouteScreenTitleActionUnavailable,
            message: context
                .l10n
                .hostsEditHostedEventRouteScreenMessageYouCanEditOnly,
            icon: CatchIcons.blockRounded,
            secondaryAction: const CatchErrorBackAction(),
          ),
        ),
      ),
      HostEventEditRouteStatus.ready => EditHostedEventScreen(
        club: state.club!,
        event: state.event!,
      ),
    };
  }
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return catchAsyncStateFromAsyncValue(value);
}
