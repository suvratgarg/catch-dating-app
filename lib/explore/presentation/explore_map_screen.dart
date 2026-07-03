import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/events.dart'
    show EventMapItem, EventMapView, EventMapViewModel, hasEventMapPin;
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Full-screen event map opened from the Explore feed's map pill.
///
/// Design-system Explore demotes the map from an always-on canvas to a focused,
/// dismissible view: the feed is the primary surface, and this route shows the
/// same nearby events as pins. Tapping a pin opens that event; the distance ring
/// cycles the shared Explore distance filter.
class ExploreMapScreen extends ConsumerWidget {
  const ExploreMapScreen({
    super.key,
    this.enableNetworkTiles = true,
    this.initialSelectedEventId,
  });

  final bool enableNetworkTiles;
  final String? initialSelectedEventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final feedAsync = ref.watch(exploreFeedViewModelProvider);
    final filters = ref.watch(exploreFiltersProvider);
    final distanceRingRadiusKm = exploreDistanceFilterKm(
      filters.distanceFilter,
    );
    final mapViewModel = feedAsync.whenData(exploreMapViewModelFromFeed);
    void cycleDistanceFilter() {
      catchSelectionHaptic();
      final controller = ref.read(exploreFiltersProvider.notifier);
      final current = ref.read(exploreFiltersProvider).distanceFilter;
      controller.setDistanceFilter(switch (current) {
        ExploreDistanceFilter.any => ExploreDistanceFilter.oneKm,
        ExploreDistanceFilter.oneKm => ExploreDistanceFilter.threeKm,
        ExploreDistanceFilter.threeKm => ExploreDistanceFilter.fiveKm,
        ExploreDistanceFilter.fiveKm => ExploreDistanceFilter.tenKm,
        ExploreDistanceFilter.tenKm => ExploreDistanceFilter.any,
      });
    }

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: EventMapView(
              enableNetworkTiles: enableNetworkTiles,
              viewModel: mapViewModel,
              distanceRingRadiusKm: distanceRingRadiusKm,
              initialSelectedEventId: initialSelectedEventId,
              onRetry: () => ref.invalidate(exploreFeedViewModelProvider),
              onEventSelected: (event) => _openEvent(context, event),
              onDistanceRingTapped: cycleDistanceFilter,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(CatchSpacing.s5),
                child: CatchIconButton(
                  variant: CatchIconButtonVariant.float,
                  tooltip: 'Back to Explore',
                  onTap: () {
                    catchSelectionHaptic();
                    if (context.canPop()) context.pop();
                  },
                  child: Icon(CatchIcons.backArrow),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEvent(BuildContext context, Event event) {
    catchSelectionHaptic();
    context.pushNamed(
      Routes.eventDetailScreen.name,
      pathParameters: {'clubId': event.clubId, 'eventId': event.id},
      extra: EventDetailRouteExtra(initialEvent: event),
    );
  }
}

/// Builds the [EventMapViewModel] (pins + ordering) from the Explore feed.
EventMapViewModel exploreMapViewModelFromFeed(ExploreFeedViewModel feed) {
  final items = [
    for (final item in feed.items)
      EventMapItem(
        event: item.event,
        status: item.status,
        clubName: item.club.name,
      ),
  ]..sort((a, b) => a.event.startTime.compareTo(b.event.startTime));
  final pinnedItems = items
      .where((item) => hasEventMapPin(item.event))
      .toList(growable: false);

  return EventMapViewModel(
    events: List.unmodifiable(items.map((item) => item.event)),
    pinnedEvents: List.unmodifiable(pinnedItems.map((item) => item.event)),
    items: List.unmodifiable(items),
    pinnedItems: List.unmodifiable(pinnedItems),
  );
}
