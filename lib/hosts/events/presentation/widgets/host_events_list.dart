import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_record_row.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_sheet.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_events_state.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_events_timeline_controller.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_events_view_model.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostEventsClubCard extends ConsumerWidget {
  const HostEventsClubCard({
    super.key,
    required this.club,
    required this.onEventEntrySelected,
    required this.onManageEvent,
    required this.now,
    required this.sessionBoundary,
  });

  final Club club;
  final HostEventEntryCallback onEventEntrySelected;
  final HostEventsManageEventCallback onManageEvent;
  final DateTime now;
  final DateTime sessionBoundary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = HostEventsTimelineRequest(
      organizerId: club.id,
      sessionBoundary: sessionBoundary,
    );
    final timelineAsync = ref.watch(
      hostEventsTimelineControllerProvider(request),
    );
    final eventsAsync = timelineAsync.whenData(
      (timeline) => timeline.allEvents,
    );
    final eventsState = catchAsyncStateFromAsyncValue(eventsAsync);
    final timeline = catchAsyncStateFromAsyncValue(timelineAsync).value;
    final workspaceState = buildHostEventsWorkspaceState(
      eventsState,
      now: now,
      hasMoreActive: timeline?.hasMoreActive ?? false,
      hasMorePast: timeline?.hasMorePast ?? false,
      loadingMoreActive: timeline?.loadingMoreActive ?? false,
      loadingMorePast: timeline?.loadingMorePast ?? false,
      activeLoadMoreError: timeline?.activeLoadMoreError,
      pastError: timeline?.pastError,
      pastStackTrace: timeline?.pastStackTrace,
    );
    final draftsAsync = ref.watch(clubEventDraftsProvider(clubId: club.id));
    final drafts = switch (draftsAsync) {
      AsyncData<List<EventDraft>>(:final value) => value,
      _ => const <EventDraft>[],
    };
    final entryState = HostEventEntryState.resolve(
      organizerId: club.id,
      drafts: drafts,
      repeatSource: workspaceState.repeatSource,
    );

    void onRetryEvents() =>
        ref.invalidate(hostEventsTimelineControllerProvider(request));
    return HostEventsClubSection(
      club: club,
      state: workspaceState,
      entryState: entryState,
      onRetryEvents: onRetryEvents,
      onLoadMoreActive: () => ref
          .read(hostEventsTimelineControllerProvider(request).notifier)
          .loadMoreActive(),
      onLoadMorePast: () => ref
          .read(hostEventsTimelineControllerProvider(request).notifier)
          .loadMorePast(),
      onRetryPast: () => ref
          .read(hostEventsTimelineControllerProvider(request).notifier)
          .retryPast(),
      onEventEntrySelected: onEventEntrySelected,
      onManageEvent: onManageEvent,
    );
  }
}

class HostEventsClubSection extends StatefulWidget {
  const HostEventsClubSection({
    super.key,
    required this.club,
    required this.state,
    required this.entryState,
    required this.onLoadMoreActive,
    required this.onLoadMorePast,
    required this.onRetryPast,
    required this.onEventEntrySelected,
    required this.onManageEvent,
    this.onRetryEvents,
  });

  final Club club;
  final HostEventsWorkspaceState state;
  final HostEventEntryState entryState;
  final VoidCallback? onRetryEvents;
  final VoidCallback onLoadMoreActive;
  final VoidCallback onLoadMorePast;
  final VoidCallback onRetryPast;
  final HostEventEntryCallback onEventEntrySelected;
  final HostEventsManageEventCallback onManageEvent;

  @override
  State<HostEventsClubSection> createState() => _HostEventsClubSectionState();
}

class _HostEventsClubSectionState extends State<HostEventsClubSection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: HostEventsView.values.length, vsync: this);
  }

  @override
  void didUpdateWidget(HostEventsClubSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) _tabs.index = 0;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold.withPrimaryRail(
      scrollKey: const ValueKey<String>('host-events-scroll-view'),
      header: CatchRootScreenHeader.title(
        title: context.l10n.hostsHostEventsListTextEvents,
        actions: [
          CatchTopBarPrimaryAction(
            key: const ValueKey<String>('host-events-create-event'),
            label: context.l10n.hostsHostEventsListLabelNewEvent,
            icon: CatchIcons.addRounded,
            onPressed: _showEventEntrySheet,
          ),
        ],
      ),
      primaryRail: CatchTabControllerRail<HostEventsView>(
        controller: _tabs,
        groupKey: const ValueKey('host-events-tabs'),
        options: [
          CatchOption(
            value: HostEventsView.upcoming,
            label: context.l10n.hostEventsUpcomingTab,
          ),
          CatchOption(
            value: HostEventsView.past,
            label: context.l10n.hostEventsPastTab,
          ),
        ],
      ),
      body: CatchRootScreenBody.paged(
        controller: _tabs,
        pages: [
          for (final view in HostEventsView.values)
            CatchRootScreenPageSpec.scroll(
              page: HostEventsTimelinePage(
                key: ValueKey('host-events-${widget.club.id}-${view.name}'),
                organizerId: widget.club.id,
                view: view,
                state: widget.state,
                onRetryEvents: widget.onRetryEvents,
                onLoadMore: view == HostEventsView.upcoming
                    ? widget.onLoadMoreActive
                    : widget.onLoadMorePast,
                onRetryPage: view == HostEventsView.upcoming
                    ? widget.onLoadMoreActive
                    : widget.onRetryPast,
                onCreateEvent: _showEventEntrySheet,
                onManageEvent: (event) =>
                    widget.onManageEvent(widget.club, event),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showEventEntrySheet() async {
    final intent = await showHostEventEntrySheet(
      context: context,
      state: widget.entryState,
    );
    if (intent == null || !mounted) return;
    widget.onEventEntrySelected(widget.club, widget.entryState, intent);
  }
}

/// One lifecycle page. The root owns tabs and scrolling chrome; this adapter
/// selects data/state only, and the shared page/section/record owners lay it out.
class HostEventsTimelinePage extends StatelessWidget
    implements CatchRootScreenPageOwner {
  const HostEventsTimelinePage({
    super.key,
    required this.organizerId,
    required this.view,
    required this.state,
    required this.onLoadMore,
    required this.onRetryPage,
    required this.onCreateEvent,
    required this.onManageEvent,
    this.onRetryEvents,
  });

  final String organizerId;
  final HostEventsView view;
  final HostEventsWorkspaceState state;
  final VoidCallback onLoadMore;
  final VoidCallback onRetryPage;
  final VoidCallback onCreateEvent;
  final ValueChanged<Event> onManageEvent;
  final VoidCallback? onRetryEvents;

  @override
  Widget build(BuildContext context) {
    final upcoming = view == HostEventsView.upcoming;
    final sections = upcoming ? state.activeSections : state.pastSections;
    final pageError = upcoming ? state.activeLoadMoreError : state.pastError;
    final hasMore = upcoming ? state.hasMoreActive : state.hasMorePast;
    final loadingMore = upcoming
        ? state.loadingMoreActive
        : state.loadingMorePast;
    return CatchRootScreenPageScrollView.standard(
      scrollKey: PageStorageKey('host-events-$organizerId-${view.name}'),
      slivers: [
        if (state.status == HostEventsWorkspaceStatus.loading ||
            (sections.isEmpty && loadingMore))
          const SliverToBoxAdapter(child: CatchSkeletonRows(count: 4))
        else if (state.status == HostEventsWorkspaceStatus.error)
          CatchSliverErrorState.fromError(
            state.error!,
            context: AppErrorContext.event,
            onRetry: onRetryEvents,
          )
        else if (sections.isEmpty && pageError != null)
          CatchSliverErrorState.fromError(
            pageError,
            context: AppErrorContext.event,
            onRetry: onRetryPage,
          )
        else if (sections.isEmpty && !hasMore)
          CatchSliverEmptyState(
            icon: CatchIcons.eventBusy,
            title: upcoming
                ? state.emptyTitle(context.l10n)
                : context.l10n.hostEventsPastEmptyTitle,
            message: upcoming
                ? state.emptyBody(context.l10n)
                : context.l10n.hostEventsPastEmptyBody,
            action: upcoming
                ? CatchButton(
                    label: context.l10n.hostsHostEventsListLabelNewEvent,
                    onPressed: onCreateEvent,
                  )
                : null,
          )
        else
          SliverToBoxAdapter(
            child: CatchSectionList(
              emptyStateOmitted: true,
              children: [
                for (final section in sections)
                  CatchSection.plain(
                    key: ValueKey(
                      'host-events-${section.grouping.name}-${section.key}',
                    ),
                    title: section.label(context.l10n),
                    titleColor: CatchTokens.of(context).ink2,
                    children: [
                      for (final row in section.rows)
                        HostEventLifecycleRow(
                          key: ValueKey('host-event-row-${row.event.id}'),
                          data: row,
                          onPressed: () => onManageEvent(row.event),
                        ),
                    ],
                  ),
                if (pageError != null)
                  CatchInlineErrorState.fromError(
                    pageError,
                    context: AppErrorContext.event,
                    onRetry: onRetryPage,
                  )
                else if (hasMore)
                  Align(
                    child: CatchButton(
                      key: ValueKey(
                        upcoming
                            ? 'host-events-load-more-active'
                            : 'host-events-load-more-past',
                      ),
                      label: upcoming
                          ? context.l10n.hostEventsTimelineLoadMoreSchedule
                          : context.l10n.hostEventsTimelineLoadMoreHistory,
                      variant: CatchButtonVariant.secondary,
                      isLoading: loadingMore,
                      onPressed: loadingMore ? null : onLoadMore,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Host lifecycle semantics over the canonical record row. Both tabs use this
/// adapter; it cannot choose its own padding, typography or interaction shape.
class HostEventLifecycleRow extends StatelessWidget {
  const HostEventLifecycleRow({
    super.key,
    required this.data,
    required this.onPressed,
  });

  final HostEventLifecycleRowData data;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, data.event.activityKind);
    return CatchRecordRow(
      title: data.event.title,
      icon: activity.glyph,
      color: activity.accent,
      facts: data.facts(
        context.l10n,
        time: MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay.fromDateTime(data.event.startTime),
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        ),
      ),
      onTap: onPressed,
    );
  }
}
