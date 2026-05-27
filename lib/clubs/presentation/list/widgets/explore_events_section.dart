import 'dart:math' as math;

import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_cover_fallback.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the Explore feed slivers: a mixed event/club discovery stream.
///
/// Returns a flat list of slivers — not a nested [SliverMainAxisGroup] —
/// so the parent sheet keeps one scroll owner while the feed can interleave
/// compact event rows, club recommendations, and the editorial event spotlight.
List<Widget> buildExploreEventsSlivers(
  WidgetRef ref, {
  bool pinnedDayHeaders = true,
  List<Club> candidateClubs = const <Club>[],
  Set<String> joinedClubIds = const <String>{},
  Set<String> hostedClubIds = const <String>{},
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
    AsyncData(:final value) => () {
      final hasDiscoverableClubCandidates = _rankClubIntermixCandidates(
        candidateClubs,
        joinedClubIds: joinedClubIds,
        hostedClubIds: hostedClubIds,
      ).isNotEmpty;
      return value.isEmpty && !hasDiscoverableClubCandidates
          ? [
              _ExploreEventsEmptySliver(
                filters: filters,
                searchQuery: searchQuery,
              ),
            ]
          : _exploreContentSlivers(
              value,
              candidateClubs: candidateClubs,
              joinedClubIds: joinedClubIds,
              hostedClubIds: hostedClubIds,
              pinnedDayHeaders: pinnedDayHeaders,
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
  required List<Club> candidateClubs,
  required Set<String> joinedClubIds,
  required Set<String> hostedClubIds,
  required bool pinnedDayHeaders,
}) {
  final cards = _buildMixedFeedCards(
    viewModel: viewModel,
    candidateClubs: candidateClubs,
    joinedClubIds: joinedClubIds,
    hostedClubIds: hostedClubIds,
  );
  if (cards.isEmpty) {
    return const [SliverToBoxAdapter(child: SizedBox.shrink())];
  }
  return [
    SliverPadding(
      padding: EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        pinnedDayHeaders ? CatchSpacing.s4 : CatchSpacing.s3,
        CatchSpacing.s5,
        CatchSpacing.s2,
      ),
      sliver: SliverList.separated(
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(height: CatchSpacing.s4),
        itemBuilder: (context, index) {
          return switch (cards[index]) {
            _MixedEventRowCard(:final item) => _ExploreFeedEventRow(item: item),
            _MixedEventSpotlightCard(:final item) => _ExploreHero(item: item),
            _MixedClubSpotlightCard(:final club) => _ExploreClubPolaroidCard(
              club: club,
            ),
            _MixedClubRowCard(:final club) => _ExploreFeedClubRow(club: club),
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
  required Set<String> hostedClubIds,
}) {
  final rankedClubs = _rankClubIntermixCandidates(
    candidateClubs,
    joinedClubIds: joinedClubIds,
    hostedClubIds: hostedClubIds,
  );
  final firstClub = rankedClubs.firstOrNull;
  final secondClub = rankedClubs.skip(1).firstOrNull;
  final spotlight = viewModel.featuredItem;
  final eventRows = viewModel.items
      .where((item) => item != spotlight)
      .toList(growable: true);
  final cards = <_MixedExploreCard>[];

  if (eventRows.isEmpty) {
    if (spotlight != null) cards.add(_MixedEventSpotlightCard(spotlight));
    if (firstClub != null) cards.add(_MixedClubSpotlightCard(firstClub));
    if (secondClub != null) cards.add(_MixedClubRowCard(secondClub));
    return cards;
  }

  final leadingCount = eventRows.length >= 2 ? 2 : 1;
  for (var i = 0; i < leadingCount; i += 1) {
    cards.add(_MixedEventRowCard(eventRows.removeAt(0)));
  }
  if (firstClub != null) cards.add(_MixedClubSpotlightCard(firstClub));
  if (spotlight != null) cards.add(_MixedEventSpotlightCard(spotlight));

  for (var i = 0; i < eventRows.length; i += 1) {
    cards.add(_MixedEventRowCard(eventRows[i]));
    if (i == 1 && secondClub != null) {
      cards.add(_MixedClubRowCard(secondClub));
    }
  }
  return cards;
}

List<Club> _rankClubIntermixCandidates(
  List<Club> clubs, {
  required Set<String> joinedClubIds,
  required Set<String> hostedClubIds,
}) {
  final ranked = clubs
      .where((club) => club.status == ClubLifecycleStatus.active)
      .where((club) => !club.archived)
      .where((club) => !joinedClubIds.contains(club.id))
      .where((club) => !hostedClubIds.contains(club.id))
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

class _MixedEventSpotlightCard extends _MixedExploreCard {
  const _MixedEventSpotlightCard(this.item);

  final ExploreEventItem item;
}

class _MixedClubSpotlightCard extends _MixedExploreCard {
  const _MixedClubSpotlightCard(this.club);

  final Club club;
}

class _MixedClubRowCard extends _MixedExploreCard {
  const _MixedClubRowCard(this.club);

  final Club club;
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

class _ExploreFeedEventRow extends ConsumerWidget {
  const _ExploreFeedEventRow({required this.item});

  final ExploreEventItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final event = item.event;
    final visual = eventActivityVisual(event.activityKind);
    final capacityProgress = event.capacityLimit <= 0
        ? 0.0
        : (event.signedUpCount / event.capacityLimit).clamp(0.0, 1.0);
    final status = _cardStatusLabel(item);
    return CatchSurface(
      onTap: () => _openEvent(context, ref, item, 'mixed_row'),
      radius: CatchRadius.md,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ExploreFeedDateBadge(startTime: event.startTime),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s4,
                  CatchSpacing.s4,
                  CatchSpacing.s3,
                  CatchSpacing.s4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ExploreFeedActivityStamp(visual: visual),
                    gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ExploreMonoLabel(
                                  item.club.name.toUpperCase(),
                                  color: t.ink3,
                                ),
                              ),
                              if (status != null) ...[
                                gapW8,
                                _ExploreStatusPill(
                                  label: status,
                                  color: visual.accent,
                                ),
                              ],
                            ],
                          ),
                          gapH6,
                          Text(
                            event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _exploreSerif(context, size: 27, height: 1),
                          ),
                          gapH8,
                          Row(
                            children: [
                              _ExploreTinyClockMark(
                                accent: visual.accent,
                                time: TimeOfDay.fromDateTime(event.startTime),
                              ),
                              gapW8,
                              Flexible(
                                child: Text(
                                  '${EventFormatters.time(event.startTime)} / ${item.priceLabel}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: CatchTextStyles.mono(
                                    context,
                                    color: t.ink2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          gapH8,
                          Row(
                            children: [
                              Flexible(
                                child: _ExploreMonoLabel(
                                  _capacityLabel(item),
                                  color: t.ink2,
                                ),
                              ),
                              gapW12,
                              Expanded(
                                child: _ExploreCapacityProgress(
                                  color: visual.accent,
                                  value: capacityProgress,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _ExploreAccentRail(color: visual.accent),
          ],
        ),
      ),
    );
  }
}

class _ExploreClubPolaroidCard extends StatelessWidget {
  const _ExploreClubPolaroidCard({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      onTap: () => _openClub(context, club),
      radius: CatchRadius.sm,
      borderColor: t.line,
      elevation: CatchSurfaceElevation.card,
      backgroundColor: t.surface,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CatchRadius.sm),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ExploreClubCover(club: club),
                    Positioned(
                      top: CatchSpacing.s3,
                      right: CatchSpacing.s3,
                      child: _ExploreDarkPill(label: _memberCountLabel(club)),
                    ),
                  ],
                ),
              ),
            ),
            gapH10,
            _ExploreMonoLabel(
              (club.nextEventLabel ?? 'Club to know').toUpperCase(),
              color: t.ink3,
            ),
            gapH3,
            Text(
              club.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _exploreSerif(context, size: 30, height: 0.98),
            ),
            gapH3,
            Text(
              _clubSupportingLabel(club),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapH10,
            Row(
              children: [
                Expanded(child: _ExploreClubTags(club: club)),
                gapW10,
                _ExploreDarkPill(label: 'View club', compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreFeedClubRow extends StatelessWidget {
  const _ExploreFeedClubRow({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = ClubCoverVisualPalette.forClub(club);
    return CatchSurface(
      onTap: () => _openClub(context, club),
      radius: CatchRadius.md,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.md),
              child: _ExploreClubCover(club: club, compact: true),
            ),
          ),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ExploreMonoLabel('CLUB TO KNOW', color: palette.accent),
                gapH4,
                Text(
                  club.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _exploreSerif(context, size: 27, height: 1),
                ),
                gapH4,
                Text(
                  _clubSupportingLabel(club),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.bodyM(context, color: t.ink2),
                ),
              ],
            ),
          ),
          gapW12,
          Icon(CatchIcons.forwardArrow, size: 18, color: t.ink3),
        ],
      ),
    );
  }
}

class _ExploreFeedDateBadge extends StatelessWidget {
  const _ExploreFeedDateBadge({required this.startTime});

  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s4),
      decoration: BoxDecoration(
        color: t.raised,
        border: Border(right: BorderSide(color: t.line)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            EventFormatters.shortWeekday(startTime).toUpperCase(),
            style: CatchTextStyles.mono(context, color: t.ink3).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          gapH4,
          Text(
            '${startTime.day}',
            style: _exploreSerif(context, size: 30, height: 0.9),
          ),
        ],
      ),
    );
  }
}

class _ExploreFeedActivityStamp extends StatelessWidget {
  const _ExploreFeedActivityStamp({required this.visual});

  final EventActivityVisualSpec visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: visual.soft.withValues(alpha: 0.72),
        border: Border.all(color: visual.accent.withValues(alpha: 0.54)),
      ),
      alignment: Alignment.center,
      child: Icon(visual.icon, size: 22, color: visual.deep),
    );
  }
}

class _ExploreTinyClockMark extends StatelessWidget {
  const _ExploreTinyClockMark({required this.accent, required this.time});

  final Color accent;
  final TimeOfDay time;

  @override
  Widget build(BuildContext context) {
    final minuteTurns = time.minute / 60;
    final hourTurns = ((time.hour % 12) + minuteTurns) / 12;
    return SizedBox.square(
      dimension: 18,
      child: CustomPaint(
        painter: _TinyClockPainter(
          color: CatchTokens.of(context).line2,
          accent: accent,
          hourTurns: hourTurns,
          minuteTurns: minuteTurns,
        ),
      ),
    );
  }
}

class _TinyClockPainter extends CustomPainter {
  const _TinyClockPainter({
    required this.color,
    required this.accent,
    required this.hourTurns,
    required this.minuteTurns,
  });

  final Color color;
  final Color accent;
  final double hourTurns;
  final double minuteTurns;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;
    canvas.drawCircle(center, radius - 1, ringPaint);
    _drawHand(canvas, center, radius * 0.44, hourTurns, accent, 2.0);
    _drawHand(canvas, center, radius * 0.62, minuteTurns, accent, 1.5);
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double length,
    double turns,
    Color color,
    double strokeWidth,
  ) {
    final angle = turns * 6.283185307179586 - 1.5707963267948966;
    final end =
        center + Offset(length * math.cos(angle), length * math.sin(angle));
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant _TinyClockPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.accent != accent ||
      oldDelegate.hourTurns != hourTurns ||
      oldDelegate.minuteTurns != minuteTurns;
}

class _ExploreCapacityProgress extends StatelessWidget {
  const _ExploreCapacityProgress({required this.color, required this.value});

  final Color color;
  final double value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      child: LinearProgressIndicator(
        minHeight: 5,
        value: value,
        color: color,
        backgroundColor: t.line,
      ),
    );
  }
}

class _ExploreAccentRail extends StatelessWidget {
  const _ExploreAccentRail({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 7,
      child: DecoratedBox(decoration: BoxDecoration(color: color)),
    );
  }
}

class _ExploreStatusPill extends StatelessWidget {
  const _ExploreStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(CatchRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.mono(context, color: color).copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _ExploreClubCover extends StatelessWidget {
  const _ExploreClubCover({required this.club, this.compact = false});

  final Club club;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final url = club.imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return ClubCoverFallback(
        club: club,
        compact: compact,
        showLocationChip: false,
        showFooterLabel: false,
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => ClubCoverFallback(
        club: club,
        compact: compact,
        showLocationChip: false,
        showFooterLabel: false,
      ),
    );
  }
}

class _ExploreClubTags extends StatelessWidget {
  const _ExploreClubTags({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final tags = club.tags.take(2).toList(growable: false);
    if (tags.isEmpty) {
      return _ExploreMonoLabel(
        _memberCountLabel(club).toUpperCase(),
        color: t.ink3,
      );
    }
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final tag in tags)
          DecoratedBox(
            decoration: BoxDecoration(
              color: t.raised,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
              border: Border.all(color: t.line2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              child: _ExploreMonoLabel(tag.toUpperCase(), color: t.ink2),
            ),
          ),
      ],
    );
  }
}

class _ExploreDarkPill extends StatelessWidget {
  const _ExploreDarkPill({required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.ink,
        borderRadius: BorderRadius.circular(CatchRadius.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 11 : CatchSpacing.s3,
          vertical: compact ? 7 : 8,
        ),
        child: Text(
          label,
          style: CatchTextStyles.labelM(context, color: t.primaryInk),
        ),
      ),
    );
  }
}

class _ExploreMonoLabel extends StatelessWidget {
  const _ExploreMonoLabel(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.mono(
        context,
        color: color,
      ).copyWith(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0),
    );
  }
}

TextStyle _exploreSerif(
  BuildContext context, {
  required double size,
  required double height,
  Color? color,
}) {
  return GoogleFonts.getFont(
    'Instrument Serif',
    fontSize: size,
    fontWeight: FontWeight.w600,
    height: height,
    letterSpacing: 0,
    color: color ?? CatchTokens.of(context).ink,
  );
}

String _clubSupportingLabel(Club club) {
  final nextEvent = club.nextEventLabel?.trim();
  if (nextEvent != null && nextEvent.isNotEmpty) {
    return 'Next: $nextEvent';
  }
  final area = club.area.trim();
  if (area.isNotEmpty) return '${_memberCountLabel(club)} - $area';
  return _memberCountLabel(club);
}

String _memberCountLabel(Club club) {
  final count = club.memberCount;
  if (count == 1) return '1 member';
  if (count > 0) return '$count members';
  return 'New club';
}

void _openClub(BuildContext context, Club club) {
  context.pushNamed(
    Routes.clubDetailScreen.name,
    pathParameters: {'clubId': club.id},
    extra: club,
  );
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
