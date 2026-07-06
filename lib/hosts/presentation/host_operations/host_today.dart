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
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final ValueChanged<int> onSwitchClubIndex;
  final VoidCallback onViewEvents;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final dashboardState = buildHostHomeTodayDashboardState(eventsAsync);

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
  final VoidCallback? onRetryEvents;

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
            title: 'No active events yet',
            body:
                'Create an event for ${club.name} to start filling the host dashboard.',
            actions: [
              CatchButton(
                label: 'New event',
                icon: Icon(CatchIcons.addRounded, size: CatchIcon.sm),
                onPressed: () => onCreateEvent(club),
              ),
              CatchButton(
                label: 'Events',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostTodayEventHero(
          event: event,
          onPressed: () => onManageEvent(club, event),
        ),
        gapH24,
        CatchSection.plain(
          title: 'Needs you',
          count: tasks.length,
          titleColor: CatchTokens.of(context).ink3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final task in tasks) ...[
                HostTodayTaskCard(task: task, onPrimary: () {}),
                gapH12,
              ],
            ],
          ),
        ),
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
  });

  final Club club;
  final String currentUid;
  final List<Club> clubs;
  final bool showClubPicker;
  final ValueChanged<int> onSwitchClubIndex;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hostName = _hostFirstName(club, currentUid);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TUESDAY EVENING',
                style: CatchTextStyles.kicker(context, color: t.ink3),
              ),
              gapH8,
              Text(
                'Good evening,\n$hostName',
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

    return CatchSurface(
      borderColor: t.line2,
      backgroundColor: t.surface,
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.micro6,
        CatchSpacing.micro6,
        CatchSpacing.s3,
        CatchSpacing.micro6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: CatchSpacing.s3,
            backgroundColor: ActivityPalette.resolve(
              context,
              club.hostDefaults.primaryActivityKind,
            ).deep,
            child: Text(
              initials,
              style: CatchTextStyles.badge(context, color: t.darkPillInk),
            ),
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
          if (showClubPicker) ...[
            gapW4,
            CatchTopBarMenuAction<int>(
              tooltip: 'Switch club',
              icon: CatchIcons.expandMoreRounded,
              items: [
                for (var index = 0; index < clubs.length; index++)
                  CatchActionMenuItem(
                    value: index,
                    label:
                        '${clubs[index].name} · '
                        '${clubs[index].isOwnedBy(currentUid) ? 'Owner' : 'Host team'}',
                  ),
              ],
              onSelected: onSwitchClubIndex,
            ),
          ],
        ],
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
    required this.onPressed,
  });

  final Event event;
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
        colors: [activity.accent, activity.deep],
      ),
      padding: CatchInsets.contentRelaxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HostTodayCountdownPill(event: event),
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
                  '${_eventDayLabel(event)} · ${EventFormatters.time(event.startTime)}',
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
                value: '${event.signedUpCount}',
                label: 'Going',
              ),
              gapW20,
              HostTodayHeroMetric(
                value: '${event.waitlistCount}',
                label: 'Waiting',
              ),
              gapW20,
              HostTodayHeroMetric(
                value: '${_reviewCount(event)}',
                label: 'To review',
                valueColor: activity.accent,
              ),
              const Spacer(),
              HostTodayAvatarStack(activity: activity),
            ],
          ),
          gapH20,
          CatchButton(
            label: 'Set up & run',
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

class HostTodayCountdownPill extends StatelessWidget {
  const HostTodayCountdownPill({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: CatchTokens.editorialWhite.withValues(
        alpha: CatchOpacity.darkHeroPillFill,
      ),
      borderWidth: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.micro6,
      ),
      child: Text(
        'STARTS ${_eventStartLeadLabel(event)}',
        style: CatchTextStyles.monoLabel(
          context,
          color: CatchTokens.editorialWhite,
        ),
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
            label: 'D',
          ),
          HostTodayAvatarDot(
            left: CatchSpacing.s10,
            fill: activity.soft,
            label: 'M',
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchButton(
                label: task.primaryActionLabel.toUpperCase(),
                size: CatchButtonSize.sm,
                accentColor: t.danger,
                onPressed: onPrimary,
              ),
              gapW8,
              CatchButton(
                label: task.secondaryActionLabel.toUpperCase(),
                size: CatchButtonSize.sm,
                variant: CatchButtonVariant.secondary,
                onPressed: () {},
              ),
            ],
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

String _eventStartLeadLabel(Event event) {
  final weekday = EventFormatters.longWeekday(event.startTime).toUpperCase();
  final time = EventFormatters.time(event.startTime).toUpperCase();
  return '$weekday · $time';
}

int _reviewCount(Event event) {
  if (event.waitlistCount > 0) {
    return event.waitlistCount > 4 ? 4 : event.waitlistCount;
  }
  final pendingCount = event.signedUpCount - event.attendedCount;
  if (pendingCount <= 0) return 0;
  return pendingCount > 4 ? 4 : pendingCount;
}
