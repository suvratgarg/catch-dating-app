import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/shared/catch_polaroid.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_transition_tags.dart';
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
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const int _minimumThisWeekRecommendationCount = 5;
const int _syntheticExploreTargetEventCount = 10;
const int _syntheticExploreTargetClubCount = 2;
const String _syntheticExploreIdPrefix = 'synthetic-explore-';

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
    AsyncLoading() => [_buildExploreEventsLoadingSliver()],
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
    AsyncData(:final value) => () {
      final hasDiscoverableClubCandidates = _rankClubIntermixCandidates(
        candidateClubs,
        joinedClubIds: joinedClubIds,
      ).isNotEmpty;
      final canUseSyntheticVisualFill = _shouldUseExploreSyntheticVisualFill;
      return value.isEmpty &&
              !hasDiscoverableClubCandidates &&
              !canUseSyntheticVisualFill
          ? [
              _buildExploreEventsEmptySliver(
                ref,
                filters: filters,
                searchQuery: searchQuery,
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
  final featured = layoutViewModel.featuredItem;
  final bodyItems = effectiveItems
      .where((item) => item != featured)
      .toList(growable: false);
  final bodyViewModel = ExploreFeedViewModel(
    items: bodyItems,
    externalItems: layoutViewModel.externalItems,
  );
  final candidateThisWeekItems = showThisWeekList
      ? _topThisWeekRecommendations(bodyItems)
      : const <ExploreEventItem>[];
  final thisWeekItems =
      candidateThisWeekItems.length >= _minimumThisWeekRecommendationCount
      ? candidateThisWeekItems
      : const <ExploreEventItem>[];
  final thisWeekEventIds = {for (final item in thisWeekItems) item.event.id};
  final cards = _buildMixedFeedCards(
    viewModel: bodyViewModel,
    candidateClubs: effectiveCandidateClubs,
    joinedClubIds: joinedClubIds,
    excludeEventIds: thisWeekEventIds,
  );
  if (cards.isEmpty && thisWeekItems.isEmpty) {
    return const [SliverToBoxAdapter(child: SizedBox.shrink())];
  }
  return [
    if (bodyViewModel.count > 0)
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            pinnedDayHeaders ? CatchSpacing.s4 : CatchSpacing.s3,
            CatchSpacing.s5,
            CatchSpacing.s1,
          ),
          child: Builder(
            builder: (context) => _buildExploreResultCountLine(
              context,
              line: _exploreResultCountLine(bodyViewModel),
            ),
          ),
        ),
      ),
    if (thisWeekItems.isNotEmpty)
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s3,
            CatchSpacing.s5,
            cards.isEmpty ? CatchSpacing.s4 : CatchSpacing.s2,
          ),
          child: Builder(
            builder: (context) => _buildThisWeekRecommendationsSection(
              context,
              items: thisWeekItems,
            ),
          ),
        ),
      ),
    SliverPadding(
      padding: EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        thisWeekItems.isEmpty
            ? (pinnedDayHeaders ? CatchSpacing.s4 : CatchSpacing.s3)
            : CatchSpacing.s4,
        CatchSpacing.s5,
        CatchSpacing.s2,
      ),
      sliver: SliverList.separated(
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(height: CatchSpacing.s4),
        itemBuilder: (context, index) {
          return switch (cards[index]) {
            _MixedEventRowCard(:final item) => _buildExploreFeedEventRow(
              context,
              ref,
              item: item,
            ),
            _MixedExternalEventRowCard(:final item) =>
              _buildExploreExternalEventRow(context, ref, item: item),
            _MixedClubSpotlightCard(:final club) =>
              _buildExploreClubPolaroidCard(context, club: club),
            _MixedClubRowCard(:final club) => _buildExploreFeedClubRow(
              context,
              club: club,
            ),
          };
        },
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s6)),
  ];
}

List<_MixedExploreCard> _buildMixedFeedCards({
  required ExploreFeedViewModel viewModel,
  required List<Club> candidateClubs,
  required Set<String> joinedClubIds,
  Set<String> excludeEventIds = const <String>{},
}) {
  final rankedClubs = _rankClubIntermixCandidates(
    candidateClubs,
    joinedClubIds: joinedClubIds,
  );
  final firstClub = rankedClubs.firstOrNull;
  final secondClub = rankedClubs.skip(1).firstOrNull;
  final eventRows = viewModel.items
      .where((item) => !excludeEventIds.contains(item.event.id))
      .toList(growable: true);
  final externalRows = viewModel.externalItems.take(8).toList();
  final cards = <_MixedExploreCard>[];

  if (eventRows.isEmpty) {
    for (final item in externalRows) {
      cards.add(_MixedExternalEventRowCard(item));
    }
    if (firstClub != null) cards.add(_MixedClubSpotlightCard(firstClub));
    if (secondClub != null) cards.add(_MixedClubRowCard(secondClub));
    return cards;
  }

  final leadingCount = eventRows.length >= 2 ? 2 : 1;
  for (var i = 0; i < leadingCount; i += 1) {
    cards.add(_MixedEventRowCard(eventRows.removeAt(0)));
  }
  if (firstClub != null) cards.add(_MixedClubSpotlightCard(firstClub));

  for (var i = 0; i < eventRows.length; i += 1) {
    cards.add(_MixedEventRowCard(eventRows[i]));
    if (i == 1 && secondClub != null) {
      cards.add(_MixedClubRowCard(secondClub));
    }
  }
  for (final item in externalRows) {
    cards.add(_MixedExternalEventRowCard(item));
  }
  return cards;
}

List<Club> _rankClubIntermixCandidates(
  List<Club> clubs, {
  required Set<String> joinedClubIds,
}) {
  final ranked = clubs
      .where((club) => club.status == ClubLifecycleStatus.active)
      .where((club) => !club.archived)
      .where((club) => !joinedClubIds.contains(club.id))
      .toList();
  ranked.sort((a, b) {
    final aHasNextEvent = a.nextEventAt != null || a.nextEventLabel != null;
    final bHasNextEvent = b.nextEventAt != null || b.nextEventLabel != null;
    if (aHasNextEvent != bHasNextEvent) return aHasNextEvent ? -1 : 1;

    final aHasImage = (a.imageUrl ?? '').isNotEmpty;
    final bHasImage = (b.imageUrl ?? '').isNotEmpty;
    if (aHasImage != bHasImage) return aHasImage ? -1 : 1;

    final ratingOrder = b.rating.compareTo(a.rating);
    if (ratingOrder != 0) return ratingOrder;

    final memberOrder = b.memberCount.compareTo(a.memberCount);
    if (memberOrder != 0) return memberOrder;

    return a.name.compareTo(b.name);
  });
  return ranked;
}

sealed class _MixedExploreCard {
  const _MixedExploreCard();
}

class _MixedEventRowCard extends _MixedExploreCard {
  const _MixedEventRowCard(this.item);

  final ExploreEventItem item;
}

class _MixedExternalEventRowCard extends _MixedExploreCard {
  const _MixedExternalEventRowCard(this.item);

  final ExploreExternalEventItem item;
}

class _MixedClubSpotlightCard extends _MixedExploreCard {
  const _MixedClubSpotlightCard(this.club);

  final Club club;
}

class _MixedClubRowCard extends _MixedExploreCard {
  const _MixedClubRowCard(this.club);

  final Club club;
}

Widget _buildExploreResultCountLine(
  BuildContext context, {
  required String line,
}) {
  return _buildExploreMonoLabel(
    context,
    line,
    color: CatchTokens.of(context).ink3,
  );
}

String _exploreResultCountLine(ExploreFeedViewModel viewModel) {
  final count = viewModel.count;
  final noun = count == 1 ? 'PLAN' : 'PLANS';
  final dateSpan = _exploreDateSpanLabel(viewModel);
  if (dateSpan == null) return '$count $noun';
  return '$count $noun · $dateSpan';
}

String? _exploreDateSpanLabel(ExploreFeedViewModel viewModel) {
  if (viewModel.isEmpty) return null;
  final starts = [
    for (final item in viewModel.items) item.event.startTime,
    for (final item in viewModel.externalItems) item.event.startTime,
  ]..sort();
  final first = starts.first;
  final last = starts.last;
  final sameDay =
      first.year == last.year &&
      first.month == last.month &&
      first.day == last.day;
  if (sameDay) return _monthDayLabel(first);
  if (first.year == last.year && first.month == last.month) {
    return '${EventFormatters.shortMonth(first).toUpperCase()} '
        '${first.day}-${last.day}';
  }
  return '${_monthDayLabel(first)}-${_monthDayLabel(last)}';
}

String _monthDayLabel(DateTime value) {
  return '${EventFormatters.shortMonth(value).toUpperCase()} ${value.day}';
}

Widget _buildExploreFeedEventRow(
  BuildContext context,
  WidgetRef ref, {
  required ExploreEventItem item,
  String analyticsSource = 'mixed_row',
  EventDateRailCardStripPosition stripPosition =
      EventDateRailCardStripPosition.single,
}) {
  final event = item.event;
  final heroTag = _isSyntheticExploreItem(item)
      ? null
      : eventTicketHeroTag(event.id, analyticsSource);
  return EventDateRailCard(
    event: event,
    kicker: item.club.name,
    supportingLabel: _rowSupportingLabel(item),
    priceLabel: item.priceLabel,
    capacityLabel: _capacityLabel(item),
    statusLabel: _cardStatusLabel(item),
    stripPosition: stripPosition,
    heroTag: heroTag,
    onTap: _isSyntheticExploreItem(item)
        ? null
        : () => _openEvent(context, ref, item, analyticsSource),
  );
}

Widget _buildExploreExternalEventRow(
  BuildContext context,
  WidgetRef ref, {
  required ExploreExternalEventItem item,
}) {
  final event = item.event;
  final t = CatchTokens.of(context);
  final visual = eventActivityVisual(event.activityKind, context: context);
  final uri = event.primaryExternalUri;
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
              child: _buildExploreMonoLabel(
                context,
                'FROM ${event.platformLabel.toUpperCase()}',
                color: t.ink3,
              ),
            ),
            gapW8,
            EventStatusPill(label: 'External', color: visual.accent),
          ],
        ),
        gapH8,
        Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.eventDisplay(context, size: 25, height: 1.02),
        ),
        gapH4,
        Text(
          _externalEventSupportingLabel(item),
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
                '${EventFormatters.time(event.startTime)} · ${event.priceLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.mono(context, color: t.ink2),
              ),
            ),
            gapW12,
            CatchButton(
              label: uri == null ? 'No link' : 'Open',
              icon: Icon(CatchIcons.arrowUpRight, size: CatchIcon.sm),
              size: CatchButtonSize.sm,
              variant: CatchButtonVariant.secondary,
              onPressed: uri == null
                  ? null
                  : () => _openExternalEvent(ref, item),
              semanticsLabel: uri == null
                  ? 'External event link unavailable'
                  : 'Open external event source',
            ),
          ],
        ),
        gapH8,
        _buildExploreMonoLabel(
          context,
          'READ-ONLY SUPPLY · NO CATCH BOOKING',
          color: t.ink3,
        ),
      ],
    ),
  );
}

Widget _buildThisWeekRecommendationsSection(
  BuildContext context, {
  required List<ExploreEventItem> items,
}) {
  return Consumer(
    builder: (context, ref, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildExploreMonoLabel(
            context,
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
            _buildExploreFeedEventRow(
              context,
              ref,
              item: items[index],
              analyticsSource: 'this_week',
              stripPosition: _stripPositionFor(index, items.length),
            ),
          ],
        ],
      );
    },
  );
}

EventDateRailCardStripPosition _stripPositionFor(int index, int total) {
  if (total <= 1) return EventDateRailCardStripPosition.single;
  if (index == 0) return EventDateRailCardStripPosition.first;
  if (index == total - 1) return EventDateRailCardStripPosition.last;
  return EventDateRailCardStripPosition.middle;
}

Widget _buildExploreClubPolaroidCard(
  BuildContext context, {
  required Club club,
}) {
  final t = CatchTokens.of(context);
  final isSynthetic = _isSyntheticExploreClub(club);
  final card = CatchPolaroid(
    onTap: isSynthetic ? null : () => _openClub(context, club),
    paddingKey: const ValueKey('explore-club-polaroid-padding'),
    media: _buildExploreClubCover(context, club: club),
    mediaOverlay: Positioned(
      top: CatchSpacing.s3,
      right: CatchSpacing.s3,
      child: _buildExploreDarkPill(context, label: clubMemberCountLabel(club)),
    ),
    caption: (club.nextEventLabel ?? 'Club to know').toUpperCase(),
    captionColor: t.ink3,
    title: club.name,
    subtitle: _clubSupportingLabel(club),
    showArrow: false,
    footer: Row(
      children: [
        Expanded(child: _buildExploreClubTags(context, club: club)),
        gapW10,
        _buildExploreDarkPill(
          context,
          label: isSynthetic ? 'Preview' : 'View club',
          compact: true,
        ),
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

Widget _buildExploreFeedClubRow(BuildContext context, {required Club club}) {
  final t = CatchTokens.of(context);
  final palette = ClubCoverVisualPalette.forClub(context, club);
  final isSynthetic = _isSyntheticExploreClub(club);
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
            child: _buildExploreClubCover(context, club: club, compact: true),
          ),
        ),
        gapW14,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildExploreMonoLabel(
                context,
                'CLUB TO KNOW',
                color: palette.accent,
              ),
              gapH4,
              Text(
                club.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.clubDisplay(context, size: 27),
              ),
              gapH4,
              Text(
                _clubSupportingLabel(club),
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

Widget _buildExploreClubCover(
  BuildContext context, {
  required Club club,
  bool compact = false,
}) {
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

Widget _buildExploreClubTags(BuildContext context, {required Club club}) {
  final t = CatchTokens.of(context);
  final tags = visibleClubTags(club, limit: 2);
  if (tags.isEmpty) {
    return _buildExploreMonoLabel(
      context,
      clubMemberCountLabel(club).toUpperCase(),
      color: t.ink3,
    );
  }
  return ClubTagWrap(tags: tags);
}

Widget _buildExploreDarkPill(
  BuildContext context, {
  required String label,
  bool compact = false,
}) {
  final t = CatchTokens.of(context);
  return CatchSurface(
    radius: CatchRadius.pill,
    backgroundColor: t.ink,
    borderWidth: 0,
    padding: EdgeInsets.symmetric(
      horizontal: compact
          ? CatchLayout.compactDarkPillHorizontalPadding
          : CatchSpacing.s3,
      vertical: compact
          ? CatchLayout.compactDarkPillVerticalPadding
          : CatchSpacing.s2,
    ),
    child: Text(
      label,
      style: CatchTextStyles.labelM(context, color: t.primaryInk),
    ),
  );
}

Widget _buildExploreMonoLabel(
  BuildContext context,
  String label, {
  required Color color,
}) {
  return Text(
    label,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: CatchTextStyles.kicker(context, color: color),
  );
}

String _clubSupportingLabel(Club club) {
  final nextEvent = club.nextEventLabel?.trim();
  if (nextEvent != null && nextEvent.isNotEmpty) {
    return 'Next: $nextEvent';
  }
  final area = club.area.trim();
  if (area.isNotEmpty) return '${clubMemberCountLabel(club)} - $area';
  return clubMemberCountLabel(club);
}

String _externalEventSupportingLabel(ExploreExternalEventItem item) {
  final event = item.event;
  return _joinExploreLabels([
    event.activityKind.label,
    event.meetingPoint,
    item.distanceFromUserLabel,
  ]);
}

String _joinExploreLabels(Iterable<String?> labels) {
  return labels
      .whereType<String>()
      .map((label) => label.trim())
      .where((label) => label.isNotEmpty)
      .join(' · ');
}

void _openClub(BuildContext context, Club club) {
  context.pushNamed(
    Routes.clubDetailScreen.name,
    pathParameters: {'clubId': club.id},
    extra: club,
  );
}

Widget _buildExploreEventsLoadingSliver() {
  return SliverToBoxAdapter(
    child: Builder(
      builder: (context) {
        final t = CatchTokens.of(context);
        return Padding(
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
            child: CatchSkeleton.card(
              height: CatchLayout.exploreEventsSkeletonHeight,
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildExploreEventsEmptySliver(
  WidgetRef ref, {
  required ExploreFilterSelection filters,
  required String searchQuery,
}) {
  return SliverToBoxAdapter(
    child: Builder(
      builder: (context) {
        final emptyState = _emptyStateFor(
          filters.timeFilter,
          hasSearch: searchQuery.isNotEmpty,
        );
        return Padding(
          padding: CatchInsets.pageHeaderBody,
          child: CatchEmptyState(
            icon: CatchIcons.eventAvailable,
            title: emptyState.title,
            message: emptyState.message,
            action: CatchButton(
              label: emptyState.actionLabel,
              icon: Icon(emptyState.actionIcon),
              variant: CatchButtonVariant.secondary,
              onPressed: () {
                final controller = ref.read(exploreFiltersProvider.notifier);
                if (emptyState.clearSearch) {
                  ref.read(exploreSearchQueryProvider.notifier).clear();
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
          ),
        );
      },
    ),
  );
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

bool get _shouldUseExploreSyntheticVisualFill =>
    kDebugMode && AppConfig.enableExploreSyntheticVisualFill;

List<Club> _withDebugSyntheticExploreClubs(
  List<Club> clubs, {
  required Set<String> joinedClubIds,
}) {
  if (!_shouldUseExploreSyntheticVisualFill) return clubs;

  final result = clubs.toList(growable: true);
  var syntheticIndex = 0;
  while (_rankClubIntermixCandidates(
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
    if (_topThisWeekRecommendations(result, now: reference).length >=
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

List<ExploreEventItem> _topThisWeekRecommendations(
  List<ExploreEventItem> items, {
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final startOfToday = DateUtils.dateOnly(reference);
  final endOfWindow = startOfToday.add(const Duration(days: 7));
  final topByDay = <DateTime, ExploreEventItem>{};

  for (final item in items) {
    final eventStart = item.event.startTime;
    if (eventStart.isBefore(startOfToday) ||
        !eventStart.isBefore(endOfWindow)) {
      continue;
    }

    final eventDay = DateUtils.dateOnly(eventStart);
    topByDay.putIfAbsent(eventDay, () => item);
    if (topByDay.length == DateTime.daysPerWeek) break;
  }

  return topByDay.values.toList(growable: false)
    ..sort((a, b) => a.event.startTime.compareTo(b.event.startTime));
}

String _rowSupportingLabel(ExploreEventItem item) {
  final event = item.event;
  return [
    event.activitySummaryLabel,
    event.locationName,
  ].where((label) => label.trim().isNotEmpty).join(' · ');
}

String _capacityLabel(ExploreEventItem item) {
  return EventCapacityPresenter(
    item.event,
  ).goingAvailabilityLabel(availabilityLabel: item.availabilityLabel);
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
