import 'dart:typed_data';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:catch_dating_app/run_clubs/presentation/create/create_run_club_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_detail_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_membership_controller.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'run_clubs_test_helpers.dart';

RunClubMembership _membership({
  String clubId = 'club-1',
  String uid = 'runner-1',
  RunClubMembershipStatus status = RunClubMembershipStatus.active,
}) => RunClubMembership(
  id: runClubMembershipId(clubId: clubId, uid: uid),
  clubId: clubId,
  uid: uid,
  role: RunClubMembershipRole.member,
  status: status,
  joinedAt: DateTime(2026, 1, 1),
);

void main() {
  group('RunClubMembershipController', () {
    test('join requires sign-in and forwards the club id', () async {
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
          .read(runClubMembershipControllerProvider.notifier)
          .join('club-7');

      expect(fakeRepository.joinedClubId, 'club-7');
    });

    test('join throws when there is no signed-in user', () async {
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
            .read(runClubMembershipControllerProvider.notifier)
            .join('club-123'),
        throwsA(isA<SignInRequiredException>()),
      );
    });

    test('leave requires sign-in and forwards the club id', () async {
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
          .read(runClubMembershipControllerProvider.notifier)
          .leave('club-9');

      expect(fakeRepository.leftClubId, 'club-9');
    });

    test('setPushNotifications forwards the club id and preference', () async {
      final fakeRepository = FakeRunClubsRepository();
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-10')),
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
          .read(runClubMembershipControllerProvider.notifier)
          .setPushNotifications(clubId: 'club-10', enabled: true);

      expect(fakeRepository.notificationsClubId, 'club-10');
      expect(fakeRepository.notificationsEnabled, isTrue);
    });
  });

  group('RunClubDetailViewModel', () {
    test('builds derived state for hosts, members, and upcoming runs', () {
      final now = DateTime(2025, 1, 1, 9);
      final futureRun = buildRun(
        id: 'future-run',
        startTime: now.add(const Duration(hours: 2)),
      );
      final soonerFutureRun = buildRun(
        id: 'sooner-future-run',
        startTime: now.add(const Duration(hours: 1)),
      );
      final pastRun = buildRun(
        id: 'past-run',
        startTime: now.subtract(const Duration(hours: 2)),
      );
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(buildRunClub(hostUserId: 'host-1')),
        runsAsync: AsyncData([futureRun, pastRun, soonerFutureRun]),
        reviewsAsync: AsyncData([buildReview()]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: AsyncData(_membership()),
        now: now,
      );

      final vm = result.requireValue!;
      expect(vm.isHost, isFalse);
      expect(vm.isMember, isTrue);
      expect(vm.upcomingRuns.map((run) => run.id), [
        'sooner-future-run',
        'future-run',
      ]);
      expect(vm.reviews, hasLength(1));
    });

    test('returns loading while a core dependency is still loading', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: const AsyncLoading(),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.isLoading, isTrue);
    });

    test('keeps schedule visible while secondary auth data hydrates', () {
      final now = DateTime(2025, 1, 1, 9);
      final futureRun = buildRun(
        id: 'future-run',
        startTime: now.add(const Duration(hours: 1)),
      );

      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(buildRunClub(hostUserId: 'host-1')),
        runsAsync: AsyncData([futureRun]),
        reviewsAsync: const AsyncLoading(),
        userProfileAsync: const AsyncLoading(),
        uidAsync: const AsyncData('host-1'),
        membershipAsync: const AsyncLoading(),
        now: now,
      );

      final vm = result.requireValue!;
      expect(vm.isHost, isTrue);
      expect(vm.upcomingRuns.map((run) => run.id), ['future-run']);
      expect(vm.reviews, isEmpty);
      expect(vm.userProfile, isNull);
      expect(vm.isMember, isFalse);
    });

    test('returns null data when the club stream yields no club', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: const AsyncData(null),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.value, isNull);
    });

    test('surfaces club stream errors', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncError(StateError('club failed'), StackTrace.empty),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces run stream errors', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(buildRunClub()),
        runsAsync: AsyncError(StateError('runs failed'), StackTrace.empty),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('uses empty reviews when the review stream is unavailable', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(buildRunClub()),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: AsyncError(
          StateError('reviews failed'),
          StackTrace.empty,
        ),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.requireValue!.reviews, isEmpty);
    });

    test('surfaces uid stream errors', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(buildRunClub()),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: AsyncError(StateError('uid failed'), StackTrace.empty),
        membershipAsync: const AsyncData(null),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('uses null profile when profile stream is unavailable', () {
      final result = buildRunClubDetailViewModel(
        clubAsync: AsyncData(buildRunClub()),
        runsAsync: const AsyncData(<Run>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncError(
          StateError('app user failed'),
          StackTrace.empty,
        ),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.requireValue!.userProfile, isNull);
    });
  });

  group('CreateRunClubController', () {
    test('picks a cover image and reads preview bytes', () async {
      final image = XFile.fromData(
        Uint8List.fromList(const [1, 2, 3]),
        name: 'club-cover.png',
      );
      final fakeImageUploadRepository = FakeImageUploadRepository(
        pickedImage: image,
      );
      final container = ProviderContainer(
        overrides: [
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final picked = await container
          .read(createRunClubControllerProvider.notifier)
          .pickCoverImage();

      expect(picked?.image, image);
      expect(picked?.bytes, [1, 2, 3]);
    });

    test(
      'creates a club through the repository when there is no cover image',
      () async {
        final fakeRepository = FakeRunClubsRepository();
        final fakeImageUploadRepository = FakeImageUploadRepository();
        final container = ProviderContainer(
          overrides: [
            runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
            imageUploadRepositoryProvider.overrideWith(
              (ref) => fakeImageUploadRepository,
            ),
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
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
            .read(createRunClubControllerProvider.notifier)
            .submit(
              name: 'Sunset Striders',
              location: buildRunClub().location,
              area: 'Bandra',
              description: 'Easy social club',
            );

        expect(fakeRepository.lastCreateCall, isNotNull);
        expect(
          fakeRepository.lastCreateCall!.clubId,
          fakeRepository.generatedId,
        );
        expect(fakeRepository.lastCreateCall!.imageUrl, isNull);
        expect(fakeImageUploadRepository.lastUploadClubId, isNull);
      },
    );

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
          watchUserProfileProvider.overrideWith(
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
      final userProfileSubscription = container.listen(
        watchUserProfileProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(userProfileSubscription.close);
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

    test('creates a club without requiring profile state', () async {
      final fakeRepository = FakeRunClubsRepository();
      final fakeImageUploadRepository = FakeImageUploadRepository();
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
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
          .read(createRunClubControllerProvider.notifier)
          .submit(
            name: 'Sunset Striders',
            location: buildRunClub().location,
            area: 'Bandra',
            description: 'Easy social club',
          );

      expect(fakeRepository.lastCreateCall, isNotNull);
      expect(fakeRepository.lastCreateCall!.clubId, fakeRepository.generatedId);
    });

    test('updates an existing club without requiring profile state', () async {
      final existingClub = buildRunClub(
        id: 'club-1',
        name: 'Old Name',
        description: 'Old description',
        area: 'Bandra',
        imageUrl: 'https://example.com/old.jpg',
        memberCount: 2,
        rating: 4.5,
        reviewCount: 8,
        nextRunLabel: 'Sat 6:30 AM',
      );
      final fakeRepository = FakeRunClubsRepository();
      final fakeImageUploadRepository = FakeImageUploadRepository();
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
          watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
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
          .read(createRunClubControllerProvider.notifier)
          .submit(
            name: 'New Name',
            location: 'indore',
            area: 'Vijay Nagar',
            description: 'Updated description',
            existingRunClub: existingClub,
          );

      expect(fakeRepository.lastUpdatedClubId, existingClub.id);
      final fields = fakeRepository.lastUpdatedFields;
      expect(fields, isNotNull);
      expect(fields!['name'], 'New Name');
      expect(fields['location'], 'indore');
      expect(fields['area'], 'Vijay Nagar');
      expect(fields['description'], 'Updated description');
      // When no new cover is uploaded, imageUrl stays as the existing one.
      expect(fields['imageUrl'], existingClub.imageUrl);
      expect(fakeImageUploadRepository.lastUploadClubId, isNull);
    });

    test('uploads a replacement cover when editing with a new image', () async {
      final existingClub = buildRunClub(
        id: 'club-1',
        imageUrl: 'https://example.com/old.jpg',
      );
      final fakeRepository = FakeRunClubsRepository();
      final fakeImageUploadRepository = FakeImageUploadRepository(
        pickedImage: XFile('/tmp/club-cover.jpg'),
        uploadResult: 'https://example.com/new.jpg',
      );
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
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
          .read(createRunClubControllerProvider.notifier)
          .submit(
            name: existingClub.name,
            location: existingClub.location,
            area: existingClub.area,
            description: existingClub.description,
            existingRunClub: existingClub,
            coverImage: fakeImageUploadRepository.pickedImage,
          );

      expect(fakeImageUploadRepository.lastUploadClubId, 'club-1');
      expect(
        fakeRepository.lastUpdatedFields!['imageUrl'],
        'https://example.com/new.jpg',
      );
    });

    test('rejects editing by a non-host user', () async {
      final container = ProviderContainer(
        overrides: [
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

      expect(
        () => container
            .read(createRunClubControllerProvider.notifier)
            .submit(
              name: 'New Name',
              location: 'mumbai',
              area: 'Bandra',
              description: 'Updated description',
              existingRunClub: buildRunClub(hostUserId: 'host-1'),
            ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
