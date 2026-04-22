import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_clubs_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunClubsListController', () {
    test('selectedRunClubCityProvider defaults to Mumbai and updates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedRunClubCityProvider), IndianCity.mumbai);

      container
          .read(selectedRunClubCityProvider.notifier)
          .setCity(IndianCity.delhi);

      expect(container.read(selectedRunClubCityProvider), IndianCity.delhi);
    });

    test('runClubsListViewModelProvider partitions joined and discover clubs', () async {
      final memberClub = _buildClub(
        id: 'member-club',
        memberUserIds: const ['runner-1'],
      );
      final followedClub = _buildClub(
        id: 'followed-club',
        hostUserId: 'host-2',
        memberUserIds: const ['host-2'],
      );
      final discoverClub = _buildClub(
        id: 'discover-club',
        hostUserId: 'host-3',
        memberUserIds: const ['host-3'],
      );

      final container = ProviderContainer(
        overrides: [
          appUserStreamProvider.overrideWith(
            (ref) => Stream.value(
              _buildUser(
                uid: 'runner-1',
                followedRunClubIds: const ['followed-club'],
              ),
            ),
          ),
          watchRunClubsByLocationProvider(
            IndianCity.mumbai,
          ).overrideWith(
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

      expect(
        viewModel.joinedClubs.map((club) => club.id),
        ['member-club', 'followed-club'],
      );
      expect(
        viewModel.discoverClubs.map((club) => club.id),
        ['discover-club'],
      );
    });
  });
}

RunClub _buildClub({
  required String id,
  String hostUserId = 'host-1',
  List<String> memberUserIds = const ['host-1'],
}) {
  return RunClub(
    id: id,
    name: 'Club $id',
    description: 'A city running club.',
    location: IndianCity.mumbai,
    area: 'Bandra',
    hostUserId: hostUserId,
    hostName: 'Host',
    createdAt: DateTime(2025, 1, 1),
    memberUserIds: memberUserIds,
  );
}

AppUser _buildUser({
  required String uid,
  List<String> followedRunClubIds = const [],
}) {
  return AppUser(
    uid: uid,
    email: '$uid@example.com',
    name: 'Runner $uid',
    dateOfBirth: DateTime(1995, 6, 15),
    bio: 'Here for the runs.',
    gender: Gender.man,
    sexualOrientation: SexualOrientation.straight,
    phoneNumber: '+10000000000',
    profileComplete: true,
    followedRunClubIds: followedRunClubIds,
    interestedInGenders: const [Gender.woman],
  );
}
