import 'package:catch_dating_app/core/motion/catch_transitions.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/events.dart'
    show EventMapItem, EventMapView, EventMapViewModel, hasEventMapPin;
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Full-screen event map opened from the Explore feed's map pill.
///
/// Design-system Explore demotes the map from an always-on canvas to a focused,
/// dismissible view: the feed is the primary surface, and this route shows the
/// same nearby events as pins. Tapping a pin selects it; tapping the selected
/// event card opens that event; the distance ring cycles the shared Explore
/// distance filter.
class ExploreMapScreen extends ConsumerStatefulWidget {
  const ExploreMapScreen({
    super.key,
    // Keep the Explore map usable when native Google Maps key validation fails.
    this.enableNetworkTiles = false,
    this.initialSelectedEventId,
  });

  final bool enableNetworkTiles;
  final String? initialSelectedEventId;

  @override
  ConsumerState<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends ConsumerState<ExploreMapScreen> {
  String? _selectedEventId;

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.initialSelectedEventId;
  }

  @override
  void didUpdateWidget(covariant ExploreMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelectedEventId != widget.initialSelectedEventId &&
        _selectedEventId == oldWidget.initialSelectedEventId) {
      _selectedEventId = widget.initialSelectedEventId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final feedAsync = ref.watch(exploreFeedViewModelProvider);
    final filters = ref.watch(exploreFiltersProvider);
    final distanceRingRadiusKm = exploreDistanceFilterKm(
      filters.distanceFilter,
    );
    final mapViewModel = feedAsync.whenData(exploreMapViewModelFromFeed);
    final feed = feedAsync.asData?.value;
    final selectedItem = _selectedItemFor(feed);
    _clearSelectionIfMissing(feed);

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
              enableNetworkTiles: widget.enableNetworkTiles,
              viewModel: mapViewModel,
              distanceRingRadiusKm: distanceRingRadiusKm,
              selectedEventId: _selectedEventId,
              onRetry: () => ref.invalidate(exploreFeedViewModelProvider),
              onEventSelected: _selectEvent,
              onSelectionCleared: _clearSelection,
              onDistanceRingTapped: cycleDistanceFilter,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: CatchInsets.pageBody.copyWith(
                  top: CatchSpacing.s5,
                  bottom: CatchSpacing.s5,
                ),
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: CatchInsets.pageBody.copyWith(top: 0),
                child: AnimatedSwitcher(
                  duration: _mapCardMotionDuration(context),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: _selectedCardTransition,
                  child: selectedItem == null
                      ? const SizedBox.shrink(
                          key: ValueKey<String>('no-selected-map-event'),
                        )
                      : _ExploreMapSelectedEventCard(
                          key: ValueKey<String>(selectedItem.event.id),
                          item: selectedItem,
                          onTap: (event, heroTag) =>
                              _openEvent(context, event, heroTag: heroTag),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectEvent(Event event) {
    catchSelectionHaptic();
    setState(() => _selectedEventId = event.id);
  }

  void _clearSelection() {
    if (_selectedEventId == null) return;
    catchSelectionHaptic();
    setState(() => _selectedEventId = null);
  }

  ExploreEventItem? _selectedItemFor(ExploreFeedViewModel? feed) {
    final selectedEventId = _selectedEventId;
    if (selectedEventId == null || feed == null) return null;
    for (final item in feed.items) {
      if (item.event.id == selectedEventId && hasEventMapPin(item.event)) {
        return item;
      }
    }
    return null;
  }

  void _clearSelectionIfMissing(ExploreFeedViewModel? feed) {
    final selectedEventId = _selectedEventId;
    if (selectedEventId == null || feed == null) return;
    if (_selectedItemFor(feed) != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedEventId != selectedEventId) return;
      setState(() => _selectedEventId = null);
    });
  }

  void _openEvent(BuildContext context, Event event, {Object? heroTag}) {
    catchSelectionHaptic();
    context.pushNamed(
      Routes.eventDetailScreen.name,
      pathParameters: {'clubId': event.clubId, 'eventId': event.id},
      extra: EventDetailRouteExtra(
        initialEvent: event,
        transition: EventDetailRouteTransition.mapSelectedCard,
        presentationMode: EventDetailPresentationMode.ticket,
        heroTag: heroTag,
      ),
    );
  }
}

class _ExploreMapSelectedEventCard extends StatelessWidget {
  const _ExploreMapSelectedEventCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ExploreEventItem item;
  final void Function(Event event, Object heroTag) onTap;

  @override
  Widget build(BuildContext context) {
    final state = ExploreEventRowState.from(item);
    final heroTag = eventTicketHeroTag(item.event.id, 'map');
    return DecoratedBox(
      decoration: const BoxDecoration(boxShadow: CatchElevation.overlay),
      child: EventDateRailCard(
        event: item.event,
        kicker: exploreEventMapKicker(item),
        supportingLabel: state.supportingLabel,
        priceLabel: state.priceLabel,
        capacityLabel: state.capacityLabel,
        statusLabel: state.statusLabel,
        heroTag: heroTag,
        onTap: () => onTap(item.event, heroTag),
      ),
    );
  }
}

Widget _selectedCardTransition(Widget child, Animation<double> animation) {
  final offsetAnimation = animation.drive(
    Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic)),
  );
  return FadeTransition(
    opacity: animation,
    child: SlideTransition(position: offsetAnimation, child: child),
  );
}

Duration _mapCardMotionDuration(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations == true
      ? Duration.zero
      : CatchMotion.fast;
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
