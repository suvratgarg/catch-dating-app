part of '../host_operations_screen.dart';

class HostClubOrganizerOverviewController extends ConsumerWidget {
  const HostClubOrganizerOverviewController({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final crmAsync = ref.watch(hostCrmSummaryProvider(club.id));
    final eventsState = catchAsyncStateFromAsyncValue(eventsAsync);
    final crmState = catchAsyncStateFromAsyncValue(crmAsync);
    final events = eventsState.value ?? const <Event>[];
    final activeEventCount = events.where((event) => !event.isCancelled).length;

    return CatchSectionList(
      emptyStateOmitted: true,
      children: [
        CatchSection.content(
          title: context.l10n.hostsHostAnalyticsLabelAllTime,
          child: HostClubOrganizerOverview(
            club: club,
            eventsLoaded: eventsState.hasData,
            eventCount: events.length,
            activeEventCount: activeEventCount,
          ),
        ),
        _HostCrmAudienceCard(
          summary: crmState.value,
          loading: crmState.isLoading,
          hasError: crmState.hasError,
          onRetry: () => ref.invalidate(hostCrmSummaryProvider(club.id)),
        ),
      ],
    );
  }
}

class _HostCrmAudienceCard extends StatelessWidget {
  const _HostCrmAudienceCard({
    required this.summary,
    required this.loading,
    required this.hasError,
    required this.onRetry,
  });

  final HostCrmSummary? summary;
  final bool loading;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final data = summary;
    return CatchSectionList(
      emptyStateOmitted: true,
      children: [
        CatchSection.content(
          title: context.l10n.hostsHostOrganizerCrmTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (loading)
                Text(
                  context.l10n.hostsHostOrganizerCrmLoading,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                )
              else if (hasError || data == null) ...[
                Text(
                  context.l10n.hostsHostOrganizerCrmUnavailable,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                gapH12,
                CatchButton(
                  label: context.l10n.sharedActionTryAgain,
                  onPressed: onRetry,
                  variant: CatchButtonVariant.secondary,
                ),
              ] else ...[
                CatchMetricSection.grid(
                  items: [
                    CatchMetricValue(
                      value: _compactCount(data.contactCount),
                      label: context.l10n.hostsHostOrganizerCrmContacts,
                    ),
                    CatchMetricValue(
                      value: _compactCount(data.pastAttendeeCount),
                      label: context.l10n.hostsHostOrganizerCrmPastAttendees,
                    ),
                    CatchMetricValue(
                      value: _compactCount(data.repeatAttendeeCount),
                      label: context.l10n.hostsHostOrganizerCrmRepeatAttendees,
                    ),
                    CatchMetricValue(
                      value: _compactCount(data.importedContactCount),
                      label: context.l10n.hostsHostOrganizerCrmImportedContacts,
                    ),
                  ],
                ),
                if (data.truncated) ...[
                  gapH12,
                  Text(
                    context.l10n.hostsHostOrganizerCrmTruncated,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
              ],
            ],
          ),
        ),
        if (!loading && !hasError && data != null)
          CatchSection.content(
            title: context.l10n.hostsHostOrganizerCrmChannels,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HostCrmChannelRow(
                  label: context.l10n.hostsHostOrganizerCrmCatchApp,
                  value: context.l10n.hostsHostOrganizerCrmLinked(
                    count: data.linkedAccountCount,
                  ),
                  status: context.l10n.hostsHostOrganizerCrmCurrentEventLive,
                ),
                gapH16,
                const CatchDivider.section(),
                gapH16,
                _HostCrmChannelRow(
                  label: context.l10n.hostsHostOrganizerCrmWhatsapp,
                  value: context.l10n.hostsHostOrganizerCrmOptedIn(
                    count: data.whatsappOptInCount,
                  ),
                  status: context.l10n.hostsHostOrganizerCrmWhatsappSetup,
                ),
                gapH16,
                const CatchDivider.section(),
                gapH16,
                _HostCrmChannelRow(
                  label: context.l10n.hostsHostOrganizerCrmTextMessage,
                  value: context.l10n.hostsHostOrganizerCrmOptedIn(
                    count: data.smsOptInCount,
                  ),
                  status: context.l10n.hostsHostOrganizerCrmSmsSetup,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HostCrmChannelRow extends StatelessWidget {
  const _HostCrmChannelRow({
    required this.label,
    required this.value,
    required this.status,
  });

  final String label;
  final String value;
  final String status;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label · $value',
          style: CatchTextStyles.labelL(context, color: t.ink),
        ),
        gapH4,
        Text(status, style: CatchTextStyles.supporting(context, color: t.ink2)),
      ],
    );
  }
}

class HostClubOrganizerOverview extends StatelessWidget {
  const HostClubOrganizerOverview({
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
    return HostOrganizerMetricGrid(
      key: const ValueKey('host-club-insights-summary'),
      club: club,
      eventsLoaded: eventsLoaded,
      eventCount: eventCount,
      activeEventCount: activeEventCount,
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

    return HostOrganizerMetricRow(items: items);
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
    return CatchMetricSection.grid(
      items: [
        for (final item in items)
          CatchMetricValue(value: item.value, label: item.label),
      ],
    );
  }
}

String _compactCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
  return '$count';
}

String _ratingValue(Club club) {
  if (club.reviewCount <= 0 || club.rating <= 0) return '—';
  final rounded = club.rating.roundToDouble();
  return club.rating == rounded
      ? rounded.toStringAsFixed(0)
      : club.rating.toStringAsFixed(1);
}
