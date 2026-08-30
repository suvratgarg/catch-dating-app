import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/chats.dart' show ChatScreen;
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chat_conversations_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_empty_state.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_sliver_header.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/responsive/breakpoints.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_master_detail_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_sends_workspace.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_whatsapp_thread_sheet.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
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
  String? _selectedThreadId;

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
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final now = widget.now ?? DateTime.now();
    final uidAsync = ref.watch(uidProvider);
    final uidState = catchAsyncStateFromAsyncValue(uidAsync);
    final uid = uidState.value;
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
            onRetry: _retry,
            onScopeChanged: _selectScope,
            onSegmentChanged: (segment) => setState(() => _segment = segment),
            onThreadSelected: _openThread,
          )
        : _HostCampaignWorkspaceSliver(
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
            onOpenInbox: () => _selectWorkspace(HostMessagingWorkspace.inbox),
          );
    final inbox = isInbox
        ? catchAsyncStateFromAsyncValue(
            ref.watch(chatsListViewModelProvider),
          ).value
        : null;
    final selectedThreadCount = selectedClub == null || inbox == null
        ? 0
        : [
            ...inbox.newMatches,
            ...inbox.conversations,
          ].where((preview) => preview.match.clubId == selectedClub.id).length;
    final showSearch =
        isInbox && (selectedThreadCount > 0 || query.trim().isNotEmpty);
    final screenSize = ScreenSize.fromWidth(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: t.bg,
      body: CatchMasterDetailLayout(
        expanded: screenSize.isExpanded && isInbox,
        master: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ChatsBrowseHeader(
                  presentation: ChatsBrowsePresentation.host,
                  showSearchAction: showSearch,
                  searchValue: isInbox ? query : '',
                  onSearchChanged: isInbox
                      ? ref.read(chatSearchQueryProvider.notifier).setQuery
                      : null,
                  hostFilter: null,
                  hostUnreadCount: 0,
                  onHostFilterChanged: null,
                  subtitle: isInbox
                      ? context.l10n.hostInboxSubtitle
                      : context.l10n.hostSendsSubtitle,
                ),
              ),
              HostMessagingWorkspaceRail(
                selected: _workspace,
                onChanged: _campaignBusy ? null : _selectWorkspace,
              ),
              workspaceSliver,
              const CatchSliverTerminalPadding(),
            ],
          ),
        ),
        detail: _selectedThreadId == null
            ? CatchEmptyState(
                icon: CatchIcons.chatBubbleOutlineRounded,
                title: context.l10n.hostInboxSelectConversationTitle,
                message: context.l10n.hostInboxSelectConversationBody,
              )
            : ChatScreen(matchId: _selectedThreadId!, embedded: true),
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
  }

  void _setCampaignBusy(bool value) {
    if (!mounted || _campaignBusy == value) return;
    setState(() => _campaignBusy = value);
  }

  void _retry(String? organizerId) {
    ref.invalidate(uidProvider);
    ref.invalidate(chatsListViewModelProvider);
    final uid = ref.read(uidProvider).asData?.value;
    if (uid != null) ref.invalidate(hostOperableClubsProvider(uid));
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

  void _openThread(ChatThreadPreview preview) {
    if (ScreenSize.fromWidth(MediaQuery.sizeOf(context).width).isExpanded) {
      setState(() => _selectedThreadId = preview.matchId);
      if (widget.syncSelectionToRoute) {
        context.goNamed(
          Routes.hostInboxScreen.name,
          queryParameters: _routeQuery(
            organizerId: preview.match.clubId,
            threadId: preview.matchId,
          ),
        );
      }
      return;
    }
    context.goNamed(
      Routes.hostChatScreen.name,
      pathParameters: {'matchId': preview.matchId},
    );
  }

  Map<String, String> _routeQuery({
    HostInboxScope? scope,
    String? organizerId,
    String? threadId,
  }) {
    final effectiveScope = scope ?? _requestedScope;
    return {
      if (_workspace != HostMessagingWorkspace.inbox)
        'workspace': _workspace.name,
      if (effectiveScope?.isGeneral == true) 'scope': 'general',
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
    required this.onRetry,
    required this.onScopeChanged,
    required this.onSegmentChanged,
    required this.onThreadSelected,
  });

  final CatchAsyncState<String?> uidState;
  final String? uid;
  final CatchAsyncState<List<Club>> clubsState;
  final Club? selectedClub;
  final String query;
  final DateTime now;
  final HostInboxScope? requestedScope;
  final HostInboxAudienceSegment selectedSegment;
  final ValueChanged<String?> onRetry;
  final ValueChanged<HostInboxScope> onScopeChanged;
  final ValueChanged<HostInboxAudienceSegment> onSegmentChanged;
  final ChatThreadSelectedCallback onThreadSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (uidState.hasError || clubsState.hasError) {
      final failed = uidState.hasError ? uidState : clubsState;
      return CatchSliverErrorState.fromError(
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
    final inboxAsync = ref.watch(chatsListViewModelProvider);
    final whatsappAsync = ref.watch(hostWhatsappThreadsProvider(club.id));
    final eventsState = catchAsyncStateFromAsyncValue(eventsAsync);
    final inboxState = catchAsyncStateFromAsyncValue(inboxAsync);
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
    final asyncStates = <CatchAsyncState<dynamic>>[
      eventsState,
      inboxState,
      catchAsyncStateFromAsyncValue(participationsAsync),
    ];
    final failed = asyncStates.where((value) => value.hasError).firstOrNull;
    if (failed != null) {
      return CatchSliverErrorState.fromError(
        failed.error!,
        context: AppErrorContext.chat,
        onRetry: () => onRetry(club.id),
      );
    }
    final loading = asyncStates.any((value) => value.isLoading);
    final inbox = inboxState.value;
    final participations = asyncStates[2].value as List<EventParticipation>?;
    final whatsappPage = whatsappState.value;
    final workspace = events == null || inbox == null || participations == null
        ? null
        : HostInboxViewModel.compose(
            events: events,
            inbox: inbox,
            participations: participations,
            selectedOrganizerId: club.id,
            selectedScope: scope,
            selectedSegment: selectedSegment,
            query: query,
            now: now,
          );
    if (loading || workspace == null) {
      return const ChatsListSkeleton();
    }
    final normalizedQuery = query.trim().toLowerCase();
    final whatsappThreads = (whatsappPage?.threads ?? const [])
        .where((thread) {
          final inScope = scope.isGeneral
              ? thread.eventIds.isEmpty
              : selectedSegment == HostInboxAudienceSegment.booked &&
                    thread.eventIds.contains(scope.eventId);
          if (!inScope) return false;
          return normalizedQuery.isEmpty ||
              thread.displayName.toLowerCase().contains(normalizedQuery) ||
              thread.lastMessageBody.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
    return SliverMainAxisGroup(
      slivers: [
        if (workspace.scopeOptions.length > 1)
          HostInboxScopeSelector(
            workspace: workspace,
            now: now,
            onChanged: onScopeChanged,
          ),
        if (!workspace.isGeneral)
          HostInboxAudienceRail(
            workspace: workspace,
            onChanged: onSegmentChanged,
          ),
        HostInboxWorkspaceSliver(
          workspace: workspace,
          whatsappThreads: whatsappThreads,
          now: now,
          onThreadSelected: onThreadSelected,
          onWhatsappSelected: (thread) => showCatchBottomSheet<void>(
            context: context,
            builder: (_) => HostWhatsappThreadSheet(
              organizerId: club.id,
              threadId: thread.threadId,
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
      return CatchSliverErrorState.fromError(
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
  Widget build(BuildContext context) => CatchSliverStateViewport(
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
  Widget build(BuildContext context) => CatchSliverStateViewport(
    child: CatchEmptyState(
      icon: CatchIcons.lockOutlineRounded,
      title: context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
      message: context.l10n.hostsHostAuthRequiredScreenMessageSignInToManage,
      action: CatchButton(
        label: context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
        onPressed: () => context.go(Routes.authScreen.path),
      ),
    ),
  );
}

class HostMessagingWorkspaceRail extends StatelessWidget {
  const HostMessagingWorkspaceRail({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HostMessagingWorkspace selected;
  final ValueChanged<HostMessagingWorkspace>? onChanged;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: CatchInsets.pageHorizontal.copyWith(bottom: CatchSpacing.s2),
      child: CatchOptionGroup<HostMessagingWorkspace>(
        key: const ValueKey<String>('host-messaging-workspace-rail'),
        contractExemption:
            'Host Messaging workspaces are local presentation state.',
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
      ),
    ),
  );
}

class HostInboxScopeSelector extends StatefulWidget {
  const HostInboxScopeSelector({
    super.key,
    required this.workspace,
    required this.now,
    required this.onChanged,
  });

  final HostInboxViewModel workspace;
  final DateTime now;
  final ValueChanged<HostInboxScope> onChanged;

  @override
  State<HostInboxScopeSelector> createState() => _HostInboxScopeSelectorState();
}

class _HostInboxScopeSelectorState extends State<HostInboxScopeSelector> {
  final _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final eventsById = {
      for (final event in widget.workspace.events) event.id: event,
    };
    final selectedScope = widget.workspace.selectedScope;
    final selectedEvent = selectedScope.eventId == null
        ? null
        : eventsById[selectedScope.eventId];
    final selectedLabel = _scopeTriggerLabel(selectedScope, selectedEvent);
    final labelColor = selectedEvent == null
        ? t.ink2
        : ActivityPalette.resolve(context, selectedEvent.activityKind).deep;

    return SliverToBoxAdapter(
      child: Padding(
        padding: CatchInsets.pageHorizontal,
        child: CatchMenuAnchor<HostInboxScope>(
          controller: _menuController,
          alignmentOffset: const Offset(0, CatchSpacing.s1),
          items: [
            for (final scope in widget.workspace.scopeOptions)
              CatchMenuItem<HostInboxScope>(
                value: scope,
                label: _scopeMenuLabel(scope, eventsById),
                selected: scope == selectedScope,
                role: CatchMenuItemRole.choice,
              ),
          ],
          onSelected: (scope, _) {
            widget.onChanged(scope);
            _menuController.close();
          },
          builder: (context, controller, child) => Semantics(
            button: true,
            label: context.l10n.hostsHostInboxScreenLabelInboxScope,
            value: selectedLabel,
            hint: context.l10n.hostsHostInboxScreenVisiblecopySelectAnEventOr,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () =>
                    controller.isOpen ? controller.close() : controller.open(),
                child: SizedBox(
                  height: CatchLayout.hostInboxScopeSelectorHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      selectedLabel.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.monoLabel(
                        context,
                        color: labelColor,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _scopeTriggerLabel(HostInboxScope scope, Event? event) {
    if (scope.isGeneral) {
      return context.l10n.hostsHostInboxScreenVisiblecopyGeneralInquiries;
    }
    if (event == null) {
      return context.l10n.hostsHostInboxScreenVisiblecopyEventInquiry;
    }
    final eventName = context.l10n
        .hostsHostInboxScreenVisiblecopyLongweekdayEventtitlelabel(
          longWeekday: AppTimeFormatters.longWeekday(event.startTime),
          eventTitleLabel: event.eventFormat.eventTitleLabel,
        );
    final timing = DateUtils.isSameDay(event.startTime, widget.now)
        ? context.l10n.hostsHostInboxScreenVisiblecopyTonightTime(
            time: AppTimeFormatters.time(event.startTime),
          )
        : context.l10n.hostsHostInboxScreenVisiblecopyShortdatelabelTime(
            shortDateLabel: event.shortDateLabel,
            time: AppTimeFormatters.time(event.startTime),
          );
    return context.l10n.hostsHostInboxScreenVisiblecopyEventnameTiming(
      eventName: eventName,
      timing: timing,
    );
  }

  String _scopeMenuLabel(HostInboxScope scope, Map<String, Event> eventsById) {
    if (scope.isGeneral) {
      return context.l10n.hostsHostInboxScreenVisiblecopyGeneralInquiries;
    }
    final event = eventsById[scope.eventId];
    if (event == null) {
      return context.l10n.hostsHostInboxScreenVisiblecopyEventInquiry;
    }
    return context.l10n
        .hostsHostInboxScreenVisiblecopyTitleShortdatelabelCompacttimerangelabel(
          title: event.title,
          shortDateLabel: event.shortDateLabel,
          compactTimeRangeLabel: event.compactTimeRangeLabel,
        );
  }
}

class HostInboxAudienceRail extends StatelessWidget {
  const HostInboxAudienceRail({
    super.key,
    required this.workspace,
    required this.onChanged,
  });

  final HostInboxViewModel workspace;
  final ValueChanged<HostInboxAudienceSegment> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: CatchInsets.pageHorizontal,
        child: CatchOptionGroup<HostInboxAudienceSegment>(
          contract:
              CatchContractConstraints.mobileFormStateHostInboxAudienceSegment,
          contractValue: (segment) => segment.name,
          selected: workspace.selectedSegment,
          options: [
            CatchOption(
              value: HostInboxAudienceSegment.booked,
              label: context.l10n
                  .hostsHostInboxScreenLabelBookedBookedthreadcount(
                    bookedThreadCount: workspace.bookedThreadCount,
                  ),
            ),
            CatchOption(
              value: HostInboxAudienceSegment.prospective,
              label: context.l10n
                  .hostsHostInboxScreenLabelProspectiveProspectivethreadcount(
                    prospectiveThreadCount: workspace.prospectiveThreadCount,
                  ),
            ),
          ],
          variant: CatchOptionGroupVariant.mono,
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
    this.whatsappThreads = const [],
    required this.now,
    required this.onThreadSelected,
    this.onWhatsappSelected,
  });

  final HostInboxViewModel workspace;
  final List<HostWhatsappThreadSummary> whatsappThreads;
  final DateTime now;
  final ChatThreadSelectedCallback onThreadSelected;
  final ValueChanged<HostWhatsappThreadSummary>? onWhatsappSelected;

  @override
  Widget build(BuildContext context) {
    final rowsByMatchId = {
      for (final row in workspace.threads) row.preview.matchId: row,
    };

    return SliverMainAxisGroup(
      slivers: [
        if (workspace.threads.isNotEmpty)
          ChatConversationsList(
            matches: workspace.threads
                .map((row) => row.preview)
                .toList(growable: false),
            now: now,
            timestampTextFor: (preview) =>
                AppTimeFormatters.compactRelativeTime(
                  preview.timestamp,
                  now: now,
                ),
            previewTextFor: (preview) {
              final row = rowsByMatchId[preview.matchId];
              return row == null
                  ? preview.previewText
                  : context.l10n.hostInboxCatchChatPreview(
                      details: row.supportingText,
                    );
            },
            onThreadSelected: onThreadSelected,
          ),
        if (whatsappThreads.isNotEmpty)
          SliverPadding(
            padding: CatchInsets.pageBody.copyWith(top: CatchSpacing.s2),
            sliver: SliverList.list(
              children: [
                for (final thread in whatsappThreads) ...[
                  HostWhatsappThreadRow(
                    thread: thread,
                    onTap: () => onWhatsappSelected?.call(thread),
                  ),
                  gapH8,
                ],
              ],
            ),
          ),
        if (workspace.threads.isEmpty && whatsappThreads.isEmpty)
          CatchSliverStateViewport(
            child: workspace.query.isNotEmpty && workspace.hasUnfilteredThreads
                ? const ChatsEmptyState.noHostSearchResults()
                : workspace.isGeneral
                ? HostInboxEmptyState(
                    title: context
                        .l10n
                        .hostsHostInboxScreenTitleNoGeneralInquiries,
                    message: context
                        .l10n
                        .hostsHostInboxScreenMessageQuestionsThatAreNot,
                  )
                : HostInboxEmptyState(
                    title: context.l10n
                        .hostsHostInboxScreenTitleNoValue1HaveWritten(
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
                    message: context
                        .l10n
                        .hostsHostInboxScreenMessagePersonalQuestionsAppearHere,
                  ),
          ),
      ],
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
