import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'run_clubs_test_helpers.dart';

void main() {
  group('RunClubsList state', () {
    test(
      'selectedRunClubCityProvider defaults to Mumbai and clears search on change',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(selectedRunClubCityProvider), IndianCity.mumbai);

        container.read(runClubSearchQueryProvider.notifier).setQuery('stride');
        container
            .read(selectedRunClubCityProvider.notifier)
            .setCity(IndianCity.delhi);

        expect(container.read(selectedRunClubCityProvider), IndianCity.delhi);
        expect(container.read(runClubSearchQueryProvider), isEmpty);
      },
    );

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
            appUserStreamProvider.overrideWith(
              (ref) => Stream.value(
                buildUser(
                  uid: 'runner-1',
                  followedRunClubIds: const ['followed-club'],
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
        expect(viewModel.discoverClubs.map((club) => club.id), [
          'discover-club',
        ]);
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
          appUserStreamProvider.overrideWith(
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
            appUserStreamProvider.overrideWith(
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
    test('followClub joins the selected club for the signed-in user', () async {
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
          .followClub('club-123');

      expect(fakeRepository.joinedClubId, 'club-123');
      expect(fakeRepository.joinedUserId, 'runner-1');
    });

    test('followClub throws when there is no signed-in user', () async {
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
            .followClub('club-123'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
