import 'dart:async';

import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_event_card_peek.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const double _peekCardWidth = 264;
const double _peekCardSpacing = CatchSpacing.s3;
const double _mapAreaScopeThresholdMeters = 25000;
const String _seeAllNearbyEventsLabel = 'See all nearby events';

enum ExploreMapSheetLeadMode { collapsedSummary, selectedEvent, nearbyRail }

/// Builds the lead sliver for the Explore map sheet.
///
/// The PEEK snap uses only an aggregate summary, selected pins promote a
/// single event hero, and the unselected half/full sheet keeps the nearby rail.
List<Widget> buildExploreMapSheetLeadSlivers({
  required WidgetRef ref,
  required String? selectedEventId,
  required LocationCoordinate? cameraCenter,
  required ClubBrowseFilterSelection filters,
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
              ? _CollapsedMapSummary(
                  count: null,
                  scopeLabel: scopeLabel,
                  filters: filters,
                )
              : const _PeekRailSkeleton(),
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
        AsyncData(:final value) => _ExploreMapSheetLead(
          items: _sortItemsForCamera(value.items, cameraCenter),
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

class _ExploreMapSheetLead extends StatelessWidget {
  const _ExploreMapSheetLead({
    required this.items,
    required this.selectedEventId,
    required this.scopeLabel,
    required this.filters,
    required this.leadMode,
    required this.onEventTapped,
    required this.onSeeAll,
  });

  final List<ExploreEventItem> items;
  final String? selectedEventId;
  final String scopeLabel;
  final ClubBrowseFilterSelection filters;
  final ExploreMapSheetLeadMode leadMode;
  final ValueChanged<Event> onEventTapped;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (leadMode == ExploreMapSheetLeadMode.collapsedSummary) {
      return _CollapsedMapSummary(
        count: items.length,
        scopeLabel: scopeLabel,
        filters: filters,
      );
    }

    if (leadMode == ExploreMapSheetLeadMode.selectedEvent) {
      final selectedItem = _selectedItem(items, selectedEventId);
      if (selectedItem != null) {
        return _SelectedEventLead(item: selectedItem);
      }
    }

    return _PeekRailContent(
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

class _CollapsedMapSummary extends StatelessWidget {
  const _CollapsedMapSummary({
    required this.count,
    required this.scopeLabel,
    required this.filters,
  });

  final int? count;
  final String scopeLabel;
  final ClubBrowseFilterSelection filters;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.micro2,
        CatchSpacing.s5,
        CatchSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _collapsedTitle(count),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: CatchTextStyles.titleM(context),
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

class _SelectedEventLead extends ConsumerWidget {
  const _SelectedEventLead({required this.item});

  final ExploreEventItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = item.event;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.micro2,
        CatchSpacing.s5,
        CatchSpacing.s4,
      ),
      child: CatchEventSpotlightCard(
        key: ValueKey('explore-selected-${event.id}'),
        title: item.event.title,
        supportingLabel: _selectedSupportingLabel(item),
        timeLabel: EventFormatters.time(event.startTime),
        countdownLabel: _selectedCountdownLabel(event.startTime),
        priceLabel: item.priceLabel,
        capacityLabel: _selectedCapacityLabel(item),
        activityKind: event.activityKind,
        kicker: item.distanceFromUserLabel ?? 'Map pick',
        visualHeroTag: eventPhotoHeroTag(event.id),
        onTap: () => _openEvent(context, ref, item, 'map_selected_card'),
      ),
    );
  }
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncRailPosition(orderChanged: false),
    );
  }

  @override
  void didUpdateWidget(covariant _PeekRailContent oldWidget) {
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
                  preferActivityArtwork: true,
                  onTap: () => _handleTap(context, item),
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
      _logMapEventSelected(ref, item, 'peek_rail');
      widget.onEventTapped(item.event);
      return;
    }
    _openEvent(context, ref, item, 'peek_rail');
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
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: _peekCardSpacing),
              itemBuilder: (_, _) =>
                  CatchSkeleton.card(width: _peekCardWidth, height: 96),
            ),
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

String _collapsedTitle(int? count) {
  if (count == null) return 'Finding events nearby';
  if (count == 0) return 'No events in this view';
  if (count == 1) return '1 event nearby';
  return '$count events nearby';
}

String _collapsedScopeLabel({
  required String scopeLabel,
  required ClubBrowseFilterSelection filters,
}) {
  final parts = <String>[
    scopeLabel,
    _timeScopeLabel(filters.timeFilter),
    if (filters.distanceFilter != ExploreDistanceFilter.any)
      'within ${_distanceScopeLabel(filters.distanceFilter)}',
    if (filters.joinedOnly) 'joined',
    if (filters.hostedOnly) 'hosted',
    if (filters.highRatedOnly) 'high rated',
    ?filters.activityTag,
    ?filters.area,
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

String _selectedSupportingLabel(ExploreEventItem item) {
  final event = item.event;
  return [
    item.club.name,
    event.locationName,
    event.activitySummaryLabel,
  ].join(' - ');
}

String _selectedCapacityLabel(ExploreEventItem item) {
  final event = item.event;
  final availability = item.availabilityLabel;
  final base = '${event.signedUpCount} going';
  if (availability != null &&
      availability.isNotEmpty &&
      availability.toLowerCase() != 'open') {
    return '$base - $availability';
  }
  if (event.spotsRemaining > 0) return '$base - ${event.spotsRemaining} left';
  return '$base - full';
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
  String source,
) {
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
      transition: source == 'map_selected_card'
          ? EventDetailRouteTransition.mapSelectedCard
          : EventDetailRouteTransition.platform,
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
