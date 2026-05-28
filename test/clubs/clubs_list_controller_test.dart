import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_discovery_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/saved_event.dart';
import 'package:catch_dating_app/events/domain/viewer_event_availability.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/search/data/explore_search_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart' as event_test;
import '../test_pump_helpers.dart';
import 'clubs_test_helpers.dart';

CityData _city(String name) => cityOptionByName(name)!.toCityData();

ClubMembership _membership({required String clubId, String uid = 'runner-1'}) =>
    ClubMembership(
      id: clubMembershipId(clubId: clubId, uid: uid),
      clubId: clubId,
      uid: uid,
      role: ClubMembershipRole.member,
      status: ClubMembershipStatus.active,
      joinedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('ClubsList state', () {
    test(
      'selectedClubCityProvider defaults to Mumbai and clears search on change',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(selectedClubCityProvider), _city('mumbai'));

        container.read(clubSearchQueryProvider.notifier).setQuery('stride');
        container
            .read(selectedClubCityProvider.notifier)
            .setCity(_city('delhi'));

        expect(container.read(selectedClubCityProvider), _city('delhi'));
        expect(container.read(clubSearchQueryProvider), isEmpty);
        expect(container.read(selectedClubCityWasUserSelectedProvider), true);
      },
    );

    test('autoSelectCity sets city when user has not made a manual pick', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedClubCityProvider), _city('mumbai'));

      container
          .read(selectedClubCityProvider.notifier)
          .autoSelectCity(_city('delhi'));

      expect(container.read(selectedClubCityProvider), _city('delhi'));
      expect(container.read(selectedClubCityWasUserSelectedProvider), false);
    });

    test('autoSelectCityByName uses known profile cities', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(selectedClubCityProvider.notifier)
          .autoSelectCityByName('indore');

      expect(container.read(selectedClubCityProvider), _city('indore'));
    });

    test('autoSelectCity does not override a manual city choice', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(selectedClubCityProvider.notifier)
          .setCity(_city('bangalore'));
      expect(container.read(selectedClubCityProvider), _city('bangalore'));

      container
          .read(selectedClubCityProvider.notifier)
          .autoSelectCity(_city('mumbai'));
      expect(container.read(selectedClubCityProvider), _city('bangalore'));
    });

    test('setCity clears search query while autoSelectCity also clears it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(clubSearchQueryProvider.notifier).setQuery('stride');
      container
          .read(selectedClubCityProvider.notifier)
          .autoSelectCity(_city('delhi'));

      expect(container.read(clubSearchQueryProvider), isEmpty);
    });

    test('setCity clears city-local filters but keeps global filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filters = container.read(clubBrowseFiltersProvider.notifier);
      filters.toggleThisWeekOnly();
      filters.toggleHighRatedOnly();
      filters.toggleDistanceFilter(ExploreDistanceFilter.threeKm);
      filters.toggleActivityTag('tempo');
      filters.toggleArea('Bandra');

      container.read(selectedClubCityProvider.notifier).setCity(_city('delhi'));

      final selection = container.read(clubBrowseFiltersProvider);
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
      expect(weekend.end, DateTime(2026, 6, 1));

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

    test('matchesClubSearchQuery matches name, area, host, and tags', () {
      final bandraClub = buildClub(
        id: 'club-1',
        name: 'Stride Social',
        area: 'Bandra',
      );
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

      expect(matchesClubSearchQuery(bandraClub, 'bandra'), isTrue);
      expect(matchesClubSearchQuery(hostClub, 'asha'), isTrue);
      expect(matchesClubSearchQuery(taggedClub, 'tempo'), isTrue);
      expect(matchesClubSearchQuery(taggedClub, 'missing'), isFalse);
    });

    test('applyClubBrowseFilters combines quick filters', () {
      final now = DateTime(2026, 1, 1, 8);
      final matchingClub = buildClub(
        id: 'matching-club',
        area: 'Bandra',
        tags: const ['tempo'],
        rating: 4.8,
        nextEventAt: now.add(const Duration(days: 2)),
      );
      final staleEventClub = buildClub(
        id: 'stale-event-club',
        area: 'Bandra',
        tags: const ['tempo'],
        rating: 4.9,
        nextEventAt: now.subtract(const Duration(hours: 1)),
      );
      final lowRatedClub = buildClub(
        id: 'low-rated-club',
        area: 'Bandra',
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

      final filtered = applyClubBrowseFilters(
        clubs: [matchingClub, staleEventClub, lowRatedClub, wrongAreaClub],
        filters: const ClubBrowseFilterSelection(
          timeFilter: ExploreTimeFilter.thisWeek,
          highRatedOnly: true,
          joinedOnly: true,
          hostedOnly: true,
          activityTag: 'Tempo',
          area: 'bandra',
        ),
        joinedClubIds: {'matching-club', 'stale-event-club', 'wrong-area-club'},
        hostedClubIds: {'matching-club', 'low-rated-club'},
        now: now,
      );

      expect(filtered.map((club) => club.id), ['matching-club']);
    });

    test('applyClubBrowseFilters uses the selected time window', () {
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

      final filtered = applyClubBrowseFilters(
        clubs: [tonightClub, tomorrowClub, weekendClub],
        filters: const ClubBrowseFilterSelection(
          timeFilter: ExploreTimeFilter.weekend,
        ),
        joinedClubIds: const {},
        hostedClubIds: const {},
        now: now,
      );

      expect(filtered.map((club) => club.id), ['weekend-club']);
    });

    test(
      'mergeExploreSourceClubs keeps hosted clubs outside the city feed',
      () {
        final cityClub = buildClub(id: 'city-club', location: 'mumbai');
        final hostedClub = buildClub(
          id: 'hosted-club',
          location: 'indore',
          hostUserId: 'runner-1',
        );
        final ownedClub = buildClub(
          id: 'owned-club',
          location: 'delhi',
          ownerUserId: 'runner-1',
        );

        final merged = mergeExploreSourceClubs(
          locationClubs: [cityClub],
          hostedClubs: [hostedClub],
          ownedClubs: [ownedClub],
        );

        expect(merged.map((club) => club.id), [
          'city-club',
          'hosted-club',
          'owned-club',
        ]);
      },
    );

    test(
      'clubsListViewModelProvider partitions joined and discover clubs',
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
            watchClubsHostedByProvider(
              'runner-1',
            ).overrideWith((ref) => Stream.value([hostedClub])),
            watchClubsOwnedByProvider(
              'runner-1',
            ).overrideWith((ref) => Stream.value(const <Club>[])),
          ],
        );
        addTearDown(container.dispose);

        final subscription = container.listen(
          clubsListViewModelProvider,
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
          'hosted-club',
        ]);
        expect(viewModel.allClubs.map((club) => club.id), [
          'member-club',
          'followed-club',
          'discover-club',
          'hosted-club',
        ]);
        expect(viewModel.joinedClubIds, {
          'member-club',
          'followed-club',
          'hosted-club',
        });
        expect(viewModel.hostedClubIds, {'hosted-club'});
      },
    );

    test(
      'clubsListViewModelProvider shows empty city without waiting for auth',
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
          clubsListViewModelProvider,
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

    test('filteredClubsProvider applies the normalized search query', () async {
      final bandraClub = buildClub(id: 'bandra-club', area: 'Bandra');
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
      container.read(clubSearchQueryProvider.notifier).setQuery('  asha');

      final subscription = container.listen(
        filteredClubsProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await container.pump();

      expect(subscription.read().value, [ashaClub]);
    });

    test(
      'exploreFeedViewModelProvider filters events by device distance',
      () async {
        final club = buildClub(id: 'club-distance', location: 'mumbai');
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
            deviceLocationProvider.overrideWith(
              () => _FakeDeviceLocation(const LocationCoordinate(19.0, 72.0)),
            ),
          ],
        );
        addTearDown(container.dispose);
        container
            .read(clubBrowseFiltersProvider.notifier)
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
      'exploreFeedViewModelProvider resolves viewer-specific availability',
      () async {
        final user = event_test.buildUser(uid: 'runner-1');
        final club = buildClub(id: 'club-availability', location: 'mumbai');
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
            watchClubsHostedByProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value(const <Club>[])),
            watchClubsOwnedByProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value(const <Club>[])),
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
        final club = buildClub(id: 'club-enrichment', location: 'mumbai');
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
            watchClubsHostedByProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value(const <Club>[])),
            watchClubsOwnedByProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value(const <Club>[])),
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

    test('clubsListViewModelProvider surfaces auth uid errors', () async {
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith(
            (ref) => Stream.error(StateError('uid failed')),
          ),
          filteredClubsProvider.overrideWithValue(
            AsyncData([buildClub(id: 'available-club')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        clubsListViewModelProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await container.pump();

      expect(subscription.read().hasError, isTrue);
      expect(subscription.read().error, isA<StateError>());
    });

    test('clubsListViewModelProvider surfaces filtered list errors', () async {
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          filteredClubsProvider.overrideWithValue(
            AsyncError(StateError('filter failed'), StackTrace.empty),
          ),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        clubsListViewModelProvider,
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
