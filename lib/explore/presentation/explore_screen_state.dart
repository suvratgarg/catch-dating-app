import 'dart:math' as math;

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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

enum ExploreScreenBodyKind {
  loading,
  error,
  content,
  contentWithoutClubs,
  empty,
}

enum ExploreScreenRetryTarget { explore, eventFeed }

const int minimumExploreThisWeekRecommendationCount = 2;

class ExploreMapLauncherState {
  const ExploreMapLauncherState({required this.label});

  factory ExploreMapLauncherState.from({
    required int? mappableEventCount,
    required AppLocalizations l10n,
  }) {
    return ExploreMapLauncherState(
      label: mappableEventCount == null || mappableEventCount == 0
          ? l10n.exploreExploreScreenStateLabelMap
          : l10n.exploreExploreScreenStateLabelMapMappableeventcount(
              mappableEventCount: mappableEventCount,
            ),
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
    required AppLocalizations l10n,
  }) {
    final chooseLabel = l10n
        .exploreExploreScreenStateVisiblecopyChooseCityLabel(label: city.label);
    return ExploreCityTriggerState(
      tooltipLabel: chooseLabel,
      semanticLabel: chooseLabel,
      scopeLabel: l10n
          .exploreExploreScreenStateVisiblecopyExploreLabel(label: city.label)
          .toUpperCase(),
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

class ExploreCityPickerState {
  const ExploreCityPickerState._({
    required this.selectedCity,
    required this.cities,
    required this.enabled,
  });

  factory ExploreCityPickerState.from({
    required CityData selectedCity,
    required Iterable<CityData> cities,
    required bool cityListLoading,
    required Object? cityListError,
  }) {
    final cityOptions = List<CityData>.unmodifiable(cities);
    return ExploreCityPickerState._(
      selectedCity: selectedCity,
      cities: cityOptions,
      enabled:
          !cityListLoading && cityListError == null && cityOptions.isNotEmpty,
    );
  }

  factory ExploreCityPickerState.disabled({required CityData selectedCity}) {
    return ExploreCityPickerState._(
      selectedCity: selectedCity,
      cities: const [],
      enabled: false,
    );
  }

  final CityData selectedCity;
  final List<CityData> cities;
  final bool enabled;
}

class ExploreChromeState {
  const ExploreChromeState({
    required this.title,
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
    required AppLocalizations l10n,
  }) {
    return ExploreChromeState._(
      query: query,
      showSearchAction: showSearchAction,
      showCoverStory: false,
      searchExpanded: false,
      searchAutofocus: false,
      l10n: l10n,
    );
  }

  factory ExploreChromeState.discovery({
    required String query,
    required bool searchRequested,
    required bool hasFeaturedItem,
    required AppLocalizations l10n,
  }) {
    final searchActive = query.trim().isNotEmpty;
    final showCoverStory = hasFeaturedItem && !searchRequested && !searchActive;
    return ExploreChromeState._(
      query: query,
      showSearchAction: true,
      showCoverStory: showCoverStory,
      searchExpanded: searchRequested || searchActive,
      searchAutofocus: searchRequested,
      l10n: l10n,
    );
  }

  ExploreChromeState._({
    required String query,
    required this.showSearchAction,
    required this.showCoverStory,
    required this.searchExpanded,
    required this.searchAutofocus,
    required AppLocalizations l10n,
  }) : title = l10n.exploreExploreScreenStateVisiblecopyExplore,
       searchValue = query,
       searchPlaceholder =
           l10n.exploreExploreScreenStateVisiblecopySearchEventsOrClubs,
       searchTooltip =
           l10n.exploreExploreScreenStateVisiblecopySearchEventsOrClubs,
       searchSemanticLabel =
           l10n.exploreExploreScreenStateVisiblecopySearchEventsOrClubs;

  final String title;
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

  factory ExploreFilterRailState.from(
    ExploreFilterSelection filters, {
    required AppLocalizations l10n,
  }) {
    final activeCount = activeExploreFilterCount(filters);
    return ExploreFilterRailState(
      activeCount: activeCount,
      filterButtonSemanticLabel: activeCount == 0
          ? l10n.exploreExploreScreenStateVisiblecopyOpenExploreFilters
          : l10n.exploreExploreScreenStateVisiblecopyOpenExploreFiltersActivecount(
              activeCount: activeCount,
            ),
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
    required AppLocalizations l10n,
  }) {
    return ExploreFilterSheetState(
      activeCount: activeExploreFilterCount(filters),
      distanceOptions: exploreDistanceFilterOptions(l10n),
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

List<ExploreDistanceFilterOption> exploreDistanceFilterOptions(
  AppLocalizations l10n,
) => <ExploreDistanceFilterOption>[
  ExploreDistanceFilterOption(
    value: ExploreDistanceFilter.any,
    label: l10n.exploreExploreScreenStateLabelAny,
  ),
  ExploreDistanceFilterOption(
    value: ExploreDistanceFilter.oneKm,
    label: l10n.exploreExploreScreenStateLabel1Km,
  ),
  ExploreDistanceFilterOption(
    value: ExploreDistanceFilter.threeKm,
    label: l10n.exploreExploreScreenStateLabel3Km,
  ),
  ExploreDistanceFilterOption(
    value: ExploreDistanceFilter.fiveKm,
    label: l10n.exploreExploreScreenStateLabel5Km,
  ),
  ExploreDistanceFilterOption(
    value: ExploreDistanceFilter.tenKm,
    label: l10n.exploreExploreScreenStateLabel10Km,
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

class ExploreCoverStoryState {
  const ExploreCoverStoryState({
    required this.kicker,
    required this.title,
    required this.ctaLabel,
    required this.timePriceLabel,
    required this.attendanceLabel,
  });

  factory ExploreCoverStoryState.from(
    ExploreEventItem item, {
    required AppLocalizations l10n,
    DateTime? now,
  }) {
    return ExploreCoverStoryState(
      kicker: _coverKicker(item, l10n: l10n, now: now),
      title: item.event.title,
      ctaLabel: l10n.exploreExploreScreenStateCtalabelClaimASeat,
      timePriceLabel: l10n.exploreExploreScreenStateVisiblecopyTimePricelabel(
        time: EventFormatters.time(item.event.startTime),
        priceLabel: item.priceLabel,
      ),
      attendanceLabel: l10n
          .exploreExploreScreenStateVisiblecopySignedupcountGoingCoverspotslabel(
            signedUpCount: item.event.signedUpCount,
            coverSpotsLabel: _coverSpotsLabel(item, l10n),
          ),
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
    required this.totalCount,
    required this.resultCountLabel,
    required this.thisWeekItems,
    required this.cardGroups,
  });

  factory ExploreFeedSectionState.from({
    required ExploreFeedViewModel viewModel,
    required List<Club> candidateClubs,
    required Set<String> joinedClubIds,
    required bool showThisWeekList,
    required AppLocalizations l10n,
    bool promoteFeaturedItem = true,
    DateTime? now,
  }) {
    final featured = promoteFeaturedItem ? viewModel.featuredItem : null;
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
    final cards = buildExploreMixedFeedCards(
      viewModel: bodyViewModel,
      candidateClubs: candidateClubs,
      joinedClubIds: joinedClubIds,
      excludeEventIds: thisWeekEventIds,
    );

    return ExploreFeedSectionState(
      bodyViewModel: bodyViewModel,
      totalCount: viewModel.count,
      resultCountLabel: _exploreResultCountLine(viewModel, l10n),
      thisWeekItems: List.unmodifiable(thisWeekItems),
      cardGroups: groupExploreMixedFeedCards(cards, l10n: l10n, now: now),
    );
  }

  final ExploreFeedViewModel bodyViewModel;
  final int totalCount;
  final String resultCountLabel;
  final List<ExploreEventItem> thisWeekItems;
  final List<ExploreFeedCardGroup> cardGroups;

  List<ExploreMixedCard> get cards =>
      List.unmodifiable([for (final group in cardGroups) ...group.cards]);

  bool get isEmpty => totalCount == 0 && cards.isEmpty && thisWeekItems.isEmpty;
}

class ExploreFeedCardGroup {
  const ExploreFeedCardGroup({
    required this.day,
    required this.label,
    required this.cards,
  });

  final DateTime? day;
  final String? label;
  final List<ExploreMixedCard> cards;

  int get timedCardCount => cards
      .where(
        (card) =>
            card is ExploreMixedEventRowCard ||
            card is ExploreMixedExternalEventRowCard,
      )
      .length;
}

class ExploreEventRowState {
  const ExploreEventRowState({
    required this.kicker,
    required this.supportingLabel,
    required this.priceLabel,
    required this.capacityLabel,
    required this.statusLabel,
  });

  factory ExploreEventRowState.from(
    ExploreEventItem item, {
    required AppLocalizations l10n,
  }) {
    return ExploreEventRowState(
      kicker: item.isFollowedClubSignal
          ? l10n.exploreExploreScreenStateKickerFromOneOfYour
          : item.club.name,
      supportingLabel: _rowSupportingLabel(item),
      priceLabel: item.priceLabel,
      capacityLabel: _capacityLabel(item),
      statusLabel: _cardStatusLabel(item, l10n),
    );
  }

  final String kicker;
  final String supportingLabel;
  final String priceLabel;
  final String capacityLabel;
  final String? statusLabel;
}

String exploreEventMapKicker(ExploreEventItem item) {
  return _joinExploreLabels([item.club.name, item.distanceFromUserLabel]);
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

  factory ExploreExternalEventRowState.from(
    ExploreExternalEventItem item, {
    required AppLocalizations l10n,
  }) {
    final event = item.event;
    final hasExternalLink = event.primaryExternalUri != null;
    return ExploreExternalEventRowState(
      sourceLabel: l10n.exploreExploreScreenStateVisiblecopyFromTouppercase(
        toUpperCase: event.platformLabel.toUpperCase(),
      ),
      statusLabel: l10n.exploreExploreScreenStateVisiblecopyExternal,
      supportingLabel: _externalEventSupportingLabel(item),
      timePriceLabel: l10n
          .exploreExploreScreenStateVisiblecopyTimePricelabelc30029(
            time: EventFormatters.time(event.startTime),
            priceLabel: event.priceLabel,
          ),
      actionLabel: hasExternalLink
          ? l10n.exploreExploreScreenStateActionlabelOpen
          : l10n.exploreExploreScreenStateActionlabelNoLink,
      actionSemanticsLabel: hasExternalLink
          ? l10n.exploreExploreScreenStateVisiblecopyOpenExternalEventSource
          : l10n.exploreExploreScreenStateVisiblecopyExternalEventLinkUnavailable,
      readOnlySupplyLabel:
          l10n.exploreExploreScreenStateVisiblecopyReadOnlySupplyNo,
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

  factory ExploreClubCardState.from(
    Club club, {
    required bool isSynthetic,
    required AppLocalizations l10n,
  }) {
    return ExploreClubCardState(
      memberCountLabel: clubMemberCountLabel(club),
      caption:
          (club.nextEventLabel ??
                  l10n.exploreExploreScreenStateCaptionClubToKnow)
              .toUpperCase(),
      title: club.name,
      supportingLabel: _clubSupportingLabel(club, l10n),
      actionLabel: isSynthetic
          ? l10n.exploreExploreScreenStateActionlabelPreview
          : l10n.exploreExploreScreenStateActionlabelViewClub,
      rowKicker: l10n.exploreExploreScreenStateVisiblecopyClubToKnow,
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

  DateTime? get startTime;
}

class ExploreMixedEventRowCard extends ExploreMixedCard {
  const ExploreMixedEventRowCard(this.item);

  final ExploreEventItem item;

  @override
  DateTime get startTime => item.event.startTime;
}

class ExploreMixedExternalEventRowCard extends ExploreMixedCard {
  const ExploreMixedExternalEventRowCard(this.item);

  final ExploreExternalEventItem item;

  @override
  DateTime get startTime => item.event.startTime;
}

class ExploreMixedClubSpotlightCard extends ExploreMixedCard {
  const ExploreMixedClubSpotlightCard(this.club);

  final Club club;

  @override
  DateTime? get startTime => null;
}

class ExploreMixedClubRowCard extends ExploreMixedCard {
  const ExploreMixedClubRowCard(this.club);

  final Club club;

  @override
  DateTime? get startTime => null;
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
  final cards = <ExploreMixedCard>[
    for (final item in viewModel.items)
      if (!excludeEventIds.contains(item.event.id))
        ExploreMixedEventRowCard(item),
    for (final item in viewModel.externalItems)
      ExploreMixedExternalEventRowCard(item),
  ]..sort((a, b) => a.startTime!.compareTo(b.startTime!));
  final timedCardCount = cards.length;

  if (cards.isEmpty) {
    if (firstClub != null) cards.add(ExploreMixedClubSpotlightCard(firstClub));
    if (secondClub != null) cards.add(ExploreMixedClubRowCard(secondClub));
    return cards;
  }

  if (firstClub != null) {
    cards.insert(
      math.min(2, cards.length),
      ExploreMixedClubSpotlightCard(firstClub),
    );
  }
  if (secondClub != null && timedCardCount >= 4) {
    cards.insert(
      math.min(5, cards.length),
      ExploreMixedClubRowCard(secondClub),
    );
  }
  return cards;
}

List<ExploreFeedCardGroup> groupExploreMixedFeedCards(
  List<ExploreMixedCard> cards, {
  required AppLocalizations l10n,
  DateTime? now,
}) {
  if (cards.isEmpty) return const <ExploreFeedCardGroup>[];

  final reference = now ?? DateTime.now();
  final today = DateUtils.dateOnly(reference);
  final tomorrow = today.add(const Duration(days: 1));
  final builders = <_ExploreFeedCardGroupBuilder>[];
  _ExploreFeedCardGroupBuilder? current;

  for (final card in cards) {
    final startTime = card.startTime;
    final day = startTime == null
        ? current?.day
        : DateUtils.dateOnly(startTime);
    if (current == null || current.day != day) {
      current = _ExploreFeedCardGroupBuilder(
        day: day,
        label: day == null
            ? null
            : exploreFeedDayLabel(day, today: today, tomorrow: tomorrow),
      );
      builders.add(current);
    }
    current.cards.add(card);
  }

  return List.unmodifiable([
    for (final builder in builders)
      ExploreFeedCardGroup(
        day: builder.day,
        label: builder.label,
        cards: List.unmodifiable(builder.cards),
      ),
  ]);
}

EventDateRailCardStripPosition exploreMixedEventStripPosition(
  List<ExploreMixedCard> cards,
  int index,
) {
  if (cards[index] is! ExploreMixedEventRowCard) {
    return EventDateRailCardStripPosition.single;
  }
  final joinsPrevious =
      index > 0 && cards[index - 1] is ExploreMixedEventRowCard;
  final joinsNext =
      index < cards.length - 1 && cards[index + 1] is ExploreMixedEventRowCard;
  if (joinsPrevious && joinsNext) {
    return EventDateRailCardStripPosition.middle;
  }
  if (joinsPrevious) return EventDateRailCardStripPosition.last;
  if (joinsNext) return EventDateRailCardStripPosition.first;
  return EventDateRailCardStripPosition.single;
}

class _ExploreFeedCardGroupBuilder {
  _ExploreFeedCardGroupBuilder({required this.day, required this.label});

  final DateTime? day;
  final String? label;
  final List<ExploreMixedCard> cards = <ExploreMixedCard>[];
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

String _exploreResultCountLine(
  ExploreFeedViewModel viewModel,
  AppLocalizations l10n,
) {
  final count = viewModel.count;
  final noun = count == 1
      ? l10n.exploreExploreScreenStateVisiblecopyPlan
      : l10n.exploreExploreScreenStateVisiblecopyPlans;
  final dateSpan = _exploreDateSpanLabel(viewModel);
  if (dateSpan == null)
    return l10n.exploreExploreScreenStateVisiblecopyCountNoun(
      count: count,
      noun: noun,
    );
  return l10n.exploreExploreScreenStateVisiblecopyCountNounDatespan(
    count: count,
    noun: noun,
    dateSpan: dateSpan,
  );
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

String? _cardStatusLabel(ExploreEventItem item, AppLocalizations l10n) {
  return switch (item.status) {
    EventTileStatus.open => _availabilityStatusLabel(item),
    EventTileStatus.recommended =>
      l10n.exploreExploreScreenStateVisiblecopyPicked,
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

String _clubSupportingLabel(Club club, AppLocalizations l10n) {
  final nextEvent = club.nextEventLabel?.trim();
  if (nextEvent != null && nextEvent.isNotEmpty) {
    return l10n.exploreExploreScreenStateVisiblecopyNextNextevent(
      nextEvent: nextEvent,
    );
  }
  final area = club.area.trim();
  if (area.isNotEmpty)
    return l10n.exploreExploreScreenStateVisiblecopyClubmembercountlabelArea(
      clubMemberCountLabel: clubMemberCountLabel(club),
      area: area,
    );
  return clubMemberCountLabel(club);
}

String _joinExploreLabels(Iterable<String?> labels) {
  return labels
      .whereType<String>()
      .map((label) => label.trim())
      .where((label) => label.isNotEmpty)
      .join(' · ');
}

String _coverKicker(
  ExploreEventItem item, {
  required AppLocalizations l10n,
  DateTime? now,
}) {
  return l10n
      .exploreExploreScreenStateVisiblecopyCovertimescopeNameLocationname(
        coverTimeScope: _coverTimeScope(
          item.event.startTime,
          l10n: l10n,
          now: now,
        ),
        name: item.club.name,
        locationName: item.event.locationName,
      );
}

String _coverTimeScope(
  DateTime start, {
  required AppLocalizations l10n,
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final today = DateUtils.dateOnly(reference);
  final eventDay = DateUtils.dateOnly(start);
  final dayOffset = eventDay.difference(today).inDays;
  return switch (dayOffset) {
    0 => l10n.exploreExploreScreenStateVisiblecopyTonight,
    1 => l10n.exploreExploreScreenStateVisiblecopyTomorrow,
    _ when dayOffset >= 0 && dayOffset < DateTime.daysPerWeek =>
      l10n.exploreExploreScreenStateVisiblecopyThisWeek,
    _ => EventFormatters.shortWeekday(start),
  };
}

String _coverSpotsLabel(ExploreEventItem item, AppLocalizations l10n) {
  final spots = math.max(0, item.event.spotsRemaining);
  return spots == 1
      ? l10n.exploreExploreScreenStateVisiblecopy1Left
      : l10n.exploreExploreScreenStateVisiblecopySpotsLeft(spots: spots);
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
    required AppLocalizations l10n,
    required String cityLabel,
    required String query,
    required ExploreFilterSelection filters,
    required bool hasSourceClubs,
    required int? mappableEventCount,
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
        mappableEventCount: mappableEventCount,
        l10n: l10n,
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
      if (eventFeedHasContent) {
        return ExploreScreenBodyState._(
          kind: ExploreScreenBodyKind.contentWithoutClubs,
          error: viewModelError,
          retryTarget: ExploreScreenRetryTarget.explore,
        );
      }
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
    required AppLocalizations l10n,
  }) {
    if (searchQuery.trim().isNotEmpty) {
      return ExploreEventsEmptyState(
        title: l10n.exploreExploreScreenStateTitleNoEventsMatchThis,
        message: l10n.exploreExploreScreenStateMessageClearTheSearchAnd,
        actionLabel:
            l10n.exploreExploreScreenStateActionlabelClearSearchAndFilters,
        actionIcon: CatchIcons.clear,
        clearSearch: true,
        clearFilters: true,
      );
    }

    return switch (filters.timeFilter) {
      ExploreTimeFilter.tonight => ExploreEventsEmptyState(
        title: l10n.exploreExploreScreenStateTitleNothingTonight,
        message: l10n.exploreExploreScreenStateMessageTheNextGoodFit,
        actionLabel: l10n.exploreExploreScreenStateActionlabelSeeWeekend,
        actionIcon: CatchIcons.thisWeek,
        nextFilter: ExploreTimeFilter.weekend,
      ),
      ExploreTimeFilter.tomorrow => ExploreEventsEmptyState(
        title: l10n.exploreExploreScreenStateTitleNothingTomorrow,
        message: l10n.exploreExploreScreenStateMessageOpenUpTheWeekend,
        actionLabel: l10n.exploreExploreScreenStateActionlabelSeeWeekend,
        actionIcon: CatchIcons.thisWeek,
        nextFilter: ExploreTimeFilter.weekend,
      ),
      ExploreTimeFilter.weekend => ExploreEventsEmptyState(
        title: l10n.exploreExploreScreenStateTitleNothingThisWeekend,
        message: l10n.exploreExploreScreenStateMessageThisWeekHasThe,
        actionLabel: l10n.exploreExploreScreenStateActionlabelSeeThisWeek,
        actionIcon: CatchIcons.thisWeek,
        nextFilter: ExploreTimeFilter.thisWeek,
      ),
      ExploreTimeFilter.thisWeek => ExploreEventsEmptyState(
        title: l10n.exploreExploreScreenStateTitleNothingThisWeek,
        message: l10n.exploreExploreScreenStateMessageRemoveTheTimeWindow,
        actionLabel: l10n.exploreExploreScreenStateActionlabelSeeAnytime,
        actionIcon: CatchIcons.clear,
        nextFilter: ExploreTimeFilter.anytime,
      ),
      ExploreTimeFilter.anytime => ExploreEventsEmptyState(
        title: l10n.exploreExploreScreenStateTitleNoUpcomingEventsMatch,
        message: l10n.exploreExploreScreenStateMessageTryADifferentArea,
        actionLabel: l10n.exploreExploreScreenStateActionlabelClearFilters,
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
