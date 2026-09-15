import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_empty_state.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_sliver_header.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_sliver_error_state.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/hosts/data/crm/host_whatsapp_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_catch_pages.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_people.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_scope_menu.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_selected_person.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_whatsapp_pages.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_new_message_screen.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_reply_drafts.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_sends_workspace.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum HostMessagingWorkspace { inbox, campaigns }

class HostInboxScreen extends ConsumerStatefulWidget {
  const HostInboxScreen({
    super.key,
    this.initialScope,
    this.initialSegment = HostInboxAudienceSegment.booked,
    this.initialWorkspace = HostMessagingWorkspace.inbox,
    this.initialSavedAudienceId,
    this.initialOrganizerId,
    this.initialThreadId,
    this.broadcastEnabled,
    this.syncSelectionToRoute = true,
    this.now,
  });

  final HostInboxScope? initialScope;
  final HostInboxAudienceSegment initialSegment;
  final HostMessagingWorkspace initialWorkspace;
  final String? initialSavedAudienceId;
  final String? initialOrganizerId;
  final String? initialThreadId;
  final bool? broadcastEnabled;
  final bool syncSelectionToRoute;
  final DateTime? now;

  @override
  ConsumerState<HostInboxScreen> createState() => _HostInboxScreenState();
}

class _HostInboxScreenState extends ConsumerState<HostInboxScreen> {
  HostInboxScope? _requestedScope;
  late HostInboxAudienceSegment _segment;
  late HostMessagingWorkspace _workspace;
  bool _campaignBusy = false;
  String? _accountId;
  String? _selectedThreadId;
  final _threadDrafts = HostReplyDrafts();

  @override
  void initState() {
    super.initState();
    _requestedScope = widget.initialScope;
    _segment = widget.initialSegment;
    _workspace = widget.initialWorkspace;
    _selectedThreadId = widget.initialThreadId;
  }

  @override
  void didUpdateWidget(covariant HostInboxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialScope != widget.initialScope &&
        widget.initialScope != null) {
      _requestedScope = widget.initialScope;
    }
    if (oldWidget.initialSegment != widget.initialSegment) {
      _segment = widget.initialSegment;
    }
    if (oldWidget.initialWorkspace != widget.initialWorkspace) {
      _workspace = widget.initialWorkspace;
    }
    if (oldWidget.initialThreadId != widget.initialThreadId) {
      _selectedThreadId = widget.initialThreadId;
    }
  }

  @override
  void dispose() {
    _threadDrafts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final now = widget.now ?? DateTime.now();
    final uidAsync = ref.watch(uidProvider);
    final uidState = catchAsyncStateFromAsyncValue(uidAsync);
    final uid = uidState.value;
    if (_accountId != null && _accountId != uid && !uidState.isLoading) {
      _threadDrafts.clear();
      _selectedThreadId = null;
    }
    if (!uidState.isLoading) _accountId = uid;
    final clubsAsync = uid == null
        ? const AsyncLoading<List<Club>>()
        : ref.watch(hostOperableClubsProvider(uid));
    final clubsState = catchAsyncStateFromAsyncValue(clubsAsync);
    final clubs = clubsState.value;
    final selectedOrganizerId = uid == null
        ? null
        : ref.watch(hostOrganizerSelectionProvider(uid));
    final selectedClub = clubs == null || clubs.isEmpty
        ? null
        : resolveSelectedHostOrganizer(
            clubs,
            selectedOrganizerId: selectedOrganizerId,
            preferredOrganizerId: selectedOrganizerId == null
                ? widget.initialOrganizerId
                : null,
          );
    final query = ref.watch(chatSearchQueryProvider);
    final isInbox = _workspace == HostMessagingWorkspace.inbox;
    final showSearch = isInbox;
    final selectedThreadId = _selectedThreadId;

    Widget buildMaster(BuildContext context, bool splitView) {
      final workspaceSliver = isInbox
          ? _HostInboxWorkspaceGroup(
              uidState: uidState,
              uid: uid,
              clubsState: clubsState,
              selectedClub: selectedClub,
              query: query,
              now: now,
              requestedScope: _requestedScope,
              selectedSegment: _segment,
              selectedThreadId: selectedThreadId,
              onRetry: _retry,
              onScopeChanged: _selectScope,
              onSegmentChanged: _selectSegment,
              onPersonSelected: (person) => _openPerson(person),
            )
          : CatchViewport.sliverLane(
              maxExtent: CatchLayout.hostMessagingSendsPageMaxExtent,
              child: _HostCampaignWorkspaceSliver(
                uidState: uidState,
                uid: uid,
                clubsState: clubsState,
                selectedClub: selectedClub,
                initialSavedAudienceId: widget.initialSavedAudienceId,
                preferredEventId: _requestedScope?.eventId,
                initialSegment: _segment,
                broadcastEnabled: _broadcastEnabled,
                now: now,
                onRetry: _retry,
                onBusyChanged: _setCampaignBusy,
                onOpenInbox: () =>
                    _selectWorkspace(HostMessagingWorkspace.inbox),
              ),
            );
      return CatchRootScreenScrollView.withPrimaryRail(
        header: CatchRootScreenHeader.custom(
          ChatsBrowseHeader(
            presentation: ChatsBrowsePresentation.host,
            showSearchAction: showSearch,
            searchValue: isInbox ? query : '',
            onSearchChanged: isInbox
                ? ref.read(chatSearchQueryProvider.notifier).setQuery
                : null,
            hostFilter: null,
            hostUnreadCount: 0,
            onHostFilterChanged: null,
            showHostSubtitle: !isInbox,
            subtitle: isInbox ? null : context.l10n.hostSendsSubtitle,
            compactForPrimaryRail: true,
            actions: [
              if (isInbox && selectedClub != null)
                CatchIconAction(
                  tooltip: context.l10n.hostInboxNewMessage,
                  onPressed: () => _newMessage(selectedClub.id),
                  child: Icon(CatchIcons.editOutlined),
                ),
            ],
          ),
        ),
        actions: HostMessagingWorkspaceRail(
          selected: _workspace,
          onChanged: _campaignBusy ? null : _selectWorkspace,
        ),
        body: CatchRootScreenBody.single(
          page: CatchRootScreenPageSpec.scroll(
            page: CatchRootScreenPageScrollView.fullBleed(
              scrollKey: PageStorageKey<String>(
                'host-messaging-${_workspace.name}',
              ),
              children: [workspaceSliver],
            ),
          ),
        ),
      );
    }

    final detail = selectedThreadId == null || selectedClub == null
        ? CatchEmptyState(
            icon: CatchIcons.chatBubbleOutlineRounded,
            title: context.l10n.hostInboxSelectConversationTitle,
            message: context.l10n.hostInboxSelectConversationBody,
          )
        : HostInboxSelectedPerson(
            organizerId: selectedClub.id,
            selection: selectedThreadId,
            scope: _requestedScope,
            now: now,
            segment: _segment,
            drafts: _threadDrafts,
            onBack: _closePerson,
          );

    return CatchScaffold.workspace(
      backgroundColor: t.bg,
      body: isInbox
          ? CatchMasterDetailViewport.adaptive(
              minimumExpandedWidth: CatchLayout.hostMessagingSplitViewMinWidth,
              leadingBuilder: (context, split) =>
                  !split && selectedThreadId != null
                  ? detail
                  : buildMaster(context, split),
              body: detail,
            )
          : CatchMasterDetailViewport(
              expanded: false,
              leading: buildMaster(context, false),
              body: detail,
            ),
    );
  }

  void _selectWorkspace(HostMessagingWorkspace workspace) {
    if (_campaignBusy || workspace == _workspace) return;
    if (workspace == HostMessagingWorkspace.campaigns) {
      ref.read(chatSearchQueryProvider.notifier).clear();
    }
    setState(() {
      _workspace = workspace;
      _selectedThreadId = null;
    });
    if (!widget.syncSelectionToRoute) return;
    context.goNamed(
      Routes.hostInboxScreen.name,
      queryParameters: _routeQuery(workspace: workspace),
    );
  }

  void _setCampaignBusy(bool value) {
    if (!mounted || _campaignBusy == value) return;
    setState(() => _campaignBusy = value);
  }

  void _retry(String? organizerId) {
    final uid = catchAsyncStateFromAsyncValue(ref.read(uidProvider)).value;
    ref.invalidate(uidProvider);
    ref.invalidate(chatsListViewModelProvider);
    if (uid != null) {
      ref.invalidate(hostOperableClubsProvider(uid));
      ref.invalidate(hostInboxCatchPagesProvider(uid));
    }
    if (_requestedScope?.eventId case final eventId?) {
      ref.invalidate(watchEventParticipationsForEventProvider(eventId));
    }
    if (organizerId != null) {
      ref.invalidate(watchEventsForClubProvider(organizerId));
      ref.invalidate(hostMessagingSetupProvider(organizerId));
    }
    setState(() {});
  }

  void _selectScope(HostInboxScope scope) {
    setState(() {
      _requestedScope = scope;
      _segment = HostInboxAudienceSegment.booked;
      _selectedThreadId = null;
    });
    if (!widget.syncSelectionToRoute) return;
    context.goNamed(
      Routes.hostInboxScreen.name,
      queryParameters: _routeQuery(scope: scope),
    );
  }

  void _selectSegment(HostInboxAudienceSegment segment) {
    if (segment == _segment) return;
    setState(() {
      _segment = segment;
      _selectedThreadId = null;
    });
    if (!widget.syncSelectionToRoute) return;
    context.goNamed(
      Routes.hostInboxScreen.name,
      queryParameters: _routeQuery(),
    );
  }

  void _openPerson(HostInboxPerson person) {
    setState(() {
      _selectedThreadId = person.personId;
      _requestedScope = person.scope;
    });
    if (widget.syncSelectionToRoute) {
      context.goNamed(
        Routes.hostInboxScreen.name,
        queryParameters: _routeQuery(
          organizerId: person.organizerId,
          threadId: person.personId,
        ),
      );
    }
  }

  void _closePerson() {
    setState(() => _selectedThreadId = null);
    if (widget.syncSelectionToRoute) {
      context.goNamed(
        Routes.hostInboxScreen.name,
        queryParameters: _routeQuery(),
      );
    }
  }

  Future<void> _newMessage(String organizerId) async {
    final selection = await Navigator.of(context).push<HostNewMessageSelection>(
      MaterialPageRoute(
        builder: (_) => HostNewMessageScreen(organizerId: organizerId),
      ),
    );
    if (!mounted || selection == null) return;
    ref.invalidate(chatsListViewModelProvider);
    setState(() {
      _requestedScope = selection.scope;
      _selectedThreadId = selection.endpointId;
    });
    if (widget.syncSelectionToRoute) {
      context.goNamed(
        Routes.hostInboxScreen.name,
        queryParameters: _routeQuery(
          organizerId: organizerId,
          threadId: selection.endpointId,
        ),
      );
    }
  }

  Map<String, String> _routeQuery({
    HostInboxScope? scope,
    HostMessagingWorkspace? workspace,
    String? organizerId,
    String? threadId,
  }) {
    final effectiveScope = scope ?? _requestedScope;
    final effectiveWorkspace = workspace ?? _workspace;
    return {
      if (effectiveWorkspace != HostMessagingWorkspace.inbox)
        'workspace': effectiveWorkspace.name,
      if (effectiveScope?.isGeneral == true) 'scope': 'general',
      'segment': _segment.name,
      'eventId': ?effectiveScope?.eventId,
      if (organizerId != null && organizerId.isNotEmpty)
        'organizerId': organizerId,
      if (threadId != null && threadId.isNotEmpty) 'threadId': threadId,
    };
  }

  bool get _broadcastEnabled => widget.broadcastEnabled ?? true;
}

class _HostInboxWorkspaceGroup extends ConsumerWidget {
  const _HostInboxWorkspaceGroup({
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
          HostInboxAudienceRail(
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
        HostInboxWorkspaceSliver(
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

class _HostCampaignWorkspaceSliver extends StatelessWidget {
  const _HostCampaignWorkspaceSliver({
    required this.uidState,
    required this.uid,
    required this.clubsState,
    required this.selectedClub,
    required this.initialSavedAudienceId,
    required this.preferredEventId,
    required this.initialSegment,
    required this.broadcastEnabled,
    required this.now,
    required this.onRetry,
    required this.onBusyChanged,
    required this.onOpenInbox,
  });

  final CatchAsyncState<String?> uidState;
  final String? uid;
  final CatchAsyncState<List<Club>> clubsState;
  final Club? selectedClub;
  final String? initialSavedAudienceId;
  final String? preferredEventId;
  final HostInboxAudienceSegment initialSegment;
  final bool broadcastEnabled;
  final DateTime now;
  final ValueChanged<String?> onRetry;
  final ValueChanged<bool> onBusyChanged;
  final VoidCallback onOpenInbox;

  @override
  Widget build(BuildContext context) {
    if (uidState.hasError || clubsState.hasError) {
      final failed = uidState.hasError ? uidState : clubsState;
      return CatchLocalizedSliverErrorState(
        failed.error!,
        context: AppErrorContext.club,
        onRetry: () => onRetry(selectedClub?.id),
      );
    }
    if (uidState.isLoading) return const ChatsListSkeleton();
    if (uid == null) return const _HostAuthRequiredSliver();
    if (clubsState.isLoading) return const ChatsListSkeleton();
    final club = selectedClub;
    if (club == null) return const _HostNoOrganizerSliver();
    return HostSendsWorkspaceSliver(
      club: club,
      initialSavedAudienceId: initialSavedAudienceId,
      preferredEventId: preferredEventId,
      initialSegment: initialSegment,
      broadcastEnabled: broadcastEnabled,
      now: now,
      onBusyChanged: onBusyChanged,
      onOpenInbox: onOpenInbox,
    );
  }
}

class _HostNoOrganizerSliver extends StatelessWidget {
  const _HostNoOrganizerSliver();

  @override
  Widget build(BuildContext context) => CatchStateViewport.sliver(
    child: CatchEmptyState(
      icon: CatchIcons.groupsOutlined,
      title: context.l10n.hostsHostEventsScaffoldTitleCreateYourFirstClub,
      message: context.l10n.hostsHostEventsScaffoldBodyCreateAClubTo,
    ),
  );
}

class _HostAuthRequiredSliver extends StatelessWidget {
  const _HostAuthRequiredSliver();

  @override
  Widget build(BuildContext context) => CatchStateViewport.sliver(
    child: CatchEmptyState(
      icon: CatchIcons.lockOutlineRounded,
      title: context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
      message: context.l10n.hostsHostAuthRequiredScreenMessageSignInToManage,
      actions: [
        CatchButton(
          label: context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
          onPressed: () => context.go(Routes.authScreen.path),
        ),
      ],
    ),
  );
}

class HostMessagingWorkspaceRail extends StatelessWidget
    implements CatchPrimaryRail, CatchScaledPreferredSize {
  const HostMessagingWorkspaceRail({
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

class HostInboxAudienceRail extends StatelessWidget {
  const HostInboxAudienceRail({
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

class HostInboxWorkspaceSliver extends StatelessWidget {
  const HostInboxWorkspaceSliver({
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
      findChildIndexCallback: (key) {
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
