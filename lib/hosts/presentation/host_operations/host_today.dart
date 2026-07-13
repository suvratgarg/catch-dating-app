part of '../host_operations_screen.dart';

class HostTodayDashboardCard extends ConsumerWidget {
  const HostTodayDashboardCard({
    super.key,
    required this.club,
    required this.currentUid,
    required this.clubs,
    required this.showClubPicker,
    required this.onSwitchClubIndex,
    required this.onViewEvents,
    required this.onCreateEvent,
    required this.onManageEvent,
    required this.onOpenTask,
    this.now,
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final ValueChanged<int> onSwitchClubIndex;
  final VoidCallback onViewEvents;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;
  final HostHomeOpenTaskCallback onOpenTask;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = this.now ?? DateTime.now();
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final dashboardState = buildHostHomeTodayDashboardState(
      eventsAsync,
      now: now,
      l10n: context.l10n,
    );

    return HostTodayDashboardSection(
      club: club,
      currentUid: currentUid,
      clubs: clubs,
      showClubPicker: showClubPicker,
      state: dashboardState,
      onSwitchClubIndex: onSwitchClubIndex,
      onRetryEvents: () => ref.invalidate(watchEventsForClubProvider(club.id)),
      onViewEvents: onViewEvents,
      onCreateEvent: onCreateEvent,
      onManageEvent: onManageEvent,
      onOpenTask: onOpenTask,
      now: now,
    );
  }
}

class HostTodayDashboardSection extends StatelessWidget {
  const HostTodayDashboardSection({
    super.key,
    required this.club,
    required this.currentUid,
    required this.clubs,
    required this.showClubPicker,
    required this.state,
    required this.onSwitchClubIndex,
    required this.onViewEvents,
    required this.onCreateEvent,
    required this.onManageEvent,
    required this.onOpenTask,
    required this.now,
    this.onRetryEvents,
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final HostHomeTodayDashboardState state;
  final ValueChanged<int> onSwitchClubIndex;
  final VoidCallback onViewEvents;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;
  final HostHomeOpenTaskCallback onOpenTask;
  final VoidCallback? onRetryEvents;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostTodayHeader(
          club: club,
          currentUid: currentUid,
          clubs: clubs,
          showClubPicker: showClubPicker,
          onSwitchClubIndex: onSwitchClubIndex,
          now: now,
        ),
        gapH18,
        switch (state.status) {
          HostHomeTodayStatus.loading => const HostTodayLoadingBody(),
          HostHomeTodayStatus.error => CatchInlineErrorState.fromError(
            state.error!,
            context: AppErrorContext.event,
            onRetry: onRetryEvents,
          ),
          HostHomeTodayStatus.empty => HostEmptyActionCard(
            title: context.l10n.hostsHostTodayTitleNoActiveEventsYet,
            body: context.l10n.hostsHostTodayBodyCreateAnEventFor(
              name: club.name,
            ),
            actions: [
              CatchButton(
                label: context.l10n.hostsHostTodayLabelNewEvent,
                icon: Icon(CatchIcons.addRounded, size: CatchIcon.sm),
                onPressed: () => onCreateEvent(club),
              ),
              CatchButton(
                label: context.l10n.hostsHostTodayLabelEvents,
                variant: CatchButtonVariant.secondary,
                size: CatchButtonSize.sm,
                onPressed: onViewEvents,
              ),
            ],
          ),
          HostHomeTodayStatus.content => _buildContent(context),
        },
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final event = state.event!;
    final tasks = state.tasks;
    final heroTaskCount = tasks
        .where((task) => task.event.id == event.id)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostTodayEventHero(
          event: event,
          now: now,
          taskCount: heroTaskCount,
          onPressed: () => onManageEvent(club, event),
        ),
        gapH24,
        CatchSection.plain(
          title: context.l10n.hostsHostTodayTitleNeedsYou,
          count: tasks.isEmpty ? null : tasks.length,
          titleColor: CatchTokens.of(context).ink3,
          child: tasks.isEmpty
              ? Text(
                  context.l10n.hostsHostTodayTextNothingNeedsYouRight,
                  style: CatchTextStyles.bodyM(context),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final task in tasks) ...[
                      HostTodayTaskCard(
                        task: task,
                        onPrimary: () => onOpenTask(club, task.event, task),
                      ),
                      gapH12,
                    ],
                  ],
                ),
        ),
        if (state.laterEvents.isNotEmpty) ...[
          gapH24,
          CatchSection.plain(
            title: context.l10n.hostsHostTodayTitleLaterThisWeek,
            count: state.laterEvents.length,
            titleColor: CatchTokens.of(context).ink3,
            trailing: CatchButton(
              label: context.l10n.hostsHostTodayLabelAllEvents,
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              onPressed: onViewEvents,
            ),
            child: Column(
              children: [
                for (final row in state.laterEvents) ...[
                  HostEventLifecycleRow(
                    data: row,
                    onPressed: () => onManageEvent(club, row.event),
                  ),
                  if (row != state.laterEvents.last) gapH10,
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class HostTodayHeader extends StatelessWidget {
  const HostTodayHeader({
    super.key,
    required this.club,
    required this.currentUid,
    required this.clubs,
    required this.showClubPicker,
    required this.onSwitchClubIndex,
    required this.now,
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final ValueChanged<int> onSwitchClubIndex;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hostName = _hostFirstName(club, currentUid);
    final daypart = switch (now.hour) {
      < 12 => context.l10n.hostsHostTodayVisiblecopyMorning,
      < 17 => context.l10n.hostsHostTodayVisiblecopyAfternoon,
      _ => context.l10n.hostsHostTodayVisiblecopyEvening,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n
                    .hostsHostTodayTextLongweekdayDaypart(
                      longWeekday: EventFormatters.longWeekday(now),
                      daypart: daypart,
                    )
                    .toUpperCase(),
                style: CatchTextStyles.kicker(context, color: t.ink3),
              ),
              gapH8,
              Text(
                context.l10n.hostsHostTodayTextGoodDaypartHostname(
                  daypart: daypart,
                  hostName: hostName,
                ),
                style: CatchTextStyles.headlineS(context, color: t.ink),
              ),
            ],
          ),
        ),
        gapW12,
        HostTodayClubPill(
          club: club,
          currentUid: currentUid,
          clubs: clubs,
          showClubPicker: showClubPicker,
          onSwitchClubIndex: onSwitchClubIndex,
        ),
      ],
    );
  }
}

class HostTodayClubPill extends StatelessWidget {
  const HostTodayClubPill({
    super.key,
    required this.club,
    required this.currentUid,
    required this.clubs,
    required this.showClubPicker,
    required this.onSwitchClubIndex,
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final ValueChanged<int> onSwitchClubIndex;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final initials = _initialsFor(club.name);
    final rawLogoUrl = club.logoPhotoUrl?.trim();
    final logoUrl = rawLogoUrl?.isNotEmpty == true ? rawLogoUrl : null;
    final canSwitch = showClubPicker && clubs.length > 1;
    final selectedClubIndex = clubs.indexWhere(
      (candidate) => candidate.id == club.id,
    );
    final triggerContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchPersonAvatar(
          key: const ValueKey('host-today-club-identity-art'),
          size: CatchSpacing.s6,
          name: club.name,
          initials: initials,
          imageUrl: logoUrl,
          activityKind: club.hostDefaults.primaryActivityKind,
        ),
        gapW8,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 104),
          child: Text(
            club.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ),
        if (canSwitch) ...[
          gapW4,
          Icon(CatchIcons.expandMoreRounded, size: CatchIcon.sm, color: t.ink3),
        ],
      ],
    );

    CatchSurface trigger({VoidCallback? onTap}) => CatchSurface(
      key: const ValueKey('host-today-club-switcher'),
      borderColor: t.line2,
      backgroundColor: t.surface,
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.micro6,
        CatchSpacing.micro6,
        CatchSpacing.s3,
        CatchSpacing.micro6,
      ),
      onTap: onTap,
      child: triggerContent,
    );

    if (!canSwitch) return trigger();

    final tooltip = context.l10n.hostsHostTodayTooltipSwitchClub;
    return MenuAnchor(
      alignmentOffset: const Offset(0, CatchSpacing.s1),
      style: const MenuStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
      menuChildren: [
        for (var index = 0; index < clubs.length; index++)
          Semantics(
            key: ValueKey('host-today-club-option-${clubs[index].id}'),
            selected: index == selectedClubIndex,
            child: MenuItemButton(
              onPressed: () => onSwitchClubIndex(index),
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: CatchSpacing.micro14,
                    vertical: CatchLayout.menuRowVerticalPadding,
                  ),
                ),
              ),
              trailingIcon: index == selectedClubIndex
                  ? Icon(
                      CatchIcons.check,
                      size: CatchLayout.menuRowCheckSize,
                      color: t.ink,
                    )
                  : const SizedBox(width: CatchLayout.menuRowCheckSize),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: CatchLayout.actionMenuWidth - CatchSpacing.s16,
                  maxWidth: CatchLayout.actionMenuWidth - CatchSpacing.s16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clubs[index].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.labelL(context, color: t.ink),
                    ),
                    gapH2,
                    Text(
                      clubs[index].isOwnedBy(currentUid)
                          ? context.l10n.hostsHostTodayLabelOwner
                          : context.l10n.hostsHostTodayLabelHostTeam,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.monoLabel(
                        context,
                        color: t.ink3,
                      ).copyWith(fontSize: CatchLayout.menuRowSublabelSize),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
      builder: (context, controller, child) => Tooltip(
        message: tooltip,
        child: Semantics(
          label: tooltip,
          value: club.name,
          button: true,
          child: trigger(
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
        ),
      ),
    );
  }
}

class HostTodayLoadingBody extends StatelessWidget {
  const HostTodayLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        HostSummarySkeleton(),
        gapH14,
        CatchSkeletonRows(
          leading: CatchSkeletonRowLeading.mediaTile,
          divided: true,
        ),
      ],
    );
  }
}

class HostTodayEventHero extends StatelessWidget {
  const HostTodayEventHero({
    super.key,
    required this.event,
    required this.now,
    required this.taskCount,
    required this.onPressed,
  });

  final Event event;
  final DateTime now;
  final int taskCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, event.activityKind);

    return CatchSurface(
      borderRadius: BorderRadius.circular(CatchRadius.lg),
      clipBehavior: Clip.antiAlias,
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [activity.deep, CatchTokens.editorialBlack],
      ),
      padding: CatchInsets.contentRelaxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchBadge.onDark(label: _eventStartLeadLabel(event, now)),
          gapH16,
          Text(
            _todayEventHeroTitle(event),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.headlineS(
              context,
              color: CatchTokens.editorialWhite,
            ),
          ),
          gapH14,
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.hostsHostTodayTextEventdaylabelTime(
                    eventDayLabel: _eventDayLabel(event),
                    time: EventFormatters.time(event.startTime),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.editorialWhite.withValues(
                      alpha: CatchOpacity.onDarkMuted,
                    ),
                  ),
                ),
              ),
              gapW12,
              Expanded(
                child: Text(
                  event.locationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.editorialWhite.withValues(
                      alpha: CatchOpacity.onDarkMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          gapH16,
          Divider(
            height: CatchStroke.hairline,
            color: CatchTokens.editorialWhite.withValues(
              alpha: CatchOpacity.darkHeroDivider,
            ),
          ),
          gapH14,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              HostTodayHeroMetric(
                value: context.l10n.hostsHostTodayVisiblecopySignedupcount(
                  signedUpCount: event.signedUpCount,
                ),
                label: context.l10n.hostsHostTodayLabelGoing,
              ),
              gapW20,
              HostTodayHeroMetric(
                value: context.l10n.hostsHostTodayVisiblecopyWaitlistcount(
                  waitlistCount: event.waitlistCount,
                ),
                label: context.l10n.hostsHostTodayLabelWaiting,
              ),
              gapW20,
              HostTodayHeroMetric(
                value: context.l10n.hostsHostTodayVisiblecopyTaskcount(
                  taskCount: taskCount,
                ),
                label: context.l10n.hostsHostTodayLabelNeedsYou,
                valueColor: activity.accent,
              ),
              const Spacer(),
            ],
          ),
          gapH20,
          CatchButton(
            label: !event.startTime.isAfter(now) && event.endTime.isAfter(now)
                ? context.l10n.hostsHostTodayLabelOpenRunOfShow
                : context.l10n.hostsHostTodayLabelSetUpRun,
            fullWidth: true,
            backgroundColor: activity.accent,
            foregroundColor: CatchTokens.editorialWhite,
            borderColor: Colors.transparent,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class HostTodayHeroMetric extends StatelessWidget {
  const HostTodayHeroMetric({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: CatchTextStyles.titleL(
            context,
            color: valueColor ?? CatchTokens.editorialWhite,
          ),
        ),
        gapH2,
        Text(
          label,
          style: CatchTextStyles.monoLabel(
            context,
            color: CatchTokens.editorialWhite.withValues(
              alpha: CatchOpacity.onDarkMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class HostTodayAvatarStack extends StatelessWidget {
  const HostTodayAvatarStack({super.key, required this.activity});

  final CatchActivity activity;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: CatchSpacing.s16,
      height: CatchSpacing.s7,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          HostTodayAvatarDot(
            left: CatchSpacing.s0,
            fill: activity.deep,
            label: '',
          ),
          HostTodayAvatarDot(
            left: CatchSpacing.s5,
            fill: t.surface,
            label: context.l10n.hostsHostTodayLabelD,
          ),
          HostTodayAvatarDot(
            left: CatchSpacing.s10,
            fill: activity.soft,
            label: context.l10n.hostsHostTodayLabelM,
          ),
        ],
      ),
    );
  }
}

class HostTodayAvatarDot extends StatelessWidget {
  const HostTodayAvatarDot({
    super.key,
    required this.left,
    required this.fill,
    required this.label,
  });

  final double left;
  final Color fill;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: CatchSpacing.s3,
        backgroundColor: CatchTokens.editorialBlack.withValues(
          alpha: CatchOpacity.avatarStackRing,
        ),
        child: CircleAvatar(
          radius: CatchSpacing.micro10,
          backgroundColor: fill,
          child: label.isEmpty
              ? null
              : Text(
                  label,
                  style: CatchTextStyles.badge(context, color: t.ink2),
                ),
        ),
      ),
    );
  }
}

class HostTodayTaskCard extends StatelessWidget {
  const HostTodayTaskCard({
    super.key,
    required this.task,
    required this.onPrimary,
  });

  final HostHomeTodayTaskData task;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      backgroundColor: t.surface,
      padding: CatchInsets.content,
      onTap: onPrimary,
      child: Row(
        children: [
          Container(
            width: CatchSpacing.s9,
            height: CatchSpacing.s9,
            decoration: BoxDecoration(
              color: t.primarySoft,
              borderRadius: BorderRadius.circular(CatchRadius.sm),
            ),
            child: Icon(task.icon, color: t.ink2, size: CatchIcon.md),
          ),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.fieldRowTitle(context, color: t.ink),
                ),
                gapH4,
                Text(
                  task.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
          gapW12,
          CatchButton(
            label: task.primaryActionLabel.toUpperCase(),
            size: CatchButtonSize.sm,
            accentColor: t.danger,
            onPressed: onPrimary,
          ),
        ],
      ),
    );
  }
}

String _hostFirstName(Club club, String currentUid) {
  final hostProfile = club.hostProfiles
      .where((profile) => profile.uid == currentUid)
      .firstOrNull;
  final fallbackName = hostProfile?.displayName.trim().isNotEmpty == true
      ? hostProfile!.displayName
      : club.hostName ?? '';
  final parts = fallbackName.trim().split(RegExp(r'\s+'));
  return parts.firstWhere((part) => part.isNotEmpty, orElse: () => 'Host');
}

String _initialsFor(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  final initials = parts
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part.characters.first.toUpperCase())
      .join();
  return initials.isEmpty ? 'CH' : initials;
}

String _eventDayLabel(Event event) {
  if (event.startTime.hour >= 17) return 'Tonight';
  return EventFormatters.longWeekday(event.startTime);
}

String _todayEventHeroTitle(Event event) {
  final weekday = EventFormatters.longWeekday(event.startTime);
  final period = event.startTime.hour < 12
      ? 'Morning'
      : event.startTime.hour < 17
      ? 'Afternoon'
      : 'Evening';
  final prefix = '$weekday $period ';
  if (event.title.startsWith(prefix)) {
    return '$weekday ${event.title.substring(prefix.length)}';
  }
  return event.title;
}

String _eventStartLeadLabel(Event event, DateTime now) {
  if (!event.startTime.isAfter(now) && event.endTime.isAfter(now)) {
    return 'LIVE NOW';
  }

  final lead = event.startTime.difference(now);
  if (!lead.isNegative && lead < const Duration(hours: 1)) {
    final minutes = lead.inMinutes.clamp(1, 59);
    return 'STARTS IN $minutes MIN';
  }
  if (DateUtils.isSameDay(event.startTime, now) && !lead.isNegative) {
    final hours = lead.inHours;
    final minutes = lead.inMinutes.remainder(60);
    return minutes == 0
        ? 'STARTS IN ${hours}H'
        : 'STARTS IN ${hours}H ${minutes}M';
  }

  final tomorrow = DateUtils.dateOnly(now).add(const Duration(days: 1));
  final prefix = DateUtils.isSameDay(event.startTime, tomorrow)
      ? 'TOMORROW'
      : EventFormatters.shortWeekday(event.startTime).toUpperCase();
  return 'STARTS $prefix · ${EventFormatters.time(event.startTime).toUpperCase()}';
}
