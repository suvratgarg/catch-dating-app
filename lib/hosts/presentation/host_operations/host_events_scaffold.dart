part of '../host_operations_screen.dart';

class HostEventsScaffold extends StatefulWidget {
  const HostEventsScaffold({
    super.key,
    required this.clubs,
    required this.currentUid,
    this.initialClubId,
    this.now,
  });

  final List<Club> clubs;
  final String currentUid;
  final String? initialClubId;
  final DateTime? now;

  @override
  State<HostEventsScaffold> createState() => _HostEventsScaffoldState();
}

class _HostEventsScaffoldState extends State<HostEventsScaffold> {
  late HostHomeScreenState _state;
  HostEventsLifecycleFilter _eventFilter = HostEventsLifecycleFilter.upcoming;
  late DateTime _clockNow;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _state = HostHomeScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubId: widget.initialClubId,
    );
    _resetClock();
  }

  @override
  void didUpdateWidget(HostEventsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _state = HostHomeScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubIndex: _state.selectedClubIndex,
      selectedClubId: _state.selectedClub?.id,
    );
    if (oldWidget.now != widget.now) _resetClock();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _resetClock() {
    _clockTimer?.cancel();
    _clockNow = widget.now ?? DateTime.now();
    if (widget.now != null) return;
    _scheduleClockTick();
  }

  void _scheduleClockTick() {
    final current = DateTime.now();
    final nextMinute = DateTime(
      current.year,
      current.month,
      current.day,
      current.hour,
      current.minute + 1,
    );
    _clockTimer = Timer(nextMinute.difference(current) + CatchMotion.fast, () {
      if (!mounted) return;
      setState(() => _clockNow = DateTime.now());
      _scheduleClockTick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final selectedClub = _state.selectedClub;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: selectedClub == null
            ? CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: CatchScreenHeaderTitle.block(
                      title: context.l10n.hostsHostEventsListTextEvents,
                    ),
                  ),
                  CatchSliverEmptyState(
                    icon: CatchIcons.groupsOutlined,
                    title: context
                        .l10n
                        .hostsHostEventsScaffoldTitleCreateYourFirstClub,
                    message:
                        context.l10n.hostsHostEventsScaffoldBodyCreateAClubTo,
                    action: CatchButton(
                      label:
                          context.l10n.hostsHostEventsScaffoldLabelCreateClub,
                      icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                      size: CatchButtonSize.sm,
                      onPressed: () =>
                          context.pushNamed(Routes.hostCreateClubScreen.name),
                    ),
                  ),
                  const CatchSliverTerminalPadding(),
                ],
              )
            : HostEventsClubCard(
                club: selectedClub,
                currentUid: _state.currentUid,
                clubs: _state.clubs,
                showClubPicker: _state.showClubPicker,
                selectedFilter: _eventFilter,
                onSwitchClubIndex: (index) =>
                    setState(() => _state = _state.selectClubIndex(index)),
                onFilterChanged: (filter) =>
                    setState(() => _eventFilter = filter),
                onCreateEvent: _openCreateEvent,
                onConnectExternalEvent: _openExternalEvent,
                onRepeatEvent: _openRepeatEvent,
                onManageEvent: _openEvent,
                onOpenTask: _openAttentionTask,
                now: _clockNow,
              ),
      ),
    );
  }

  void _openCreateEvent(Club club) {
    context.pushNamed(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': club.id},
      extra: club,
    );
  }

  void _openExternalEvent(Club club) {
    context.pushNamed(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': club.id},
      extra: HostCreateEventRouteArguments(
        initialClub: club,
        externalBookingMode: true,
      ),
    );
  }

  void _openRepeatEvent(Club club, Event event) {
    final prefill = CreateEventPrefill.repeat(
      event: event,
      createdAt: _clockNow,
    );
    context.pushNamed(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': club.id},
      extra: HostCreateEventRouteArguments(
        initialClub: club,
        initialPrefill: prefill,
      ),
    );
  }

  void _openEvent(Club club, Event event) {
    final isLive =
        !event.startTime.isAfter(_clockNow) && event.endTime.isAfter(_clockNow);
    final section = isLive
        ? 'live'
        : event.endTime.isAfter(_clockNow)
        ? 'setup'
        : 'report';
    context.pushNamed(
      Routes.hostAppEventManageScreen.name,
      pathParameters: {'clubId': club.id, 'eventId': event.id},
      queryParameters: {'section': section},
      extra: event,
    );
  }

  void _openAttentionTask(Club club, Event event, HostEventAttentionData task) {
    context.pushNamed(
      Routes.hostAppEventManageScreen.name,
      pathParameters: {'clubId': club.id, 'eventId': event.id},
      queryParameters: {
        'section': switch (task.destination) {
          HostEventAttentionDestination.guests => 'guests',
          HostEventAttentionDestination.setup => 'setup',
        },
      },
      extra: event,
    );
  }
}
