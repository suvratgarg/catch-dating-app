import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/create/create_run_club_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_detail_controller.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'run_clubs_test_helpers.dart';

void main() {
  group('RunClub domain helpers', () {
    test('addMember adds a new member and normalizes memberCount', () {
      final club = buildRunClub(
        memberUserIds: const ['host-1'],
        memberCount: 99,
      );

      final updatedClub = club.addMember('runner-1');

      expect(updatedClub.memberUserIds, ['host-1', 'runner-1']);
      expect(updatedClub.memberCount, 2);
    });

    test('addMember is idempotent for existing members', () {
      final club = buildRunClub(memberUserIds: const ['host-1', 'runner-1']);

      final updatedClub = club.addMember('runner-1');

      expect(updatedClub.memberUserIds, club.memberUserIds);
      expect(updatedClub.memberCount, club.memberCount);
    });

    test('removeMember removes a member and never goes negative', () {
      final club = buildRunClub(
        memberUserIds: const ['host-1', 'runner-1'],
        memberCount: 99,
      );

      final updatedClub = club.removeMember('runner-1');

      expect(updatedClub.memberUserIds, ['host-1']);
      expect(updatedClub.memberCount, 1);
    });
  });

  group('RunClubDetailController', () {
    test('join forwards club and user ids to the repository', () async {
      final fakeRepository = FakeRunClubsRepository();
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-7')),
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
          .read(runClubDetailControllerProvider.notifier)
          .join('club-7');

      expect(fakeRepository.joinedClubId, 'club-7');
      expect(fakeRepository.joinedUserId, 'runner-7');
    });

    test('leave forwards club and user ids to the repository', () async {
      final fakeRepository = FakeRunClubsRepository();
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-9')),
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
          .read(runClubDetailControllerProvider.notifier)
          .leave('club-9');

      expect(fakeRepository.leftClubId, 'club-9');
      expect(fakeRepository.leftUserId, 'runner-9');
    });
  });

  group('RunClubDetailViewModel', () {
    test('builds derived state for hosts, members, and upcoming runs', () {
      final now = DateTime(2025, 1, 1, 9);
      final futureRun = buildRun(
        id: 'future-run',
        startTime: now.add(const Duration(hours: 2)),
      );
      final pastRun = buildRun(
        id: 'past-run',
        startTime: now.subtract(const Duration(hours: 2)),
      );
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(
          buildRunClub(
            hostUserId: 'host-1',
            memberUserIds: const ['host-1', 'runner-1'],
          ),
        ),
        runsAsync: AsyncData([futureRun, pastRun]),
        reviewsAsync: AsyncData([buildReview()]),
        appUserAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        now: now,
      );

      final vm = result.requireValue!;
      expect(vm.isHost, isFalse);
      expect(vm.isMember, isTrue);
      expect(vm.upcomingRuns.map((run) => run.id), ['future-run']);
      expect(vm.allRuns.map((run) => run.id), ['future-run', 'past-run']);
      expect(vm.reviews, hasLength(1));
    });

    test('returns loading while any dependency is still loading', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: const AsyncLoading(),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        appUserAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
      );

      expect(result.isLoading, isTrue);
    });

    test('returns null data when the club stream yields no club', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: const AsyncData(null),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        appUserAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
      );

      expect(result.value, isNull);
    });

    test('surfaces club stream errors', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncError(StateError('club failed'), StackTrace.empty),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        appUserAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces run stream errors', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(buildRunClub()),
        runsAsync: AsyncError(StateError('runs failed'), StackTrace.empty),
        reviewsAsync: const AsyncData(<Review>[]),
        appUserAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces review stream errors', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(buildRunClub()),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: AsyncError(
          StateError('reviews failed'),
          StackTrace.empty,
        ),
        appUserAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces uid stream errors', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(buildRunClub()),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        appUserAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: AsyncError(StateError('uid failed'), StackTrace.empty),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces downstream errors instead of silently swallowing them', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(buildRunClub()),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        appUserAsync: AsyncError(
          StateError('app user failed'),
          StackTrace.empty,
        ),
        uidAsync: const AsyncData('runner-1'),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });
  });

  group('CreateRunClubController', () {
    test('creates a club directly when there is no cover image', () async {
      final fakeRepository = FakeRunClubsRepository();
      final fakeImageUploadRepository = FakeImageUploadRepository();
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
          appUserStreamProvider.overrideWith(
            (ref) => Stream.value(
              buildUser(
                uid: 'host-1',
                name: 'Priya',
                photoUrls: const ['https://example.com/host.jpg'],
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final uidSubscription = container.listen(
        uidProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uidSubscription.close);
      final appUserSubscription = container.listen(
        appUserStreamProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(appUserSubscription.close);
      await container.pump();
      await container.pump();

      await container
          .read(createRunClubControllerProvider.notifier)
          .submit(
            name: 'Sunset Striders',
            location: buildRunClub().location,
            area: 'Bandra',
            description: 'Easy social club',
          );

      expect(fakeRepository.lastCreateCall, isNotNull);
      expect(fakeRepository.lastCreateCall!.clubId, fakeRepository.generatedId);
      expect(fakeRepository.lastCreateCall!.imageUrl, isNull);
      expect(fakeRepository.lastCreateCall!.hostName, 'Priya');
      expect(
        fakeRepository.lastCreateCall!.hostAvatarUrl,
        'https://example.com/host.jpg',
      );
      expect(fakeImageUploadRepository.lastUploadClubId, isNull);
    });

    test('uploads the cover image before creating the club', () async {
      final fakeRepository = FakeRunClubsRepository()..generatedId = 'club-42';
      final fakeImageUploadRepository = FakeImageUploadRepository(
        pickedImage: XFile('/tmp/club-cover.jpg'),
      );
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
          appUserStreamProvider.overrideWith(
            (ref) => Stream.value(buildUser(uid: 'host-1', name: 'Priya')),
          ),
        ],
      );
      addTearDown(container.dispose);
      final uidSubscription = container.listen(
        uidProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uidSubscription.close);
      final appUserSubscription = container.listen(
        appUserStreamProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(appUserSubscription.close);
      await container.pump();
      await container.pump();

      await container
          .read(createRunClubControllerProvider.notifier)
          .submit(
            name: 'Sunset Striders',
            location: buildRunClub().location,
            area: 'Bandra',
            description: 'Easy social club',
            coverImage: fakeImageUploadRepository.pickedImage,
          );

      expect(fakeImageUploadRepository.lastUploadClubId, 'club-42');
      expect(fakeRepository.lastCreateCall, isNotNull);
      expect(fakeRepository.lastCreateCall!.clubId, 'club-42');
      expect(
        fakeRepository.lastCreateCall!.imageUrl,
        fakeImageUploadRepository.uploadResult,
      );
    });

    test(
      'throws a helpful error when the user profile is unavailable',
      () async {
        final container = ProviderContainer(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
            appUserStreamProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );
        addTearDown(container.dispose);
        final uidSubscription = container.listen(
          uidProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(uidSubscription.close);
        final appUserSubscription = container.listen(
          appUserStreamProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(appUserSubscription.close);
        await container.pump();
        await container.pump();

        expect(
          () => container
              .read(createRunClubControllerProvider.notifier)
              .submit(
                name: 'Sunset Striders',
                location: buildRunClub().location,
                area: 'Bandra',
                description: 'Easy social club',
              ),
          throwsA(isA<StateError>()),
        );
      },
    );
  });
}
