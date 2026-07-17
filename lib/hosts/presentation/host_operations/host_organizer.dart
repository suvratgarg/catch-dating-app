part of '../host_operations_screen.dart';

class HostClubOrganizerOverviewController extends ConsumerWidget {
  const HostClubOrganizerOverviewController({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(watchEventsForClubProvider(club.id));
    final events = eventsAsync.asData?.value ?? const <Event>[];
    final activeEventCount = events.where((event) => !event.isCancelled).length;

    return HostClubOrganizerOverview(
      club: club,
      eventsLoaded: eventsAsync.hasValue,
      eventCount: events.length,
      activeEventCount: activeEventCount,
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
