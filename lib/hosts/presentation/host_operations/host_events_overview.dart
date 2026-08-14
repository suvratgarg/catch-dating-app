part of '../host_operations_screen.dart';

class HostEventsOverviewSection extends StatelessWidget {
  const HostEventsOverviewSection({
    super.key,
    required this.club,
    required this.state,
    required this.onManageEvent,
    required this.onOpenTask,
    required this.now,
  });

  final Club club;
  final HostEventsOverviewState state;
  final HostHomeManageEventCallback onManageEvent;
  final HostHomeOpenTaskCallback onOpenTask;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    if (state.status != HostEventsOverviewStatus.content) {
      return const SizedBox.shrink();
    }
    return HostEventsOverviewContent(
      state: state,
      club: club,
      now: now,
      onManageEvent: onManageEvent,
      onOpenTask: onOpenTask,
    );
  }
}

class HostEventsOverviewContent extends StatelessWidget {
  const HostEventsOverviewContent({
    super.key,
    required this.state,
    required this.club,
    required this.now,
    required this.onManageEvent,
    required this.onOpenTask,
  });

  final HostEventsOverviewState state;
  final Club club;
  final DateTime now;
  final void Function(Club club, Event event) onManageEvent;
  final HostHomeOpenTaskCallback onOpenTask;

  @override
  Widget build(BuildContext context) {
    final event = state.event!;
    final tasks = state.tasks;
    final heroTaskCount = tasks
        .where((task) => task.event.id == event.id)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostEventOperationalSpotlight(
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
                  style: CatchTextStyles.supporting(context),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final task in tasks) ...[
                      HostEventAttentionCard(
                        task: task,
                        onPrimary: () => onOpenTask(club, task.event, task),
                      ),
                      gapH12,
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class HostEventOperationalSpotlight extends StatelessWidget {
  const HostEventOperationalSpotlight({
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
              HostEventOperationalMetric(
                value: context.l10n.hostsHostTodayVisiblecopySignedupcount(
                  signedUpCount: event.signedUpCount,
                ),
                label: context.l10n.hostsHostTodayLabelGoing,
              ),
              gapW20,
              HostEventOperationalMetric(
                value: context.l10n.hostsHostTodayVisiblecopyWaitlistcount(
                  waitlistCount: event.waitlistCount,
                ),
                label: context.l10n.hostsHostTodayLabelWaiting,
              ),
              gapW20,
              HostEventOperationalMetric(
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

class HostEventOperationalMetric extends StatelessWidget {
  const HostEventOperationalMetric({
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

class HostEventAttentionCard extends StatelessWidget {
  const HostEventAttentionCard({
    super.key,
    required this.task,
    required this.onPrimary,
  });

  final HostEventAttentionData task;
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
          SizedBox(
            width: CatchSpacing.s9,
            height: CatchSpacing.s9,
            child: ColoredBox(
              color: t.primarySoft,
              child: Icon(task.icon, color: t.ink2, size: CatchIcon.md),
            ),
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
  if (!lead.isNegative && lead < hostEventsImminentEventLeadTime) {
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
