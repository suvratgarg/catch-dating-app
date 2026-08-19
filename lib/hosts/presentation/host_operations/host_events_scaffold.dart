part of '../host_operations_screen.dart';

class HostEventsScaffold extends ConsumerStatefulWidget {
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
  ConsumerState<HostEventsScaffold> createState() => _HostEventsScaffoldState();
}

class _HostEventsScaffoldState extends ConsumerState<HostEventsScaffold> {
  late DateTime _clockNow;
  late DateTime _timelineBoundary;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _resetClock();
  }

  @override
  void didUpdateWidget(HostEventsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    _timelineBoundary = _clockNow;
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
    final selectedOrganizerId = ref.watch(
      hostOrganizerSelectionProvider(widget.currentUid),
    );
    final selectedClub = resolveSelectedHostOrganizer(
      widget.clubs,
      selectedOrganizerId: selectedOrganizerId,
      preferredOrganizerId: selectedOrganizerId == null
          ? widget.initialClubId
          : null,
    );

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
                onEventEntrySelected: _handleEventEntrySelected,
                onManageEvent: _openEvent,
                onOpenTask: _openAttentionTask,
                now: _clockNow,
                sessionBoundary: _timelineBoundary,
              ),
      ),
    );
  }

  Future<void> _handleEventEntrySelected(
    Club club,
    HostEventEntryState state,
    HostEventEntryIntent intent,
  ) async {
    switch (intent) {
      case HostEventEntryIntent.resumeDraft:
        final draft = await _pickDraft(state);
        if (draft == null || !mounted) return;
        await _openCreateEvent(club, initialDraft: draft);
      case HostEventEntryIntent.repeatLastEvent:
        final source = state.repeatSource;
        if (source == null) return;
        await _openRepeatEvent(club, source);
      case HostEventEntryIntent.createWithCatchBookings:
        await _openCreateEvent(club);
      case HostEventEntryIntent.createFromGuestList:
        await _openExternalEvent(club);
    }
  }

  Future<EventDraft?> _pickDraft(HostEventEntryState state) async {
    if (!state.hasMultipleDrafts) return state.mostRecentDraft;
    return showDraftPickerSheet(
      context: context,
      drafts: state.drafts,
      showStartFreshAction: false,
      onDeleteDraft: (draft) async {
        await CreateEventDraftController.deleteDraftMutation.run(ref, (tx) {
          return tx
              .get(createEventDraftControllerProvider.notifier)
              .deleteDraft(clubId: draft.clubId, draftId: draft.id);
        });
        ref.invalidate(clubEventDraftsProvider(clubId: draft.clubId));
      },
    );
  }

  Future<void> _openCreateEvent(Club club, {EventDraft? initialDraft}) async {
    await context.pushNamed(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': club.id},
      extra: HostCreateEventRouteArguments(
        initialClub: club,
        initialDraft: initialDraft,
        externalBookingMode: initialDraft?.externalBookingMode ?? false,
        promptForDrafts: false,
      ),
    );
    ref.invalidate(clubEventDraftsProvider(clubId: club.id));
  }

  Future<void> _openExternalEvent(Club club) async {
    HostRosterTable? table;
    try {
      table = await ref
          .read(createEventControllerProvider.notifier)
          .pickRosterFile();
    } on HostRosterImportException catch (error) {
      if (mounted) {
        showCatchSnackBar(
          context,
          hostRosterImportIssueCopy(context, error.issue),
        );
      }
      return;
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
      return;
    }
    if (table == null || !mounted) return;
    final rosterPlan = await showHostRosterMapping(context, table);
    if (rosterPlan == null || !mounted) return;
    await context.pushNamed(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': club.id},
      extra: HostCreateEventRouteArguments(
        initialClub: club,
        externalBookingMode: true,
        initialRosterImportPlan: rosterPlan,
        promptForDrafts: false,
      ),
    );
    ref.invalidate(clubEventDraftsProvider(clubId: club.id));
  }

  Future<void> _openRepeatEvent(Club club, Event event) async {
    final prefill = CreateEventPrefill.repeat(
      event: event,
      createdAt: _clockNow,
    );
    await context.pushNamed(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': club.id},
      extra: HostCreateEventRouteArguments(
        initialClub: club,
        initialPrefill: prefill,
        promptForDrafts: false,
      ),
    );
    ref.invalidate(clubEventDraftsProvider(clubId: club.id));
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
