import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('filteredClubsProvider applies the normalized search query', () async {
      final bandraClub = buildClub(id: 'bandra-club', area: 'Bandra');
      final ashaClub = buildClub(
        id: 'asha-club',
        hostName: 'Asha',
        area: 'Juhu',
      );
      final container = ProviderContainer(
        overrides: [
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

    test('clubsListViewModelProvider surfaces auth uid errors', () async {
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith(
            (ref) => Stream.error(StateError('uid failed')),
          ),
          filteredClubsProvider.overrideWithValue(const AsyncData(<Club>[])),
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
