part of 'host_event_manage_screen.dart';

typedef _HostEventManageRouteData = ({String? uid, Club? club, Event? event});

class HostEventManageRouteScreen extends ConsumerWidget {
  const HostEventManageRouteScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
    this.initialSection = HostEventManageSection.setup,
    this.initialParticipantSearchQuery = '',
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;
  final HostEventManageSection initialSection;
  final String initialParticipantSearchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final clubAsync = ref.watch(fetchClubProvider(clubId));
    final eventAsync = ref.watch(watchEventProvider(eventId));
    final routeDataAsync = _hostEventManageRouteData(
      uidAsync: uidAsync,
      clubAsync: clubAsync,
      eventAsync: eventAsync,
      initialEvent: initialEvent,
    );

    return CatchAsyncValueView<_HostEventManageRouteData>(
      value: routeDataAsync,
      onRetry: () {
        ref.invalidate(uidProvider);
        ref.invalidate(fetchClubProvider(clubId));
        ref.invalidate(watchEventProvider(eventId));
      },
      loadingBuilder: (_) => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostsHostEventManageRouteScreenTitleManageEvent,
          divider: scrolledUnder,
        ),
        body: const SafeArea(child: HostRouteLoadingBody(showTabRail: true)),
      ),
      errorBuilder: (_, error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.event,
        onRetry: () {
          ref.invalidate(fetchClubProvider(clubId));
          ref.invalidate(watchEventProvider(eventId));
        },
      ),
      builder: (context, routeData) {
        final uid = routeData.uid;
        final club = routeData.club;
        final event = routeData.event;
        if (club == null || event == null) {
          return CatchErrorScaffold(
            title:
                context.l10n.hostsHostEventManageRouteScreenTitleEventNotFound,
            message: context
                .l10n
                .hostsHostEventManageRouteScreenMessageThisHostedEventIs,
            secondaryAction: const CatchErrorBackAction(),
          );
        }

        if (uid == null || !club.isHostedBy(uid)) {
          return CatchErrorScaffold(
            title: context
                .l10n
                .hostsHostEventManageRouteScreenTitleActionUnavailable,
            message: context
                .l10n
                .hostsHostEventManageRouteScreenMessageYouCanManageOnly,
            icon: CatchIcons.blockRounded,
            secondaryAction: const CatchErrorBackAction(),
          );
        }

        return HostEventManageScreen(
          club: club,
          event: event,
          onBackToSuccess: () => Navigator.of(context).maybePop(),
          initialSection: initialSection,
          initialParticipantSearchQuery: initialParticipantSearchQuery,
        );
      },
    );
  }
}

AsyncValue<_HostEventManageRouteData> _hostEventManageRouteData({
  required AsyncValue<String?> uidAsync,
  required AsyncValue<Club?> clubAsync,
  required AsyncValue<Event?> eventAsync,
  required Event? initialEvent,
}) {
  final event = eventAsync.asData?.value ?? initialEvent;
  final loading =
      uidAsync.isLoading ||
      clubAsync.isLoading ||
      (eventAsync.isLoading && event == null);
  if (loading) return const AsyncLoading<_HostEventManageRouteData>();

  final error = uidAsync.error ?? clubAsync.error ?? eventAsync.error;
  if (error != null) {
    final stackTrace =
        uidAsync.stackTrace ??
        clubAsync.stackTrace ??
        eventAsync.stackTrace ??
        StackTrace.current;
    return AsyncError<_HostEventManageRouteData>(error, stackTrace);
  }

  return AsyncData<_HostEventManageRouteData>((
    uid: uidAsync.asData?.value,
    club: clubAsync.asData?.value,
    event: event,
  ));
}
