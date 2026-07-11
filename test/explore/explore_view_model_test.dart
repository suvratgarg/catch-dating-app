import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_discovery_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/external_event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/external_event.dart';
import 'package:catch_dating_app/events/domain/saved_event.dart';
import 'package:catch_dating_app/events/domain/viewer_event_availability.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/explore/data/explore_search_repository.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_filter_logic.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart';
import '../events/events_test_helpers.dart' as event_test;
import '../test_pump_helpers.dart';

CityData _city(String name) => cityOptionByName(name)!.toCityData();

String get _mumbaiMarketId => _city('mumbai').effectiveMarketId;

ClubMembership _membership({required String clubId, String uid = 'runner-1'}) =>
    ClubMembership(
      id: clubMembershipId(clubId: clubId, uid: uid),
      clubId: clubId,
      uid: uid,
      role: ClubMembershipRole.member,
      status: ClubMembershipStatus.active,
      joinedAt: DateTime(2026),
    );

ExploreEventItem _exploreItem({
  required String id,
  required Club club,
  required DateTime startTime,
  bool isJoinedClubMember = false,
  bool isFollowedClubSignal = false,
  int? bookedCount,
  int priceInPaise = 0,
  double? distanceFromUserKm,
  double? startingPointLat,
  double? startingPointLng,
}) {
  return ExploreEventItem(
    event:
        buildEvent(
          id: id,
          clubId: club.id,
          startTime: startTime,
          bookedCount: bookedCount,
          priceInPaise: priceInPaise,
        ).copyWith(
          startingPointLat: startingPointLat,
          startingPointLng: startingPointLng,
        ),
    club: club,
    isJoinedClubMember: isJoinedClubMember,
    isFollowedClubSignal: isFollowedClubSignal,
    distanceFromUserKm: distanceFromUserKm,
  );
}

void main() {
  group('Explore state', () {
    test('ExploreDiscoveryEmptyState derives provider-free empty actions', () {
      final noSource = ExploreDiscoveryEmptyState.from(
        cityLabel: 'Mumbai',
        hasSourceClubs: false,
        hasSearch: false,
        filters: const ExploreFilterSelection(),
      );
      expect(noSource.kind, ExploreDiscoveryEmptyKind.noSourceClubs);
      expect(noSource.action, ExploreDiscoveryEmptyAction.none);

      final searchAndFilters = ExploreDiscoveryEmptyState.from(
        cityLabel: 'Mumbai',
        hasSourceClubs: true,
        hasSearch: true,
        filters: const ExploreFilterSelection(highRatedOnly: true),
      );
      expect(
        searchAndFilters.kind,
        ExploreDiscoveryEmptyKind.noFilteredSearchResults,
      );
      expect(
        searchAndFilters.action,
        ExploreDiscoveryEmptyAction.clearSearchAndFilters,
      );
      expect(searchAndFilters.clearSearch, true);
      expect(searchAndFilters.clearFilters, true);

      final filtersOnly = ExploreDiscoveryEmptyState.from(
        cityLabel: 'Mumbai',
        hasSourceClubs: true,
        hasSearch: false,
        filters: const ExploreFilterSelection(highRatedOnly: true),
      );
      expect(filtersOnly.kind, ExploreDiscoveryEmptyKind.noFilterResults);
      expect(filtersOnly.action, ExploreDiscoveryEmptyAction.clearFilters);
    });

    test('ExploreEventsEmptyState derives provider-free event actions', () {
      final search = ExploreEventsEmptyState.from(
        filters: const ExploreFilterSelection(),
        searchQuery: 'tempo',
      );
      expect(search.title, 'No events match this search');
      expect(search.clearSearch, true);
      expect(search.clearFilters, true);
      expect(search.nextFilter, isNull);

      final thisWeek = ExploreEventsEmptyState.from(
        filters: const ExploreFilterSelection(
          timeFilter: ExploreTimeFilter.thisWeek,
        ),
        searchQuery: '',
      );
      expect(thisWeek.title, 'Nothing this week');
      expect(thisWeek.nextFilter, ExploreTimeFilter.anytime);
      expect(thisWeek.clearFilters, false);

      final anytime = ExploreEventsEmptyState.from(
        filters: const ExploreFilterSelection(
          timeFilter: ExploreTimeFilter.anytime,
        ),
        searchQuery: '',
      );
      expect(anytime.title, 'No upcoming events match this view');
      expect(anytime.clearFilters, true);
      expect(anytime.nextFilter, isNull);
    });

    test('ExploreMapLauncherState derives provider-free map labels', () {
      expect(
        ExploreMapLauncherState.from(mappableEventCount: null).label,
        'Map',
      );
      expect(ExploreMapLauncherState.from(mappableEventCount: 0).label, 'Map');
      expect(
        ExploreMapLauncherState.from(mappableEventCount: 3).label,
        'Map · 3',
      );
    });

    test('ExploreCityTriggerState derives provider-free city chrome', () {
      final idle = ExploreCityTriggerState.from(
        city: _city('mumbai'),
        focused: false,
      );
      expect(idle.tooltipLabel, 'Choose city: Mumbai');
      expect(idle.semanticLabel, 'Choose city: Mumbai');
      expect(idle.scopeLabel, 'EXPLORE · MUMBAI');
      expect(idle.icon, CatchIcons.locationOnOutlined);

      final focused = ExploreCityTriggerState.from(
        city: _city('mumbai'),
        focused: true,
      );
      expect(focused.icon, CatchIcons.locationOnRounded);
    });

    test(
      'ExploreCityPickerState exposes provider-free picker availability',
      () {
        final ready = ExploreCityPickerState.from(
          selectedCity: _city('mumbai'),
          cities: [_city('mumbai'), _city('delhi')],
          cityListLoading: false,
          cityListError: null,
        );

        expect(ready.selectedCity, _city('mumbai'));
        expect(ready.cities.map((city) => city.label), ['Mumbai', 'Delhi NCR']);
        expect(ready.enabled, true);

        final loading = ExploreCityPickerState.from(
          selectedCity: _city('mumbai'),
          cities: const [],
          cityListLoading: true,
          cityListError: null,
        );
        expect(loading.enabled, false);

        final failed = ExploreCityPickerState.from(
          selectedCity: _city('mumbai'),
          cities: [_city('mumbai')],
          cityListLoading: false,
          cityListError: Object(),
        );
        expect(failed.enabled, false);
      },
    );

    test('ExploreChromeState derives browse header labels', () {
      final state = ExploreChromeState.browse(
        query: 'pickleball dinner',
        showSearchAction: true,
      );

      expect(state.title, 'Explore');
      expect(state.searchValue, 'pickleball dinner');
      expect(state.searchPlaceholder, 'Search events or clubs');
      expect(state.searchTooltip, 'Search events or clubs');
      expect(state.searchSemanticLabel, 'Search events or clubs');
      expect(state.showSearchAction, true);
      expect(state.showCoverStory, false);
      expect(state.searchExpanded, false);
      expect(state.searchAutofocus, false);

      final cityOnly = ExploreChromeState.browse(
        query: '',
        showSearchAction: false,
      );
      expect(cityOnly.showSearchAction, false);
    });

    test('ExploreChromeState derives discovery cover/search policy', () {
      final cover = ExploreChromeState.discovery(
        query: '',
        searchRequested: false,
        hasFeaturedItem: true,
      );
      expect(cover.showCoverStory, true);
      expect(cover.searchExpanded, false);
      expect(cover.searchAutofocus, false);

      final requestedSearch = ExploreChromeState.discovery(
        query: '',
        searchRequested: true,
        hasFeaturedItem: true,
      );
      expect(requestedSearch.showCoverStory, false);
      expect(requestedSearch.searchExpanded, true);
      expect(requestedSearch.searchAutofocus, true);

      final activeSearch = ExploreChromeState.discovery(
        query: 'tempo',
        searchRequested: false,
        hasFeaturedItem: true,
      );
      expect(activeSearch.showCoverStory, false);
      expect(activeSearch.searchExpanded, true);
      expect(activeSearch.searchAutofocus, false);

      final noFeaturedItem = ExploreChromeState.discovery(
        query: '',
        searchRequested: false,
        hasFeaturedItem: false,
      );
      expect(noFeaturedItem.showCoverStory, false);
    });

    test('ExploreFilterRailState derives active count and semantics', () {
      final empty = ExploreFilterRailState.from(const ExploreFilterSelection());
      expect(empty.activeCount, 0);
      expect(empty.filterButtonSemanticLabel, 'Open explore filters');

      final active = ExploreFilterRailState.from(
        const ExploreFilterSelection(
          distanceFilter: ExploreDistanceFilter.threeKm,
          highRatedOnly: true,
          joinedOnly: true,
          activityTag: 'dinner',
          area: 'Bandra',
        ),
      );
      expect(active.activeCount, 5);
      expect(
        active.filterButtonSemanticLabel,
        'Open explore filters, 5 active',
      );
    });

    test('ExploreFilterSheetState derives distance and area options', () {
      final sheetState = ExploreFilterSheetState.from(
        filters: const ExploreFilterSelection(area: 'Bandra'),
        sourceClubs: [
          buildClub(id: 'area-khar', area: 'Khar'),
          buildClub(id: 'area-empty', area: ''),
        ],
      );

      expect(sheetState.distanceOptions.map((option) => option.label), [
        'Any',
        '1 km',
        '3 km',
        '5 km',
        '10 km',
      ]);
      expect(sheetState.areaOptions, ['Bandra', 'Khar']);
      expect(sheetState.activeCount, 1);
    });

    test('ExploreCoverStoryState derives provider-free cover copy', () {
      final club = buildClub(id: 'cover-club', name: 'Cover Club');
      final item = _exploreItem(
        id: 'cover-event',
        club: club,
        startTime: DateTime(2026, 7, 2, 18),
        bookedCount: 19,
      );

      final state = ExploreCoverStoryState.from(
        item,
        now: DateTime(2026, 7, 2, 10),
      );

      expect(state.kicker, 'Tonight - Cover Club - Start');
      expect(state.title, item.event.title);
      expect(state.ctaLabel, 'Claim a seat');
      expect(state.timePriceLabel, '6:00 PM - Free');
      expect(state.attendanceLabel, '19 going - 1 left');
    });

    test(
      'ExploreFeedSectionState counts the full feed and only promotes a visible cover',
      () {
        final now = DateTime(2026, 7, 1, 10);
        final eventClub = buildClub(id: 'event-club');
        final joinedClub = buildClub(
          id: 'joined-club',
          name: 'Joined Club',
          nextEventLabel: 'Tonight',
        );
        final spotlightClub = buildClub(
          id: 'spotlight-club',
          name: 'Spotlight Club',
          nextEventLabel: 'Tomorrow',
          imageUrl: 'https://example.com/club.jpg',
          rating: 4.9,
          memberCount: 200,
        );

        final state = ExploreFeedSectionState.from(
          viewModel: ExploreFeedViewModel(
            items: [
              _exploreItem(
                id: 'featured-event',
                club: eventClub,
                startTime: DateTime(2026, 7, 1, 18),
              ),
              _exploreItem(
                id: 'second-event',
                club: eventClub,
                startTime: DateTime(2026, 7, 2, 18),
              ),
              _exploreItem(
                id: 'third-event',
                club: eventClub,
                startTime: DateTime(2026, 7, 3, 18),
              ),
            ],
          ),
          candidateClubs: [joinedClub, spotlightClub],
          joinedClubIds: {'joined-club'},
          showThisWeekList: false,
          now: now,
        );

        expect(state.bodyViewModel.items.map((item) => item.event.id), [
          'second-event',
          'third-event',
        ]);
        expect(state.totalCount, 3);
        expect(state.resultCountLabel, '3 PLANS · JUL 1-3');
        expect(state.cards, hasLength(3));
        expect(
          (state.cards[0] as ExploreMixedEventRowCard).item.event.id,
          'second-event',
        );
        expect(
          (state.cards[1] as ExploreMixedEventRowCard).item.event.id,
          'third-event',
        );
        expect(
          (state.cards[2] as ExploreMixedClubSpotlightCard).club.id,
          'spotlight-club',
        );
        expect(state.cardGroups, hasLength(2));
        expect(state.cardGroups.first.label, startsWith('Tomorrow ·'));

        final searchState = ExploreFeedSectionState.from(
          viewModel: ExploreFeedViewModel(
            items: [
              _exploreItem(
                id: 'featured-event',
                club: eventClub,
                startTime: DateTime(2026, 7, 1, 18),
              ),
              _exploreItem(
                id: 'second-event',
                club: eventClub,
                startTime: DateTime(2026, 7, 2, 18),
              ),
              _exploreItem(
                id: 'third-event',
                club: eventClub,
                startTime: DateTime(2026, 7, 3, 18),
              ),
            ],
          ),
          candidateClubs: const [],
          joinedClubIds: const {},
          showThisWeekList: false,
          promoteFeaturedItem: false,
          now: now,
        );
        expect(searchState.bodyViewModel.items.map((item) => item.event.id), [
          'featured-event',
          'second-event',
          'third-event',
        ]);
        expect(searchState.resultCountLabel, '3 PLANS · JUL 1-3');
      },
    );

    test('ExploreFeedSectionState promotes a real two-day This week strip', () {
      final now = DateTime(2026, 7, 1, 10);
      final club = buildClub(id: 'week-club');
      final featured = _exploreItem(
        id: 'featured-event',
        club: club,
        startTime: DateTime(2026, 7, 1, 18),
      );
      final weekItems = [
        for (var index = 0; index < 5; index += 1)
          _exploreItem(
            id: 'week-event-$index',
            club: club,
            startTime: DateTime(2026, 7, index + 2, 18),
          ),
      ];

      final promoted = ExploreFeedSectionState.from(
        viewModel: ExploreFeedViewModel(items: [featured, ...weekItems]),
        candidateClubs: const [],
        joinedClubIds: const {},
        showThisWeekList: true,
        now: now,
      );
      expect(promoted.thisWeekItems, hasLength(5));
      expect(promoted.cards, isEmpty);
      expect(promoted.isEmpty, false);

      final twoDayStrip = ExploreFeedSectionState.from(
        viewModel: ExploreFeedViewModel(
          items: [
            featured,
            ...weekItems.take(minimumExploreThisWeekRecommendationCount),
          ],
        ),
        candidateClubs: const [],
        joinedClubIds: const {},
        showThisWeekList: true,
        now: now,
      );
      expect(twoDayStrip.thisWeekItems, hasLength(2));
      expect(twoDayStrip.cards, isEmpty);

      final oneDayFallback = ExploreFeedSectionState.from(
        viewModel: ExploreFeedViewModel(items: [featured, weekItems.first]),
        candidateClubs: const [],
        joinedClubIds: const {},
        showThisWeekList: true,
        now: now,
      );
      expect(oneDayFallback.thisWeekItems, isEmpty);
      expect(
        oneDayFallback.cards.whereType<ExploreMixedEventRowCard>(),
        hasLength(1),
      );
    });

    test(
      'mixed feed chronologically merges internal and external plans before clubs',
      () {
        final club = buildClub(id: 'event-club');
        final spotlightClub = buildClub(
          id: 'spotlight-club',
          nextEventLabel: 'Friday',
        );
        final external = ExploreExternalEventItem(
          event: _externalEvent(
            id: 'external-early',
            title: 'External Early',
            citySlug: 'mumbai',
            startTime: DateTime(2026, 7, 2, 12),
          ),
        );
        final cards = buildExploreMixedFeedCards(
          viewModel: ExploreFeedViewModel(
            items: [
              _exploreItem(
                id: 'internal-late',
                club: club,
                startTime: DateTime(2026, 7, 3, 18),
              ),
              _exploreItem(
                id: 'internal-middle',
                club: club,
                startTime: DateTime(2026, 7, 2, 18),
              ),
            ],
            externalItems: [external],
          ),
          candidateClubs: [spotlightClub],
          joinedClubIds: const {},
        );

        expect(cards, hasLength(4));
        expect(
          (cards[0] as ExploreMixedExternalEventRowCard).item.event.id,
          'external-early',
        );
        expect(
          (cards[1] as ExploreMixedEventRowCard).item.event.id,
          'internal-middle',
        );
        expect(
          (cards[2] as ExploreMixedClubSpotlightCard).club.id,
          'spotlight-club',
        );
        expect(
          (cards[3] as ExploreMixedEventRowCard).item.event.id,
          'internal-late',
        );

        final groups = groupExploreMixedFeedCards(
          cards,
          now: DateTime(2026, 7, 1, 10),
        );
        expect(groups, hasLength(2));
        expect(groups.first.timedCardCount, 2);
        expect(groups.first.cards, hasLength(3));
        expect(groups.last.timedCardCount, 1);
      },
    );

    test('second club row waits until the feed has room to interleave', () {
      final eventClub = buildClub(id: 'cadence-event-club');
      final clubs = [
        buildClub(id: 'cadence-spotlight', nextEventLabel: 'Friday'),
        buildClub(id: 'cadence-row', nextEventLabel: 'Saturday'),
      ];

      List<ExploreMixedCard> cardsFor(int eventCount) {
        return buildExploreMixedFeedCards(
          viewModel: ExploreFeedViewModel(
            items: [
              for (var index = 0; index < eventCount; index += 1)
                _exploreItem(
                  id: 'cadence-event-$index',
                  club: eventClub,
                  startTime: DateTime(2026, 7, 2, 10 + index),
                ),
            ],
          ),
          candidateClubs: clubs,
          joinedClubIds: const {},
        );
      }

      for (final eventCount in [1, 2, 3]) {
        expect(
          cardsFor(eventCount).whereType<ExploreMixedClubRowCard>(),
          isEmpty,
        );
      }
      final fourEventCards = cardsFor(4);
      expect(fourEventCards.whereType<ExploreMixedClubRowCard>(), hasLength(1));
      expect(fourEventCards.last, isA<ExploreMixedClubRowCard>());
    });

    test('mixed feed does not silently truncate external results', () {
      final externalItems = [
        for (var index = 0; index < 9; index += 1)
          ExploreExternalEventItem(
            event: _externalEvent(
              id: 'external-$index',
              title: 'External $index',
              citySlug: 'mumbai',
              startTime: DateTime(2026, 7, 2, 10 + index),
            ),
          ),
      ];

      final cards = buildExploreMixedFeedCards(
        viewModel: ExploreFeedViewModel(
          items: const [],
          externalItems: externalItems,
        ),
        candidateClubs: const [],
        joinedClubIds: const {},
      );

      expect(cards.whereType<ExploreMixedExternalEventRowCard>(), hasLength(9));
    });

    test('ticket strip joins only uninterrupted internal event rows', () {
      final club = buildClub(id: 'event-club');
      ExploreMixedEventRowCard internal(String id, int hour) =>
          ExploreMixedEventRowCard(
            _exploreItem(
              id: id,
              club: club,
              startTime: DateTime(2026, 7, 2, hour),
            ),
          );
      final cards = <ExploreMixedCard>[
        internal('first', 10),
        internal('second', 11),
        ExploreMixedClubRowCard(buildClub(id: 'club-break')),
        internal('third', 12),
        ExploreMixedExternalEventRowCard(
          ExploreExternalEventItem(
            event: _externalEvent(
              id: 'external-break',
              title: 'External Break',
              citySlug: 'mumbai',
              startTime: DateTime(2026, 7, 2, 13),
            ),
          ),
        ),
        internal('fourth', 14),
      ];

      expect(
        exploreMixedEventStripPosition(cards, 0),
        EventDateRailCardStripPosition.first,
      );
      expect(
        exploreMixedEventStripPosition(cards, 1),
        EventDateRailCardStripPosition.last,
      );
      expect(
        exploreMixedEventStripPosition(cards, 3),
        EventDateRailCardStripPosition.single,
      );
      expect(
        exploreMixedEventStripPosition(cards, 5),
        EventDateRailCardStripPosition.single,
      );
    });

    test('mappableEventCount ignores external and coordinate-less events', () {
      final club = buildClub(id: 'map-club');
      final viewModel = ExploreFeedViewModel(
        items: [
          _exploreItem(
            id: 'pinned',
            club: club,
            startTime: DateTime(2026, 7, 2, 10),
            startingPointLat: 19.06,
            startingPointLng: 72.83,
          ),
          _exploreItem(
            id: 'unpinned',
            club: club,
            startTime: DateTime(2026, 7, 2, 11),
          ),
        ],
        externalItems: [
          ExploreExternalEventItem(
            event: _externalEvent(
              id: 'external',
              title: 'External',
              citySlug: 'mumbai',
              startTime: DateTime(2026, 7, 2, 12),
            ),
          ),
        ],
      );

      expect(viewModel.count, 3);
      expect(viewModel.mappableEventCount, 1);
    });

    test('ExploreEventRowState derives provider-free event row labels', () {
      final club = buildClub(id: 'row-club', name: 'Row Club');
      final item = _exploreItem(
        id: 'row-event',
        club: club,
        startTime: DateTime(2026, 7, 2, 18),
        isJoinedClubMember: true,
      );

      final state = ExploreEventRowState.from(item);

      expect(state.kicker, 'Row Club');
      expect(state.supportingLabel, contains('Start'));
      expect(state.priceLabel, 'Free');
      expect(state.capacityLabel, isNotEmpty);
      expect(state.statusLabel, 'Picked');
    });

    test('ExploreEventRowState uses truthful membership-derived copy', () {
      final club = buildClub(id: 'member-row-club', name: 'Member Club');
      final item = _exploreItem(
        id: 'member-row-event',
        club: club,
        startTime: DateTime(2026, 7, 2, 18),
        isJoinedClubMember: true,
        isFollowedClubSignal: true,
      );

      expect(ExploreEventRowState.from(item).kicker, 'FROM ONE OF YOUR CLUBS');
    });

    test('ExploreExternalEventRowState derives provider-free row labels', () {
      final event = _externalEvent(
        id: 'external-row',
        title: 'Afterfly Social',
        citySlug: 'mumbai',
        startTime: DateTime(2026, 7, 2, 18),
      );
      final item = ExploreExternalEventItem(
        event: event,
        distanceFromUserKm: 2.4,
      );

      final state = ExploreExternalEventRowState.from(item);

      expect(state.sourceLabel, 'FROM LUMA');
      expect(
        state.supportingLabel,
        'Singles mixer · Bandra Amphitheatre · 2.4 km away',
      );
      expect(state.timePriceLabel, '6:00 PM · Price on source');
      expect(state.actionLabel, 'Open');
      expect(state.actionSemanticsLabel, 'Open external event source');
      expect(state.readOnlySupplyLabel, 'READ-ONLY SUPPLY · NO CATCH BOOKING');
      expect(state.hasExternalLink, true);
    });

    test(
      'unclaimed organizer external event without link renders No link row state',
      () {
        final event = _externalEvent(
          id: 'external-unclaimed-organizer',
          title: 'Unclaimed Organizer Social',
          citySlug: 'mumbai',
          startTime: DateTime(2026, 7, 2, 18),
          externalLinks: const [],
        ).copyWith(canonicalHostId: '', compatibilityClubId: '');
        final state = ExploreExternalEventRowState.from(
          ExploreExternalEventItem(event: event),
        );

        expect(state.actionLabel, 'No link');
        expect(state.actionSemanticsLabel, 'External event link unavailable');
        expect(state.hasExternalLink, false);
        expect(state.supportingLabel, contains('Bandra Amphitheatre'));
      },
    );

    test('ExploreClubCardState derives shared club card labels', () {
      final club = buildClub(
        id: 'club-card',
        name: 'Tempo House',
        tags: const ['Bandra', 'music', 'social', 'late'],
        memberCount: 42,
        nextEventLabel: 'Fri 8 PM',
      );

      final state = ExploreClubCardState.from(club, isSynthetic: false);
      final previewState = ExploreClubCardState.from(club, isSynthetic: true);

      expect(state.memberCountLabel, '42 members');
      expect(state.caption, 'FRI 8 PM');
      expect(state.title, 'Tempo House');
      expect(state.supportingLabel, 'Next: Fri 8 PM');
      expect(state.actionLabel, 'View club');
      expect(state.rowKicker, 'CLUB TO KNOW');
      expect(state.tags, ['music', 'social']);
      expect(previewState.actionLabel, 'Preview');
    });

    test('ExploreScreenBodyState derives route branch precedence', () {
      final emptyState = ExploreDiscoveryEmptyState.from(
        cityLabel: 'Mumbai',
        hasSourceClubs: false,
        hasSearch: false,
        filters: const ExploreFilterSelection(),
      );
      const emptyViewModel = ExploreViewModel(joinedClubs: [], allClubs: []);
      final populatedViewModel = ExploreViewModel(
        joinedClubs: const [],
        allClubs: [buildClub(id: 'club-content')],
      );

      ExploreScreenBodyState body({
        bool viewModelLoading = false,
        Object? viewModelError,
        ExploreViewModel? viewModel,
        bool eventFeedLoading = false,
        Object? eventFeedError,
        bool eventFeedHasContent = false,
      }) {
        return ExploreScreenBodyState.from(
          viewModelLoading: viewModelLoading,
          viewModelError: viewModelError,
          viewModel: viewModel ?? emptyViewModel,
          eventFeedLoading: eventFeedLoading,
          eventFeedError: eventFeedError,
          eventFeedHasContent: eventFeedHasContent,
          emptyState: emptyState,
        );
      }

      expect(body(viewModelLoading: true).kind, ExploreScreenBodyKind.loading);

      final viewModelError = body(viewModelError: StateError('clubs failed'));
      expect(viewModelError.kind, ExploreScreenBodyKind.error);
      expect(viewModelError.retryTarget, ExploreScreenRetryTarget.explore);

      final viewModelErrorWithFeed = body(
        viewModelError: StateError('clubs failed'),
        eventFeedHasContent: true,
      );
      expect(
        viewModelErrorWithFeed.kind,
        ExploreScreenBodyKind.contentWithoutClubs,
      );
      expect(
        viewModelErrorWithFeed.retryTarget,
        ExploreScreenRetryTarget.explore,
      );

      final populatedClubs = body(viewModel: populatedViewModel);
      expect(populatedClubs.kind, ExploreScreenBodyKind.content);
      expect(populatedClubs.viewModel, populatedViewModel);

      final populatedEvents = body(eventFeedHasContent: true);
      expect(populatedEvents.kind, ExploreScreenBodyKind.content);
      expect(populatedEvents.viewModel, emptyViewModel);

      expect(body(eventFeedLoading: true).kind, ExploreScreenBodyKind.loading);

      final feedError = body(eventFeedError: StateError('events failed'));
      expect(feedError.kind, ExploreScreenBodyKind.error);
      expect(feedError.retryTarget, ExploreScreenRetryTarget.eventFeed);

      final empty = body();
      expect(empty.kind, ExploreScreenBodyKind.empty);
      expect(empty.emptyState, emptyState);
    });

    test('ExploreDiscoveryScreenState derives route display state', () {
      const emptyViewModel = ExploreViewModel(joinedClubs: [], allClubs: []);
      final state = ExploreDiscoveryScreenState.from(
        cityLabel: 'Mumbai',
        query: 'padel',
        filters: const ExploreFilterSelection(
          distanceFilter: ExploreDistanceFilter.threeKm,
        ),
        hasSourceClubs: true,
        mappableEventCount: 4,
        viewModelLoading: false,
        viewModel: emptyViewModel,
        eventFeedLoading: false,
        eventFeedHasContent: false,
      );

      expect(state.mapLauncherState.label, 'Map · 4');
      expect(
        state.emptyState.kind,
        ExploreDiscoveryEmptyKind.noFilteredSearchResults,
      );
      expect(
        state.emptyState.action,
        ExploreDiscoveryEmptyAction.clearSearchAndFilters,
      );
      expect(state.bodyState.kind, ExploreScreenBodyKind.empty);
      expect(state.bodyState.emptyState, state.emptyState);

      final content = ExploreDiscoveryScreenState.from(
        cityLabel: 'Mumbai',
        query: '',
        filters: const ExploreFilterSelection(),
        hasSourceClubs: false,
        mappableEventCount: 1,
        viewModelLoading: false,
        viewModel: emptyViewModel,
        eventFeedLoading: false,
        eventFeedHasContent: true,
      );

      expect(content.mapLauncherState.label, 'Map · 1');
      expect(content.bodyState.kind, ExploreScreenBodyKind.content);
    });

    test(
      'selectedExploreCityProvider defaults to Mumbai and clears search on change',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(selectedExploreCityProvider), _city('mumbai'));

        container.read(exploreSearchQueryProvider.notifier).setQuery('stride');
        container
            .read(selectedExploreCityProvider.notifier)
            .setCity(_city('delhi'));

        expect(container.read(selectedExploreCityProvider), _city('delhi'));
        expect(container.read(exploreSearchQueryProvider), isEmpty);
        expect(
          container.read(selectedExploreCityWasUserSelectedProvider),
          true,
        );
      },
    );

    test('autoSelectCity sets city when user has not made a manual pick', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedExploreCityProvider), _city('mumbai'));

      container
          .read(selectedExploreCityProvider.notifier)
          .autoSelectCity(_city('delhi'));

      expect(container.read(selectedExploreCityProvider), _city('delhi'));
      expect(container.read(selectedExploreCityWasUserSelectedProvider), false);
    });

    test('autoSelectCityByName uses known profile cities', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(selectedExploreCityProvider.notifier)
          .autoSelectCityByName('indore');

      expect(container.read(selectedExploreCityProvider), _city('indore'));
    });

    test('autoSelectCity does not override a manual city choice', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(selectedExploreCityProvider.notifier)
          .setCity(_city('bangalore'));
      expect(container.read(selectedExploreCityProvider), _city('bangalore'));

      container
          .read(selectedExploreCityProvider.notifier)
          .autoSelectCity(_city('mumbai'));
      expect(container.read(selectedExploreCityProvider), _city('bangalore'));
    });

    test('setCity clears search query while autoSelectCity also clears it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(exploreSearchQueryProvider.notifier).setQuery('stride');
      container
          .read(selectedExploreCityProvider.notifier)
          .autoSelectCity(_city('delhi'));

      expect(container.read(exploreSearchQueryProvider), isEmpty);
    });

    test('setCity clears city-local filters but keeps global filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filters = container.read(exploreFiltersProvider.notifier);
      filters.toggleThisWeekOnly();
      filters.toggleHighRatedOnly();
      filters.toggleDistanceFilter(ExploreDistanceFilter.threeKm);
      filters.toggleActivityTag('tempo');
      filters.toggleArea('Bandra');

      container
          .read(selectedExploreCityProvider.notifier)
          .setCity(_city('delhi'));

      final selection = container.read(exploreFiltersProvider);
      expect(selection.timeFilter, ExploreTimeFilter.thisWeek);
      expect(selection.thisWeekOnly, isTrue);
      expect(selection.distanceFilter, ExploreDistanceFilter.threeKm);
      expect(selection.highRatedOnly, isTrue);
      expect(selection.activityTag, isNull);
      expect(selection.area, isNull);
    });

    test('time filters define discovery windows', () {
      final now = DateTime(2026, 5, 26, 10);

      final tonight = exploreTimeWindowFor(ExploreTimeFilter.tonight, now)!;
      expect(tonight.start, DateTime(2026, 5, 26, 18));
      expect(tonight.end, DateTime(2026, 5, 27, 3));

      final tomorrow = exploreTimeWindowFor(ExploreTimeFilter.tomorrow, now)!;
      expect(tomorrow.start, DateTime(2026, 5, 27));
      expect(tomorrow.end, DateTime(2026, 5, 28));

      final weekend = exploreTimeWindowFor(ExploreTimeFilter.weekend, now)!;
      expect(weekend.start, DateTime(2026, 5, 29));
      expect(weekend.end, DateTime(2026, 6));

      final thisWeek = exploreTimeWindowFor(ExploreTimeFilter.thisWeek, now)!;
      expect(thisWeek.start, now);
      expect(thisWeek.end, DateTime(2026, 6, 2, 10));
    });

    test('distance filter values define proximity radii', () {
      expect(exploreDistanceFilterKm(ExploreDistanceFilter.any), isNull);
      expect(exploreDistanceFilterKm(ExploreDistanceFilter.oneKm), 1);
      expect(exploreDistanceFilterKm(ExploreDistanceFilter.threeKm), 3);
      expect(exploreDistanceFilterKm(ExploreDistanceFilter.fiveKm), 5);
      expect(exploreDistanceFilterKm(ExploreDistanceFilter.tenKm), 10);
    });

    test(
      'matchesExploreClubSearchQuery matches name, area, host, and tags',
      () {
        final bandraClub = buildClub();
        final hostClub = buildClub(
          id: 'club-2',
          name: 'Sunrise Crew',
          hostName: 'Asha',
        );
        final taggedClub = buildClub(
          id: 'club-3',
          name: 'Night Pacers',
          tags: const ['tempo', 'community'],
        );

        expect(matchesExploreClubSearchQuery(bandraClub, 'bandra'), isTrue);
        expect(matchesExploreClubSearchQuery(hostClub, 'asha'), isTrue);
        expect(matchesExploreClubSearchQuery(taggedClub, 'tempo'), isTrue);
        expect(matchesExploreClubSearchQuery(taggedClub, 'missing'), isFalse);
      },
    );

    test('applyExploreFilters combines quick filters', () {
      final now = DateTime(2026, 1, 1, 8);
      final matchingClub = buildClub(
        id: 'matching-club',
        tags: const ['tempo'],
        rating: 4.8,
        nextEventAt: now.add(const Duration(days: 2)),
      );
      final staleEventClub = buildClub(
        id: 'stale-event-club',
        tags: const ['tempo'],
        rating: 4.9,
        nextEventAt: now.subtract(const Duration(hours: 1)),
      );
      final lowRatedClub = buildClub(
        id: 'low-rated-club',
        tags: const ['tempo'],
        rating: 4.2,
        nextEventAt: now.add(const Duration(days: 2)),
      );
      final wrongAreaClub = buildClub(
        id: 'wrong-area-club',
        area: 'Juhu',
        tags: const ['tempo'],
        rating: 4.8,
        nextEventAt: now.add(const Duration(days: 2)),
      );

      final filtered = applyExploreFilters(
        clubs: [matchingClub, staleEventClub, lowRatedClub, wrongAreaClub],
        filters: const ExploreFilterSelection(
          timeFilter: ExploreTimeFilter.thisWeek,
          highRatedOnly: true,
          joinedOnly: true,
          activityTag: 'Tempo',
          area: 'bandra',
        ),
        joinedClubIds: {'matching-club', 'stale-event-club', 'wrong-area-club'},
        now: now,
      );

      expect(filtered.map((club) => club.id), ['matching-club']);
    });

    test('applyExploreFilters uses the selected time window', () {
      final now = DateTime(2026, 5, 26, 10);
      final tonightClub = buildClub(
        id: 'tonight-club',
        nextEventAt: DateTime(2026, 5, 26, 19),
      );
      final tomorrowClub = buildClub(
        id: 'tomorrow-club',
        nextEventAt: DateTime(2026, 5, 27, 8),
      );
      final weekendClub = buildClub(
        id: 'weekend-club',
        nextEventAt: DateTime(2026, 5, 30, 8),
      );

      final filtered = applyExploreFilters(
        clubs: [tonightClub, tomorrowClub, weekendClub],
        filters: const ExploreFilterSelection(
          timeFilter: ExploreTimeFilter.weekend,
        ),
        joinedClubIds: const {},
        now: now,
      );

      expect(filtered.map((club) => club.id), ['weekend-club']);
    });

    test('applyExploreFilters ignores a distance-only selection on clubs', () {
      final now = DateTime(2026, 1, 1, 8);
      // Well outside the default "this week" window: if a distance-only
      // selection wrongly triggered club time-filtering, this club would vanish.
      final club = buildClub(
        id: 'club-distance-only',
        nextEventAt: now.add(const Duration(days: 30)),
      );
      const filters = ExploreFilterSelection(
        distanceFilter: ExploreDistanceFilter.fiveKm,
      );

      // Distance is an active filter globally (it narrows the events feed)...
      expect(filters.hasActiveFilters, isTrue);
      // ...but not for the club list, which has no coordinates to filter on.
      expect(filters.hasActiveClubFilters, isFalse);

      final filtered = applyExploreFilters(
        clubs: [club],
        filters: filters,
        joinedClubIds: const {},
        now: now,
      );

      expect(filtered.map((club) => club.id), ['club-distance-only']);
    });

    test('clubMatchesScopeFilters short-circuits the tag check for events', () {
      // Default tags are ['social'] — the club does not carry 'running'.
      final club = buildClub(id: 'club-social');
      const filters = ExploreFilterSelection(activityTag: 'running');

      // The events query already filtered by ActivityKind, so the club need not
      // also carry the tag as free text.
      expect(
        clubMatchesScopeFilters(
          club: club,
          filters: filters,
          joinedClubIds: const {},
          activityHandledByEventFilter: true,
        ),
        isTrue,
      );
      // The club list has no event filter behind it, so the tag must match.
      expect(
        clubMatchesScopeFilters(
          club: club,
          filters: filters,
          joinedClubIds: const {},
        ),
        isFalse,
      );
    });

    test('debouncedExploreSearchQuery debounces and trims the server key', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(exploreSearchQueryProvider.notifier).setQuery('asha ');

      // Keep the autoDispose provider mounted while it debounces, the way the
      // view models do by watching it (otherwise the pending timer is disposed).
      final subscription = container.listen(
        debouncedExploreSearchQueryProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      // The live query is available immediately, but the debounced server key
      // lags until the typing pause elapses — so a keystroke can't fire a call.
      expect(container.read(exploreSearchQueryProvider), 'asha ');
      expect(subscription.read().isLoading, isTrue);

      // After the debounce window it settles to the trimmed query, so a trailing
      // space no longer mints a distinct search key.
      expect(
        await container.read(debouncedExploreSearchQueryProvider.future),
        'asha',
      );
    });

    test(
      'debouncedExploreSearchQuery settles immediately for short queries',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(exploreSearchQueryProvider.notifier).setQuery('a');

        final subscription = container.listen(
          debouncedExploreSearchQueryProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);

        // Clears and single characters bypass the debounce: nothing to search.
        expect(
          await container.read(debouncedExploreSearchQueryProvider.future),
          'a',
        );
      },
    );

    test(
      'exploreClubsViewModelProvider partitions joined and discover clubs',
      () async {
        final memberClub = buildClub(id: 'member-club');
        final followedClub = buildClub(
          id: 'followed-club',
          hostUserId: 'host-2',
        );
        final discoverClub = buildClub(
          id: 'discover-club',
          hostUserId: 'host-3',
        );
        final hostedClub = buildClub(id: 'hosted-club', hostUserId: 'runner-1');

        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            watchActiveClubMembershipsForUserProvider('runner-1').overrideWith(
              (ref) => Stream.value([
                _membership(clubId: 'member-club'),
                _membership(clubId: 'followed-club'),
              ]),
            ),
            watchClubsByLocationProvider(_mumbaiMarketId).overrideWith(
              (ref) => Stream.value([
                memberClub,
                followedClub,
                discoverClub,
                hostedClub,
              ]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final subscription = container.listen(
          exploreClubsViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);

        await flushTestEventQueue();

        expect(
          subscription.read().hasValue,
          isTrue,
          reason: '${subscription.read()}',
        );
        final viewModel = subscription.read().value!;

        expect(viewModel.joinedClubs.map((club) => club.id), [
          'member-club',
          'followed-club',
        ]);
        expect(viewModel.allClubs.map((club) => club.id), [
          'member-club',
          'followed-club',
          'discover-club',
          'hosted-club',
        ]);
        expect(viewModel.joinedClubIds, {'member-club', 'followed-club'});
      },
    );

    test(
      'exploreClubsViewModelProvider shows empty city without waiting for auth',
      () async {
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => const Stream.empty()),
            watchClubsByLocationProvider(
              _mumbaiMarketId,
            ).overrideWith((ref) => Stream.value(const <Club>[])),
          ],
        );
        addTearDown(container.dispose);

        final subscription = container.listen(
          exploreClubsViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        await container.pump();
        await flushTestEventQueue();
        await container.pump();

        final viewModel = subscription.read().value!;

        expect(viewModel.isEmpty, isTrue);
        expect(viewModel.joinedClubs, isEmpty);
        expect(viewModel.allClubs, isEmpty);
      },
    );

    test(
      'filteredExploreClubsProvider applies the normalized search query',
      () async {
        final bandraClub = buildClub(id: 'bandra-club');
        final ashaClub = buildClub(
          id: 'asha-club',
          hostName: 'Asha',
          area: 'Juhu',
        );
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value(null)),
            exploreSearchRepositoryProvider.overrideWithValue(
              _FakeExploreSearchRepository(error: StateError('search offline')),
            ),
            watchClubsByLocationProvider(
              _mumbaiMarketId,
            ).overrideWith((ref) => Stream.value([bandraClub, ashaClub])),
          ],
        );
        addTearDown(container.dispose);
        container.read(exploreSearchQueryProvider.notifier).setQuery('  asha');

        final subscription = container.listen(
          filteredExploreClubsProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        await container.pump();

        expect(subscription.read().value, [ashaClub]);
      },
    );

    test(
      'exploreFeedViewModelProvider filters events by device distance',
      () async {
        final club = buildClub(id: 'club-distance');
        final near = event_test.buildEvent(
          id: 'near-event',
          clubId: club.id,
          meetingPoint: 'Near plaza',
          startTime: DateTime.now().add(const Duration(days: 1)),
          startingPointLat: 19.0,
          startingPointLng: 72.01,
        );
        final far = event_test.buildEvent(
          id: 'far-event',
          clubId: club.id,
          meetingPoint: 'Far park',
          startTime: DateTime.now().add(const Duration(days: 2)),
          startingPointLat: 19.0,
          startingPointLng: 72.09,
        );
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value(null)),
            watchClubsByLocationProvider(
              _mumbaiMarketId,
            ).overrideWith((ref) => Stream.value([club])),
            eventDiscoveryRepositoryProvider.overrideWithValue(
              _FakeEventDiscoveryRepository([far, near]),
            ),
            externalEventRepositoryProvider.overrideWithValue(
              _FakeExternalEventRepository([]),
            ),
            deviceLocationProvider.overrideWith(
              () => _FakeDeviceLocation(const LocationCoordinate(19.0, 72.0)),
            ),
          ],
        );
        addTearDown(container.dispose);
        container
            .read(exploreFiltersProvider.notifier)
            .setDistanceFilter(ExploreDistanceFilter.threeKm);

        final subscription = container.listen(
          exploreFeedViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        await container.pump();
        await flushTestEventQueue();
        await container.pump();

        expect(
          subscription.read().hasValue,
          isTrue,
          reason: '${subscription.read()}',
        );
        final viewModel = subscription.read().value!;

        expect(viewModel.items.map((item) => item.event.id), ['near-event']);
        expect(viewModel.items.single.distanceFromUserKm, lessThan(3));
        expect(
          viewModel.items.single.distanceFromUserLabel,
          contains('km away'),
        );
      },
    );

    test(
      'exploreFeedViewModelProvider keeps external supply separate',
      () async {
        final externalEvent = _externalEvent(
          id: 'external-mumbai-mixer',
          title: 'Mumbai Singles Mixer',
          citySlug: 'mumbai',
          startTime: DateTime.now().add(const Duration(days: 1)),
        );
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value(null)),
            watchClubsByLocationProvider(
              _mumbaiMarketId,
            ).overrideWith((ref) => Stream.value(const <Club>[])),
            eventDiscoveryRepositoryProvider.overrideWithValue(
              _FakeEventDiscoveryRepository([]),
            ),
            externalEventRepositoryProvider.overrideWithValue(
              _FakeExternalEventRepository([externalEvent]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final subscription = container.listen(
          exploreFeedViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        await container.pump();
        await flushTestEventQueue();
        await container.pump();

        expect(
          subscription.read().hasValue,
          isTrue,
          reason: '${subscription.read()}',
        );
        final viewModel = subscription.read().value!;

        expect(viewModel.items, isEmpty);
        expect(viewModel.externalItems.map((item) => item.event.id), [
          'external-mumbai-mixer',
        ]);
        expect(viewModel.isEmpty, isFalse);
        expect(viewModel.count, 1);
      },
    );

    test(
      'exploreFeedViewModelProvider resolves viewer-specific availability',
      () async {
        final user = event_test.buildUser();
        final club = buildClub(id: 'club-availability');
        final joinedEvent = event_test.buildEvent(
          id: 'joined-event',
          clubId: club.id,
          startTime: DateTime.now().add(const Duration(days: 1)),
        );
        final savedEvent = event_test.buildEvent(
          id: 'saved-event',
          clubId: club.id,
          startTime: DateTime.now().add(const Duration(days: 2)),
        );
        final requestEvent = event_test.buildEvent(
          id: 'request-event',
          clubId: club.id,
          startTime: DateTime.now().add(const Duration(days: 3)),
          eventPolicy: EventPolicyBundle.requestToJoinEvent(
            capacityLimit: 12,
            basePriceInPaise: 0,
          ),
        );
        final savedEdge = SavedEvent(
          id: savedEventId(uid: user.uid, eventId: savedEvent.id),
          uid: user.uid,
          eventId: savedEvent.id,
          savedAt: DateTime(2026, 5, 26),
        );

        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value(user.uid)),
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            watchClubsByLocationProvider(
              _mumbaiMarketId,
            ).overrideWith((ref) => Stream.value([club])),
            watchActiveClubMembershipsForUserProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value(const <ClubMembership>[])),
            watchEventParticipationsForUserProvider(user.uid).overrideWith(
              (ref) => Stream.value([
                event_test.buildEventParticipation(
                  event: joinedEvent,
                  uid: user.uid,
                ),
              ]),
            ),
            watchSignedUpEventsProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value([joinedEvent])),
            watchSavedEventsForUserProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value([savedEdge])),
            watchSavedEventDetailsForUserProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value([savedEvent])),
            watchEventsByIdsProvider(
              EventsByIdQuery([joinedEvent.id]),
            ).overrideWith((ref) => Stream.value([joinedEvent])),
            eventDiscoveryRepositoryProvider.overrideWithValue(
              _FakeEventDiscoveryRepository([requestEvent, savedEvent]),
            ),
            externalEventRepositoryProvider.overrideWithValue(
              _FakeExternalEventRepository([]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final subscription = container.listen(
          exploreFeedViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        await container.pump();
        await flushTestEventQueue();
        await container.pump();

        expect(
          subscription.read().hasValue,
          isTrue,
          reason: '${subscription.read()}',
        );
        final byId = {
          for (final item in subscription.read().value!.items)
            item.event.id: item,
        };

        expect(byId['joined-event']?.status, EventTileStatus.joined);
        expect(byId['saved-event']?.status, EventTileStatus.saved);
        expect(
          byId['request-event']?.availability?.status,
          ViewerEventAvailabilityStatus.requestRequired,
        );
        expect(byId['request-event']?.availabilityLabel, 'Request required');
      },
    );

    test(
      'exploreFeedViewModelProvider does not block on personal event enrichment',
      () async {
        final user = event_test.buildUser(uid: 'runner-enrichment');
        final club = buildClub(id: 'club-enrichment');
        final joinedEvent = event_test.buildEvent(
          id: 'joined-enrichment',
          clubId: club.id,
          startTime: DateTime.now().add(const Duration(days: 1)),
        );
        final discoverableEvent = event_test.buildEvent(
          id: 'discoverable-enrichment',
          clubId: club.id,
          startTime: DateTime.now().add(const Duration(days: 2)),
        );
        final personalEvents = StreamController<List<Event>>();
        addTearDown(personalEvents.close);

        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value(user.uid)),
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            watchClubsByLocationProvider(
              _mumbaiMarketId,
            ).overrideWith((ref) => Stream.value([club])),
            watchActiveClubMembershipsForUserProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value(const <ClubMembership>[])),
            watchEventParticipationsForUserProvider(user.uid).overrideWith(
              (ref) => Stream.value([
                event_test.buildEventParticipation(
                  event: joinedEvent,
                  uid: user.uid,
                ),
              ]),
            ),
            watchSavedEventsForUserProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value(const <SavedEvent>[])),
            watchEventsByIdsProvider(
              EventsByIdQuery([joinedEvent.id]),
            ).overrideWith((ref) => personalEvents.stream),
            eventDiscoveryRepositoryProvider.overrideWithValue(
              _FakeEventDiscoveryRepository([discoverableEvent]),
            ),
            externalEventRepositoryProvider.overrideWithValue(
              _FakeExternalEventRepository([]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final subscription = container.listen(
          exploreFeedViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        await container.pump();
        await flushTestEventQueue();
        await container.pump();

        expect(subscription.read().hasValue, isTrue);
        expect(subscription.read().value!.items.map((item) => item.event.id), [
          'discoverable-enrichment',
        ]);

        personalEvents.add([joinedEvent]);
        await flushTestEventQueue();
        await container.pump();

        expect(subscription.read().value!.items.map((item) => item.event.id), [
          'joined-enrichment',
          'discoverable-enrichment',
        ]);
      },
    );

    test('exploreClubsViewModelProvider surfaces auth uid errors', () async {
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith(
            (ref) => Stream.error(StateError('uid failed')),
          ),
          filteredExploreClubsProvider.overrideWithValue(
            AsyncData([buildClub(id: 'available-club')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        exploreClubsViewModelProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await container.pump();

      expect(subscription.read().hasError, isTrue);
      expect(subscription.read().error, isA<StateError>());
    });

    test(
      'exploreClubsViewModelProvider surfaces filtered list errors',
      () async {
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            filteredExploreClubsProvider.overrideWithValue(
              AsyncError(StateError('filter failed'), StackTrace.empty),
            ),
          ],
        );
        addTearDown(container.dispose);

        final subscription = container.listen(
          exploreClubsViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        await container.pump();

        expect(subscription.read().hasError, isTrue);
        expect(subscription.read().error, isA<StateError>());
      },
    );
  });
}

class _FakeDeviceLocation extends DeviceLocation {
  _FakeDeviceLocation(this.location);

  final LocationCoordinate? location;

  @override
  Future<LocationCoordinate?> build() async => location;
}

class _FakeEventDiscoveryRepository extends Fake
    implements EventDiscoveryRepository {
  _FakeEventDiscoveryRepository(this.events);

  final List<Event> events;

  @override
  Future<List<Event>> fetchDiscoverableEvents(EventDiscoveryQuery query) async {
    return events;
  }
}

class _FakeExternalEventRepository extends Fake
    implements ExternalEventRepository {
  _FakeExternalEventRepository(this.events);

  final List<ExternalEvent> events;

  @override
  Future<List<ExternalEvent>> fetchDiscoverableExternalEvents(
    ExternalEventDiscoveryQuery query,
  ) async {
    return events;
  }
}

ExternalEvent _externalEvent({
  required String id,
  required String title,
  required String citySlug,
  required DateTime startTime,
  List<ExternalEventLink> externalLinks = const [
    ExternalEventLink(
      platform: 'luma',
      url: 'https://luma.com/e',
      linkType: 'booking_or_event_page',
      sourceEventKey: 'external-source-key',
      candidateId: 'candidate-external',
      primary: true,
    ),
  ],
}) {
  return ExternalEvent(
    id: id,
    canonicalHostId: 'host-afterfly',
    compatibilityClubId: 'club-afterfly',
    title: title,
    description: 'A reviewed external event.',
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 2)),
    meetingPoint: 'Bandra Amphitheatre',
    activityKind: ActivityKind.singlesMixer,
    interactionModel: EventInteractionModel.freeFormMixer,
    status: 'active',
    publicationStatus: 'public',
    citySlug: citySlug,
    externalLinks: externalLinks,
  );
}

class _FakeExploreSearchRepository implements ExploreSearchRepository {
  const _FakeExploreSearchRepository({this.error});

  final Object? error;

  @override
  Future<ExploreSearchResult> searchExplore({
    required String query,
    required String cityName,
    int limit = 20,
  }) async {
    final error = this.error;
    if (error != null) throw error;
    return ExploreSearchResult.empty;
  }
}
