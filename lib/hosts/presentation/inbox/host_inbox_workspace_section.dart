part of 'host_inbox_screen.dart';

class HostInboxWorkspaceSection extends ConsumerWidget {
  const HostInboxWorkspaceSection({
    super.key,
    required this.uidState,
    required this.uid,
    required this.clubsState,
    required this.selectedClub,
    required this.query,
    required this.now,
    required this.requestedScope,
    required this.selectedSegment,
    required this.selectedThreadId,
    required this.onRetry,
    required this.onScopeChanged,
    required this.onSegmentChanged,
    required this.onPersonSelected,
  });
  final CatchAsyncState<String?> uidState;
  final String? uid;
  final CatchAsyncState<List<Club>> clubsState;
  final Club? selectedClub;
  final String query;
  final DateTime now;
  final HostInboxScope? requestedScope;
  final HostInboxAudienceSegment selectedSegment;
  final String? selectedThreadId;
  final ValueChanged<String?> onRetry;
  final ValueChanged<HostInboxScope> onScopeChanged;
  final ValueChanged<HostInboxAudienceSegment> onSegmentChanged;
  final ValueChanged<HostInboxPerson> onPersonSelected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (uidState.hasError || clubsState.hasError) {
      final failed = uidState.hasError ? uidState : clubsState;
      return CatchLocalizedSliverErrorState(
        failed.error!,
        context: AppErrorContext.chat,
        onRetry: () => onRetry(selectedClub?.id),
      );
    }
    if (uidState.isLoading) return const ChatsListSkeleton();
    if (uid == null) return const _HostAuthRequiredSliver();
    if (clubsState.isLoading) return const ChatsListSkeleton();
    final club = selectedClub;
    if (club == null) return const _HostNoOrganizerSliver();
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final inboxAsync = ref.watch(hostInboxCatchViewModelProvider);
    final whatsappAsync = ref.watch(hostInboxWhatsappPagesProvider(club.id));
    final eventsState = catchAsyncStateFromAsyncValue(eventsAsync);
    final inboxState = catchAsyncStateFromAsyncValue(inboxAsync);
    final liveInboxState = catchAsyncStateFromAsyncValue(
      ref.watch(chatsListViewModelProvider),
    );
    final whatsappState = catchAsyncStateFromAsyncValue(whatsappAsync);
    final events = eventsState.value;
    final scope = events == null
        ? const HostInboxScope.general()
        : resolveHostInboxScope(
            events: events,
            now: now,
            requestedScope: requestedScope,
          );
    final eventId = scope.eventId;
    final participationsAsync = eventId == null
        ? const AsyncData<List<EventParticipation>>([])
        : ref.watch(watchEventParticipationsForEventProvider(eventId));
    final failed = eventsState.hasError ? eventsState : null;
    if (failed != null) {
      return CatchLocalizedSliverErrorState(
        failed.error!,
        context: AppErrorContext.chat,
        onRetry: () => onRetry(club.id),
      );
    }
    final loading = eventsState.isLoading;
    final inbox =
        inboxState.value ??
        const ChatsListViewModel(
          newMatches: [],
          conversations: [],
          totalThreadCount: 0,
        );
    final participations = catchAsyncStateFromAsyncValue(
      participationsAsync,
    ).value;
    final whatsappPage = whatsappState.value;
    final catchPages = ref.watch(hostInboxCatchPagesProvider(uid!));
    final sourceWindowMayHaveMore =
        catchAsyncStateFromAsyncValue(
          ref.watch(chatsListViewModelProvider),
        ).value?.sourceWindowMayHaveMore ??
        true;
    final catchHasMore = catchPages.canLoadMore(sourceWindowMayHaveMore);
    final workspace = events == null
        ? null
        : HostInboxViewModel.compose(
            events: events,
            inbox: inbox,
            participations: participations ?? const [],
            selectedOrganizerId: club.id,
            selectedScope: scope,
            selectedSegment: selectedSegment,
            query: query,
            now: now,
          );
    if (loading || workspace == null) {
      return const ChatsListSkeleton();
    }
    final people = composeHostInboxPeople(
      organizerId: club.id,
      scope: scope,
      segment: selectedSegment,
      catchThreads: [...inbox.newMatches, ...inbox.conversations],
      whatsappThreads: whatsappPage?.threads ?? const [],
      participations: participations,
      query: query,
    );
    final partial =
        catchHasMore ||
        catchPages.error != null ||
        liveInboxState.isLoading ||
        liveInboxState.hasError ||
        inboxState.isLoading ||
        inboxState.hasError ||
        whatsappState.isLoading ||
        whatsappState.hasError ||
        whatsappPage?.nextCursor != null;
    return SliverMainAxisGroup(
      slivers: [
        if (workspace.scopeOptions.length > 1)
          HostInboxScopeMenu(
            workspace: workspace,
            now: now,
            onChanged: onScopeChanged,
          ),
        if (!workspace.isGeneral)
          HostInboxAudienceInput(
            workspace: workspace,
            people: people,
            complete: !partial && participations != null,
            onChanged: onSegmentChanged,
          ),
        if (partial)
          SliverToBoxAdapter(
            child: CatchSection.content(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.hostInboxPartialSources,
                    style: CatchTextStyles.supporting(context),
                  ),
                  if (liveInboxState.hasError ||
                      inboxState.hasError ||
                      whatsappState.hasError)
                    CatchButton(
                      label: context.l10n.sharedActionTryAgain,
                      onPressed: () {
                        ref.invalidate(hostWhatsappThreadsProvider(club.id));
                        onRetry(club.id);
                      },
                    ),
                ],
              ),
            ),
          ),
        if (people.unclassifiedCount > 0)
          SliverToBoxAdapter(
            child: CatchSection.content(
              child: Text(
                context.l10n.hostInboxUnclassified,
                style: CatchTextStyles.supporting(context),
              ),
            ),
          ),
        HostInboxPeopleSection(
          workspace: workspace,
          people: people,
          now: now,
          selectedThreadId: selectedThreadId,
          showEmpty: !partial,
          sourceCoverageComplete: !partial,
          onPersonSelected: onPersonSelected,
        ),
        if (catchHasMore)
          SliverToBoxAdapter(
            child: CatchSection.content(
              child: CatchButton(
                label: catchPages.error == null
                    ? context.l10n.hostInboxMoreConversations
                    : context.l10n.sharedActionTryAgain,
                onPressed: catchPages.loadingMore
                    ? null
                    : () => ref
                          .read(hostInboxCatchPagesProvider(uid!).notifier)
                          .loadMore(),
              ),
            ),
          ),
        if (whatsappPage?.nextCursor != null)
          SliverToBoxAdapter(
            child: CatchSection.content(
              child: CatchButton(
                label: whatsappPage?.error == null
                    ? context.l10n.hostInboxMoreConversations
                    : context.l10n.sharedActionTryAgain,
                onPressed: whatsappPage!.loadingMore
                    ? null
                    : () => ref
                          .read(
                            hostInboxWhatsappPagesProvider(club.id).notifier,
                          )
                          .loadMore(),
              ),
            ),
          ),
      ],
    );
  }
}

class HostMessagingWorkspaceTabBar extends StatelessWidget
    implements CatchPrimaryRail, CatchScaledPreferredSize {
  const HostMessagingWorkspaceTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final HostMessagingWorkspace selected;
  final ValueChanged<HostMessagingWorkspace>? onChanged;
  @override
  Size get preferredSize => Size.fromHeight(CatchPageTabBar.minimumHeight);
  @override
  Size preferredSizeFor(BuildContext context) =>
      Size.fromHeight(CatchPageTabBar.heightFor(context));
  @override
  Widget build(BuildContext context) => CatchPageTabBar<HostMessagingWorkspace>(
    key: const ValueKey<String>('host-messaging-workspace-rail'),
    selected: selected,
    options: [
      CatchOption(
        value: HostMessagingWorkspace.inbox,
        label: context.l10n.hostMessagingWorkspaceInbox,
      ),
      CatchOption(
        value: HostMessagingWorkspace.campaigns,
        label: context.l10n.hostMessagingWorkspaceSends,
      ),
    ],
    onChanged: onChanged,
  );
}

class HostInboxAudienceInput extends StatelessWidget {
  const HostInboxAudienceInput({
    super.key,
    required this.workspace,
    required this.onChanged,
    this.people,
    this.complete = true,
  });
  final HostInboxViewModel workspace;
  final HostInboxPeople? people;
  final bool complete;
  final ValueChanged<HostInboxAudienceSegment> onChanged;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: CatchInsets.pageHorizontal,
        child: CatchChoiceInput<HostInboxAudienceSegment>.segmented(
          variant: CatchChoiceInputVariant.summary,
          contract:
              CatchContractConstraints.mobileFormStateHostInboxAudienceSegment,
          contractValueBuilder: (segment) => segment.name,
          selected: workspace.selectedSegment,
          options: [
            CatchOption(
              value: HostInboxAudienceSegment.booked,
              label: complete
                  ? context.l10n
                        .hostsHostInboxScreenLabelBookedBookedthreadcount(
                          bookedThreadCount:
                              people?.bookedCount ??
                              workspace.bookedThreadCount,
                        )
                  : context.l10n.hostInboxBookedStatus,
            ),
            CatchOption(
              value: HostInboxAudienceSegment.prospective,
              label: complete
                  ? context.l10n
                        .hostsHostInboxScreenLabelProspectiveProspectivethreadcount(
                          prospectiveThreadCount:
                              people?.prospectiveCount ??
                              workspace.prospectiveThreadCount,
                        )
                  : context.l10n.hostInboxProspectiveStatus,
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class HostInboxPeopleSection extends StatelessWidget {
  const HostInboxPeopleSection({
    super.key,
    required this.workspace,
    required this.people,
    required this.now,
    this.selectedThreadId,
    this.showEmpty = true,
    this.sourceCoverageComplete = true,
    required this.onPersonSelected,
  });
  final HostInboxViewModel workspace;
  final HostInboxPeople people;
  final DateTime now;
  final String? selectedThreadId;
  final bool showEmpty;
  final bool sourceCoverageComplete;
  final ValueChanged<HostInboxPerson> onPersonSelected;
  @override
  Widget build(BuildContext context) {
    if (people.people.isEmpty) {
      return showEmpty
          ? CatchStateViewport.sliver(
              child: workspace.query.isNotEmpty
                  ? const ChatsEmptyState.noHostSearchResults()
                  : HostInboxEmptyState(
                      title: workspace.isGeneral
                          ? context
                                .l10n
                                .hostsHostInboxScreenTitleNoGeneralInquiries
                          : context.l10n.hostsHostInboxScreenTitleNoValue1HaveWritten(
                              value1:
                                  workspace.selectedSegment ==
                                      HostInboxAudienceSegment.booked
                                  ? context
                                        .l10n
                                        .hostsHostInboxScreenTitleBookedAttendees
                                  : context
                                        .l10n
                                        .hostsHostInboxScreenTitleProspectiveAttendees,
                            ),
                      message: context.l10n.hostInboxChoosePerson,
                    ),
            )
          : const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return CatchSection.sliverRows(
      itemCount: people.people.length,
      indexForKeyBuilder: (key) {
        final index = people.people.indexWhere((p) => ValueKey(p.key) == key);
        return index < 0 ? null : index;
      },
      itemBuilder: (context, index) {
        final person = people.people[index];
        final unread = person.knownUnreadCount;
        return CatchField.navigate(
          key: ValueKey(person.key),
          content: CatchConversationLayout(
            name: person.displayName,
            imageUrl: person.photoUrl,
            preview: person.previewText,
            timestamp: AppTimeFormatters.compactRelativeTime(
              person.timestamp,
              now: now,
            ),
            context: !workspace.isGeneral && person.booked == null
                ? context.l10n.hostInboxUnknownBooking
                : null,
            activityLabel: unread > 0
                ? '$unread${sourceCoverageComplete && person.unreadCountIsComplete ? '' : '+'}'
                : null,
            activitySemantics: unread > 0
                ? sourceCoverageComplete && person.unreadCountIsComplete
                      ? context.l10n.coreCatchPersonRowLabelLabelUnreadChats(
                          label: '$unread',
                        )
                      : context.l10n.hostInboxPartialUnread(count: unread)
                : null,
          ),
          states: {
            if (selectedThreadId != null &&
                person.containsEndpoint(selectedThreadId!))
              WidgetState.selected,
          },
          onActivate: () => onPersonSelected(person),
        );
      },
    );
  }
}

class HostInboxEmptyState extends StatelessWidget {
  const HostInboxEmptyState({
    super.key,
    required this.title,
    required this.message,
  });
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.contentRelaxed,
      child: CatchEmptyState(
        icon: CatchIcons.chatBubbleOutlineRounded,
        title: title,
        message: message,
      ),
    );
  }
}
