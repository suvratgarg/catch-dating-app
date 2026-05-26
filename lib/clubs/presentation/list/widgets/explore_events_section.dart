import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_corner_sash.dart';
import 'package:catch_dating_app/core/widgets/catch_day_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_card_compact.dart';
import 'package:catch_dating_app/core/widgets/catch_event_card_hero.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
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
List<Widget> buildExploreEventsSlivers(WidgetRef ref) {
  final feedAsync = ref.watch(exploreFeedViewModelProvider);

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
          ? const [_ExploreEventsEmptySliver()]
          : _exploreContentSlivers(value),
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
    final slivers = buildExploreEventsSlivers(ref);
    if (slivers.length == 1) return slivers.single;
    return SliverMainAxisGroup(slivers: slivers);
  }
}

List<Widget> _exploreContentSlivers(ExploreFeedViewModel viewModel) {
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
    for (final group in dayGroups) ..._buildDayGroupSlivers(group),
    const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
  ];
}

List<Widget> _buildDayGroupSlivers(ExploreEventDayGroup group) {
  // We deliberately do NOT use `SliverPersistentHeader(pinned: true)` for the
  // day-section headers — pinned headers nested inside a `SliverMainAxisGroup`
  // hit the upstream Flutter bug where `layoutExtent` can exceed
  // `paintExtent` when the header is partially clipped, throwing an assertion
  // in `SliverGeometry.debugAssertIsValid`. See
  // https://github.com/flutter/flutter/issues/146867. Inline headers still
  // give the day-grouping value the user wanted; tracking the sticky-headers
  // re-introduction in [docs/ui_modernization_backlog.md].
  return [
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
    return CatchEventCardHero(
      title: item.event.title,
      subtitle: '${item.club.name} · ${item.event.locationName}',
      kickerLabel: _heroKickerLabel(item.event.startTime),
      kickerTrailing: _heroKickerTrailing(item.event.startTime),
      meta: _buildHeroMeta(item),
      distanceTrailing: _buildDistanceEntry(item),
      photoUrl: item.event.photoUrl,
      pace: item.event.pace,
      activityKind: item.event.activityKind,
      sash: _sashForStatus(item.status),
      editorialSash: _editorialSashFor(item),
      priceLabel: item.priceLabel,
      onTap: () => _openEvent(context, ref, item, 'featured'),
      aspectRatio: 5 / 4,
    );
  }
}

class _ExploreCompactCard extends ConsumerWidget {
  const _ExploreCompactCard({required this.item});

  final ExploreEventItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CatchEventCardCompact(
      title: item.event.title,
      subtitle: '${item.club.name} · ${item.event.locationName}',
      kickerLabel: _compactKickerLabel(item.event.startTime),
      kickerTrailing: _compactKickerTrailing(item.event.startTime),
      meta: _buildCompactMeta(item),
      distanceTrailing: _buildDistanceEntry(item),
      photoUrl: item.event.photoUrl,
      pace: item.event.pace,
      activityKind: item.event.activityKind,
      sash: _sashForStatus(item.status),
      priceLabel: item.priceLabel,
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

class _ExploreEventsEmptySliver extends StatelessWidget {
  const _ExploreEventsEmptySliver();

  @override
  Widget build(BuildContext context) {
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
          title: 'No upcoming events match this view',
          message:
              'Try a broader time window, a different area, or check the club directory below.',
          layout: CatchEmptyStateLayout.inline,
          iconStyle: CatchEmptyStateIconStyle.plain,
        ),
      ),
    );
  }
}

// ── shared helpers ─────────────────────────────────────────────────────────

CatchEventSashSpec? _sashForStatus(EventTileStatus status) {
  return switch (status) {
    EventTileStatus.joined => CatchEventSashSpec(
      label: "You're in",
      icon: CatchIcons.joinedCheck,
      tone: CatchSashTone.success,
    ),
    EventTileStatus.hosted => CatchEventSashSpec(
      label: 'You host',
      icon: CatchIcons.hostBadge,
      tone: CatchSashTone.solid,
    ),
    EventTileStatus.saved => CatchEventSashSpec(
      label: 'Saved',
      icon: CatchIcons.saved,
      tone: CatchSashTone.solid,
    ),
    EventTileStatus.waitlisted => CatchEventSashSpec(
      label: 'Waitlisted',
      icon: CatchIcons.waitlisted,
      tone: CatchSashTone.solid,
    ),
    EventTileStatus.attended => const CatchEventSashSpec(
      label: 'Attended',
      tone: CatchSashTone.success,
    ),
    EventTileStatus.full => const CatchEventSashSpec(
      label: 'Full',
      tone: CatchSashTone.solid,
    ),
    EventTileStatus.recommended ||
    EventTileStatus.open ||
    EventTileStatus.past ||
    EventTileStatus.ineligible ||
    EventTileStatus.cancelled => null,
  };
}

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

String _heroKickerLabel(DateTime startTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final eventDay = DateTime(startTime.year, startTime.month, startTime.day);
  final diffDays = eventDay.difference(today).inDays;
  final time = EventFormatters.time(startTime);
  return switch (diffDays) {
    0 => 'Tonight · $time',
    1 => 'Tomorrow · $time',
    _ => '${EventFormatters.shortWeekday(startTime).toUpperCase()} · $time',
  };
}

String? _heroKickerTrailing(DateTime startTime) {
  final delta = startTime.difference(DateTime.now());
  if (delta.inMinutes <= 0 || delta.inHours >= 24) return null;
  if (delta.inHours < 1) {
    return 'in ${delta.inMinutes}m';
  }
  final minutes = delta.inMinutes.remainder(60);
  if (minutes == 0) return 'in ${delta.inHours}h';
  return 'in ${delta.inHours}h ${minutes}m';
}

String _compactKickerLabel(DateTime startTime) {
  return EventFormatters.time(startTime);
}

String? _compactKickerTrailing(DateTime startTime) {
  final delta = startTime.difference(DateTime.now());
  if (delta.inMinutes <= 0 || delta.inHours >= 6) return null;
  if (delta.inHours < 1) return 'in ${delta.inMinutes}m';
  final minutes = delta.inMinutes.remainder(60);
  if (minutes == 0) return 'in ${delta.inHours}h';
  return 'in ${delta.inHours}h ${minutes}m';
}

List<CatchMetaEntry> _buildHeroMeta(ExploreEventItem item) {
  final event = item.event;
  return [
    CatchMetaEntry(
      icon: activityKindGlyph(event.activityKind),
      label: event.activitySummaryLabel,
    ),
    CatchMetaEntry(
      icon: CatchIcons.group,
      label: '${event.signedUpCount}/${event.capacityLimit}',
    ),
    ?_buildAvailabilityEntry(item),
  ];
}

List<CatchMetaEntry> _buildCompactMeta(ExploreEventItem item) {
  final event = item.event;
  return [
    CatchMetaEntry(
      icon: activityKindGlyph(event.activityKind),
      label: event.activitySummaryLabel,
    ),
    CatchMetaEntry(
      icon: CatchIcons.group,
      label: '${event.signedUpCount}/${event.capacityLimit}',
    ),
    ?_buildAvailabilityEntry(item),
  ];
}

CatchMetaEntry? _buildAvailabilityEntry(ExploreEventItem item) {
  final label = item.availabilityLabel;
  if (label == null || label.trim().isEmpty) return null;
  return CatchMetaEntry(icon: CatchIcons.spots, label: label);
}

CatchMetaEntry? _buildDistanceEntry(ExploreEventItem item) {
  final distance = item.distanceFromUserKm;
  if (distance == null) return null;
  final label = distance < 1
      ? '${(distance * 1000).round()} m'
      : (distance >= 10
            ? '${distance.round()} km'
            : '${distance.toStringAsFixed(1)} km');
  return CatchMetaEntry(icon: CatchIcons.nearMe, label: label);
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
