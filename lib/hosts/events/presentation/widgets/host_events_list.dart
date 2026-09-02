import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
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

class HostEventsClubSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hasScheduleRegion =
        state.activeSections.isNotEmpty ||
        state.activeLoadMoreError != null ||
        state.hasMoreActive;
    return CatchRootScreenScaffold.standard(
      scrollKey: const ValueKey<String>('host-events-scroll-view'),
      header: CatchScreenHeaderTitle.block(
        title: context.l10n.hostsHostEventsListTextEvents,
        actions: [
          CatchTopBarPrimaryAction(
            key: const ValueKey<String>('host-events-create-event'),
            label: context.l10n.hostsHostEventsListLabelNewEvent,
            icon: CatchIcons.addRounded,
            onPressed: () => _showEventEntrySheet(context),
          ),
        ],
      ),
      slivers: [
        switch (state.status) {
          HostEventsWorkspaceStatus.loading => const SliverToBoxAdapter(
            child: CatchSkeletonRows(
              leading: CatchSkeletonRowLeading.mediaTile,
              count: 4,
            ),
          ),
          HostEventsWorkspaceStatus.error => CatchSliverErrorState.fromError(
            state.error!,
            context: AppErrorContext.event,
            onRetry: onRetryEvents,
          ),
          HostEventsWorkspaceStatus.empty => CatchSliverEmptyState(
            icon: CatchIcons.eventBusy,
            title: state.emptyTitle(context.l10n),
            message: state.emptyBody(context.l10n),
            action: CatchButton(
              label: context.l10n.hostsHostEventsListLabelNewEvent,
              size: CatchButtonSize.sm,
              onPressed: () => _showEventEntrySheet(context),
            ),
          ),
          HostEventsWorkspaceStatus.populated => SliverList.list(
            children: [
              if (state.activeSections.isNotEmpty) ...[
                Padding(
                  padding: CatchInsets.hostEventFirstSectionLabel,
                  child: Text(
                    context.l10n.hostEventsTimelineSchedule.toUpperCase(),
                    style: CatchTextStyles.monoLabel(
                      context,
                      color: CatchTokens.of(context).ink3,
                    ),
                  ),
                ),
                for (final section in state.activeSections) ...[
                  Padding(
                    padding: CatchInsets.hostEventSectionLabel,
                    child: Text(
                      section.label.toUpperCase(),
                      style: CatchTextStyles.monoLabel(
                        context,
                        color: CatchTokens.of(context).ink3,
                      ),
                    ),
                  ),
                  for (final row in section.rows) ...[
                    HostEventLifecycleRow(
                      key: ValueKey<String>('host-event-row-${row.event.id}'),
                      data: row,
                      onPressed: () => onManageEvent(club, row.event),
                    ),
                    gapH10,
                  ],
                ],
              ],
              if (state.activeLoadMoreError != null)
                CatchInlineErrorState.fromError(
                  state.activeLoadMoreError!,
                  context: AppErrorContext.event,
                  onRetry: onLoadMoreActive,
                )
              else if (state.hasMoreActive)
                Align(
                  child: CatchButton(
                    key: const ValueKey('host-events-load-more-active'),
                    label: context.l10n.hostEventsTimelineLoadMoreSchedule,
                    variant: CatchButtonVariant.secondary,
                    size: CatchButtonSize.sm,
                    isLoading: state.loadingMoreActive,
                    onPressed: state.canLoadMoreActive
                        ? onLoadMoreActive
                        : null,
                  ),
                ),
              if (state.pastSections.isNotEmpty) ...[
                if (hasScheduleRegion) gapH24,
                Padding(
                  padding: hasScheduleRegion
                      ? CatchInsets.hostEventSectionLabel
                      : CatchInsets.hostEventFirstSectionLabel,
                  child: Text(
                    context.l10n.hostEventsTimelineHistory.toUpperCase(),
                    style: CatchTextStyles.monoLabel(
                      context,
                      color: CatchTokens.of(context).ink3,
                    ),
                  ),
                ),
                for (
                  var sectionIndex = 0;
                  sectionIndex < state.pastSections.length;
                  sectionIndex += 1
                )
                  CatchSection.fieldRows(
                    key: ValueKey<String>(
                      'host-events-month-${state.pastSections[sectionIndex].key}',
                    ),
                    title: state.pastSections[sectionIndex].label,
                    first: sectionIndex == 0,
                    children: [
                      for (final row in state.pastSections[sectionIndex].rows)
                        CatchField.nav(
                          key: ValueKey<String>(
                            'host-event-field-${row.event.id}',
                          ),
                          leading: HostEventLifecycleDateBlock(
                            data: row,
                            accent: ActivityPalette.resolve(
                              context,
                              row.event.activityKind,
                            ).accent,
                          ),
                          leadingExtent: CatchSpacing.s12,
                          title: row.event.title,
                          body: row.metaLabel,
                          emphasis: CatchFieldEmphasis.title,
                          bodyMaxLines: 1,
                          onTap: () => onManageEvent(club, row.event),
                        ),
                    ],
                  ),
              ],
              if (state.pastError != null)
                CatchInlineErrorState.fromError(
                  state.pastError!,
                  context: AppErrorContext.event,
                  onRetry: onRetryPast,
                )
              else if (state.hasMorePast)
                Align(
                  child: CatchButton(
                    key: const ValueKey('host-events-load-more-past'),
                    label: context.l10n.hostEventsTimelineLoadMoreHistory,
                    variant: CatchButtonVariant.secondary,
                    size: CatchButtonSize.sm,
                    isLoading: state.loadingMorePast,
                    onPressed: state.canLoadMorePast ? onLoadMorePast : null,
                  ),
                ),
            ],
          ),
        },
      ],
    );
  }

  Future<void> _showEventEntrySheet(BuildContext context) async {
    final intent = await showHostEventEntrySheet(
      context: context,
      state: entryState,
    );
    if (intent == null || !context.mounted) return;
    onEventEntrySelected(club, entryState, intent);
  }
}

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
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, data.event.activityKind);

    return CatchSurface(
      borderColor: t.line,
      radius: CatchRadius.md,
      clipBehavior: Clip.antiAlias,
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: CatchSpacing.s1,
                child: ColoredBox(color: activity.accent),
              ),
              Padding(
                padding: CatchInsets.hostEventLifecycleDate,
                child: HostEventLifecycleDateBlock(
                  data: data,
                  accent: activity.accent,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: CatchInsets.contentVertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.name(context, color: t.ink),
                      ),
                      gapH4,
                      Text(
                        data.metaLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.monoLabelS(
                          context,
                          color: t.ink3,
                        ),
                      ),
                      if (!data.isPast) ...[
                        gapH8,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(CatchRadius.pill),
                          child: SizedBox(
                            height: CatchSpacing.s1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ColoredBox(color: t.line2),
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: data.fillRatio,
                                  child: ColoredBox(color: activity.accent),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: CatchInsets.inlineHorizontalRelaxed,
                child: Icon(
                  CatchIcons.chevronRightRounded,
                  color: t.ink3,
                  size: CatchIcon.sm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HostEventLifecycleDateBlock extends StatelessWidget {
  const HostEventLifecycleDateBlock({
    super.key,
    required this.data,
    required this.accent,
  });

  final HostEventLifecycleRowData data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final semanticLabel = data.isLive || data.isToday
        ? (data.isLive
              ? context.l10n.hostsHostEventsListTextLive
              : context.l10n.hostsHostEventsListTextToday)
        : '${data.dateLabel} ${data.monthLabel}';
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: CatchSpacing.s12,
        child: data.isLive || data.isToday
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CatchIcons.eventLive, color: accent, size: CatchIcon.sm),
                  gapH3,
                  Text(
                    data.isLive
                        ? context.l10n.hostsHostEventsListTextLive
                        : context.l10n.hostsHostEventsListTextToday,
                    style: CatchTextStyles.monoLabelS(context, color: t.ink3),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.dateLabel,
                    style: CatchTextStyles.titleL(
                      context,
                      color: data.isPast ? t.ink3 : t.ink,
                    ),
                  ),
                  gapH3,
                  Text(
                    data.monthLabel,
                    style: CatchTextStyles.monoLabelS(context, color: t.ink3),
                  ),
                ],
              ),
      ),
    );
  }
}
