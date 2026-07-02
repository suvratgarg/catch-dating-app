import 'dart:math' as math;

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:flutter/material.dart';

enum ExploreDiscoveryEmptyKind {
  noSourceClubs,
  noSearchResults,
  noFilterResults,
  noFilteredSearchResults,
}

enum ExploreDiscoveryEmptyAction {
  none,
  clearSearch,
  clearFilters,
  clearSearchAndFilters,
}

enum ExploreScreenBodyKind { loading, error, content, empty }

enum ExploreScreenRetryTarget { explore, eventFeed }

const int minimumExploreThisWeekRecommendationCount = 5;

class ExploreMapLauncherState {
  const ExploreMapLauncherState({required this.label});

  factory ExploreMapLauncherState.from({required int? eventFeedCount}) {
    return ExploreMapLauncherState(
      label: eventFeedCount == null || eventFeedCount == 0
          ? 'Map'
          : 'Map · $eventFeedCount',
    );
  }

  final String label;
}

class ExploreCityTriggerState {
  const ExploreCityTriggerState({
    required this.tooltipLabel,
    required this.semanticLabel,
    required this.scopeLabel,
    required this.icon,
  });

  factory ExploreCityTriggerState.from({
    required CityData city,
    required bool focused,
  }) {
    final chooseLabel = 'Choose city: ${city.label}';
    return ExploreCityTriggerState(
      tooltipLabel: chooseLabel,
      semanticLabel: chooseLabel,
      scopeLabel: 'EXPLORE · ${city.label}'.toUpperCase(),
      icon: focused
          ? CatchIcons.locationOnRounded
          : CatchIcons.locationOnOutlined,
    );
  }

  final String tooltipLabel;
  final String semanticLabel;
  final String scopeLabel;
  final IconData icon;
}

class ExploreChromeState {
  const ExploreChromeState({
    required this.title,
    required this.subtitle,
    required this.searchValue,
    required this.searchPlaceholder,
    required this.searchTooltip,
    required this.searchSemanticLabel,
    required this.showSearchAction,
    required this.showCoverStory,
    required this.searchExpanded,
    required this.searchAutofocus,
  });

  factory ExploreChromeState.browse({
    required String query,
    required bool showSearchAction,
  }) {
    return ExploreChromeState._(
      query: query,
      showSearchAction: showSearchAction,
      showCoverStory: false,
      searchExpanded: false,
      searchAutofocus: false,
    );
  }

  factory ExploreChromeState.discovery({
    required String query,
    required bool searchRequested,
    required bool hasFeaturedItem,
  }) {
    final searchActive = query.trim().isNotEmpty;
    final showCoverStory = hasFeaturedItem && !searchRequested && !searchActive;
    return ExploreChromeState._(
      query: query,
      showSearchAction: true,
      showCoverStory: showCoverStory,
      searchExpanded: searchRequested || searchActive,
      searchAutofocus: searchRequested,
    );
  }

  const ExploreChromeState._({
    required String query,
    required this.showSearchAction,
    required this.showCoverStory,
    required this.searchExpanded,
    required this.searchAutofocus,
  }) : title = 'Explore',
       subtitle = 'Find an event worth showing up for.',
       searchValue = query,
       searchPlaceholder = 'Search events or clubs',
       searchTooltip = 'Search events or clubs',
       searchSemanticLabel = 'Search events or clubs';

  final String title;
  final String subtitle;
  final String searchValue;
  final String searchPlaceholder;
  final String searchTooltip;
  final String searchSemanticLabel;
  final bool showSearchAction;
  final bool showCoverStory;
  final bool searchExpanded;
  final bool searchAutofocus;
}

class ExploreFilterRailState {
  const ExploreFilterRailState({
    required this.activeCount,
    required this.filterButtonSemanticLabel,
  });

  factory ExploreFilterRailState.from(ExploreFilterSelection filters) {
    final activeCount = activeExploreFilterCount(filters);
    return ExploreFilterRailState(
      activeCount: activeCount,
      filterButtonSemanticLabel: activeCount == 0
          ? 'Open explore filters'
          : 'Open explore filters, $activeCount active',
    );
  }

  final int activeCount;
  final String filterButtonSemanticLabel;
}

class ExploreFilterSheetState {
  const ExploreFilterSheetState({
    required this.activeCount,
    required this.distanceOptions,
    required this.areaOptions,
  });

  factory ExploreFilterSheetState.from({
    required ExploreFilterSelection filters,
    required Iterable<Club> sourceClubs,
  }) {
    return ExploreFilterSheetState(
      activeCount: activeExploreFilterCount(filters),
      distanceOptions: exploreDistanceFilterOptions,
      areaOptions: _areaOptions(sourceClubs, filters.area),
    );
  }

  final int activeCount;
  final List<ExploreDistanceFilterOption> distanceOptions;
  final List<String> areaOptions;
}

class ExploreDistanceFilterOption {
  const ExploreDistanceFilterOption({required this.value, required this.label});

  final ExploreDistanceFilter value;
  final String label;
}

const exploreDistanceFilterOptions = <ExploreDistanceFilterOption>[
  ExploreDistanceFilterOption(value: ExploreDistanceFilter.any, label: 'Any'),
  ExploreDistanceFilterOption(
    value: ExploreDistanceFilter.oneKm,
    label: '1 km',
  ),
  ExploreDistanceFilterOption(
    value: ExploreDistanceFilter.threeKm,
    label: '3 km',
  ),
  ExploreDistanceFilterOption(
    value: ExploreDistanceFilter.fiveKm,
    label: '5 km',
  ),
  ExploreDistanceFilterOption(
    value: ExploreDistanceFilter.tenKm,
    label: '10 km',
  ),
];

int activeExploreFilterCount(ExploreFilterSelection filters) {
  var count = 0;
  if (filters.timeFilter != defaultExploreTimeFilter) count += 1;
  if (filters.distanceFilter != ExploreDistanceFilter.any) count += 1;
  if (filters.highRatedOnly) count += 1;
  if (filters.joinedOnly) count += 1;
  if (filters.activityTag != null) count += 1;
  if (filters.area != null) count += 1;
  return count;
}

class ExploreCollapsedMapSummaryState {
  const ExploreCollapsedMapSummaryState({
    required this.title,
    required this.scopeLabel,
  });

  factory ExploreCollapsedMapSummaryState.from({
    required int? count,
    required String scopeLabel,
    required ExploreFilterSelection filters,
  }) {
    return ExploreCollapsedMapSummaryState(
      title: _collapsedMapTitle(count),
      scopeLabel: _collapsedMapScopeLabel(
        scopeLabel: scopeLabel,
        filters: filters,
      ),
    );
  }

  final String title;
  final String scopeLabel;
}

class ExplorePeekRailState {
  const ExplorePeekRailState({
    required this.title,
    required this.seeAllLabel,
    required this.seeAllButtonLabel,
  });

  factory ExplorePeekRailState.from({required int itemCount}) {
    return ExplorePeekRailState(
      title: itemCount == 1 ? '1 event near you' : '$itemCount events near you',
      seeAllLabel: 'See all nearby events',
      seeAllButtonLabel: 'See all',
    );
  }

  final String title;
  final String seeAllLabel;
  final String seeAllButtonLabel;
}

class ExploreMapEventTicketState {
  const ExploreMapEventTicketState({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.countdownLabel,
    required this.priceLabel,
    required this.capacityLabel,
    required this.spotlightKicker,
    this.statusLabel,
  });

  factory ExploreMapEventTicketState.from(
    ExploreEventItem item, {
    String? statusLabel,
    String? spotlightKicker,
    DateTime? now,
  }) {
    final event = item.event;
    return ExploreMapEventTicketState(
      title: event.title,
      subtitle: _mapEventTicketSubtitle(item),
      timeLabel: EventFormatters.time(event.startTime),
      countdownLabel: _mapEventCountdownLabel(event.startTime, now: now),
      priceLabel: item.priceLabel,
      capacityLabel: _mapEventCapacityLabel(item),
      statusLabel: statusLabel ?? _mapEventTicketStatusLabel(item),
      spotlightKicker:
          spotlightKicker ?? item.distanceFromUserLabel ?? 'Spotlight pick',
    );
  }

  final String title;
  final String subtitle;
  final String timeLabel;
  final String countdownLabel;
  final String priceLabel;
  final String capacityLabel;
  final String spotlightKicker;
  final String? statusLabel;
}

class ExploreCoverStoryState {
  const ExploreCoverStoryState({
    required this.kicker,
    required this.title,
    required this.ctaLabel,
    required this.timePriceLabel,
    required this.attendanceLabel,
  });

  factory ExploreCoverStoryState.from(ExploreEventItem item, {DateTime? now}) {
    return ExploreCoverStoryState(
      kicker: _coverKicker(item, now: now),
      title: item.event.title,
      ctaLabel: 'Claim a seat',
      timePriceLabel:
          '${EventFormatters.time(item.event.startTime)} - ${item.priceLabel}',
      attendanceLabel:
          '${item.event.signedUpCount} going - ${_coverSpotsLabel(item)}',
    );
  }

  final String kicker;
  final String title;
  final String ctaLabel;
  final String timePriceLabel;
  final String attendanceLabel;
}

class ExploreFeedSectionState {
  const ExploreFeedSectionState({
    required this.bodyViewModel,
    required this.resultCountLabel,
    required this.thisWeekItems,
    required this.cards,
  });

  factory ExploreFeedSectionState.from({
    required ExploreFeedViewModel viewModel,
    required List<Club> candidateClubs,
    required Set<String> joinedClubIds,
    required bool showThisWeekList,
    DateTime? now,
  }) {
    final featured = viewModel.featuredItem;
    final bodyItems = viewModel.items
        .where((item) => item != featured)
        .toList(growable: false);
    final bodyViewModel = ExploreFeedViewModel(
      items: bodyItems,
      externalItems: viewModel.externalItems,
    );
    final candidateThisWeekItems = showThisWeekList
        ? topExploreThisWeekRecommendations(bodyItems, now: now)
        : const <ExploreEventItem>[];
    final thisWeekItems =
        candidateThisWeekItems.length >=
            minimumExploreThisWeekRecommendationCount
        ? candidateThisWeekItems
        : const <ExploreEventItem>[];
    final thisWeekEventIds = {for (final item in thisWeekItems) item.event.id};

    return ExploreFeedSectionState(
      bodyViewModel: bodyViewModel,
      resultCountLabel: _exploreResultCountLine(bodyViewModel),
      thisWeekItems: List.unmodifiable(thisWeekItems),
      cards: List.unmodifiable(
        buildExploreMixedFeedCards(
          viewModel: bodyViewModel,
          candidateClubs: candidateClubs,
          joinedClubIds: joinedClubIds,
          excludeEventIds: thisWeekEventIds,
        ),
      ),
    );
  }

  final ExploreFeedViewModel bodyViewModel;
  final String resultCountLabel;
  final List<ExploreEventItem> thisWeekItems;
  final List<ExploreMixedCard> cards;

  bool get isEmpty => cards.isEmpty && thisWeekItems.isEmpty;
}

class ExploreEventRowState {
  const ExploreEventRowState({
    required this.kicker,
    required this.supportingLabel,
    required this.priceLabel,
    required this.capacityLabel,
    required this.statusLabel,
  });

  factory ExploreEventRowState.from(ExploreEventItem item) {
    return ExploreEventRowState(
      kicker: item.club.name,
      supportingLabel: _rowSupportingLabel(item),
      priceLabel: item.priceLabel,
      capacityLabel: _capacityLabel(item),
      statusLabel: _cardStatusLabel(item),
    );
  }

  final String kicker;
  final String supportingLabel;
  final String priceLabel;
  final String capacityLabel;
  final String? statusLabel;
}

class ExploreExternalEventRowState {
  const ExploreExternalEventRowState({
    required this.sourceLabel,
    required this.statusLabel,
    required this.supportingLabel,
    required this.timePriceLabel,
    required this.actionLabel,
    required this.actionSemanticsLabel,
    required this.readOnlySupplyLabel,
    required this.hasExternalLink,
  });

  factory ExploreExternalEventRowState.from(ExploreExternalEventItem item) {
    final event = item.event;
    final hasExternalLink = event.primaryExternalUri != null;
    return ExploreExternalEventRowState(
      sourceLabel: 'FROM ${event.platformLabel.toUpperCase()}',
      statusLabel: 'External',
      supportingLabel: _externalEventSupportingLabel(item),
      timePriceLabel:
          '${EventFormatters.time(event.startTime)} · ${event.priceLabel}',
      actionLabel: hasExternalLink ? 'Open' : 'No link',
      actionSemanticsLabel: hasExternalLink
          ? 'Open external event source'
          : 'External event link unavailable',
      readOnlySupplyLabel: 'READ-ONLY SUPPLY · NO CATCH BOOKING',
      hasExternalLink: hasExternalLink,
    );
  }

  final String sourceLabel;
  final String statusLabel;
  final String supportingLabel;
  final String timePriceLabel;
  final String actionLabel;
  final String actionSemanticsLabel;
  final String readOnlySupplyLabel;
  final bool hasExternalLink;
}

class ExploreClubCardState {
  const ExploreClubCardState({
    required this.memberCountLabel,
    required this.caption,
    required this.title,
    required this.supportingLabel,
    required this.actionLabel,
    required this.rowKicker,
    required this.tags,
  });

  factory ExploreClubCardState.from(Club club, {required bool isSynthetic}) {
    return ExploreClubCardState(
      memberCountLabel: clubMemberCountLabel(club),
      caption: (club.nextEventLabel ?? 'Club to know').toUpperCase(),
      title: club.name,
      supportingLabel: _clubSupportingLabel(club),
      actionLabel: isSynthetic ? 'Preview' : 'View club',
      rowKicker: 'CLUB TO KNOW',
      tags: visibleClubTags(club, limit: 2),
    );
  }

  final String memberCountLabel;
  final String caption;
  final String title;
  final String supportingLabel;
  final String actionLabel;
  final String rowKicker;
  final List<String> tags;
}

sealed class ExploreMixedCard {
  const ExploreMixedCard();
}

class ExploreMixedEventRowCard extends ExploreMixedCard {
  const ExploreMixedEventRowCard(this.item);

  final ExploreEventItem item;
}

class ExploreMixedExternalEventRowCard extends ExploreMixedCard {
  const ExploreMixedExternalEventRowCard(this.item);

  final ExploreExternalEventItem item;
}

class ExploreMixedClubSpotlightCard extends ExploreMixedCard {
  const ExploreMixedClubSpotlightCard(this.club);

  final Club club;
}

class ExploreMixedClubRowCard extends ExploreMixedCard {
  const ExploreMixedClubRowCard(this.club);

  final Club club;
}

List<ExploreMixedCard> buildExploreMixedFeedCards({
  required ExploreFeedViewModel viewModel,
  required List<Club> candidateClubs,
  required Set<String> joinedClubIds,
  Set<String> excludeEventIds = const <String>{},
}) {
  final rankedClubs = rankExploreClubIntermixCandidates(
    candidateClubs,
    joinedClubIds: joinedClubIds,
  );
  final firstClub = rankedClubs.firstOrNull;
  final secondClub = rankedClubs.skip(1).firstOrNull;
  final eventRows = viewModel.items
      .where((item) => !excludeEventIds.contains(item.event.id))
      .toList(growable: true);
  final externalRows = viewModel.externalItems.take(8).toList();
  final cards = <ExploreMixedCard>[];

  if (eventRows.isEmpty) {
    for (final item in externalRows) {
      cards.add(ExploreMixedExternalEventRowCard(item));
    }
    if (firstClub != null) cards.add(ExploreMixedClubSpotlightCard(firstClub));
    if (secondClub != null) cards.add(ExploreMixedClubRowCard(secondClub));
    return cards;
  }

  final leadingCount = eventRows.length >= 2 ? 2 : 1;
  for (var i = 0; i < leadingCount; i += 1) {
    cards.add(ExploreMixedEventRowCard(eventRows.removeAt(0)));
  }
  if (firstClub != null) cards.add(ExploreMixedClubSpotlightCard(firstClub));

  for (var i = 0; i < eventRows.length; i += 1) {
    cards.add(ExploreMixedEventRowCard(eventRows[i]));
    if (i == 1 && secondClub != null) {
      cards.add(ExploreMixedClubRowCard(secondClub));
    }
  }
  for (final item in externalRows) {
    cards.add(ExploreMixedExternalEventRowCard(item));
  }
  return cards;
}

List<Club> rankExploreClubIntermixCandidates(
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

List<ExploreEventItem> topExploreThisWeekRecommendations(
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

String _rowSupportingLabel(ExploreEventItem item) {
  final event = item.event;
  return [
    event.activitySummaryLabel,
    event.locationName,
  ].where((label) => label.trim().isNotEmpty).join(' · ');
}

String _capacityLabel(ExploreEventItem item) {
  return EventCapacityLabels(
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

String _externalEventSupportingLabel(ExploreExternalEventItem item) {
  final event = item.event;
  return _joinExploreLabels([
    event.activityKind.label,
    event.meetingPoint,
    item.distanceFromUserLabel,
  ]);
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

String _joinExploreLabels(Iterable<String?> labels) {
  return labels
      .whereType<String>()
      .map((label) => label.trim())
      .where((label) => label.isNotEmpty)
      .join(' · ');
}

String _coverKicker(ExploreEventItem item, {DateTime? now}) {
  return '${_coverTimeScope(item.event.startTime, now: now)} - '
      '${item.club.name} - ${item.event.locationName}';
}

String _coverTimeScope(DateTime start, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateUtils.dateOnly(reference);
  final eventDay = DateUtils.dateOnly(start);
  final dayOffset = eventDay.difference(today).inDays;
  return switch (dayOffset) {
    0 => 'Tonight',
    1 => 'Tomorrow',
    _ when dayOffset >= 0 && dayOffset < DateTime.daysPerWeek => 'This week',
    _ => EventFormatters.shortWeekday(start),
  };
}

String _coverSpotsLabel(ExploreEventItem item) {
  final spots = math.max(0, item.event.spotsRemaining);
  return spots == 1 ? '1 left' : '$spots left';
}

String _collapsedMapTitle(int? count) {
  if (count == null) return 'Finding events nearby';
  if (count == 0) return 'No events in this view';
  if (count == 1) return '1 event nearby';
  return '$count events nearby';
}

String _collapsedMapScopeLabel({
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

String _mapEventTicketSubtitle(ExploreEventItem item) {
  final event = item.event;
  return '${item.club.name} · ${event.locationName}';
}

String? _mapEventTicketStatusLabel(ExploreEventItem item) {
  return item.distanceFromUserLabel ?? item.availabilityLabel;
}

String _mapEventCapacityLabel(ExploreEventItem item) {
  return EventCapacityLabels(
    item.event,
  ).activityGoingAvailabilityLabel(availabilityLabel: item.availabilityLabel);
}

String _mapEventCountdownLabel(DateTime startTime, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateUtils.dateOnly(reference);
  final eventDay = DateUtils.dateOnly(startTime);
  final diffDays = eventDay.difference(today).inDays;
  return switch (diffDays) {
    0 => 'Today',
    1 => 'Tomorrow',
    _ => EventFormatters.shortWeekday(startTime),
  };
}

List<String> _areaOptions(Iterable<Club> clubs, String? selectedArea) {
  final areas = <String>{};
  for (final club in clubs) {
    final area = club.area.trim();
    if (area.isNotEmpty) areas.add(area);
  }
  final selected = selectedArea?.trim();
  if (selected != null && selected.isNotEmpty) areas.add(selected);
  return areas.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

class ExploreDiscoveryScreenState {
  const ExploreDiscoveryScreenState({
    required this.mapLauncherState,
    required this.emptyState,
    required this.bodyState,
  });

  factory ExploreDiscoveryScreenState.from({
    required String cityLabel,
    required String query,
    required ExploreFilterSelection filters,
    required bool hasSourceClubs,
    required int? eventFeedCount,
    required bool viewModelLoading,
    Object? viewModelError,
    required ExploreViewModel? viewModel,
    required bool eventFeedLoading,
    Object? eventFeedError,
    required bool eventFeedHasContent,
  }) {
    final emptyState = ExploreDiscoveryEmptyState.from(
      cityLabel: cityLabel,
      hasSourceClubs: hasSourceClubs,
      hasSearch: query.trim().isNotEmpty,
      filters: filters,
    );
    return ExploreDiscoveryScreenState(
      mapLauncherState: ExploreMapLauncherState.from(
        eventFeedCount: eventFeedCount,
      ),
      emptyState: emptyState,
      bodyState: ExploreScreenBodyState.from(
        viewModelLoading: viewModelLoading,
        viewModelError: viewModelError,
        viewModel: viewModel,
        eventFeedLoading: eventFeedLoading,
        eventFeedError: eventFeedError,
        eventFeedHasContent: eventFeedHasContent,
        emptyState: emptyState,
      ),
    );
  }

  final ExploreMapLauncherState mapLauncherState;
  final ExploreDiscoveryEmptyState emptyState;
  final ExploreScreenBodyState bodyState;
}

class ExploreScreenBodyState {
  const ExploreScreenBodyState._({
    required this.kind,
    this.viewModel,
    this.emptyState,
    this.error,
    this.retryTarget,
  });

  factory ExploreScreenBodyState.from({
    required bool viewModelLoading,
    Object? viewModelError,
    required ExploreViewModel? viewModel,
    required bool eventFeedLoading,
    Object? eventFeedError,
    required bool eventFeedHasContent,
    required ExploreDiscoveryEmptyState emptyState,
  }) {
    if (viewModelLoading) {
      return const ExploreScreenBodyState._(
        kind: ExploreScreenBodyKind.loading,
      );
    }
    if (viewModelError != null) {
      return ExploreScreenBodyState._(
        kind: ExploreScreenBodyKind.error,
        error: viewModelError,
        retryTarget: ExploreScreenRetryTarget.explore,
      );
    }

    final resolvedViewModel = viewModel;
    if (resolvedViewModel == null) {
      return const ExploreScreenBodyState._(
        kind: ExploreScreenBodyKind.loading,
      );
    }
    if (!resolvedViewModel.isEmpty || eventFeedHasContent) {
      return ExploreScreenBodyState._(
        kind: ExploreScreenBodyKind.content,
        viewModel: resolvedViewModel,
      );
    }
    if (eventFeedLoading) {
      return const ExploreScreenBodyState._(
        kind: ExploreScreenBodyKind.loading,
      );
    }
    if (eventFeedError != null) {
      return ExploreScreenBodyState._(
        kind: ExploreScreenBodyKind.error,
        error: eventFeedError,
        retryTarget: ExploreScreenRetryTarget.eventFeed,
      );
    }
    return ExploreScreenBodyState._(
      kind: ExploreScreenBodyKind.empty,
      emptyState: emptyState,
    );
  }

  final ExploreScreenBodyKind kind;
  final ExploreViewModel? viewModel;
  final ExploreDiscoveryEmptyState? emptyState;
  final Object? error;
  final ExploreScreenRetryTarget? retryTarget;
}

class ExploreDiscoveryEmptyState {
  const ExploreDiscoveryEmptyState({
    required this.kind,
    required this.cityLabel,
    required this.action,
  });

  factory ExploreDiscoveryEmptyState.from({
    required String cityLabel,
    required bool hasSourceClubs,
    required bool hasSearch,
    required ExploreFilterSelection filters,
  }) {
    final hasFilters = filters.hasActiveFilters;
    if (!hasSourceClubs) {
      return ExploreDiscoveryEmptyState(
        kind: ExploreDiscoveryEmptyKind.noSourceClubs,
        cityLabel: cityLabel,
        action: ExploreDiscoveryEmptyAction.none,
      );
    }
    if (hasSearch && hasFilters) {
      return ExploreDiscoveryEmptyState(
        kind: ExploreDiscoveryEmptyKind.noFilteredSearchResults,
        cityLabel: cityLabel,
        action: ExploreDiscoveryEmptyAction.clearSearchAndFilters,
      );
    }
    if (hasSearch) {
      return ExploreDiscoveryEmptyState(
        kind: ExploreDiscoveryEmptyKind.noSearchResults,
        cityLabel: cityLabel,
        action: ExploreDiscoveryEmptyAction.clearSearch,
      );
    }
    if (hasFilters) {
      return ExploreDiscoveryEmptyState(
        kind: ExploreDiscoveryEmptyKind.noFilterResults,
        cityLabel: cityLabel,
        action: ExploreDiscoveryEmptyAction.clearFilters,
      );
    }
    return ExploreDiscoveryEmptyState(
      kind: ExploreDiscoveryEmptyKind.noSourceClubs,
      cityLabel: cityLabel,
      action: ExploreDiscoveryEmptyAction.none,
    );
  }

  final ExploreDiscoveryEmptyKind kind;
  final String cityLabel;
  final ExploreDiscoveryEmptyAction action;

  bool get clearSearch =>
      action == ExploreDiscoveryEmptyAction.clearSearch ||
      action == ExploreDiscoveryEmptyAction.clearSearchAndFilters;

  bool get clearFilters =>
      action == ExploreDiscoveryEmptyAction.clearFilters ||
      action == ExploreDiscoveryEmptyAction.clearSearchAndFilters;
}

class ExploreEventsEmptyState {
  const ExploreEventsEmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    this.nextFilter,
    this.clearSearch = false,
    this.clearFilters = false,
  });

  factory ExploreEventsEmptyState.from({
    required ExploreFilterSelection filters,
    required String searchQuery,
  }) {
    if (searchQuery.trim().isNotEmpty) {
      return ExploreEventsEmptyState(
        title: 'No events match this search',
        message: 'Clear the search and filters to see every upcoming event.',
        actionLabel: 'Clear search and filters',
        actionIcon: CatchIcons.clear,
        clearSearch: true,
        clearFilters: true,
      );
    }

    return switch (filters.timeFilter) {
      ExploreTimeFilter.tonight => ExploreEventsEmptyState(
        title: 'Nothing tonight',
        message: 'The next good fit may be over the weekend.',
        actionLabel: 'See weekend',
        actionIcon: CatchIcons.thisWeek,
        nextFilter: ExploreTimeFilter.weekend,
      ),
      ExploreTimeFilter.tomorrow => ExploreEventsEmptyState(
        title: 'Nothing tomorrow',
        message: 'Open up the weekend to catch more event slots.',
        actionLabel: 'See weekend',
        actionIcon: CatchIcons.thisWeek,
        nextFilter: ExploreTimeFilter.weekend,
      ),
      ExploreTimeFilter.weekend => ExploreEventsEmptyState(
        title: 'Nothing this weekend',
        message: 'This week has the broader event slate.',
        actionLabel: 'See this week',
        actionIcon: CatchIcons.thisWeek,
        nextFilter: ExploreTimeFilter.thisWeek,
      ),
      ExploreTimeFilter.thisWeek => ExploreEventsEmptyState(
        title: 'Nothing this week',
        message: 'Remove the time window to see every upcoming event.',
        actionLabel: 'See anytime',
        actionIcon: CatchIcons.clear,
        nextFilter: ExploreTimeFilter.anytime,
      ),
      ExploreTimeFilter.anytime => ExploreEventsEmptyState(
        title: 'No upcoming events match this view',
        message:
            'Try a different area, a wider distance, or check the club directory below.',
        actionLabel: 'Clear filters',
        actionIcon: CatchIcons.clear,
        clearFilters: true,
      ),
    };
  }

  final String title;
  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final ExploreTimeFilter? nextFilter;
  final bool clearSearch;
  final bool clearFilters;
}
