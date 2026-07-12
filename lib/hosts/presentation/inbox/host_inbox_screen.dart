import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chats_list_view_model.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chat_conversations_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_empty_state.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_list.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_list_body.dart';
import 'package:catch_dating_app/chats/presentation/inbox/widgets/chats_sliver_header.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_segmented_control.dart';
import 'package:catch_dating_app/events/data/event_callable_responses.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_broadcast_composer_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_broadcast_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_view_model.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostInboxScreen extends ConsumerStatefulWidget {
  const HostInboxScreen({
    super.key,
    this.initialScope,
    this.initialSegment = HostInboxAudienceSegment.booked,
    this.broadcastEnabled,
    this.syncSelectionToRoute = true,
    this.now,
  });

  final HostInboxScope? initialScope;
  final HostInboxAudienceSegment initialSegment;
  final bool? broadcastEnabled;
  final bool syncSelectionToRoute;
  final DateTime? now;

  @override
  ConsumerState<HostInboxScreen> createState() => _HostInboxScreenState();
}

class _HostInboxScreenState extends ConsumerState<HostInboxScreen> {
  HostInboxScope? _requestedScope;
  late HostInboxAudienceSegment _segment;

  @override
  void initState() {
    super.initState();
    _requestedScope = widget.initialScope;
    _segment = widget.initialSegment;
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
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final now = widget.now ?? DateTime.now();
    final uidAsync = ref.watch(uidProvider);
    final uid = uidAsync.asData?.value;
    final clubsAsync = uid == null
        ? const AsyncLoading<List<Club>>()
        : ref.watch(hostOperableClubsProvider(uid));
    final clubs = clubsAsync.asData?.value;
    final eventsAsync = clubs == null
        ? clubsAsync.when(
            data: (_) => const AsyncLoading<List<Event>>(),
            loading: () => const AsyncLoading<List<Event>>(),
            error: AsyncError<List<Event>>.new,
          )
        : ref.watch(
            watchEventsForClubsProvider(
              EventsForClubsQuery(clubs.map((club) => club.id)),
            ),
          );
    final inboxAsync = ref.watch(chatsListViewModelProvider);
    final query = ref.watch(chatSearchQueryProvider);
    final events = eventsAsync.asData?.value;
    final scope = events == null
        ? const HostInboxScope.general()
        : resolveHostInboxScope(
            events: events,
            now: now,
            requestedScope: _requestedScope,
          );
    final eventId = scope.eventId;
    final participationsAsync = eventId == null
        ? const AsyncData<List<EventParticipation>>([])
        : ref.watch(watchEventParticipationsForEventProvider(eventId));
    final asyncValues = <AsyncValue<dynamic>>[
      uidAsync,
      clubsAsync,
      eventsAsync,
      inboxAsync,
      participationsAsync,
    ];
    final failed = asyncValues.where((value) => value.hasError).firstOrNull;
    final loading =
        uid == null ||
        asyncValues.any((value) => value.isLoading || !value.hasValue);
    final inbox = inboxAsync.asData?.value;
    final participations = participationsAsync.asData?.value;
    final workspace = events == null || inbox == null || participations == null
        ? null
        : HostInboxViewModel.compose(
            events: events,
            inbox: inbox,
            participations: participations,
            selectedScope: scope,
            selectedSegment: _segment,
            query: query,
            now: now,
          );
    final showSearch =
        (inbox?.totalThreadCount ?? 0) > 0 || query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ChatsBrowseHeader(
                showSearchAction: showSearch,
                searchValue: query,
                onSearchChanged: ref
                    .read(chatSearchQueryProvider.notifier)
                    .setQuery,
                hostFilter: null,
                hostUnreadCount: 0,
                onHostFilterChanged: null,
                showHostSubtitle: false,
                height: CatchLayout.hostInboxHeaderHeight,
                contentPadding: CatchInsets.hostInboxHeader,
              ),
            ),
            if (failed != null)
              CatchSliverErrorState.fromError(
                failed.error!,
                context: AppErrorContext.chat,
                onRetry: _retry,
              )
            else if (loading || workspace == null)
              const ChatsListSkeleton()
            else ...[
              HostInboxScopeSelector(
                workspace: workspace,
                now: now,
                onChanged: _selectScope,
              ),
              if (!workspace.isGeneral)
                HostInboxAudienceRail(
                  workspace: workspace,
                  onChanged: (segment) => setState(() => _segment = segment),
                ),
              HostInboxWorkspaceSliver(
                workspace: workspace,
                now: now,
                broadcastEnabled: _broadcastEnabled,
                onThreadSelected: _openThread,
                onBroadcastSelected: _openBroadcast,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _retry() {
    ref.invalidate(uidProvider);
    ref.invalidate(chatsListViewModelProvider);
    final uid = ref.read(uidProvider).asData?.value;
    if (uid != null) ref.invalidate(hostOperableClubsProvider(uid));
    setState(() {});
  }

  void _selectScope(HostInboxScope scope) {
    setState(() {
      _requestedScope = scope;
      _segment = HostInboxAudienceSegment.booked;
    });
    if (!widget.syncSelectionToRoute) return;
    context.goNamed(
      Routes.hostInboxScreen.name,
      queryParameters: scope.isGeneral
          ? const {'scope': 'general'}
          : {'eventId': scope.eventId!},
    );
  }

  void _openThread(ChatThreadPreview preview) {
    context.goNamed(
      Routes.hostChatScreen.name,
      pathParameters: {'matchId': preview.matchId},
    );
  }

  void _openBroadcast(HostInboxViewModel workspace) {
    final event = workspace.selectedEvent;
    if (event == null) return;
    HostInboxBroadcastController.reset(ref);
    unawaited(
      showCatchBottomSheet<SendEventBroadcastCallableResponse>(
        context: context,
        builder: (context) => HostBroadcastComposerSheet(
          event: event,
          bookedCount: workspace.bookedAudienceCount,
          prospectiveCount: workspace.prospectiveAudienceCount,
          initialSegment: workspace.selectedSegment,
          sendingEnabled: _broadcastEnabled,
        ),
      ).then((result) {
        if (!mounted || result == null) return;
        final suffix = result.isPartial
            ? context.l10n.hostsHostInboxScreenVisiblecopySomePushAttemptsFailed
            : '';
        showCatchSnackBar(
          context,
          context.l10n
              .hostsHostInboxScreenVisiblecopyBroadcastSentToRecipientcount(
                recipientCount: result.recipientCount,
                suffix: suffix,
              ),
        );
      }),
    );
  }

  bool get _broadcastEnabled =>
      widget.broadcastEnabled ?? AppConfig.enableHostEventBroadcast;
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
        child: LayoutBuilder(
          builder: (context, constraints) => MenuAnchor(
            controller: _menuController,
            alignmentOffset: const Offset(0, CatchSpacing.s1),
            style: const MenuStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              elevation: WidgetStatePropertyAll(0),
              shadowColor: WidgetStatePropertyAll(Colors.transparent),
              surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
              padding: WidgetStatePropertyAll(EdgeInsets.zero),
            ),
            menuChildren: [
              CatchMenu<HostInboxScope>(
                width: constraints.maxWidth,
                items: [
                  for (final scope in widget.workspace.scopeOptions)
                    CatchMenuItem<HostInboxScope>(
                      value: scope,
                      label: _scopeMenuLabel(scope, eventsById),
                      selected: scope == selectedScope,
                    ),
                ],
                onSelected: (scope, _) {
                  widget.onChanged(scope);
                  _menuController.close();
                },
              ),
            ],
            builder: (context, controller, child) => Semantics(
              button: true,
              label: context.l10n.hostsHostInboxScreenLabelInboxScope,
              value: selectedLabel,
              hint: context.l10n.hostsHostInboxScreenVisiblecopySelectAnEventOr,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => controller.isOpen
                      ? controller.close()
                      : controller.open(),
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
      ),
    );
  }

  String _scopeTriggerLabel(HostInboxScope scope, Event? event) {
    if (scope.isGeneral)
      return context.l10n.hostsHostInboxScreenVisiblecopyGeneralInquiries;
    if (event == null)
      return context.l10n.hostsHostInboxScreenVisiblecopyEventInquiry;
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
    if (scope.isGeneral)
      return context.l10n.hostsHostInboxScreenVisiblecopyGeneralInquiries;
    final event = eventsById[scope.eventId];
    if (event == null)
      return context.l10n.hostsHostInboxScreenVisiblecopyEventInquiry;
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
        child: CatchSegmentedControl<HostInboxAudienceSegment>(
          selected: workspace.selectedSegment,
          segments: [
            CatchSegment(
              value: HostInboxAudienceSegment.booked,
              label: context.l10n
                  .hostsHostInboxScreenLabelBookedBookedthreadcount(
                    bookedThreadCount: workspace.bookedThreadCount,
                  ),
            ),
            CatchSegment(
              value: HostInboxAudienceSegment.prospective,
              label: context.l10n
                  .hostsHostInboxScreenLabelProspectiveProspectivethreadcount(
                    prospectiveThreadCount: workspace.prospectiveThreadCount,
                  ),
            ),
          ],
          expanded: true,
          style: CatchSegmentedControlStyle.surface,
          size: CatchSegmentedControlSize.compact,
          labelStyle: CatchSegmentedControlLabelStyle.mono,
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
    required this.now,
    required this.broadcastEnabled,
    required this.onThreadSelected,
    required this.onBroadcastSelected,
  });

  final HostInboxViewModel workspace;
  final DateTime now;
  final bool broadcastEnabled;
  final ChatThreadSelectedCallback onThreadSelected;
  final ValueChanged<HostInboxViewModel> onBroadcastSelected;

  @override
  Widget build(BuildContext context) {
    final event = workspace.selectedEvent;
    final canSend =
        broadcastEnabled &&
        workspace.broadcastLifecycleAvailable &&
        workspace.selectedAudienceCount > 0;
    final rowsByMatchId = {
      for (final row in workspace.threads) row.preview.matchId: row,
    };

    return SliverMainAxisGroup(
      slivers: [
        if (event != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: CatchInsets.pageBody.copyWith(
                top: CatchSpacing.s4,
                bottom: CatchSpacing.s2,
              ),
              child: HostInboxBroadcastCard(
                audienceCount: workspace.selectedAudienceCount,
                audienceLabel: context.l10n
                    .hostsHostInboxScreenVisiblecopyNameAttendee(
                      name: workspace.selectedSegment.name,
                    ),
                subtitle: _broadcastSubtitle,
                onTap: canSend ? () => onBroadcastSelected(workspace) : null,
              ),
            ),
          ),
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
            previewTextFor: (preview) =>
                rowsByMatchId[preview.matchId]?.supportingText ??
                preview.previewText,
            onThreadSelected: onThreadSelected,
          )
        else
          SliverFillRemaining(
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
        const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
      ],
    );
  }

  String get _broadcastSubtitle {
    if (!workspace.broadcastLifecycleAvailable) {
      return 'Broadcasts close when the event ends';
    }
    if (!broadcastEnabled) {
      return 'Available after the production backend preflight';
    }
    if (workspace.selectedAudienceCount == 0) {
      return 'No eligible recipients in this audience yet';
    }
    return 'Reminders, the meeting point, changes';
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
