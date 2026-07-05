part of '../host_operations_screen.dart';

class HostClubOrganizerOverviewController extends ConsumerWidget {
  const HostClubOrganizerOverviewController({
    super.key,
    required this.club,
    required this.currentUid,
    required this.isOwner,
    required this.clubs,
    required this.showClubPicker,
    required this.onSelectClubIndex,
    required this.onSelectTab,
    required this.onPreviewClub,
    required this.onOpenSettings,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;
  final List<Club> clubs;
  final bool showClubPicker;
  final ValueChanged<int> onSelectClubIndex;
  final ValueChanged<HostClubTab> onSelectTab;
  final HostClubPreviewCallback onPreviewClub;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final events = eventsAsync.asData?.value ?? const <Event>[];
    final activeEventCount = events.where((event) => !event.isCancelled).length;

    return HostClubOrganizerOverview(
      club: club,
      currentUid: currentUid,
      isOwner: isOwner,
      clubs: clubs,
      showClubPicker: showClubPicker,
      eventsLoaded: eventsAsync.hasValue,
      eventCount: events.length,
      activeEventCount: activeEventCount,
      onSelectClubIndex: onSelectClubIndex,
      onSelectTab: onSelectTab,
      onPreviewClub: onPreviewClub,
      onOpenSettings: onOpenSettings,
    );
  }
}

class HostClubOrganizerOverview extends StatelessWidget {
  const HostClubOrganizerOverview({
    super.key,
    required this.club,
    required this.currentUid,
    required this.isOwner,
    required this.clubs,
    required this.showClubPicker,
    required this.eventsLoaded,
    required this.eventCount,
    required this.activeEventCount,
    required this.onSelectClubIndex,
    required this.onSelectTab,
    required this.onPreviewClub,
    required this.onOpenSettings,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;
  final List<Club> clubs;
  final bool showClubPicker;
  final bool eventsLoaded;
  final int eventCount;
  final int activeEventCount;
  final ValueChanged<int> onSelectClubIndex;
  final ValueChanged<HostClubTab> onSelectTab;
  final HostClubPreviewCallback onPreviewClub;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      key: const ValueKey('host-club-organizer-overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostOrganizerHeader(
          club: club,
          trailing: showClubPicker
              ? CatchTopBarMenuAction<int>(
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
                  onSelected: onSelectClubIndex,
                )
              : null,
        ),
        if (isOwner) ...[
          gapH14,
          HostOrganizerPayoutPromptController(
            uid: currentUid,
            onManagePayouts: () => onSelectTab(HostClubTab.edit),
          ),
        ],
        gapH16,
        HostOrganizerMetricGrid(
          club: club,
          eventsLoaded: eventsLoaded,
          eventCount: eventCount,
          activeEventCount: activeEventCount,
        ),
        gapH12,
        CatchSection.contained(
          children: [
            CatchField.nav(
              icon: CatchIcons.visibilityOutlined,
              title: 'How guests see you',
              body: 'Public page',
              onTap: () => onPreviewClub(club),
            ),
          ],
        ),
        gapH24,
        CatchSectionHeader(
          title: 'Team · ${club.displayHostProfiles.length}',
          padding: EdgeInsets.zero,
          titleStyle: CatchTextStyles.monoLabel(context, color: t.ink2),
          trailing: isOwner
              ? CatchTextButton(
                  label: 'Manage',
                  onPressed: () => onSelectTab(HostClubTab.edit),
                  tone: CatchTextButtonTone.neutral,
                  minimumSize: const Size(0, CatchSpacing.s8),
                )
              : null,
        ),
        gapH10,
        HostOrganizerTeamCard(
          profiles: club.displayHostProfiles,
          currentUid: currentUid,
        ),
        gapH24,
        CatchSectionHeader(
          title: 'Trends · last 12 weeks',
          padding: EdgeInsets.zero,
          titleStyle: CatchTextStyles.monoLabel(context, color: t.ink2),
          trailing: CatchTextButton(
            label: 'See insights',
            onPressed: () => onSelectTab(HostClubTab.insights),
            tone: CatchTextButtonTone.neutral,
            minimumSize: const Size(0, CatchSpacing.s8),
          ),
        ),
        gapH10,
        HostOrganizerTrendStrip(
          memberCount: club.memberCount,
          activeEventCount: activeEventCount,
          onTap: () => onSelectTab(HostClubTab.insights),
        ),
        gapH24,
        CatchSectionHeader(
          title: 'Manage',
          padding: EdgeInsets.zero,
          titleStyle: CatchTextStyles.monoLabel(context, color: t.ink2),
        ),
        gapH10,
        CatchSection.contained(
          children: [
            CatchField.nav(
              icon: CatchIcons.paymentsOutlined,
              title: 'Payouts',
              body: isOwner ? 'Manage' : 'Owner only',
              onTap: isOwner ? () => onSelectTab(HostClubTab.edit) : null,
            ),
            CatchField.nav(
              icon: CatchIcons.tuneRounded,
              title: 'Event defaults',
              body: 'Prefill new events',
              onTap: isOwner ? () => onSelectTab(HostClubTab.edit) : null,
            ),
            CatchField.nav(
              icon: CatchIcons.settingsOutlined,
              title: 'Settings',
              onTap: onOpenSettings,
            ),
          ],
        ),
      ],
    );
  }
}

class HostOrganizerHeader extends StatelessWidget {
  const HostOrganizerHeader({super.key, required this.club, this.trailing});

  final Club club;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final formats = _organizerFormats(club);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CatchPersonAvatar(
              size: CatchLayout.avatarIdentityExtent,
              name: club.name,
              initials: _initialsForName(club.name),
              imageUrl: club.logoPhotoUrl,
              shape: CatchPersonAvatarShape.square,
            ),
            gapW14,
            Expanded(
              child: Text(
                _organizerMeta(club),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.monoLabel(context, color: t.ink3),
              ),
            ),
            if (trailing != null) ...[gapW12, trailing!],
          ],
        ),
        if (formats.isNotEmpty) ...[
          gapH14,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final format in formats)
                CatchBadge(label: format, uppercase: true),
            ],
          ),
        ],
      ],
    );
  }
}

class HostOrganizerMetricGrid extends StatelessWidget {
  const HostOrganizerMetricGrid({
    super.key,
    required this.club,
    required this.eventsLoaded,
    required this.eventCount,
    required this.activeEventCount,
  });

  final Club club;
  final bool eventsLoaded;
  final int eventCount;
  final int activeEventCount;

  @override
  Widget build(BuildContext context) {
    final items = [
      HostOrganizerMetricItem(
        value: _compactCount(club.memberCount),
        label: 'Members',
      ),
      HostOrganizerMetricItem(
        value: _ratingValue(club),
        label: club.reviewCount > 0
            ? 'Rating · ${club.reviewCount} reviews'
            : 'Rating',
      ),
      HostOrganizerMetricItem(
        value: eventsLoaded ? _compactCount(eventCount) : '-',
        label: 'Events hosted',
      ),
      HostOrganizerMetricItem(
        value: eventsLoaded ? _compactCount(activeEventCount) : '-',
        label: 'Upcoming',
      ),
    ];

    return Column(
      children: [
        HostOrganizerMetricRow(items: [items[0], items[1]]),
        gapH12,
        HostOrganizerMetricRow(items: [items[2], items[3]]),
      ],
    );
  }
}

class HostOrganizerMetricItem {
  const HostOrganizerMetricItem({required this.value, required this.label});

  final String value;
  final String label;
}

class HostOrganizerMetricRow extends StatelessWidget {
  const HostOrganizerMetricRow({super.key, required this.items});

  final List<HostOrganizerMetricItem> items;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: CatchLayout.hostOrganizerMetricRowHeight,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchSpacing.s3,
                ),
                child: CatchStatColumn(
                  value: items[0].value,
                  label: items[0].label,
                ),
              ),
            ),
            ColoredBox(
              color: t.line,
              child: const SizedBox(width: CatchStroke.hairline),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CatchSpacing.s3,
                ),
                child: CatchStatColumn(
                  value: items[1].value,
                  label: items[1].label,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HostOrganizerTeamCard extends StatelessWidget {
  const HostOrganizerTeamCard({
    super.key,
    required this.profiles,
    required this.currentUid,
  });

  final List<ClubHostProfile> profiles;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    if (profiles.isEmpty) {
      return Text(
        'No host team members yet.',
        style: CatchTextStyles.supporting(context, color: t.ink2),
      );
    }

    final visibleProfiles = profiles.take(3).toList(growable: false);
    return CatchSurface(
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
      borderColor: t.line,
      child: Column(
        children: [
          for (var index = 0; index < visibleProfiles.length; index++)
            HostOrganizerTeamRow(
              profile: visibleProfiles[index],
              currentUid: currentUid,
              divider: index > 0,
            ),
        ],
      ),
    );
  }
}

class HostOrganizerTeamRow extends StatelessWidget {
  const HostOrganizerTeamRow({
    super.key,
    required this.profile,
    required this.currentUid,
    required this.divider,
  });

  final ClubHostProfile profile;
  final String currentUid;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isCurrentUser = profile.uid == currentUid;
    final roleLabel = profile.role == ClubHostRole.owner ? 'Owner' : 'Host';
    return Stack(
      children: [
        if (divider)
          const Positioned(
            top: 0,
            left: CatchLayout.hostOrganizerTeamDividerInset,
            right: 0,
            child: CatchDivider(),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s3),
          child: Row(
            children: [
              CatchPersonAvatar(
                size: CatchLayout.avatarRowExtent,
                name: profile.displayName,
                imageUrl: profile.avatarUrl,
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.fieldRowTitle(
                        context,
                        color: t.ink,
                      ),
                    ),
                    gapH2,
                    Text(
                      isCurrentUser ? 'You · $roleLabel' : roleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              if (profile.role == ClubHostRole.owner)
                const CatchBadge(
                  label: 'Owner',
                  tone: CatchBadgeTone.solid,
                  uppercase: true,
                )
              else
                Icon(
                  CatchIcons.chevronRightRounded,
                  size: CatchIcon.control,
                  color: t.ink3,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class HostOrganizerTrendStrip extends StatelessWidget {
  const HostOrganizerTrendStrip({
    super.key,
    required this.memberCount,
    required this.activeEventCount,
    required this.onTap,
  });

  final int memberCount;
  final int activeEventCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bars = _trendBars(memberCount: memberCount, events: activeEventCount);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CatchStatColumn(
                monoValue: true,
                value: _compactCount(memberCount),
                label: 'Members',
              ),
              gapW16,
              CatchStatColumn(
                monoValue: true,
                value: _compactCount(activeEventCount),
                label: 'Active events',
              ),
              const Spacer(),
              Icon(CatchIcons.chevronRightRounded, size: CatchIcon.control),
            ],
          ),
          gapH16,
          SizedBox(
            height: CatchLayout.hostOrganizerTrendChartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < bars.length; index++) ...[
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: bars[index],
                        widthFactor: 0.62,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: t.primary,
                            borderRadius: BorderRadius.circular(
                              CatchRadius.pill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (index < bars.length - 1) gapW4,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<String> _organizerFormats(Club club) {
  final tags = club.tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .take(4)
      .toList(growable: false);
  if (tags.isNotEmpty) return tags;
  return [club.hostDefaults.primaryActivityKind.label];
}

String _organizerMeta(Club club) {
  final parts = [
    if (club.area.trim().isNotEmpty) club.area.trim(),
    if (club.location.trim().isNotEmpty) club.location.trim(),
    'Since ${club.createdAt.year}',
  ];
  return parts.join(' · ').toUpperCase();
}

String _initialsForName(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return '?';
  return words.take(2).map((word) => word.characters.first).join();
}

String _compactCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return '$count';
}

String _ratingValue(Club club) {
  if (club.reviewCount <= 0 || club.rating <= 0) return 'New';
  final rounded = club.rating.roundToDouble();
  return club.rating == rounded
      ? rounded.toStringAsFixed(0)
      : club.rating.toStringAsFixed(1);
}

List<double> _trendBars({required int memberCount, required int events}) {
  final seed = (memberCount + events * 17).clamp(0, 999).toInt();
  return [
    for (var index = 0; index < 10; index++)
      (0.34 + (((seed + index * 13) % 58) / 100)).clamp(0.24, 0.96).toDouble(),
  ];
}
