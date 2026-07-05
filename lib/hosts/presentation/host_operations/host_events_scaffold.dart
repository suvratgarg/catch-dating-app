part of '../host_operations_screen.dart';

class HostEventsScaffold extends StatefulWidget {
  const HostEventsScaffold({
    super.key,
    required this.clubs,
    required this.currentUid,
    this.initialClubId,
    this.initialTab = HostHomeTab.today,
  });

  final List<Club> clubs;
  final String currentUid;
  final String? initialClubId;
  final HostHomeTab initialTab;

  @override
  State<HostEventsScaffold> createState() => _HostEventsScaffoldState();
}

class _HostEventsScaffoldState extends State<HostEventsScaffold> {
  late HostHomeScreenState _state;

  @override
  void initState() {
    super.initState();
    _state = HostHomeScreenState.resolve(
      clubs: widget.clubs,
      currentUid: widget.currentUid,
      selectedClubId: widget.initialClubId,
      selectedTab: widget.initialTab,
    );
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
                  onViewEvents: () => setState(
                    () => _state = _state.selectTab(HostHomeTab.events),
                  ),
                  onCreateEvent: _openCreateEvent,
                  onManageEvent: _openManageEvent,
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: t.bg,
      appBar: HostOperationsTopBar(
        kicker: 'OPERATIONS',
        title: _state.title,
        actions: [
          if (_state.showClubPicker)
            CatchTopBarMenuAction<int>(
              tooltip: 'Switch club',
              icon: CatchIcons.expandMoreRounded,
              items: [
                for (var index = 0; index < _state.clubs.length; index++)
                  CatchActionMenuItem(
                    value: index,
                    label:
                        '${_state.clubs[index].name} · '
                        '${_state.clubs[index].isOwnedBy(_state.currentUid) ? 'Owner' : 'Host team'}',
                  ),
              ],
              onSelected: (index) =>
                  setState(() => _state = _state.selectClubIndex(index)),
            ),
        ],
      ),
      body: ListView(
        padding: CatchInsets.pageBodyUnderHeader,
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
            HostEventsClubCard(
              club: selectedClub,
              currentUid: _state.currentUid,
              onCreateEvent: _openCreateEvent,
              onManageEvent: _openManageEvent,
            ),
        ],
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

  void _openManageEvent(Club club, Event event) {
    context.pushNamed(
      Routes.hostAppEventManageScreen.name,
      pathParameters: {'clubId': club.id, 'eventId': event.id},
      extra: event,
    );
  }
}
