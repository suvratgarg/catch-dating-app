import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'run_clubs_test_helpers.dart';

CityData _cityFromEnum(IndianCity c) => CityData(
  name: c.name,
  label: c.label,
  latitude: c.latitude,
  longitude: c.longitude,
);

void main() {
  group('RunClubsList state', () {
    test(
      'selectedRunClubCityProvider defaults to Mumbai and clears search on change',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(selectedRunClubCityProvider), _cityFromEnum(IndianCity.mumbai));

        container.read(runClubSearchQueryProvider.notifier).setQuery('stride');
        container
            .read(selectedRunClubCityProvider.notifier)
            .setCity(_cityFromEnum(IndianCity.delhi));

        expect(container.read(selectedRunClubCityProvider), _cityFromEnum(IndianCity.delhi));
        expect(container.read(runClubSearchQueryProvider), isEmpty);
      },
    );

    test('autoSelectCity sets city when user has not made a manual pick', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedRunClubCityProvider), _cityFromEnum(IndianCity.mumbai));

      container
          .read(selectedRunClubCityProvider.notifier)
          .autoSelectCity(_cityFromEnum(IndianCity.delhi));

      expect(container.read(selectedRunClubCityProvider), _cityFromEnum(IndianCity.delhi));
    });

    test('autoSelectCity does not override a manual city choice', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(selectedRunClubCityProvider.notifier)
          .setCity(_cityFromEnum(IndianCity.bangalore));
      expect(container.read(selectedRunClubCityProvider), _cityFromEnum(IndianCity.bangalore));

      container
          .read(selectedRunClubCityProvider.notifier)
          .autoSelectCity(_cityFromEnum(IndianCity.mumbai));
      expect(
        container.read(selectedRunClubCityProvider),
        _cityFromEnum(IndianCity.bangalore),
      );
    });

    test('setCity clears search query while autoSelectCity also clears it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(runClubSearchQueryProvider.notifier).setQuery('stride');
      container
          .read(selectedRunClubCityProvider.notifier)
          .autoSelectCity(_cityFromEnum(IndianCity.delhi));

      expect(container.read(runClubSearchQueryProvider), isEmpty);
    });

    test('matchesRunClubSearchQuery matches name, area, host, and tags', () {
      final bandraClub = buildRunClub(
        id: 'club-1',
        name: 'Stride Social',
        area: 'Bandra',
      );
      final hostClub = buildRunClub(
        id: 'club-2',
        name: 'Sunrise Crew',
        hostName: 'Asha',
      );
      final taggedClub = buildRunClub(
        id: 'club-3',
        name: 'Night Pacers',
        tags: const ['tempo', 'community'],
      );

      expect(matchesRunClubSearchQuery(bandraClub, 'bandra'), isTrue);
      expect(matchesRunClubSearchQuery(hostClub, 'asha'), isTrue);
      expect(matchesRunClubSearchQuery(taggedClub, 'tempo'), isTrue);
      expect(matchesRunClubSearchQuery(taggedClub, 'missing'), isFalse);
    });

    test(
      'runClubsListViewModelProvider partitions joined and discover clubs',
      () async {
        final memberClub = buildRunClub(
          id: 'member-club',
          memberUserIds: const ['runner-1'],
        );
        final followedClub = buildRunClub(
          id: 'followed-club',
          hostUserId: 'host-2',
          memberUserIds: const ['host-2'],
        );
        final discoverClub = buildRunClub(
          id: 'discover-club',
          hostUserId: 'host-3',
          memberUserIds: const ['host-3'],
        );

        final container = ProviderContainer(
          overrides: [
            watchUserProfileProvider.overrideWith(
              (ref) => Stream.value(
                buildUser(
                  uid: 'runner-1',
                  joinedRunClubIds: const ['followed-club'],
                ),
              ),
            ),
            watchRunClubsByLocationProvider(IndianCity.mumbai).overrideWith(
              (ref) => Stream.value([memberClub, followedClub, discoverClub]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final subscription = container.listen(
          runClubsListViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        final viewModel = subscription.read().value!;

        expect(viewModel.joinedClubs.map((club) => club.id), [
          'member-club',
          'followed-club',
        ]);
        expect(viewModel.allClubs.map((club) => club.id), [
          'member-club',
          'followed-club',
          'discover-club',
        ]);
        expect(viewModel.joinedClubIds, {'member-club', 'followed-club'});
      },
    );

    test(
      'filteredRunClubsProvider applies the normalized search query',
      () async {
        final bandraClub = buildRunClub(id: 'bandra-club', area: 'Bandra');
        final ashaClub = buildRunClub(
          id: 'asha-club',
          hostName: 'Asha',
          area: 'Juhu',
        );
        final container = ProviderContainer(
          overrides: [
            watchRunClubsByLocationProvider(
              IndianCity.mumbai,
            ).overrideWith((ref) => Stream.value([bandraClub, ashaClub])),
          ],
        );
        addTearDown(container.dispose);
        container.read(runClubSearchQueryProvider.notifier).setQuery('  asha');

        final subscription = container.listen(
          filteredRunClubsProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        await container.pump();

        expect(subscription.read().value, [ashaClub]);
      },
    );

    test('runClubsListViewModelProvider surfaces app user errors', () async {
      final container = ProviderContainer(
        overrides: [
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.error(StateError('user failed')),
          ),
          filteredRunClubsProvider.overrideWithValue(
            const AsyncData(<RunClub>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        runClubsListViewModelProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await container.pump();

      expect(subscription.read().hasError, isTrue);
      expect(subscription.read().error, isA<StateError>());
    });

    test(
      'runClubsListViewModelProvider surfaces filtered list errors',
      () async {
        final container = ProviderContainer(
          overrides: [
            watchUserProfileProvider.overrideWith(
              (ref) => Stream.value(buildUser(uid: 'runner-1')),
            ),
            filteredRunClubsProvider.overrideWithValue(
              AsyncError(StateError('filter failed'), StackTrace.empty),
            ),
          ],
        );
        addTearDown(container.dispose);

        final subscription = container.listen(
          runClubsListViewModelProvider,
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

  group('RunClubsListController', () {
    test('joinClub joins the selected club for the signed-in user', () async {
      final fakeRepository = FakeRunClubsRepository();
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        ],
      );
      addTearDown(container.dispose);
      final uidSubscription = container.listen(
        uidProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uidSubscription.close);
      await container.pump();
      await container
          .read(runClubsListControllerProvider.notifier)
          .joinClub('club-123');

      expect(fakeRepository.joinedClubId, 'club-123');
      expect(fakeRepository.joinedUserId, 'runner-1');
    });

    test('joinClub throws when there is no signed-in user', () async {
      final container = ProviderContainer(
        overrides: [uidProvider.overrideWith((ref) => Stream.value(null))],
      );
      addTearDown(container.dispose);
      final uidSubscription = container.listen(
        uidProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uidSubscription.close);
      await container.pump();

      expect(
        () => container
            .read(runClubsListControllerProvider.notifier)
            .joinClub('club-123'),
        throwsA(isA<SignInRequiredException>()),
      );
    });
  });
}
