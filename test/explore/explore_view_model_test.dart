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
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_filter_logic.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/search/data/explore_search_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart';
import '../events/events_test_helpers.dart' as event_test;
import '../test_pump_helpers.dart';

CityData _city(String name) => cityOptionByName(name)!.toCityData();

ClubMembership _membership({required String clubId, String uid = 'runner-1'}) =>
    ClubMembership(
      id: clubMembershipId(clubId: clubId, uid: uid),
      clubId: clubId,
      uid: uid,
      role: ClubMembershipRole.member,
      status: ClubMembershipStatus.active,
      joinedAt: DateTime(2026),
    );

void main() {
  group('Explore state', () {
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
      'exploreViewModelProvider partitions joined and discover clubs',
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
            watchClubsByLocationProvider('mumbai').overrideWith(
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
          exploreViewModelProvider,
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
      'exploreViewModelProvider shows empty city without waiting for auth',
      () async {
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => const Stream.empty()),
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value(const <Club>[])),
          ],
        );
        addTearDown(container.dispose);

        final subscription = container.listen(
          exploreViewModelProvider,
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
              'mumbai',
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
              'mumbai',
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
              'mumbai',
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
              'mumbai',
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
              'mumbai',
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

    test('exploreViewModelProvider surfaces auth uid errors', () async {
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
        exploreViewModelProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await container.pump();

      expect(subscription.read().hasError, isTrue);
      expect(subscription.read().error, isA<StateError>());
    });

    test('exploreViewModelProvider surfaces filtered list errors', () async {
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
        exploreViewModelProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await container.pump();

      expect(subscription.read().hasError, isTrue);
      expect(subscription.read().error, isA<StateError>());
    });
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
    externalLinks: const [
      ExternalEventLink(
        platform: 'luma',
        url: 'https://luma.com/e',
        linkType: 'booking_or_event_page',
        sourceEventKey: 'external-source-key',
        candidateId: 'candidate-external',
        primary: true,
      ),
    ],
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
