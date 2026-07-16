part of '../host_operations_screen.dart';

class HostClubOrganizerOverviewController extends ConsumerWidget {
  const HostClubOrganizerOverviewController({
    super.key,
    required this.club,
    required this.currentUid,
    required this.isOwner,
    required this.onOpenEditor,
    required this.onOpenSettings,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;
  final VoidCallback onOpenEditor;
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
      eventsLoaded: eventsAsync.hasValue,
      eventCount: events.length,
      activeEventCount: activeEventCount,
      onOpenEditor: onOpenEditor,
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
    required this.eventsLoaded,
    required this.eventCount,
    required this.activeEventCount,
    required this.onOpenEditor,
    required this.onOpenSettings,
  });

  final Club club;
  final String currentUid;
  final bool isOwner;
  final bool eventsLoaded;
  final int eventCount;
  final int activeEventCount;
  final VoidCallback onOpenEditor;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final formats = _organizerFormats(club);

    return Column(
      key: const ValueKey('host-club-edit-summary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: CatchInsets.pageBodyUnderHeader.copyWith(bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (formats.isNotEmpty) ...[
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    for (final format in formats)
                      CatchBadge(label: format, uppercase: true),
                  ],
                ),
                gapH12,
              ],
              if (isOwner) ...[
                HostOrganizerPayoutPromptController(
                  uid: currentUid,
                  onManagePayouts: onOpenEditor,
                ),
              ],
              gapH16,
              HostOrganizerMetricGrid(
                club: club,
                eventsLoaded: eventsLoaded,
                eventCount: eventCount,
                activeEventCount: activeEventCount,
              ),
              gapH24,
              CatchSectionHeader(
                title: context.l10n.hostsHostOrganizerTitleTeamLength(
                  length: club.displayHostProfiles.length,
                ),
                padding: EdgeInsets.zero,
                titleStyle: CatchTextStyles.monoLabel(context, color: t.ink2),
                trailing: isOwner
                    ? CatchTextButton(
                        label: context.l10n.hostsHostOrganizerLabelManage,
                        onPressed: onOpenEditor,
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
                title: context.l10n.hostsHostOrganizerTitleManage,
                padding: EdgeInsets.zero,
                titleStyle: CatchTextStyles.monoLabel(context, color: t.ink2),
              ),
              gapH10,
              CatchSection.contained(
                children: [
                  CatchField.nav(
                    icon: CatchIcons.paymentsOutlined,
                    title: context.l10n.hostsHostOrganizerTitlePayouts,
                    body: isOwner
                        ? context.l10n.hostsHostOrganizerBodyManage
                        : context.l10n.hostsHostOrganizerBodyOwnerOnly,
                    onTap: isOwner ? onOpenEditor : null,
                  ),
                  CatchField.nav(
                    icon: CatchIcons.tuneRounded,
                    title: context.l10n.hostsHostOrganizerTitleEventDefaults,
                    body: context.l10n.hostsHostOrganizerBodyPrefillNewEvents,
                    onTap: isOwner ? onOpenEditor : null,
                  ),
                  CatchField.nav(
                    icon: CatchIcons.settingsOutlined,
                    title: context.l10n.hostsHostOrganizerTitleSettings,
                    onTap: onOpenSettings,
                  ),
                ],
              ),
            ],
          ),
        ),
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
        label: context.l10n.hostsHostOrganizerLabelMembers,
      ),
      HostOrganizerMetricItem(
        value: _ratingValue(club),
        label: club.reviewCount > 0
            ? context.l10n.hostsHostOrganizerLabelRatingReviewcountReviews(
                reviewCount: club.reviewCount,
              )
            : context.l10n.hostsHostOrganizerLabelRating,
      ),
      HostOrganizerMetricItem(
        value: eventsLoaded ? _compactCount(eventCount) : '-',
        label: context.l10n.hostsHostOrganizerLabelEventsHosted,
      ),
      HostOrganizerMetricItem(
        value: eventsLoaded ? _compactCount(activeEventCount) : '-',
        label: context.l10n.hostsHostOrganizerLabelUpcoming,
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
        context.l10n.hostsHostOrganizerTextNoHostTeamMembers,
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
    final roleLabel = profile.role == ClubHostRole.owner
        ? context.l10n.hostsHostOrganizerVisiblecopyOwner
        : context.l10n.hostsHostOrganizerVisiblecopyHost;
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
                      isCurrentUser
                          ? context.l10n.hostsHostOrganizerTextYouRolelabel(
                              roleLabel: roleLabel,
                            )
                          : roleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              if (profile.role == ClubHostRole.owner)
                CatchBadge(
                  label: context.l10n.hostsHostOrganizerLabelOwner,
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

List<String> _organizerFormats(Club club) {
  final tags = club.tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .take(4)
      .toList(growable: false);
  if (tags.isNotEmpty) return tags;
  return [club.hostDefaults.primaryActivityKind.label];
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
