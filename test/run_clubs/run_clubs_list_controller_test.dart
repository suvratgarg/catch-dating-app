import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';
import 'run_clubs_test_helpers.dart';

CityData _city(String name) => cityOptionByName(name)!.toCityData();

RunClubMembership _membership({
  required String clubId,
  String uid = 'runner-1',
}) => RunClubMembership(
  id: runClubMembershipId(clubId: clubId, uid: uid),
  clubId: clubId,
  uid: uid,
  role: RunClubMembershipRole.member,
  status: RunClubMembershipStatus.active,
  joinedAt: DateTime(2026, 1, 1),
);

void main() {
  group('RunClubsList state', () {
    test(
      'selectedRunClubCityProvider defaults to Mumbai and clears search on change',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(selectedRunClubCityProvider), _city('mumbai'));

        container.read(runClubSearchQueryProvider.notifier).setQuery('stride');
        container
            .read(selectedRunClubCityProvider.notifier)
            .setCity(_city('delhi'));

        expect(container.read(selectedRunClubCityProvider), _city('delhi'));
        expect(container.read(runClubSearchQueryProvider), isEmpty);
      },
    );

    test('autoSelectCity sets city when user has not made a manual pick', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedRunClubCityProvider), _city('mumbai'));

      container
          .read(selectedRunClubCityProvider.notifier)
          .autoSelectCity(_city('delhi'));

      expect(container.read(selectedRunClubCityProvider), _city('delhi'));
    });

    test('autoSelectCity does not override a manual city choice', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(selectedRunClubCityProvider.notifier)
          .setCity(_city('bangalore'));
      expect(container.read(selectedRunClubCityProvider), _city('bangalore'));

      container
          .read(selectedRunClubCityProvider.notifier)
          .autoSelectCity(_city('mumbai'));
      expect(container.read(selectedRunClubCityProvider), _city('bangalore'));
    });

    test('setCity clears search query while autoSelectCity also clears it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(runClubSearchQueryProvider.notifier).setQuery('stride');
      container
          .read(selectedRunClubCityProvider.notifier)
          .autoSelectCity(_city('delhi'));

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
        final memberClub = buildRunClub(id: 'member-club');
        final followedClub = buildRunClub(
          id: 'followed-club',
          hostUserId: 'host-2',
        );
        final discoverClub = buildRunClub(
          id: 'discover-club',
          hostUserId: 'host-3',
        );
        final hostedClub = buildRunClub(
          id: 'hosted-club',
          hostUserId: 'runner-1',
        );

        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            watchActiveRunClubMembershipsForUserProvider(
              'runner-1',
            ).overrideWith(
              (ref) => Stream.value([
                _membership(clubId: 'member-club'),
                _membership(clubId: 'followed-club'),
              ]),
            ),
            watchRunClubsByLocationProvider('mumbai').overrideWith(
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
          runClubsListViewModelProvider,
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
              'mumbai',
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

    test('runClubsListViewModelProvider surfaces auth uid errors', () async {
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith(
            (ref) => Stream.error(StateError('uid failed')),
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
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
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
