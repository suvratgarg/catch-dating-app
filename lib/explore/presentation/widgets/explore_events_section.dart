import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/catch_polaroid.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/clubs/shared/club_transition_tags.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const int _syntheticExploreTargetEventCount = 10;
const int _syntheticExploreTargetClubCount = 2;
const String _syntheticExploreIdPrefix = 'synthetic-explore-';
const EdgeInsets _exploreEventsErrorPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5,
  CatchSpacing.s3,
  CatchSpacing.s5,
  CatchSpacing.s3,
);
const EdgeInsets _exploreEventsLoadingPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5,
  CatchSpacing.s3,
  CatchSpacing.s5,
  CatchSpacing.s3,
);

/// Builds the Explore feed slivers: a mixed event/club discovery stream.
///
/// Returns a flat list of slivers — not a nested [SliverMainAxisGroup] —
/// so the parent sheet keeps one scroll owner while the feed can interleave
/// compact event rows and club recommendations.
List<Widget> buildExploreEventsSlivers(
  WidgetRef ref, {
  bool pinnedDayHeaders = true,
  List<Club> candidateClubs = const <Club>[],
  Set<String> joinedClubIds = const <String>{},
}) {
  final feedAsync = ref.watch(exploreFeedViewModelProvider);
  final filters = ref.watch(exploreFiltersProvider);
  final searchQuery = ref.watch(exploreSearchQueryProvider).trim();

  return switch (feedAsync) {
    AsyncLoading() => [const ExploreEventsLoadingSliver()],
    AsyncError(:final error) => [
      SliverToBoxAdapter(
        // Bound the error sliver's scroll extent so a long `error.toString()`
        // (e.g. a wrapped ProviderException with full stack trace) does not
        // dominate the sheet's sliver layout and starve following siblings
        // of paint extent. The `OverflowBox` lets the child report its
        // natural intrinsic size while we clip down to a fixed paint area.
        child: ClipRect(
          child: SizedBox(
            height: CatchLayout.exploreErrorSliverHeight,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: 0,
              maxHeight: 1200,
              child: Padding(
                padding: _exploreEventsErrorPadding,
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
    AsyncData(:final value) => () {
      final hasDiscoverableClubCandidates = rankExploreClubIntermixCandidates(
        candidateClubs,
        joinedClubIds: joinedClubIds,
      ).isNotEmpty;
      final canUseSyntheticVisualFill = _shouldUseExploreSyntheticVisualFill;
      return value.isEmpty &&
              !hasDiscoverableClubCandidates &&
              !canUseSyntheticVisualFill
          ? [
              ExploreEventsEmptySliver(
                state: ExploreEventsEmptyState.from(
                  filters: filters,
                  searchQuery: searchQuery,
                ),
                onClearSearch: () =>
                    ref.read(exploreSearchQueryProvider.notifier).clear(),
                onClearFilters: () =>
                    ref.read(exploreFiltersProvider.notifier).clear(),
                onSetTimeFilter: (filter) => ref
                    .read(exploreFiltersProvider.notifier)
                    .setTimeFilter(filter),
              ),
            ]
          : _exploreContentSlivers(
              value,
              ref: ref,
              candidateClubs: candidateClubs,
              joinedClubIds: joinedClubIds,
              pinnedDayHeaders: pinnedDayHeaders,
              showThisWeekList:
                  filters.timeFilter == ExploreTimeFilter.thisWeek,
            );
    }(),
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
  required WidgetRef ref,
  required List<Club> candidateClubs,
  required Set<String> joinedClubIds,
  required bool pinnedDayHeaders,
  required bool showThisWeekList,
}) {
  final effectiveCandidateClubs = _withDebugSyntheticExploreClubs(
    candidateClubs,
    joinedClubIds: joinedClubIds,
  );
  final effectiveItems = _withDebugSyntheticExploreItems(
    viewModel.items,
    seedClubs: [
      for (final item in viewModel.items) item.club,
      ...effectiveCandidateClubs,
    ],
  );
  final layoutViewModel = identical(effectiveItems, viewModel.items)
      ? viewModel
      : ExploreFeedViewModel(
          items: effectiveItems,
          externalItems: viewModel.externalItems,
        );
  final sectionState = ExploreFeedSectionState.from(
    viewModel: layoutViewModel,
    candidateClubs: effectiveCandidateClubs,
    joinedClubIds: joinedClubIds,
    showThisWeekList: showThisWeekList,
  );
  if (sectionState.isEmpty) {
    return const [SliverToBoxAdapter(child: SizedBox.shrink())];
  }
  final resultCountPadding = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    pinnedDayHeaders ? CatchSpacing.s4 : CatchSpacing.s3,
    CatchSpacing.s5,
    CatchSpacing.s1,
  );
  final thisWeekPadding = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    CatchSpacing.s3,
    CatchSpacing.s5,
    sectionState.cards.isEmpty ? CatchSpacing.s4 : CatchSpacing.s2,
  );
  final feedListPadding = EdgeInsets.fromLTRB(
    CatchSpacing.s5,
    sectionState.thisWeekItems.isEmpty
        ? (pinnedDayHeaders ? CatchSpacing.s4 : CatchSpacing.s3)
        : CatchSpacing.s4,
    CatchSpacing.s5,
    CatchSpacing.s2,
  );

  return [
    if (sectionState.bodyViewModel.count > 0)
      SliverToBoxAdapter(
        child: Padding(
          padding: resultCountPadding,
          child: Builder(
            builder: (context) => ExploreMonoLabel(
              sectionState.resultCountLabel,
              color: CatchTokens.of(context).ink3,
            ),
          ),
        ),
      ),
    if (sectionState.thisWeekItems.isNotEmpty)
      SliverToBoxAdapter(
        child: Padding(
          padding: thisWeekPadding,
          child: Builder(
            builder: (context) => ThisWeekRecommendationsSection(
              items: sectionState.thisWeekItems,
            ),
          ),
        ),
      ),
    SliverPadding(
      padding: feedListPadding,
      sliver: SliverList.separated(
        itemCount: sectionState.cards.length,
        separatorBuilder: (_, _) => const SizedBox(height: CatchSpacing.s4),
        itemBuilder: (context, index) {
          return switch (sectionState.cards[index]) {
            ExploreMixedEventRowCard(:final item) => ExploreFeedEventRow(
              item: item,
            ),
            ExploreMixedExternalEventRowCard(:final item) =>
              ExploreExternalEventRow(item: item),
            ExploreMixedClubSpotlightCard(:final club) =>
              ExploreClubPolaroidCard(club: club),
            ExploreMixedClubRowCard(:final club) => ExploreFeedClubRow(
              club: club,
            ),
          };
        },
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
  ];
}

class ExploreFeedEventRow extends ConsumerWidget {
  const ExploreFeedEventRow({
    super.key,
    required this.item,
    this.analyticsSource = 'mixed_row',
    this.stripPosition = EventDateRailCardStripPosition.single,
  });

  final ExploreEventItem item;
  final String analyticsSource;
  final EventDateRailCardStripPosition stripPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = item.event;
    final state = ExploreEventRowState.from(item);
    final heroTag = _isSyntheticExploreItem(item)
        ? null
        : eventTicketHeroTag(event.id, analyticsSource);
    return EventDateRailCard(
      event: event,
      kicker: state.kicker,
      supportingLabel: state.supportingLabel,
      priceLabel: state.priceLabel,
      capacityLabel: state.capacityLabel,
      statusLabel: state.statusLabel,
      stripPosition: stripPosition,
      heroTag: heroTag,
      onTap: _isSyntheticExploreItem(item)
          ? null
          : () => _openEvent(context, ref, item, analyticsSource),
    );
  }
}

class ExploreExternalEventRow extends ConsumerWidget {
  const ExploreExternalEventRow({super.key, required this.item});

  final ExploreExternalEventItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = item.event;
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(event.activityKind, context: context);
    final state = ExploreExternalEventRowState.from(item);
    return CatchSurface(
      radius: CatchRadius.md,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              EventActivityStamp(
                visual: visual,
                size: 26,
                iconSize: CatchIcon.sm,
              ),
              gapW8,
              Expanded(
                child: ExploreMonoLabel(state.sourceLabel, color: t.ink3),
              ),
              gapW8,
              EventStatusPill(label: state.statusLabel, color: visual.accent),
            ],
          ),
          gapH8,
          Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.eventDisplay(
              context,
              size: 25,
              height: 1.02,
            ),
          ),
          gapH4,
          Text(
            state.supportingLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH10,
          Row(
            children: [
              EventClockMark(
                accent: visual.accent,
                time: TimeOfDay.fromDateTime(event.startTime),
                size: 17,
              ),
              gapW8,
              Expanded(
                child: Text(
                  state.timePriceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.mono(context, color: t.ink2),
                ),
              ),
              gapW12,
              CatchButton(
                label: state.actionLabel,
                icon: Icon(CatchIcons.arrowUpRight, size: CatchIcon.sm),
                size: CatchButtonSize.sm,
                variant: CatchButtonVariant.secondary,
                onPressed: !state.hasExternalLink
                    ? null
                    : () => _openExternalEvent(ref, item),
                semanticsLabel: state.actionSemanticsLabel,
              ),
            ],
          ),
          gapH8,
          ExploreMonoLabel(state.readOnlySupplyLabel, color: t.ink3),
        ],
      ),
    );
  }
}

class ThisWeekRecommendationsSection extends StatelessWidget {
  const ThisWeekRecommendationsSection({super.key, required this.items});

  final List<ExploreEventItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExploreMonoLabel(
          'COMING UP · ${items.length}',
          color: CatchTokens.of(context).ink3,
        ),
        gapH2,
        CatchSectionHeader(
          title: 'This week',
          padding: EdgeInsets.zero,
          titleStyle: CatchTextStyles.clubDisplay(
            context,
            size: 38,
            height: 0.92,
          ),
        ),
        gapH12,
        for (var index = 0; index < items.length; index += 1) ...[
          ExploreFeedEventRow(
            item: items[index],
            analyticsSource: 'this_week',
            stripPosition: _stripPositionFor(index, items.length),
          ),
        ],
      ],
    );
  }
}

EventDateRailCardStripPosition _stripPositionFor(int index, int total) {
  if (total <= 1) return EventDateRailCardStripPosition.single;
  if (index == 0) return EventDateRailCardStripPosition.first;
  if (index == total - 1) return EventDateRailCardStripPosition.last;
  return EventDateRailCardStripPosition.middle;
}

class ExploreClubPolaroidCard extends StatelessWidget {
  const ExploreClubPolaroidCard({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isSynthetic = _isSyntheticExploreClub(club);
    final state = ExploreClubCardState.from(club, isSynthetic: isSynthetic);
    final card = CatchPolaroid(
      onTap: isSynthetic ? null : () => _openClub(context, club),
      paddingKey: const ValueKey('explore-club-polaroid-padding'),
      media: ExploreClubCover(club: club),
      mediaOverlay: Positioned(
        top: CatchSpacing.s3,
        right: CatchSpacing.s3,
        child: ExploreDarkPill(state.memberCountLabel),
      ),
      caption: state.caption,
      captionColor: t.ink3,
      title: state.title,
      subtitle: state.supportingLabel,
      showArrow: false,
      footer: Row(
        children: [
          Expanded(child: ExploreClubTags(state: state)),
          gapW10,
          ExploreDarkPill(state.actionLabel, compact: true),
        ],
      ),
    );
    if (isSynthetic) return card;
    return Hero(
      tag: clubInteractionHeroTag(club.id),
      transitionOnUserGestures: true,
      child: Material(color: Colors.transparent, child: card),
    );
  }
}

class ExploreFeedClubRow extends StatelessWidget {
  const ExploreFeedClubRow({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = ClubCoverVisualPalette.forClub(context, club);
    final isSynthetic = _isSyntheticExploreClub(club);
    final state = ExploreClubCardState.from(club, isSynthetic: isSynthetic);
    return CatchSurface(
      onTap: isSynthetic ? null : () => _openClub(context, club),
      radius: CatchRadius.md,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      padding: CatchInsets.content,
      child: Row(
        children: [
          SizedBox.square(
            // Fixed compact cover thumbnail (not scaling media). A bounded box
            // gives the cover determinate constraints — an AspectRatio here gets
            // unbounded width (Row) and height (SliverList) and cannot lay out.
            dimension: CatchLayout.clubCoverThumbnailExtent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.md),
              child: ExploreClubCover(club: club, compact: true),
            ),
          ),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ExploreMonoLabel(state.rowKicker, color: palette.accent),
                gapH4,
                Text(
                  state.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.clubDisplay(context, size: 27),
                ),
                gapH4,
                Text(
                  state.supportingLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
          gapW12,
          Icon(
            CatchIcons.forwardArrow,
            size: CatchIcon.md,
            color: isSynthetic
                ? t.ink3.withValues(alpha: CatchOpacity.exploreMutedAffordance)
                : t.ink3,
          ),
        ],
      ),
    );
  }
}

class ExploreClubCover extends StatelessWidget {
  const ExploreClubCover({super.key, required this.club, this.compact = false});

  final Club club;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final url = club.imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return ClubPolaroidArtwork(club: club, compact: compact);
    }
    return CatchGradedImage(
      child: CatchNetworkImage(
        url,
        errorBuilder: (_, _, _) =>
            ClubPolaroidArtwork(club: club, compact: compact),
      ),
    );
  }
}

class ExploreClubTags extends StatelessWidget {
  const ExploreClubTags({super.key, required this.state});

  final ExploreClubCardState state;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    if (state.tags.isEmpty) {
      return ExploreMonoLabel(
        state.memberCountLabel.toUpperCase(),
        color: t.ink3,
      );
    }
    return ClubTagWrap(tags: state.tags);
  }
}

class ExploreDarkPill extends StatelessWidget {
  const ExploreDarkPill(this.label, {super.key, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final pillPadding = EdgeInsets.symmetric(
      horizontal: compact
          ? CatchLayout.compactDarkPillHorizontalPadding
          : CatchSpacing.s3,
      vertical: compact
          ? CatchLayout.compactDarkPillVerticalPadding
          : CatchSpacing.s2,
    );

    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: t.ink,
      borderWidth: 0,
      padding: pillPadding,
      child: Text(
        label,
        style: CatchTextStyles.labelM(context, color: t.primaryInk),
      ),
    );
  }
}

class ExploreMonoLabel extends StatelessWidget {
  const ExploreMonoLabel(this.label, {super.key, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.kicker(context, color: color),
    );
  }
}

void _openClub(BuildContext context, Club club) {
  context.pushNamed(
    Routes.clubDetailScreen.name,
    pathParameters: {'clubId': club.id},
    extra: club,
  );
}

class ExploreEventsLoadingSliver extends StatelessWidget {
  const ExploreEventsLoadingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: _exploreEventsLoadingPadding,
        child: CatchSurface(
          clipBehavior: Clip.antiAlias,
          borderColor: t.line,
          elevation: CatchSurfaceElevation.card,
          child: CatchSkeleton.card(
            height: CatchLayout.exploreEventsSkeletonHeight,
          ),
        ),
      ),
    );
  }
}

class ExploreEventsEmptySliver extends StatelessWidget {
  const ExploreEventsEmptySliver({
    super.key,
    required this.state,
    this.onClearSearch,
    this.onClearFilters,
    this.onSetTimeFilter,
  });

  final ExploreEventsEmptyState state;
  final VoidCallback? onClearSearch;
  final VoidCallback? onClearFilters;
  final ValueChanged<ExploreTimeFilter>? onSetTimeFilter;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: CatchInsets.pageHeaderBody,
        child: CatchEmptyState(
          icon: CatchIcons.eventAvailable,
          title: state.title,
          message: state.message,
          action: CatchButton(
            label: state.actionLabel,
            icon: Icon(state.actionIcon),
            variant: CatchButtonVariant.secondary,
            onPressed: _handleAction,
          ),
          layout: CatchEmptyStateLayout.inline,
        ),
      ),
    );
  }

  void _handleAction() {
    if (state.clearSearch) onClearSearch?.call();
    final nextFilter = state.nextFilter;
    if (nextFilter != null) {
      onSetTimeFilter?.call(nextFilter);
      return;
    }
    if (state.clearFilters) onClearFilters?.call();
  }
}

bool get _shouldUseExploreSyntheticVisualFill =>
    kDebugMode && AppConfig.enableExploreSyntheticVisualFill;

List<Club> _withDebugSyntheticExploreClubs(
  List<Club> clubs, {
  required Set<String> joinedClubIds,
}) {
  if (!_shouldUseExploreSyntheticVisualFill) return clubs;

  final result = clubs.toList(growable: true);
  var syntheticIndex = 0;
  while (rankExploreClubIntermixCandidates(
        result,
        joinedClubIds: joinedClubIds,
      ).length <
      _syntheticExploreTargetClubCount) {
    result.add(_syntheticExploreClub(syntheticIndex));
    syntheticIndex += 1;
  }
  return result;
}

List<ExploreEventItem> _withDebugSyntheticExploreItems(
  List<ExploreEventItem> items, {
  required List<Club> seedClubs,
}) {
  if (!_shouldUseExploreSyntheticVisualFill) return items;

  final result = items.toList(growable: true);
  final clubs = seedClubs
      .where((club) => club.status == ClubLifecycleStatus.active)
      .where((club) => !club.archived)
      .toList(growable: true);
  if (clubs.isEmpty) clubs.add(_syntheticExploreClub(0));

  final reference = DateTime.now();
  final today = DateUtils.dateOnly(reference);
  final existingDays = {
    for (final item in result) DateUtils.dateOnly(item.event.startTime),
  };

  for (var dayOffset = 0; dayOffset < DateTime.daysPerWeek; dayOffset += 1) {
    if (topExploreThisWeekRecommendations(result, now: reference).length >=
        DateTime.daysPerWeek) {
      break;
    }
    final day = today.add(Duration(days: dayOffset));
    if (existingDays.contains(day)) continue;
    final spec =
        _syntheticExploreEventSpecs[dayOffset %
            _syntheticExploreEventSpecs.length];
    result.add(
      _syntheticExploreItem(
        club: clubs[dayOffset % clubs.length],
        spec: spec,
        day: day,
        dayOffset: dayOffset,
        variant: 0,
        reference: reference,
      ),
    );
    existingDays.add(day);
  }

  var overflowIndex = 0;
  while (result.length < _syntheticExploreTargetEventCount) {
    final dayOffset = 1 + (overflowIndex % (DateTime.daysPerWeek - 1));
    final spec =
        _syntheticExploreEventSpecs[(overflowIndex + DateTime.daysPerWeek) %
            _syntheticExploreEventSpecs.length];
    result.add(
      _syntheticExploreItem(
        club: clubs[overflowIndex % clubs.length],
        spec: spec,
        day: today.add(Duration(days: dayOffset)),
        dayOffset: dayOffset,
        variant: overflowIndex + 1,
        reference: reference,
      ),
    );
    overflowIndex += 1;
  }

  return result;
}

Club _syntheticExploreClub(int index) {
  final spec =
      _syntheticExploreClubSpecs[index % _syntheticExploreClubSpecs.length];
  return Club(
    id: '${_syntheticExploreIdPrefix}club-$index',
    name: spec.name,
    description: 'Synthetic Explore visual-fill club.',
    location: spec.location,
    area: spec.area,
    hostUserId: '${_syntheticExploreIdPrefix}host-$index',
    hostName: spec.hostName,
    createdAt: DateTime(2026, 5),
    tags: spec.tags,
    memberCount: spec.memberCount,
    rating: spec.rating,
    reviewCount: spec.reviewCount,
    nextEventAt: DateTime.now().add(Duration(days: index + 1, hours: 7)),
    nextEventLabel: spec.nextEventLabel,
  );
}

ExploreEventItem _syntheticExploreItem({
  required Club club,
  required _SyntheticExploreEventSpec spec,
  required DateTime day,
  required int dayOffset,
  required int variant,
  required DateTime reference,
}) {
  var start = DateTime(day.year, day.month, day.day, spec.hour, spec.minute);
  if (!start.isAfter(reference)) {
    start = reference.add(const Duration(hours: 2));
  }
  final event = Event(
    id: '${_syntheticExploreIdPrefix}event-$dayOffset-$variant',
    clubId: club.id,
    startTime: start,
    endTime: start.add(Duration(minutes: spec.durationMinutes)),
    meetingPoint: spec.meetingPoint,
    eventFormat: spec.eventFormat,
    distanceKm: spec.distanceKm,
    pace: spec.pace,
    capacityLimit: spec.capacityLimit,
    description: 'Synthetic Explore visual-fill event.',
    priceInPaise: spec.priceInPaise,
    bookedCount: spec.bookedCount,
  );
  return ExploreEventItem(
    event: event,
    club: club,
    status: EventTileStatus.open,
    distanceFromUserKm: spec.distanceFromUserKm,
  );
}

bool _isSyntheticExploreItem(ExploreEventItem item) {
  return item.event.id.startsWith(_syntheticExploreIdPrefix);
}

bool _isSyntheticExploreClub(Club club) {
  return club.id.startsWith(_syntheticExploreIdPrefix);
}

class _SyntheticExploreClubSpec {
  const _SyntheticExploreClubSpec({
    required this.name,
    required this.location,
    required this.area,
    required this.hostName,
    required this.tags,
    required this.memberCount,
    required this.rating,
    required this.reviewCount,
    required this.nextEventLabel,
  });

  final String name;
  final String location;
  final String area;
  final String hostName;
  final List<String> tags;
  final int memberCount;
  final double rating;
  final int reviewCount;
  final String nextEventLabel;
}

class _SyntheticExploreEventSpec {
  const _SyntheticExploreEventSpec({
    required this.meetingPoint,
    required this.activityKind,
    this.customActivityLabel,
    this.customInteractionModel,
    required this.distanceKm,
    required this.pace,
    required this.capacityLimit,
    required this.bookedCount,
    required this.priceInPaise,
    required this.hour,
    required this.minute,
    required this.durationMinutes,
    required this.distanceFromUserKm,
  });

  final String meetingPoint;
  final ActivityKind activityKind;
  final String? customActivityLabel;
  final EventInteractionModel? customInteractionModel;
  final double distanceKm;
  final PaceLevel pace;
  final int capacityLimit;
  final int bookedCount;
  final int priceInPaise;
  final int hour;
  final int minute;
  final int durationMinutes;
  final double distanceFromUserKm;

  EventFormatSnapshot get eventFormat {
    final label = customActivityLabel;
    if (label != null) {
      return EventFormatSnapshot.custom(
        label: label,
        interactionModel:
            customInteractionModel ?? EventInteractionModel.openFormat,
      );
    }
    return EventFormatSnapshot.fromActivityKind(activityKind);
  }
}

const _syntheticExploreClubSpecs = [
  _SyntheticExploreClubSpec(
    name: 'Lodhi Garden Event Collective',
    location: 'Delhi',
    area: 'Lodhi Garden',
    hostName: 'Aarav',
    tags: ['Social runs', 'Outdoors'],
    memberCount: 128,
    rating: 4.8,
    reviewCount: 36,
    nextEventLabel: 'Wed 7:30 PM',
  ),
  _SyntheticExploreClubSpec(
    name: 'Sundowner Run Club',
    location: 'Bengaluru',
    area: 'Indiranagar',
    hostName: 'Mira',
    tags: ['Evening runs', 'Cafe stops'],
    memberCount: 94,
    rating: 4.7,
    reviewCount: 21,
    nextEventLabel: 'Thu 6:30 PM',
  ),
];

const _syntheticExploreEventSpecs = [
  _SyntheticExploreEventSpec(
    meetingPoint: 'Lodhi Garden gate 1',
    activityKind: ActivityKind.socialRun,
    distanceKm: 10,
    pace: PaceLevel.competitive,
    capacityLimit: 8,
    bookedCount: 5,
    priceInPaise: 0,
    hour: 19,
    minute: 30,
    durationMinutes: 75,
    distanceFromUserKm: 1.2,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'Long table room',
    activityKind: ActivityKind.openActivity,
    customActivityLabel: 'long table',
    customInteractionModel: EventInteractionModel.seatedTable,
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: 8,
    bookedCount: 6,
    priceInPaise: 140000,
    hour: 19,
    minute: 30,
    durationMinutes: 120,
    distanceFromUserKm: 3.6,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'Cubbon Park bandstand',
    activityKind: ActivityKind.socialRun,
    distanceKm: 5,
    pace: PaceLevel.easy,
    capacityLimit: 12,
    bookedCount: 9,
    priceInPaise: 0,
    hour: 6,
    minute: 30,
    durationMinutes: 60,
    distanceFromUserKm: 2.1,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'NGMA courtyard',
    activityKind: ActivityKind.openActivity,
    customActivityLabel: 'sketching strangers',
    customInteractionModel: EventInteractionModel.openFormat,
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: 6,
    bookedCount: 4,
    priceInPaise: 60000,
    hour: 16,
    minute: 30,
    durationMinutes: 90,
    distanceFromUserKm: 4.8,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'Corner sourdough bar',
    activityKind: ActivityKind.dinner,
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: 6,
    bookedCount: 5,
    priceInPaise: 95000,
    hour: 11,
    minute: 30,
    durationMinutes: 120,
    distanceFromUserKm: 5.4,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'Neighborhood court 2',
    activityKind: ActivityKind.pickleball,
    distanceKm: 0,
    pace: PaceLevel.moderate,
    capacityLimit: 10,
    bookedCount: 7,
    priceInPaise: 75000,
    hour: 18,
    minute: 0,
    durationMinutes: 75,
    distanceFromUserKm: 2.9,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'Museum cafe steps',
    activityKind: ActivityKind.singlesMixer,
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: 14,
    bookedCount: 8,
    priceInPaise: 50000,
    hour: 17,
    minute: 0,
    durationMinutes: 90,
    distanceFromUserKm: 6.1,
  ),
];

// ── shared helpers ─────────────────────────────────────────────────────────

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
    extra: EventDetailRouteExtra(
      initialEvent: item.event,
      transition: EventDetailRouteTransition.ticketCard,
      presentationMode: EventDetailPresentationMode.ticket,
      heroTag: eventTicketHeroTag(item.event.id, source),
    ),
  );
}

void _openExternalEvent(WidgetRef ref, ExploreExternalEventItem item) {
  final uri = item.event.primaryExternalUri;
  if (uri == null) return;
  _logExploreExternalEventOpened(ref, item);
  unawaited(ref.read(externalLinkControllerProvider).openExternal(uri));
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

void _logExploreExternalEventOpened(
  WidgetRef ref,
  ExploreExternalEventItem item,
) {
  ref
      .read(appAnalyticsProvider)
      .logEvent(
        AnalyticsEvents.exploreEventOpened,
        parameters: {
          AnalyticsParameters.eventId: item.event.id,
          AnalyticsParameters.exploreSource: 'external_supply',
          AnalyticsParameters.activityKind: item.event.activityKind.name,
          AnalyticsParameters.availabilityStatus: 'external_outbound',
          'external_platform': item.event.platformLabel,
          AnalyticsParameters.distanceKm: item.distanceFromUserKm == null
              ? null
              : double.parse(item.distanceFromUserKm!.toStringAsFixed(2)),
        },
      );
}
