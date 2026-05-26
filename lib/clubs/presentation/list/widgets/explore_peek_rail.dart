import 'dart:async';

import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_card_peek.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _peekCardWidth = 264;
const double _peekCardSpacing = CatchSpacing.s3;

/// Builds the slivers for the "events near you" rail at the top of the
/// Explore sheet. Always present so the PEEK snap reveals it naturally;
/// dragging up reveals the rest of the feed below.
///
/// Previously this rail was a separate scrollable that the sheet builder
/// swapped in/out based on `_isPeek`. That broke the sheet's scroll
/// controller binding mid-drag and caused the sheet to stall when the user
/// tried to expand from PEEK. Now the rail is a sliver, the feed is a
/// single stable `CustomScrollView`, and the gesture has nothing to fight.
List<Widget> buildExploreNearbySlivers({
  required WidgetRef ref,
  required String? selectedEventId,
  required ValueChanged<Event> onEventTapped,
  required VoidCallback onSeeAll,
}) {
  final feedAsync = ref.watch(exploreFeedViewModelProvider);
  return [
    SliverToBoxAdapter(
      child: switch (feedAsync) {
        AsyncLoading() => const _PeekRailSkeleton(),
        AsyncError(:final error) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CatchSpacing.s5,
            vertical: CatchSpacing.s3,
          ),
          child: CatchInlineErrorState.fromError(
            error,
            context: AppErrorContext.event,
            onRetry: () => ref.invalidate(exploreFeedViewModelProvider),
            compact: true,
          ),
        ),
        AsyncData(:final value) =>
          value.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CatchSpacing.s5,
                    vertical: CatchSpacing.s3,
                  ),
                  child: CatchEmptyState(
                    icon: CatchIcons.eventBusy,
                    title: 'No events near you yet',
                    message: 'Pan the map or widen your filters.',
                    layout: CatchEmptyStateLayout.inline,
                  ),
                )
              : _PeekRailContent(
                  items: value.items,
                  selectedEventId: selectedEventId,
                  onEventTapped: onEventTapped,
                  onSeeAll: onSeeAll,
                ),
      },
    ),
  ];
}

class _PeekRailContent extends ConsumerStatefulWidget {
  const _PeekRailContent({
    required this.items,
    required this.selectedEventId,
    required this.onEventTapped,
    required this.onSeeAll,
  });

  final List<ExploreEventItem> items;
  final String? selectedEventId;
  final ValueChanged<Event> onEventTapped;
  final VoidCallback onSeeAll;

  @override
  ConsumerState<_PeekRailContent> createState() => _PeekRailContentState();
}

class _PeekRailContentState extends ConsumerState<_PeekRailContent> {
  final ScrollController _railController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant _PeekRailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedEventId != widget.selectedEventId ||
        oldWidget.items != widget.items) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  @override
  void dispose() {
    _railController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final items = widget.items;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.micro2,
        CatchSpacing.s5,
        CatchSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  items.length == 1
                      ? '1 event near you'
                      : '${items.length} events near you',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.titleM(context),
                ),
              ),
              gapW8,
              Tooltip(
                message: 'See all nearby events',
                child: Semantics(
                  button: true,
                  label: 'See all nearby events',
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      key: const ValueKey('explore-peek-see-all-button'),
                      onTap: widget.onSeeAll,
                      borderRadius: BorderRadius.circular(CatchRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CatchSpacing.s2,
                          vertical: CatchSpacing.micro3,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'See all',
                              style: CatchTextStyles.labelL(
                                context,
                                color: t.primary,
                              ),
                            ),
                            gapW4,
                            Icon(
                              CatchIcons.forwardArrow,
                              size: 16,
                              color: t.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          gapH10,
          SizedBox(
            height: 96,
            child: ListView.separated(
              controller: _railController,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: _peekCardSpacing),
              itemBuilder: (context, index) {
                final item = items[index];
                return CatchEventCardPeek(
                  key: ValueKey('explore-peek-${item.event.id}'),
                  title: item.event.title,
                  subtitle: '${item.club.name} · ${item.event.locationName}',
                  kickerLabel: _peekKicker(item),
                  distanceLabel: _peekDistanceLabel(item),
                  photoUrl: item.event.photoUrl,
                  pace: item.event.pace,
                  activityKind: item.event.activityKind,
                  selected: item.event.id == widget.selectedEventId,
                  width: _peekCardWidth,
                  onTap: () => _handleTap(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToSelected() {
    if (!mounted || !_railController.hasClients) return;
    final selectedEventId = widget.selectedEventId;
    if (selectedEventId == null) return;
    final selectedIndex = widget.items.indexWhere(
      (item) => item.event.id == selectedEventId,
    );
    if (selectedIndex < 0) return;
    final targetOffset = selectedIndex * (_peekCardWidth + _peekCardSpacing);
    final clampedOffset = targetOffset
        .clamp(0.0, _railController.position.maxScrollExtent)
        .toDouble();
    unawaited(
      _railController.animateTo(
        clampedOffset,
        duration: CatchMotion.base,
        curve: CatchMotion.springCurve,
      ),
    );
  }

  void _handleTap(BuildContext context, ExploreEventItem item) {
    final isSelected = item.event.id == widget.selectedEventId;
    if (!isSelected) {
      ref
          .read(appAnalyticsProvider)
          .logEvent(
            AnalyticsEvents.exploreMapEventSelected,
            parameters: {
              AnalyticsParameters.eventId: item.event.id,
              AnalyticsParameters.clubId: item.club.id,
              AnalyticsParameters.exploreSource: 'peek_rail',
              AnalyticsParameters.activityKind: item.event.activityKind.name,
              AnalyticsParameters.availabilityStatus:
                  item.availability?.status.name,
              AnalyticsParameters.distanceKm: item.distanceFromUserKm == null
                  ? null
                  : double.parse(item.distanceFromUserKm!.toStringAsFixed(2)),
            },
          );
      widget.onEventTapped(item.event);
      return;
    }
    ref
        .read(appAnalyticsProvider)
        .logEvent(
          AnalyticsEvents.exploreEventOpened,
          parameters: {
            AnalyticsParameters.eventId: item.event.id,
            AnalyticsParameters.clubId: item.club.id,
            AnalyticsParameters.exploreSource: 'peek_rail',
            AnalyticsParameters.activityKind: item.event.activityKind.name,
            AnalyticsParameters.availabilityStatus:
                item.availability?.status.name,
            AnalyticsParameters.distanceKm: item.distanceFromUserKm == null
                ? null
                : double.parse(item.distanceFromUserKm!.toStringAsFixed(2)),
          },
        );
    context.pushNamed(
      Routes.eventDetailScreen.name,
      pathParameters: {'clubId': item.event.clubId, 'eventId': item.event.id},
      extra: item.event,
    );
  }
}

class _PeekRailSkeleton extends StatelessWidget {
  const _PeekRailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.micro2,
        CatchSpacing.s5,
        CatchSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: 132),
          gapH10,
          Row(
            children: [
              CatchSkeleton.card(width: _peekCardWidth, height: 96),
              gapW10,
              CatchSkeleton.card(width: _peekCardWidth, height: 96),
            ],
          ),
        ],
      ),
    );
  }
}

String _peekKicker(ExploreEventItem item) {
  final start = item.event.startTime;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final eventDay = DateTime(start.year, start.month, start.day);
  final diffDays = eventDay.difference(today).inDays;
  final time = EventFormatters.time(start);
  return switch (diffDays) {
    0 => 'Today · $time',
    1 => 'Tomorrow · $time',
    _ => '${EventFormatters.shortWeekday(start)} · $time',
  };
}

String? _peekDistanceLabel(ExploreEventItem item) {
  final distance = item.distanceFromUserKm;
  if (distance == null) return null;
  if (distance < 1) return '${(distance * 1000).round()} m';
  if (distance >= 10) return '${distance.round()} km';
  return '${distance.toStringAsFixed(1)} km';
}
