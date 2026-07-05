part of '../host_operations_screen.dart';

class HostEventsClubCard extends ConsumerWidget {
  const HostEventsClubCard({
    super.key,
    required this.club,
    required this.currentUid,
    required this.onCreateEvent,
    required this.onManageEvent,
  });

  final Club club;
  final String currentUid;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final eventsState = buildHostHomeEventsSectionState(eventsAsync);
    final owner = club.isOwnedBy(currentUid);

    return HostEventsClubSection(
      club: club,
      roleLabel: owner ? 'Owner' : 'Host team',
      owner: owner,
      eventsState: eventsState,
      onRetryEvents: () => ref.invalidate(watchEventsForClubProvider(club.id)),
      onCreateEvent: onCreateEvent,
      onManageEvent: onManageEvent,
    );
  }
}

class HostEventsClubSection extends StatelessWidget {
  const HostEventsClubSection({
    super.key,
    required this.club,
    required this.roleLabel,
    required this.owner,
    required this.eventsState,
    required this.onCreateEvent,
    required this.onManageEvent,
    this.onRetryEvents,
  });

  final Club club;
  final String roleLabel;
  final bool owner;
  final HostHomeEventsSectionState eventsState;
  final VoidCallback? onRetryEvents;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostMetaRow(club: club, roleLabel: roleLabel, owner: owner),
        gapH24,
        CatchSection.plain(
          title: 'Upcoming',
          titleColor: t.ink3,
          bodyGap: CatchSpacing.s2,
          child: switch (eventsState.status) {
            HostHomeEventsStatus.loading => const CatchSkeletonRows(
              leading: CatchSkeletonRowLeading.mediaTile,
              count: 2,
              divided: true,
            ),
            HostHomeEventsStatus.error => CatchInlineErrorState.fromError(
              eventsState.error!,
              context: AppErrorContext.event,
              onRetry: onRetryEvents,
            ),
            HostHomeEventsStatus.empty => HostEventRows(
              club: club,
              rows: eventsState.rows,
              emptyTextColor: t.ink2,
              onCreateEvent: onCreateEvent,
              onManageEvent: onManageEvent,
            ),
            HostHomeEventsStatus.populated => HostEventRows(
              club: club,
              rows: eventsState.rows,
              emptyTextColor: t.ink2,
              onCreateEvent: onCreateEvent,
              onManageEvent: onManageEvent,
            ),
          },
        ),
      ],
    );
  }
}

class HostEventRows extends StatelessWidget {
  const HostEventRows({
    super.key,
    required this.club,
    required this.rows,
    required this.emptyTextColor,
    required this.onCreateEvent,
    required this.onManageEvent,
  });

  final Club club;
  final HostHomeEventRowsState rows;
  final Color emptyTextColor;
  final HostHomeCreateEventCallback onCreateEvent;
  final HostHomeManageEventCallback onManageEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows.rows)
          CatchField.nav(
            title: row.title,
            valueText: row.timeRangeLabel,
            icon: CatchIcons.calendarTodayOutlined,
            divider: row.divider,
            onTap: () => onManageEvent(club, row.event),
          ),
        CatchField.nav(
          title: 'Add event',
          icon: CatchIcons.addRounded,
          divider: !rows.isEmpty,
          onTap: () => onCreateEvent(club),
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: CatchSpacing.s2),
            child: Text(
              'No active events yet.',
              style: CatchTextStyles.supporting(context, color: emptyTextColor),
            ),
          ),
      ],
    );
  }
}

class HostMetaRow extends StatelessWidget {
  const HostMetaRow({
    super.key,
    required this.club,
    required this.roleLabel,
    required this.owner,
  });

  final Club club;
  final String roleLabel;
  final bool owner;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final area = [
      if (club.area.trim().isNotEmpty) club.area.trim(),
      if (club.location.trim().isNotEmpty) club.location.trim(),
    ].join(' · ');

    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (area.isNotEmpty)
          Text(
            area.toUpperCase(),
            style: CatchTextStyles.monoLabel(context, color: t.ink3),
          ),
        CatchBadge(
          label: roleLabel,
          tone: owner ? CatchBadgeTone.solid : CatchBadgeTone.neutral,
          uppercase: true,
        ),
        CatchActivityChip(
          activityKind: club.hostDefaults.primaryActivityKind,
          primary: true,
        ),
      ],
    );
  }
}
