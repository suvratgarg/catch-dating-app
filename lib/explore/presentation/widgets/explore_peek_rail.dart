import 'dart:async';

import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_capacity_presenter.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _ticketRailCardWidth = CatchLayout.exploreTicketRailCardWidth;
const double _ticketRailHeight = CatchLayout.exploreTicketRailHeight;
const double _ticketRailCardSpacing = CatchSpacing.s3;
const double _mapAreaScopeThresholdMeters = 25000;
const String _seeAllNearbyEventsLabel = 'See all nearby events';
const EdgeInsets _mapSheetLeadPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5,
  CatchSpacing.micro2,
  CatchSpacing.s5,
  CatchSpacing.s4,
);

enum ExploreMapSheetLeadMode { collapsedSummary, selectedEvent, nearbyRail }

/// Builds the lead sliver for the Explore map sheet.
///
/// The PEEK snap uses only an aggregate summary. Selected pins render the
/// shared ticket card unless the selected event is the feed spotlight, and the
/// unselected half/full sheet keeps the nearby ticket rail.
List<Widget> buildExploreMapSheetLeadSlivers({
  required WidgetRef ref,
  required String? selectedEventId,
  required LocationCoordinate? cameraCenter,
  required ExploreFilterSelection filters,
  required String scopeLabel,
  required ExploreMapSheetLeadMode leadMode,
  required ValueChanged<Event> onEventTapped,
  required VoidCallback onSeeAll,
}) {
  final feedAsync = ref.watch(exploreFeedViewModelProvider);
  if (feedAsync case AsyncData(:final value)
      when value.isEmpty &&
          leadMode != ExploreMapSheetLeadMode.collapsedSummary) {
    return const <Widget>[];
  }
  return [
    SliverToBoxAdapter(
      child: switch (feedAsync) {
        AsyncLoading() =>
          leadMode == ExploreMapSheetLeadMode.collapsedSummary
              ? CollapsedMapSummary(
                  count: null,
                  scopeLabel: scopeLabel,
                  filters: filters,
                )
              : PeekRailSkeleton(),
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
        AsyncData(:final value) => ExploreMapSheetLead(
          items: _sortItemsForCamera(value.items, cameraCenter),
          spotlightEventId: value.featuredItem?.event.id,
          selectedEventId: selectedEventId,
          scopeLabel: scopeLabel,
          filters: filters,
          leadMode: leadMode,
          onEventTapped: onEventTapped,
          onSeeAll: onSeeAll,
        ),
      },
    ),
  ];
}

List<ExploreEventItem> _sortItemsForCamera(
  List<ExploreEventItem> items,
  LocationCoordinate? cameraCenter,
) {
  if (cameraCenter == null) return items;
  final sorted = [...items];
  sorted.sort((left, right) {
    final leftDistance = _distanceFromCamera(left, cameraCenter);
    final rightDistance = _distanceFromCamera(right, cameraCenter);
    if (leftDistance == null && rightDistance == null) {
      return left.event.startTime.compareTo(right.event.startTime);
    }
    if (leftDistance == null) return 1;
    if (rightDistance == null) return -1;
    final distanceCompare = leftDistance.compareTo(rightDistance);
    if (distanceCompare != 0) return distanceCompare;
    return left.event.startTime.compareTo(right.event.startTime);
  });
  return List.unmodifiable(sorted);
}

double? _distanceFromCamera(
  ExploreEventItem item,
  LocationCoordinate cameraCenter,
) {
  final eventLocation = LocationCoordinate.fromNullable(
    latitude: item.event.effectiveStartingPointLat,
    longitude: item.event.effectiveStartingPointLng,
  );
  if (eventLocation == null) return null;
  return cameraCenter.distanceTo(eventLocation);
}

class ExploreMapSheetLead extends ConsumerWidget {
  const ExploreMapSheetLead({
    super.key,
    required this.items,
    this.spotlightEventId,
    this.selectedEventId,
    required this.scopeLabel,
    required this.filters,
    required this.leadMode,
    required this.onEventTapped,
    required this.onSeeAll,
  });

  final List<ExploreEventItem> items;
  final String? spotlightEventId;
  final String? selectedEventId;
  final String scopeLabel;
  final ExploreFilterSelection filters;
  final ExploreMapSheetLeadMode leadMode;
  final ValueChanged<Event> onEventTapped;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  if (leadMode == ExploreMapSheetLeadMode.collapsedSummary) {
    return CollapsedMapSummary(
      count: items.length,
      scopeLabel: scopeLabel,
      filters: filters,
    );
  }

  if (leadMode == ExploreMapSheetLeadMode.selectedEvent) {
    final selectedItem = _selectedItem(items, selectedEventId);
    if (selectedItem != null) {
      return _buildSelectedEventLead(
        ref,
        item: selectedItem,
        spotlightEventId: spotlightEventId,
      );
    }
  }

  return ExplorePeekRailContent(
    items: items,
    selectedEventId: selectedEventId,
    onEventTapped: onEventTapped,
    onSeeAll: onSeeAll,
  );
  }
}

ExploreEventItem? _selectedItem(
  List<ExploreEventItem> items,
  String? selectedEventId,
) {
  if (selectedEventId == null) return null;
  for (final item in items) {
    if (item.event.id == selectedEventId) return item;
  }
  return null;
}

class CollapsedMapSummary extends StatelessWidget {
  const CollapsedMapSummary({
    super.key,
    required this.count,
    required this.scopeLabel,
    required this.filters,
  });

  final int? count;
  final String scopeLabel;
  final ExploreFilterSelection filters;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: _mapSheetLeadPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _collapsedTitle(count),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: CatchTextStyles.sectionTitle(context),
          ),
          gapH4,
          Text(
            _collapsedScopeLabel(scopeLabel: scopeLabel, filters: filters),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

Widget _buildSelectedEventLead(
  WidgetRef ref, {
  required ExploreEventItem item,
  required String? spotlightEventId,
}) {
  return Builder(
    builder: (context) {
      final event = item.event;
      final isSpotlight = event.id == spotlightEventId;
      final source = 'map_selected_card';
      return Padding(
        padding: _mapSheetLeadPadding,
        child: isSpotlight
            ? CatchEventCard.spotlight(
                key: ValueKey('explore-selected-${event.id}'),
                title: item.event.title,
                supportingLabel: _eventTicketSubtitle(item),
                timeLabel: EventFormatters.time(event.startTime),
                countdownLabel: _selectedCountdownLabel(event.startTime),
                priceLabel: item.priceLabel,
                capacityLabel: _selectedCapacityLabel(item),
                activityKind: event.activityKind,
                kicker: item.distanceFromUserLabel ?? 'Spotlight pick',
                heroTag: eventSpotlightHeroTag(event.id, source),
                onTap: () => _openEvent(
                  context,
                  ref,
                  item,
                  source,
                  presentationMode: EventDetailPresentationMode.spotlightDark,
                  transition: EventDetailRouteTransition.spotlightCard,
                  heroTag: eventSpotlightHeroTag(event.id, source),
                ),
              )
            : ExploreEventTicketCard(
                key: ValueKey('explore-selected-${event.id}'),
                item: item,
                statusLabel: item.distanceFromUserLabel ?? 'Map pick',
                heroTag: eventTicketHeroTag(event.id, source),
                onTap: () => _openEvent(
                  context,
                  ref,
                  item,
                  source,
                  presentationMode: EventDetailPresentationMode.ticket,
                  transition: EventDetailRouteTransition.mapSelectedCard,
                  heroTag: eventTicketHeroTag(event.id, source),
                ),
              ),
      );
    },
  );
}

class ExploreEventTicketCard extends StatelessWidget {
  const ExploreEventTicketCard({
    super.key,
    required this.item,
    this.statusLabel,
    this.width,
    this.heroTag,
    this.onTap,
  });

  final ExploreEventItem item;
  final String? statusLabel;
  final double? width;
  final Object? heroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final event = item.event;
    return CatchEventCard.ticket(
      width: width,
      title: event.title,
      subtitle: _eventTicketSubtitle(item),
      timeLabel: EventFormatters.time(event.startTime),
      countdownLabel: _selectedCountdownLabel(event.startTime),
      priceLabel: item.priceLabel,
      capacityLabel: _selectedCapacityLabel(item),
      activityKind: event.activityKind,
      statusLabel: statusLabel,
      clockTime: TimeOfDay.fromDateTime(event.startTime),
      heroTag: heroTag,
      onTap: onTap,
    );
  }
}

class ExplorePeekRailContent extends ConsumerStatefulWidget {
  const ExplorePeekRailContent({
    super.key,
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
  ConsumerState<ExplorePeekRailContent> createState() =>
      _ExplorePeekRailContentState();
}

class _ExplorePeekRailContentState
    extends ConsumerState<ExplorePeekRailContent> {
  final ScrollController _railController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncRailPosition(orderChanged: false),
    );
  }

  @override
  void didUpdateWidget(covariant ExplorePeekRailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final orderChanged = !_sameEventOrder(oldWidget.items, widget.items);
    if (oldWidget.selectedEventId != widget.selectedEventId || orderChanged) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _syncRailPosition(orderChanged: orderChanged),
      );
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
      padding: _mapSheetLeadPadding,
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
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
              gapW8,
              Tooltip(
                message: _seeAllNearbyEventsLabel,
                child: Semantics(
                  button: true,
                  label: _seeAllNearbyEventsLabel,
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
            height: _ticketRailHeight,
            child: ListView.separated(
              controller: _railController,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: _ticketRailCardSpacing),
              itemBuilder: (context, index) {
                final item = items[index];
                return Align(
                  alignment: Alignment.topLeft,
                  child: ExploreEventTicketCard(
                    key: ValueKey('explore-peek-${item.event.id}'),
                    item: item,
                    width: _ticketRailCardWidth,
                    statusLabel: item.event.id == widget.selectedEventId
                        ? 'Selected'
                        : _ticketStatusLabel(item),
                    heroTag: item.event.id == widget.selectedEventId
                        ? eventTicketHeroTag(item.event.id, 'peek_rail')
                        : null,
                    onTap: () => _handleTap(context, item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _syncRailPosition({required bool orderChanged}) {
    if (!mounted || !_railController.hasClients) return;
    final selectedEventId = widget.selectedEventId;
    if (selectedEventId == null) {
      if (orderChanged && _railController.offset > 0) {
        _railController.jumpTo(0);
      }
      return;
    }
    final selectedIndex = widget.items.indexWhere(
      (item) => item.event.id == selectedEventId,
    );
    if (selectedIndex < 0) return;
    final targetOffset =
        selectedIndex * (_ticketRailCardWidth + _ticketRailCardSpacing);
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
      _logMapEventSelected(ref, item, 'peek_rail');
      widget.onEventTapped(item.event);
      return;
    }
    _openEvent(
      context,
      ref,
      item,
      'peek_rail',
      presentationMode: EventDetailPresentationMode.ticket,
      transition: EventDetailRouteTransition.ticketCard,
      heroTag: eventTicketHeroTag(item.event.id, 'peek_rail'),
    );
  }
}

bool _sameEventOrder(
  List<ExploreEventItem> left,
  List<ExploreEventItem> right,
) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i += 1) {
    if (left[i].event.id != right[i].event.id) return false;
  }
  return true;
}

class PeekRailSkeleton extends StatelessWidget {
  const PeekRailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _mapSheetLeadPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
          gapH10,
          SizedBox(
            height: _ticketRailHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: _ticketRailCardSpacing),
              itemBuilder: (_, _) => CatchSkeleton.card(
                width: _ticketRailCardWidth,
                height: _ticketRailHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _collapsedTitle(int? count) {
  if (count == null) return 'Finding events nearby';
  if (count == 0) return 'No events in this view';
  if (count == 1) return '1 event nearby';
  return '$count events nearby';
}

String _collapsedScopeLabel({
  required String scopeLabel,
  required ExploreFilterSelection filters,
}) {
  final parts = <String>[
    scopeLabel,
    _timeScopeLabel(filters.timeFilter),
    if (filters.distanceFilter != ExploreDistanceFilter.any)
      'within ${_distanceScopeLabel(filters.distanceFilter)}',
    if (filters.joinedOnly) 'joined',
    if (filters.highRatedOnly) 'high rated',
    if (filters.activityTag != null) filters.activityTag!,
    if (filters.area != null) filters.area!,
  ];
  return parts.join(' · ');
}

String exploreMapScopeLabel({
  required CityData city,
  required LocationCoordinate? cameraCenter,
}) {
  if (cameraCenter == null) return city.label;
  final cityCenter = LocationCoordinate(city.latitude, city.longitude);
  return cityCenter.distanceTo(cameraCenter) >= _mapAreaScopeThresholdMeters
      ? 'Map area'
      : city.label;
}

String _timeScopeLabel(ExploreTimeFilter filter) {
  return switch (filter) {
    ExploreTimeFilter.anytime => 'Anytime',
    ExploreTimeFilter.tonight => 'Tonight',
    ExploreTimeFilter.tomorrow => 'Tomorrow',
    ExploreTimeFilter.weekend => 'Weekend',
    ExploreTimeFilter.thisWeek => 'This week',
  };
}

String _distanceScopeLabel(ExploreDistanceFilter filter) {
  return switch (filter) {
    ExploreDistanceFilter.any => 'any distance',
    ExploreDistanceFilter.oneKm => '1 km',
    ExploreDistanceFilter.threeKm => '3 km',
    ExploreDistanceFilter.fiveKm => '5 km',
    ExploreDistanceFilter.tenKm => '10 km',
  };
}

String _eventTicketSubtitle(ExploreEventItem item) {
  final event = item.event;
  return '${item.club.name} · ${event.locationName}';
}

String? _ticketStatusLabel(ExploreEventItem item) {
  return item.distanceFromUserLabel ?? item.availabilityLabel;
}

String _selectedCapacityLabel(ExploreEventItem item) {
  return EventCapacityPresenter(
    item.event,
  ).activityGoingAvailabilityLabel(availabilityLabel: item.availabilityLabel);
}

String _selectedCountdownLabel(DateTime startTime) {
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

void _logMapEventSelected(WidgetRef ref, ExploreEventItem item, String source) {
  ref
      .read(appAnalyticsProvider)
      .logEvent(
        AnalyticsEvents.exploreMapEventSelected,
        parameters: _analyticsParameters(item, source),
      );
}

void _openEvent(
  BuildContext context,
  WidgetRef ref,
  ExploreEventItem item,
  String source, {
  required EventDetailPresentationMode presentationMode,
  required EventDetailRouteTransition transition,
  required Object heroTag,
}) {
  ref
      .read(appAnalyticsProvider)
      .logEvent(
        AnalyticsEvents.exploreEventOpened,
        parameters: _analyticsParameters(item, source),
      );
  context.pushNamed(
    Routes.eventDetailScreen.name,
    pathParameters: {'clubId': item.event.clubId, 'eventId': item.event.id},
    extra: EventDetailRouteExtra(
      initialEvent: item.event,
      transition: transition,
      presentationMode: presentationMode,
      heroTag: heroTag,
    ),
  );
}

Map<String, Object?> _analyticsParameters(
  ExploreEventItem item,
  String source,
) {
  return {
    AnalyticsParameters.eventId: item.event.id,
    AnalyticsParameters.clubId: item.club.id,
    AnalyticsParameters.exploreSource: source,
    AnalyticsParameters.activityKind: item.event.activityKind.name,
    AnalyticsParameters.availabilityStatus: item.availability?.status.name,
    AnalyticsParameters.distanceKm: item.distanceFromUserKm == null
        ? null
        : double.parse(item.distanceFromUserKm!.toStringAsFixed(2)),
  };
}
