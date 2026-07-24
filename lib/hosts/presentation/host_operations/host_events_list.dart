part of '../host_operations_screen.dart';

class HostEventsClubCard extends ConsumerWidget {
  const HostEventsClubCard({
    super.key,
    required this.club,
    required this.currentUid,
    required this.clubs,
    required this.showClubPicker,
    required this.selectedFilter,
    required this.onSwitchClubIndex,
    required this.onFilterChanged,
    required this.onCreateEvent,
    required this.onRepeatEvent,
    required this.onManageEvent,
    required this.now,
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final HostEventsLifecycleFilter selectedFilter;
  final ValueChanged<int> onSwitchClubIndex;
  final ValueChanged<HostEventsLifecycleFilter> onFilterChanged;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeRepeatEventCallback onRepeatEvent;
  final HostHomeManageEventCallback onManageEvent;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final workspaceState = buildHostEventsWorkspaceState(
      eventsAsync,
      now: now,
      selectedFilter: selectedFilter,
    );

    return HostEventsClubSection(
      club: club,
      currentUid: currentUid,
      clubs: clubs,
      showClubPicker: showClubPicker,
      state: workspaceState,
      onSwitchClubIndex: onSwitchClubIndex,
      onFilterChanged: onFilterChanged,
      onRetryEvents: () => ref.invalidate(watchEventsForClubProvider(club.id)),
      onCreateEvent: onCreateEvent,
      onRepeatEvent: onRepeatEvent,
      onManageEvent: onManageEvent,
    );
  }
}

class HostEventsClubSection extends StatelessWidget {
  const HostEventsClubSection({
    super.key,
    required this.club,
    required this.currentUid,
    required this.clubs,
    required this.showClubPicker,
    required this.state,
    required this.onSwitchClubIndex,
    required this.onFilterChanged,
    required this.onCreateEvent,
    required this.onRepeatEvent,
    required this.onManageEvent,
    this.onRetryEvents,
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final HostEventsWorkspaceState state;
  final ValueChanged<int> onSwitchClubIndex;
  final ValueChanged<HostEventsLifecycleFilter> onFilterChanged;
  final VoidCallback? onRetryEvents;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeRepeatEventCallback onRepeatEvent;
  final HostHomeManageEventCallback onManageEvent;

  @override
  Widget build(BuildContext context) {
    final repeatSource = state.repeatSource;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: CatchScreenHeaderTitle.block(
            title: context.l10n.hostsHostEventsListTextEvents,
            actions: [
              if (showClubPicker)
                HostTodayClubPill(
                  club: club,
                  currentUid: currentUid,
                  clubs: clubs,
                  showClubPicker: true,
                  onSwitchClubIndex: onSwitchClubIndex,
                ),
            ],
          ),
        ),
        SliverPadding(
          padding: CatchInsets.pageHorizontal,
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                gapH4,
                Row(
                  children: [
                    Expanded(
                      child: CatchButton(
                        label: context.l10n.hostsHostEventsListLabelNewEvent,
                        icon: Icon(CatchIcons.addRounded, size: CatchIcon.sm),
                        onPressed: () => onCreateEvent(club),
                      ),
                    ),
                    gapW10,
                    Expanded(
                      child: CatchButton(
                        label: state.repeatLabel(context.l10n),
                        variant: CatchButtonVariant.secondary,
                        icon: Icon(CatchIcons.refresh, size: CatchIcon.sm),
                        onPressed: repeatSource == null
                            ? null
                            : () => onRepeatEvent(club, repeatSource),
                      ),
                    ),
                  ],
                ),
                gapH16,
                CatchOptionGroup<HostEventsLifecycleFilter>(
                  contract: CatchContractConstraints
                      .mobileFormStateHostEventsLifecycleFilter,
                  contractValue: (filter) => filter.name,
                  selected: state.selectedFilter,
                  onChanged: onFilterChanged,
                  options: [
                    for (final filter in HostEventsLifecycleFilter.values)
                      CatchOption(value: filter, label: filter.label),
                  ],
                ),
                gapH14,
              ],
            ),
          ),
        ),
        switch (state.status) {
          HostEventsWorkspaceStatus.loading => const SliverPadding(
            padding: CatchInsets.pageHorizontal,
            sliver: SliverToBoxAdapter(
              child: CatchSkeletonRows(
                leading: CatchSkeletonRowLeading.mediaTile,
                count: 4,
              ),
            ),
          ),
          HostEventsWorkspaceStatus.error => SliverPadding(
            padding: CatchInsets.pageHorizontal,
            sliver: SliverToBoxAdapter(
              child: CatchInlineErrorState.fromError(
                state.error!,
                context: AppErrorContext.event,
                onRetry: onRetryEvents,
              ),
            ),
          ),
          HostEventsWorkspaceStatus.empty => CatchSliverEmptyState(
            icon: CatchIcons.eventBusy,
            title: state.emptyTitle(context.l10n),
            message: state.emptyBody(context.l10n),
            action: state.selectedFilter == HostEventsLifecycleFilter.upcoming
                ? CatchButton(
                    label: context.l10n.hostsHostEventsListLabelNewEvent,
                    size: CatchButtonSize.sm,
                    onPressed: () => onCreateEvent(club),
                  )
                : null,
          ),
          HostEventsWorkspaceStatus.populated => SliverPadding(
            padding: CatchInsets.pageHorizontal,
            sliver: SliverList.list(
              children: [
                for (
                  var sectionIndex = 0;
                  sectionIndex < state.sections.length;
                  sectionIndex += 1
                )
                  if (state.selectedFilter == HostEventsLifecycleFilter.past)
                    CatchSection.fieldRows(
                      key: ValueKey<String>(
                        'host-events-month-${state.sections[sectionIndex].key}',
                      ),
                      title: state.sections[sectionIndex].label,
                      first: sectionIndex == 0,
                      children: [
                        for (final row in state.sections[sectionIndex].rows)
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
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: CatchSpacing.s1,
                        bottom: CatchSpacing.micro10,
                      ),
                      child: Text(
                        state.sections[sectionIndex].label.toUpperCase(),
                        style: CatchTextStyles.monoLabel(
                          context,
                          color: CatchTokens.of(context).ink3,
                        ),
                      ),
                    ),
                    for (final row in state.sections[sectionIndex].rows) ...[
                      HostEventLifecycleRow(
                        data: row,
                        onPressed: () => onManageEvent(club, row.event),
                      ),
                      gapH10,
                    ],
                  ],
              ],
            ),
          ),
        },
        const CatchSliverTerminalPadding(),
      ],
    );
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
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s3,
                  CatchSpacing.s3,
                  CatchSpacing.micro14,
                  CatchSpacing.s3,
                ),
                child: HostEventLifecycleDateBlock(
                  data: data,
                  accent: activity.accent,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: CatchSpacing.s3,
                  ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchSpacing.s3,
                ),
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
