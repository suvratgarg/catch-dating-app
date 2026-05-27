import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_day_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Builds the Explore feed slivers: editorial hero + day-grouped event list.
///
/// Returns a flat list of slivers — not a nested [SliverMainAxisGroup] —
/// because nested groups with [SliverPersistentHeader(pinned: true)] inside
/// trigger a Flutter layout assertion ("layoutExtent exceeds paintExtent")
/// when the pinned header is partially clipped by a parent group.
List<Widget> buildExploreEventsSlivers(
  WidgetRef ref, {
  bool pinnedDayHeaders = true,
}) {
  final feedAsync = ref.watch(exploreFeedViewModelProvider);
  final filters = ref.watch(clubBrowseFiltersProvider);
  final searchQuery = ref.watch(clubSearchQueryProvider).trim();

  return switch (feedAsync) {
    AsyncLoading() => const [_ExploreEventsLoadingSliver()],
    AsyncError(:final error) => [
      SliverToBoxAdapter(
        // Bound the error sliver's scroll extent so a long `error.toString()`
        // (e.g. a wrapped ProviderException with full stack trace) does not
        // dominate the sheet's sliver layout and starve following siblings
        // of paint extent. The `OverflowBox` lets the child report its
        // natural intrinsic size while we clip down to a fixed paint area.
        child: ClipRect(
          child: SizedBox(
            height: 180,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 0,
              maxHeight: 1200,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s5,
                  CatchSpacing.s3,
                  CatchSpacing.s5,
                  CatchSpacing.s3,
                ),
                child: CatchInlineErrorState.fromError(
                  error,
                  context: AppErrorContext.event,
                  onRetry: () => ref.invalidate(exploreFeedViewModelProvider),
                  compact: true,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
    AsyncData(:final value) =>
      value.isEmpty
          ? [
              _ExploreEventsEmptySliver(
                filters: filters,
                searchQuery: searchQuery,
              ),
            ]
          : _exploreContentSlivers(value, pinnedDayHeaders: pinnedDayHeaders),
  };
}

/// Compatibility shim — earlier call sites used `const ExploreEventsSection()`
/// as a single sliver. New call sites should prefer
/// [buildExploreEventsSlivers] so the slivers are spread into the parent
/// flat slivers list.
class ExploreEventsSection extends ConsumerWidget {
  const ExploreEventsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slivers = buildExploreEventsSlivers(ref, pinnedDayHeaders: false);
    if (slivers.length == 1) return slivers.single;
    return SliverMainAxisGroup(slivers: slivers);
  }
}

List<Widget> _exploreContentSlivers(
  ExploreFeedViewModel viewModel, {
  required bool pinnedDayHeaders,
}) {
  final featured = viewModel.featuredItem;
  final dayGroups = viewModel.dayGroupsExcludingFeatured();
  return [
    if (featured != null)
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s4,
            CatchSpacing.s5,
            CatchSpacing.s5,
          ),
          child: _ExploreHero(item: featured),
        ),
      ),
    for (final group in dayGroups)
      ..._buildDayGroupSlivers(group, pinnedHeader: pinnedDayHeaders),
    const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
  ];
}

List<Widget> _buildDayGroupSlivers(
  ExploreEventDayGroup group, {
  required bool pinnedHeader,
}) {
  return [
    if (pinnedHeader)
      SliverPersistentHeader(
        pinned: true,
        delegate: CatchDaySectionHeaderDelegate(
          label: group.label,
          count: group.count,
        ),
      )
    else
      SliverToBoxAdapter(
        child: CatchDaySectionHeader(label: group.label, count: group.count),
      ),
    SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        0,
        CatchSpacing.s5,
        CatchSpacing.s2,
      ),
      sliver: SliverList.separated(
        itemCount: group.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: CatchSpacing.s3),
        itemBuilder: (context, index) {
          final item = group.items[index];
          return _ExploreCompactCard(item: item);
        },
      ),
    ),
  ];
}

class _ExploreHero extends ConsumerWidget {
  const _ExploreHero({required this.item});

  final ExploreEventItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = item.event;
    return CatchEventSpotlightCard(
      title: item.event.title,
      supportingLabel: _supportingLabel(item),
      timeLabel: EventFormatters.time(event.startTime),
      countdownLabel: _heroCountdownLabel(event.startTime),
      priceLabel: item.priceLabel,
      capacityLabel: _capacityLabel(item),
      activityKind: event.activityKind,
      kicker: _spotlightKickerFor(item),
      onTap: () => _openEvent(context, ref, item, 'featured'),
    );
  }
}

class _ExploreCompactCard extends ConsumerWidget {
  const _ExploreCompactCard({required this.item});

  final ExploreEventItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = item.event;
    return CatchEventTicketCard(
      title: event.title,
      subtitle: '${item.club.name} - ${event.locationName}',
      timeLabel: EventFormatters.time(event.startTime),
      countdownLabel: _compactCountdownLabel(event.startTime),
      priceLabel: item.priceLabel,
      capacityLabel: _capacityLabel(item),
      activityKind: event.activityKind,
      statusLabel: _cardStatusLabel(item),
      clockTime: TimeOfDay.fromDateTime(event.startTime),
      onTap: () => _openEvent(context, ref, item, 'list'),
    );
  }
}

class _ExploreEventsLoadingSliver extends StatelessWidget {
  const _ExploreEventsLoadingSliver();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          CatchSpacing.s3,
          CatchSpacing.s5,
          CatchSpacing.s3,
        ),
        child: CatchSurface(
          clipBehavior: Clip.antiAlias,
          borderColor: t.line,
          elevation: CatchSurfaceElevation.card,
          radius: CatchRadius.lg,
          child: CatchSkeleton.card(height: 160),
        ),
      ),
    );
  }
}

class _ExploreEventsEmptySliver extends ConsumerWidget {
  const _ExploreEventsEmptySliver({
    required this.filters,
    required this.searchQuery,
  });

  final ClubBrowseFilterSelection filters;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emptyState = _emptyStateFor(
      filters.timeFilter,
      hasSearch: searchQuery.isNotEmpty,
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          CatchSpacing.s4,
          CatchSpacing.s5,
          CatchSpacing.s3,
        ),
        child: CatchEmptyState(
          icon: CatchIcons.eventAvailable,
          title: emptyState.title,
          message: emptyState.message,
          action: CatchButton(
            label: emptyState.actionLabel,
            icon: Icon(emptyState.actionIcon),
            variant: CatchButtonVariant.secondary,
            onPressed: () {
              final controller = ref.read(clubBrowseFiltersProvider.notifier);
              if (emptyState.clearSearch) {
                ref.read(clubSearchQueryProvider.notifier).clear();
              }
              final nextFilter = emptyState.nextFilter;
              if (nextFilter == null) {
                controller.clear();
              } else {
                controller.setTimeFilter(nextFilter);
              }
            },
          ),
          layout: CatchEmptyStateLayout.inline,
          iconStyle: CatchEmptyStateIconStyle.plain,
        ),
      ),
    );
  }
}

_ExploreEmptyStateCopy _emptyStateFor(
  ExploreTimeFilter filter, {
  required bool hasSearch,
}) {
  if (hasSearch) {
    return _ExploreEmptyStateCopy(
      title: 'No events match this search',
      message: 'Clear the search and filters to see every upcoming event.',
      actionLabel: 'Clear search and filters',
      actionIcon: CatchIcons.clear,
      clearSearch: true,
    );
  }
  return switch (filter) {
    ExploreTimeFilter.tonight => _ExploreEmptyStateCopy(
      title: 'Nothing tonight',
      message: 'The next good fit may be over the weekend.',
      actionLabel: 'See weekend',
      actionIcon: CatchIcons.thisWeek,
      nextFilter: ExploreTimeFilter.weekend,
    ),
    ExploreTimeFilter.tomorrow => _ExploreEmptyStateCopy(
      title: 'Nothing tomorrow',
      message: 'Open up the weekend to catch more event slots.',
      actionLabel: 'See weekend',
      actionIcon: CatchIcons.thisWeek,
      nextFilter: ExploreTimeFilter.weekend,
    ),
    ExploreTimeFilter.weekend => _ExploreEmptyStateCopy(
      title: 'Nothing this weekend',
      message: 'This week has the broader event slate.',
      actionLabel: 'See this week',
      actionIcon: CatchIcons.thisWeek,
      nextFilter: ExploreTimeFilter.thisWeek,
    ),
    ExploreTimeFilter.thisWeek => _ExploreEmptyStateCopy(
      title: 'Nothing this week',
      message: 'Remove the time window to see every upcoming event.',
      actionLabel: 'See anytime',
      actionIcon: CatchIcons.clear,
      nextFilter: ExploreTimeFilter.anytime,
    ),
    ExploreTimeFilter.anytime => _ExploreEmptyStateCopy(
      title: 'No upcoming events match this view',
      message:
          'Try a different area, a wider distance, or check the club directory below.',
      actionLabel: 'Clear filters',
      actionIcon: CatchIcons.clear,
    ),
  };
}

class _ExploreEmptyStateCopy {
  const _ExploreEmptyStateCopy({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    this.nextFilter,
    this.clearSearch = false,
  });

  final String title;
  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final ExploreTimeFilter? nextFilter;
  final bool clearSearch;
}

// ── shared helpers ─────────────────────────────────────────────────────────

String? _editorialSashFor(ExploreEventItem item) {
  final now = DateTime.now();
  final delta = item.event.startTime.difference(now);
  if (delta.inHours <= 12 && delta.isNegative == false) {
    return "Tonight's pick";
  }
  if (item.status == EventTileStatus.recommended) {
    return 'Picked for you';
  }
  return null;
}

String _spotlightKickerFor(ExploreEventItem item) {
  final status = _cardStatusLabel(item);
  if (status != null && item.status != EventTileStatus.open) return status;
  return _editorialSashFor(item) ?? "This week's pick";
}

String _supportingLabel(ExploreEventItem item) {
  final event = item.event;
  final distance = item.distanceFromUserLabel;
  return [
    item.club.name,
    event.locationName,
    event.activitySummaryLabel,
    ?distance,
  ].join(' - ');
}

String _capacityLabel(ExploreEventItem item) {
  final event = item.event;
  final availability = item.availabilityLabel;
  final base = '${event.signedUpCount} going';
  if (event.spotsRemaining <= 0) return '$base - full';
  if (availability != null &&
      availability.isNotEmpty &&
      availability.toLowerCase() != 'open') {
    return '$base - $availability';
  }
  if (event.spotsRemaining > 0) return '$base - ${event.spotsRemaining} left';
  return base;
}

String _heroCountdownLabel(DateTime startTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final eventDay = DateTime(startTime.year, startTime.month, startTime.day);
  final diffDays = eventDay.difference(today).inDays;
  return switch (diffDays) {
    0 => _relativeCountdownLabel(startTime) ?? 'Tonight',
    1 => 'Tomorrow',
    _ => EventFormatters.shortWeekday(startTime),
  };
}

String _compactCountdownLabel(DateTime startTime) {
  final relative = _relativeCountdownLabel(startTime);
  if (relative != null) return relative;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final eventDay = DateTime(startTime.year, startTime.month, startTime.day);
  final diffDays = eventDay.difference(today).inDays;
  return switch (diffDays) {
    0 => 'Today',
    1 => 'Tomorrow',
    _ => EventFormatters.shortWeekday(startTime),
  };
}

String? _relativeCountdownLabel(DateTime startTime) {
  final delta = startTime.difference(DateTime.now());
  if (delta.inMinutes <= 0 || delta.inHours >= 6) return null;
  if (delta.inHours < 1) return 'In ${delta.inMinutes}m';
  final minutes = delta.inMinutes.remainder(60);
  if (minutes == 0) return 'In ${delta.inHours}h';
  return 'In ${delta.inHours}h ${minutes}m';
}

String? _cardStatusLabel(ExploreEventItem item) {
  return switch (item.status) {
    EventTileStatus.open => _availabilityStatusLabel(item),
    EventTileStatus.recommended => 'Picked',
    EventTileStatus.joined ||
    EventTileStatus.saved ||
    EventTileStatus.hosted ||
    EventTileStatus.waitlisted ||
    EventTileStatus.attended ||
    EventTileStatus.past ||
    EventTileStatus.full ||
    EventTileStatus.ineligible ||
    EventTileStatus.cancelled => eventTileStatusLabel(item.status),
  };
}

String? _availabilityStatusLabel(ExploreEventItem item) {
  final label = item.availabilityLabel?.trim();
  if (label == null || label.isEmpty || label.toLowerCase() == 'open') {
    return null;
  }
  return label;
}

void _openEvent(
  BuildContext context,
  WidgetRef ref,
  ExploreEventItem item,
  String source,
) {
  _logExploreEventOpened(ref, item, source);
  context.pushNamed(
    Routes.eventDetailScreen.name,
    pathParameters: {'clubId': item.event.clubId, 'eventId': item.event.id},
    extra: item.event,
  );
}

void _logExploreEventOpened(
  WidgetRef ref,
  ExploreEventItem item,
  String source,
) {
  ref
      .read(appAnalyticsProvider)
      .logEvent(
        AnalyticsEvents.exploreEventOpened,
        parameters: {
          AnalyticsParameters.eventId: item.event.id,
          AnalyticsParameters.clubId: item.club.id,
          AnalyticsParameters.exploreSource: source,
          AnalyticsParameters.activityKind: item.event.activityKind.name,
          AnalyticsParameters.availabilityStatus:
              item.availability?.status.name,
          AnalyticsParameters.distanceKm: item.distanceFromUserKm == null
              ? null
              : double.parse(item.distanceFromUserKm!.toStringAsFixed(2)),
        },
      );
}
