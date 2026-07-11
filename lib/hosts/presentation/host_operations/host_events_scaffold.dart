part of '../host_operations_screen.dart';

class HostEventsScaffold extends StatefulWidget {
  const HostEventsScaffold({
    super.key,
    required this.clubs,
    required this.currentUid,
    this.initialClubId,
    this.initialTab = HostHomeTab.today,
    this.onViewEvents,
    this.now,
  });

  final List<Club> clubs;
  final String currentUid;
  final String? initialClubId;
  final HostHomeTab initialTab;
  final VoidCallback? onViewEvents;
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
      selectedTab: widget.initialTab,
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
      selectedTab: _state.selectedTab,
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

    if (_state.selectedTab == HostHomeTab.today) {
      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: CatchInsets.pageBody.copyWith(top: CatchSpacing.s12),
            children: [
              if (selectedClub == null)
                HostEmptyActionCard(
                  title: 'Create your first club',
                  body:
                      'Create a club to publish events, manage attendees, and run Event Success.',
                  actions: [
                    CatchButton(
                      label: 'Create club',
                      icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                      onPressed: () =>
                          context.pushNamed(Routes.hostCreateClubScreen.name),
                    ),
                  ],
                )
              else
                HostTodayDashboardCard(
                  club: selectedClub,
                  currentUid: _state.currentUid,
                  clubs: _state.clubs,
                  showClubPicker: _state.showClubPicker,
                  onSwitchClubIndex: (index) =>
                      setState(() => _state = _state.selectClubIndex(index)),
                  onViewEvents:
                      widget.onViewEvents ??
                      () => setState(
                        () => _state = _state.selectTab(HostHomeTab.events),
                      ),
                  onCreateEvent: _openCreateEvent,
                  onManageEvent: _openTodayEvent,
                  onOpenTask: _openTodayTask,
                  now: _clockNow,
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: CatchInsets.pageBody.copyWith(top: CatchSpacing.s3),
          children: [
            if (selectedClub == null) ...[
              Text(
                'Events',
                style: CatchTextStyles.headline(context, color: t.ink),
              ),
              gapH24,
              HostEmptyActionCard(
                title: 'Create your first club',
                body:
                    'Create a club to publish events, manage attendees, and run Event Success.',
                actions: [
                  CatchButton(
                    label: 'Create club',
                    icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                    onPressed: () =>
                        context.pushNamed(Routes.hostCreateClubScreen.name),
                  ),
                ],
              ),
            ] else
              HostEventsClubCard(
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
                onRepeatEvent: _openRepeatEvent,
                onManageEvent: _openManageEvent,
                now: _clockNow,
              ),
          ],
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

  void _openManageEvent(Club club, Event event) {
    context.pushNamed(
      Routes.hostAppEventManageScreen.name,
      pathParameters: {'clubId': club.id, 'eventId': event.id},
      extra: event,
    );
  }

  void _openTodayEvent(Club club, Event event) {
    final isLive =
        !event.startTime.isAfter(_clockNow) && event.endTime.isAfter(_clockNow);
    context.pushNamed(
      Routes.hostAppEventManageScreen.name,
      pathParameters: {'clubId': club.id, 'eventId': event.id},
      queryParameters: {'section': isLive ? 'live' : 'setup'},
      extra: event,
    );
  }

  void _openTodayTask(Club club, Event event, HostHomeTodayTaskData task) {
    context.pushNamed(
      Routes.hostAppEventManageScreen.name,
      pathParameters: {'clubId': club.id, 'eventId': event.id},
      queryParameters: {
        'section': switch (task.destination) {
          HostHomeTodayTaskDestination.guests => 'guests',
          HostHomeTodayTaskDestination.setup => 'setup',
        },
      },
      extra: event,
    );
  }
}
